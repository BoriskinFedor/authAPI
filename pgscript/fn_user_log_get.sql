create or replace function api.fn_user_log_get(
    arg_token varchar
)
returns jsonb
as
$body$
declare
    v_user_id integer;
    v_result jsonb;
begin
    arg_token = trim(arg_token);

    if coalesce(arg_token, '') = '' then
        raise exception 'API_ERROR Ошибка параметра';
    end if;

    select s.user_id
    from api.t_session s
    join api.t_session_type st on
        st.id = s.type_id
    where
        s.token = arg_token and
        (s.create_ts + st.duration)::timestamp > now()::timestamp
    into v_user_id;

    select jsonb_agg(r)
    from (
        select
            l.create_ts as log_ts,
            la.name as log_action
        from api.t_user_log l
        join api.t_user_log_action la on
            la.id = l.action_id
        where l.user_id = v_user_id
        order by l.create_ts desc
    ) r
    into v_result;

    return v_result;
end;
$body$
language plpgsql IMMUTABLE;
alter function api.fn_user_log_get(varchar) owner to postgres;

grant execute on function api.fn_user_log_get(varchar) to postgres;
grant execute on function api.fn_user_log_get(varchar) to api_caller;
revoke all on function api.fn_user_log_get(varchar) from public;

comment on function api.fn_user_log_get(varchar) is 'Лог авторизации пользователя';
