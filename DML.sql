/*
Password123#@!
ESTE ARCHIVO SE EJECUTA DESPUES DE HABER CARGADO LOS DATOS A LAS TABLAS
*/

INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('S','Soltero');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('C','Casado');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('D','Divorciado');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('V','Viudo');

INSERT INTO tipo_licencia (id_tipo_licencia,descripcion,restriccion) VALUES ('A','Permite conducir vehículos de transporte que tenga una carga de más de 3.5 toneladas métricas, incluyendo transporte escolar, colectivo, urbano y extraurbano.','Se tiene que ser mayor de 25 años y haber tenido licencia tipo B o C por más de 3 años.');
INSERT INTO tipo_licencia (id_tipo_licencia,descripcion,restriccion) VALUES ('B','Permite al conductor manejar toda clase de automóviles de hasta 3.5 toneladas métricas de peso bruto y pueden recibir remuneración o pago por conducir.','Se tiene que ser ser mayor de 23 años y haber tenido 2 años la licencia tipo C.');
INSERT INTO tipo_licencia (id_tipo_licencia,descripcion,restriccion) VALUES ('C','Se otorga al sacar la primera licencia. Permite, sin recibir remuneración o pago, manejar todo tipo de automóviles, páneles, pick-ups con o sin remolques que tengan un peso máximo de 3.5 toneladas métricas de peso.','Ninguna');
INSERT INTO tipo_licencia (id_tipo_licencia,descripcion,restriccion) VALUES ('M','Este tipo de licencia únicamente permite manejar motocicletas o moto bicicletas.','Ninguna');
INSERT INTO tipo_licencia (id_tipo_licencia,descripcion,restriccion) VALUES ('E','Permite a la persona conducir maquinaria agrícola e industrial, únicamente.','No se puede manejar cualquier otro vehículo.');

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
SELECT CONCAT(id_acta_nacimiento,LPAD(id_municipio , 4, 0)) AS dpi,id_acta_nacimiento,'S',id_municipio,DATE(DATE_ADD(fecha_nacimiento, INTERVAL 18 YEAR)) FROM acta_nacimiento
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 18;

-- DEFUNCIONES: Ingresar las personas en la tabla acta_defuncion en el caso que sean >= 75 anios
INSERT INTO acta_defuncion (id_acta_nacimiento,fecha_fallecimiento,motivo)
SELECT id_acta_nacimiento,DATE(DATE_ADD(NOW(), INTERVAL -2 YEAR)),'Carga Masiva' FROM acta_nacimiento
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 95;

-- 10 MATRIMONIOS
SELECT AddMatrimonio(10000000021407,10000019982211,'1980-01-05');
SELECT AddMatrimonio(10000000060116,10000019951018,'1990-02-05');
SELECT AddMatrimonio(10000000080611,10000019341208,'2000-03-05');
SELECT AddMatrimonio(10000000091902,10000019940610,'1989-04-05');
SELECT AddMatrimonio(10000000101201,10000019921414,'2000-05-05');
SELECT AddMatrimonio(10000000110514,10000019901313,'2006-06-05');
SELECT AddMatrimonio(10000000141709,10000019890909,'1990-07-05');
SELECT AddMatrimonio(10000000161015,10000019880905,'1985-08-05');
SELECT AddMatrimonio(10000000341228,10000019861014,'1978-09-05');
SELECT AddMatrimonio(10000000201502,10000019840508,'1990-10-05');
SELECT AddMatrimonio(10000000230116,10000019740920,'2005-02-05');
SELECT AddMatrimonio(10000000251206,10000019821321,'2009-03-09');
SELECT AddMatrimonio(10000000260205,10000019691212,'2003-02-17');
SELECT AddMatrimonio(10000000270512,10000019730204,'2001-03-21');
SELECT AddMatrimonio(10000000322202,10000019781312,'2004-01-25');

-- 20 LICENCIAS
SELECT AddLicencia(10000000060116,'2020-01-06','C');
SELECT AddLicencia(10000000141709,'2020-02-13','C');
SELECT AddLicencia(10000000171417,'2020-03-17','C');
SELECT AddLicencia(10000019890909,'2020-04-21','C');
SELECT AddLicencia(10000019760411,'2020-05-23','C');
SELECT AddLicencia(10000019691212,'2020-06-10','C');
SELECT AddLicencia(10000019601225,'2020-07-05','M');
SELECT AddLicencia(10000000371908,'2020-08-02','M');
SELECT AddLicencia(10000000420111,'2020-09-19','M');
SELECT AddLicencia(10000019971203,'2020-10-20','M');
SELECT AddLicencia(10000010011205,'2021-06-06','C');
SELECT AddLicencia(10000009940803,'2021-07-13','C');
SELECT AddLicencia(10000009971002,'2021-11-17','C');
SELECT AddLicencia(10000009960715,'2021-07-21','C');
SELECT AddLicencia(10000010040408,'2021-06-23','C');
SELECT AddLicencia(10000010050307,'2021-07-10','C');
SELECT AddLicencia(10000009952011,'2021-09-05','M');
SELECT AddLicencia(10000010060802,'2021-08-02','M');
SELECT AddLicencia(10000010071227,'2021-09-19','M');
SELECT AddLicencia(10000009980513,'2021-10-20','M');

-- 5 DIVORCIOS
SELECT AddDivorcio(1010,'2010-01-05');
SELECT AddDivorcio(1011,'2011-05-06');
SELECT AddDivorcio(1012,'2010-07-25');
SELECT AddDivorcio(1013,'2009-12-05');
SELECT AddDivorcio(1014,'2007-05-17');
