import {Pool } from 'pg';
import dotenv from 'dotenv';
dotenv.config()

export const pool = new Pool({
    port: 5432,
    host: process.env.PG_HOST,
    password: process.env.PG_PASS,
    user: process.env.PG_USER,
    database: process.env.PG_DB
});