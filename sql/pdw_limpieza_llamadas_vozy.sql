create or replace procedure extracciones.pdw_limpieza_llamadas_vozy(IN p_fecha date)
    language plpgsql
as
$$
declare

    v_fecha date := p_fecha - '1day'::interval;

begin

    drop table if exists tbl_llamadas_variables;

    create temp table tbl_llamadas_variables
    as
    SELECT t.session_id,
           u.idx,
           u.elem ->> 'name'  AS name,
           u.elem ->> 'value' AS value
    FROM extracciones.tbl_llamadas AS t
             CROSS JOIN LATERAL unnest(t.variables) WITH ORDINALITY AS u(elem, idx)
    WHERE t.call_answered = 'true'
    ORDER BY u.idx;

    drop table if exists tbl_llamadas_final;

    create temp table tbl_llamadas_final
    (
        fecha             date,
        session_id        varchar(200),
        contact_phone     varchar(20),
        call_answered     bool,
        campaign_name     varchar(300),
        duration          numeric,
        codigo_cliente    varchar(50),
        inactivo          varchar(2),
        fecha_limite      date,
        saldo             numeric,
        vozy_success_type varchar(200),
        reason            varchar(1000),
        code_reason       varchar(1000),
        hang_up_cause     varchar(1000),
        voicemail         boolean,
        contactability    varchar(200),
        call_contacted    boolean
    );

    insert into tbl_llamadas_final
    (fecha, session_id, contact_phone, call_answered, campaign_name, duration, hang_up_cause, voicemail, contactability, call_contacted)
    select to_date(fecha, 'yyyy-mm-dd'),
           session_id,
           contact_phone,
           cast(call_answered as bool),
           campaign_name,
           duration,
           hang_up_cause,
           coalesce(voicemail, false),
           contactability,
           coalesce(call_contacted, false)
    from extracciones.tbl_llamadas;

    update tbl_llamadas_final a
    set codigo_cliente = b.value
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'codigo_cliente';

    update tbl_llamadas_final a
    set inactivo = b.value
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'userType'
      and b.value in ('SI', 'NO');

    update tbl_llamadas_final a
    set fecha_limite = extracciones.convertir_a_fecha(b.value)
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'limitDate';

    update tbl_llamadas_final a
    set saldo = cast(b.value as numeric)
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'debtAmount'
      and b.value ~ '^[0-9]+(\.[0-9]+)?$';

    update tbl_llamadas_final a
    set vozy_success_type = b.value
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'Vozy_SuccessType';

    update tbl_llamadas_final a
    set reason = b.value
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'reason';

    update tbl_llamadas_final a
    set code_reason = b.value
    from tbl_llamadas_variables b
    where a.session_id = b.session_id
      and b.name = 'code_reason';

    delete
    from extracciones.tbl_extraccion_llamadas_vozy
    where fecha = v_fecha;

    insert into extracciones.tbl_extraccion_llamadas_vozy
    (fecha,
     session_id,
     contact_phone,
     call_answered,
     campaign_name,
     duration,
     codigo_cliente,
     inactivo,
     fecha_limite,
     saldo,
     hang_up_cause,
     vozy_success_type,
     reason,
     code_reason,
     voicemail,
     contactability,
     call_contacted)
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
           hang_up_cause,
           vozy_success_type,
           reason,
           code_reason,
           voicemail,
           contactability,
           call_contacted
    from tbl_llamadas_final;

    truncate table extracciones.tbl_llamadas;

end;
$$;

alter procedure extracciones.pdw_limpieza_llamadas_vozy(date) owner to "vozy.extracciones";

grant execute on procedure extracciones.pdw_limpieza_llamadas_vozy(date) to extracciones_role;
