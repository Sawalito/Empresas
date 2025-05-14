--limpieza de datos
DROP SCHEMA IF EXISTS limpieza CASCADE;

CREATE SCHEMA IF NOT EXISTS limpieza;

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

-- Elimina filas duplicadas de la tabla limpieza.companies, conservando solo una fila por cada combinación única de los campos especificados.
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
