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
```
```sql
SELECT *, COUNT(*) AS count
FROM companies
GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
HAVING COUNT(*) > 1;
```
```sql
DELETE FROM companies
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM companies
  GROUP BY company_name, description, average_rating, highly_rated_for, critically_rated_for, total_reviews, average_salary, total_interviews, available_jobs, total_benefits
);
```

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
