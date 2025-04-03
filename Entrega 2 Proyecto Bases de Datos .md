### **Entrega 2 Proyecto Bases de Datos** 

### **Alejandro Castillo, Jorge Lafarga, Natalia Quintana, Silvestre Rosales, Saúl Rojas**

### 

### **Instrucciones para psql**

**\-- Borrar y crear database**

DROP DATABASE IF EXISTS top\_companies;  
CREATE DATABASE top\_companies;

**\--  Conectarse al database**

\\c top\_companies;

**\-- Borrar y crear tabla**

DROP TABLE IF EXISTS companies;

CREATE TABLE companies (company\_name TEXT, description TEXT, average\_rating DOUBLE PRECISION, highly\_rated\_for TEXT, critically\_rated\_for TEXT, total\_reviews TEXT, average\_salary TEXT, total\_interviews TEXT, available\_jobs TEXT, total\_benefits TEXT);

**\--  Copiar valores del .csv IMPORTANTE: CAMBIAR LA DIRECCIÓN DEL ARCHIVO** 

SET CLIENT\_ENCODING TO 'UTF8';

\\copy companies (company\_name, description, average\_rating, highly\_rated\_for, critically\_rated\_for, total\_reviews, average\_salary, total\_interviews, available\_jobs, total\_benefits) FROM '**C:/Users/Light 16 Pro/Downloads/companies.csv**' WITH (FORMAT csv, HEADER true, DELIMITER ',');

**\-- Ingresar a TablePlus y conectarse a la base de datos “top\_companies”**

**Código SQL para limpiar y convertir columnas a sus tipos de datos respectivos para poderse analizar** 

– El siguiente código convierte los valores de 2.5k a 2500 para poder ser analizados como números. Esto se hace para total\_reviews, average\_salary, total\_interviews y available\_jobs. 

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

\-- Una vez modificados los datos, podemos cambiar el tipo de dato en la tabla para guardar mas espacio y ser mas eficientes

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

**Consultas utilizadas para analizar los datos**

* **¿Existen columnas con valores únicos?**  
  * No, pero si deberían de ser ya que hay algunas tuplas repetidas, el siguiente codigo ayuda a deshacerse de dichas tuplas repetidas   
    

\-- Cuenta la cantidad de compañías distintas asumiendo que si dos se llaman igual, son la misma compañía. Regresa 9355

SELECT COUNT(DISTINCT(company\_name))  
FROM companies;

\-- Regresa todas las compañías que aparecen mas de una vez y que además todos sus atributos son iguales, es decir, son tuplas repetidas/ Regresa 641, por lo que hay 4 tuplas que tienen nombres repetidos pero atributos diferentes

SELECT \*, COUNT(\*) AS count  
FROM companies  
GROUP BY company\_name, description, average\_rating, highly\_rated\_for,  
         critically\_rated\_for, total\_reviews, average\_salary,  
         total\_interviews, available\_jobs, total\_benefits  
HAVING COUNT(\*) \> 1;

\-- Elimina todas las tuplas duplicadas, solo si todos sus atributos son iguales

DELETE FROM companies  
WHERE ctid NOT IN (  
  SELECT MIN(ctid)  
  FROM companies  
  GROUP BY company\_name, description, average\_rating, highly\_rated\_for, critically\_rated\_for, total\_reviews, average\_salary, total\_interviews, available\_jobs, total\_benefits  
);

\-- Regresa todas las tuplas que tienen el mismo nomre. Regresa 8 tuplas, por lo que hay 4 pares de tuplas con el mismo nombre. Podemos observar que todos sus atributos son iguales a excepcion de "description", que al momento de enlistar las sucursales, vienen en distinto orden

SELECT \*  
FROM companies  
WHERE company\_name IN (  
  SELECT company\_name  
  FROM companies  
  GROUP BY company\_name  
  HAVING COUNT(\*) \> 1  
)  
ORDER BY company\_name;

\-- Elimina todas las tuplas repetidas sin considerar descripcion

DELETE FROM companies  
WHERE ctid NOT IN (  
  SELECT MIN(ctid)  
  FROM companies  
  GROUP BY company\_name, average\_rating, highly\_rated\_for, critically\_rated\_for, total\_reviews, average\_salary, total\_interviews, total\_benefits  
);

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

    

* **Duplicados en atributos categóricos**  
  * Si los hay en description, highly\_rated\_for y critically\_rated\_for si lo que se busca es todas las tuplas que compartan alguna caracteristica, por ejemplo, todas las companias que sean aclamadas favorablemente por “Job Security”, el código es el siguiente:  
      
    SELECT \*  
    FROM companies  
    WHERE highly\_rated\_for ILIKE '%Job Security%';  
      
* **Columnas redundantes**  
  * No las hay  
* **Conteo de tuplas por cada categoría**  
  * Para saber qué categorías hay, se utiliza el siguiente codigo:   
      
    SELECT DISTINCT TRIM(regexp\_split\_to\_table(category, ',')) AS category  
    FROM (  
      SELECT highly\_rated\_for AS category FROM companies  
      WHERE highly\_rated\_for IS NOT NULL  
      
      UNION ALL  
      
      SELECT critically\_rated\_for AS category FROM companies  
      WHERE critically\_rated\_for IS NOT NULL  
    ) AS combined  
    ORDER BY category;  
      
    Esto regresa las categorías:   
* Company Culture  
* Job Security  
* Promotions / Appraisal  
* Salary & Benefits  
* Skill Development / Learning  
* Work Life Balance  
* Work Satisfaction


  Ahora, el siguiente codigo cuenta las apariciones de cada categoria: 


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
    ![][image2]![][image3]![][image4]  
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

  

[image1]: <data:image/png;base64,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>

[image2]: <data:image/png;base64,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>

[image3]: <data:image/png;base64,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>

[image4]: <data:image/png;base64,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>