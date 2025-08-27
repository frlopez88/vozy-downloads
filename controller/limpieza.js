import { pool } from "../db/cn.js";


export const limpiezaDistribucion = async (p_fecha) => {

    const sql = `call extracciones.pkg_carga_vozy($1)`
    const params = [p_fecha]

    try {

        await pool.query(sql, params)
        return { message: "Proceso Finalizado" }

    } catch (err) {
        return { message: err.message }
    }


}

