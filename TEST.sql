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
