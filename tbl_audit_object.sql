-- Table: metaestructura.tbl_audit_object

-- DROP TABLE metaestructura.tbl_audit_object;

CREATE TABLE metaestructura.tbl_audit_object
(
  cc_register_audit_id serial NOT NULL, -- Identificador para registro de historico
  cc_register_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de alta del registro
  cc_update_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de ultima modificacion del registro
  cc_user_register character varying(32) NOT NULL DEFAULT "current_user"(), -- Usuario de base de datos que realizo el registro
  cc_user_update character varying(32) NOT NULL DEFAULT "current_user"(), -- Usuario de base de datos de ultima modificacion del registro
  object_audit_id bigserial NOT NULL, -- Identificador unico de la table de auditoria de datos
  object_ip_server character varying, -- Ip de server
  object_ip_client character varying, -- Ip del client de aplicación
  object_bd_name character varying NOT NULL, -- name de la base de datos
  object_echema_name character varying NOT NULL, -- name del echema origen auditado
  object_oid integer, -- Identificador del objectect en el GDB
  object_table_name character varying NOT NULL, -- name del table origen auditado
  object_type_id "char", -- Identificador de type de objectect
  object_type_description character varying, -- description de type de objectect
  object_objectect character varying, -- name del objectect
  object_structure_description text, -- Estructura del sql de objectect
  object_pk integer, -- Numero de llaves primarias
  object_pk_description text, -- List of llaves primarias
  object_fields integer, -- Numero de fields que contiene el objectect
  object_fields_description text, -- List of fields
  object_fields_type text -- List of type de fields
);

COMMENT ON TABLE metaestructura.tbl_audit_object IS 'Storage dml audit table';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_audit_id IS 'Register object serial indentifier';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_ip_server IS 'Ip server object';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_ip_client IS 'Ip client  object';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_bd_name IS 'Database name';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_echema_name IS 'Origin schema name audit';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_oid IS 'Object database identifier';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_table_name IS 'Object table name audit';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_type_id IS 'Object type id audit';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_type_desc+ription IS 'Object type id audit';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_objectect IS 'name del objectect';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_structure_description IS 'Estructura del sql de objectect';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_pk IS 'Numero de llaves primarias';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_pk_description IS 'List of llaves primarias';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_fields IS 'Numero de fields que contiene el objectect';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_fields_description IS 'List of fields';
COMMENT ON COLUMN metaestructura.tbl_audit_object.object_fields_type IS 'List of type de fields ';
COMMENT ON COLUMN metaestructura.tbl_audit_object.cc_idregcambio IS 'Identificador para registro de histórico';
COMMENT ON COLUMN metaestructura.tbl_audit_object.cc_fecha_alta IS 'Fecha de alta del registro';
COMMENT ON COLUMN metaestructura.tbl_audit_object.cc_fecha_modifico IS 'Fecha de última modificación del registro';
COMMENT ON COLUMN metaestructura.tbl_audit_object.cc_usuario_alta IS 'Usuario de base de datos que realizo el registro';
COMMENT ON COLUMN metaestructura.tbl_audit_object.cc_usuario_modifico IS 'Usuario de base de datos de última modificación del registro';

