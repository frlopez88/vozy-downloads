create or replace procedure extracciones.pkg_carga_vozy(IN p_fecha date)
    language plpgsql
as
$$
declare

begin

    call extracciones.pdw_limpieza_llamadas_vozy(p_fecha);
    call extracciones.pdw_distribucion_vozy(p_fecha);

end;
$$;

alter procedure extracciones.pkg_carga_vozy(date) owner to "vozy.extracciones";

grant execute on procedure extracciones.pkg_carga_vozy(date) to extracciones_role;
