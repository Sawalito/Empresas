-- Normalización de la tabla companies
-- Antes correr 01_create_schema.sql
--Ponerle un id a las nuevas columnas
ALTER TABLE limpieza.companies 
ADD COLUMN id INTEGER;

UPDATE limpieza.companies
SET id = sub.row_num
FROM (
  SELECT ctid, ROW_NUMBER() OVER (ORDER BY ctid) AS row_num
  FROM limpieza.companies
) sub
WHERE limpieza.companies.ctid = sub.ctid;

ALTER TABLE limpieza.companies
ALTER COLUMN id SET NOT NULL;

ALTER TABLE limpieza.companies
ADD CONSTRAINT pk_companies PRIMARY KEY (id);


DROP SEQUENCE IF EXISTS limpieza_companies_id_seq;
CREATE SEQUENCE limpieza_companies_id_seq;

SELECT setval('limpieza_companies_id_seq', (SELECT MAX(id) FROM limpieza.companies));

ALTER TABLE limpieza.companies
ALTER COLUMN id SET DEFAULT nextval('limpieza_companies_id_seq');

SELECT * FROM limpieza.companies
ORDER BY id;



DROP TABLE IF EXISTS limpieza.descriptions;
CREATE TABLE limpieza.descriptions (
    id BIGSERIAL PRIMARY KEY,
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


-- Actualiza la columna 'location' en la tabla 'descriptions'.
-- Extrae la última parte del atributo 'description' (separado por '|') como ubicación.
UPDATE limpieza.descriptions
SET location = TRIM(
    SPLIT_PART(description, '|', array_length(string_to_array(description, '|'), 1))
)
WHERE description IS NOT NULL;

--Comprobacion
SELECT * FROM  limpieza.descriptions ORDER BY id;

-- Agregar columna de descripcion
ALTER TABLE limpieza.companies
ADD COLUMN descripcion_id BIGINT REFERENCES limpieza.descriptions(id);

UPDATE limpieza.companies c
SET descripcion_id = d.id
FROM limpieza.descriptions d
WHERE c.description = d.description;

ALTER TABLE limpieza.descriptions 
DROP COLUMN dsescription;

SELECT * FROM limpieza.descriptions ORDER BY id;

SELECT * FROM limpieza.companies;

-- CUIDADO: Eliminar la columna description de la tabla companies
ALTER TABLE limpieza.companies 
DROP COLUMN description;
-- AQUI HAY UN TYPO?






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

-- Agregar clave primaria a limpieza.companies_fn1
ALTER TABLE limpieza.companies_fn1
ADD CONSTRAINT pk_companies_fn1 PRIMARY KEY (id, rating_value);



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

-- Agregar clave primaria a limpieza.companies_fn2
ALTER TABLE limpieza.companies_fn2
ADD CONSTRAINT pk_companies_fn2 PRIMARY KEY (id, highly_rated_for_value, critically_rated_for_value);




--Teorema de Heath 4FN

-- Crear tabla companies_base con clave primaria
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

-- Agregar clave primaria a companies_base
ALTER TABLE limpieza.companies_base
ADD CONSTRAINT pk_companies_base PRIMARY KEY (id);

-- Crear tabla companies_descripciones con clave primaria y foránea
DROP TABLE IF EXISTS limpieza.companies_descripciones;
CREATE TABLE limpieza.companies_descripciones AS
SELECT DISTINCT
    id,
    descripcion_id
FROM limpieza.companies_fn2
WHERE descripcion_id IS NOT NULL;

-- Agregar clave primaria y clave foránea a companies_descripciones
ALTER TABLE limpieza.companies_descripciones
ADD CONSTRAINT pk_companies_descripciones PRIMARY KEY (id, descripcion_id),
ADD CONSTRAINT fk_companies_descripciones FOREIGN KEY (descripcion_id) REFERENCES limpieza.descriptions (id);

-- Crear tabla companies_highly_rated con clave primaria
DROP TABLE IF EXISTS limpieza.companies_highly_rated;
CREATE TABLE limpieza.companies_highly_rated AS
SELECT DISTINCT
    id,
    highly_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE highly_rated_for_value IS NOT NULL;

-- Agregar clave primaria a companies_highly_rated
ALTER TABLE limpieza.companies_highly_rated
ADD CONSTRAINT pk_companies_highly_rated PRIMARY KEY (id, rating_value);

-- Crear tabla companies_critically_rated con clave primaria
DROP TABLE IF EXISTS limpieza.companies_critically_rated;
CREATE TABLE limpieza.companies_critically_rated AS
SELECT DISTINCT
    id,
    critically_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE critically_rated_for_value IS NOT NULL;

-- Agregar clave primaria a companies_critically_rated
ALTER TABLE limpieza.companies_critically_rated
ADD CONSTRAINT pk_companies_critically_rated PRIMARY KEY (id, rating_value);

-- Verificar las tablas
SELECT * FROM limpieza.companies_base;
SELECT * FROM limpieza.companies_descripciones ORDER BY id;
SELECT * FROM limpieza.companies_highly_rated ORDER BY id;
SELECT * FROM limpieza.companies_critically_rated ORDER BY id;



CREATE SCHEMA final;

ALTER TABLE limpieza.companies_base SET SCHEMA final;
ALTER TABLE limpieza.companies_descripciones SET SCHEMA final;
ALTER TABLE limpieza.companies_highly_rated SET SCHEMA final;
ALTER TABLE limpieza.companies_critically_rated SET SCHEMA final;



