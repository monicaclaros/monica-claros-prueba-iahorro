-- iAhorro Prueba Técnica - Ejercicio 1.2: Top 3 agentes por tasa de conversión
-- Query para identificar los agentes más eficientes en la conversión de leads a solicitudes

SELECT
    a.name,
    a.team,
    a.office,
    COUNT(DISTINCT l.lead_id)                                AS leads_asignados,
    COUNT(DISTINCT ma.lead_id)                               AS solicitudes_generadas,
    ROUND(COUNT(DISTINCT ma.lead_id) * 100.0 / NULLIF(COUNT(DISTINCT l.lead_id), 0), 1) AS tasa_conversion_pct
FROM agents a
JOIN leads_clean l ON a.agent_id = l.assigned_agent_id
LEFT JOIN mortgage_applications ma ON l.lead_id = ma.lead_id
WHERE a.active = true
  AND l.assigned_agent_id NOT IN ('AGT097', 'AGT098', 'AGT099')
GROUP BY a.agent_id, a.name, a.team, a.office
HAVING COUNT(DISTINCT l.lead_id) >= 15
ORDER BY tasa_conversion_pct DESC
LIMIT 3;

/*
RESULTADOS EJECUTADOS:

name      | team     | office   | leads_asignados | solicitudes_generadas | tasa_conversion_pct
Agente 5  | equipo_b | madrid   | 43              | 15                    | 34.9
Agente 13 | equipo_a | madrid   | 38              | 13                    | 34.2
Agente 3  | equipo_c | valencia | 38              | 13                    | 34.2

ANÁLISIS:
El agente con mayor tasa (Agente 5, 34.9%) coincide en este caso con el mayor número absoluto de
solicitudes (15). Sin embargo, la distinción entre tasa y volumen sigue siendo relevante: Agentes 13
y 3 tienen idéntica tasa (34.2%) con igual volumen (13), pero carteras de leads distintas. Si solo
miráramos volumen absoluto, el ranking podría estar sesgado hacia agentes con más leads asignados
independientemente de su eficiencia.
*/
