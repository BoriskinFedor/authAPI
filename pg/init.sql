CREATE ROLE api_caller WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  PASSWORD 'ApiPassword';




CREATE SCHEMA IF NOT EXISTS api;
COMMENT ON SCHEMA api IS 'API';
GRANT ALL ON SCHEMA api TO api_caller;
GRANT ALL ON SCHEMA api TO postgres;
REVOKE ALL ON SCHEMA api FROM public;




CREATE SCHEMA IF NOT EXISTS basis;
COMMENT ON SCHEMA basis IS 'Основная схема';
GRANT ALL ON SCHEMA basis TO api_caller;
GRANT ALL ON SCHEMA basis TO postgres;
REVOKE ALL ON SCHEMA basis FROM public;




create table basis.t_user(
	id serial primary key,
	login varchar(50) NOT NULL,
	password varchar(256) NOT NULL,
	password_salt varchar(16) NOT NULL,
	failed_pass_count integer NOT NULL default 0::integer
);
grant all on table basis.t_user to postgres;
grant all on table basis.t_user to api_caller;
REVOKE ALL on table basis.t_user FROM public;
grant all on sequence basis.t_user_id_seq to api_caller;
comment on table basis.t_user is 'Пользователи';
comment on column basis.t_user.id is 'Идентификатор';
comment on column basis.t_user.login is 'Логин';
comment on column basis.t_user.password is 'Пароль';
comment on column basis.t_user.password_salt is 'Соль';
comment on column basis.t_user.failed_pass_count is 'Кол-во неудачных попыток входа';
create unique index on basis.t_user using btree (login);




create table api.t_session_type(
	id serial primary key,
	duration interval not null,
	code varchar(50) not null
);
grant all on table api.t_session_type to postgres;
grant all on table api.t_session_type to api_caller;
REVOKE ALL on table api.t_session_type FROM public;
grant all on sequence api.t_session_type_id_seq to api_caller;
comment on table api.t_session_type is 'Сессии. Тип';
comment on column api.t_session_type.id is 'Идентификатор';
comment on column api.t_session_type.duration is 'Продолжительность сессии';
comment on column api.t_session_type.code is 'Кодовое наименование';
create unique index on api.t_session_type using btree (code);

insert into api.t_session_type(
	duration,
	code
)
values(
	'30 minutes'::interval,
	'default'::varchar
);




create table api.t_session(
	id serial primary key,
	user_id integer not null references basis.t_user(id) on update cascade on delete cascade,
	create_ts timestamp not null default now()::timestamp,
	token varchar not null,
	type_id integer not null references api.t_session_type(id) on update cascade on delete no action
);
grant all on table api.t_session to postgres;
grant all on table api.t_session to api_caller;
REVOKE ALL on table api.t_session FROM public;
grant all on sequence api.t_session_id_seq to api_caller;
comment on table api.t_session is 'Сессии';
comment on column api.t_session.id is 'Идентификатор';
comment on column api.t_session.user_id is 'Код пользователя';
comment on column api.t_session.create_ts is 'Время создания';
comment on column api.t_session.type_id is 'Тип';
create index on api.t_session using btree (user_id);
create unique index on api.t_session using btree (token);




create table api.t_user_log_action(
	id serial primary key,
	name varchar(50) not null,
	code varchar(50) not null
);
grant all on table api.t_user_log_action to postgres;
grant all on table api.t_user_log_action to api_caller;
REVOKE ALL on table api.t_user_log_action FROM public;
grant all on sequence api.t_user_log_action_id_seq to api_caller;
comment on table api.t_user_log_action is 'Лог авторизации пользователей. Действия';
comment on column api.t_user_log_action.id is 'Идентификатор';
comment on column api.t_user_log_action.name is 'Наименование';
comment on column api.t_user_log_action.code is 'Кодовое наименование';
create unique index on api.t_user_log_action using btree (code);

insert into api.t_user_log_action(
	name,
	code
)
values(
	'Успешная авторизация',
	'auth_success'
),
(
	'Неудачная попытка авторизации',
	'auth_fail'
),
(
	'Пользователь заблокирован',
	'user_block'
);



create table api.t_user_log(
	id serial primary key,
	user_id integer not null references basis.t_user(id) on update cascade on delete cascade,
	create_ts timestamp not null default now()::timestamp,
	action_id integer not null references api.t_user_log_action(id) on update cascade on delete no action,
	session_id integer references api.t_session(id) on update cascade on delete no action
);
grant all on table api.t_user_log to postgres;
grant all on table api.t_user_log to api_caller;
REVOKE ALL on table api.t_user_log FROM public;
grant all on sequence api.t_user_log_id_seq to api_caller;
comment on table api.t_user_log is 'Лог авторизации пользователей';
comment on column api.t_user_log.id is 'Идентификатор';
comment on column api.t_user_log.user_id is 'Код пользователя';
comment on column api.t_user_log.create_ts is 'Время создания';
comment on column api.t_user_log.action_id is 'Тип действия';
comment on column api.t_user_log.session_id is 'Код сессии (при успешной авторизации)';
create index on api.t_user_log using btree (user_id);




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




create or replace function api.fn_user_log_clean(
    arg_token varchar
)
returns void
as
$body$
declare
    v_user_id integer;
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

    delete from api.t_user_log l
    where l.user_id = v_user_id;
end;
$body$
language plpgsql;
alter function api.fn_user_log_clean(varchar) owner to postgres;

grant execute on function api.fn_user_log_clean(varchar) to postgres;
grant execute on function api.fn_user_log_clean(varchar) to api_caller;
revoke all on function api.fn_user_log_clean(varchar) from public;

comment on function api.fn_user_log_clean(varchar) is 'Очистка лога авторизации пользователя';




create or replace function api.fn_user_auth(
    arg_login varchar,
    arg_password varchar
)
returns varchar
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
    v_token varchar = sha256(now()::timestamp::varchar::bytea)::varchar;
    v_session_id integer;
begin
    arg_login    = trim(arg_login);
    arg_password = trim(arg_password);

    select
        u.id,
        coalesce(u.failed_pass_count, 0),
        sha256(concat(arg_password, u.password_salt)::varchar::bytea)::varchar = u.password
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