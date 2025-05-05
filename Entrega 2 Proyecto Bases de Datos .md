### **Entrega 2 Proyecto Bases de Datos** 

### **Alejandro Castillo, Jorge Lafarga, Natalia Quintana, Silvestre Rosales, Saúl Rojas**

### 

### **Instrucciones para psql**

**\-- Borrar y crear database**
```sql
DROP DATABASE IF EXISTS top_companies;  
CREATE DATABASE top_companies;
```

**\--  Conectarse al database**
```sql
\\c top_companies;
```

**\-- Borrar y crear tabla**
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

**\--  Carga del Archivo CSV**
⚠️ IMPORTANTE: Antes de ejecutar este comando, cambia la dirección del archivo CSV en tu sistema.

```sql
SET CLIENT_ENCODING TO 'UTF8';

\copy companies FROM 'C:/Users/Light 16 Pro/Downloads/companies.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

**\-- Ingresar a TablePlus y conectarse a la base de datos “top_companies”**


**Código SQL para limpiar y convertir columnas a sus tipos de datos respectivos para poderse analizar** 

– El siguiente código convierte los valores de 2.5k a 2500 para poder ser analizados como números. Esto se hace para total_reviews, average_salary, total_interviews y available_jobs. 
```sql
UPDATE companies SET total_reviews = (  
  CASE  
    WHEN total_reviews ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(total_reviews), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN total_reviews \= '--' OR total_reviews IS NULL THEN NULL  
    ELSE total_reviews  
  END  
);

UPDATE companies SET average_salary \= (  
  CASE  
    WHEN average_salary ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(average_salary), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN average_salary \= '--' OR average_salary IS NULL THEN NULL  
    ELSE average_salary  
  END  
);

UPDATE companies SET total_interviews \= (  
  CASE  
    WHEN total_interviews ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(total_interviews), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN total_interviews \= '--' OR total_interviews IS NULL THEN NULL  
    ELSE total_interviews  
  END  
);

UPDATE companies SET available_jobs \= (  
  CASE  
    WHEN available_jobs ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(available_jobs), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN available_jobs \= '--' OR available_jobs IS NULL THEN NULL  
    ELSE available_jobs  
  END  
);

UPDATE companies SET total_benefits \= (  
  CASE  
    WHEN total_benefits ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(total_benefits), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN total_benefits \= '--' OR total_benefits IS NULL THEN NULL  
    ELSE total_benefits  
  END  
);
```
\-- Una vez modificados los datos, podemos cambiar el tipo de dato en la tabla para guardar mas espacio y ser mas eficientes
```sql
ALTER TABLE companies ALTER COLUMN total_reviews TYPE BIGINT USING total_reviews::BIGINT;

ALTER TABLE companies ALTER COLUMN average_salary TYPE BIGINT USING average_salary::BIGINT;

ALTER TABLE companies ALTER COLUMN total_interviews TYPE BIGINT USING total_interviews::BIGINT;

ALTER TABLE companies ALTER COLUMN available_jobs TYPE BIGINT USING available_jobs::BIGINT;

ALTER TABLE companies ALTER COLUMN total_benefits TYPE BIGINT USING total_benefits::BIGINT;

ALTER TABLE companies  
ALTER COLUMN company_name TYPE VARCHAR(255);

ALTER TABLE companies  
ALTER COLUMN description TYPE VARCHAR(255);

ALTER TABLE companies  
ALTER COLUMN highly_rated_for TYPE VARCHAR(255);

ALTER TABLE companies  
ALTER COLUMN critically_rated_for TYPE VARCHAR(255);
```

**Consultas utilizadas para analizar los datos**

* **¿Existen columnas con valores únicos?**  
  * No, pero si deberían de ser ya que hay algunas tuplas repetidas, el siguiente codigo ayuda a deshacerse de dichas tuplas repetidas   
    

\-- Cuenta la cantidad de compañías distintas asumiendo que si dos se llaman igual, son la misma compañía. Regresa 9355
```sql
SELECT COUNT(DISTINCT(company_name))  
FROM companies;
```
\-- Regresa todas las compañías que aparecen mas de una vez y que además todos sus atributos son iguales, es decir, son tuplas repetidas/ Regresa 641, por lo que hay 4 tuplas que tienen nombres repetidos pero atributos diferentes
```sql
SELECT \*, COUNT(\*) AS count  
FROM companies  
GROUP BY company_name, description, average_rating, highly_rated_for,  
         critically_rated_for, total_reviews, average_salary,  
         total_interviews, available_jobs, total_benefits  
HAVING COUNT(\*) \> 1;
```
\-- Elimina todas las tuplas duplicadas, solo si todos sus atributos son iguales
```sql
DELETE FROM companies  
WHERE ctid NOT IN (  
  SELECT MIN(ctid)  
  FROM companies  
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits  
);
```
\-- Regresa todas las tuplas que tienen el mismo nomre. Regresa 8 tuplas, por lo que hay 4 pares de tuplas con el mismo nombre. Podemos observar que todos sus atributos son iguales a excepcion de "description", que al momento de enlistar las sucursales, vienen en distinto orden
```sql
SELECT \*  
FROM companies  
WHERE company_name IN (  
  SELECT company_name  
  FROM companies  
  GROUP BY company_name  
  HAVING COUNT(\*) \> 1  
)  
ORDER BY company_name;
```
\-- Elimina todas las tuplas repetidas sin considerar descripcion
```sql
DELETE FROM companies  
WHERE ctid NOT IN (  
  SELECT MIN(ctid)  
  FROM companies  
  GROUP BY company_name, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, total_benefits  
);
```

* **Mínimos y máximos de fechas**  
  * No hay fechas  
* **Mínimos, máximos y promedios de valores numéricos**  
  * Los valores son los siguientes:

|  | Minimo | Media | Maxima |
| :---- | :---- | :---- | :---- |
| rating | 1.3 | 3.89 | 5 |
| total reviews | 72 | 435.24 | 73100 |
| salary | 2 | 2502.91 | 856900 |
| interviews | 1 | 26.88 | 6100 |
| available jobs | 1 | 35.44 | 9900 |
| benefits | 1 | 56.56 | 11500 |

    

    El código utilizado para conseguir los valores es este:

    
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
    

* **Duplicados en atributos categóricos**  
  * Si los hay en description, highly_rated_for y critically_rated_for si lo que se busca es todas las tuplas que compartan alguna caracteristica, por ejemplo, todas las companias que sean aclamadas favorablemente por “Job Security”, el código es el siguiente:  
```sql      
    SELECT \*  
    FROM companies  
    WHERE highly_rated_for ILIKE '%Job Security%';  
```

* **Columnas redundantes**  
  * No las hay  
* **Conteo de tuplas por cada categoría**  
  * Para saber qué categorías hay, se utiliza el siguiente codigo:   
```sql      
    SELECT DISTINCT TRIM(regexp_split_to_table(category, ',')) AS category  
    FROM (  
      SELECT highly_rated_for AS category FROM companies  
      WHERE highly_rated_for IS NOT NULL  
      
      UNION ALL  
      
      SELECT critically_rated_for AS category FROM companies  
      WHERE critically_rated_for IS NOT NULL  
    ) AS combined  
    ORDER BY category;  
```

    Esto regresa las categorías:   
* Company Culture  
* Job Security  
* Promotions / Appraisal  
* Salary & Benefits  
* Skill Development / Learning  
* Work Life Balance  
* Work Satisfaction


  Ahora, el siguiente codigo cuenta las apariciones de cada categoria: 

```sql
  SELECT

    category,

    COUNT(CASE WHEN highly_rated_for ILIKE '%' || category || '%' THEN 1 END) AS highly_rated_for,

    COUNT(CASE WHEN critically_rated_for ILIKE '%' || category || '%' THEN 1 END) AS critically_rated_for

  FROM (

    VALUES 

      ('Company Culture'),

      ('Job Security'),

      ('Promotions / Appraisal'),

      ('Salary & Benefits'),

      ('Skill Development / Learning'),

      ('Work Life Balance'),

      ('Work Satisfaction')

  ) AS categories(category)

  CROSS JOIN companies

  GROUP BY category

  ORDER BY category;
```

  Regresa los siguientes valores: ![][image1]

* **Conteo de valores nulos**  
  * Utilicé el siguiente código para contar nulos por columna:  
      
    SELECT  
      COUNT(\*) FILTER (WHERE company_name IS NULL) AS company_name_nulls,  
      COUNT(\*) FILTER (WHERE description IS NULL) AS description_nulls,  
      COUNT(\*) FILTER (WHERE average_rating IS NULL) AS average_rating_nulls,  
      COUNT(\*) FILTER (WHERE highly_rated_for IS NULL) AS highly_rated_for_nulls,  
      COUNT(\*) FILTER (WHERE critically_rated_for IS NULL) AS critically_rated_for_nulls,  
      COUNT(\*) FILTER (WHERE total_reviews IS NULL) AS total_reviews_nulls,  
      COUNT(\*) FILTER (WHERE average_salary IS NULL) AS average_salary_nulls,  
      COUNT(\*) FILTER (WHERE total_interviews IS NULL) AS total_interviews_nulls,  
      COUNT(\*) FILTER (WHERE available_jobs IS NULL) AS available_jobs_nulls,  
      COUNT(\*) FILTER (WHERE total_benefits IS NULL) AS total_benefits_nulls  
    FROM companies;  
      
    Regresa lo siguiente:  
    ![alt text](image.png)


* **¿Existen inconsistencias en el set de datos?**  
  * **Sí, se detectaron algunas inconsistencias en el conjunto de datos, y se han documentado y corregido en su mayoría. Aquí un resumen de los hallazgos:**  
      
    **1\. Formato de datos no uniforme**  
* **Varias columnas numéricas (total_reviews, average_salary, etc.) venían como texto con sufijo  'k' (por ejemplo, '2.5k'), lo que impedía análisis numéricos directos.**  
* **Se estandarizaron multiplicando los valores por 1,000 y convirtiéndolos a tipo INT, BIGINT o SMALLINT.**


  **2\. Valores NULL**

* **Se identificaron valores nulos, por ejemplo, en:**  
- **highly_rated_for: 92 nulos**  
- **critically_rated_for: 7,193 nulos**  
- **etc.**  
* **Se consideró si reemplazarlos por 'Not Available' pero decidí mantenerlos como NULL.**


  **3\. Filas duplicadas**

* **Se detectaron filas completamente duplicadas y también otras muy similares, donde solo cambiaba un atributo irrelevante, por lo que se hizo un análisis de tuplas repetidoas y posteriormente se eliminaron.**


  **4\. Categorías combinadas en una sola columna**

* **Columnas como highly_rated_for y critically_rated_for contenían múltiples categorías combinadas por comas o slashes. Se dividieron esas categorías para analizar ocurrencias individuales, y se contó la frecuencia de cada una.**

  
>