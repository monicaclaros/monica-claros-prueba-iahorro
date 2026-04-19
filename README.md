# Prueba Técnica — Data & Automation Analyst | iAhorro
**Candidata:** Mónica Claros  
**Fecha de entrega:** Abril 2025  
**Herramienta SQL:** MotherDuck (DuckDB cloud) — Notebook "iAhorro"

## Resumen ejecutivo
La prueba se ha abordado con un enfoque práctico orientado a negocio, priorizando la calidad del dato y la identificación de fricciones operativas en el funnel. El análisis revela un problema sistemático de sincronización entre el sistema bancario y el CRM que está afectando significativamente al reporting de conversión. Además, se identifican variaciones relevantes en la eficiencia del funnel que sugieren oportunidades de mejora en la gestión operativa y la calidad de los leads.

---

## Organización de la entrega

```
monica-claros-prueba-iahorro/
├── README.md                        ← este archivo
├── 0_exploracion.md                 ← exploración de datos previa al análisis
├── bigquery/
│   ├── 1.1_funnel.sql + resultados  ← funnel semanal Q1 2025
│   ├── 1.2_agentes.sql + resultados ← top 3 agentes por conversión
│   ├── 1.3_consistencia.sql + resultados ← anomalías entre tablas
│   ├── 1.4_optimizacion.sql         ← query optimizada con explicaciones
│   └── 1.5_diseno_tabla.md          ← diseño tabla eventos (conceptual)
├── powerbi/
│   ├── iAhorro Dashboard.pbix
│   ├── 2.1_modelado.md
│   ├── 2.2_medidas.md
│   ├── 2.3_dashboard.md
│   └── 2.4_performance.md
├── n8n/
│   ├── 3.1_workflow.json
│   ├── 3.1_workflow_captura.png
│   ├── 3.1_workflow_webhook.png
│   └── 3.1_explicacion.md                       
└── bonus/
    └── 4_analisis_negocio.md        ← análisis para Head of Operations
```

---
---

## Decisiones técnicas tomadas

### Herramienta SQL
Usé **MotherDuck** (DuckDB en cloud) en lugar de BigQuery Sandbox. Ambas son opciones válidas según el enunciado. La ventaja de DuckDB para este dataset es la velocidad de carga directa desde CSV sin configuración de proyecto cloud.

### Estructura de datos en MotherDuck
Al importar los CSVs, cada archivo quedó como base de datos separada (`leads`, `calls`, `mortgage_app`, `agents`). Para simplificar los queries, creé vistas unificadas en `my_db`:

```sql
CREATE OR REPLACE VIEW my_db.main.leads AS SELECT * FROM leads.leads;
CREATE OR REPLACE VIEW my_db.main.calls AS SELECT * FROM calls.calls;
CREATE OR REPLACE VIEW my_db.main.mortgage_applications AS SELECT * FROM mortgage_app.mortgage_app;
CREATE OR REPLACE VIEW my_db.main.agents AS SELECT * FROM agents.agents;
```

### Vista leads_clean
Creé una vista `leads_clean` que resuelve dos problemas detectados en la exploración:
1. **Duplicados**: 3 lead_ids aparecen 2 veces con fechas distintas (leads re-registrados). Se colapsan con `GROUP BY lead_id` conservando el `MIN(created_at)`.
2. **Inconsistencia de mayúsculas en status**: `Perdido`, `PERDIDO`, `Nuevo`, `NUEVO` se normalizan con `LOWER()`.

Resultado: 803 → 800 filas limpias.

### Agentes excluidos del análisis de rendimiento
Los agent_ids `AGT097`, `AGT098`, `AGT099` no existen en la tabla `agents` (el equipo activo llega hasta `AGT020`). Se excluyen del ejercicio 1.2 por ser agentes que ya no están en la empresa.

### Power BI
Modelo en esquema estrella con `leads_clean` como tabla de hechos central. Tabla de fechas generada en DAX. Tres medidas implementadas: tasa de conversión lead-a-solicitud, variación YoY de leads captados y tiempo medio hasta primera llamada en horas.

### n8n
Workflow con 6 nodos: Schedule Trigger (lunes-viernes 8:00h) → simulación de datos BigQuery vía nodo Code → filtro de leads con status nuevo y más de 48h de espera → IF condicional → construcción del mensaje → envío via HTTP Request a webhook. Probado y funcionando: el webhook recibió correctamente los 3 leads de prueba con todos los campos requeridos (ID, fecha, fuente, importe).

---

## Hallazgo más relevante

**El 52% de las hipotecas aprobadas no tienen el CRM actualizado.** 46 de 88 solicitudes con `status = aprobada` en `mortgage_applications` mantienen `status = solicitud_enviada` en `leads`. El patrón es sistemático (los 46 tienen exactamente el mismo status), lo que apunta a un proceso operacional roto, no a errores puntuales. Detalle completo en `0_exploracion.md` y `bigquery/1.3_resultados.txt`.

Este fallo provoca una subestimación del rendimiento comercial y puede estar afectando tanto a la toma de decisiones como a la evaluación del equipo.

---

## Qué haría diferente con más tiempo

1. **n8n — Ejercicio 3.2:** Implementar el loop de PATCH por lead con retry ante error 429, backoff exponencial y notificación de fallos persistentes.
2. **Análisis de fuente de captación:** Cruzar la semana de captación con `utm_campaign` para validar la hipótesis de que el pico de leads de la semana 10 vino de una campaña de menor calidad.
3. **Tests de integridad automatizados:** Convertir los queries de la Parte 0 en checks recurrentes con dbt tests en lugar de queries manuales.
4. **Power BI — optimización:** Revisar rendimiento con Performance Analyzer y reducir cardinalidad en columnas de texto.

---

## Partes incompletas

| Parte | Estado |
|-------|--------|
| Parte 0 — Exploración | Completa |
| Parte 1 — SQL (1.1–1.5) | Completa |
| Parte 2 — Power BI | Completa |
| Parte 3 — n8n (3.1) | Completa |
| Parte 3 — n8n (3.2 errores) | Diseño documentado, sin implementar |
| Parte 4 — Análisis de negocio | Completa |
