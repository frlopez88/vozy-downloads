// index.js
import dotenv from 'dotenv';
dotenv.config();

import { conversion } from './utils/conversionUnix.js';
import { request } from './controller/insercion.js';
import { limpiezaDistribucion } from './controller/limpieza.js';

const hoy = new Date();
const manana = new Date(hoy);
manana.setDate(hoy.getDate() + 1);

const fechaProceso = process.argv[2] || manana.toISOString().slice(0,10);
console.log("Fecha Proceso:", fechaProceso)

const dates = conversion(fechaProceso);
console.log(dates)
const base_url = process.env.BASE_URL;
const api_key = process.env.API_KEY;

const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function main() {
  let page = 1;
  let total = 0;

  while (true) {
    const url = `${base_url}?start_date=${dates.inicio_unix}&end_date=${dates.fin_unix}&page=${page}&per_page=500`;
    console.log(`Page ${page} -> ${url}`);

    const { count, done, error } = await request(url, api_key);

    if (error) {
      console.error('Error en la página', page, error);
      break; // corta para investigar; si quieres continuar, cambia a `page++` y `continue`
    }

    console.log(`Insertados ${count} registros en página ${page}`);
    total += count;

    if (done) {
      console.log('Fin de paginación (sin más registros)');
      break;
    }

    page += 1;
    await sleep(200);
  }
  console.log(`Total insertado: ${total}`);

  const { message } = await limpiezaDistribucion(fechaProceso )

  console.log("Proceso de Limpieza: ", message)
}

main().catch(err => console.error('Fatal:', err));