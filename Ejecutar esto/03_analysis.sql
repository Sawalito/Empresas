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


--Aspectos más mencionados como altamente valorados o criticados
SELECT aspect,
    COUNT(*) FILTER (WHERE highly_rated_for ILIKE '%' || aspect || '%') AS highly_rated_count,
    COUNT(*) FILTER (WHERE critically_rated_for ILIKE '%' || aspect || '%') AS critically_rated_count
FROM (
  VALUES
    ('Company Culture'),
    ('Job Security'),
    ('Promotions / Appraisal'),
    ('Salary & Benefits'),
    ('Skill Development / Learning'),
    ('Work Life Balance'),
    ('Work Satisfaction')
) AS a(aspect)
CROSS JOIN final.companies_4fn
GROUP BY aspect
ORDER BY highly_rated_count DESC, critically_rated_count DESC;


--Covarianza entre Salario Promedio y Calificación
SELECT
  ROUND(COVAR_SAMP(average_salary, average_rating)::numeric, 2) AS covarianza_salario_rating
FROM final.companies_4fn
WHERE average_salary IS NOT NULL AND average_rating IS NOT NULL;

-- Correlación entre Número de Beneficios y Calificación
SELECT
  ROUND(CORR(total_benefits::FLOAT, average_rating)::numeric, 3) AS correlacion_beneficios_rating
FROM final.companies_4fn
WHERE total_benefits IS NOT NULL AND average_rating IS NOT NULL;



-- Promedio de calificación agrupado por cada aspecto altamente valorado
SELECT
    chr.rating_value AS aspect,
    ROUND(AVG(c.average_rating)::NUMERIC, 3) AS avg_rating,
    COUNT(*) AS num_empresas
FROM final.companies_highly_rated chr
JOIN final.companies_4fn c ON chr.id_company = c.id
WHERE chr.rating_value IS NOT NULL AND c.average_rating IS NOT NULL
GROUP BY chr.rating_value
ORDER BY avg_rating DESC;

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