# Análisis del Funnel Hipotecario — iAhorro
**Para:** Head of Operations  
**Fecha:** Abril 2025

---

El análisis del dataset del primer trimestre de 2025 revela tres patrones que merecen atención inmediata.

**El embudo tiene una fuga crítica entre aprobación bancaria y cierre en CRM.** De las 88 solicitudes que el banco ha aprobado, 46 (el 52%) siguen figurando en el sistema como `solicitud_enviada` en lugar de `cerrado_ganado`. Esto no es un error puntual: los 46 registros tienen exactamente el mismo status, lo que indica que el proceso de actualización del CRM tras recibir la confirmación bancaria sencillamente no se está ejecutando. Como consecuencia, cualquier métrica de conversión extraída del CRM subestima el rendimiento real del equipo en al menos un 50%.

**El volumen de captación no predice el volumen de negocio.** La semana del 3 de marzo fue la de mayor captación del trimestre (29 leads), pero también la de menor tasa de conversión a solicitud (17.2%) y cero aprobaciones. Por el contrario, la semana del 27 de enero, con solo 20 leads, produjo la mejor tasa lead→solicitud del período (50%). La calidad de la fuente de captación importa más que el volumen bruto.

**Tres agentes concentran la mejor eficiencia del equipo.** Agente 5 (34.9%), Agente 13 y Agente 3 (34.2% cada uno) convierten a más del doble de la tasa media observable. Los tres operan desde Madrid salvo Agente 3 (Valencia), y pertenecen a equipos distintos. Hay algo en su forma de trabajar los leads que no está replicado en el resto del equipo.

---

**Recomendación para las próximas 4 semanas:**

Implementar un proceso automático de sincronización de status entre el sistema bancario y el CRM. Cada vez que una solicitud pase a `aprobada` en `mortgage_applications`, el status del lead correspondiente debe actualizarse automáticamente a `cerrado_ganado` sin intervención manual. Mientras se desarrolla esa integración, un recordatorio diario automatizado a los agentes con solicitudes aprobadas sin cerrar en CRM costaría pocas horas de implementación y corregiría el problema de forma inmediata.

**Indicador de seguimiento semanal:** porcentaje de solicitudes `aprobada` cuyo lead tiene `cerrado_ganado` en CRM. Hoy está en el 48%. El objetivo es llegar al 95% en cuatro semanas.
