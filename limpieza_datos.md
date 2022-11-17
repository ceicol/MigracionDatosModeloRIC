# Insumo #

 Para poder implementar el insumo entregado por parte de la entidad municipal, se es necesario realizar un proceso de limpieza y adaptación del insumo, para poder adaptarlo al modelo de Registro de Información Catastral.

**En la depuración de los datos se debe tener en cuenta**:

- Datos ausentes o valores atípicos.
- Caracteres especiales.
- Espacios duplicados.
- Espacios inicio y fin.
- Estructura de los códigos.
  - Rango de valores.
  - Completar la estructura.
  - Remover campos innecesarios.
- Dominios de valores.

## Clases ##
- **Numero predial nacional (codigo).**
  
   - Verificar y corregir si hay presencia se espacios en el código predial nacional. 

        ```sql
        --Verificar si hay espacios en el codigo predial nacional 
        select * from public.girondatos  where codigo like '% %';
         
        --Remover espacios dobles en el codigo predial nacional
        update  public.girondatos set codigo =replace (codigo,' ', '')
        where codigo like '% %' 
        ```
   - Verificar y corregir si hay caracteres alfanuméricos, en la estructura del código predial nacional.   
        ```sql
        --Verificar si se encuentra caracteres no numericos en el codigo predial nacional
        select *  from public.girondatos  where codigo !~ '^[0-9]*$';
         
        --Los caracteres alfanumericos que se encontraron pasan a estar en minuscula 
        update public.girondatos set codigo = lower(codigo)
        where codigo !~ '^[0-9]*$';
        
        --Correcion de caracteres alfanumericos del codigo predial nacional
        update public.girondatos 
        set codigo= replace (codigo, 'o', '0')   
        where codigo !~ '^[0-9]*$';
        ```
   - Verificar y eliminar si hay presencia de registros en el código predial nacional de las posiciones de la 1 a 5, no correspondan al municipio de Girón en el departamento de Santander, el cual corresponde al código  ‘68307'.
   
        ```sql
        --Identificacion de registros que no correspondan al municipio de Giron del departamento de Santander
        select * from public.girondatos where codigo not like '68307%';
    
        --Depuracion de los datos que no sean del municipio de giron
        delete from public.girondatos where  codigo not like '68307%';
        ```

    - Se debe verificar y corregir que los predios que corresponden al perímetro rural, en la estructura del  código  predial nacional en su posición nacional se le asigne el valor ‘00’. 
        ```sql
        --Identificación de predios que en su codigo nacional en la posicion 6 y 7 que sean rurales se codifiquen con '00'
        select * from public.girondatos where codigo not like '6830700%' and tipo_predio  = 'RURAL';
         
        -- Correción de los registros que presentan la problematica en el codigo nacional 
        update public.girondatos 
        set codigo=replace (codigo,'6830701','6830700')
        where codigo not like '6830700%' and tipo_predio  = 'RURAL';
        ```
 - **Numero predial nacional anterior (codigo_anterior).**
   
    - Verificar y corregir si hay presencia se espacios en el código predial nacional anterior.
        ```sql
        --verificar si hay espacios en el codigo predial anterior
        select * from public.girondatos  where codigo_anterior like '% %';
            
        --Remover espacios dobles en el codigo predial anterior 
        update  public.girondatos set codigo_anterior  =replace (codigo_anterior ,' ', '') where codigo_anterior like '% %';
        ```
    - Verificar y corregir si hay caracteres alfanuméricos, en la estructura del código predial nacional anterior.
     
        ```sql
        --Verificar si se encuentra caracteres no numericos en el codigo predial anterior
        select *  from public.girondatos  where codigo_anterior  !~ '^[0-9]*$';
        
        --Los caracteres alfanumericos que se encontraron pasan a estar en minuscula 
        update public.girondatos set codigo_anterior  = lower(codigo_anterior)
        where codigo_anterior  !~ '^[0-9]*$';
        --Correcion de caracteres alfanumericos del codigo predial anterior
        update public.girondatos 
        set codigo_anterior = replace (codigo_anterior, 'o', '0')   
        where codigo_anterior  !~ '^[0-9]*$';
        ```
    - Verificar y eliminar si hay presencia de registros en el código predial nacional anterior de las posiciones de la 1 a 5, no correspondan al municipio de Girón en el departamento de Santander, el cual corresponde al código  ‘68307'.

        ```sql
        --Identificacion de predios que en su codigo nacional en la posicion 6 y 7 que sean rurales se codifiquen con 
        select * from public.girondatos where codigo_anterior  not like '6830700%' and tipo_predio  = 'RURAL';
        
        -- Correcion de los registros que presentan la problematica en el codigo predial anterio
        update public.girondatos 
        set codigo_anterior =replace (codigo_anterior ,'6830701','6830700') where codigo_anterior  not like '6830700%' and tipo_predio  = 'RURAL';
        ```
- **Zona del predio (tipo_predio).**

    - Verificar el rango de valores diligenciados en la variable tipo_predios, el cual indica el perímetro en el cual se encuentra, finalmente estandarizar los valores al dominio del modelo RIC.
    
        ```sql
        -- Valores que registra la zona del predio 
        select tipo_predio from public.girondatos group by tipo_predio;
        
        --Estandarizacion de valores en zona del predio segun el modelo RIC
        update public.girondatos set tipo_predio= (case 
        when tipo_predio like 'RURAL' then  'Rural'
        when tipo_predio like 'URBANO' then 'Urbano'end);
        ```
    - Identificación y corrección de registros de los predios que indican estar en zona Urbana, pero los cuales su código predial nacional, presenta la codificación ‘6830700’ el cual indica estar en perímetro Rural.
        ```sql
        --Identificacion de predios que indican que zona del predio urbano pero en el codigo nacional son rurales
        select * from public.girondatos where tipo_predio = 'Urbano' and  codigo  like '6830700%';
        
        -- Correcion del valor de la zona del predio con respeto a la estructura del codigo predial nacional
        
        update public.girondatos set tipo_predio='Rural' 
        where tipo_predio = 'Urbano' and  codigo like '6830700%';
        ```
- **Tipo de documento de identificación (tipo_de_documento_de_identificacion )**

    - Identificación del rango de valores del tipo de documento de identificación registrado, finamente estandarizar los valores al dominio del modelo RIC.

        ```sql
        --Identificacion del grupo de valores del tipo de documento de identificacion
        select tipo_de_documento_de_identificacion  from public.girondatos group by tipo_de_documento_de_identificacion;
        
        --Estandarizacion de valores de tipo de docuemnto de identificacion segun el modelo RIV
        update public.girondatos 
        set tipo_de_documento_de_identificacion = (case 
        when tipo_de_documento_de_identificacion like 'CC' then 'Cedula_Ciudadania'
        when tipo_de_documento_de_identificacion like 'C' then 'Cedula_Ciudadania'
        when tipo_de_documento_de_identificacion like 'RC' then 'Registro_Civil'
        when tipo_de_documento_de_identificacion like 'TI' then 'Tarjeta_Identidad'
        when tipo_de_documento_de_identificacion like 'CE' then 'Cedula_Extranjeria'
        when tipo_de_documento_de_identificacion like 'NIT'then 'NIT'
        when tipo_de_documento_de_identificacion like 'PA' then 'Pasaporte'
        end);
        ```
    - Identificación del rango de valores del tipo de documento de identificación registrado, finamente estandarizar los valores al dominio del modelo RIC.

        ``` sql
        --Eliminar los registros con Tarjeta de Identidad
        delete from public.girondatos where tipo_de_documento_de_identificacion like 'Tarjeta_Identidad';
        --Eliminar los registros con Cedula de Ciudadania 
        delete from public.girondatos where tipo_de_documento_de_identificacion like 'Cedula_Extranjeria';
        ```
- **Tipo de interesado**
  
    - Creación del atributo tipo de interesado, el cual indica el tipo de persona que es dueña del predio. 

        ```sql
        -- Crear el atibuto de tipo de interesado
        alter table  public.girondatos add tipo_interesado varchar(250);
        
        -- Agregar el tipo de interesado segun el modelo RIC
        update public.girondatos set tipo_interesado = (
        case
        when tipo_de_documento_de_identificacion like 'NIT' then 'Persona_Juridica'
        else 'Persona_Natural'
        end);
        ```
- **Grupo étnico (grupo_etnico)**

    - Identificación del rango de valores y estandarización del Grupo Étnico según los valores indicados por el modelo RIC.

        ```sql
        --Identificacion del grupo de valores registrados en grupo_etnico
        select grupo_etnico  from public.girondatos group by grupo_etnico;
        
        --Estandarizacion de valores de grupo_etnico segun el modelo RIV
        update public.girondatos 
        set grupo_etnico = (case
            when grupo_etnico like 'NEGRO AFROCOLOMBIANO' then 'Negro_Afrocolombiano'
            when grupo_etnico like 'RROM' then 'Rrom'
            when grupo_etnico like 'PALENQUERO' then 'Palenquero'
            when grupo_etnico like 'RAIZAL' then 'Raizal'
            when grupo_etnico like 'INDIGENA'then 'Indigena'
            when grupo_etnico like 'NINGUNO' then 'Ninguno'
        end); 
        ```
    - Actualizar el valor del grupo étnico de aquellos registros que tengan el tipo de documento NIT.

        ```sql
        -- remplazar el grupo etnico de los registros con tipo de documento NIT
        update public.girondatos set grupo_etnico  =  regexp_replace(grupo_etnico ,'([A-Z])\w+','Ninguno','g')
        where tipo_de_documento_de_identificacion like 'NIT';
        ```
- **Estado civil (estado_civil)**
  
    - Identificación del rango de valores del estado civil del propietario, para finalmente estandarizar los valores en base del dominio del modelo RIC
    
        ```sql
        --Identificacion del grupo de valores registrados en estado_civil
        select estado_civil from public.girondatos group by estado_civil;
        
        --Estandarizacion de valores de estado_etnico segun el modelo RIV
        update public.girondatos 
        set estado_civil = (case
            when estado_civil like 'CASADO' then 'Casado'
            when estado_civil like 'CASADA' then 'Casado'
            when estado_civil like 'SOLTERO' then 'Soltero'
            when estado_civil like 'UNION LIBRE 2 AÑOS' then 'No_Casado_Vive_En_Pareja_2_Anios_O_Mas'
            when estado_civil like 'UNION LIBRE 1 AÑO' then 'No_Casado_Vive_En_Pareja_Menos_2_Anios'
            when estado_civil like 'UNION LIBRE 4 AÑOS' then 'No_Casado_Vive_En_Pareja_2_Anios_O_Mas'
            when estado_civil like 'SIN INFORMACION' then null
        end);
        ```
    - Cambiar el estado civil de los registros que tengan como tipo de documento de identidad NIT.
    
        ```sql
        -- remplazar el estado civil de los registros con tipo de documento NIT
        update public.girondatos set estado_civil =  regexp_replace(estado_civil,'([A-Z])\w+',null,'g') 
        where tipo_de_documento_de_identificacion like 'NIT';
        ```

- **Tipo de fuente administrativa (tipo_documento)**
    - Identificación del rango de valores del tipo de fuente administrativa y estandarizar el rango de valores que pueden tomar en base de los dominios definidos en el modelo RIC. 

        ```sql
        --Identificacion del grupo de valores del tipo de documento de la fuente administrativa
        select tipo_documento  from public.girondatos group by tipo_documento ;
        
        --Estandarizacion de valores del tipo de documento de la fuente administrativa segun el modelo RIC
        update public.girondatos set tipo_documento = (case 
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
        ```
- **Estado del folio (estado_folio)**
    - Eliminar los registros los cuales presenten un estado de folio 'Cerrado".

        ```sql
        --Eliminar los registros con estados de folios cerrados
        delete  from public.girondatos where estado_folio like 'CERRADO';
        ```
    - Eliminar la variable del estado de folio.
        ```sql
        --Borrado del atribuo estado_folio
        alter table public.girondatos drop estado_folio;
        ```

- **Numero de documento de identificación (numero_documento)**

    - Verificar que no haya presencia de caracteres alfanuméricos en la identificación del propietario. 
        ```sql
        --Verificar si hay caracteres alfanumeriocos en los numeros de identificacion 
        select *  from public.girondatos  where numero_documento !~ '^[0-9]*$';
        ```
    - Verificar que no haya presencia de caracteres alfanuméricos en la identificación del propietario. 
        ```sql
        --Identifacion de numero de documentos de identidad vacios 
        select * from public.girondatos where numero_documento like'';
        --Asignacion de valor a los registros con numero  documento de identicacion vacios
        update public.girondatos set numero_documento  = 'Sin_Informacion'
        where numero_documento like'';
        ```
- **Tipo de derecho (derecho )**

    - Identificación del rango de valores del tipo de derecho que el propietario presenta sobre el predio, para finalmente estandarizar el rango de valores que pueden tomar en base de los dominios definidos en el modelo RIC. 

        ```sql  
        --Identificacion del grupo de valores del tipo de derecho
        select derecho  from public.girondatos group by derecho;
        --Estandarizacion de valores  del tipo de derechos segun el modelo RIC
        update public.girondatos set derecho = (
        case
            when derecho like 'POSESION' then 'Posesion'
            when derecho like 'POSECION' then 'Posesion'
            when derecho like 'OCUPASION' then 'Ocupacion'
            when derecho like 'OCUPACION' then 'Ocupacion'
            when derecho like 'DOMINIO' then 'Dominio'
        end);
        ```
- **Fecha del acto administrativo (fecha)**

    - Se debe cambiar el tipo de dato que tiene la variable de Fecha, esto debido que en el insumo entregado es de tipo String, para que cumpla la consistencia lógica asociada a la información se lleva a un tipo Date. 

        ```sql
        -- Cambiar el formato de la variable fecha de String a Date
        alter table public.girondatos alter column fecha type date using fecha::date;
        ```
    -  Verificar si hay fechas asociadas a registros con fechas inferiores a el 1 de enero de 1930 y superiores a la fecha actual, en esos casos se les asignara un valor.

        ```sql
        --Verificar si existen fechas menores  a 1930 y mayores a la fecha actual	
        select * from public.girondatos where fecha <'1930-01-01' or fecha > now();
        --Asignar un valor estandar a  los registros que presentan inconsitencia logica en sus fechas 
        update public.girondatos set fecha= null
        where fecha <'1930-01-01' or fecha > now();
        ```
- **Nombre del propietario (propietario)**

    - Identificación y corrección si en el campo del nombre del propietario, existe el carácter '-'.
    
        ```sql 
        -- Identificacion del caracter '-' en el nombre del propietario
        select * from public.girondatos  where propietario ~ '-';
        -- correcion del nombre
        update public.girondatos  set propietario = replace(propietario,'-',' ') 
        where propietario ~ '-';
        ```

    - Identificación y corrección de doble espaciado en el campo de nombre de propietario.
        ```sql
        -- Identificacion de nombres con doble espacio en su campo
        select * from public.girondatos where propietario  like '%  %';
        -- Correcion del doble espaciado en el nombre del propietario
        update public.girondatos  set propietario=replace(propietario,'  ',' ')
        where propietario  like '%  %';
        ```

    - Convertir todos los caracteres alfanuméricos a mayúsculas.

        ```sql
        --Estandarizar los nombres de propiestarios en mayuscula
        update public.girondatos set propietario = upper(propietario); 
        ```

- **Primer nombre, segundo nombre, primer apellido y segundo apellido.**

    - Creación de los atributos Primer nombre, segundo nombre, primer apellido y segundo apellido, según los lineamientos del modelo RIC.

        ```sql
        --Creacion de los atributos de primer_nombre, segundo_nombre,primer_apellido y segundo apellido
        alter table  public.girondatos add primer_nombre varchar(250);
        alter table  public.girondatos add segundo_nombre varchar(250);
        alter table  public.girondatos add primer_apellido varchar(250);
        alter table  public.girondatos add segundo_apellido varchar(250);
        ```
    - Numero de espacios en el nombre de propietario.

        ```sql
        --numero de espacios en el nombre del propietario
        select propietario,
        (array_length(string_to_array(propietario , ' '),1)-1) as numero_espacios
        from public.girondatos;
        ```
    - Nombre de propiatarios con un espacio.    
        - Identificación de los nombres con un espacio.
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 1;
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 1;
            ```
        - Primer apellido.
            ```sql
            update public.girondatos 
            set primer_apellido = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 1;
    - Nombre con dos espacios que en su nombre tienen la expresión 'DEL'.
        - Identificación.
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DEL %';
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DEL %';
            ```
        -  Primer apellido.
            ```sql
            update public.girondatos 
            set primer_apellido = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DEL %';
            ```
    -  Nombre con dos espacios que en su nombre tienen la expresión 'DE'.
        - Identificación
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DE %';
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DE %';
            ```
        - Primer apellido.
            ```sql
            update public.girondatos 
            set primer_apellido = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  and propietario  like '% DE %';
            ```
    - Nombres con dos espacios que no tienen la expresión ‘DEL’ y ‘DE’.
        - Identificación.
            ```sql
            select * from public.girondatos g 
            where tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```

        - Primer apellido.
            ```sql
            update public.girondatos
            set primer_apellido= (string_to_array(propietario, ' '))[2]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
        - Segundo apellido. 
            ```sql 
            update public.girondatos
            set segundo_apellido= (string_to_array(propietario, ' '))[3]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 2  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
    - Nombre con tres espacios que no tienen la expresión 'DEL'.
        - Identificación.
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';
            ```
        - Segundo nombre.
            ```sql 
            update public.girondatos 
            set segundo_nombre = (string_to_array(propietario, ' '))[2]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';
            ```
        - Primer apellido 
        
            ```sql
            update public.girondatos 
            set primer_apellido = concat((string_to_array(propietario, ' '))[3],' ',(string_to_array(propietario, ' '))[4])
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DEL %';
            ```
    - Nombre con tres espacios que no tienen la expresión 'DE'.
        - Identificación.
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';
            ```
        - Segundo nombre
            ```sql
            update public.girondatos 
            set segundo_nombre = (string_to_array(propietario, ' '))[2]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %';
            ```
        - Primer apellido.
            ```sql
            update public.girondatos 
            set primer_apellido = concat((string_to_array(propietario, ' '))[3],' ',(string_to_array(propietario, ' '))[4])
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  and propietario  like '% DE %'; 
            ```
    - Nombre con tres espacios que no tienen la expresión ‘DEL’ y ‘DE’.
        - Identificación.
            ```sql
            --Propietario con tres espacios en su nombre el cual no tiene la palabra "DEL" o "DE"
            select * from public.girondatos  
            where tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
        - Primer nombre. 
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) =  3
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
        -  Segundo nombre.
            ```sql
            update public.girondatos 
            set segundo_nombre = (string_to_array(propietario, ' '))[2]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            update public.girondatos
            ```
        - Primer apellido.
            ```sql
            update public.girondatos
            set primer_apellido= (string_to_array(propietario, ' '))[3]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3  
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
        - Segundo apellido.
            ```sql
            update public.girondatos
            set segundo_apellido= (string_to_array(propietario, ' '))[4]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 3 
            and propietario  not like '% DE %' and propietario  not like '% DEL %';
            ```
    - Nombre con cuatro espacios.
        -  Identificación. 
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 4;  
            ```
        - Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 4;
            ```
        - Segundo nombre.
            ```sql
            update public.girondatos 
            set segundo_nombre = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 4;
            ```
        - Primer apellido.
            ```sql
            update public.girondatos
            set primer_apellido= (string_to_array(propietario, ' '))[4]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 4;
            ```
        - Segundo apellido.
            ```sql
            update public.girondatos
            set segundo_apellido= (string_to_array(propietario, ' '))[5]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 4;
            ```
    - Nombre con cinco espacios.
        - Identificación.
            ```sql
            select * from public.girondatos g 
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 5;
            ```
        -  Primer nombre.
            ```sql
            update public.girondatos 
            set primer_nombre = (string_to_array(propietario, ' '))[1]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 5;
            ```
        - Segundo nombre.
            ```sql
            update public.girondatos 
            set segundo_nombre = concat((string_to_array(propietario, ' '))[2],' ',(string_to_array(propietario, ' '))[3])
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 5;
            ```
        - Primer apellido.
            ```sql
            update public.girondatos
            set primer_apellido= (string_to_array(propietario, ' '))[5]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 5;
            ```
        - Segundo apellido.
            ```sql
            update public.girondatos
            set segundo_apellido= (string_to_array(propietario, ' '))[6]
            where  tipo_de_documento_de_identificacion  not like 'NIT' 
            and (array_length(string_to_array(propietario , ' '),1)-1) = 5;
            ```
- **Razon social** 
    - Creación del atributo razón social.	
        ```sql
        --Creacion del campo Razon Social 
        alter table  public.girondatos add razon_social varchar(250);
        ```
    - Asignación de valores a la razón social a los propietarios con tipo de identificación NIT.
        ```sql
        --Adicion de los valores de la razon social
        update public.girondatos set razon_social = propietario 
        where  tipo_de_documento_de_identificacion   like 'NIT'; 
        ```

## Borrado de atributos que no se van a emplear ##
- **numero_subterraneos**
    ```sql
    alter table public.girondatos drop numero_subterraneos;
    ```
- **vereda_codigo**
    ```sql
    alter table public.girondatos drop vereda_codigo;
    ```
- **propietario**
    ```sql
    alter table public.girondatos drop propietario;
## Cambio de sistema de proyección de los insumos geográficos ##
- **terrenp**
    ```sql
    --Cambio del sistema de proyección de la capa de terrenos
    alter table public.terreno 
        alter column geom type geometry(MultiPolygon, 9377)
        using st_transform(st_setsrid(geom,3116), 9377)
    ;
    ```