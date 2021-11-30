-- View: metaestructura.vl_valida_campos_control

-- DROP VIEW metaestructura.vl_valida_campos_control;

CREATE OR REPLACE VIEW metaestructura.vl_valida_campos_control AS 
 SELECT dblink.obj_ip_servidor,
    dblink.obj_ip_cliente,
    dblink.obj_bd_nombre,
    dblink.obj_esquema_nombre,
    dblink.obj_oid,
    dblink.obj_tabla_nombre,
    dblink.obj_operacion,
    dblink.dis_actualiza_control,
    dblink.dis_registra_audit,
    dblink.atr_cc_idregcambio,
    dblink.atr_cc_fecha_alta,
    dblink.atr_cc_fecha_modifico,
    dblink.atr_cc_usuario_alta,
    dblink.atr_cc_usuario_modifico,
    dblink.atr_idregcambio,
    dblink.atr_fecha_alta,
    dblink.atr_fecha_modifico,
    dblink.atr_usuario_alta,
    dblink.atr_usuario_modifico
   FROM dblink(metaestructura.fn_string_conexion_local(), '/**/
    select      
                    host( inet_server_addr() )  obj_ip_servidor
                ,   host( inet_client_addr() )  obj_ip_cliente
                ,   current_database()          obj_bd_nombre
                ,   t.nspname                   obj_esquema_nombre
                ,   t.oid                       obj_oid
                ,   t.relname                   obj_tabla_nombre

                ,   CASE    WHEN            sum(case when c.attname = ''cc_idregcambio''            then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_fecha_alta''             then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_fecha_modifico''         then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_usuario_alta''           then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_usuario_modifico''       then 1 else 0 end)>0
                                    AND    (SELECT      sum(    case    when    d.tgname  = ''dis_actualiza_control_bu''    
                                                                        then    1 
                                                                        else    0 end) 
                                            FROM        metaestructura.disparadores d   
                                            WHERE       d.tgrelid   = t.oid                                      )>0
                                    AND     sum(CASE    WHEN    t.relname IN (''tbl_audit_cf'',''tbl_audit_dml'')       then 1
                                                        ELSE   (SELECT      sum(    case    when    d.tgname  = ''dis_registra_audit_biud''    
                                                                                    then    1 
                                                                                    else    0 end) 
                                                                FROM        metaestructura.disparadores d
                                                                WHERE       d.tgrelid   = t.oid
                                                                )
                                                        END)>0    THEN  ''FINALIZED''
                            WHEN            sum(case when c.attname = ''cc_idregcambio''            then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_fecha_alta''             then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_fecha_modifico''         then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_usuario_alta''           then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''cc_usuario_modifico''       then 1 else 0 end)>0    THEN  ''TRIGGER''
                            WHEN            sum(case when c.attname = ''idregcambio''               then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''fecha_alta''                then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''fecha_modifico''            then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''usuario_alta''              then 1 else 0 end)>0
                                    AND     sum(case when c.attname = ''usuario_modifico''          then 1 else 0 end)>0    THEN  ''ALTER''
                            WHEN           (sum(case when c.attname = ''idregcambio''               then 1 else 0 end)+
                                            sum(case when c.attname = ''fecha_alta''                then 1 else 0 end)+
                                            sum(case when c.attname = ''fecha_modifico''            then 1 else 0 end)+
                                            sum(case when c.attname = ''usuario_alta''              then 1 else 0 end)+
                                            sum(case when c.attname = ''usuario_modifico''          then 1 else 0 end))>0   THEN  ''HOMOLOGATE''
                            ELSE                                                                                                  ''INSERT''
                    END                         obj_operacion
                ,   COALESCE((
                                    SELECT      sum(case when d.tgname  = ''dis_actualiza_control_bu''          then 1 else 0 end) 
                                    FROM        metaestructura.disparadores d   
                                    WHERE       d.tgrelid   = t.oid 
                    ),0)                        dis_actualiza_control
                ,   COALESCE((
                            CASE    WHEN        t.relname IN (''tbl_audit_cf'',''tbl_audit_dml'')  then 1
                            ELSE   (SELECT      sum(case when d.tgname  = ''dis_registra_audit_biud'' 
                                                         then 1 else 0 end) 
                                    FROM        metaestructura.disparadores d
                                    WHERE       d.tgrelid   = t.oid)
                            END
                    ),0)                        dis_registra_audit
                ,   sum(case when c.attname = ''cc_idregcambio''              then 1 else 0 end) atr_cc_idregcambio
                ,   sum(case when c.attname = ''cc_fecha_alta''               then 1 else 0 end) atr_cc_fecha_alta
                ,   sum(case when c.attname = ''cc_fecha_modifico''           then 1 else 0 end) atr_cc_fecha_modifico
                ,   sum(case when c.attname = ''cc_usuario_alta''             then 1 else 0 end) atr_cc_usuario_alta
                ,   sum(case when c.attname = ''cc_usuario_modifico''         then 1 else 0 end) atr_cc_usuario_modifico

                ,   sum(case when c.attname = ''idregcambio''                 then 1 else 0 end) atr_idregcambio
                ,   sum(case when c.attname = ''fecha_alta''                  then 1 else 0 end) atr_fecha_alta
                ,   sum(case when c.attname = ''fecha_modifico''              then 1 else 0 end) atr_fecha_modifico
                ,   sum(case when c.attname = ''usuario_alta''                then 1 else 0 end) atr_usuario_alta
                ,   sum(case when c.attname = ''usuario_modifico''            then 1 else 0 end) atr_usuario_modifico
                
    FROM        metaestructura.tablas       t
    LEFT JOIN   metaestructura.campos       c   ON  c.attrelid  = t.oid
    where       not lower(t.nspname) similar to ''%(information_schema|pg_)%''
    AND         t.relkind   = ''r''
    AND         c.attname   not ilike ''obj_cc%''
    AND         c.attnum    > 0
    AND         c.atttypid  > 0
    GROUP BY        t.nspname
                ,   t.relname
                ,   t.oid
                ,   c.nspname
                ,   c.relname
                ,   c.attrelid
    ORDER BY        t.nspname
                ,   t.relname;
/**/'::text) dblink(obj_ip_servidor character varying, obj_ip_cliente character varying, obj_bd_nombre character varying, obj_esquema_nombre character varying, obj_oid oid, obj_tabla_nombre character varying, obj_operacion character varying, dis_actualiza_control bigint, dis_registra_audit bigint, atr_cc_idregcambio bigint, atr_cc_fecha_alta bigint, atr_cc_fecha_modifico bigint, atr_cc_usuario_alta bigint, atr_cc_usuario_modifico bigint, atr_idregcambio bigint, atr_fecha_alta bigint, atr_fecha_modifico bigint, atr_usuario_alta bigint, atr_usuario_modifico bigint);

ALTER TABLE metaestructura.vl_valida_campos_control
  OWNER TO postgres;
