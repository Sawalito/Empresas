# Entrega 1 del proyecto de Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

Los datos originales se encuentran en el archivo companies.csv

### **Descripción general de los datos**

     
Este conjunto de datos contiene información sobre las principales 10,000 empresas, incluyendo su nombre, descripción, calificación, aspectos más valorados y criticados, número de reseñas, salario promedio, cantidad de entrevistas realizadas, cantidad de empleos disponibles y beneficios.

     
Fue recopilado por Vedant Khapekar. La fuente original de los datos proviene de Ambition Box, una plataforma de reclutamiento. 

El dataset original está disponible en [Kaggle](https://www.kaggle.com/datasets/vedantkhapekar/top-10000-companies-dataset). No se actualiza, aunque los datos cambien en Ambition Box.

El propósito de este conjunto de datos es proporcionar información detallada sobre las principales empresas, lo que permite realizar análisis de:

* Opiniones de empleados sobre las empresas.  
* Factores que influyen en la calificación de una empresa.  
* Comparaciones salariales y oportunidades laborales.  
* Tendencias en el mercado laboral.

### **Atributos del Dataset**
En este conjunto de datos hay 10 000 tuplas que contienen informacion de 10 000 empresas, con 10 atributos que permiten realizar un análisis profundo del mercado laboral.
Cada atributo tiene el siguiete significado de acuerdo a la pagina de origen.

* Company_name - Nombre de la empresa.  
* Description - Breve descripción de la empresa, incluyendo industria y número de  
  Empleados.  
* Ratings - Calificación promedio de la empresa según las reseñas.  
* Highly_rated_for - Aspectos altamente valorados de la empresa por los empleados.  
* Critically_rated_for - Aspectos más criticados de la empresa.  
* Total_reviews - Número total de reseñas de empleados sobre la empresa.  
* Avg_salary - Salario promedio en la empresa.  
* Interviews_taken - Cantidad de entrevistas que ha hecho la empresa.  
* Total_jobs_available - Número total de empleos actualmente disponibles en la empresa.  
* Total_benefits - Cantidad de beneficios que ofrece la empresa i.e. formas alternativas de remuneración, como acciones u otras inversiones.

En el csv todos los atributos son texto, pero por el tipo de dato intencionado podemos observar las siguientes caracteristicas:

Los atributos numéricos son :     
* Ratings (float) → Calificación promedio de la empresa.  
* Total_reviews (text, pero representa valores numéricos).  
* Avg_salary (text, pero representa valores numéricos).  
* Interviews_taken (text, pero representa valores numéricos).  
* Total_jobs_available (text, pero representa valores numéricos).  
* Total_benefits (text, pero representa valores numéricos).
Los que representan valores numéricos pero son text, es porque sus números están expresados como “3k” en vez de 3000.

Los atributos categóricos son:  
* Company_name   
* Highly_rated_for   
* Critically_rated_for  
        
Los atributos de tipo texto son:
 * Company_name  
* Description  
* Highly_rated_for  
* Critically_rated_for

No hay atributos de tipo temporal y/o fecha

El objetivo de este conjunto de datos es proporcionar información detallada sobre las principales 10,000 empresas, permitiendo analizar factores clave del mercado laboral. El equipo lo utilizará para:

* Evaluar las opiniones de los empleados sobre sus empresas.  
* Identificar los aspectos más valorados y criticados en las compañías.  
* Analizar factores que influyen en la calificación de una empresa.  
* Comparar salarios y oportunidades laborales entre empresas.  
* Estudiar tendencias en el mercado laboral, como la demanda de talento y los beneficios ofrecidos.

### **Consideraciones éticas que conlleva el análisis y explotación de dichos datos**
* Privacidad y anonimización: Asegurar que los datos personales de empleados o evaluadores estén protegidos y, si es necesario, anonimizar información sensible.  
* Uso responsable de la información: No utilizar los datos para generar informes sesgados o manipulados que puedan afectar injustamente la reputación de una empresa o individuo.  
* Transparencia: Indicar claramente las fuentes de los datos y las metodologías empleadas para su análisis.  
* Evitar discriminación: **Asegurar que el análisis no refuerce sesgos en la contratación o evaluación de empresas en función de factores como ubicación, industria o tamaño.**
* Impacto en el mercado laboral: Considerar cómo la difusión de estos análisis podría influir en decisiones de contratación, salarios y beneficios, evitando afectar negativamente a empresas o empleados.

