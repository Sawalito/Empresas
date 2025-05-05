# Entrega 3 Proyecto Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

### Normalización de datos hasta cuarta formal normal
Para no regarla, creamos un esquema limpieza que asegura una separacion entre los datos originales y estos procesados. El siguiente codigo tiene la entrega pasada de limpieza y conversion de datos

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


SELECT * FROM limpieza.companies;

SELECT MIN(ctid)
  FROM companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits;

SELECT
    CTID
FROM limpieza.companies;

SELECT description FROM limpieza.companies;


DELETE FROM limpieza.companies
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
);

```





--Ponerle un id a las nuevas columnas
ALTER TABLE limpieza.companies
ADD COLUMN id INTEGER;

ALTER TABLE limpieza.companies DROP COLUMN id;

ALTER TABLE limpieza.companies ALTER COLUMN id DROP DEFAULT;

UPDATE limpieza.companies
SET id = sub.row_num
FROM (
  SELECT ctid, ROW_NUMBER() OVER (ORDER BY ctid) AS row_num
  FROM limpieza.companies
) sub
WHERE limpieza.companies.ctid = sub.ctid;

DROP SEQUENCE IF EXISTS limpieza_companies_id_seq;

CREATE SEQUENCE limpieza_companies_id_seq;

SELECT setval('limpieza_companies_id_seq', (SELECT MAX(id) FROM limpieza.companies));

ALTER TABLE limpieza.companies
ALTER COLUMN id SET DEFAULT nextval('limpieza_companies_id_seq');


ALTER TABLE limpieza.companies
ALTER COLUMN id SET DEFAULT nextval('limpieza_companies_id_seq');


SELECT * FROM limpieza.companies
ORDER BY id;

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
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies c
WHERE c.highly_rated_for IS NULL;


CREATE TABLE limpieza.companies_fn2 AS

-- Descomposición de critically_rated_for
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    c.rating_value AS highly_rated_for_value,
    TRIM(value) AS critically_rated_for_value,
    c.total_reviews,
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
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies_fn1 c
WHERE c.critically_rated_for IS NULL;


SELECT * FROM limpieza.companies_fn2 WHERE id = 66;

SELECT * FROM limpieza.companies_fn2 ORDER BY id;

SELECT * FROM limpieza.companies_fn1 ORDER BY id;

SELECT * FROM limpieza.companies WHERE id = 66;

--Teorema de Heath 4FN

DROP TABLE limpieza.companies_base;

CREATE TABLE limpieza.companies_base AS
SELECT DISTINCT
    id,
    company_name,
    average_rating,
    total_reviews,
    available_jobs,
    total_benefits
FROM limpieza.companies_fn2;
SELECT * FROM limpieza.companies_base;

DROP TABLE limpieza.companies_descripciones;
CREATE TABLE limpieza.companies_descripciones AS
SELECT DISTINCT
    id,
    descripcion_id
FROM limpieza.companies_fn2
WHERE descripcion_id IS NOT NULL;

SELECT * FROM limpieza.companies_descripciones ORDER BY id;

CREATE TABLE limpieza.companies_highly_rated AS
SELECT DISTINCT
    id,
    highly_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE highly_rated_for_value IS NOT NULL;

SELECT * FROM limpieza.companies_highly_rated ORDER BY id;


CREATE TABLE limpieza.companies_critically_rated AS
SELECT DISTINCT
    id,
    critically_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE critically_rated_for_value IS NOT NULL;

SELECT * FROM limpieza.companies_critically_rated ORDER BY id;


--Tablas resultantes para el proyecto:

--companies_base
--companies_critically_rated
--companies_descripciones
--companies_highly_rated
--descriptions



