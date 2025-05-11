# Entrega 4 del proyecto de Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

## Analisis de datos a traves de consultas SQL y creacion de atributos analiticos.

### Evaluar las opiniones de los empleados sobre sus empresas
#### Análisis de la distribución de calificaciones promedio (average_rating)
Esta consulta muestra la cantidad de empresas para cada valor de calificación promedio, así como el porcentaje que representa cada grupo respecto al total. Permite visualizar la concentración de empresas en ciertos rangos de calificación.
```sql
SELECT 
    average_rating,
    COUNT(*) AS num_empresas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM final.companies_4fn
GROUP BY average_rating
ORDER BY average_rating DESC;
```
| average\_rating | num\_empresas | porcentaje |
| :--- | :--- | :--- |
| 5 | 11 | 0.12 |
| 4.9 | 24 | 0.26 |
| 4.8 | 48 | 0.51 |
| 4.7 | 65 | 0.69 |
| 4.6 | 127 | 1.36 |
| 4.5 | 198 | 2.12 |
| 4.4 | 363 | 3.88 |
| 4.3 | 609 | 6.51 |
| 4.2 | 855 | 9.14 |
| 4.1 | 1108 | 11.84 |
| 4 | 1112 | 11.89 |
| 3.9 | 1051 | 11.23 |
| 3.8 | 913 | 9.76 |
| 3.7 | 718 | 7.68 |
| 3.6 | 597 | 6.38 |
| 3.5 | 469 | 5.01 |
| 3.4 | 308 | 3.29 |
| 3.3 | 246 | 2.63 |
| 3.2 | 181 | 1.93 |
| 3.1 | 124 | 1.33 |
| 3 | 63 | 0.67 |
| 2.9 | 50 | 0.53 |
| 2.8 | 34 | 0.36 |
| 2.7 | 23 | 0.25 |
| 2.6 | 18 | 0.19 |
| 2.5 | 11 | 0.12 |
| 2.4 | 9 | 0.1 |
| 2.3 | 6 | 0.06 |
| 2.2 | 4 | 0.04 |
| 2.1 | 6 | 0.06 |
| 2 | 1 | 0.01 |
| 1.9 | 1 | 0.01 |
| 1.6 | 1 | 0.01 |
| 1.3 | 1 | 0.01 |

Estadísticas descriptivas de las calificaciones promedio
¿Las empresas tienen calificaciones muy dispersas o la mayoría se concentra en un rango? 
Se presentan varias medidas estadísticas para analizar la distribución de las calificaciones promedio.
```sql
SELECT
    ROUND(AVG(average_rating)::numeric, 3) AS media_rating,
    ROUND(VAR_SAMP(average_rating)::numeric, 3) AS varianza_rating,
    ROUND(STDDEV_SAMP(average_rating)::numeric, 3) AS desviacion_rating,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_rating) AS mediana,
    ---moda
    (SELECT average_rating
    FROM (SELECT average_rating, COUNT(*) AS freq
        FROM final.companies_4fn
        GROUP BY average_rating
        ORDER BY freq DESC, average_rating
        LIMIT 1)) AS moda
FROM final.companies_4fn;
```
| media\_rating | varianza\_rating | desviacion\_rating | mediana | moda |
| :--- | :--- | :--- | :--- | :--- |
| 3.896 | 0.148 | 0.385 | 3.9 | 4 |


- **Media**: Promedio de las calificaciones.
- **Varianza** y **Desviación estándar**: Miden la dispersión de las calificaciones.
- **Mediana**: Valor central de la distribución.
- **Moda**: Calificación más frecuente.
- **Asimetría**: Indica si la distribución está sesgada a la izquierda o derecha (negativa: sesgo a la izquierda). No se pudo calcular
- **Curtosis**: Mide la "altitud" de la distribución (mayor a 0: más concentrada en el centro y colas). No se pudo calcular

Una varianza y coeficiente de variación bajos indican que la mayoría de las empresas tienen calificaciones similares. La asimetría negativa sugiere que hay más empresas con calificaciones altas, y la curtosis cercana a 0 indica una distribución similar a la normal.



### Identificar los aspectos más valorados y criticados en las compañías

#### Aspectos más mencionados como altamente valorados o criticados
```sql
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
```
| aspect | highly\_rated\_count | critically\_rated\_count |
| :--- | :--- | :--- |
| Job Security | 4560 | 361 |
| Company Culture | 4194 | 190 |
| Work Life Balance | 3795 | 146 |
| Skill Development / Learning | 3255 | 168 |
| Promotions / Appraisal | 3011 | 2414 |
| Salary & Benefits | 2764 | 884 |
| Work Satisfaction | 2252 | 261 |


### Analizar factores que influyen en la calificación de una empresa

#### Relación entre salario promedio y calificación
Covarianza entre Salario Promedio y Calificación  
¿Las empresas mejor calificadas tienden a pagar más?

```sql
SELECT
    ROUND(COVAR_SAMP(average_salary, average_rating)::numeric, 2) AS covarianza_salario_rating
FROM final.companies_4fn
WHERE average_salary IS NOT NULL AND average_rating IS NOT NULL;
```

| covarianza\_salario\_rating |
| :--- |
| -5.5 |

Una covarianza negativa sugiere que, en este conjunto de datos, a mayor salario promedio, menor calificación promedio de la empresa.  
Esto resulta contraintuitivo, ya que se esperaría una relación positiva entre salario y satisfacción. Algunas posibles razones para este resultado pueden ser:

- Empresas con salarios altos pueden tener ambientes laborales más exigentes o estresantes, lo que afecta la percepción de los empleados.
- Las empresas con mejores calificaciones podrían ofrecer otros beneficios no monetarios (como cultura, balance vida-trabajo) que influyen más en la satisfacción.
- Puede haber sesgo en los datos o diferencias sectoriales que afectan la relación entre salario y calificación.
- La muestra puede estar dominada por empresas de sectores donde el salario no es el principal factor de satisfacción.

#### Correlación entre Número de Beneficios y Calificación
¿Ofrecer más beneficios se asocia con mejores calificaciones?
```sql
SELECT
    ROUND(CORR(total_benefits::FLOAT, average_rating)::numeric, 3) AS correlacion_beneficios_rating
FROM final.companies_4fn
WHERE total_benefits IS NOT NULL AND average_rating IS NOT NULL;
```
| correlacion\_beneficios\_rating |
| :--- |
| 0.036 |

El valor de 0.036 indica una correlación positiva muy débil entre el número de beneficios ofrecidos y la calificación promedio de las empresas. En la práctica, esto significa que aumentar la cantidad de beneficios no se traduce necesariamente en una mejor percepción por parte de los empleados.

Una correlación cercana a 1 implica una relación de proporcionalidad fuerte; cercana a 0, indica independencia o ausencia de relación; y cercana a -1, una relación inversa .
En este caso, la correlación es casi nula, igual algo contraintuitivo, lo que sugiere que otros factores (como cultura organizacional, balance vida-trabajo o salario) pueden tener mayor peso en la satisfacción de los empleados.
Es posible que la calidad o relevancia de los beneficios importe más que la cantidad, o que existan diferencias sectoriales o de expectativas que diluyan el impacto de los beneficios en la calificación general.


#### Promedio de calificación agrupado por cada aspecto altamente valorado
```sql
SELECT
    chr.rating_value AS aspect,
    ROUND(AVG(c.average_rating)::NUMERIC, 3) AS avg_rating,
    COUNT(*) AS num_empresas
FROM final.companies_highly_rated chr
JOIN final.companies_4fn c ON chr.id_company = c.id
WHERE chr.rating_value IS NOT NULL AND c.average_rating IS NOT NULL
GROUP BY chr.rating_value
ORDER BY avg_rating DESC;
```
| aspect | avg\_rating | num\_empresas |
| :--- | :--- | :--- |
| Skill Development / Learning | 4.059 | 3255 |
| Work Life Balance | 4.049 | 3795 |
| Company Culture | 4.015 | 4194 |
| Job Security | 3.899 | 4560 |
| Work Satisfaction | 3.862 | 2252 |
| Salary & Benefits | 3.771 | 2764 |
| Promotions / Appraisal | 3.572 | 3011 |

#### Beneficios Más Comunes en Empresas Mejor Calificadas
¿Qué beneficios aparecen más en empresas con calificación superior a 4?
```sql
SELECT 
    ch.rating_value,
    COUNT(*) AS frecuencia
FROM final.companies_highly_rated ch
JOIN final.companies_4fn c ON ch.id_company = c.id
WHERE c.average_rating >= 4
GROUP BY ch.rating_value
ORDER BY frecuencia DESC
LIMIT 10;
```
| rating\_value | frecuencia |
| :--- | :--- |
| Company Culture | 2832 |
| Work Life Balance | 2690 |
| Job Security | 2400 |
| Skill Development / Learning | 2303 |
| Work Satisfaction | 1085 |
| Salary & Benefits | 930 |
| Promotions / Appraisal | 216 |

Estos son los beneficios más comunes en empresas con calificación promedio superior a 4.
Estos beneficios pueden ser factores clave para una buena percepción de la empresa.

### Analizar salarios y oportunidades laborales entre empresas
#### Top 5 empresas con mejor salario promedio
```sql
SELECT company_name, average_salary
FROM final.companies_4fn
WHERE average_salary IS NOT NULL
ORDER BY average_salary DESC
LIMIT 5;
```
| company\_name | average\_salary |
| :--- | :--- |
| TCS | 856900 |
| Accenture | 584600 |
| Cognizant | 561500 |
| Infosys | 462000 |
| Wipro | 427400 |

#### Empresas con Mayor Varianza en Salarios por Industria
¿En qué industrias hay más desigualdad salarial?
```sql
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
```
| industry | varianza\_salario | empresas |
| :--- | :--- | :--- |
| 51-200 Employees \(Global\) | null | 1 |
| 79 years old | null | 1 |
| Conglomerate | null | 1 |
| Forbes Global 2000 | null | 1 |
| 13 years old | null | 1 |
| 17 years old | null | 1 |
| 201-500 Employees \(Global\) | null | 1 |
| 2024 years old | null | 1 |
| Events | null | 1 |
| Fortune India 500 | null | 1 |
Industrias con mayor varianza pueden tener tanto empresas que pagan muy bien como otras que pagan poco.

#### Relación entre número de empleos disponibles y salario
```sql
SELECT company_name,
    average_salary,
    available_jobs
FROM final.companies_4fn
WHERE average_salary IS NOT NULL AND available_jobs IS NOT NULL
ORDER BY available_jobs DESC
LIMIT 10;
```
| company\_name | average\_salary | available\_jobs |
| :--- | :--- | :--- |
| Accenture | 584600 | 9900 |
| IBM | 221500 | 4000 |
| Diverse Lynx | 1500 | 3600 |
| Randstad | 13200 | 2300 |
| Multiplier Brand Solutions | 722 | 2300 |
| Ernst & Young | 124000 | 1800 |
| Skillventory | 442 | 1700 |
| Antal International | 506 | 1500 |
| PwC | 82700 | 1200 |
| Zyoin | 670 | 1200 |


### Estudiar tendencias en el mercado laboral

#### Relación entre entrevistas y trabajos disponibles (indicador de demanda)
```sql
SELECT company_name,
    total_interviews,
    available_jobs,
    ROUND(CAST(total_interviews AS NUMERIC) / NULLIF(available_jobs, 0), 2) AS interviews_per_job
FROM final.companies_4fn
WHERE total_interviews IS NOT NULL AND available_jobs IS NOT NULL
ORDER BY interviews_per_job DESC
LIMIT 10;
```
| company\_name | total\_interviews | available\_jobs | interviews\_per\_job |
| :--- | :--- | :--- | :--- |
| Google | 408 | 1 | 408 |
| HCL Group | 282 | 1 | 282 |
| TCS iON | 210 | 1 | 210 |
| Nagarjuna Construction Company | 208 | 1 | 208 |
| JBM Group | 185 | 1 | 185 |
| Bank of America | 151 | 1 | 151 |
| Adani Power | 141 | 1 | 141 |
| ABB Group | 128 | 1 | 128 |
| Reliance SMSL | 127 | 1 | 127 |
| Ceat Tyres | 115 | 1 | 115 |

### Análisis de Críticas Más Frecuentes
¿Qué aspectos son más criticados en las empresas peor calificadas?
```sql
SELECT
    cc.value AS critica,
    COUNT(*) AS frecuencia
FROM final.companies_critically_rated cc
JOIN final.companies_4fn c ON cc.id_company = c.id
WHERE c.average_rating < 3
GROUP BY cc.value
ORDER BY frecuencia DESC
LIMIT 10;
```
| critica | frecuencia |
| :--- | :--- |
| null | 163 |
| Work Satisfaction | 2 |
| Company Culture | 1 |
| Job Security | 1 |
| Promotions / Appraisal | 1 |
| Skill Development / Learning | 1 |

### Empresas con Mayor Diferencia entre Salario y Calificación
¿Hay empresas que pagan mucho pero tienen mala calificación (o viceversa)?
```sql
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
```
| company\_name | average\_salary | average\_rating | diferencia\_salario | diferencia\_rating |
| :--- | :--- | :--- | :--- | :--- |
| TCS | 856900 | 3.8 | 854397.083716454613493 | -0.09609750882068724 |
| Accenture | 584600 | 4 | 582097.083716454613493 | 0.10390249117931294 |
| Cognizant | 561500 | 3.9 | 558997.083716454613493 | 0.0039024911793128503 |
| Infosys | 462000 | 3.8 | 459497.083716454613493 | -0.09609750882068724 |
| Wipro | 427400 | 3.8 | 424897.083716454613493 | -0.09609750882068724 |
| Capgemini | 414400 | 3.9 | 411897.083716454613493 | 0.0039024911793128503 |
| HCLTech | 293400 | 3.7 | 290897.083716454613493 | -0.19609750882068688 |
| Tech Mahindra | 251300 | 3.7 | 248797.083716454613493 | -0.19609750882068688 |
| IBM | 221500 | 4.1 | 218997.083716454613493 | 0.20390249117931258 |
| Genpact | 190400 | 3.9 | 187897.083716454613493 | 0.0039024911793128503 |
