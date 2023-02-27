create or replace function api.fn_user_auth(
    arg_login varchar,
    arg_password varchar
)
returns varchar
as
$body$
declare
    v_current_ts timestamp = now()::timestamp;
    v_failed_pass_limit integer = 5;
    v_user_id integer;
    v_failed_pass_count integer;
    v_is_correct_password boolean = false;
    v_token varchar = right(sha256(v_current_ts::varchar::bytea)::varchar, 64);
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
    else
        if v_failed_pass_count >= v_failed_pass_limit then
            raise exception 'API_ERROR Превышено количество попыток авторизации';
        elsif not v_is_correct_password then
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
                    QQQ_BLOCK
                );
            end if;

            raise exception 'API_ERROR Ошибка авторизации. Проверьте корректность логина и пароля';
        end if;
    end if;

    update basis.t_user u set
        failed_pass_count = 0
    where u.login = arg_login;

    insert into api.t_user_log(
        user_id,
        create_ts,
        action_id
    )
    values(
        v_user_id,
        v_current_ts,
        QQQ_AUTH
    );

    insert into api.t_session(
        user_id,
        create_ts,
        token,
        session_type_id
    )
    values(
        v_user_id,
        v_current_ts,
        v_token,
        QQQ_TWO_MINUTES
    );

    return v_token;
end;
$body$
language plpgsql;
alter function api.fn_user_auth(varchar, varchar) owner to postgres;

grant execute on function api.fn_user_auth(varchar, varchar) to postgres;
grant execute on function api.fn_user_auth(varchar, varchar) to api_caller;
revoke all on function api.fn_user_auth(varchar, varchar) from public;

comment on function api.fn_user_auth(varchar, varchar) is 'Авторизация пользователя';