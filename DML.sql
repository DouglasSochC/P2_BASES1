/*
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password123#@!';
LOAD DATA INFILE '/home/douglas/Documentos/Sistemas de Base de Datos 1/Laboratorio/Proyecto 2/carga_masiva/departamentos.csv' INTO TABLE departamento FIELDS TERMINATED BY ';'
COPY departamento FROM '/home/douglas/Documentos/Sistemas de Base de Datos 1/Laboratorio/Proyecto 2/carga_masiva/departamentos.csv' DELIMITER ';' CSV HEADER;
*/

INSERT INTO estado_civil (nombre) VALUES ('Soltero');
INSERT INTO estado_civil (nombre) VALUES ('Casado');
INSERT INTO estado_civil (nombre) VALUES ('Divorciado');
INSERT INTO estado_civil (nombre) VALUES ('Viudo');

-- Ingresar las personas (que fueron ingresadas masivamente) en la tabla de ciudadanos solo en el caso que sean >= 18 anios
INSERT INTO ciudadano (dpi,id_persona,id_estado_civil)
SELECT CONCAT(id_persona,LPAD(id_municipio , 4, 0)) AS dpi,id_persona,1 FROM persona
WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 18;

-- 
