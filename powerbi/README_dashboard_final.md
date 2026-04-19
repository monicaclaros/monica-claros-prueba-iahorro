# Proyecto Power BI — Análisis del Funnel de Leads

## Descripción

Este proyecto consiste en la construcción de un modelo de datos y un dashboard en Power BI para el seguimiento del funnel de captación de leads.

El objetivo es analizar el volumen, la conversión y la eficiencia operativa del proceso comercial, permitiendo una toma de decisiones basada en datos.

---

## Estructura del proyecto

```
powerbi/
│
├── informe.pbix
├── 2.1_modelado.md
├── 2.2_medidas.md
├── 2.3_dashboard.md
├── 2.4_performance.md
└── 2.3_capturas/
    ├── 01_modelo_relaciones.png
    ├── 02_dashboard_overview.png
    ├── 03_dashboard_filtro_fecha.png
    ├── 04_dashboard_filtro_provincia.png
    ├── 05_dashboard_filtro_campaña.png
    ├── 06_dashboard_filtro_provincia_fecha.png
    └── 07_dashboard_tendencia_leads.png
```

---

## Modelo de datos

Se ha implementado un modelo en esquema estrella donde:

- `leads_clean` actúa como tabla de hechos principal.
- `calls` aporta información sobre las llamadas realizadas.
- `mortgage_applications` representa las solicitudes generadas.
- `agents` funciona como dimensión para segmentación por equipo.

Las relaciones están definidas mediante claves (`lead_id`, `agent_id`) con cardinalidad uno a muchos y dirección de filtro simple.

---

## Medidas DAX

Se han implementado las siguientes métricas clave:

- Tasa de conversión lead a solicitud
- Variación interanual (YoY) de leads
- Tiempo medio hasta la primera llamada
- Duración media de llamadas

Todas las medidas responden dinámicamente a los filtros del dashboard.

---

## Dashboard

El dashboard está orientado al seguimiento operativo del funnel.

Incluye:

- KPIs principales
- Evolución mensual del funnel
- Tendencia temporal de leads
- Comparativa por provincia

---

## Filtros

Se han implementado filtros interactivos para facilitar el análisis:

- Filtro temporal (Mes_Orden)
- Filtro por provincia (botones)
- Filtro por campaña (utm_campaign)
- Filtros combinados para análisis segmentado

---

## Visual destacado

El gráfico de tendencia de leads permite analizar la evolución temporal y detectar cambios relevantes en la captación.

Este tipo de visual aporta mayor valor analítico que los gráficos estáticos.

---

## Conclusión

El proyecto proporciona una visión completa del funnel de captación, permitiendo:

- monitorizar el rendimiento
- detectar oportunidades de mejora
- analizar el comportamiento por segmento

---

## Entrega

Incluye:

- Archivo `.pbix`
- Documentación en Markdown
- Capturas del dashboard
