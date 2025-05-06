# Entrega 4 del proyecto de Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

## Consultas SQL

### 1. Evaluar las opiniones de los empleados sobre sus empresas
 
#### Cantidad de empresas agrupadas por su calificación promedio (average_rating). 
Se filtran las calificaciones promedio para que solo se incluyan valores entre 1 y 5, y se ordenan los resultados de forma descendente 
según la calificación promedio. Esto permite analizar la distribución de empresas según sus calificaciones.

```sql
SELECT average_rating,
    COUNT(*) AS count_companies
FROM limpieza.companies
WHERE average_rating IN (1, 2, 3, 4, 5)
GROUP BY average_rating
ORDER BY average_rating DESC;
```
```plaintext
average_rating | count_companies
---------------+-----------------
              5 |              11
              4 |            1112
              3 |              63
              2 |               1
```

#### Análisis de la varianza en las calificaciones de las empresas con promedio perfecto

En lugar de simplemente listar las empresas con una calificación promedio de 5, es más útil analizar la varianza en las calificaciones individuales de estas empresas. Esto puede revelar si las calificaciones perfectas son consistentes o si están influenciadas por valores atípicos.

```sql
SELECT company_name,
    VARIANCE(rating) AS rating_variance,
    COUNT(*) AS total_reviews
FROM limpieza.reviews
WHERE company_name IN (
    SELECT company_name
    FROM limpieza.companies
    WHERE average_rating = 5
)
GROUP BY company_name
ORDER BY rating_variance ASC;
```

```plaintext
                  company_name                  | rating_variance | total_reviews
------------------------------------------------+-----------------+---------------
 Lavender Technology                            |           0.000 |           508
 InternEzy                                      |           0.000 |           414
 Stirring Minds                                 |           0.000 |           278
 Matrimonialsindia                              |           0.000 |           171
 Dr.SNS Rajalakshmi College Of Arts and Science |           0.000 |           221
```

Este análisis muestra que todas las empresas con calificación promedio de 5 tienen una varianza de 0, lo que indica que todas las calificaciones individuales son consistentemente perfectas. Si se detectara una varianza mayor a 0, se podría investigar más a fondo para identificar posibles anomalías o patrones en las calificaciones.


#### Opiniones promedio de empleados por empresa (con función de ventana)
```sql
SELECT company_name,
    average_rating,
    RANK() OVER (ORDER BY average_rating DESC) AS rating_rank
FROM limpieza.companies
WHERE average_rating IS NOT NULL
LIMIT 10;
```markdown

```

### 2. Identificar los aspectos más valorados y criticados en las compañías

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
CROSS JOIN limpieza.companies
GROUP BY aspect
ORDER BY highly_rated_count DESC, critically_rated_count DESC;
```
```plaintext
aspect                        | highly_rated_count | critically_rated_count
------------------------------+--------------------+------------------------
Job Security                 |               4560 |                    361
Company Culture              |               4194 |                    190
Work Life Balance            |               3795 |                    146
Skill Development / Learning |               3255 |                    168
Promotions / Appraisal       |               3011 |                   2414
Salary & Benefits            |               2764 |                    884
Work Satisfaction            |               2252 |                    261
```

### 3. Analizar factores que influyen en la calificación de una empresa

#### Relación entre salario promedio y calificación
```sql
SELECT company_name,
    average_salary,
    average_rating,
    total_reviews
FROM limpieza.companies
WHERE average_salary IS NOT NULL AND average_rating IS NOT NULL
ORDER BY average_rating DESC
LIMIT 10;
```
```plaintext
company_name                  | average_salary | average_rating | total_reviews
------------------------------------------------+----------------+----------------+---------------
IBC Techno                                     |              4 |              5 |            95
Teqtous Inc                                    |              9 |              5 |            83
Dr.SNS Rajalakshmi College Of Arts and Science |             20 |              5 |           221
Matrimonialsindia                              |            114 |              5 |           171
Deejos Engineers & Contractors                 |             28 |              5 |           151
Royal Migration Solutions                      |              2 |              5 |           341
Stirring Minds                                 |             31 |              5 |           278
InternEzy                                      |              3 |              5 |           414
Lavender Technology                            |              2 |              5 |           508
Jayasree Techno Solutions                      |             13 |              5 |            83
```

#### Promedio de calificación agrupado por un aspecto altamente valorado
```sql
SELECT TRIM(regexp_split_to_table(highly_rated_for, ',')) AS aspect,
    AVG(average_rating) AS avg_rating,
    COUNT(*) AS num_empresas
FROM limpieza.companies
WHERE highly_rated_for IS NOT NULL AND average_rating IS NOT NULL
GROUP BY aspect
ORDER BY avg_rating DESC;
```
```plaintext
aspect                        |     avg_rating     | num_empresas
------------------------------+--------------------+--------------
Skill Development / Learning  |  4.059047619047634 |         3255
Work Life Balance             |  4.048932806324115 |         3795
Company Culture               |  4.014520743919898 |         4194
Job Security                  |  3.8991885964912303 |         4560
Work Satisfaction             |  3.862166962699821 |         2252
Salary & Benefits             |  3.770767004341543 |         2764
Promotions / Appraisal        |  3.5721687147127192 |         3011
```

### 4. Comparar salarios y oportunidades laborales entre empresas

#### Top 5 empresas con mejor salario promedio
```sql
SELECT company_name, average_salary
FROM limpieza.companies
WHERE average_salary IS NOT NULL
ORDER BY average_salary DESC
LIMIT 5;
```
```plaintext
company_name | average_salary
--------------+----------------
 TCS          |         856900
 Accenture    |         584600
 Cognizant    |         561500
 Infosys      |         462000
 Wipro        |         427400
```
#### Relación entre número de empleos disponibles y salario
```sql
SELECT company_name,
    average_salary,
    available_jobs
FROM limpieza.companies
WHERE average_salary IS NOT NULL AND available_jobs IS NOT NULL
ORDER BY available_jobs DESC
LIMIT 10;
```
```plaintext
company_name        | average_salary | available_jobs
----------------------------+----------------+----------------
 Accenture                  |         584600 |           9900
 IBM                        |         221500 |           4000
 Diverse Lynx               |           1500 |           3600
 Randstad                   |          13200 |           2300
 Multiplier Brand Solutions |            722 |           2300
 Ernst & Young              |         124000 |           1800
 Skillventory               |            442 |           1700
 Antal International        |            506 |           1500
 PwC                        |          82700 |           1200
 Zyoin                      |            670 |           1200
```

### 5. Estudiar tendencias en el mercado laboral

#### Relación entre entrevistas y trabajos disponibles (indicador de demanda)
```sql
SELECT company_name,
    total_interviews,
    available_jobs,
    ROUND(CAST(total_interviews AS NUMERIC) / NULLIF(available_jobs, 0), 2) AS interviews_per_job
FROM limpieza.companies
WHERE total_interviews IS NOT NULL AND available_jobs IS NOT NULL
ORDER BY interviews_per_job DESC
LIMIT 10;
```
```plaintext
company_name          | total_interviews | available_jobs | interviews_per_job
--------------------------------+------------------+----------------+--------------------
 Google                         |              408 |              1 |             408.00
 HCL Group                      |              282 |              1 |             282.00
 TCS iON                        |              210 |              1 |             210.00
 Nagarjuna Construction Company |              208 |              1 |             208.00
 JBM Group                      |              185 |              1 |             185.00
 Bank of America                |              151 |              1 |             151.00
 Adani Power                    |              141 |              1 |             141.00
 ABB Group                      |              128 |              1 |             128.00
 Reliance SMSL                  |              127 |              1 |             127.00
 Ceat Tyres                     |              115 |              1 |             115.00
```

#### Promedio de beneficios ofrecidos por sector más valorado
```sql
SELECT TRIM(regexp_split_to_table(highly_rated_for, ',')) AS aspect,
    AVG(total_benefits) AS avg_benefits
FROM limpieza.companies
WHERE highly_rated_for IS NOT NULL AND total_benefits IS NOT NULL
GROUP BY aspect
ORDER BY avg_benefits DESC;
```
```plaintext
aspect                        |    avg_benefits
------------------------------+---------------------
Job Security                 | 70.6973451327433628
Skill Development / Learning | 68.7537128712871287
Company Culture              | 59.1017560740918932
Work Life Balance            | 55.2104006367736800
Salary & Benefits            | 47.7065257017863653
Promotions / Appraisal       | 35.2457315031804486
Work Satisfaction            | 34.5725190839694656
```