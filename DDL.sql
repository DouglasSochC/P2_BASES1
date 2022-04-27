/*
CREATE DATABASE b1_proyecto2;
https://dev.mysql.com/doc/refman/8.0/en/example-foreign-keys.html
*/

CREATE TABLE tabla_temporal (
    id_acta_nacimiento TEXT,
    primer_nombre TEXT,
    segundo_nombre TEXT,
    tercer_nombre TEXT,
    primer_apellido TEXT,
    segundo_apellido TEXT,
    genero TEXT,
    fecha_nacimiento TEXT,
    id_municipio TEXT,
    id_padre TEXT,
    id_madre TEXT
);

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

CREATE TABLE nombre_persona (
    id_nombre_persona INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre TEXT NOT NULL CHECK (nombre NOT LIKE '%[^a-zA-Z]%')
);

CREATE TABLE apellido_persona (
    id_apellido_persona INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    apellido TEXT NOT NULL CHECK (apellido NOT LIKE '%[^a-zA-Z]%')
);

CREATE TABLE acta_nacimiento (
    id_acta_nacimiento INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    primer_nombre INT UNSIGNED NOT NULL,
    segundo_nombre INT UNSIGNED,
    tercer_nombre INT UNSIGNED,
    primer_apellido INT UNSIGNED NOT NULL,
    segundo_apellido INT UNSIGNED,
    genero VARCHAR(1) NOT NULL CHECK (genero NOT LIKE '%[M|F]%'),
    fecha_nacimiento DATE NOT NULL,
    id_municipio INT UNSIGNED NOT NULL,
    id_padre BIGINT UNSIGNED,
    id_madre BIGINT UNSIGNED,
    FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio),
    FOREIGN KEY (primer_nombre) REFERENCES nombre_persona (id_nombre_persona),
    FOREIGN KEY (segundo_nombre) REFERENCES nombre_persona (id_nombre_persona),
    FOREIGN KEY (tercer_nombre) REFERENCES nombre_persona (id_nombre_persona),
    FOREIGN KEY (primer_apellido) REFERENCES apellido_persona (id_apellido_persona),
    FOREIGN KEY (segundo_apellido) REFERENCES apellido_persona (id_apellido_persona)
);

CREATE TABLE estado_civil (
    id_estado_civil VARCHAR(1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
);

CREATE TABLE ciudadano(
    dpi BIGINT UNSIGNED PRIMARY KEY,
    id_acta_nacimiento INT UNSIGNED NOT NULL,
    id_estado_civil VARCHAR(1) NOT NULL,
    id_municipio_residencia INT UNSIGNED NOT NULL,
    fecha_emision DATE NOT NULL,
    FOREIGN KEY (id_acta_nacimiento) REFERENCES acta_nacimiento (id_acta_nacimiento),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil (id_estado_civil),
    FOREIGN KEY (id_municipio_residencia) REFERENCES municipio (id_municipio)
);

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
    fecha_matrimonio DATE NOT NULL,
    estado BOOLEAN NOT NULL,
    FOREIGN KEY (dpi_hombre) REFERENCES ciudadano (dpi),
    FOREIGN KEY (dpi_mujer) REFERENCES ciudadano (dpi)
);

CREATE TABLE acta_divorcio(
    id_acta_divorcio BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_acta_matrimonio BIGINT UNSIGNED NOT NULL,
    fecha_divorcio DATE NOT NULL,
    FOREIGN KEY (id_acta_matrimonio) REFERENCES acta_matrimonio (id_acta_matrimonio)
);

CREATE TABLE tipo_licencia (
    id_tipo_licencia VARCHAR(1) NOT NULL PRIMARY KEY,
    descripcion TEXT NOT NULL,
    restriccion TEXT NOT NULL
);

CREATE TABLE licencia_conducir (
    id_licencia_conducir INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    licencia_anulada BOOLEAN NOT NULL,
    fecha_anulacion DATE,
    id_acta_nacimiento INT UNSIGNED NOT NULL,
    FOREIGN KEY (id_acta_nacimiento) REFERENCES acta_nacimiento (id_acta_nacimiento)
);

CREATE TABLE detalle_licencia_conducir (
    id_detalle_licencia_conducir INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_emision DATE NOT NULL,
    fecha_renovacion DATE NOT NULL,
    id_tipo_licencia VARCHAR(1) NOT NULL,
    id_licencia_conducir INT UNSIGNED NOT NULL,
    FOREIGN KEY (id_tipo_licencia) REFERENCES tipo_licencia (id_tipo_licencia),
    FOREIGN KEY (id_licencia_conducir) REFERENCES licencia_conducir (id_licencia_conducir)
);

-- ALTER TABLES
ALTER TABLE acta_nacimiento ADD CONSTRAINT `fk_padre` FOREIGN KEY (`id_padre`) REFERENCES `ciudadano` (`dpi`);
ALTER TABLE acta_nacimiento ADD CONSTRAINT `fk_madre` FOREIGN KEY (`id_madre`) REFERENCES `ciudadano` (`dpi`);
ALTER TABLE acta_nacimiento AUTO_INCREMENT=1000000000;
ALTER TABLE acta_matrimonio AUTO_INCREMENT=1000;
ALTER TABLE acta_divorcio AUTO_INCREMENT=1000;
ALTER TABLE licencia_conducir AUTO_INCREMENT=1000;
ALTER TABLE departamento AUTO_INCREMENT=10;
ALTER TABLE municipio AUTO_INCREMENT=10;

-- FUNCIONES FUNCIONES FUNCIONES FUNCIONES FUNCIONES FUNCIONES --
-- FUNCIONES FUNCIONES FUNCIONES FUNCIONES FUNCIONES FUNCIONES --
-- FUNCIONES FUNCIONES FUNCIONES FUNCIONES FUNCIONES FUNCIONES --

-- NOTAS:
-- 1. El formato de fecha utilizado en las funciones es de yyyy-mm-dd

DELIMITER $$
-- Se obtiene el id del acta de nacimiento a traves del CUI generado con el 'id_acta_nacimiento' + 'id_municipio'
CREATE FUNCTION obtenerIDAN(p_cui BIGINT) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE respuesta INT;
    SET respuesta = (SELECT id_acta_nacimiento FROM (SELECT CONCAT(id_acta_nacimiento,LPAD(id_municipio , 4, 0)) AS cui,id_acta_nacimiento FROM acta_nacimiento) existencia_cui WHERE cui = p_cui);
    RETURN respuesta;
END$$
DELIMITER

DELIMITER $$
-- Retorna el id del nombre de una persona, en el caso que no exista el nombre este se ingresa
CREATE FUNCTION idNombrePersona(p_nombre TEXT) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE respuesta INT;
    SET respuesta = (SELECT id_nombre_persona FROM nombre_persona WHERE nombre = p_nombre);

    IF respuesta IS NULL THEN
        INSERT INTO nombre_persona (nombre) VALUES (p_nombre);
        SET respuesta = (SELECT LAST_INSERT_ID());
    END IF;

    RETURN respuesta;
END$$
DELIMITER

DELIMITER $$
-- Retorna el id de la licencia que ha sido insertada
CREATE FUNCTION crearLicencia(p_id_acta_nacimiento INT) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE respuesta INT;
    INSERT INTO licencia_conducir (licencia_anulada,id_acta_nacimiento) VALUES (FALSE,p_id_acta_nacimiento);
    SET respuesta = (SELECT LAST_INSERT_ID());
    RETURN respuesta;
END$$
DELIMITER

DELIMITER $$
CREATE FUNCTION addNacimiento(p_dpi_padre BIGINT,p_dpi_madre BIGINT,p_primer_nombre VARCHAR(30),p_segundo_nombre VARCHAR(30),p_tercer_nombre VARCHAR(150),p_fecha_nacimiento DATE,p_id_municipio INT,p_genero VARCHAR(1)) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE existe_padre,existe_madre,verificacion_fecha BOOLEAN;
    DECLARE p_primer_apellido,p_segundo_apellido INT;
    SET existe_padre = (SELECT COUNT(id_acta_nacimiento) FROM acta_nacimiento WHERE acta_nacimiento.id_acta_nacimiento = (SELECT obtenerIDAN(p_dpi_padre)) AND acta_nacimiento.genero = 'M') > 0;
    SET existe_madre = (SELECT COUNT(id_acta_nacimiento) FROM acta_nacimiento WHERE acta_nacimiento.id_acta_nacimiento = (SELECT obtenerIDAN(p_dpi_madre)) AND acta_nacimiento.genero = 'F') > 0;
    SET verificacion_fecha = (SELECT DATEDIFF(NOW(), p_fecha_nacimiento)) >= 0;   

    IF NOT existe_padre THEN
   	    RETURN 'DPI del padre invalido';
    END IF;
  
    IF NOT existe_madre THEN
   	    RETURN 'DPI de la madre invalido';
    END IF;
    
    IF NOT verificacion_fecha THEN
        RETURN 'No se pueden registrar nacimientos con una fecha posterior a la fecha de registro';
    END IF;
    
    SET p_primer_apellido = (SELECT primer_apellido FROM acta_nacimiento WHERE id_acta_nacimiento = (SELECT obtenerIDAN(p_dpi_padre)));
    SET p_segundo_apellido = (SELECT primer_apellido FROM acta_nacimiento WHERE id_acta_nacimiento = (SELECT obtenerIDAN(p_dpi_madre)));

    INSERT INTO acta_nacimiento (
        primer_nombre,
        segundo_nombre,
        tercer_nombre,
        primer_apellido,
        segundo_apellido,
        genero,fecha_nacimiento,id_municipio,id_padre,id_madre
    ) 
    VALUES (
        (SELECT idNombrePersona(p_primer_nombre)),
        (SELECT idNombrePersona(p_segundo_nombre)),
        (SELECT idNombrePersona(p_tercer_nombre)),
        p_primer_apellido,
        p_segundo_apellido,
        p_genero,p_fecha_nacimiento,p_id_municipio,p_dpi_padre,p_dpi_madre);

    RETURN 'Ingresado Correctamente';
END$$
DELIMITER

DELIMITER $$
CREATE FUNCTION AddDefuncion(p_cui BIGINT,p_fecha_fallecido DATE,p_motivo TEXT) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE ya_nacio,ya_murio,esta_casado BOOLEAN;
    DECLARE p_id_acta_nacimiento INT;

    SET p_id_acta_nacimiento = (SELECT obtenerIDAN (p_cui));
    IF p_id_acta_nacimiento IS NULL THEN
   	    RETURN 'No existe el CUI ingresado';
    END IF;

    SET ya_nacio = (SELECT DATEDIFF(p_fecha_fallecido, (SELECT fecha_nacimiento FROM acta_nacimiento WHERE id_acta_nacimiento = p_id_acta_nacimiento))) > 0;
    IF NOT ya_nacio THEN
        RETURN 'La fecha de fallecimiento es menor a la fecha de nacimiento';
    END IF;
  
    SET ya_murio = (SELECT COUNT(id_acta_defuncion) FROM acta_defuncion WHERE id_acta_nacimiento = p_id_acta_nacimiento) > 0;
    IF ya_murio THEN
   	    RETURN 'Esta persona ya posee un acta de defuncion';
    END IF;

    SET esta_casado = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi = p_cui AND id_estado_civil = 'C') = 1;
    IF esta_casado THEN
        UPDATE ciudadano SET id_estado_civil = 'V' WHERE dpi = (SELECT dpi_mujer FROM acta_matrimonio WHERE dpi_hombre = p_cui AND estado = TRUE);
        UPDATE ciudadano SET id_estado_civil = 'V' WHERE dpi = (SELECT dpi_hombre FROM acta_matrimonio WHERE dpi_mujer = p_cui AND estado = TRUE);
    END IF;

    INSERT INTO acta_defuncion (id_acta_nacimiento,fecha_fallecimiento,motivo) 
    VALUES (p_id_acta_nacimiento,p_fecha_fallecido,p_motivo);

    RETURN 'Ingresado Correctamente';
END$$
DELIMITER

DELIMITER $$
CREATE FUNCTION AddMatrimonio(p_dpi_hombre BIGINT,p_dpi_mujer BIGINT,p_fecha_matrimonio DATE) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE fecha_valida,posee_dpi_hombre,posee_dpi_mujer,es_hombre,es_mujer,hombre_fallecido,mujer_fallecida,hombre_casado,mujer_casada BOOLEAN;
    
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

    SET fecha_valida = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi IN (p_dpi_hombre,p_dpi_mujer) AND fecha_emision <= p_fecha_matrimonio) = 2;
    IF NOT fecha_valida THEN
        RETURN 'La fecha de matrimonio ingresada es invalida debido a que alguna de las dos personas no poseia DPI para esa fecha';
    END IF;
    
    INSERT INTO acta_matrimonio (dpi_hombre,dpi_mujer,fecha_matrimonio,estado) 
    VALUES (p_dpi_hombre,p_dpi_mujer,p_fecha_matrimonio,TRUE);

    UPDATE ciudadano SET id_estado_civil = 'C' WHERE dpi IN (p_dpi_hombre,p_dpi_mujer);

    RETURN 'Ingresado Correctamente';
END$$
DELIMITER

DELIMITER $$
CREATE FUNCTION AddDivorcio(p_id_acta_matrimonio INT,p_fecha_divorcio DATE) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE existe_acta_matrimonio,es_matrimonio_activo,verificacion_fecha BOOLEAN;

    SET existe_acta_matrimonio = (SELECT COUNT(id_acta_matrimonio) FROM acta_matrimonio WHERE id_acta_matrimonio = p_id_acta_matrimonio) = 1;
    IF NOT existe_acta_matrimonio THEN
   	    RETURN 'No existe el acta de matrimonio ingresado';
    END IF;

    SET es_matrimonio_activo = (SELECT COUNT(id_acta_matrimonio) FROM acta_matrimonio WHERE id_acta_matrimonio = p_id_acta_matrimonio AND estado = TRUE) = 1;
    IF NOT es_matrimonio_activo THEN
        RETURN 'No es un matrimonio activo, por lo tanto no se puede realizar el divorcio';
    END IF;
    
    SET verificacion_fecha = (SELECT DATEDIFF(p_fecha_divorcio,(SELECT fecha_matrimonio FROM acta_matrimonio WHERE id_acta_matrimonio = p_id_acta_matrimonio))) >= 0;
    IF NOT verificacion_fecha THEN
        RETURN 'No se puede registrar el divorcio con una fecha anterior a la fecha de matrimonio';
    END IF;

    INSERT INTO acta_divorcio (id_acta_matrimonio,fecha_divorcio) VALUES (p_id_acta_matrimonio,p_fecha_divorcio);
    UPDATE ciudadano SET id_estado_civil = 'D' WHERE dpi = (SELECT dpi_hombre FROM acta_matrimonio WHERE id_acta_matrimonio = p_id_acta_matrimonio);
    UPDATE ciudadano SET id_estado_civil = 'D' WHERE dpi = (SELECT dpi_mujer FROM acta_matrimonio WHERE id_acta_matrimonio = p_id_acta_matrimonio);
    UPDATE acta_matrimonio SET estado = FALSE WHERE id_acta_matrimonio = p_id_acta_matrimonio;

    RETURN 'Ingresado Correctamente';
END$$
DELIMITER

DELIMITER $$
CREATE FUNCTION AddLicencia(p_cui BIGINT,p_fecha_emision DATE,p_id_tipo_licencia VARCHAR(1)) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE edad_suficiente,ya_tiene_licencia BOOLEAN;
    DECLARE v_id_tipo_licencia VARCHAR(1);
    DECLARE v_id_acta_nacimiento,v_id_licencia_conducir INT;

    SET v_id_acta_nacimiento = (SELECT obtenerIDAN(p_cui));
    IF v_id_acta_nacimiento IS NULL THEN
        RETURN 'El CUI ingresado es invalido';
    END IF;
    
    SET edad_suficiente = (DATE(NOW()) - DATE_ADD((SELECT fecha_nacimiento FROM acta_nacimiento WHERE id_acta_nacimiento = (SELECT obtenerIDAN(p_cui))), INTERVAL 16 YEAR)) >= 0;
    IF NOT edad_suficiente THEN
        RETURN 'La persona aun no tiene permitido obtener una licencia de conducir';
    END IF;  

    IF NOT (p_id_tipo_licencia = 'E' OR p_id_tipo_licencia = 'C' OR p_id_tipo_licencia = 'M') THEN
        RETURN 'El tipo de licencia no es valido';
    END IF;    

    SET ya_tiene_licencia = (SELECT COUNT(lc.id_licencia_conducir) FROM licencia_conducir lc INNER JOIN detalle_licencia_conducir dlc ON lc.id_licencia_conducir = dlc.id_licencia_conducir WHERE lc.id_acta_nacimiento = (SELECT obtenerIDAN(p_cui)) AND dlc.id_tipo_licencia = p_id_tipo_licencia) > 0;
    IF ya_tiene_licencia THEN
   	    RETURN 'La persona ya tiene o ya ha tenido una licencia de conducir de este tipo';
    END IF;

    IF p_id_tipo_licencia != 'E' THEN
        SET v_id_tipo_licencia = (SELECT dlc.id_tipo_licencia FROM licencia_conducir lc INNER JOIN detalle_licencia_conducir dlc ON dlc.id_licencia_conducir = lc.id_licencia_conducir WHERE lc.id_acta_nacimiento = (SELECT obtenerIDAN(p_cui)) AND dlc.id_tipo_licencia != 'E');
        IF v_id_tipo_licencia IS NOT NULL THEN
            RETURN 'Ya ha poseido al menos una vez estos tipos de licencia: C,M; Por lo tanto solo renuevela';
        END IF;
    END IF;

    SET v_id_licencia_conducir = (SELECT crearLicencia((SELECT obtenerIDAN(p_cui))));
    INSERT INTO detalle_licencia_conducir (fecha_emision,fecha_renovacion,id_tipo_licencia,id_licencia_conducir) 
    VALUES (p_fecha_emision,DATE_ADD(p_fecha_emision, INTERVAL 1 YEAR),p_id_tipo_licencia,v_id_licencia_conducir);

    RETURN 'Ingresado Correctamente';
END$$
DELIMITER

DELIMITER $$
CREATE FUNCTION generarDPI(p_cui BIGINT,p_fecha_emision DATE,p_id_municipio INT) RETURNS TEXT DETERMINISTIC
BEGIN
    DECLARE v_id_acta_nacimiento,v_id_municipio INT;
    DECLARE ya_es_mayor_18,ya_tiene_dpi BOOLEAN;

    SET v_id_acta_nacimiento = (SELECT obtenerIDAN(p_cui));
    IF v_id_acta_nacimiento IS NULL THEN
   	    RETURN 'No existe el CUI ingresado';
    END IF;

    SET v_id_municipio = (SELECT id_municipio FROM municipio WHERE id_municipio = p_id_municipio);
    IF v_id_municipio IS NULL THEN
        RETURN 'El municipio que ha ingresado no existe';
    END IF;
    
    SET ya_tiene_dpi = (SELECT COUNT(dpi) FROM ciudadano WHERE dpi = p_cui) > 0;
    IF ya_tiene_dpi THEN
        RETURN 'Ya se ha generado con anterioridad el DPI del CUI ingresado';
    END IF;

    SET ya_es_mayor_18 = (SELECT COUNT(id_acta_nacimiento) FROM acta_nacimiento WHERE YEAR(NOW()) - YEAR(fecha_nacimiento) >= 18 AND id_acta_nacimiento = (SELECT obtenerIDAN(p_cui)));
    IF NOT ya_es_mayor_18 THEN
        RETURN 'La persona con el CUI ingresado no es mayor o igual a 18 años';
    END IF;

    INSERT INTO ciudadano (dpi,id_acta_nacimiento,id_estado_civil,id_municipio_residencia,fecha_emision) 
    VALUES (p_cui,v_id_acta_nacimiento,'S',p_id_municipio,p_fecha_emision);
    
    RETURN 'Ingresado Correctamente';
END$$
DELIMITER

-- PROCEDIMIENTOS PROCEDIMIENTOS PROCEDIMIENTOS PROCEDIMIENTOS --
-- PROCEDIMIENTOS PROCEDIMIENTOS PROCEDIMIENTOS PROCEDIMIENTOS --
-- PROCEDIMIENTOS PROCEDIMIENTOS PROCEDIMIENTOS PROCEDIMIENTOS --

DELIMITER $$
CREATE PROCEDURE getDPI(IN p_cui BIGINT)
BEGIN
    SELECT p_cui AS CUI,CONCAT(pn.nombre,' ',sn.nombre,' ',tn.nombre) AS nombres,CONCAT(pa.apellido,' ',sa.apellido) AS apellidos,an.fecha_nacimiento,d.nombre AS departamento,m.nombre AS municipio,an.genero 
    FROM acta_nacimiento an
    INNER JOIN nombre_persona pn ON pn.id_nombre_persona = an.primer_nombre
    INNER JOIN nombre_persona sn  ON sn.id_nombre_persona = an.segundo_nombre
    INNER JOIN nombre_persona tn ON tn.id_nombre_persona = an.tercer_nombre
    INNER JOIN apellido_persona pa ON pa.id_apellido_persona = an.primer_apellido
    INNER JOIN apellido_persona sa ON sa.id_apellido_persona = an.segundo_apellido
    INNER JOIN municipio m ON m.id_municipio = an.id_municipio
    INNER JOIN departamento d ON d.id_departamento = m.id_departamento 
    WHERE an.id_acta_nacimiento = (SELECT obtenerIDAN(p_cui));
END$$
DELIMITER