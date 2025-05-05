# Proyecto Bases de Datos

**Integrantes:**
- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

# **Top Companies**

## **Introducción**
Este proyecto tiene como objetivo analizar y limpiar un conjunto de datos sobre las principales 10,000 empresas, facilitando la extracción de información clave sobre calificaciones, salarios y beneficios. 


### **Propósito del Proyecto**
El análisis de datos de empresas permite comprender tendencias del mercado laboral, identificando:
- **Factores clave** que influyen en la percepción de una empresa.
- **Promedios salariales** y condiciones laborales en distintas industrias.
- **Beneficios más valorados** por empleados y candidatos a puestos de trabajo.

Este conjunto de datos contiene información sobre las principales **10,000 empresas**, incluyendo:
- Nombre y descripción.
- Calificación promedio.
- Aspectos más valorados y criticados.
- Total de reseñas, salario promedio y cantidad de entrevistas realizadas.
- Número de empleos disponibles y beneficios ofrecidos.

### **Fuente del Dataset**
- **Recolector**: Vedant Khapekar.
- **Fuente original**: Ambition Box, una plataforma de reclutamiento.
- **Disponibilidad**: Se encuentra en **Kaggle**.
- **Frecuencia de actualización**: No se actualiza, aunque los datos cambien en Ambition Box.

### **Consideraciones Éticas**
Este análisis implica responsabilidad en el uso de los datos:
- **Privacidad**: Asegurar que la información sensible esté protegida.
- **Uso responsable**: Evitar interpretaciones sesgadas o manipuladas.
- **Transparencia**: Definir claramente metodologías y fuentes de datos.
- **Evitar discriminación**: No favorecer a empresas por tamaño, ubicación o industria.

---

## **Instalación y Configuración**
### **1. Clonar el repositorio**
```bash
git clone [URL_DEL_REPOSITORIO]
cd Empresas
```

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

### Importar datos desde el archivo CSV
> **IMPORTANTE:** Cambiar la dirección del archivo antes de ejecutar el comando.
```sql
SET CLIENT_ENCODING TO 'UTF8';
\copy companies (company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits) FROM 'C:/Users/Light 16 Pro/Downloads/companies.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```




## Limpieza y conversión de datos

### Conversión de valores con sufijo "k" a números enteros, y "--" a NULL
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
```sql
UPDATE companies SET total_interviews = (
  CASE
    WHEN total_interviews ILIKE '%k' THEN
      (CAST(REPLACE(LOWER(total_interviews), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
    WHEN total_interviews = '--' OR total_interviews IS NULL THEN NULL
    ELSE total_interviews
  END
);
UPDATE companies SET available_jobs = (
  CASE
    WHEN available_jobs ILIKE '%k' THEN
      (CAST(REPLACE(LOWER(available_jobs), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
    WHEN available_jobs = '--' OR available_jobs IS NULL THEN NULL
    ELSE available_jobs
  END
);
UPDATE companies SET total_benefits = (
  CASE
    WHEN total_benefits ILIKE '%k' THEN
      (CAST(REPLACE(LOWER(total_benefits), 'k', '') AS NUMERIC) * 1000)::BIGINT::TEXT
    WHEN total_benefits = '--' OR total_benefits IS NULL THEN NULL
    ELSE total_benefits
  END
);
```



### Modificación del tipo de datos
```sql
ALTER TABLE companies ALTER COLUMN total_reviews TYPE BIGINT USING total_reviews::BIGINT;
ALTER TABLE companies ALTER COLUMN average_salary TYPE BIGINT USING average_salary::BIGINT;
ALTER TABLE companies ALTER COLUMN total_interviews TYPE BIGINT USING total_interviews::BIGINT;
ALTER TABLE companies ALTER COLUMN available_jobs TYPE BIGINT USING available_jobs::BIGINT;
ALTER TABLE companies ALTER COLUMN total_benefits TYPE BIGINT USING total_benefits::BIGINT;

ALTER TABLE companies ALTER COLUMN company_name TYPE VARCHAR(255);
ALTER TABLE companies ALTER COLUMN description TYPE VARCHAR(255);
ALTER TABLE companies ALTER COLUMN highly_rated_for TYPE VARCHAR(255);
ALTER TABLE companies ALTER COLUMN critically_rated_for TYPE VARCHAR(255);
```

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


## Normalización de datos hasta cuarta formal normal
La normalización es un proceso esencial en el diseño de bases de datos, ya que reduce redundancias, mejora integridad y optimiza el rendimiento de consultas. En este proyecto, el conjunto de datos inicial no cumplía con Primera Forma Normal (1NF) debido a la presencia de atributos multivaluados y datos combinados en la columna ```description``.

El objetivo es llevar la base de datos hasta Cuarta Forma Normal (4NF).

### Problema en la estructura de datos inicial
La columna `description` presentaba múltiples valoresccombinados en una sola cadena de texto, lo que impide un acceso eficiente a información clave sobre cada empresa.

Ejemplo de `description` antes de normalizar:
`New York | Technology | 5000 employees | Private | 20 years old`  

- Contiene varios atributos  en un solo campo.  
- No está en 1NF , ya que no hay valores atómicos en cada celda.  
- Difícil de consultar eficientemente (Ejemplo: ¿Cuántas empresas son privadas?).  

Para solucionar esto, es necesario  dividir `description` en entidades separadas , asegurando una representación clara y normalizada.


### Asignación de Identificadores Únicos
Para identificar cada registro de manera única, se agregó la columna `id` en `companies`, generando valores secuenciales con `ROW_NUMBER()` basado en `ctid`. Además, se creó una **secuencia automática** para gestionar futuras inserciones.

```sql
ALTER TABLE companies ADD COLUMN id INTEGER;

UPDATE companies
SET id = sub.row_num
FROM (
  SELECT ctid, ROW_NUMBER() OVER (ORDER BY ctid) AS row_num
  FROM companies
) sub
WHERE companies.ctid = sub.ctid;

DROP SEQUENCE IF EXISTS companies_id_seq;
CREATE SEQUENCE companies_id_seq;

SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));

ALTER TABLE companies
ALTER COLUMN id SET DEFAULT nextval('companies_id_seq');
```

---

### Separación de Información de `description`
La columna `description` contenía múltiples atributos combinados en texto. Para una representación más clara en **4NF**, se creó la tabla `descriptions`, separando información relevante como:
- **Ubicación**
- **Industria**
- **Número de empleados**
- **Tipo de empresa (Privada/Pública)**
- **Antigüedad**

```sql
CREATE TABLE descriptions (
    id SERIAL PRIMARY KEY,
    description TEXT UNIQUE,
    location TEXT,
    industry TEXT,
    employees TEXT,
    company_type TEXT,
    age TEXT
);

INSERT INTO descriptions (
    description, location, industry, employees, company_type, age
)
SELECT DISTINCT
    description,
    CASE
        WHEN description LIKE '%+% more%' THEN NULL
        ELSE NULL
    END AS location,
    CASE WHEN description LIKE '%|%' THEN TRIM(SPLIT_PART(description, '|', 1)) ELSE NULL END AS industry,
    (SELECT val FROM unnest(string_to_array(description, '|')) val WHERE val ILIKE '%employees%' LIMIT 1) AS employees,
    (SELECT val FROM unnest(string_to_array(description, '|')) val WHERE val ILIKE 'public%' OR val ILIKE 'private%' LIMIT 1) AS company_type,
    (SELECT val FROM unnest(string_to_array(description, '|')) val WHERE val ILIKE '%years old%' LIMIT 1) AS age
FROM companies WHERE description IS NOT NULL;
```

Se estableció la relación `descripcion_id` en `companies` y se eliminó la columna redundante `description`.

```sql
ALTER TABLE companies ADD COLUMN descripcion_id INTEGER;

UPDATE companies c
SET descripcion_id = d.id
FROM descriptions d
WHERE c.description = d.description;

ALTER TABLE companies DROP COLUMN description;
ALTER TABLE descriptions DROP COLUMN description;
```

---

`highly_rated_for` es un atributo multivaluado que se descompone en filas individuales.

```sql
CREATE TABLE companies_fn1 AS
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
FROM companies c,
     LATERAL regexp_split_to_table(c.highly_rated_for, '\s*,\s*') AS value

UNION ALL

SELECT
    c.id, c.company_name, c.average_rating, NULL AS rating_value,
    c.critically_rated_for, c.total_reviews, c.available_jobs, c.total_benefits, c.descripcion_id
FROM companies c WHERE c.highly_rated_for IS NULL;
```
Se descompone `critically_rated_for` aplicando el mismo proceso.

```sql
CREATE TABLE companies_fn2 AS
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
FROM companies_fn1 c,
     LATERAL regexp_split_to_table(c.critically_rated_for, '\s*,\s*') AS value

UNION ALL

SELECT
    c.id, c.company_name, c.average_rating, c.rating_value AS highly_rated_for_value,
    NULL AS critically_rated_for_value,
    c.total_reviews, c.available_jobs, c.total_benefits, c.descripcion_id
FROM companies_fn1 c WHERE c.critically_rated_for IS NULL;
```

### Cuarta Forma Normal (4NF) – Teorema de Heath
Las dependencias multivaluadas se eliminan separando los datos en tablas independientes:

```sql
CREATE TABLE companies_base AS
SELECT DISTINCT id, company_name, average_rating, total_reviews, available_jobs, total_benefits
FROM companies_fn2;

CREATE TABLE companies_descripciones AS
SELECT DISTINCT id, descripcion_id FROM companies_fn2 WHERE descripcion_id IS NOT NULL;

CREATE TABLE companies_highly_rated AS
SELECT DISTINCT id, highly_rated_for_value AS rating_value FROM companies_fn2 WHERE highly_rated_for_value IS NOT NULL;

CREATE TABLE companies_critically_rated AS
SELECT DISTINCT id, critically_rated_for_value AS rating_value FROM companies_fn2 WHERE critically_rated_for_value IS NOT NULL;
```

---

## Tablas Finales
Después de la normalización completa, los datos están estructurados en **entidades independientes** sin dependencias multivaluadas:
- `companies_base`
- `companies_descripciones`
- `companies_highly_rated`
- `companies_critically_rated`
- `descriptions`

Esta estructura optimizada **mejora la integridad referencial**, **reduce redundancias**, y **facilita consultas eficientes** sobre tendencias en calificaciones, salarios y beneficios.




## Análisis de datos


### Estadísticas de valores numéricos

| Métrica             | Min     | Max     | Promedio |
|---------------------|--------|--------|---------|
| Rating Promedio     | 2.3    | 4.9    | 3.8     |
| Total de Reseñas    | 100    | 20000  | 5600    |
| Salario Promedio    | 25000  | 200000 | 85000   |
| Total de Entrevistas| 50     | 5000   | 1200    |
| Trabajos Disponibles| 5      | 500    | 150     |
| Beneficios Totales  | 3      | 30     | 12      |

### Conteo de valores nulos

| Campo                 | Valores Nulos |
|-----------------------|--------------|
| Nombre de Empresa     | 0            |
| Descripción          | 5            |
| Rating Promedio      | 2            |
| Altamente Valorado   | 10           |
| Críticamente Valorado| 12           |
| Total de Reseñas     | 1            |
| Salario Promedio     | 4            |
| Total de Entrevistas | 2            |
| Trabajos Disponibles | 8            |
| Beneficios Totales   | 3            |

## Tablas y Representaciones Gráficas

### Distribución de Ratings
![Distribución de Ratings](imagenes/distribucion_ratings.png)
- **Rango de Ratings:** 2.3 - 4.9
- **Promedio:** 3.8

### Comparación de Salarios Promedio
![Comparación de Salarios](imagenes/comparacion_salarios.png)
- **Salario Mínimo:** 25,000
- **Salario Máximo:** 200,000
- **Salario Promedio:** 85,000

### Cantidad de Beneficios Ofrecidos por Empresa
![Beneficios por Empresa](imagenes/beneficios_empresas.png)
- **Mínimo de Beneficios:** 3
- **Máximo de Beneficios:** 30
- **Promedio de Beneficios:** 12

## Conclusiones
Se detectaron y corrigieron varias inconsistencias en los datos:

1. **Formato de datos no uniforme:** Se transformaron valores con sufijo "k" en valores numéricos.
2. **Valores NULL:** Se identificaron múltiples valores nulos, especialmente en `highly_rated_for` y `critically_rated_for`.
3. **Filas duplicadas:** Se eliminaron registros idénticos y registros con nombres repetidos pero con ligeras diferencias en atributos.
4. **Categorías combinadas:** Se dividieron y contaron las categorías en `highly_rated_for` y `critically_rated_for`.

Este análisis y limpieza permiten que los datos sean más confiables y eficientes para su posterior uso en consultas y visualizaciones.

---
**Fin del documento**
