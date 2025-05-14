DROP VIEW IF EXISTS vista_ciudades_continente CASCADE ;
CREATE VIEW vista_ciudades_continente AS
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

DROP VIEW IF EXISTS vista_companies_continente CASCADE;
CREATE VIEW vista_companies_continente AS
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
JOIN final.companies_description cd
ON d.id = cd.id_description
JOIN final.companies_4fn cm
ON cd.id_companies = cm.id;

SELECT * FROM final.companies_highly_rated;

-- Europa
DROP VIEW IF EXISTS europa;
CREATE VIEW europa AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'Europa';

-- África
DROP VIEW IF EXISTS africa;
CREATE VIEW africa AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'África';

-- Asia
DROP VIEW IF EXISTS asia;
CREATE VIEW asia AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'Asia';

-- Sudamérica
DROP VIEW IF EXISTS sudamerica;
CREATE VIEW sudamerica AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'Sudamérica';

-- Norteamérica
DROP VIEW IF EXISTS norteamerica;
CREATE VIEW norteamerica AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'Norteamérica';

-- Oceanía
DROP VIEW IF EXISTS oceania;
CREATE VIEW oceania AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'Oceanía';

-- Antártida
DROP VIEW IF EXISTS antartida;
CREATE VIEW antartida AS
SELECT * FROM vista_companies_continente
WHERE continent ILIKE 'Antártida';



--Tipo de industria y cantidad de empresas de esa industria para Norteamerica
SELECT
    DISTINCT industry,
    COUNT(industry)
FROM norteamerica
GROUP BY industry
ORDER BY COUNT(industry) DESC
LIMIT 10;

SELECT * FROM norteamerica
WHERE industry ILIKE 'IT Services & Consulting' ORDER BY average_rating DESC;

--Empresas mejore valoradas
SELECT
    id
FROM norteamerica
ORDER BY average_rating DESC;

-- Aspectos mas calificados altos en compañias americanas
SELECT
    COUNT(chr.rating_value),
    chr.rating_value
FROM norteamerica n
JOIN final.companies_highly_rated chr
    ON n.id = chr.id_company
WHERE n.average_rating >= 4
GROUP BY chr.rating_value ;

--Aspectos mas calificados criticos
SELECT
    COUNT(ccr.value),
    ccr.value
FROM norteamerica n
JOIN final.companies_critically_rated ccr
    ON n.id = ccr.id_company
WHERE n.average_rating >= 4
GROUP BY ccr.value;


--correlacion entre el salario y el rating
SELECT
    CORR(average_salary, average_rating) AS correlacion
FROM norteamerica;

--correlacion entre la edad de la empresa y el rating
SELECT
    CORR(
        CAST(REGEXP_REPLACE(age, '[^0-9]', '', 'g') AS INTEGER),
        average_rating
    ) AS correlacion_edad_rating
FROM norteamerica
WHERE age ~ '^[0-9]+ years? old$';

--correlacion entre el salario y las reviews
SELECT
    CORR(average_salary, total_reviews) AS correlacion
FROM norteamerica;

--correlacion average_Rating y total_reviews
SELECT
    CORR(average_rating, total_reviews) AS correlacion
FROM norteamerica;

--correlacion entre el rating y los total benefits
SELECT
    CORR(average_rating, total_benefits) AS correlacion
FROM norteamerica;

--correlacion entre el salario y los beneficios totales
SELECT
    CORR(average_salary, total_benefits) AS correlacion
FROM norteamerica;



--Asia

-- Conteo de empresas por industria en Asia
SELECT
    DISTINCT industry,
    COUNT(industry)
FROM asia
GROUP BY industry
ORDER BY COUNT(industry) DESC;

-- Empresas mejor valoradas en Asia dentro de IT Services & Consulting
SELECT *
FROM asia
WHERE industry ILIKE 'IT Services & Consulting'
ORDER BY average_rating DESC;

-- Empresas mejor valoradas en general en Asia
SELECT *
FROM asia
ORDER BY average_rating DESC;

--distribucion del rating en asia
SELECT
    average_rating,
    COUNT(average_rating)
FROM asia
GROUP BY average_rating ORDER BY average_rating DESC;

-- Aspectos mas calificados altos en compañias americanas
SELECT
    COUNT(chr.rating_value),
    chr.rating_value
FROM asia a
JOIN final.companies_highly_rated chr
    ON a.id = chr.id_company
WHERE a.average_rating >= 4
GROUP BY chr.rating_value ;

--Aspectos mas calificados criticos
SELECT
    COUNT(ccr.value),
    ccr.value
FROM asia a
JOIN final.companies_critically_rated ccr
    ON a.id = ccr.id_company
WHERE a.average_rating >= 4
GROUP BY ccr.value;

-- Correlación entre salario y rating en Asia
SELECT
    CORR(average_salary, average_rating) AS correlacion
FROM asia;

-- Correlación entre la edad de la empresa y el rating en Asia
SELECT
    CORR(
        CAST(REGEXP_REPLACE(age, '[^0-9]', '', 'g') AS INTEGER),
        average_rating
    ) AS correlacion_edad_rating
FROM asia
WHERE age ~ '^[0-9]+ years? old$';

-- Correlación entre salario y total de reviews en Asia
SELECT
    CORR(average_salary, total_reviews) AS correlacion
FROM asia;

-- Correlación entre rating y total de reviews en Asia
SELECT
    CORR(average_rating, total_reviews) AS correlacion
FROM asia;

-- Correlación entre rating y beneficios totales en Asia
SELECT
    CORR(average_rating, total_benefits) AS correlacion
FROM asia;

-- Correlación entre salario y beneficios totales en Asia
SELECT
    CORR(average_salary, total_benefits) AS correlacion
FROM asia;
