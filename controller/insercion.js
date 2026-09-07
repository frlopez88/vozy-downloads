// controller/insercion.js
import { pool } from '../db/cn.js';
import { config } from 'dotenv';

config()

const tabla = process.env.BD_TBL_LLAMADAS


const INSERT_SQL = `
  INSERT INTO ${tabla}
  (fecha, session_id, contact_phone, call_answered, duration, campaign_name, variables, hang_up_cause, voicemail, contactability, call_contacted)
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
`;



export const request = async (url, x_api_key) => {
  try {
    const res = await fetch(url, {
      method: 'GET',
      headers: { 'x-api-key': x_api_key }
    });

    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`HTTP ${res.status} ${res.statusText} – ${text}`);
    }

    const json = await res.json();
    const records = json?.data?.call_record ?? null;

    // Fin de la paginación si viene null o array vacío
    if (!records || records.length === 0) {
      return { count: 0, done: true };
    }

    /* --- DIAGNOSTICO: imprime el primer registro para verificar estructura ---
    console.log('=== PRIMER REGISTRO (estructura completa) ===');
    console.log(JSON.stringify(records[0], null, 2));
    console.log('=== voicemail del primer registro:', records[0]?.voicemail);
    console.log('=== keys del primer registro:', Object.keys(records[0] ?? {}));
     ----------------------------------------------------------------------- */

    for (const obj of records) {
      
      const params = [
        obj.date?.substring(0, 10),
        obj.session_id,
        obj.contact_phone?.substring(0, 12),
        obj.call_answered,
        obj.duration,
        obj.campaign_name,
        obj.variables,
        obj.hang_up_cause,
        obj.call_voicemail ?? false,
        obj.contactability_type,
        obj.call_contacted
      ];
      await pool.query(INSERT_SQL, params);
    }

    return { count: records.length, done: false };
  } catch (err) {
    console.error('request() error:', err.message);
    // si falla, corta la paginación para que no quede en loop infinito
    return { count: 0, done: true, error: err.message };
  }
};
