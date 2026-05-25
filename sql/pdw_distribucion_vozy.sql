create or replace procedure extracciones.pdw_distribucion_vozy(IN p_fecha date)
    language plpgsql
as
$$
declare
    v_fecha     date := p_fecha - '1day'::interval;
    v_cant_regs numeric;
    v_analistas int;
begin

    select count(*)
    into v_cant_regs
    from extracciones.tbl_extraccion_llamadas_vozy
    where fecha = v_fecha;

    raise notice 'regs %', v_cant_regs;

    select count(*)
    into v_analistas
    from extracciones.tbl_usuarios_evaluacion
    where bot = 'Bot Cobros'
      and activo = true;

    drop table if exists tbl_analistas_ordenados;

    create temp table tbl_analistas_ordenados
    as
    select id,
           nombre,
           row_number() over (order by id) as grupo
    from extracciones.tbl_usuarios_evaluacion
    where bot = 'Bot Cobros'
      and activo = true;

    drop table if exists tbl_asignacion_w1;

    create temp table if not exists tbl_asignacion_w1
    as
    select fecha,
           session_id,
           contact_phone,
           call_answered,
           campaign_name,
           duration,
           codigo_cliente,
           inactivo,
           fecha_limite,
           saldo,
           row_number() over (order by session_id) as r1,
           vozy_success_type,
           reason,
           code_reason,
           hang_up_cause,
           voicemail
    from extracciones.tbl_extraccion_llamadas_vozy a
    where fecha = v_fecha
      and call_answered = true;

    delete
    from extracciones.tbl_asignacion
    where fecha = v_fecha;

    insert into extracciones.tbl_asignacion
    (fecha, session_id, contact_phone, call_answered, campaign_name, duration, codigo_cliente, inactivo,
     fecha_limite, saldo, grupo, analista, vozy_success_type, reason, code_reason, hang_up_cause, voicemail)
    select a.fecha,
           a.session_id,
           a.contact_phone,
           a.call_answered,
           a.campaign_name,
           a.duration,
           a.codigo_cliente,
           a.inactivo,
           a.fecha_limite,
           a.saldo,
           mod(r1, v_analistas) + 1 as grupo,
           b.nombre                 as analista,
           a.vozy_success_type,
           a.reason,
           a.code_reason,
           a.hang_up_cause,
           a.voicemail
    from tbl_asignacion_w1 a,
         tbl_analistas_ordenados b
    where (mod(r1, v_analistas) + 1) = b.grupo;

end;
$$;

alter procedure extracciones.pdw_distribucion_vozy(date) owner to "vozy.extracciones";

grant execute on procedure extracciones.pdw_distribucion_vozy(date) to extracciones_role;
