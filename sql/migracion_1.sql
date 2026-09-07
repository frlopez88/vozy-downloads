-- Migracion 1: agregar columna voicemail
-- Ejecutar antes de desplegar los nuevos procedimientos

ALTER TABLE extracciones.tbl_llamadas
    ADD COLUMN IF NOT EXISTS voicemail boolean DEFAULT false;

ALTER TABLE extracciones.tbl_extraccion_llamadas_vozy
    ADD COLUMN IF NOT EXISTS voicemail boolean DEFAULT false;

ALTER TABLE extracciones.tbl_asignacion
    ADD COLUMN IF NOT EXISTS voicemail boolean DEFAULT false;

-- Migracion 2: agregar columnas contactability y call_contacted
-- Ejecutar antes de desplegar los nuevos procedimientos

ALTER TABLE extracciones.tbl_llamadas
    ADD COLUMN IF NOT EXISTS contactability varchar(200),
    ADD COLUMN IF NOT EXISTS call_contacted boolean DEFAULT false;

ALTER TABLE extracciones.tbl_extraccion_llamadas_vozy
    ADD COLUMN IF NOT EXISTS contactability varchar(200),
    ADD COLUMN IF NOT EXISTS call_contacted boolean DEFAULT false;

ALTER TABLE extracciones.tbl_asignacion
    ADD COLUMN IF NOT EXISTS contactability varchar(200),
    ADD COLUMN IF NOT EXISTS call_contacted boolean DEFAULT false;
