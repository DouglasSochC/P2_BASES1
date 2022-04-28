-- Personas Fallecidas
SELECT ciudadano.dpi,ciudadano.id_estado_civil,acta_nacimiento.id_acta_nacimiento,acta_nacimiento.genero FROM ciudadano INNER JOIN acta_nacimiento ON acta_nacimiento.id_acta_nacimiento = ciudadano.id_acta_nacimiento WHERE ciudadano.id_acta_nacimiento IN (select id_acta_nacimiento from acta_defuncion);

-- Personas Vivas
SELECT ciudadano.dpi,ciudadano.id_estado_civil,acta_nacimiento.id_acta_nacimiento,acta_nacimiento.genero FROM ciudadano INNER JOIN acta_nacimiento ON acta_nacimiento.id_acta_nacimiento = ciudadano.id_acta_nacimiento WHERE ciudadano.id_acta_nacimiento NOT IN (select id_acta_nacimiento from acta_defuncion);

-- Nacimiento
SELECT addNacimiento(1,1,'a','b','c','2020-01-01',101,'M'); -- Error
SELECT addNacimiento(10000000021407,10000019982211,'a','b','c','2020-01-01',101,'M');

-- Defuncion
SELECT AddDefuncion(1,'2000-10-24','Enfermedad'); -- Error
SELECT AddDefuncion(10000000021407,'2000-10-22','Enfermedad'); -- Exito

-- Matrimonio
SELECT AddMatrimonio(1,1,'2000-10-24');
SELECT AddMatrimonio(10000000080611,10000019971203,'2000-10-24');

-- Divorcio
SELECT AddDivorcio(1,'2000-10-24'); -- Error
SELECT AddDivorcio(1000,'2000-10-23'); -- Error
SELECT AddDivorcio(1000,'2005-10-24'); -- Exito

-- Licencia
SELECT AddLicencia(1,'2020-01-06','C'); -- Error No existe el CUI
SELECT AddLicencia(10000001271612,'2020-01-06','C'); -- Error menor a 16 anios
SELECT AddLicencia(10000001190505,'2020-01-06','X'); -- Error tipo de licencia no es valido
SELECT AddLicencia(10000000060116,'2020-01-06','C'); -- Error ya ha tenido el tipo de licencia
SELECT AddLicencia(10000009980513,'2021-10-20','C'); -- Error licencias mutuamente excluyentes

-- Anular Licencia
SELECT anularLicencia(1,'2023-01-01','Se paso un rojo'); -- Error numero de licencia no existe
SELECT anularLicencia(1019,'2021-01-01','Se paso un rojo'); -- Error fecha de anulacion
SELECT anularLicencia(1019,'2023-01-01','Se paso un rojo'); -- Correcto
SELECT anularLicencia(1019,'2022-12-01','Se paso un rojo'); -- Error ya que ya ha sido anulado con anterioridad y la fecha es menor a la ya asignada
SELECT anularLicencia(1019,'2024-12-02','Se paso un rojo'); -- Correcto

-- Renovacion de Licencia
SELECT renewLicencia(123,'2022-04-28','M',0); -- Error rango de fecha
SELECT renewLicencia(123,'2022-04-28','M',3); -- Error el numero de licencia no existe
SELECT renewLicencia(1019,'2022-04-28','M',3); -- Error la licencia esta anulada
SELECT renewLicencia(1000,'2022-04-27','M',3); -- Error la fecha de renovacion debe de ser igual o mayor a hoy
SELECT renewLicencia(1000,'2022-04-28','E',3); -- Error nunca a poseido una licencia tipo E
SELECT renewLicencia(1000,'2022-04-28','A',3); -- Error no lleva mas de 3 años con licencia B o C
SELECT renewLicencia(1001,'2022-04-28','B',3); -- Error no lleva mas de 2 años con licencia C
SELECT renewLicencia(1000,'2022-06-01','C',1); -- Correcto
    -- Verificando renovacion de licencia tipo E
    SELECT AddLicencia(10000000060116,'2021-06-06','E');
    SELECT renewLicencia(1020,'2022-05-28','E',3);
    -- Cambiar de C a B
    SELECT renewLicencia(1000,'2022-06-01','B',1); -- Correcto
    -- Cambiar de (C o B) a A
    SELECT renewLicencia(1000,'2023-06-01','A',1); -- Correcto

-- Generar DPI
SELECT generarDPI(1,'2020-01-06',101); -- Error No existe el CUI
SELECT generarDPI(10000000021407,'2020-01-06',1); -- Error No existe el id_municipio
SELECT generarDPI(10000000021407,'2020-01-06',101); -- Error Ya se ha generado el CUI con anterioridad
SELECT generarDPI(10000000012003,'2020-01-06',101); -- Error No se puede generar porque todavia no >= 18
SELECT addNacimiento(10000000021407,10000019982211,'a','b','c','2000-01-01',101,'M');
SELECT generarDPI(10000020000101,'2020-01-06',101); -- Correcto pero tiene que ejecutarse el addNacimiento de arriba

-- PROCEDIMIENTOS
CALL getDPI(10000000021407);
CALL getDivorcio(1000);
