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

CREATE TABLE acta_nacimiento (
    id_acta_nacimiento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
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
    id_estado_civil VARCHAR(1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE ciudadano(
    dpi BIGINT UNSIGNED PRIMARY KEY,
    id_acta_nacimiento INT UNSIGNED NOT NULL,
    id_estado_civil VARCHAR(1) NOT NULL,
    FOREIGN KEY (id_acta_nacimiento) REFERENCES acta_nacimiento (id_acta_nacimiento),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil (id_estado_civil)
);
ALTER TABLE acta_nacimiento ADD CONSTRAINT `fk_padre` FOREIGN KEY (`id_padre`) REFERENCES `ciudadano` (`dpi`);
ALTER TABLE acta_nacimiento ADD CONSTRAINT `fk_madre` FOREIGN KEY (`id_madre`) REFERENCES `ciudadano` (`dpi`);

CREATE TABLE acta_defuncion (
    id_acta_defuncion INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_acta_nacimiento INT UNSIGNED NOT NULL,
    fecha_fallecimiento DATE NOT NULL,
    motivo TEXT NOT NULL,
    FOREIGN KEY (id_acta_nacimiento) REFERENCES acta_nacimiento (id_acta_nacimiento)
);

CREATE TABLE acta_matrimonio (
    id_acta_matrimonio BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dpi_hombre BIGINT UNSIGNED NOT NULL,
    dpi_mujer BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (dpi_hombre) REFERENCES ciudadano (dpi),
    FOREIGN KEY (dpi_mujer) REFERENCES ciudadano (dpi)
);

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

ALTER TABLE acta_nacimiento AUTO_INCREMENT=1000000000;
ALTER TABLE departamento AUTO_INCREMENT=10;
ALTER TABLE municipio AUTO_INCREMENT=10;

-- PROCEDIMIENTOS

-- Se obtiene el id del acta de nacimiento a traves del CUI generado con su id_municipio
DELIMITER $$
CREATE FUNCTION obtenerIDAN(p_cui BIGINT) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE respuesta INT;
    SET respuesta = (SELECT id_acta_nacimiento FROM (SELECT CONCAT(id_acta_nacimiento,LPAD(id_municipio , 4, 0)) AS cui,id_acta_nacimiento FROM acta_nacimiento) existencia_cui WHERE cui = p_cui);
    RETURN respuesta;
END$$
DELIMITER

-- FUNCIONES

DELIMITER $$
-- El formato de fecha utilizado en esta funcion es de yyyy-mm-dd
CREATE FUNCTION addNacimiento(p_dpi_padre BIGINT,p_dpi_madre BIGINT,primer_nombre VARCHAR(30),segundo_nombre VARCHAR(30),tercer_nombre VARCHAR(150),fecha_nacimiento DATE,id_municipio INT,p_genero VARCHAR(1)) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE existe_padre,existe_madre,verificacion_fecha BOOLEAN;
    DECLARE p_apellido,s_apellido VARCHAR(30);
    SET existe_padre = (SELECT COUNT(id_acta_nacimiento) FROM acta_nacimiento WHERE acta_nacimiento.id_acta_nacimiento = (SELECT obtenerIDAN(p_dpi_padre)) AND acta_nacimiento.genero = 'M') > 0;
    SET existe_madre = (SELECT COUNT(id_acta_nacimiento) FROM acta_nacimiento WHERE acta_nacimiento.id_acta_nacimiento = (SELECT obtenerIDAN(p_dpi_madre)) AND acta_nacimiento.genero = 'F') > 0;
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
    
    SET p_apellido = (SELECT primer_apellido FROM acta_nacimiento INNER JOIN ciudadano ON (ciudadano.id_acta_nacimiento = acta_nacimiento.id_acta_nacimiento) WHERE ciudadano.dpi = p_dpi_padre);
    SET s_apellido = (SELECT primer_apellido FROM acta_nacimiento INNER JOIN ciudadano ON (ciudadano.id_acta_nacimiento = acta_nacimiento.id_acta_nacimiento) WHERE ciudadano.dpi = p_dpi_madre);

    INSERT INTO acta_nacimiento (primer_nombre,segundo_nombre,tercer_nombre,primer_apellido,segundo_apellido,genero,fecha_nacimiento,id_municipio,id_padre,id_madre) 
    VALUES (primer_nombre,segundo_nombre,tercer_nombre,p_apellido,s_apellido,p_genero,fecha_nacimiento,id_municipio,p_dpi_padre,p_dpi_madre);

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
    DECLARE p_id_acta_nacimiento INT;

    SET p_id_acta_nacimiento = (SELECT obtenerIDAN (p_cui));
    SET ya_murio = (SELECT COUNT(id_acta_defuncion) FROM acta_defuncion WHERE id_acta_nacimiento = p_id_acta_nacimiento) > 0;
    SET ya_nacio = (SELECT DATEDIFF(p_fecha_fallecido, (SELECT fecha_nacimiento FROM acta_nacimiento WHERE id_acta_nacimiento = p_id_acta_nacimiento))) > 0;

    IF p_id_acta_nacimiento IS NULL THEN
   	    RETURN 'No existe el CUI ingresado';
    END IF;

    IF NOT ya_nacio THEN
        RETURN 'La fecha de fallecimiento es menor a la fecha de nacimiento';
    END IF;
  
    IF ya_murio THEN
   	    RETURN 'Esta acta_nacimiento ya posee un acta de defuncion';
    END IF;

    INSERT INTO acta_defuncion (id_acta_nacimiento,fecha_fallecimiento,motivo) 
    VALUES (p_id_acta_nacimiento,p_fecha_fallecido,p_motivo);

    RETURN 'Ingresado Correctamente';
END$$
-- SELECT AddDefuncion(1,'2000-10-24','Enfermedad');
-- SELECT AddDefuncion(10000000000308,'2000-10-22','Enfermedad');
DELIMITER

DELIMITER $$
-- El formato de fecha utilizado en esta funcion es de yyyy-mm-dd
CREATE FUNCTION AddMatrimonio(p_dpi_hombre BIGINT,p_dpi_mujer BIGINT,p_fecha_matrimonio DATE) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE posee_dpi_hombre,posee_dpi_mujer,es_hombre,es_mujer,hombre_fallecido,mujer_fallecida,hombre_casado,mujer_casada BOOLEAN;
    
    SET posee_dpi_hombre = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi = p_dpi_hombre) = 1;
    SET posee_dpi_mujer = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi = p_dpi_mujer) = 1;
    IF NOT posee_dpi_hombre THEN
   	    RETURN 'El DPI del hombre no existe';
    ELSEIF NOT posee_dpi_mujer THEN
        RETURN 'El DPI de la mujer no existe';
    END IF;

    SET es_hombre = (SELECT COUNT(acta_nacimiento.id_acta_nacimiento) FROM acta_nacimiento INNER JOIN ciudadano ON (ciudadano.id_acta_nacimiento = acta_nacimiento.id_acta_nacimiento) WHERE ciudadano.dpi = p_dpi_hombre AND acta_nacimiento.genero = 'M') = 1;
    SET es_mujer = (SELECT COUNT(acta_nacimiento.id_acta_nacimiento) FROM acta_nacimiento INNER JOIN ciudadano ON (ciudadano.id_acta_nacimiento = acta_nacimiento.id_acta_nacimiento) WHERE ciudadano.dpi = p_dpi_mujer AND acta_nacimiento.genero = 'F') = 1;
    IF NOT es_hombre THEN
   	    RETURN 'El DPI ingresado en el parametro p_dpi_hombre no es un hombre';
    ELSEIF NOT es_mujer THEN
        RETURN 'El DPI ingresado en el parametro p_dpi_mujer no es una mujer';
    END IF;

    SET hombre_fallecido = (SELECT COUNT(id_acta_defuncion) FROM acta_defuncion WHERE acta_defuncion.id_acta_nacimiento = (SELECT acta_nacimiento.id_acta_nacimiento FROM acta_nacimiento INNER JOIN ciudadano ON (ciudadano.id_acta_nacimiento = acta_nacimiento.id_acta_nacimiento) WHERE ciudadano.dpi = p_dpi_hombre)) = 1;
    SET mujer_fallecida = (SELECT COUNT(id_acta_defuncion) FROM acta_defuncion WHERE acta_defuncion.id_acta_nacimiento = (SELECT acta_nacimiento.id_acta_nacimiento FROM acta_nacimiento INNER JOIN ciudadano ON (ciudadano.id_acta_nacimiento = acta_nacimiento.id_acta_nacimiento) WHERE ciudadano.dpi = p_dpi_mujer)) = 1;
    IF hombre_fallecido THEN
   	    RETURN 'El hombre ya ha fallecido';
    ELSEIF mujer_fallecida THEN
        RETURN 'La mujer ya ha fallecido';
    END IF;

    SET hombre_casado = (SELECT COUNT(dpi) FROM ciudadano WHERE ciudadano.dpi = p_dpi_hombre AND ciudadano.id_estado_civil = 'C') = 1;
    SET mujer_casada = (SELECT COUNT(dpi) FROM ciudadano WHERE ciudadano.dpi = p_dpi_mujer AND ciudadano.id_estado_civil = 'C') = 1;
    IF hombre_casado THEN
        RETURN 'El hombre tiene un matrimonio activo';
    ELSEIF mujer_casada THEN
        RETURN 'La mujer tiene un matrimonio activo';
    END IF;
    
    INSERT INTO acta_matrimonio (dpi_hombre,dpi_mujer) 
    VALUES (p_dpi_hombre,p_dpi_mujer);

    UPDATE ciudadano SET id_estado_civil = 'C' WHERE dpi IN (p_dpi_hombre,p_dpi_mujer);

    RETURN 'Ingresado Correctamente';
END$$
-- SELECT AddMatrimonio(1,1,'2000-10-24');
-- SELECT AddMatrimonio(10000000000308,'2000-10-22','Enfermedad');
DELIMITER