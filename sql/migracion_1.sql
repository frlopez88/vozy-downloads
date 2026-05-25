-- Migracion 1: agregar columna voicemail
-- Ejecutar antes de desplegar los nuevos procedimientos

ALTER TABLE extracciones.tbl_llamadas
    ADD COLUMN IF NOT EXISTS voicemail boolean DEFAULT false;

ALTER TABLE extracciones.tbl_extraccion_llamadas_vozy
    ADD COLUMN IF NOT EXISTS voicemail boolean DEFAULT false;

ALTER TABLE extracciones.tbl_asignacion
    ADD COLUMN IF NOT EXISTS voicemail boolean DEFAULT false;
