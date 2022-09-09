--      LIMPIEZA DE DATOS       --
--Verificar si hay espacios en el codigo predial nacional 
select * from girondatos  where codigo like '% %';

--Remover espacios dobles en el codigo predial nacional
update  girondatos set codigo =replace (codigo,' ', '')
where codigo like '% %' ;

--Verificar si se encuentra caracteres no numericos en el codigo predial nacional
select *  from girondatos  where codigo !~ '^[0-9]*$';

--Los caracteres alfanumericos que se encontraron pasan a estar en minuscula 
update girondatos set codigo = lower(codigo)
where codigo !~ '^[0-9]*$';
--Correcion de caracteres alfanumericos del codigo predial nacional
update girondatos 
set codigo= replace (codigo, 'o', '0')   
where codigo !~ '^[0-9]*$';

--Identificacion de registros que no correspondan al municipio de Giron del departamento de Santander
select * from girondatos where codigo not like '68307%';

--Depuracion de los datos que no sean del municipio de Giron
delete from girondatos where  codigo not like '68307%';


--Identificación de predios que en su codigo nacional en la posicion 6 y 7 que sean rurales se codifiquen con '00'
select * from girondatos where codigo not like '6830700%' and tipo_predio  = 'RURAL';

-- Correción de los registros que presentan la problematica en el codigo nacional 
update girondatos 
set codigo=replace (codigo,'6830701','6830700')
where codigo not like '6830700%' and tipo_predio  = 'RURAL'; 


-- Codigo predial anterior
--verificar si hay espacios en el codigo predial anterior
select * from girondatos  where codigo_anterior like '% %';

--Remover espacios dobles en el codigo predial anterior
update  girondatos set codigo_anterior  =replace (codigo_anterior ,' ', '')
where codigo_anterior like '% %';


--Verificar si se encuentra caracteres no numericos en el codigo predial anterior
select *  from girondatos  where codigo_anterior  !~ '^[0-9]*$';

--Los caracteres alfanumericos que se encontraron pasan a estar en minuscula 
update girondatos set codigo_anterior  = lower(codigo_anterior)
where codigo_anterior  !~ '^[0-9]*$';
--Correcion de caracteres alfanumericos del codigo predial anterior
update girondatos 
set codigo_anterior = replace (codigo_anterior, 'o', '0')   
where codigo_anterior  !~ '^[0-9]*$';


--Identificacion de predios que en su codigo nacional en la posicion 6 y 7 que sean rurales se codifiquen con 
select * from girondatos where codigo_anterior  not like '6830700%' and tipo_predio  = 'RURAL';

-- Correcion de los registros que presentan la problematica en el codigo predial anterio
update girondatos 
set codigo_anterior =replace (codigo_anterior ,'6830701','6830700')
where codigo_anterior  not like '6830700%' and tipo_predio  = 'RURAL';

--- Zona del predio
-- Valores que registra la zona del predio 
select tipo_predio from girondatos group by tipo_predio;

--Estandarizacion de valores en zona del predio segun el modelo RIC
update girondatos set tipo_predio= (case 
	when tipo_predio like 'RURAL' then  'Rural'
	when tipo_predio like 'URBANO' then 'Urbano'end);

--Identificacion de predios que indican que zona del predio urbano pero en el codigo nacional son rurales
select * from girondatos where tipo_predio = 'Urbano' and  codigo  like '6830700%';

-- Correcion del valor de la zona del predio con respeto a la estructura del codigo predial nacional
update girondatos set tipo_predio='Rural' 
where tipo_predio = 'Urbano' and  codigo  like '6830700%';

--Tipo de documento de identidad
--Identificacion del grupo de valores del tipo de documento de identificacion
select tipo_de_documento_de_identificacion  from girondatos group by tipo_de_documento_de_identificacion;

--Estandarizacion de valores de tipo de docuemnto de identificacion segun el modelo RIV
update girondatos 
set tipo_de_documento_de_identificacion = (case 
	when tipo_de_documento_de_identificacion like 'CC' then 'Cedula_Ciudadania'
	when tipo_de_documento_de_identificacion like 'C' then 'Cedula_Ciudadania'
	when tipo_de_documento_de_identificacion like 'RC' then 'Registro_Civil'
	when tipo_de_documento_de_identificacion like 'TI' then 'Tarjeta_Identidad'
	when tipo_de_documento_de_identificacion like 'CE' then 'Cedula_Extranjeria'
	when tipo_de_documento_de_identificacion like 'NIT'then 'NIT'
	when tipo_de_documento_de_identificacion like 'PA' then 'Pasaporte'
end);

--Eliminar los registros con Tarjeta de Identidad
delete from girondatos where tipo_de_documento_de_identificacion like 'Tarjeta_Identidad';
--Eliminar los registros con Cedula de Ciudadania 
delete from girondatos where tipo_de_documento_de_identificacion like 'Cedula_Extranjeria';

-- Crear el atibuto de tipo de interesado
alter table  girondatos add tipo_interesado varchar(250);

-- Agregar el tipo de interesado segun el modelo RIC
update girondatos set tipo_interesado = (
case
	when tipo_de_documento_de_identificacion like 'NIT' then 'Persona_Juridica'
	else 'Persona_Natural'
end);

-- Grupo etnico--
--Identificacion del grupo de valores registrados en grupo_etnico
select grupo_etnico  from girondatos group by grupo_etnico;

--Estandarizacion de valores de grupo_etnico segun el modelo RIV
update girondatos 
set grupo_etnico = (case
		when grupo_etnico like 'NEGRO AFROCOLOMBIANO' then 'Negro_Afrocolombiano'
		when grupo_etnico like 'RROM' then 'Rrom'
		when grupo_etnico like 'PALENQUERO' then 'Palenquero'
		when grupo_etnico like 'RAIZAL' then 'Raizal'
		when grupo_etnico like 'INDIGENA'then 'Indigena'
		when grupo_etnico like 'NINGUNO' then 'Ninguno'
	end); 

-- remplazar el grupo etnico de los registros con tipo de documento NIT
update girondatos set grupo_etnico  =  regexp_replace(grupo_etnico ,'([A-Z])\w+','Ninguno','g')
where tipo_de_documento_de_identificacion like 'NIT';

-- Estado_civil--
--Identificacion del grupo de valores registrados en estado_civil
select estado_civil from girondatos group by estado_civil;

--Estandarizacion de valores de estado_etnico segun el modelo RIV
update girondatos 
set estado_civil = (case
		when estado_civil like 'CASADO' then 'Casado'
		when estado_civil like 'CASADA' then 'Casado'
		when estado_civil like 'SOLTERO' then 'Soltero'
		when estado_civil like 'UNION LIBRE 2 AÑOS' then 'No_Casado_Vive_En_Pareja_2_Anios_O_Mas'
		when estado_civil like 'UNION LIBRE 1 AÑO' then 'No_Casado_Vive_En_Pareja_Menos_2_Anios'
		when estado_civil like 'UNION LIBRE 4 AÑOS' then 'No_Casado_Vive_En_Pareja_2_Anios_O_Mas'
		when estado_civil like 'SIN INFORMACION' then null
	end);
-- remplazar el estado civil de los registros con tipo de documento NIT
update girondatos set estado_civil =  regexp_replace(estado_civil,'([A-Z])\w+',null,'g') 
where tipo_de_documento_de_identificacion like 'NIT';

-- Tipo de fuente administrativa
--Identificacion del grupo de valores del tipo de documento de la fuente administrativa
select tipo_documento  from girondatos group by tipo_documento ;

--Estandarizacion de valores del tipo de documento de la fuente administrativa segun el modelo RIC
update girondatos set tipo_documento = (case 
	when tipo_documento like 'SIN_INFORMACION' then 'Sin_Documento'
	when tipo_documento like 'AUTO' then  'Documento_Publico.Acto_Administrativo'
	when tipo_documento like 'CERTIFICADO' then 'Documento_Publico.Acto_Administrativo'
	when tipo_documento like 'OFICIO' then 'Documento_Publico.Sentencia_Judicial'
	when tipo_documento like 'DESPACHO' then 'Documento_Publico.Sentencia_Judicial'
	when tipo_documento like 'DILIGENCIA'then 'Documento_Publico.Sentencia_Judicial'
	when tipo_documento like 'RESOLUCION' then 'Documento_Publico.Acto_Administrativo'
	when tipo_documento like 'ESCRITURA'then 'Documento_Publico.Escritura_Publica'
	when tipo_documento like 'SENTENCIA' then 'Documento_Publico.Sentencia_Judicial'
	when tipo_documento like 'ACTA' then 'Documento_Publico.Sentencia_Judicial'
end); 
--Estado_Folio--
--Eliminar los registros con estados de folios cerrados
delete  from girondatos where estado_folio like 'CERRADO';
--Borrado del atribuo estado_folio
alter table girondatos drop estado_folio;

--Numero de docuemto de identificacion--
--Verificar si hay caracteres alfanumeriocos en los numeros de identificacion
select *  from girondatos  where numero_documento !~ '^[0-9]*$';

--Identifacion de numero de documentos de identidad vacios 
select * from girondatos where numero_documento like'';
--Asignacion de valor a los registros con numero  documento de identicacion vacios
update girondatos set numero_documento  = 'Sin_Informacion'
where numero_documento like'';


-- Tipo de derecho
--Identificacion del grupo de valores del tipo de derecho
select derecho  from girondatos group by derecho;
--Estandarizacion de valores  del tipo de derechos segun el modelo RIC
update girondatos set derecho = (
	case
		when derecho like 'POSESION' then 'Posesion'
		when derecho like 'POSECION' then 'Posesion'
		when derecho like 'OCUPASION' then 'Ocupacion'
		when derecho like 'OCUPACION' then 'Ocupacion'
		when derecho like 'DOMINIO' then 'Dominio'
	end);


--Fecha de acto administrativo 
-- Cambiar el formato de la variable fecha de String a Date
alter table public.girondatos alter column fecha type date using fecha::date;
--Verificar si existen fechas menores  a 1930 y mayores a la fecha actual	
select * from girondatos where fecha <'1930-01-01' or fecha > now();
--Asignar un valor estandar a  los registros que presentan inconsitencia logica en sus fechas 
update girondatos set fecha= null
where fecha <'1930-01-01' or fecha > now();

--Nombre del propietario
-- Identificacion del caracter '-' en el nombre del propietario
select * from girondatos  where propietario ~ '-';
-- correcion del nombre
update girondatos  set propietario=replace(propietario,'-',' ') 
where propietario ~ '-';

-- Identificacion de nombres con doble espacio en su campo
select * from girondatos where propietario  like '%  %';
-- Correcion del doble espaciado en el nombre del propietario
update girondatos  set propietario=replace(propietario,'  ',' ')
where propietario  like '%  %';

--Estandarizar los nombres de propiestarios en mayuscula
update girondatos set propietario =upper(propietario); 

--Creacion de los atributos de primer_nombre, segundo_nombre,primer_apellido y segundo apellido
alter table  girondatos add primer_nombre varchar(250);
alter table  girondatos add segundo_nombre varchar(250);
alter table  girondatos add primer_apellido varchar(250);
alter table  girondatos add segundo_apellido varchar(250);



--Numero de espacios en el nombre del propietario
select propietario,
(array_length(string_to_array(propietario , ' '),1)-1) as numero_espacios
from girondatos;

--Propietario con un espacio en su nombre
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 1;

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 1;


update girondatos 
set primer_apellido = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 1;

--Propietario con dos espacios en su nombre y tienen la expresion DEL
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DEL %';

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DEL %';

update girondatos 
set primer_apellido = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DEL %';

--Propietario con dos espacios en su nombre y tienen la expresion DE
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DE %';


update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DE %';

update girondatos 
set primer_apellido = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DE %';

--Propietario con tres espacios en su nombre el cual no tiene la palabra "DEL" o "DE"

select * from girondatos g 
where tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
and propietario  not like '% DE %' and propietario  not like '% DEL %';

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
and propietario  not like '% DE %' and propietario  not like '% DEL %';


update girondatos
set primer_apellido= (string_to_array(propietario, ' '))[2]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
and propietario  not like '% DE %' and propietario  not like '% DEL %';

update girondatos
set segundo_apellido= (string_to_array(propietario, ' '))[3]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
and propietario  not like '% DE %' and propietario  not like '% DEL %';

--Propietario con tres espacios en su nombre y tienen la expresion DEL
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';

update girondatos 
set segundo_nombre = (string_to_array(propietario, ' '))[2]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';

update girondatos 
set primer_apellido = concat((string_to_array(propietario, ' '))[3],' ',(string_to_array(propietario, ' '))[4])
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';


--Propietario con tres espacios en su nombre y tienen la expresion DE
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';

update girondatos 
set segundo_nombre = (string_to_array(propietario, ' '))[2]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';

update girondatos 
set primer_apellido = concat((string_to_array(propietario, ' '))[3],' ',(string_to_array(propietario, ' '))[4])
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';

--Propietario con tres espacios en su nombre el cual no tiene la palabra "DEL" o "DE"
select * from girondatos  
where tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  
and propietario  not like '% DE %' and propietario  not like '% DEL %';

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) =  3
and propietario  not like '% DE %' and propietario  not like '% DEL %';

update girondatos 
set segundo_nombre = (string_to_array(propietario, ' '))[2]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  
and propietario  not like '% DE %' and propietario  not like '% DEL %';
update girondatos

update girondatos
set primer_apellido= (string_to_array(propietario, ' '))[3]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3  
and propietario  not like '% DE %' and propietario  not like '% DEL %';

update girondatos
set segundo_apellido= (string_to_array(propietario, ' '))[4]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 3 
and propietario  not like '% DE %' and propietario  not like '% DEL %';

--Propietario con cuatro espacios en su nombre 
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 4;  

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 4;

update girondatos 
set segundo_nombre = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 4;

update girondatos
set primer_apellido= (string_to_array(propietario, ' '))[4]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 4;

update girondatos
set segundo_apellido= (string_to_array(propietario, ' '))[5]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 4;

--Propietario con cinco espacios en su nombre 
select * from girondatos g 
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 5;  

update girondatos 
set primer_nombre = (string_to_array(propietario, ' '))[1]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 5;

update girondatos 
set segundo_nombre = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 5;

update girondatos
set primer_apellido= (string_to_array(propietario, ' '))[5]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 5;

update girondatos
set segundo_apellido= (string_to_array(propietario, ' '))[6]
where  tipo_de_documento_de_identificacion  not like 'NIT' 
and (array_length(string_to_array(propietario , ' '),1)-1) = 5;

--Creacion del campo Razon Social 
alter table  girondatos add razon_social varchar(250);

--Adicion de los valores de la razon social
update girondatos set razon_social = propietario 
where  tipo_de_documento_de_identificacion   like 'NIT'; 

-- Depuracion de las variables que no se implementan
alter table girondatos drop numero_subterraneos;
alter table girondatos drop vereda_codigo;
alter table girondatos drop propietario;