CREATE ROLE api_caller WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  PASSWORD 'ApiPassword';

CREATE SCHEMA IF NOT EXISTS api;
COMMENT ON SCHEMA public IS 'API';
GRANT ALL ON SCHEMA api TO api_caller;
GRANT ALL ON SCHEMA api TO postgres;


CREATE SCHEMA IF NOT EXISTS basis;
COMMENT ON SCHEMA public IS 'Основная схема';
GRANT ALL ON SCHEMA basis TO api_caller;
GRANT ALL ON SCHEMA basis TO postgres;

create table basis.t_user(
	id serial primary key,
	login varchar(50) NOT NULL,
	password varchar(256) NOT NULL,
	password_salt varchar(16) NOT NULL,
	failed_pass_count integer
);
grant all on table basis.t_user to postgres;
grant all on table basis.t_user to api_caller;
grant all on sequence basis.t_user_id_seq to public;
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
grant all on sequence api.t_session_type_id_seq to public;
comment on table api.t_session_type is 'Сессии. Тип';
comment on column api.t_session_type.id is 'Идентификатор';
comment on column api.t_session_type.duration is 'Продолжительность сессии';
comment on column api.t_session_type.code is 'Кодовое наименование';
create unique index on api.t_session_type using btree (code);

create table api.t_session(
	id serial primary key,
	user_id integer not null references basis.t_user(id) on update cascade on delete cascade,
	create_ts timestamp not null default now()::timestamp,
	token varchar(64) not null,
	session_type_id integer not null references api.t_session_type(id) on update cascade on delete no action
);
grant all on table api.t_session to postgres;
grant all on table api.t_session to api_caller;
grant all on sequence api.t_session_id_seq to public;
comment on table api.t_session is 'Сессии';
comment on column api.t_session.id is 'Идентификатор';
comment on column api.t_session.user_id is 'Код пользователя';
comment on column api.t_session.create_ts is 'Время создания';
comment on column api.t_session.session_type_id is 'Тип';
create index on api.t_session using btree (user_id);
create unique index on api.t_session using btree (token);

create table api.t_user_log_action(
	id serial primary key,
	name varchar(50) not null,
	code varchar(50) not null
);
grant all on table api.t_user_log_action to postgres;
grant all on table api.t_user_log_action to api_caller;
grant all on sequence api.t_user_log_action_id_seq to public;
comment on table api.t_user_log_action is 'Лог авторизации пользователей. Действия';
comment on column api.t_user_log_action.id is 'Идентификатор';
comment on column api.t_user_log_action.name is 'Наименование';
comment on column api.t_user_log_action.code is 'Кодовое наименование';
create unique index on api.t_user_log_action using btree (code);

create table api.t_user_log(
	id serial primary key,
	user_id integer not null references basis.t_user(id) on update cascade on delete cascade,
	create_ts timestamp not null default now()::timestamp,
	action_id integer not null references api.t_user_log_action(id) on update cascade on delete no action
);
grant all on table api.t_user_log to postgres;
grant all on table api.t_user_log to api_caller;
grant all on sequence api.t_user_log_id_seq to public;
comment on table api.t_user_log is 'Лог авторизации пользователей';
comment on column api.t_user_log.id is 'Идентификатор';
comment on column api.t_user_log.user_id is 'Код пользователя';
comment on column api.t_user_log.create_ts is 'Время создания';
comment on column api.t_user_log.action_id is 'Тип действия';
create index on api.t_user_log using btree (user_id);



commit
rollback