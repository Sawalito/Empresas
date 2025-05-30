-- Normalización de la tabla companies
-- Antes correr 01_limpieza.sql
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

--agregar comcolumna a companies llamada description_id
ALTER TABLE normalizacion.companies
ADD COLUMN description_id BIGINT;

--hacer la consulta correlacionada para llenar la columna description_id
UPDATE normalizacion.companies
SET description_id = (
    SELECT id
    FROM normalizacion.descriptions
    WHERE description = normalizacion.companies.description
);

ALTER TABLE normalizacion.companies DROP COLUMN description;
ALTER TABLE normalizacion.descriptions DROP COLUMN description;

-- Agrega la clave foránea
ALTER TABLE normalizacion.companies ADD CONSTRAINT fk_companies_description FOREIGN KEY (description_id) REFERENCES normalizacion.descriptions(id) ON DELETE SET NULL;


-- Enriquecimiento de la base de datos con location: latitud y longitud.
UPDATE normalizacion.descriptions
SET location = REGEXP_REPLACE(location, '\s*\+\d+\s*more', '', 'gi');

CREATE TABLE IF NOT EXISTS normalizacion.locations (
    id BIGSERIAL PRIMARY KEY,
    city VARCHAR(255),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);

SELECT*FROM normalizacion.locations;

INSERT INTO normalizacion.locations (city)
SELECT DISTINCT location FROM normalizacion.descriptions;

ALTER TABLE normalizacion.descriptions ADD COLUMN id_city BIGINT REFERENCES normalizacion.locations (id);

UPDATE normalizacion.descriptions
    SET id_city = (SELECT id
                   FROM normalizacion.locations
                   WHERE city = location)
WHERE id_city is NULL;

CREATE TABLE IF NOT EXISTS city_coordinates_temp (
  city TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION
);

UPDATE normalizacion.locations l
SET
  latitude = c.latitude,
  longitude = c.longitude
FROM city_coordinates_temp c
WHERE l.city=c.city;


-- Normalización de la tabla companies
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

-- por teorema de Heath
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
    total_benefits,
    description_id
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

SELECT * FROM normalizacion.locations;












DROP SCHEMA IF EXISTS final CASCADE;
CREATE SCHEMA IF NOT EXISTS final;

ALTER TABLE normalizacion.companies_4fn SET SCHEMA final;
ALTER TABLE normalizacion.descriptions SET SCHEMA final;
ALTER TABLE normalizacion.companies_highly_rated SET SCHEMA final;
ALTER TABLE normalizacion.companies_critically_rated SET SCHEMA final;
ALTER TABLE normalizacion.locations SET SCHEMA final;


















