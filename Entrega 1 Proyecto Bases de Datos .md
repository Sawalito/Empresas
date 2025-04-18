# Entrega 1 del proyecto de Bases de Datos

- Alejandro Castillo
- Jorge Lafarga
- Natalia Quintana
- Silvestre Rosales
- Saúl Rojas

Los datos originales se encuentran en el archivo companies.csv

1. ### **Descripción general de los datos**

     
   Este conjunto de datos contiene información sobre las principales 10,000 empresas, incluyendo su nombre, descripción, calificación, aspectos más valorados y criticados, número de reseñas, salario promedio, cantidad de entrevistas realizadas, cantidad de empleos disponibles y beneficios.

2. **¿Quién los recolecta?**  
     
   Fue recopilado por Vedant Khapekar. La fuente original de los datos proviene de Ambition Box, una plataforma de reclutamiento.

3. **¿Cuál es el propósito de su recolección?**

   El propósito de este conjunto de datos es proporcionar información detallada sobre las principales empresas, lo que permite realizar análisis de:

* Opiniones de empleados sobre las empresas.  
* Factores que influyen en la calificación de una empresa.  
* Comparaciones salariales y oportunidades laborales.  
* Tendencias en el mercado laboral.

4. **¿Dónde se pueden obtener?**

En Kaggle

5. **¿Con qué frecuencia se actualizan?**

   Nunca, a pesar de que los datos cambien en Ambition Box, esta base de datos no se actualiza.

6. **¿Cuántas tuplas y cuántos atributos tiene el set de datos?**

Consta de 10,000 tuplas y 10 atributos.

7. **¿Qué significa cada atributo del set?**

* Company\_name \- Nombre de la empresa.  
* Description \- Breve descripción de la empresa, incluyendo industria y número de  
  Empleados.  
* Ratings \- Calificación promedio de la empresa según las reseñas.  
* Highly\_rated\_for \- Aspectos altamente valorados de la empresa por los empleados.  
* Critically\_rated\_for \- Aspectos más criticados de la empresa.  
* Total\_reviews \- Número total de reseñas de empleados sobre la empresa.  
* Avg\_salary \- Salario promedio en la empresa.  
* Interviews\_taken \- Cantidad de entrevistas que ha hecho la empresa.  
* Total\_jobs\_available \- Número total de empleos actualmente disponibles en la empresa.  
* Total\_benefits \- Cantidad de beneficios que ofrece la empresa i.e. formas alternativas de remuneración, como acciones u otras inversiones.

  ### 

8. ### **¿Qué atributos son numéricos?**

     
* Ratings (float) → Calificación promedio de la empresa.  
* Total\_reviews (text, pero representa valores numéricos).  
* Avg\_salary (text, pero representa valores numéricos).  
* Interviews\_taken (text, pero representa valores numéricos).  
* Total\_jobs\_available (text, pero representa valores numéricos).  
* Total\_benefits (text, pero representa valores numéricos).

Los que representan valores numéricos pero son text, es porque sus números están expresados como “3k” en vez de 3000\.

9. **¿Qué atributos son categóricos?**  
     
* Company\_name   
* Highly\_rated\_for   
* Critically\_rated\_for  
    
    
10. **¿Qué atributos son de tipo texto?**

    

* Company\_name  
* Description  
* Highly\_rated\_for  
* Critically\_rated\_for

11. **¿Qué atributos son de tipo temporal y/o fecha?**

Ninguno.

12. **¿Cuál es el objetivo buscado con el set de datos? ¿Para qué  se usará por el equipo?**

El objetivo de este conjunto de datos es proporcionar información detallada sobre las principales 10,000 empresas, permitiendo analizar factores clave del mercado laboral. El equipo lo utilizará para:

* Evaluar las opiniones de los empleados sobre sus empresas.  
* Identificar los aspectos más valorados y criticados en las compañías.  
* Analizar factores que influyen en la calificación de una empresa.  
* Comparar salarios y oportunidades laborales entre empresas.  
* Estudiar tendencias en el mercado laboral, como la demanda de talento y los beneficios ofrecidos.

13. ### **¿Qué consideraciones éticas conlleva el análisis y explotación de dichos datos?**

      
* Privacidad y anonimización: Asegurar que los datos personales de empleados o evaluadores estén protegidos y, si es necesario, anonimizar información sensible.  
* Uso responsable de la información: No utilizar los datos para generar informes sesgados o manipulados que puedan afectar injustamente la reputación de una empresa o individuo.  
* Transparencia: Indicar claramente las fuentes de los datos y las metodologías empleadas para su análisis.  
* Evitar discriminación: Asegurar que el análisis no refuerce sesgos en la contratación o evaluación de empresas en función de factores como ubicación, industria o tamaño.  
* Impacto en el mercado laboral: Considerar cómo la difusión de estos análisis podría influir en decisiones de contratación, salarios y beneficios, evitando afectar negativamente a empresas o empleados.

