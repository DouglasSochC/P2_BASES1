-- Personas Fallecidas
SELECT ciudadano.dpi,ciudadano.id_estado_civil,acta_nacimiento.id_acta_nacimiento,acta_nacimiento.genero FROM ciudadano INNER JOIN acta_nacimiento ON acta_nacimiento.id_acta_nacimiento = ciudadano.id_acta_nacimiento WHERE ciudadano.id_acta_nacimiento IN (select id_acta_nacimiento from acta_defuncion);

-- Personas Vivas
SELECT ciudadano.dpi,ciudadano.id_estado_civil,acta_nacimiento.id_acta_nacimiento,acta_nacimiento.genero FROM ciudadano INNER JOIN acta_nacimiento ON acta_nacimiento.id_acta_nacimiento = ciudadano.id_acta_nacimiento WHERE ciudadano.id_acta_nacimiento NOT IN (select id_acta_nacimiento from acta_defuncion);

-- 