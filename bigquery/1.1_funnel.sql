-- iAhorro Prueba Técnica - Ejercicio 1.1: Funnel semanal Q1 2025
-- Query para analizar la conversión de leads a través del embudo de ventas por semana

SELECT
    CAST(DATE_TRUNC('week', l.created_at) AS DATE) AS semana_inicio,
    DATE_PART('week', l.created_at)                AS semana_iso,
    COUNT(DISTINCT l.lead_id)                      AS leads_captados,
    COUNT(DISTINCT c.lead_id)                      AS leads_con_llamada,
    COUNT(DISTINCT ma.lead_id)                     AS leads_con_solicitud,
    COUNT(DISTINCT CASE WHEN ma.status = 'aprobada' THEN ma.lead_id END) AS solicitudes_aprobadas,
    ROUND(COUNT(DISTINCT ma.lead_id) * 100.0 / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1) AS pct_lead_a_solicitud,
    ROUND(COUNT(DISTINCT CASE WHEN ma.status = 'aprobada' THEN ma.lead_id END) * 100.0 / NULLIF(COUNT(DISTINCT ma.lead_id), 0), 1) AS pct_solicitud_a_aprobacion
FROM leads_clean l
LEFT JOIN calls c ON l.lead_id = c.lead_id
LEFT JOIN mortgage_applications ma ON l.lead_id = ma.lead_id
WHERE l.created_at >= '2025-01-01'
  AND l.created_at <  '2025-04-01'
GROUP BY 1, 2
ORDER BY 1;

/*
RESULTADOS EJECUTADOS:

semana_inicio | semana_iso | leads_captados | leads_con_llamada | leads_con_solicitud | solicitudes_aprobadas | pct_lead_a_solicitud | pct_solicitud_a_aprobacion
2024-12-30    | 1          | 18             | 16                | 2                   | 1                     | 11.1                 | 50.0
2025-01-06    | 2          | 12             | 12                | 1                   | 1                     | 8.3                  | 100.0
2025-01-13    | 3          | 16             | 14                | 3                   | 0                     | 18.8                 | 0.0
2025-01-20    | 4          | 23             | 22                | 5                   | 2                     | 21.7                 | 40.0
2025-01-27    | 5          | 20             | 19                | 10                  | 6                     | 50.0                 | 60.0
2025-02-03    | 6          | 22             | 17                | 5                   | 3                     | 22.7                 | 60.0
2025-02-10    | 7          | 16             | 14                | 7                   | 2                     | 43.8                 | 28.6
2025-02-17    | 8          | 26             | 21                | 9                   | 1                     | 34.6                 | 11.1
2025-02-24    | 9          | 14             | 12                | 6                   | 2                     | 42.9                 | 33.3
2025-03-03    | 10         | 29             | 24                | 5                   | 0                     | 17.2                 | 0.0
2025-03-10    | 11         | 20             | 19                | 5                   | 4                     | 25.0                 | 80.0
2025-03-17    | 12         | 22             | 18                | 6                   | 4                     | 27.3                 | 66.7
2025-03-24    | 13         | 18             | 14                | 6                   | 5                     | 33.3                 | 83.3
2025-03-31    | 14         | 3              | 3                 | 1                   | 1                     | 33.3                 | 100.0

ANÁLISIS:
La semana 5 (27 ene) destaca con la mayor tasa de conversión lead→solicitud (50%), el doble de la media.
La semana 10 (3 mar) es el caso opuesto: el mayor volumen de leads captados (29) pero la peor conversión
(17.2%) y 0 aprobaciones, patrón clásico de cantidad sobre calidad. Las semanas 11-13 muestran tasas de
aprobación altas y consecutivas (80%, 66.7%, 83.3%), probable efecto pipeline: las solicitudes de semanas
anteriores maduran con retraso natural. La semana 14 (31 mar) solo tiene 3 leads por ser semana incompleta,
no es representativa.
*/
