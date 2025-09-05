import { pool } from "../db/cn.js";
import { config } from "dotenv";

config()

const procedureName = process.env.BD_PKG;

export const limpiezaDistribucion = async (p_fecha) => {

    const sql = `call ${procedureName}`
    const params = [p_fecha]
    console.log(sql)
    console.log(p_fecha)

    try {

        await pool.query(sql, params)
        return { message: "Proceso Finalizado", tieneError2: false }

    } catch (err) {
        return { message: err.message, tieneError2: true }
    }


}

