### **Entrega 2 Proyecto Bases de Datos** 

### **Alejandro Castillo, Jorge Lafarga, Natalia Quintana, Silvestre Rosales, Saúl Rojas**

### 

### **Instrucciones para psql**

**\-- Borrar y crear database**
```sql
DROP DATABASE IF EXISTS top\_companies;  
CREATE DATABASE top\_companies;
```

**\--  Conectarse al database**
```sql
\\c top\_companies;
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

**\-- Ingresar a TablePlus y conectarse a la base de datos “top\_companies”**


**Código SQL para limpiar y convertir columnas a sus tipos de datos respectivos para poderse analizar** 

– El siguiente código convierte los valores de 2.5k a 2500 para poder ser analizados como números. Esto se hace para total\_reviews, average\_salary, total\_interviews y available\_jobs. 
```sql
UPDATE companies SET total\_reviews \= (  
  CASE  
    WHEN total\_reviews ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(total\_reviews), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN total\_reviews \= '--' OR total\_reviews IS NULL THEN NULL  
    ELSE total\_reviews  
  END  
);

UPDATE companies SET average\_salary \= (  
  CASE  
    WHEN average\_salary ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(average\_salary), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN average\_salary \= '--' OR average\_salary IS NULL THEN NULL  
    ELSE average\_salary  
  END  
);

UPDATE companies SET total\_interviews \= (  
  CASE  
    WHEN total\_interviews ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(total\_interviews), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN total\_interviews \= '--' OR total\_interviews IS NULL THEN NULL  
    ELSE total\_interviews  
  END  
);

UPDATE companies SET available\_jobs \= (  
  CASE  
    WHEN available\_jobs ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(available\_jobs), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN available\_jobs \= '--' OR available\_jobs IS NULL THEN NULL  
    ELSE available\_jobs  
  END  
);

UPDATE companies SET total\_benefits \= (  
  CASE  
    WHEN total\_benefits ILIKE '%k' THEN  
      (CAST(REPLACE(LOWER(total\_benefits), 'k', '') AS NUMERIC) \* 1000)::BIGINT::TEXT  
    WHEN total\_benefits \= '--' OR total\_benefits IS NULL THEN NULL  
    ELSE total\_benefits  
  END  
);
```
\-- Una vez modificados los datos, podemos cambiar el tipo de dato en la tabla para guardar mas espacio y ser mas eficientes
```sql
ALTER TABLE companies ALTER COLUMN total\_reviews TYPE BIGINT USING total\_reviews::BIGINT;

ALTER TABLE companies ALTER COLUMN average\_salary TYPE BIGINT USING average\_salary::BIGINT;

ALTER TABLE companies ALTER COLUMN total\_interviews TYPE BIGINT USING total\_interviews::BIGINT;

ALTER TABLE companies ALTER COLUMN available\_jobs TYPE BIGINT USING available\_jobs::BIGINT;

ALTER TABLE companies ALTER COLUMN total\_benefits TYPE BIGINT USING total\_benefits::BIGINT;

ALTER TABLE companies  
ALTER COLUMN company\_name TYPE VARCHAR(255);

ALTER TABLE companies  
ALTER COLUMN description TYPE VARCHAR(255);

ALTER TABLE companies  
ALTER COLUMN highly\_rated\_for TYPE VARCHAR(255);

ALTER TABLE companies  
ALTER COLUMN critically\_rated\_for TYPE VARCHAR(255);
```

**Consultas utilizadas para analizar los datos**

* **¿Existen columnas con valores únicos?**  
  * No, pero si deberían de ser ya que hay algunas tuplas repetidas, el siguiente codigo ayuda a deshacerse de dichas tuplas repetidas   
    

\-- Cuenta la cantidad de compañías distintas asumiendo que si dos se llaman igual, son la misma compañía. Regresa 9355
```sql
SELECT COUNT(DISTINCT(company\_name))  
FROM companies;
```
\-- Regresa todas las compañías que aparecen mas de una vez y que además todos sus atributos son iguales, es decir, son tuplas repetidas/ Regresa 641, por lo que hay 4 tuplas que tienen nombres repetidos pero atributos diferentes
```sql
SELECT \*, COUNT(\*) AS count  
FROM companies  
GROUP BY company\_name, description, average\_rating, highly\_rated\_for,  
         critically\_rated\_for, total\_reviews, average\_salary,  
         total\_interviews, available\_jobs, total\_benefits  
HAVING COUNT(\*) \> 1;
```
\-- Elimina todas las tuplas duplicadas, solo si todos sus atributos son iguales
```sql
DELETE FROM companies  
WHERE ctid NOT IN (  
  SELECT MIN(ctid)  
  FROM companies  
  GROUP BY company\_name, description, average\_rating, highly\_rated\_for, critically\_rated\_for, total\_reviews, average\_salary, total\_interviews, available\_jobs, total\_benefits  
);
```
\-- Regresa todas las tuplas que tienen el mismo nomre. Regresa 8 tuplas, por lo que hay 4 pares de tuplas con el mismo nombre. Podemos observar que todos sus atributos son iguales a excepcion de "description", que al momento de enlistar las sucursales, vienen en distinto orden
```sql
SELECT \*  
FROM companies  
WHERE company\_name IN (  
  SELECT company\_name  
  FROM companies  
  GROUP BY company\_name  
  HAVING COUNT(\*) \> 1  
)  
ORDER BY company\_name;
```
\-- Elimina todas las tuplas repetidas sin considerar descripcion
```sql
DELETE FROM companies  
WHERE ctid NOT IN (  
  SELECT MIN(ctid)  
  FROM companies  
  GROUP BY company\_name, average\_rating, highly\_rated\_for, critically\_rated\_for, total\_reviews, average\_salary, total\_interviews, total\_benefits  
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

      MIN(average\_rating) AS min\_rating,

      MAX(average\_rating) AS max\_rating,

      AVG(average\_rating) AS avg\_rating,

    

      MIN(total\_reviews) AS min\_reviews,

      MAX(total\_reviews) AS max\_reviews,

      AVG(total\_reviews) AS avg\_reviews,

    

      MIN(average\_salary) AS min\_salary,

      MAX(average\_salary) AS max\_salary,

      AVG(average\_salary) AS avg\_salary,

    

      MIN(total\_interviews) AS min\_interviews,

      MAX(total\_interviews) AS max\_interviews,

      AVG(total\_interviews) AS avg\_interviews,

    

      MIN(available\_jobs) AS min\_jobs,

      MAX(available\_jobs) AS max\_jobs,

      AVG(available\_jobs) AS avg\_jobs,

    

      MIN(total\_benefits) AS min\_benefits,

      MAX(total\_benefits) AS max\_benefits,

      AVG(total\_benefits) AS avg\_benefits

    FROM companies;
```  
    

* **Duplicados en atributos categóricos**  
  * Si los hay en description, highly\_rated\_for y critically\_rated\_for si lo que se busca es todas las tuplas que compartan alguna caracteristica, por ejemplo, todas las companias que sean aclamadas favorablemente por “Job Security”, el código es el siguiente:  
```sql      
    SELECT \*  
    FROM companies  
    WHERE highly\_rated\_for ILIKE '%Job Security%';  
```

* **Columnas redundantes**  
  * No las hay  
* **Conteo de tuplas por cada categoría**  
  * Para saber qué categorías hay, se utiliza el siguiente codigo:   
```sql      
    SELECT DISTINCT TRIM(regexp\_split\_to\_table(category, ',')) AS category  
    FROM (  
      SELECT highly\_rated\_for AS category FROM companies  
      WHERE highly\_rated\_for IS NOT NULL  
      
      UNION ALL  
      
      SELECT critically\_rated\_for AS category FROM companies  
      WHERE critically\_rated\_for IS NOT NULL  
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

    COUNT(CASE WHEN highly\_rated\_for ILIKE '%' || category || '%' THEN 1 END) AS highly\_rated\_for,

    COUNT(CASE WHEN critically\_rated\_for ILIKE '%' || category || '%' THEN 1 END) AS critically\_rated\_for

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
      COUNT(\*) FILTER (WHERE company\_name IS NULL) AS company\_name\_nulls,  
      COUNT(\*) FILTER (WHERE description IS NULL) AS description\_nulls,  
      COUNT(\*) FILTER (WHERE average\_rating IS NULL) AS average\_rating\_nulls,  
      COUNT(\*) FILTER (WHERE highly\_rated\_for IS NULL) AS highly\_rated\_for\_nulls,  
      COUNT(\*) FILTER (WHERE critically\_rated\_for IS NULL) AS critically\_rated\_for\_nulls,  
      COUNT(\*) FILTER (WHERE total\_reviews IS NULL) AS total\_reviews\_nulls,  
      COUNT(\*) FILTER (WHERE average\_salary IS NULL) AS average\_salary\_nulls,  
      COUNT(\*) FILTER (WHERE total\_interviews IS NULL) AS total\_interviews\_nulls,  
      COUNT(\*) FILTER (WHERE available\_jobs IS NULL) AS available\_jobs\_nulls,  
      COUNT(\*) FILTER (WHERE total\_benefits IS NULL) AS total\_benefits\_nulls  
    FROM companies;  
      
    Regresa lo siguiente:  
    ![alt text](image.png)


* **¿Existen inconsistencias en el set de datos?**  
  * **Sí, se detectaron algunas inconsistencias en el conjunto de datos, y se han documentado y corregido en su mayoría. Aquí un resumen de los hallazgos:**  
      
    **1\. Formato de datos no uniforme**  
* **Varias columnas numéricas (total\_reviews, average\_salary, etc.) venían como texto con sufijo  'k' (por ejemplo, '2.5k'), lo que impedía análisis numéricos directos.**  
* **Se estandarizaron multiplicando los valores por 1,000 y convirtiéndolos a tipo INT, BIGINT o SMALLINT.**


  **2\. Valores NULL**

* **Se identificaron valores nulos, por ejemplo, en:**  
- **highly\_rated\_for: 92 nulos**  
- **critically\_rated\_for: 7,193 nulos**  
- **etc.**  
* **Se consideró si reemplazarlos por 'Not Available' pero decidí mantenerlos como NULL.**


  **3\. Filas duplicadas**

* **Se detectaron filas completamente duplicadas y también otras muy similares, donde solo cambiaba un atributo irrelevante, por lo que se hizo un análisis de tuplas repetidoas y posteriormente se eliminaron.**


  **4\. Categorías combinadas en una sola columna**

* **Columnas como highly\_rated\_for y critically\_rated\_for contenían múltiples categorías combinadas por comas o slashes. Se dividieron esas categorías para analizar ocurrencias individuales, y se contó la frecuencia de cada una.**

  
>