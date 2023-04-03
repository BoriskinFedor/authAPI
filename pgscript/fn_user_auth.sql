create or replace function api.fn_user_auth(
    arg_login varchar,
    arg_password varchar
)
returns bytea
as
$body$
declare
    LOG_ACTION_AUTH_SUCCESS integer = (select q.id from api.t_user_log_action q where q.code = 'auth_success' limit 1);
    LOG_ACTION_AUTH_FAIL    integer = (select q.id from api.t_user_log_action q where q.code = 'auth_fail' limit 1);
    LOG_ACTION_USER_BLOCK   integer = (select q.id from api.t_user_log_action q where q.code = 'user_block' limit 1);

    SESSION_DEFAULT integer = (select q.id from api.t_session_type q where q.code = 'default' limit 1);

    v_current_ts timestamp = now()::timestamp;
    v_user_id integer;
    v_failed_pass_limit integer = 5;
    v_failed_pass_count integer;
    v_is_correct_password boolean;
    v_token bytea = sha256(now()::timestamp::varchar::bytea);
    v_session_id integer;
begin
    arg_login    = trim(arg_login);
    arg_password = trim(arg_password);

    select
        u.id,
        coalesce(u.failed_pass_count, 0),
        sha256(concat(arg_password, u.password_salt))::varchar = u.password
    from basis.t_user u
    where u.login = arg_login
    into
        v_user_id,
        v_failed_pass_count,
        v_is_correct_password;
    
    if not found then
        raise exception 'API_ERROR Ошибка авторизации. Проверьте корректность логина и пароля';
    end if;

    if v_failed_pass_count >= v_failed_pass_limit then
        raise exception 'API_ERROR Превышено максимальное количество попыток авторизации';
    end if;

    if coalesce(v_is_correct_password, false) then
        v_failed_pass_count = 0;

        update basis.t_user u set
            failed_pass_count = v_failed_pass_count
        where u.login = arg_login;

        insert into api.t_session(
            user_id,
            create_ts,
            token,
            type_id     
        )
        values(
            v_user_id,
            v_current_ts,
            v_token,
            SESSION_DEFAULT
        )
        returning id
        into v_session_id;

        insert into api.t_user_log(
            user_id,
            create_ts,
            action_id,
            session_id
        )
        values(
            v_user_id,
            v_current_ts,
            LOG_ACTION_AUTH_SUCCESS,
            v_session_id
        );
    else
        v_failed_pass_count = v_failed_pass_count + 1;

        update basis.t_user u set
            failed_pass_count = v_failed_pass_count
        where u.login = arg_login;

        if v_failed_pass_count = v_failed_pass_limit then
            insert into api.t_user_log(
                user_id,
                create_ts,
                action_id
            )
            values(
                v_user_id,
                v_current_ts,
                LOG_ACTION_USER_BLOCK
            );
        else
            insert into api.t_user_log(
                user_id,
                create_ts,
                action_id
            )
            values(
                v_user_id,
                v_current_ts,
                LOG_ACTION_AUTH_FAIL
            );
        end if;

        raise exception 'API_ERROR Ошибка авторизации. Проверьте корректность логина и пароля';
    end if;

    return v_token;
end;
$body$
language plpgsql;
alter function api.fn_user_auth(varchar, varchar) owner to postgres;

grant execute on function api.fn_user_auth(varchar, varchar) to postgres;
grant execute on function api.fn_user_auth(varchar, varchar) to api_caller;
revoke all on function api.fn_user_auth(varchar, varchar) from public;

comment on function api.fn_user_auth(varchar, varchar) is 'Авторизация пользователя';