# Proyecto Bases de Datos

**Integrantes:**
- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

# **Top Companies**

## **Introducción**
Este proyecto tiene como objetivo analizar y limpiar un conjunto de datos sobre las principales 10,000 empresas, facilitando la extracción de información clave sobre calificaciones, salarios y beneficios. 


### **Propósito del Proyecto**
El análisis de datos de empresas permite comprender tendencias del mercado laboral, identificando:
- **Factores clave** que influyen en la percepción de una empresa.
- **Promedios salariales** y condiciones laborales en distintas industrias.
- **Beneficios más valorados** por empleados y candidatos a puestos de trabajo.

Este conjunto de datos contiene información sobre las principales **10,000 empresas**, incluyendo:
- Nombre y descripción.
- Calificación promedio.
- Aspectos más valorados y criticados.
- Total de reseñas, salario promedio y cantidad de entrevistas realizadas.
- Número de empleos disponibles y beneficios ofrecidos.

### **Fuente del Dataset**
- **Recolector**: Vedant Khapekar.
- **Fuente original**: Ambition Box, una plataforma de reclutamiento.
- **Disponibilidad**: Se encuentra en **Kaggle**.
- **Frecuencia de actualización**: No se actualiza, aunque los datos cambien en Ambition Box.

### **Consideraciones Éticas**
Este análisis implica responsabilidad en el uso de los datos:
- **Privacidad**: Asegurar que la información sensible esté protegida.
- **Uso responsable**: Evitar interpretaciones sesgadas o manipuladas.
- **Transparencia**: Definir claramente metodologías y fuentes de datos.
- **Evitar discriminación**: No favorecer a empresas por tamaño, ubicación o industria.

---

## **Instalación y Configuración**
### **1. Clonar el repositorio**
```bash
git clone [URL_DEL_REPOSITORIO]
cd Empresas
```

## Instrucciones para psql

### Borrar y crear la base de datos
```sql
DROP DATABASE IF EXISTS top_companies;
CREATE DATABASE top_companies;
```

### Conectarse a la base de datos
```sql
\c top_companies;
```

### Borrar y crear la tabla
```sql
DROP TABLE IF EXISTS companies;

CREATE TABLE companies (
    company_name TEXT,
    description TEXT,
    average_rating DOUBLE PRECISION,
    highly_rated_for TEXT,
    critically_rated_for TEXT,
    total_reviews TEXT,
    average_salary TEXT,
    total_interviews TEXT,
    available_jobs TEXT,
    total_benefits TEXT
);
```

### Importar datos desde el archivo CSV
> **IMPORTANTE:** Cambiar la dirección del archivo antes de ejecutar el comando.
```sql
SET CLIENT_ENCODING TO 'UTF8';
\copy companies (company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits) FROM 'C:/Users/Light 16 Pro/Downloads/companies.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```



### Limpieza y Conversión de Datos

Para garantizar la integridad y consistencia de los datos, se realizaron los siguientes pasos de limpieza y conversión en el esquema `limpieza`:

#### 1. Creación del Esquema y Copia de Datos
Se creó un esquema `limpieza` para separar los datos originales de los procesados:
```sql
CREATE SCHEMA limpieza;

CREATE TABLE IF NOT EXISTS limpieza.companies AS
  SELECT * FROM public.companies;
```

#### 2. Conversión de Valores con Sufijo "k" y "--" a Números Enteros o NULL
Se procesaron las columnas `total_reviews`, `average_salary`, `total_interviews`, `available_jobs` y `total_benefits` para convertir valores con sufijo "k" a números enteros y reemplazar valores "--" con `NULL`:
```sql
UPDATE limpieza.companies SET total_reviews = (
  CASE
  WHEN total_reviews ILIKE '%k' THEN
    (CAST(REPLACE(LOWER(total_reviews), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
  WHEN total_reviews = '--' OR total_reviews IS NULL THEN NULL
  ELSE total_reviews
  END
);

UPDATE limpieza.companies SET average_salary = (
  CASE
  WHEN average_salary ILIKE '%k' THEN
    (CAST(REPLACE(LOWER(average_salary), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
  WHEN average_salary = '--' OR average_salary IS NULL THEN NULL
  ELSE average_salary
  END
);

UPDATE limpieza.companies SET total_interviews = (
  CASE
  WHEN total_interviews ILIKE '%k' THEN
    (CAST(REPLACE(LOWER(total_interviews), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
  WHEN total_interviews = '--' OR total_interviews IS NULL THEN NULL
  ELSE total_interviews
  END
);

UPDATE limpieza.companies SET available_jobs = (
  CASE
  WHEN available_jobs ILIKE '%k' THEN
    (CAST(REPLACE(LOWER(available_jobs), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
  WHEN available_jobs = '--' OR available_jobs IS NULL THEN NULL
  ELSE available_jobs
  END
);

UPDATE limpieza.companies SET total_benefits = (
  CASE
  WHEN total_benefits ILIKE '%k' THEN
    (CAST(REPLACE(LOWER(total_benefits), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
  WHEN total_benefits = '--' OR total_benefits IS NULL THEN NULL
  ELSE total_benefits
  END
);
```

#### 3. Modificación del Tipo de Datos
Se ajustaron los tipos de datos de las columnas para reflejar los cambios realizados:
```sql
ALTER TABLE limpieza.companies ALTER COLUMN total_reviews TYPE BIGINT USING total_reviews::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN average_salary TYPE BIGINT USING average_salary::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN total_interviews TYPE BIGINT USING total_interviews::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN available_jobs TYPE BIGINT USING available_jobs::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN total_benefits TYPE BIGINT USING total_benefits::BIGINT;

ALTER TABLE limpieza.companies ALTER COLUMN company_name TYPE VARCHAR(255);
ALTER TABLE limpieza.companies ALTER COLUMN description TYPE VARCHAR(255);
ALTER TABLE limpieza.companies ALTER COLUMN highly_rated_for TYPE VARCHAR(255);
ALTER TABLE limpieza.companies ALTER COLUMN critically_rated_for TYPE VARCHAR(255);
```

#### 4. Eliminación de Duplicados
Se eliminaron registros duplicados basándose en combinaciones de columnas clave:
```sql
DELETE FROM limpieza.companies
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM limpieza.companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
);

DELETE FROM limpieza.companies
WHERE ctid NOT IN (  
  SELECT MIN(ctid)
  FROM limpieza.companies
  GROUP BY company_name, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, total_benefits
);
```

Con estos pasos, los datos en el esquema `limpieza` están listos para su análisis y normalización.




## Normalización de datos hasta cuarta formal normal

El objetivo es llevar la base de datos hasta Cuarta Forma Normal (4NF).
Un problema inicial es que la tabla no contiene un identificador.

### Asignación de ID a la Tabla `companies`
Primero, se añade una columna **`id`** a la tabla `companies`, asignando valores únicos a cada registro usando `ROW_NUMBER()` para garantizar una clave artificial.
`ROW_NUMBER()` genera un índice incremental basado en `ctid`, permitiendo una identificación única.

```sql
--Ponerle un id a las nuevas columnas
ALTER TABLE limpieza.companies ADD COLUMN id INTEGER;

UPDATE limpieza.companies
SET id = sub.row_num
FROM (
  SELECT ctid, ROW_NUMBER() OVER (ORDER BY ctid) AS row_num
  FROM limpieza.companies
) sub
WHERE limpieza.companies.ctid = sub.ctid;
```
---
### Creación de una Secuencia para ID
Se utiliza una **secuencia (`limpieza_companies_id_seq`)** para mantener la generación automática de identificadores en futuras inserciones.

```sql
DROP SEQUENCE IF EXISTS limpieza_companies_id_seq;
CREATE SEQUENCE limpieza_companies_id_seq;

SELECT setval('limpieza_companies_id_seq', (SELECT MAX(id) FROM limpieza.companies));

ALTER TABLE limpieza.companies
ALTER COLUMN id SET DEFAULT nextval('limpieza_companies_id_seq');

SELECT * FROM limpieza.companies
ORDER BY id;
```

### Relvar Original (Tabla Companies)
Ahora podemos definir la relvar original (antes de cualquier descomposición) con el siguiente encabezado:

```
Companies = { id, company_name, average_rating, total_reviews, average_salary, total_interviews, available_jobs, total_benefits, description, highly_rated_for, critically_rated_for }
```

**Dependencia Funcional (DF):**

El identificador único `id` determina de forma única el resto de los atributos:

```
{id} → { company_name, average_rating, total_reviews, average_salary, total_interviews, available_jobs, total_benefits, description, highly_rated_for, critically_rated_for }
```

**Dependencias Multivaluadas (DMV) No Triviales:**

Dado que los campos `highly_rated_for` y `critically_rated_for` contienen múltiples valores en una misma celda, se tienen las siguientes dependencias multivaluadas:

```
{id} ->> { highly_rated_for }
{id} ->> { critically_rated_for }
```


### Problema en la estructura de datos inicial

El campo `description` en la tabla original contiene una cadena compuesta de varios atributos como ubicación, industria, número de empleados, tipo de empresa y años de operación. Para cumplir 1NF, se extrajo esta información a una nueva relvar.

**Encabezado de la relvar:**

```
Descriptions = { descripcion_id, location, industry, employees, company_type, age }
```

**Dependencia Funcional:**

```
{ descripcion_id } → { location, industry, employees, company_type, age }
```

Ejemplo de `description` antes de normalizar:

| description |  
|-----------------------------------------|  
| Engineering & Construction \| 51-200 Employees \| 54 years old \| Mumbai +12 more |  
| Automobile \| 5k-10k Employees \| Public \| 79 years old \| Pune +250 more |  
| IT Services & Consulting \| 10k-50k Employees \| Public \| 34 years old \| Pune +33 more |  
| Power \| 1k-5k Employees \| Public \| 18 years old \| Ahmedabad +79 more |  
| Noida +69 more |  

Para solucionar esto, es necesario  dividir `description` en entidades separadas , asegurando una representación clara y normalizada.

---

### Creación de una tabla `descriptions` para separar lo que contiene la columna description

Para cumplir con  1NF , descomponemos la columna `description` en una nueva tabla llamada `descriptions`, donde cada empresa tendrá referencias claras a información detallada como:  


| id  | location   | industry                  | employees       | company_type | age       |
|-----|-----------|---------------------------|----------------|--------------|-----------|
| 1   | Mumbai    | Engineering & Construction | 51-200         | NULL         | 54 years  |
| 2   | Pune      | Automobile                 | 5k-10k         | Public       | 79 years  |
| 3   | Pune      | IT Services & Consulting   | 10k-50k        | Public       | 34 years  |
| 4   | Ahmedabad | Power                      | 1k-5k          | Public       | 18 years  |
| 5   | Noida     | NULL                       | NULL           | NULL         | NULL      |

```sql
--Creacion de las tablas de descripcion

DROP TABLE IF EXISTS limpieza.descriptions;
CREATE TABLE limpieza.descriptions (
    id SERIAL PRIMARY KEY,
    description TEXT UNIQUE,
    location TEXT,
    industry TEXT,
    employees TEXT,
    company_type TEXT,
    age TEXT
);
```

Extraer Atributos de `description`
Dado que `description` contiene múltiples valores en **formato texto**, se usa `string_to_array()` y expresiones regulares para extraer:
- **Ubicación (`location`)**
- **Industria (`industry`)**
- **Número de empleados (`employees`)**
- **Tipo de empresa (`company_type`)**
- **Años de operación (`age`)**

```sql
INSERT INTO limpieza.descriptions (
    description,
    location,
    industry,
    employees,
    company_type,
    age
)
SELECT
    d.description,

    -- Detectar ubicación como "City +N more"
    CASE
        WHEN d.description ~* '^[A-Za-z ]+\s+\+\d+\s+more$' THEN d.description
        WHEN d.description LIKE '%+% more%' THEN NULL
        ELSE NULL
    END AS location,

    -- Extraer industry
    CASE
        WHEN d.description LIKE '%|%' THEN TRIM(SPLIT_PART(d.description, '|', 1))
        ELSE NULL
    END AS industry,

    -- Employees
    (
        SELECT val FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%employees%' LIMIT 1
    ) AS employees,

    -- Company type
    (
        SELECT val FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE 'public%' OR val ILIKE 'private%' LIMIT 1
    ) AS company_type,

    -- Age
    (
        SELECT val FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%years old%' LIMIT 1
    ) AS age

FROM (
    SELECT DISTINCT description
    FROM limpieza.companies
    WHERE description IS NOT NULL
) d;
```

Esto permite almacenar cada atributo en su **propia columna**, facilitando análisis.

```sql
-- Actualiza la columna 'location' en la tabla 'descriptions'.
-- Extrae la última parte del atributo 'description' (separado por '|') como ubicación.
UPDATE limpieza.descriptions
SET location = TRIM(
    SPLIT_PART(description, '|', array_length(string_to_array(description, '|'), 1))
)
WHERE description IS NOT NULL;

--Comprobacion
SELECT * FROM  limpieza.descriptions ORDER BY id;

SELECT * FROM limpieza.descriptions;

SELECT COUNT(*) FROM limpieza.descriptions;

SELECT COUNT(DISTINCT description) FROM limpieza.companies;
```
En la tabla companies cambiar `description` por 'descripcion_id'.
```sql
-- Agregar columna de descripcion
ALTER TABLE limpieza.companies
ADD COLUMN descripcion_id INTEGER;

UPDATE limpieza.companies c
SET descripcion_id = d.id
FROM limpieza.descriptions d
WHERE c.description = d.description;

ALTER TABLE limpieza.descriptions DROP COLUMN description;
SELECT * FROM limpieza.descriptions ORDER BY id;

SELECT * FROM limpieza.companies;
ALTER TABLE limpieza.companies DROP COLUMN description;
```
---

### Descomposición de Atributos Multivaluados
Debido a que los atributos `highly_rated_for` y `critically_rated_for` son multivaluados, se realizó una descomposición en relaciones independientes, eliminando la redundancia y dejando cada valor en una sola celda (cumpliendo 1NF y avanzando hacia 4NF).

**Relvar Companies_Highly_Rated**
```
Companies_Highly_Rated = { id, rating_value }

{id } → { rating_value }
```

**Relvar Companies_Critically_Rated**
```
Companies_Critically_Rated = { id, rating_value }

{id } → { rating_value }
```


```sql

--LLevar a FN1
DROP TABLE IF EXISTS limpieza.companies_fn1;

CREATE TABLE limpieza.companies_fn1 AS
-- Filas con valores individuales de highly_rated_for
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    TRIM(value) AS rating_value,
    c.critically_rated_for,
    c.total_reviews,
    c.average_salary,
    c.total_interviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies c,
     LATERAL regexp_split_to_table(c.highly_rated_for, '\s*,\s*') AS value

UNION ALL

-- Fila única cuando highly_rated_for es NULL
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    NULL AS rating_value,
    c.critically_rated_for,
    c.total_reviews,
    c.average_salary,
    c.total_interviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies c
WHERE c.highly_rated_for IS NULL;
```

Se aplica el mismo proceso para `critically_rated_for`.

```sql
DROP TABLE IF EXISTS limpieza.companies_fn2;
CREATE TABLE limpieza.companies_fn2 AS
-- Descomposición de critically_rated_for
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    c.rating_value AS highly_rated_for_value,
    TRIM(value) AS critically_rated_for_value,
    c.total_reviews,
    c.average_salary,
    c.total_interviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies_fn1 c,
     LATERAL regexp_split_to_table(c.critically_rated_for, '\s*,\s*') AS value
UNION ALL
-- Fila con NULL si critically_rated_for lo es
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    c.rating_value AS highly_rated_for_value,
    NULL AS critically_rated_for_value,
    c.total_reviews,
    c.average_salary,
    c.total_interviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies_fn1 c
WHERE c.critically_rated_for IS NULL;
```
```sql
SELECT * FROM limpieza.companies_fn2 WHERE id = 66;

SELECT * FROM limpieza.companies_fn2 ORDER BY id;

SELECT * FROM limpieza.companies_fn1 ORDER BY id;

SELECT * FROM limpieza.companies WHERE id = 66;
```


---

### Aplicación del Teorema de Heath (4NF)
Se descompone la tabla final en múltiples entidades.
La  última fase  de normalización consiste en  eliminar dependencias multivaluadas  en la base de datos utilizando el  Teorema de Heath . Esto nos permite dividir correctamente la información y generar relaciones claras sin redundancias.  

Para evitar la repetición de información que se ha fragmentado en las otras relaciones, se genera una relación que almacena únicamente los atributos que dependen funcionalmente de la clave principal sin la información descompuesta.

**Relvar Companies_Base (Información Esencial de Empresa):**
```
Companies_Base = { id, company_name, average_rating, total_reviews, average_salary, total_interviews, available_jobs, total_benefits }

descripcion_id, companies_highly_rated_id, companies_critically_rated_id }

{id} → { company_name, average_rating, total_reviews,  average_salary, total_interviews, available_jobs, total_benefits}

 descripcion_id, companies_highly_rated_id, companies_critically_rated_id }
```


Tablas finales después de 4NF:   
- `companies_base`: Información esencial de cada empresa.  
- `descriptions`: Atributos detallados por empresa.  
- `companies_highly_rated`: Categorías positivas en empresas.  
- `companies_critically_rated`: Categorías negativas en empresas.  
- `companies_descripciones`: Relación entre empresas y su descripción.  

```sql
--Teorema de Heath 4FN
DROP TABLE IF EXISTS limpieza.companies_base;
CREATE TABLE limpieza.companies_base AS
SELECT DISTINCT
    id,
    company_name,
    average_rating,
    total_reviews,
    average_salary,
    total_interviews,
    available_jobs,
    total_benefits
FROM limpieza.companies_fn2;
SELECT * FROM limpieza.companies_base;


--errores aqui creo, t.d.
DROP TABLE IF EXISTS limpieza.companies_descripciones;
CREATE TABLE limpieza.companies_descripciones AS
SELECT DISTINCT
    id,
    descripcion_id
FROM limpieza.companies_fn2
WHERE descripcion_id IS NOT NULL;
SELECT * FROM limpieza.companies_descripciones ORDER BY id;

--DROP TABLE limpieza.companies_highly_rated
CREATE TABLE limpieza.companies_highly_rated AS
SELECT DISTINCT
    id,
    highly_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE highly_rated_for_value IS NOT NULL;
SELECT * FROM limpieza.companies_highly_rated ORDER BY id;

--DROP TABLE limpieza.companies_critically_rated
CREATE TABLE limpieza.companies_critically_rated AS
SELECT DISTINCT
    id,
    critically_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE critically_rated_for_value IS NOT NULL;
SELECT * FROM limpieza.companies_critically_rated ORDER BY id;
```
Ahora los atributos multivaluados están en **tablas separadas**, cumpliendo **4NF**.

---

Tablas resultantes para el proyecto:
- companies_base
- companies_critically_rated
- companies_descripciones
- companies_highly_rated
- descriptions

