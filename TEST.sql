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

-- Generar DPI
SELECT generarDPI(1,'2020-01-06',101); -- Error No existe el CUI
SELECT generarDPI(10000000021407,'2020-01-06',1); -- Error No existe el id_municipio
SELECT generarDPI(10000000021407,'2020-01-06',101); -- Error Ya se ha generado el CUI con anterioridad
SELECT generarDPI(10000000012003,'2020-01-06',101); -- Error No se puede generar porque todavia no >= 18
SELECT addNacimiento(10000000021407,10000019982211,'a','b','c','2000-01-01',101,'M');
SELECT generarDPI(10000020000101,'2020-01-06',101); -- Correcto pero tiene que ejecutarse el addNacimiento de arriba
