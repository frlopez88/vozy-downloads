export const conversion = (fechaStr) => {

    const fecha = new Date(fechaStr);

    if (isNaN(fecha)) {
        throw new Error("Fecha inválida. Usa formato: DD-MMM-YYYY, ej: 01-aug-2025");
    }

    // Calcular inicio del día (00:00:00)
    const inicio = new Date(fecha);
    inicio.setHours(0, 0, 0, 0);

    // Calcular fin del día (23:59:59)
    const fin = new Date(fecha);
    fin.setHours(23, 59, 59, 999);

    return {
        inicio_unix: Math.floor(inicio.getTime() / 1000),
        fin_unix: Math.floor(fin.getTime() / 1000),
        inicio_humano: inicio.toUTCString(),
        fin_humano: fin.toUTCString(), 
        fecha_original : fechaStr
    };


}