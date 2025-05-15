DROP VIEW IF EXISTS final.vista_ciudades_continente CASCADE ;
CREATE VIEW final.vista_ciudades_continente AS
SELECT
    id,
    city,
    latitude,
    longitude,
    CASE
        WHEN latitude BETWEEN -35 AND 37 AND longitude BETWEEN -10 AND 60 THEN 'Europa'
        WHEN latitude BETWEEN -35 AND 35 AND longitude BETWEEN -20 AND 55 THEN 'África'
        WHEN latitude BETWEEN 5 AND 80 AND longitude BETWEEN 60 AND 180 THEN 'Asia'
        WHEN latitude BETWEEN -55 AND 15 AND longitude BETWEEN -80 AND -35 THEN 'Sudamérica'
        WHEN latitude BETWEEN 15 AND 75 AND longitude BETWEEN -170 AND -50 THEN 'Norteamérica'
        WHEN latitude BETWEEN -50 AND 0 AND longitude BETWEEN 110 AND 180 THEN 'Oceanía'
        WHEN latitude < -60 THEN 'Antártida'
        ELSE 'Desconocido'
    END AS continente
FROM final.locations;

DROP VIEW IF EXISTS final.vista_companies_continente CASCADE;
CREATE VIEW final.vista_companies_continente AS
SELECT
    cm.*,
    cc.continente AS continent,
    cc.city AS city,
    d.age AS age,
    d.company_type AS company_type,
    d.industry
FROM vista_ciudades_continente cc
JOIN final.descriptions d
ON d.id_city = cc.id
JOIN final.companies_4fn cm
ON d.id = cm.description_id;


-- Europa
DROP VIEW IF EXISTS final.europa;
CREATE VIEW final.europa AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'Europa';

-- África
DROP VIEW IF EXISTS final.africa;
CREATE VIEW final.africa AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'África';

-- Asia
DROP VIEW IF EXISTS final.asia;
CREATE VIEW final.asia AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'Asia';

-- Sudamérica
DROP VIEW IF EXISTS final.sudamerica;
CREATE VIEW final.sudamerica AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'Sudamérica';

-- Norteamérica
DROP VIEW IF EXISTS final.norteamerica;
CREATE VIEW final.norteamerica AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'Norteamérica';

-- Oceanía
DROP VIEW IF EXISTS final.oceania;
CREATE VIEW final.oceania AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'Oceanía';

-- Antártida
DROP VIEW IF EXISTS final.antartida;
CREATE VIEW final.antartida AS
SELECT * FROM final.vista_companies_continente
WHERE continent ILIKE 'Antártida';



--Tipo de industria y cantidad de empresas de esa industria para Norteamerica
SELECT
    DISTINCT industry,
    COUNT(industry)
FROM final.norteamerica
GROUP BY industry
ORDER BY COUNT(industry) DESC
LIMIT 10;

--Empresas mejore valoradas
SELECT
    company_name,
    average_rating
FROM final.norteamerica
ORDER BY average_rating DESC
LIMIT 10;

-- Aspectos mas calificados altos en compañias americanas
SELECT
    COUNT(chr.rating_value),
    chr.rating_value
FROM final.norteamerica n
JOIN final.companies_highly_rated chr
    ON n.id = chr.id_company
WHERE n.average_rating >= 4
GROUP BY chr.rating_value ;

--Aspectos mas calificados criticos
SELECT
    COUNT(ccr.value),
    ccr.value
FROM final.norteamerica n
JOIN final.companies_critically_rated ccr
    ON n.id = ccr.id_company
WHERE n.average_rating >= 4
GROUP BY ccr.value;


--correlacion entre el salario y el rating
SELECT
    CORR(average_salary, average_rating) AS correlacion
FROM final.norteamerica;

--correlacion entre la edad de la empresa y el rating
SELECT
    CORR(
        CAST(REGEXP_REPLACE(age, '[^0-9]', '', 'g') AS INTEGER),
        average_rating
    ) AS correlacion_edad_rating
FROM final.norteamerica
WHERE age ~ '^[0-9]+ years? old$';

--correlacion entre el salario y las reviews
SELECT
    CORR(average_salary, total_reviews) AS correlacion
FROM final.norteamerica;

--correlacion average_Rating y total_reviews
SELECT
    CORR(average_rating, total_reviews) AS correlacion
FROM final.norteamerica;

--correlacion entre el rating y los total benefits
SELECT
    CORR(average_rating, total_benefits) AS correlacion
FROM final.norteamerica;

--correlacion entre el salario y los beneficios totales
SELECT
    CORR(average_salary, total_benefits) AS correlacion
FROM final.norteamerica;



--Asia

-- Conteo de empresas por industria en Asia
SELECT
    DISTINCT industry,
    COUNT(industry)
FROM final.asia
GROUP BY industry
ORDER BY COUNT(industry) DESC;

-- Empresas mejor valoradas en Asia dentro de IT Services & Consulting
SELECT *
FROM final.asia
WHERE industry ILIKE 'IT Services & Consulting'
ORDER BY average_rating DESC;

-- Empresas mejor valoradas en general en Asia
SELECT *
FROM final.asia
ORDER BY average_rating DESC;

--distribucion del rating en asia
SELECT
    average_rating,
    COUNT(average_rating)
FROM final.asia
GROUP BY average_rating ORDER BY average_rating DESC;

-- Aspectos mas calificados altos en compañias americanas
SELECT
    COUNT(chr.rating_value),
    chr.rating_value
FROM final.asia a
JOIN final.companies_highly_rated chr
    ON a.id = chr.id_company
WHERE a.average_rating >= 4
GROUP BY chr.rating_value ;

--Aspectos mas calificados criticos
SELECT
    COUNT(ccr.value),
    ccr.value
FROM final.asia a
JOIN final.companies_critically_rated ccr
    ON a.id = ccr.id_company
WHERE a.average_rating >= 4
GROUP BY ccr.value;

-- Correlación entre salario y rating en Asia
SELECT
    CORR(average_salary, average_rating) AS correlacion
FROM final.asia;

-- Correlación entre la edad de la empresa y el rating en Asia
SELECT
    CORR(
        CAST(REGEXP_REPLACE(age, '[^0-9]', '', 'g') AS INTEGER),
        average_rating
    ) AS correlacion_edad_rating
FROM final.asia
WHERE age ~ '^[0-9]+ years? old$';

-- Correlación entre salario y total de reviews en Asia
SELECT
    CORR(average_salary, total_reviews) AS correlacion
FROM final.asia;

-- Correlación entre rating y total de reviews en Asia
SELECT
    CORR(average_rating, total_reviews) AS correlacion
FROM final.asia;

-- Correlación entre rating y beneficios totales en Asia
SELECT
    CORR(average_rating, total_benefits) AS correlacion
FROM final.asia;

-- Correlación entre salario y beneficios totales en Asia
SELECT
    CORR(average_salary, total_benefits) AS correlacion
FROM final.asia;
