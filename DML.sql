/*
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password123#@!';
LOAD DATA INFILE '/home/douglas/Documentos/Sistemas de Base de Datos 1/Laboratorio/Proyecto 2/carga_masiva/departamentos.csv' INTO TABLE departamento FIELDS TERMINATED BY ';'
COPY departamento FROM '/home/douglas/Documentos/Sistemas de Base de Datos 1/Laboratorio/Proyecto 2/carga_masiva/departamentos.csv' DELIMITER ';' CSV HEADER;
*/

/*
ESTE ARCHIVO SE EJECUTA DESPUES DE HABER CARGADO LOS DATOS A LAS TABLAS
*/

INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('S','Soltero');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('C','Casado');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('D','Divorciado');
INSERT INTO estado_civil (id_estado_civil,nombre) VALUES ('V','Viudo');

-- INSERTANDO DATOS DE LOS REGISTROS MASIVOS

-- Ingresar las personas en la tabla de ciudadanos en el caso que sean >= 18 anios
INSERT INTO ciudadano (dpi,id_acta_nacimiento,id_estado_civil)
SELECT CONCAT(id_acta_nacimiento,LPAD(id_municipio , 4, 0)) AS dpi,id_acta_nacimiento,'S' FROM acta_nacimiento
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 18;

-- Ingresar las personas en la tabla acta_defuncion en el caso que sean >= 75 anios
INSERT INTO acta_defuncion (id_acta_nacimiento,fecha_fallecimiento,motivo)
SELECT id_acta_nacimiento,DATE(NOW()),'Carga Masiva' FROM acta_nacimiento
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 75;

-- 
