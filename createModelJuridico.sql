DROP DATABASE zeus;
CREATE DATABASE zeus
  WITH ENCODING='UTF8'
       CONNECTION LIMIT=-1;

\connect zeus

create schema person;

create table person.type (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    type_id serial primary key,
    type_description_en varchar unique not null,
    type_description_es varchar unique not null);

comment on table person.type is 'Storage type person table';
comment on column person.type.cf_raid is 'Register key, audit serial indentifier';
comment on column person.type.cf_register_date is 'Date when creating data';
comment on column person.type.cf_update_date is 'Date when updating data';
comment on column person.type.cf_user_register is 'The user who creating data';
comment on column person.type.cf_user_update is 'The user who updating data';
comment on column person.type.type_id is 'Primary key, type serial identifier';
comment on column person.type.type_description_en is 'Type english description languages';
comment on column person.type.type_description_es is 'Type spanish description languages';

insert into person.type (type_description_en,type_description_es) values ('Physical person','Persona Fisica');
insert into person.type (type_description_en,type_description_es) values ('Moral person','Persona Moral');
insert into person.type (type_description_en,type_description_es) values ('Digital person','Persona Digital');

create table person.text_element (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    text_element_id serial primary key,
    type_id integer[] not null,
    --type_id integer[] not null check (type_id <@  '{1,2,3}'::integer[]),
    text_description_en varchar unique not null,
    text_description_es varchar unique not null);

comment on table person.text_element is 'Storage typr person table';
comment on column person.text_element.cf_raid is 'Register key, audit serial indentifier';
comment on column person.text_element.cf_register_date is 'Date when creating data';
comment on column person.text_element.cf_update_date is 'Date when updating data';
comment on column person.text_element.cf_user_register is 'The user who creating data';
comment on column person.text_element.cf_user_update is 'The user who updating data';
comment on column person.text_element.text_element_id is 'Primary key, text_element serial identifier';
comment on column person.text_element.type_id is 'Foreign key, person type identifier';
comment on column person.text_element.text_description_en is 'Text english languages';
comment on column person.text_element.text_description_es is 'Text spanish languages';

create table person.type_log (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    type_log_id serial primary key,
    type_log_description_en varchar unique not null,
    type_log_description_es varchar unique not null);

comment on table person.type_log is 'Storage type person table';
comment on column person.type_log.cf_raid is 'Register key, audit serial indentifier';
comment on column person.type_log.cf_register_date is 'Date when creating data';
comment on column person.type_log.cf_update_date is 'Date when updating data';
comment on column person.type_log.cf_user_register is 'The user who creating data';
comment on column person.type_log.cf_user_update is 'The user who updating data';
comment on column person.type_log.type_log_id is 'Primary key, log type serial identifier';
comment on column person.type_log.type_log_description_en is 'Log type english description';
comment on column person.type_log.type_log_description_es is 'Log type spanish description';

insert into person.type_log (type_log_description_en,type_log_description_es) values ('Success','Exito');
insert into person.type_log (type_log_description_en,type_log_description_es) values ('Warning','Advertencia');
insert into person.type_log (type_log_description_en,type_log_description_es) values ('Error','Error');

CREATE TABLE person.log
(
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    date_time character varying,
    process character varying,
    log character varying,
    type_log_id integer references person.type_log);

create or replace function person.fn_person_type_review() returns trigger as
$$
declare
    wl_sql text;
    wl_validate boolean:=false;
begin
    wl_sql := ' select  count(*)=0 
                from    (select unnest('''||new.type_id::text||'''::integer[]) type_id) as t1
                where   type_id not in (
                select type_id from person.type
                );';
    if TG_OP = 'INSERT'
    then
        execute wl_sql into wl_validate;
    elsif TG_OP = 'UPDATE' and new.type_id <> old.type_id
    then
        execute wl_sql into wl_validate;
    end if;
    if wl_validate is false
    then
        raise exception 'Some array key (type_id)=(%) is not present in table "type"',new.type_id;
    else
        return new;
    end if;
end;
$$
language plpgsql;

CREATE TRIGGER tri_person_type_review
  BEFORE insert or update
  ON person.text_element
  FOR EACH ROW
  EXECUTE PROCEDURE person.fn_person_type_review();

insert into person.text_element (text_description_en,text_description_es,type_id) values ('Name','Nombre','{1,3}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('Last name','Apellido','{1,3}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('Second last name','Segundo apellido','{1,3}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('Business name','Razón social','{2}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('CURP','CURP','{1}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('RFC','RFC','{1,2}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('IMMS','IMMS','{1}');
insert into person.text_element (text_description_en,text_description_es,type_id) values ('Gender','Genero','{1}');

create table person.date_element (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    date_element_id serial primary key,
    type_id integer[] not null,
    date_description_en varchar unique not null,
    date_description_es varchar unique not null);

comment on column person.date_element.cf_raid is 'Register key, audit serial indentifier';
comment on column person.date_element.cf_register_date is 'Date when creating data';
comment on column person.date_element.cf_update_date is 'Date when updating data';
comment on column person.date_element.cf_user_register is 'The user who creating data';
comment on column person.date_element.cf_user_update is 'The user who updating data';
comment on column person.date_element.date_element_id is 'Primary key, date_element serial identifier';
comment on column person.date_element.type_id is 'Foreign key, person type identifier';
comment on column person.date_element.date_description_en is 'Text english languages';
comment on column person.date_element.date_description_es is 'Text spanish languages';

CREATE TRIGGER tri_person_type_review
  BEFORE insert or update
  ON person.date_element
  FOR EACH ROW
  EXECUTE PROCEDURE person.fn_person_type_review();

insert into person.date_element (date_description_en,date_description_es,type_id) values ('Birth date','Fecha de nacimiento','{1}');
insert into person.date_element (date_description_en,date_description_es,type_id) values ('Death date','Fecha de defunción','{1}');
insert into person.date_element (date_description_en,date_description_es,type_id) values ('Register date','Fecha de registro','{1,2,3}');
insert into person.date_element (date_description_en,date_description_es,type_id) values ('Inactive date','Fecha de baja','{1,2,3}');
insert into person.date_element (date_description_en,date_description_es,type_id) values ('Operation start date','Fecha de inicio de operación','{2,3}');
insert into person.date_element (date_description_en,date_description_es,type_id) values ('Operation end date','Fecha de fin de operación','{2,3}');

create table person.numeric_element (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    numeric_element_id serial primary key,
    type_id integer[] not null,
    numeric_description_en varchar unique not null,
    numeric_description_es varchar unique not null);

comment on column person.numeric_element.cf_raid is 'Register key, audit serial indentifier';
comment on column person.numeric_element.cf_register_date is 'Date when creating data';
comment on column person.numeric_element.cf_update_date is 'Date when updating data';
comment on column person.numeric_element.cf_user_register is 'The user who creating data';
comment on column person.numeric_element.cf_user_update is 'The user who updating data';
comment on column person.numeric_element.numeric_element_id is 'Primary key, numeric_element serial identifier';
comment on column person.numeric_element.type_id is 'Foreign key, person type identifier';
comment on column person.numeric_element.numeric_description_en is 'Numeric english languages';
comment on column person.numeric_element.numeric_description_es is 'Numeric spanish languages';

CREATE TRIGGER tri_person_type_review
  BEFORE insert or update
  ON person.numeric_element
  FOR EACH ROW
  EXECUTE PROCEDURE person.fn_person_type_review();

create table person.integer_element (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    integer_element_id serial primary key,
    type_id integer[] not null,
    integer_description_en varchar unique not null,
    integer_description_es varchar unique not null);

comment on column person.integer_element.cf_raid is 'Register key, audit serial indentifier';
comment on column person.integer_element.cf_register_date is 'Date when creating data';
comment on column person.integer_element.cf_update_date is 'Date when updating data';
comment on column person.integer_element.cf_user_register is 'The user who creating data';
comment on column person.integer_element.cf_user_update is 'The user who updating data';
comment on column person.integer_element.integer_element_id is 'Primary key, integer_element serial identifier';
comment on column person.integer_element.type_id is 'Foreign key, person type identifier';
comment on column person.integer_element.integer_description_en is 'Integer english languages';
comment on column person.integer_element.integer_description_es is 'Integer spanish languages';

CREATE TRIGGER tri_person_type_review
  BEFORE insert or update
  ON person.integer_element
  FOR EACH ROW
  EXECUTE PROCEDURE person.fn_person_type_review();

insert into person.integer_element (integer_description_en,integer_description_es,type_id) values ('Sons','Hijos','{1}');
insert into person.integer_element (integer_description_en,integer_description_es,type_id) values ('Main phone','Telefono','{1,2,3}');
insert into person.integer_element (integer_description_en,integer_description_es,type_id) values ('Secondary phone','Otro telefono','{1,2,3}');
insert into person.numeric_element (numeric_description_en,numeric_description_es,type_id) values ('Employees','Empleados','{2}');

create table person.main (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    person_id bigserial primary key,
    type_id integer references person.type not null
);

comment on table person.main is 'Storage person table';
comment on column person.main.cf_raid is 'Register key, audit serial indentifier';
comment on column person.main.cf_register_date is 'Date when creating data';
comment on column person.main.cf_update_date is 'Date when updating data';
comment on column person.main.cf_user_register is 'The user who creating data';
comment on column person.main.cf_user_update is 'The user who updating data';
comment on column person.main.person_id is 'Primary key, person serial identifier';
comment on column person.main.type_id is 'Foreign key, person type identifier';

insert into person.main (type_id) values (1);
insert into person.main (type_id) values (2);
insert into person.main (type_id) values (3);

create table person.main_text (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    person_id bigint references person.main not null,
    type_id integer references person.type not null,
    text_element_id integer references person.text_element not null,
    text_value varchar not null
);

comment on table person.main_text is 'Text element storage table';
comment on column person.main_text.cf_raid is 'Register key, audit serial indentifier';
comment on column person.main_text.cf_register_date is 'Date when creating data';
comment on column person.main_text.cf_update_date is 'Date when updating data';
comment on column person.main_text.cf_user_register is 'The user who creating data';
comment on column person.main_text.cf_user_update is 'The user who updating data';
comment on column person.main_text.person_id is 'Primary key, person serial identifier';
comment on column person.main_text.type_id is 'Foreign key, person type identifier';

create table person.main_date (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    person_id bigint references person.main not null,
    type_id integer references person.type not null,
    date_element_id integer references person.date_element not null,
    date_value date not null
);

comment on table person.main_date is 'Date element storage table';
comment on column person.main_date.cf_raid is 'Register key, audit serial indentifier';
comment on column person.main_date.cf_register_date is 'Date when creating data';
comment on column person.main_date.cf_update_date is 'Date when updating data';
comment on column person.main_date.cf_user_register is 'The user who creating data';
comment on column person.main_date.cf_user_update is 'The user who updating data';
comment on column person.main_date.person_id is 'Primary key, person serial identifier';
comment on column person.main_date.type_id is 'Foreign key, person type identifier';



create table person.main_numeric (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    person_id bigint references person.main not null,
    type_id integer references person.type not null,
    numeric_element_id integer references person.date_element not null,
    numeric_value numeric
);

comment on table person.main_numeric is 'Date element storage table';
comment on column person.main_numeric.cf_raid is 'Register key, audit serial indentifier';
comment on column person.main_numeric.cf_register_date is 'Date when creating data';
comment on column person.main_numeric.cf_update_date is 'Date when updating data';
comment on column person.main_numeric.cf_user_register is 'The user who creating data';
comment on column person.main_numeric.cf_user_update is 'The user who updating data';
comment on column person.main_numeric.person_id is 'Primary key, person serial identifier';
comment on column person.main_numeric.type_id is 'Foreign key, person type identifier';



create table person.main_integer (
    cf_raid serial NOT NULL,
    cf_register_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_update_date timestamp without time zone NOT NULL DEFAULT now(),
    cf_user_register varchar NOT NULL DEFAULT "current_user"(),
    cf_user_update varchar NOT NULL DEFAULT "current_user"(),
    person_id bigint references person.main not null,
    type_id integer references person.type not null,
    integer_element_id integer references person.date_element not null,
    integer_value integer not null
);

comment on table person.main_date is 'Date element storage table';
comment on column person.main_integer.cf_raid is 'Register key, audit serial indentifier';
comment on column person.main_integer.cf_register_date is 'Date when creating data';
comment on column person.main_integer.cf_update_date is 'Date when updating data';
comment on column person.main_integer.cf_user_register is 'The user who creating data';
comment on column person.main_integer.cf_user_update is 'The user who updating data';
comment on column person.main_integer.person_id is 'Primary key, person serial identifier';
comment on column person.main_integer.type_id is 'Foreign key, person type identifier';