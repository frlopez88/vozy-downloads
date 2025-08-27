// controller/insercion.js
import { pool } from '../db/cn.js';

const INSERT_SQL = `
  INSERT INTO extracciones.tbl_llamadas
  (fecha, session_id, contact_phone, call_answered, duration, campaign_name, variables)
  VALUES ($1, $2, $3, $4, $5, $6, $7)
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

    const answered = records.filter(r => r.call_answered === true);

    for (const obj of answered) {
      const params = [
        obj.date?.substring(0, 10), 
        obj.session_id,
        obj.contact_phone?.substring(0, 12), 
        obj.call_answered,
        obj.duration,
        obj.campaign_name,
        obj.variables
      ];
      await pool.query(INSERT_SQL, params);
    }

    return { count: answered.length, done: false };

  } catch (err) {
    console.error('request() error:', err.message);
    // si falla, corta la paginación para que no quede en loop infinito
    return { count: 0, done: true, error: err.message };
  }
};
