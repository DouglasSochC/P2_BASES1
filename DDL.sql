/*
CREATE DATABASE b1_proyecto2;
https://dev.mysql.com/doc/refman/8.0/en/example-foreign-keys.html
*/

CREATE TABLE departamento(
    id_departamento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE municipio(
    id_municipio INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    id_departamento INT UNSIGNED NOT NULL,
    FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento)
);

CREATE TABLE persona (
    id_persona INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    primer_nombre VARCHAR(30) CHECK (primer_nombre NOT LIKE '%[^A-Z]%') NOT NULL,
    segundo_nombre VARCHAR(30) CHECK (segundo_nombre NOT LIKE '%[^a-zA-Z]%'),
    tercer_nombre VARCHAR(150) CHECK (tercer_nombre NOT LIKE '%[^a-zA-Z]%'),
    primer_apellido VARCHAR(30) NOT NULL CHECK (primer_apellido NOT LIKE '%[^a-zA-Z]%'),
    segundo_apellido VARCHAR(30) CHECK (segundo_apellido NOT LIKE '%[^a-zA-Z]%'),
    genero VARCHAR(1) NOT NULL CHECK (genero NOT LIKE '%[M|F]%'),
    fecha_nacimiento DATE NOT NULL,
    id_municipio INT UNSIGNED NOT NULL,
    id_padre BIGINT UNSIGNED,
    id_madre BIGINT UNSIGNED,
    FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio)
);

CREATE TABLE estado_civil (
    id_estado_civil INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE ciudadano(
    dpi BIGINT UNSIGNED PRIMARY KEY,
    id_persona INT UNSIGNED NOT NULL,
    id_estado_civil INT UNSIGNED NOT NULL,
    FOREIGN KEY (id_persona) REFERENCES persona (id_persona),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil (id_estado_civil)
);
ALTER TABLE persona ADD CONSTRAINT `fk_padre` FOREIGN KEY (`id_padre`) REFERENCES `ciudadano` (`dpi`);
ALTER TABLE persona ADD CONSTRAINT `fk_madre` FOREIGN KEY (`id_madre`) REFERENCES `ciudadano` (`dpi`);

CREATE TABLE acta_defuncion (
    id_acta_defuncion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_persona INT UNSIGNED NOT NULL,
    fecha_fallecimiento DATE NOT NULL,
    motivo TEXT NOT NULL,
    FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
);

-- CREATE TABLE acta_matrimonio (
--     id_acta_matrimonio BIGINT UNSIGNED PRIMARY KEY,
--     id_ciudadano_1 BIGINT UNSIGNED NOT NULL,
--     id_ciudadano_2 BIGINT UNSIGNED NOT NULL,
--     FOREIGN KEY (id_ciudadano_1) REFERENCES ciudadano (id_ciudadano),
--     FOREIGN KEY (id_ciudadano_2) REFERENCES ciudadano (id_ciudadano)
-- );

-- CREATE TABLE acta_divorcio(
--     id_acta_divorcio BIGINT UNSIGNED PRIMARY KEY,
--     id_ciudadano_1 BIGINT UNSIGNED NOT NULL,
--     id_ciudadano_2 BIGINT UNSIGNED NOT NULL,
--     FOREIGN KEY (id_ciudadano_1) REFERENCES ciudadano (id_ciudadano),
--     FOREIGN KEY (id_ciudadano_2) REFERENCES ciudadano (id_ciudadano)
-- );

-- CREATE TABLE tipo_licencia (
--     id_tipo_licencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
--     nombre VARCHAR(30) NOT NULL,
--     cantidad_carga DOUBLE NOT NULL,
--     minimo_edad INT NOT NULL,
--     descripcion VARCHAR(200) NOT NULL
-- );

-- CREATE TABLE licencia_ciudadano(
--     id_licencia_ciudadano INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
--     id_ciudadano INT UNSIGNED,
--     id_tipo_licencia INT UNSIGNED,
--     fecha_emision DATE NOT NULL,
--     FOREIGN KEY (id_ciudadano) REFERENCES ciudadano (id_ciudadano),
--     FOREIGN KEY (id_tipo_licencia) REFERENCES tipo_licencia (id_tipo_licencia),

-- );

ALTER TABLE persona AUTO_INCREMENT=1000000000;
ALTER TABLE departamento AUTO_INCREMENT=10;
ALTER TABLE municipio AUTO_INCREMENT=10;

-- FUNCIONES

DELIMITER $$
-- El formato de fecha utilizado en esta funcion es de yyyy-mm-dd
CREATE FUNCTION addNacimiento(dpi_padre BIGINT,dpi_madre BIGINT,primer_nombre VARCHAR(30),segundo_nombre VARCHAR(30),tercer_nombre VARCHAR(150),fecha_nacimiento DATE,id_municipio INT, genero VARCHAR(1)) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE existe_padre,existe_madre,verificacion_fecha BOOLEAN;
    DECLARE p_apellido,s_apellido VARCHAR(30);
    SET existe_padre = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi = dpi_padre) > 0;
    SET existe_madre = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi = dpi_madre) > 0;
    SET verificacion_fecha = (SELECT DATEDIFF(NOW(), fecha_nacimiento)) >= 0;

    IF NOT existe_padre THEN
   	    RETURN 'DPI del padre invalido';
    END IF;
  
    IF NOT existe_madre THEN
   	    RETURN 'DPI de la madre invalido';
    END IF;
    
    IF NOT verificacion_fecha THEN
        RETURN 'No se pueden registrar nacimientos con una fecha posterior a la fecha de registro';
    END IF;
    
    SET p_apellido = (SELECT primer_apellido FROM persona INNER JOIN ciudadano ON (ciudadano.id_persona = persona.id_persona) WHERE ciudadano.dpi = dpi_padre);
    SET s_apellido = (SELECT primer_apellido FROM persona INNER JOIN ciudadano ON (ciudadano.id_persona = persona.id_persona) WHERE ciudadano.dpi = dpi_madre);

    INSERT INTO persona (primer_nombre,segundo_nombre,tercer_nombre,primer_apellido,segundo_apellido,genero,fecha_nacimiento,id_municipio,id_padre,id_madre) 
    VALUES (primer_nombre,segundo_nombre,tercer_nombre,p_apellido,s_apellido,genero,fecha_nacimiento,id_municipio,dpi_padre,dpi_madre);

    RETURN 'Ingresado Correctamente';
END$$
-- SELECT addNacimiento(1,1,'a','b','c','2020-01-01',101,'M');
-- SELECT addNacimiento(10000000000308,10000000011103,'a','b','c','2020-01-01',101,'M');
DELIMITER

DELIMITER $$
-- El formato de fecha utilizado en esta funcion es de yyyy-mm-dd
CREATE FUNCTION AddDefuncion(p_cui BIGINT,p_fecha_fallecido DATE,p_motivo TEXT) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE ya_nacio BOOLEAN;
    DECLARE ya_murio BOOLEAN;
    DECLARE p_id_persona INT;

    SET p_id_persona = (SELECT id_persona FROM (SELECT CONCAT(id_persona,LPAD(id_municipio , 4, 0)) AS cui,id_persona FROM persona) existencia_cui WHERE cui = p_cui);
    SET ya_murio = (SELECT COUNT(id_acta_defuncion) FROM acta_defuncion WHERE id_persona = p_id_persona) > 0;
    SET ya_nacio = (SELECT DATEDIFF(p_fecha_fallecido, (SELECT fecha_nacimiento FROM persona WHERE id_persona = p_id_persona))) > 0;

    IF p_id_persona IS NULL THEN
   	    RETURN 'No existe el CUI ingresado';
    END IF;

    IF NOT ya_nacio THEN
        RETURN 'La fecha de fallecimiento es menor a la fecha de nacimiento';
    END IF;
  
    IF ya_murio THEN
   	    RETURN 'Esta persona ya posee un acta de defuncion';
    END IF;

    INSERT INTO acta_defuncion (id_persona,fecha_fallecimiento,motivo) 
    VALUES (p_id_persona,p_fecha_fallecido,p_motivo);

    RETURN 'Ingresado Correctamente';
END$$
-- SELECT AddDefuncion(1,'2000-10-24','Enfermedad');
-- SELECT AddDefuncion(10000000000308,'2000-10-22','Enfermedad');
-- SELECT AddDefuncion(10000000000308,'2020-10-22','Enfermedad');
DELIMITER
