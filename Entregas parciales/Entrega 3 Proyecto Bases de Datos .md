# Entrega 3 Proyecto Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

### Normalización de datos hasta cuarta formal normal
Para garantizar la integridad y consistencia de los datos, se realizaron los siguientes pasos de limpieza y conversión en el esquema `limpieza`. El siguiente codigo tiene la entrega pasada de limpieza y conversion de datos.

```sql
CREATE SCHEMA limpieza;

CREATE TABLE IF NOT EXISTS limpieza.companies AS
    SELECT * FROM public.companies;

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


--Cambio de los datos

ALTER TABLE limpieza.companies ALTER COLUMN total_reviews TYPE BIGINT USING total_reviews::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN average_salary TYPE BIGINT USING average_salary::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN total_interviews TYPE BIGINT USING total_interviews::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN available_jobs TYPE BIGINT USING available_jobs::BIGINT;
ALTER TABLE limpieza.companies ALTER COLUMN total_benefits TYPE BIGINT USING total_benefits::BIGINT;

ALTER TABLE limpieza.companies ALTER COLUMN company_name TYPE VARCHAR(255);
ALTER TABLE limpieza.companies ALTER COLUMN description TYPE VARCHAR(255);
ALTER TABLE limpieza.companies ALTER COLUMN highly_rated_for TYPE VARCHAR(255);
ALTER TABLE limpieza.companies ALTER COLUMN critically_rated_for TYPE VARCHAR(255);

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


## Normalización de Datos

El objetivo es llevar la base de datos hasta Cuarta Forma Normal (4NF).
En esta etapa, los datos se migran al esquema `normalizacion` y posteriormente al esquema `final` para distinguir claramente las tablas normalizadas.

Un problema inicial es que la tabla no contiene un identificador.

### Asignación de ID a la Tabla `companies`
Primero, se añade una columna **`id`** a la tabla `companies`, asignando valores únicos a cada registro usando `ROW_NUMBER()` para garantizar una clave artificial.
`ROW_NUMBER()` genera un índice incremental basado en `ctid`, permitiendo una identificación única.
```sql
-- Normalización de la tabla companies
-- Antes correr 01_create_schema.sql
DROP SCHEMA IF EXISTS normalizacion CASCADE;

CREATE SCHEMA IF NOT EXISTS normalizacion;

CREATE TABLE IF NOT EXISTS normalizacion.companies AS
    SELECT * FROM limpieza.companies;

ALTER TABLE normalizacion.companies
ADD COLUMN id INTEGER;

UPDATE normalizacion.companies
SET id = sub.row_num
FROM (
  SELECT ctid, ROW_NUMBER() OVER (ORDER BY ctid) AS row_num
  FROM normalizacion.companies
) sub
WHERE normalizacion.companies.ctid = sub.ctid;

ALTER TABLE normalizacion.companies
ALTER COLUMN id SET NOT NULL;

ALTER TABLE normalizacion.companies
ADD CONSTRAINT pk_companies PRIMARY KEY (id);
```
---

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
DROP TABLE IF EXISTS normalizacion.descriptions;
CREATE TABLE normalizacion.descriptions (
    id BIGSERIAL PRIMARY KEY,
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
INSERT INTO normalizacion.descriptions (
    description,
    location,
    industry,
    employees,
    company_type,
    age
)
SELECT
    d.description,

    -- Detectar ubicación como la última parte después del último '|'
    TRIM(SPLIT_PART(d.description, '|', array_length(string_to_array(d.description, '|'), 1))) AS location,

    -- Extraer industry (primer campo antes del primer '|')
    CASE
        WHEN d.description LIKE '%|%' THEN TRIM(SPLIT_PART(d.description, '|', 1))
        ELSE NULL
    END AS industry,

    -- Employees (campo que contiene 'employees')
    (
        SELECT TRIM(val) FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%employees%' LIMIT 1
    ) AS employees,

    -- Company type: solo 'Public' o 'Private'
    (
        SELECT
            CASE
                WHEN val ILIKE '%public%' THEN 'Public'
                WHEN val ILIKE '%private%' THEN 'Private'
                ELSE NULL
            END
        FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%public%' OR val ILIKE '%private%'
        LIMIT 1
    ) AS company_type,

    -- Age (campo que contiene 'years old')
    (
        SELECT TRIM(val) FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%years old%' LIMIT 1
    ) AS age

FROM (
    SELECT DISTINCT description
    FROM normalizacion.companies
    WHERE description IS NOT NULL
) d;
```
Esto permite almacenar cada atributo en su **propia columna**.

Agregar una tabla pivote `companies_description`.
```sql
DROP TABLE IF EXISTS normalizacion.companies_description;
CREATE TABLE IF NOT EXISTS normalizacion.companies_description (
    id BIGSERIAL PRIMARY KEY,
    id_description BIGINT ,
    id_companies BIGINT
);

INSERT INTO normalizacion.companies_description (id_description, id_companies)
SELECT i.id, l.id
FROM  normalizacion.descriptions i
JOIN normalizacion.companies l ON i.description = l.description;

ALTER TABLE normalizacion.companies DROP COLUMN description;
ALTER TABLE normalizacion.descriptions DROP COLUMN description;
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
--tablas parciales:
DROP TABLE IF EXISTS normalizacion.companies_fn1;
CREATE TABLE normalizacion.companies_fn1 AS
SELECT c.*, r.rating_value
FROM normalizacion.companies c
LEFT JOIN LATERAL (
    SELECT regexp_split_to_table(c.highly_rated_for, '\s*,\s*') AS rating_value
) r ON true;

DROP TABLE IF EXISTS normalizacion.companies_fn2;
CREATE TABLE normalizacion.companies_fn2 AS
SELECT c.*, r.value
FROM normalizacion.companies_fn1 c
LEFT JOIN LATERAL (
    SELECT regexp_split_to_table(c.critically_rated_for, '\s*,\s*') AS value
) r ON true;

--por Teorema de Heath
DROP TABLE IF EXISTS normalizacion.companies_4fn;
CREATE TABLE normalizacion.companies_4fn AS
    SELECT DISTINCT
    id,
    company_name,
    average_rating,
    total_reviews,
    average_salary,
    total_interviews,
    available_jobs,
    total_benefits
FROM normalizacion.companies_fn2;

-- Agregar clave primaria a la tabla companies_4fn para permitir referencias foráneas
ALTER TABLE normalizacion.companies_4fn
ADD CONSTRAINT pk_companies_4fn PRIMARY KEY (id);

DROP TABLE IF EXISTS normalizacion.companies_highly_rated;
CREATE TABLE normalizacion.companies_highly_rated (
    id BIGSERIAL PRIMARY KEY,
    id_company BIGINT,
    rating_value VARCHAR(100)
);

INSERT INTO normalizacion.companies_highly_rated (id_company,rating_value)
SELECT DISTINCT
    id,
    rating_value
FROM normalizacion.companies_fn2
WHERE rating_value IS NOT NULL;

DROP TABLE IF EXISTS normalizacion.companies_critically_rated;
CREATE TABLE normalizacion.companies_critically_rated (
    id BIGSERIAL PRIMARY KEY,
    id_company BIGINT,
    value VARCHAR(100)
);

INSERT INTO normalizacion.companies_critically_rated(id_company,value)
SELECT DISTINCT
    id,
    value
FROM normalizacion.companies_fn2;



-- Llaves foráneas para mantener integridad referencial
-- companies_description: referencia a descriptions y companies_4fn
ALTER TABLE normalizacion.companies_description
ADD CONSTRAINT fk_companies_description_description
  FOREIGN KEY (id_description) REFERENCES normalizacion.descriptions(id)
  ON DELETE CASCADE,
ADD CONSTRAINT fk_companies_description_company
  FOREIGN KEY (id_companies) REFERENCES normalizacion.companies_4fn(id)
  ON DELETE CASCADE;

-- companies_highly_rated: referencia a companies_4fn
ALTER TABLE normalizacion.companies_highly_rated
ADD CONSTRAINT fk_highly_rated_company
  FOREIGN KEY (id_company) REFERENCES normalizacion.companies_4fn(id)
  ON DELETE CASCADE;

-- companies_critically_rated: referencia a companies_4fn
ALTER TABLE normalizacion.companies_critically_rated
ADD CONSTRAINT fk_critically_rated_company
  FOREIGN KEY (id_company) REFERENCES normalizacion.companies_4fn(id)
  ON DELETE CASCADE;

```
Ahora los atributos multivaluados están en **tablas separadas**, cumpliendo **4NF**.

### Migración al esquema final

Para distinguir las tablas normalizadas, se migran al esquema `final`:

```sql
CREATE SCHEMA IF NOT EXISTS final;

ALTER TABLE normalizacion.companies_4fn SET SCHEMA final;
ALTER TABLE normalizacion.descriptions SET SCHEMA final;
ALTER TABLE normalizacion.companies_highly_rated SET SCHEMA final;
ALTER TABLE normalizacion.companies_critically_rated SET SCHEMA final;
ALTER TABLE normalizacion.companies_description SET SCHEMA final;
```
## Diagrama Entidad-Relación (ERD)

A continuación se muestra el diagrama Entidad-Relación (ERD) que representa la estructura final de la base de datos tras la normalización:

![Diagrama ERD](./images/erd.png)