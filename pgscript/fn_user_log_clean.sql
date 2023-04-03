create or replace function api.fn_user_log_clean(
    arg_token bytea
)
returns void
as
$body$
declare
    v_user_id integer;
begin
    if arg_token is null then
        raise exception 'API_ERROR Ошибка параметра';
    end if;

    select s.user_id
    from api.t_session s
    join api.t_session_type st on
        st.id = s.type_id
    where
        s.token = arg_token and
        (s.create_ts + st.duration)::timestamp < now()::timestamp
    into v_user_id;

    delete from api.t_user_log l
    where l.user_id = v_user_id;
end;
$body$
language plpgsql;
alter function api.fn_user_log_clean(bytea) owner to postgres;

grant execute on function api.fn_user_log_clean(bytea) to postgres;
grant execute on function api.fn_user_log_clean(bytea) to api_caller;
revoke all on function api.fn_user_log_clean(bytea) from public;

comment on function api.fn_user_log_clean(bytea) is 'Очистка лога авторизации пользователя';
