# Entrega 3 Proyecto Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

### Normalización de datos hasta cuarta formal normal
Para no regarla, creamos un esquema limpieza que asegura una separacion entre los datos originales y estos procesados. El siguiente codigo tiene la entrega pasada de limpieza y conversion de datos.

```sql
CREATE SCHEMA limpieza;

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


SELECT * FROM limpieza.companies;

SELECT MIN(ctid)
  FROM companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits;

SELECT
    CTID
FROM limpieza.companies;

SELECT description FROM limpieza.companies;


DELETE FROM limpieza.companies
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
);

```


## Normalización de Datos
La normalización es un proceso esencial en el diseño de bases de datos, ya que reduce redundancias, mejora integridad y optimiza el rendimiento de consultas. En este proyecto, el conjunto de datos inicial no cumplía con Primera Forma Normal (1NF) debido a la presencia de atributos multivaluados y datos combinados en la columna ```description``.

Nuestro objetivo es llevar la base de datos hasta Cuarta Forma Normal (4NF), y vamos a hacerlo en orden **FN1 → FN2 → 4NF** revisando las dependencias funcionales y multivaluadas.

### Problema en la estructura de datos inicial

La columna `description` presentaba múltiples valoresccombinados en una sola cadena de texto, lo que impide un acceso eficiente a información clave sobre cada empresa.

Ejemplo de `description` antes de normalizar:
`New York | Technology | 5000 employees | Private | 20 years old`  

- Contiene varios atributos  en un solo campo.  
- No está en 1NF , ya que no hay valores atómicos en cada celda.  
- Difícil de consultar eficientemente (Ejemplo: ¿Cuántas empresas son privadas?).  

Para solucionar esto, es necesario  dividir `description` en entidades separadas , asegurando una representación clara y normalizada.

---

### Asignación de ID a la Tabla `companies`
Primero, se añade una columna **`id`** a la tabla `companies`, asignando valores únicos a cada registro usando `ROW_NUMBER()` para garantizar una clave artificial.
`ROW_NUMBER()` genera un índice incremental basado en `ctid`, permitiendo una identificación única.
```sql
--Ponerle un id a las nuevas columnas
ALTER TABLE limpieza.companies ADD COLUMN id INTEGER;

UPDATE limpieza.companies
SET id = sub.row_num
FROM (
  SELECT ctid, ROW_NUMBER() OVER (ORDER BY ctid) AS row_num
  FROM limpieza.companies
) sub
WHERE limpieza.companies.ctid = sub.ctid;
```

---

### Creación de una Secuencia para ID
Se utiliza una **secuencia (`limpieza_companies_id_seq`)** para mantener la generación automática de identificadores en futuras inserciones.

```sql
DROP SEQUENCE IF EXISTS limpieza_companies_id_seq;
CREATE SEQUENCE limpieza_companies_id_seq;

SELECT setval('limpieza_companies_id_seq', (SELECT MAX(id) FROM limpieza.companies));

ALTER TABLE limpieza.companies
ALTER COLUMN id SET DEFAULT nextval('limpieza_companies_id_seq');

SELECT * FROM limpieza.companies
ORDER BY id;
```


### Creación de una tabla `descriptions` para separar lo que contiene la columna description

Para cumplir con  1NF , descomponemos la columna `description` en una nueva tabla llamada `descriptions`, donde cada empresa tendrá referencias claras a información detallada como:  

| ID  | Ubicación   | Industria  | Empleados  | Tipo de empresa | Antigüedad  |
|-----|------------|------------|------------|----------------|-------------|
| 1   | New York   | Technology | 5000       | Private        | 20 years    |
| 2   | San Diego  | Healthcare | 1200       | Public         | 15 years    |


```sql
--Creacion de las tablas de descripcion

DROP TABLE IF EXISTS limpieza.descriptions;
CREATE TABLE limpieza.descriptions (
    id SERIAL PRIMARY KEY,
    description TEXT UNIQUE,
    location TEXT,
    industry TEXT,
    employees TEXT,
    company_type TEXT,
    age TEXT
);
```

Extraer Atributos de `description`
Dado que `description` contiene múltiples valores en **formato texto**, se usa `string_to_array()` y expresiones regulares para extraer:
- **Ubicación (`location`)**
- **Industria (`industry`)**
- **Número de empleados (`employees`)**
- **Tipo de empresa (`company_type`)**
- **Años de operación (`age`)**

```sql
INSERT INTO limpieza.descriptions (
    description,
    location,
    industry,
    employees,
    company_type,
    age
)
SELECT
    d.description,

    -- Detectar ubicación como "City +N more"
    CASE
        WHEN d.description ~* '^[A-Za-z ]+\s+\+\d+\s+more$' THEN d.description
        WHEN d.description LIKE '%+% more%' THEN NULL
        ELSE NULL
    END AS location,

    -- Extraer industry
    CASE
        WHEN d.description LIKE '%|%' THEN TRIM(SPLIT_PART(d.description, '|', 1))
        ELSE NULL
    END AS industry,

    -- Employees
    (
        SELECT val FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%employees%' LIMIT 1
    ) AS employees,

    -- Company type
    (
        SELECT val FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE 'public%' OR val ILIKE 'private%' LIMIT 1
    ) AS company_type,

    -- Age
    (
        SELECT val FROM unnest(string_to_array(d.description, '|')) val
        WHERE val ILIKE '%years old%' LIMIT 1
    ) AS age

FROM (
    SELECT DISTINCT description
    FROM limpieza.companies
    WHERE description IS NOT NULL
) d;
```

Esto permite almacenar cada atributo en su **propia columna**, facilitando análisis.

```sql
-- Actualiza la columna 'location' en la tabla 'descriptions'.
-- Extrae la última parte del atributo 'description' (separado por '|') como ubicación.
UPDATE limpieza.descriptions
SET location = TRIM(
    SPLIT_PART(description, '|', array_length(string_to_array(description, '|'), 1))
)
WHERE description IS NOT NULL;

--Comprobacion
SELECT * FROM  limpieza.descriptions ORDER BY id;

SELECT * FROM limpieza.descriptions;

SELECT COUNT(*) FROM limpieza.descriptions;


SELECT COUNT(DISTINCT description) FROM limpieza.companies;
```
En la tabla companies cambiar `description` por 'descripcion_id'.
```sql
-- Agregar columna de descripcion
ALTER TABLE limpieza.companies
ADD COLUMN descripcion_id INTEGER;

UPDATE limpieza.companies c
SET descripcion_id = d.id
FROM limpieza.descriptions d
WHERE c.description = d.description;

ALTER TABLE limpieza.descriptions DROP COLUMN description;
SELECT * FROM limpieza.descriptions ORDER BY id;

SELECT * FROM limpieza.companies;
ALTER TABLE limpieza.companies DROP COLUMN description;
```
---


### Descomposición en FN1
Las columnas `highly_rated_for` y `critically_rated_for` contienen  múltiples valores separados por comas y por '/', lo que indica una dependencia multivaluada. Para llevar a  FN1 y FN2 , descomponemos cada categoría en una entidad propia.  

Antes de la normalización:   
| ID | Empresa       | highly_rated_for       | critically_rated_for   |
|----|--------------|------------------------|------------------------|
| 1  | Amazon       | Salary, Benefits       | Work-life balance     |

Después de FN1 y FN2:   
| ID | Empresa       | highly_rated_for       |
|----|--------------|------------------------|
| 1  | Amazon       | Salary                 |
| 1  | Amazon       | Benefits               |

| ID | Empresa       | critically_rated_for   |
|----|--------------|------------------------|
| 1  | Amazon       | Work-life balance      |


```sql

--LLevar a FN1
DROP TABLE IF EXISTS limpieza.companies_fn1;

CREATE TABLE limpieza.companies_fn1 AS

-- Filas con valores individuales de highly_rated_for
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    TRIM(value) AS rating_value,
    c.critically_rated_for,
    c.total_reviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies c,
     LATERAL regexp_split_to_table(c.highly_rated_for, '\s*,\s*') AS value

UNION ALL

-- Fila única cuando highly_rated_for es NULL
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    NULL AS rating_value,
    c.critically_rated_for,
    c.total_reviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies c
WHERE c.highly_rated_for IS NULL;
```


### Descomposición en FN2
Se aplica el mismo proceso para `critically_rated_for`.

```sql
CREATE TABLE limpieza.companies_fn2 AS
-- Descomposición de critically_rated_for
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    c.rating_value AS highly_rated_for_value,
    TRIM(value) AS critically_rated_for_value,
    c.total_reviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies_fn1 c,
     LATERAL regexp_split_to_table(c.critically_rated_for, '\s*,\s*') AS value

UNION ALL

-- Fila con NULL si critically_rated_for lo es
SELECT
    c.id,
    c.company_name,
    c.average_rating,
    c.rating_value AS highly_rated_for_value,
    NULL AS critically_rated_for_value,
    c.total_reviews,
    c.available_jobs,
    c.total_benefits,
    c.descripcion_id
FROM limpieza.companies_fn1 c
WHERE c.critically_rated_for IS NULL;
```
```sql
SELECT * FROM limpieza.companies_fn2 WHERE id = 66;

SELECT * FROM limpieza.companies_fn2 ORDER BY id;

SELECT * FROM limpieza.companies_fn1 ORDER BY id;

SELECT * FROM limpieza.companies WHERE id = 66;
```


---

### Aplicación del Teorema de Heath (4NF)
Se descompone la tabla final en múltiples entidades.
La  última fase  de normalización consiste en  eliminar dependencias multivaluadas  en la base de datos utilizando el  Teorema de Heath . Esto nos permite dividir correctamente la información y generar relaciones claras sin redundancias.  

Tablas finales después de 4NF:   
- `companies_base`: Información esencial de cada empresa.  
- `descriptions`: Atributos detallados por empresa.  
- `companies_highly_rated`: Categorías positivas en empresas.  
- `companies_critically_rated`: Categorías negativas en empresas.  
- `companies_descripciones`: Relación entre empresas y su descripción.  

```sql
--Teorema de Heath 4FN

--DROP TABLE limpieza.companies_base;
CREATE TABLE limpieza.companies_base AS
SELECT DISTINCT
    id,
    company_name,
    average_rating,
    total_reviews,
    available_jobs,
    total_benefits
FROM limpieza.companies_fn2;
SELECT * FROM limpieza.companies_base;

--DROP TABLE limpieza.companies_descripciones;
CREATE TABLE limpieza.companies_descripciones AS
SELECT DISTINCT
    id,
    descripcion_id
FROM limpieza.companies_fn2
WHERE descripcion_id IS NOT NULL;
SELECT * FROM limpieza.companies_descripciones ORDER BY id;

--DROP TABLE limpieza.companies_highly_rated
CREATE TABLE limpieza.companies_highly_rated AS
SELECT DISTINCT
    id,
    highly_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE highly_rated_for_value IS NOT NULL;
SELECT * FROM limpieza.companies_highly_rated ORDER BY id;

--DROP TABLE limpieza.companies_critically_rated
CREATE TABLE limpieza.companies_critically_rated AS
SELECT DISTINCT
    id,
    critically_rated_for_value AS rating_value
FROM limpieza.companies_fn2
WHERE critically_rated_for_value IS NOT NULL;
SELECT * FROM limpieza.companies_critically_rated ORDER BY id;
```
Ahora los atributos multivaluados están en **tablas separadas**, cumpliendo **4NF**.

---

Tablas resultantes para el proyecto:
- companies_base
- companies_critically_rated
- companies_descripciones
- companies_highly_rated
- descriptions


## Análisis de datos a través de consultas SQL y creación de atributos analíticos

to be continued...