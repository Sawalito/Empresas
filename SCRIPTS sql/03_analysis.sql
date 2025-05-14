--Analisis de datos

--Análisis de la distribución de calificaciones promedio (average_rating)
SELECT
    average_rating,
    COUNT(*) AS num_empresas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM final.companies_4fn
GROUP BY average_rating
ORDER BY average_rating DESC;

--Estadísticas descriptivas de las calificaciones promedio
SELECT ROUND(AVG(average_rating)::numeric, 3)                                          AS media_rating,
       ROUND(VAR_SAMP(average_rating)::numeric, 3)                                     AS varianza_rating,
       ROUND(STDDEV_SAMP(average_rating)::numeric, 3)                                  AS desviacion_rating,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_rating)                     AS mediana,
       ---moda
       (SELECT average_rating
        FROM (SELECT average_rating, COUNT(*) AS freq
              FROM final.companies_4fn
              GROUP BY average_rating
              ORDER BY freq DESC, average_rating
              LIMIT 1))                                                                AS moda
FROM final.companies_4fn;

-- Distribuvion de salarios promedio (average_salary)
SELECT
    total_benefits,
    COUNT(*) AS num_empresas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM final.companies_4fn
GROUP BY total_benefits
ORDER BY total_benefits DESC;

SELECT
    ROUND(AVG(average_salary)::numeric, 3) AS media,
    ROUND(VAR_SAMP(average_salary)::numeric, 3) AS varianza,
    ROUND(STDDEV_SAMP(average_salary)::numeric, 3) AS desviacion,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_salary) AS mediana,
    ---moda
    (SELECT average_salary
    FROM (SELECT average_salary, COUNT(*) AS freq
        FROM final.companies_4fn
        GROUP BY average_salary
        ORDER BY freq DESC, average_salary
        LIMIT 1)) AS moda
FROM final.companies_4fn;

--Covarianza y correlacion entre rating y salario promedio
SELECT
    ROUND(COVAR_SAMP(average_rating, average_salary)::numeric, 2) AS covarianza,
    ROUND(CORR(average_rating, average_salary)::numeric, 3) AS correlacion
FROM final.companies_4fn
WHERE average_salary IS NOT NULL AND average_rating IS NOT NULL;

--Covarianza y correlacion entre rating y Número de beneficios (total_benefits)
SELECT
    ROUND(COVAR_SAMP(average_rating, total_benefits)::numeric, 2) AS covarianza,
    ROUND(CORR(average_rating, total_benefits)::numeric, 3) AS correlacion
FROM final.companies_4fn
WHERE total_benefits IS NOT NULL AND average_rating IS NOT NULL;

-- prueba que da covarianza = varianza y correl = 1
SELECT
    ROUND(COVAR_SAMP(average_rating, average_rating)::numeric, 2) AS covarianza,
    ROUND(CORR(average_rating, average_rating)::numeric, 3) AS correlacion
FROM final.companies_4fn
WHERE average_rating IS NOT NULL AND average_rating IS NOT NULL;

--Covarianza y correlacion entre rating y total_reviews
SELECT
    ROUND(COVAR_SAMP(average_rating, total_reviews)::numeric, 2) AS covarianza,
    ROUND(CORR(average_rating, total_reviews)::numeric, 3) AS correlacion
FROM final.companies_4fn
WHERE total_reviews IS NOT NULL AND average_rating IS NOT NULL;

-- Promedio de rating por industria
SELECT
    d.industry,
    ROUND(AVG(c.average_rating)::numeric, 3) AS avg_rating,
    COUNT(*) AS num_empresas
FROM final.companies_4fn c
JOIN final.companies_description cd ON c.id = cd.id_companies
JOIN final.descriptions d ON cd.id_description = d.id
WHERE d.industry IS NOT NULL
GROUP BY d.industry
ORDER BY count(*) DESC
LIMIT 10;

-- Promedio de rating por aspecto altamente valorado (highly rating value)
SELECT
    chr.rating_value AS aspect,
    ROUND(AVG(c.average_rating)::numeric, 3) AS avg_rating,
    COUNT(*) AS num_empresas
FROM final.companies_highly_rated chr
JOIN final.companies_4fn c ON chr.id_company = c.id
WHERE chr.rating_value IS NOT NULL AND c.average_rating IS NOT NULL
GROUP BY chr.rating_value
ORDER BY avg_rating DESC
LIMIT 10;


--Beneficios Más Comunes en Empresas Mejor Calificadas
SELECT
  ch.rating_value,
  COUNT(*) AS frecuencia
FROM final.companies_highly_rated ch
JOIN final.companies_4fn c ON ch.id_company = c.id
WHERE c.average_rating >= 4
GROUP BY ch.rating_value
ORDER BY frecuencia DESC
LIMIT 10;


--Top 5 empresas con mejor salario promedio
SELECT company_name, average_salary
FROM final.companies_4fn
WHERE average_salary IS NOT NULL
ORDER BY average_salary DESC
LIMIT 5;


--Empresas con Mayor Varianza en Salarios por Industria
SELECT
  d.industry,
  ROUND(VAR_SAMP(c.average_salary), 2) AS varianza_salario,
  COUNT(*) AS empresas
FROM final.companies_4fn c
JOIN final.companies_description cd ON c.id = cd.id_companies
JOIN final.descriptions d ON cd.id_description = d.id
WHERE c.average_salary IS NOT NULL AND d.industry IS NOT NULL
GROUP BY d.industry
ORDER BY varianza_salario DESC
LIMIT 10;

--Relación entre número de empleos disponibles y salario
SELECT company_name,
    average_salary,
    available_jobs
FROM final.companies_4fn
WHERE average_salary IS NOT NULL AND available_jobs IS NOT NULL
ORDER BY available_jobs DESC
LIMIT 10;

--Relación entre entrevistas y trabajos disponibles (indicador de demanda)
SELECT company_name,
    total_interviews,
    available_jobs,
    ROUND(CAST(total_interviews AS NUMERIC) / NULLIF(available_jobs, 0), 2) AS interviews_per_job
FROM final.companies_4fn
WHERE total_interviews IS NOT NULL AND available_jobs IS NOT NULL
ORDER BY interviews_per_job DESC
LIMIT 10;

--Análisis de Críticas Más Frecuentes
SELECT
  cc.value AS critica,
  COUNT(*) AS frecuencia
FROM final.companies_critically_rated cc
JOIN final.companies_4fn c ON cc.id_company = c.id
WHERE c.average_rating < 3
GROUP BY cc.value
ORDER BY frecuencia DESC
LIMIT 10;


--Empresas con Mayor Diferencia entre Salario y Calificación
SELECT
  company_name,
  average_salary,
  average_rating,
  (average_salary - AVG(average_salary) OVER()) AS diferencia_salario,
  (average_rating - AVG(average_rating) OVER()) AS diferencia_rating
FROM final.companies_4fn
WHERE average_salary IS NOT NULL AND average_rating IS NOT NULL
ORDER BY diferencia_salario DESC, diferencia_rating ASC
LIMIT 10;