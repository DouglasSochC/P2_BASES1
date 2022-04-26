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

-- IF p_id_tipo_licencia != 'E' THEN
--     SET v_id_tipo_licencia = (SELECT dlc.id_tipo_licencia FROM licencia_conducir lc INNER JOIN detalle_licencia_conducir dlc ON dlc.id_licencia_conducir = lc.id_licencia_conducir WHERE lc.id_acta_nacimiento = (SELECT obtenerIDAN(p_cui)) AND (dlc.fecha_renovacion - DATE(NOW())) >= 0 AND dlc.id_tipo_licencia != 'E');
--     SET v_id_tipo_licencia = IF((v_id_tipo_licencia = 'A' OR v_id_tipo_licencia = 'B' OR v_id_tipo_licencia = 'C'),'C',v_id_tipo_licencia);
--     IF (v_id_tipo_licencia = 'M' AND p_id_tipo_licencia = 'C') OR (v_id_tipo_licencia = 'C' AND p_id_tipo_licencia = 'M') THEN
--         RETURN 'Ya posee una licencia activa que es mutuamente excluyente a la que desea generar actualmente';
--     END IF;
-- END IF;