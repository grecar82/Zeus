-- Function: metaestructura.fn_dml_audit()

-- DROP FUNCTION metaestructura.fn_dml_audit();

CREATE OR REPLACE FUNCTION metaestructura.fn_dml_audit()
  RETURNS trigger AS
$BODY$
/*
    Author      : Gregorio Daniel Carmona Vazquez
    Date        : 2021-11-28
    Descrition  : Trigger dml audit control
*/
DECLARE 
    wl_n0                INTEGER;
    wl_n1                INTEGER;
    wl_i                 INTEGER;

    wl_structure_table	 TEXT;
    wl_sql               TEXT;

    wl_ip_server       character varying :=host( inet_server_addr() );
    wl_ip_client        character varying :=inet_client_addr();
    wl_bd_name         character varying :=current_database();
    wl_relid             integer           :=TG_RELID;
    wl_table_name        character varying :=TG_TABLE_NAME;
    wl_schema_name       character varying :=TG_TABLE_SCHEMA;
    wl_op                character varying :=TG_OP;
    wl_register_audit_id       integer;
    wl_pg_version        character varying :='';
    wl_version           DOUBle PRECISION;
    wl_field             varchar[];

    wl_old_tmp           character varying :='';
    wl_new_tmp           character varying :='';
    wl_json_tmp          json;
    wl_json_tra          TEXT:='';
    wl_json              json;
    
    
    wl_schema_audit_org  character varying;
    wl_schema_audit_des  character varying;
    wl_schema_audit_tmp  character varying;
    
    wl_tabla_audit_org   character varying;
    wl_tabla_audit_des   character varying;
    wl_tabla_audit_tmp   character varying;

    wl_objeto_audit_org  character varying;
    wl_objeto_audit_des  character varying;
    wl_objeto_audit_tmp  character varying;

    wl_length integer;
BEGIN
    EXECUTE     ('SHOW server_version;') into wl_pg_version;
    wl_version                             := substr(wl_pg_version, 1, 3); 
    wl_schema_audit_org                    :='metaestructura';
    wl_tabla_audit_org                     :='tbl_audit_dml';
    
    wl_schema_audit_des                    :=TG_TABLE_SCHEMA;
    wl_tabla_audit_des                     :=wl_tabla_audit_org;
    
    wl_schema_audit_tmp                    :=wl_schema_audit_org;
    wl_tabla_audit_tmp                     :=wl_tabla_audit_org ||'_tmp';
    
    wl_objeto_audit_org                    :=wl_schema_audit_org||'.'||wl_tabla_audit_org;
    wl_objeto_audit_des                    :=wl_schema_audit_des||'.'||wl_tabla_audit_des;
    wl_objeto_audit_tmp                    :=wl_tabla_audit_tmp;

    
    SELECT      ARRAY( 
                SELECT      attname 
                FROM        metaestructura.fields 
                WHERE       attnum      > 0 
                AND         atttypid    > 0 
                AND         attrelid    = TG_RELID
                AND         relname     = TG_TABLE_NAME
                AND         nspname     = TG_TABLE_SCHEMA
                ORDER BY    attnum
    ) INTO      wl_field;
    SELECT      COUNT(*)    INTO wl_n0 
    FROM        metaestructura.tablas 
    WHERE       tipo_objeto             = 'Tabla'
    and         nspname                 = wl_schema_audit_des
    AND         relname                 = wl_tabla_audit_des;
    
    if          wl_n0=0      then
                SELECT      metaestructura.fn_genera_tabladef(wl_objeto_audit_org,wl_objeto_audit_des) INTO wl_structure table;
                EXECUTE     (wl_structure_table);
    end if; objectect

    wl_sql :='
    INSERT INTO '|| wl_objeto_audit_des||'
               ( obj_ip_servidor, obj_ip_cliente, obj_bd_nombre, obj_esquema_nombre, obj_oid, obj_tabla_nombre, obj_operacion, obj_cc_register_audit_id, transaccion )
    SELECT       $1 ,$2 ,$3 ,$4 ,$5 ,$6 ,$7 ,$8 ,$9';

    IF          TG_OP       = 'DELETE' THEN
                for         wl_i in 1..array_length(wl_field,1)                 loop
                            EXECUTE     'SELECT ($1).' || wl_field[wl_i]  INTO wl_old_tmp USING OLD;
                            IF      wl_field[wl_i]  ~ '.*cc_register_audit_id' THEN
                                    wl_register_audit_id   :=wl_old_tmp;
                            END IF;
                            IF      wl_old_tmp IS NOT NULL    THEN 
                                    IF          wl_version>=9.4 THEN
                                                wl_json_tmp      :=json_object(array[array['field',wl_field[wl_i]], 
                                                                                    array['orden',wl_i::character varying],
                                                                                    array['old',wl_old_tmp]]);
                                    ELSE
                                                SELECT      array_to_json(array_agg(jc.*)) INTO  wl_json_tmp
                                                FROM       (select      *
                                                            FROM       (VALUES  (wl_field[wl_i], wl_i, wl_old_tmp)
                                                                        ) i     (field, orden, old)
                                                            ) jc;
                                                wl_json_tmp      :=wl_json_tmp->>0;
                                    END IF;        
                                    wl_json_tra      := wl_json_tra || wl_json_tmp ||', ';
                            END IF;
                end loop;
                wl_json_tra                          :=  substr(wl_json_tra, 0, length(wl_json_tra)-1);
                wl_json                              :=  '{"movimiento": ['|| wl_json_tra||' ]}';
                EXECUTE     (wl_sql) 
                USING           wl_ip_server  
                            ,   wl_ip_client
                            ,   wl_bd_name
                            ,   wl_schema_name
                            ,   wl_relid
                            ,   wl_table_name
                            ,   wl_op
                            ,   wl_register_audit_id
                            ,   wl_json;
                RETURN      OLD;
    ELSIF       TG_OP   = 'UPDATE' THEN
                for     wl_i in 1..array_length(wl_field,1) loop
                        EXECUTE     'SELECT ($1).' || wl_field[wl_i]  INTO wl_old_tmp USING OLD;
                        EXECUTE     'SELECT ($1).' || wl_field[wl_i]  INTO wl_new_tmp USING NEW;
                        IF          wl_field[wl_i]  ~ '.*cc_register_audit_id' THEN
                                    wl_register_audit_id   :=wl_new_tmp;
                        END IF;
                        IF          (wl_old_tmp<>wl_new_tmp)  
                                    OR (wl_old_tmp IS NULL AND wl_new_tmp IS NOT NULL) 
                                    OR (wl_old_tmp IS NOT NULL  AND wl_new_tmp IS NULL) THEN  

                                    IF          wl_version>=9.4 THEN
                                                wl_json_tmp      :=json_object(array[array['field',wl_field[wl_i]], 
                                                                                    array['orden',wl_i::character varying],
                                                                                    array['old',wl_old_tmp], 
                                                                                    array['new',wl_new_tmp]]);
                                    ELSE
                                                SELECT      array_to_json(array_agg(jc.*)) INTO  wl_json_tmp
                                                FROM       (select      *
                                                            FROM       (VALUES  (wl_field[wl_i], wl_i, wl_old_tmp, wl_new_tmp)
                                                                        ) i     (field, orden, old, new)
                                                            ) jc;
                                                wl_json_tmp      :=wl_json_tmp->>0;
                                    END IF;        
                                    wl_json_tra      := wl_json_tra || wl_json_tmp ||', ';
                        END IF;
                end loop;
                
                wl_length    :=  length(wl_json_tra);
                if (wl_length=0) then
                    wl_length=wl_length;
                    else
                    wl_length=wl_length-1;
                end if;
                --wl_json_tra                          :=  substr(wl_json_tra, 0, length(wl_json_tra)-1);
                wl_json_tra                          :=  substr(wl_json_tra, 0, wl_length);
                wl_json                              :=  '{"movimiento": ['|| wl_json_tra||' ]}';
                
                EXECUTE    (wl_sql) 
                USING           wl_ip_server  
                            ,   wl_ip_client
                            ,   wl_bd_name
                            ,   wl_schema_name
                            ,   wl_relid
                            ,   wl_table_name
                            ,   wl_op
                            ,   wl_register_audit_id
                            ,   wl_json;
                RETURN      NEW;
    ELSIF       TG_OP  = 'INSERT' THEN
                for     wl_i in 1..array_length(wl_field,1) loop
                        EXECUTE     'SELECT ($1).' || wl_field[wl_i]  INTO wl_new_tmp USING NEW;
                        IF          wl_field[wl_i]  ~ '.*cc_register_audit_id' THEN
                                    wl_register_audit_id   :=wl_new_tmp;
                        END IF;
                        IF          wl_new_tmp IS NOT NULL THEN 
                                    IF          wl_version>=9.4 THEN
                                                wl_json_tmp      :=json_object(array[array['field',wl_field[wl_i]], 
                                                                                    array['orden',wl_i::character varying],
                                                                                    array['new',wl_new_tmp]]);
                                    ELSE
                                                SELECT      array_to_json(array_agg(jc.*)) INTO  wl_json_tmp
                                                FROM       (select      *
                                                            FROM       (VALUES  (wl_field[wl_i], wl_i, wl_new_tmp)
                                                                        ) i     (field, orden, new)
                                                            ) jc;
                                                wl_json_tmp      :=wl_json_tmp->>0;
                                    END IF;        
                                    wl_json_tra      := wl_json_tra || wl_json_tmp ||', ';
                        END IF;
                end loop;
                
                wl_length    :=  length(wl_json_tra);
                if (wl_length=0) then
                    wl_length=wl_length;
                    else
                    wl_length=wl_length-1;
                end if;
                --wl_json_tra                          :=  substr(wl_json_tra, 0, length(wl_json_tra)-1);
                wl_json_tra                          :=  substr(wl_json_tra, 0, wl_length);
                wl_json                              :=  '{"movimiento": ['|| wl_json_tra||' ]}';
                                            
                EXECUTE    (wl_sql) 
                USING           wl_ip_server  
                            ,   wl_ip_client
                            ,   wl_bd_name
                            ,   wl_schema_name
                            ,   wl_relid
                            ,   wl_table_name
                            ,   wl_op
                            ,   wl_register_audit_id
                            ,   wl_json;
                RETURN      NEW;
    END IF;
    RETURN  NULL;
   
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION metaestructura.fn_dml_audit()
  OWNER TO postgres;
