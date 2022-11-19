/***************************************************************************
                              ETL Ejercicio
                             -----------------------

 ***************************************************************************/
--========================================================================
-- 1. Registramos el gestor y el operador catastral
--========================================================================

--1.1 Creacion del gestor catastral

insert into etl.ric_gestorcatastral
(t_ili_tid, nombre_gestor, nit_gestor_catastral, fecha_inicio_prestacion_servicio)
select
	uuid_generate_v4(),
	'Giron Catastro',
	'360.705.121-1',
	now();
--1.2 Creacion del Operador catastral
insert into etl.ric_operadorcatastral
(t_ili_tid, nombre_operador, nit_operador_catastral)
select
	uuid_generate_v4(),
	'Giron Catastro',
	'360.705.121-1';

--========================================================================
-- 2. Registramos los predios
--========================================================================

insert into etl.ric_predio (
    t_ili_tid, 
    departamento, 
    municipio, 
    codigo_homologado, 
    nupre, 
    codigo_orip, 
    matricula_inmobiliaria, 
    numero_predial, 
    numero_predial_anterior, 
    fecha_inscripcion_catastral,
    condicion_predio, 
    destinacion_economica,
    tipo,
    avaluo_catastral, 
    zona, 
    vigencia_actualizacion_catastral, 
    estado, 
    catastro, 
    ric_gestorcatastral, 
    ric_operadorcatastral, 
    comienzo_vida_util_version, 
    espacio_de_nombres, 
    local_id)
select 
	uuid_generate_v4(),
	'68' as Departamento,
	'307' as municipio,
	row_number() over() as codigo_homologado,
	case 
		when  length(g1.matricula) < 9 then concat('AAB', g1.matricula) 
		else concat('I', g1.matricula) end as nupre,
	'300' as codigo_orib,
	g1.matricula  as matricula,
	g1.codigo as numero_predial,
	g1.codigo_anterior as numero_predial_anterior,
	null as fecha_inscripcion,
	(select t_id from  etl.ric_condicionprediotipo where ilicode  like 'NPH') as condicion_predio,
	(select t_id from etl.ric_destinacioneconomicatipo where ilicode like 'Agricola') as destinacion_economica,
	(select t_id from etl.col_unidadadministrativabasicatipo where  ilicode like 'Predio.Privado') as tipo,
	'10000' as avaluo,	
	(select t_id from etl.ric_zonatipo where ilicode = g1.tipo_predio) as zona_tipo, 
	TO_DATE('20220101','YYYYMMDD') as vigencia_actualizacion_catastral,
	(select t_id from etl.ric_estadotipo where ilicode like 'Activo') as estado,
	null as catastro,
	(select t_id from etl.ric_gestorcatastral where nombre_gestor like 'Giron Catastro') as ric_gestorcatastral,
	(select t_id from etl.ric_operadorcatastral where nombre_operador like 'Giron Catastro') as ric_operadorcatastral,
	now() as comienzo_vida_util_version,
	'RIC_PREDIO' as espacio_de_nombres,
	row_number() over() as local_id
from  (
	select codigo,matricula,codigo_anterior, tipo_predio,
	ROW_NUMBER() OVER(PARTITION BY codigo ) as numero_fila
	from public.girondatos as g1
) as g1  where g1.numero_fila=1;

--========================================================================
-- 3. Registramos los terrenos
--========================================================================
insert into etl.ric_terreno(
	t_ili_tid,
	area_terreno,
	area_digital_gestor,
	geometria,
	dimension,
	etiqueta,
	relacion_superficie,
	comienzo_vida_util_version,
	espacio_de_nombres,
	local_id
)
select 
	uuid_generate_v4() as t_ili_tid,
	st_area(te.geom) as area_terreno,
	te.shape_area  as area_digital_gestor,
	st_force3D(te.geom) as geometria,
	(select t_id from etl.col_dimensiontipo where ilicode like 'Dim2D') as dimension,
	te.codigo as etiqueta,
	(select t_id from etl.col_relacionsuperficietipo where ilicode like 'En_Rasante') as relacion_superficie,
	now() as comienzo_vida_util_version,
	'RIC_TERRENO' as espacio_de_nombres,
	row_number() over() as local_id
from public.terreno te 
join etl.ric_predio pr on pr.numero_predial =te.codigo ;

update etl.ric_terreno set geometria = ST_RemoveRepeatedPoints(geometria);
--========================================================================
-- 4. Registramos la tabla de relacion entre los terrenos y predios 
--========================================================================
insert into etl.col_uebaunit(
	t_ili_tid,
	ue_ric_terreno,
	baunit
)
select
	uuid_generate_v4() as t_ili_tid,
	te.t_id as id_terreno,
	pr.t_id as id_predio
from etl.ric_terreno te join etl.ric_predio pr
on te.etiqueta = pr.numero_predial;

--========================================================================
-- 5. Registramos las direccion asociada a cada predio
--========================================================================
insert into  etl.extdireccion(
	tipo_direccion,
	es_direccion_principal,
	nombre_predio,
	ric_predio_direccion
)
select 
	(select t_id from etl.extdireccion_tipo_direccion where ilicode = di.tipo_dirrecion),
	case 
		when di.direccion_pri like 'si' then true
		else false 
	end ,
	di.dirreccion as nombre_predio,
	t_id as lc_predio_direccion
from etl.ric_predio pr join public.dirrecion_giron di
on pr.numero_predial = di.codigo ;

--========================================================================
-- 6. Registramos los interesados y agrupacion de interesados
--========================================================================
--6.1 crear un atributo adicional para crear la relacion  con el predio
alter table etl.ric_interesado  add id_predio varchar(40);

--6.2 Registramos los interesados
insert into etl.ric_interesado (
	t_ili_tid,
	tipo, 
	tipo_documento, 
	documento_identidad,
	primer_nombre, 
	segundo_nombre,
	primer_apellido, 
	segundo_apellido, 
	sexo, 
	grupoetnico,
	razon_social,
	estado_civil,
	comienzo_vida_util_version,
	espacio_de_nombres, 
	local_id,
	id_predio)
select 
	uuid_generate_v4(),
	(select t_id from etl.ric_interesadotipo where ilicode = g1.tipo_interesado),
	(select t_id from etl.ric_interesadodocumentotipo where ilicode = g1.tipo_de_documento_de_identificacion),
	g1.numero_documento as numero_identificacion,
	g1.primer_nombre as primer_nombre,
	g1.segundo_nombre  as segundo_nombre,
	g1.primer_apellido as primer_apellido,
	case 
		when  g1.segundo_apellido like '' then null
		else  g1.segundo_apellido
	end ,
	null as sexo,
	(select t_id from etl.ric_grupoetnicotipo where ilicode = g1.grupo_etnico),
	g1.razon_social,
	(select t_id from etl.ric_estadociviltipo where ilicode = g1.estado_civil),
	now() as vida_util,
	'RIC_INTERESADO' as nombre,	
	row_number() over() as local_id,
	g1.codigo
from  (
	select numero_documento, codigo,tipo_interesado,tipo_de_documento_de_identificacion,
	primer_nombre,segundo_nombre,primer_apellido,segundo_apellido,grupo_etnico,razon_social,
	estado_civil,ROW_NUMBER() OVER(PARTITION BY numero_documento) as numero_fila
	from public.girondatos) as g1 where g1.numero_fila = 1;

--6.3 Registramos la agrupacion de interesados

insert into etl.ric_agrupacioninteresados(
	t_ili_tid,
	tipo,
	nombre,
	comienzo_vida_util_version,
	espacio_de_nombres,
	local_id)
select
	uuid_generate_v4() as t_ili_tid,
	(select t_id from etl.col_grupointeresadotipo where ilicode like 'Grupo_Civil') as tipo,
	gi.codigo,
	now(),
	'RIC_AGRUPACIONINTERESADOS' as espacio_de_nombres,
	row_number() over() as local_id
from public.girondatos gi
group by gi.codigo 
having count(gi.codigo) >1;

--6.4 Registramos la tabla de miembros
insert into etl.col_miembros(
t_ili_tid, 
interesado_ric_interesado, 
agrupacion, 
participacion)
select 
	uuid_generate_v4() as t_ili_tid,
	it.t_id as interesado_ric_interesado,
	ag.t_id as agrupacion,
	0.1 as participacion  
from etl.ric_agrupacioninteresados  ag
join public.girondatos  gi on ag.nombre =gi.codigo 
join etl.ric_interesado it on it.documento_identidad =gi.numero_documento;

--========================================================================
-- 7. Registramos los derechos
--========================================================================

--7.1 Registro de la informacion de cada derecho
insert into etl.ric_derecho(
	t_ili_tid,
	tipo,
	fraccion_derecho,
	fecha_inicio_tenencia,
	unidad,
	comienzo_vida_util_version,
	espacio_de_nombres,
	local_id
)
select
	uuid_generate_v4() as t_ili_tid,
	(select t_id from etl.ric_derechotipo where ilicode = gi.derecho) as tipo,
	1.0 as fraccion_derecho,
	gi.fecha as fecha_inicio_tenencia,
	pr.t_id,
	now() as comienzo_vida_util_version,
	pr.numero_predial  as espacio_de_nombres,
	row_number() over() as local_id
from  (
	select fecha,derecho,codigo,ROW_NUMBER() OVER(PARTITION BY codigo) as numero_fila
	from public.girondatos) as gi join etl.ric_predio pr
on  gi.codigo  = pr.numero_predial where gi.numero_fila = 1;

-- 7.2 Registramos la relacion derecho-agrupacion de interesados

update etl.ric_derecho as dr
set  interesado_ric_agrupacioninteresados = agrupacion.t_id 
from (select ra.t_id as t_id, ra.nombre as nombres from etl.ric_agrupacioninteresados ra  join etl.ric_derecho dr
on ra.nombre = dr.espacio_de_nombres
) as agrupacion  where dr.espacio_de_nombres =  agrupacion.nombres;

-- 7.2 Registramos la relacion derecho-interesados

update etl.ric_derecho 
set interesado_ric_interesado = it.t_id 
from etl.ric_interesado it
where  ric_derecho.espacio_de_nombres = it.id_predio  and
ric_derecho.interesado_ric_agrupacioninteresados  is null;

--========================================================================
-- 8. Registramos las fuentes administrativas
--========================================================================
insert into etl.ric_fuenteadministrativa(
	t_ili_tid,
	tipo,
	ente_emisor,
	estado_disponibilidad,
	fecha_documento_fuente,
	espacio_de_nombres,
	local_id
)
select 
	uuid_generate_v4() as t_ili_tid,
	(select t_id from etl.col_fuenteadministrativatipo where ilicode like gi.tipo_documento) as tipo,
	gi.ente_emisor,
	(select t_id from etl.col_estadodisponibilidadtipo where ilicode ='Convertido') as estado_disponibilidad,
	gi.fecha as fecha_documento_fuente,
	gi.codigo as espacio_de_nombres,
	row_number() over() as local_id
from public.girondatos gi;

--========================================================================
-- 9. Registramos la tabla col_rrrfuente
--========================================================================

insert into etl.col_rrrfuente
(t_ili_tid, fuente_administrativa, rrr)
select
	uuid_generate_v4() as t_ili_tid,
	fu.t_id,
	de.t_id 
from etl.ric_derecho de join etl.ric_fuenteadministrativa fu
on de.espacio_de_nombres = fu.espacio_de_nombres;

--========================================================================
-- 10. Registramos los tramites catastrales
--========================================================================
--10.1 Se crea un campo temporal para asociar el predio al tramite
alter table etl.ric_tramitecatastral  add id_predio varchar(40);

--10.2 Ingreamos la informacion de tramites catastrales
insert into etl.ric_tramitecatastral(
	t_ili_tid,
	clasificacion_mutacion,
	numero_resolucion,
	fecha_resolucion,
	fecha_radicacion,
	id_predio)
select
	uuid_generate_v4() as t_id,
	(select t_id from etl.ric_mutaciontipo where ilicode like tr.clasificacion_tipo) tramite, 
	tr.resolucion,
	cast(tr.fecha_inicio as date),
	cast(tr.fecha_radicacion  as date),
	pr.numero_predial
from public.tramites  tr 
join etl.ric_predio pr on pr.numero_predial  = tr.codigo 
where pr.numero_predial is not null;

--10.3 se registra la tabla que relaciona los predios-tramite catastral
insert into etl.ric_predio_tramitecatastral
(t_ili_tid, ric_predio, ric_tramite_catastral)
select
	uuid_generate_v4() as t_ili_tid ,
	pr.t_id as ric_predio ,
	rtr.t_id as ric_tramite_catastral 
from etl.ric_tramitecatastral rtr 
join etl.ric_predio pr on rtr.id_predio = pr.numero_predial;

--11. Borado de atributos temporales
alter table etl.ric_tramitecatastral drop  id_predio; 
alter table etl.ric_interesado  drop id_predio;