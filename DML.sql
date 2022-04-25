/*
Password123#@!
ESTE ARCHIVO SE EJECUTA DESPUES DE HABER CARGADO LOS DATOS A LAS TABLAS
*/

INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('S','Soltero');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('C','Casado');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('D','Divorciado');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('V','Viudo');

-- INSERTANDO DATOS DE LOS REGISTROS MASIVOS

-- Ingresar los nombres
INSERT INTO nombre_persona (nombre)
SELECT DISTINCT primer_nombre FROM tabla_temporal
WHERE (SELECT COUNT(id_nombre_persona) FROM nombre_persona WHERE nombre_persona.nombre = tabla_temporal.primer_nombre) <= 0;

INSERT INTO nombre_persona (nombre)
SELECT DISTINCT segundo_nombre FROM tabla_temporal
WHERE (SELECT COUNT(id_nombre_persona) FROM nombre_persona WHERE nombre_persona.nombre = tabla_temporal.segundo_nombre) <= 0;

INSERT INTO nombre_persona (nombre)
SELECT DISTINCT tercer_nombre FROM tabla_temporal
WHERE (SELECT COUNT(id_nombre_persona) FROM nombre_persona WHERE nombre_persona.nombre = tabla_temporal.tercer_nombre) <= 0;

-- Ingresar los apellidos
INSERT INTO apellido_persona (apellido)
SELECT DISTINCT primer_apellido FROM tabla_temporal
WHERE (SELECT COUNT(id_apellido_persona) FROM apellido_persona WHERE apellido_persona.apellido = tabla_temporal.primer_apellido) <= 0;

INSERT INTO apellido_persona (apellido)
SELECT DISTINCT segundo_apellido FROM tabla_temporal
WHERE (SELECT COUNT(id_apellido_persona) FROM apellido_persona WHERE apellido_persona.apellido = tabla_temporal.segundo_apellido) <= 0;

-- Ingresar las actas de nacimiento
INSERT INTO acta_nacimiento (primer_nombre,segundo_nombre,tercer_nombre,primer_apellido,segundo_apellido,genero,fecha_nacimiento,id_municipio,id_padre,id_madre)
SELECT 
	(SELECT id_nombre_persona FROM nombre_persona WHERE nombre_persona.nombre = tt.primer_nombre),
	(SELECT id_nombre_persona FROM nombre_persona WHERE nombre_persona.nombre = tt.segundo_nombre),
	(SELECT id_nombre_persona FROM nombre_persona WHERE nombre_persona.nombre = tt.tercer_nombre),
	(SELECT id_apellido_persona FROM apellido_persona WHERE apellido_persona.apellido = tt.primer_apellido),
	(SELECT id_apellido_persona FROM apellido_persona WHERE apellido_persona.apellido = tt.segundo_apellido),
	tt.genero, tt.fecha_nacimiento,tt.id_municipio,NULL,NULL
FROM tabla_temporal tt;

-- Ingresar las personas en la tabla de ciudadanos en el caso que sean >= 18 anios
INSERT INTO ciudadano (dpi,id_acta_nacimiento,id_estado_civil,id_municipio_residencia,fecha_emision)
SELECT CONCAT(id_acta_nacimiento,LPAD(id_municipio , 4, 0)) AS dpi,id_acta_nacimiento,'S',id_municipio,DATE(NOW()) FROM acta_nacimiento
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 18;

-- Ingresar las personas en la tabla acta_defuncion en el caso que sean >= 75 anios
INSERT INTO acta_defuncion (id_acta_nacimiento,fecha_fallecimiento,motivo)
SELECT id_acta_nacimiento,DATE(NOW()),'Carga Masiva' FROM acta_nacimiento
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 75;
