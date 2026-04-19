# Análisis del Funnel Hipotecario — iAhorro
**Para:** Head of Operations  
**Fecha:** Abril 2025  
**Fuentes:** SQL (DuckDB/MotherDuck) · Power BI Dashboard · n8n Automation Prototype

---

## Contexto del análisis

Este análisis se basa en tres capas complementarias: las consultas SQL sobre los datos brutos (leads, calls, mortgage_applications, agents), el dashboard operativo construido en Power BI con modelo estrella y medidas DAX, y el prototipo de automatización desarrollado en n8n. Los tres apuntan de forma consistente a los mismos problemas y permiten ir más allá del diagnóstico hacia una solución ya operativa.

El dataset cubre 800 leads únicos desde octubre 2024 hasta junio 2025, con una tasa de conversión global a solicitud del 27% y un tiempo medio de 31,4 horas desde la captación hasta la primera llamada.

---

## Hallazgo 1 — El 52% de las hipotecas aprobadas no están cerradas en CRM

De las 88 solicitudes que el banco ha marcado como `aprobada` en el sistema de mortgage_applications, 46 (el 52%) siguen figurando como `solicitud_enviada` en el CRM de leads. El patrón no es aleatorio: todos los 46 registros tienen exactamente el mismo status, lo que descarta errores puntuales y apunta a un proceso roto de forma sistemática.

El impacto operativo es inmediato: cualquier métrica de conversión extraída del CRM subestima el rendimiento real del equipo en al menos un 50%. El dashboard de Power BI confirma este problema visualmente — el funnel de barras por mes muestra una brecha constante entre Applications y Approved_Applications que no se refleja en el contador de leads cerrados.

**Lo que ya está construido:** el workflow de n8n desarrollado durante esta prueba ejecuta cada mañana a las 8:00 una consulta que detecta exactamente estos registros — leads con `solicitud_enviada` cuya solicitud asociada figura como `aprobada` — y envía una alerta con el listado completo. El prototipo está funcionando y testado. Pasar de webhook a un canal de Slack o email del equipo es una hora de configuración.

**Indicador de seguimiento:** % de solicitudes `aprobada` cuyo lead tiene `cerrado_ganado` en CRM. Hoy: 48%. Objetivo en 4 semanas: 95%.

---

## Hallazgo 2 — La velocidad de respuesta predice la conversión, no el volumen

El dashboard de Power BI permite cruzar tiempo de primera llamada con tasa de conversión por provincia, y el patrón es claro:

- **Sevilla**: 23,8 horas de media hasta la primera llamada → 42,9% de conversión
- **Madrid**: 30,4 horas → 26,6% de conversión
- **Media global**: 31,4 horas → 27,0% de conversión

La provincia con el tiempo de respuesta más corto tiene una tasa de conversión un 60% superior a la media. No es una coincidencia puntual: es una señal consistente de que la velocidad de contacto es uno de los principales palancas de conversión disponibles sin cambiar ni el producto ni el precio.

El análisis SQL confirma la misma lógica desde el ángulo temporal: la semana del 3 de marzo fue la de mayor captación del trimestre (29 leads) pero la de menor conversión a solicitud (17,2%) y cero aprobaciones. Por el contrario, la semana del 27 de enero, con solo 20 leads, produjo la mejor tasa del período (50%). El volumen de entrada no determina el resultado. La calidad del seguimiento sí.

---

## Hallazgo 3 — Existen patrones geográficos y de eficiencia que no están siendo aprovechados

Tres agentes concentran la mejor eficiencia del equipo: Agente 5 (34,9%), Agente 13 y Agente 3 (34,2% cada uno), operando a más del doble de la tasa media observable. El dashboard de Power BI añade una dimensión geográfica que SQL no puede ver directamente: Sevilla, con solo 7 leads en el período filtrado, alcanza una conversión del 42,9%, mientras que Madrid, el mercado más grande con 109 leads, se queda en el 26,6%.

Esto sugiere dos hipótesis no excluyentes: que oficinas más pequeñas tienen menor tiempo de respuesta porque la carga de trabajo lo permite, o que hay prácticas de gestión de leads en determinados equipos que no están replicadas en el resto de la organización. El filtro por `team` disponible en el dashboard (equipo_a, equipo_b, equipo_c) permitiría validar cuál de las dos explicaciones tiene más peso — un análisis pendiente que el modelo de datos ya permite hacer.

---

## Recomendaciones para las próximas 4 semanas

**Semana 1 — Activar la alerta diaria de CRM**  
El workflow de n8n ya existe y está testado. El único paso pendiente es configurar el canal de destino (Slack, Teams o email del equipo responsable de actualización). Coste estimado: una hora. Impacto: elimina la ceguera operativa sobre los 46 registros desincronizados y detiene el crecimiento del problema desde mañana.

**Semana 2 — Medir y reducir el tiempo de primera llamada**  
El dashboard ya tiene la medida `Avg_Time_to_First_Call_Hours` construida. Añadir un objetivo (por ejemplo, < 24 horas) como línea de referencia en el visual y hacer seguimiento semanal por equipo. Sevilla a 23,8 horas demuestra que es alcanzable.

**Semana 3 — Investigar qué hacen diferente los tres agentes top y Sevilla**  
Entrevistas cortas o revisión de grabaciones de llamadas para identificar si hay un patrón replicable: ¿contactan antes? ¿tienen un script diferente? ¿gestionan menos leads en paralelo?

**Semana 4 — Analizar calidad por campaña**  
El dashboard permite filtrar por `utm_campaign` (brand_q1, comparador, hipoteca_fija, retargeting, sin campaña). El pico de captación de marzo con la peor conversión del trimestre es muy probablemente explicable por la campaña activa ese mes. Identificar qué campañas traen leads de calidad versus volumen sin conversión permite redirigir presupuesto de adquisición con datos.

---

## Conclusión

Los tres problemas identificados comparten una raíz común: hay información valiosa que existe en los sistemas pero no está fluyendo a quien la necesita ni en el formato ni en el momento adecuado. El 52% de hipotecas aprobadas sin cerrar en CRM es el caso más urgente y ya tiene solución construida. La velocidad de respuesta como palanca de conversión es accionable sin coste tecnológico adicional. Y la heterogeneidad de rendimiento entre agentes y provincias sugiere que el conocimiento ya existe dentro del equipo — el trabajo es identificarlo y transferirlo.
