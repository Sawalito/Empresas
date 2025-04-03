# Proyecto Bases de Datos - Entrega 2

**Integrantes:**
- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

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

### Importar datos desde un archivo CSV
> **IMPORTANTE:** Cambiar la dirección del archivo antes de ejecutar el comando.
```sql
SET CLIENT_ENCODING TO 'UTF8';
\copy companies (company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits) 
FROM 'C:/Users/Light 16 Pro/Downloads/companies.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

## Limpieza y conversión de datos

### Conversión de valores con sufijo "k" a números enteros
```sql
UPDATE companies SET total_reviews = (
  CASE
    WHEN total_reviews ILIKE '%k' THEN
      (CAST(REPLACE(LOWER(total_reviews), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
    WHEN total_reviews = '--' OR total_reviews IS NULL THEN NULL
    ELSE total_reviews
  END
);

UPDATE companies SET average_salary = (
  CASE
    WHEN average_salary ILIKE '%k' THEN
      (CAST(REPLACE(LOWER(average_salary), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
    WHEN average_salary = '--' OR average_salary IS NULL THEN NULL
    ELSE average_salary
  END
);
```
(Se repiten los mismos pasos para `total_interviews`, `available_jobs` y `total_benefits`)

### Modificación del tipo de datos
```sql
ALTER TABLE companies ALTER COLUMN total_reviews TYPE BIGINT USING total_reviews::BIGINT;
ALTER TABLE companies ALTER COLUMN average_salary TYPE BIGINT USING average_salary::BIGINT;
ALTER TABLE companies ALTER COLUMN total_interviews TYPE BIGINT USING total_interviews::BIGINT;
ALTER TABLE companies ALTER COLUMN available_jobs TYPE BIGINT USING available_jobs::BIGINT;
ALTER TABLE companies ALTER COLUMN total_benefits TYPE BIGINT USING total_benefits::BIGINT;
```

## Análisis de datos

### Detección y eliminación de duplicados
```sql
SELECT COUNT(DISTINCT(company_name)) FROM companies;

SELECT *, COUNT(*) AS count
FROM companies
GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
HAVING COUNT(*) > 1;

DELETE FROM companies
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
);
```

### Estadísticas de valores numéricos
```sql
SELECT
  MIN(average_rating) AS min_rating,
  MAX(average_rating) AS max_rating,
  AVG(average_rating) AS avg_rating,

  MIN(total_reviews) AS min_reviews,
  MAX(total_reviews) AS max_reviews,
  AVG(total_reviews) AS avg_reviews,

  MIN(average_salary) AS min_salary,
  MAX(average_salary) AS max_salary,
  AVG(average_salary) AS avg_salary,

  MIN(total_interviews) AS min_interviews,
  MAX(total_interviews) AS max_interviews,
  AVG(total_interviews) AS avg_interviews,

  MIN(available_jobs) AS min_jobs,
  MAX(available_jobs) AS max_jobs,
  AVG(available_jobs) AS avg_jobs,

  MIN(total_benefits) AS min_benefits,
  MAX(total_benefits) AS max_benefits,
  AVG(total_benefits) AS avg_benefits
FROM companies;
```

### Conteo de valores nulos
```sql
SELECT
  COUNT(*) FILTER (WHERE company_name IS NULL) AS company_name_nulls,
  COUNT(*) FILTER (WHERE description IS NULL) AS description_nulls,
  COUNT(*) FILTER (WHERE average_rating IS NULL) AS average_rating_nulls,
  COUNT(*) FILTER (WHERE highly_rated_for IS NULL) AS highly_rated_for_nulls,
  COUNT(*) FILTER (WHERE critically_rated_for IS NULL) AS critically_rated_for_nulls,
  COUNT(*) FILTER (WHERE total_reviews IS NULL) AS total_reviews_nulls,
  COUNT(*) FILTER (WHERE average_salary IS NULL) AS average_salary_nulls,
  COUNT(*) FILTER (WHERE total_interviews IS NULL) AS total_interviews_nulls,
  COUNT(*) FILTER (WHERE available_jobs IS NULL) AS available_jobs_nulls,
  COUNT(*) FILTER (WHERE total_benefits IS NULL) AS total_benefits_nulls
FROM companies;
```

## Tablas y Representaciones Gráficas

### Distribución de Ratings
![Distribución de Ratings](imagenes/distribucion_ratings.png)

### Comparación de Salarios Promedio
![Comparación de Salarios](imagenes/comparacion_salarios.png)

### Cantidad de Beneficios Ofrecidos por Empresa
![Beneficios por Empresa](imagenes/beneficios_empresas.png)

## Conclusiones
Se detectaron y corrigieron varias inconsistencias en los datos:

1. **Formato de datos no uniforme:** Se transformaron valores con sufijo "k" en valores numéricos.
2. **Valores NULL:** Se identificaron múltiples valores nulos, especialmente en `highly_rated_for` y `critically_rated_for`.
3. **Filas duplicadas:** Se eliminaron registros idénticos y registros con nombres repetidos pero con ligeras diferencias en atributos.
4. **Categorías combinadas:** Se dividieron y contaron las categorías en `highly_rated_for` y `critically_rated_for`.

Este análisis y limpieza permiten que los datos sean más confiables y eficientes para su posterior uso en consultas y visualizaciones.

---
**Fin del documento**
