-- iAhorro Prueba Técnica - Ejercicio 1.3: Consistencia entre tablas (3 condiciones)
-- Análisis de integridad referencial y coherencia de datos entre CRM y sistema bancario

-- ========================================
-- CONDICIÓN A: cerrado_ganado sin solicitud
-- ========================================
-- Identifica leads marcados como ganados en el CRM que no tienen registro en el sistema de hipotecas

SELECT
    l.lead_id,
    l.status AS lead_status,
    'sin solicitud en mortgage_applications' AS problema
FROM leads_clean l
LEFT JOIN mortgage_applications ma ON l.lead_id = ma.lead_id
WHERE l.status = 'cerrado_ganado'
  AND ma.lead_id IS NULL;

-- RESULTADO: 0 filas
-- Conclusión: No hay inconsistencias de este tipo. Todos los leads cerrados_ganado tienen solicitud.


-- ========================================
-- CONDICIÓN B: aprobada sin cerrado_ganado
-- ========================================
-- Identifica hipotecas aprobadas cuyo lead en el CRM aún no está marcado como ganado
-- Este es el hallazgo crítico: indica que el CRM no se actualiza tras aprobación bancaria

SELECT
    l.lead_id,
    l.status        AS lead_status,
    ma.status       AS app_status,
    'aprobada sin actualizar CRM' AS problema
FROM leads_clean l
JOIN mortgage_applications ma ON l.lead_id = ma.lead_id
WHERE ma.status = 'aprobada'
  AND l.status != 'cerrado_ganado';

-- RESULTADO: 46 filas (todos con lead_status=solicitud_enviada, app_status=aprobada)
-- Hallazgo crítico: El 52% de las hipotecas aprobadas (46 de 88) no tienen el CRM actualizado.
-- No es ruido aleatorio sino un proceso sistemáticamente roto que requiere atención operacional inmediata.


-- ========================================
-- CONDICIÓN C: call_number inconsistente
-- ========================================
-- Identifica leads cuyo número de secuencia máximo en calls no coincide con el total de llamadas
-- Indica errores en la numeración de llamadas o registros duplicados/faltantes

SELECT
    lead_id,
    COUNT(*)         AS llamadas_reales,
    MAX(call_number) AS max_call_number,
    'call_number no cuadra con total llamadas' AS problema
FROM calls
GROUP BY lead_id
HAVING COUNT(*) != MAX(call_number)
ORDER BY lead_id;

-- RESULTADO: 5 filas
-- LEAD00001: 3 llamadas reales pero max_call_number=2
-- LEAD00051: 3 llamadas reales pero max_call_number=2
-- LEAD00101: 4 llamadas reales pero max_call_number=3
-- LEAD00218: 2 llamadas reales pero max_call_number=1
-- LEAD00322: 2 llamadas reales pero max_call_number=1
--
-- Conclusión: Las anomalías de call_number coinciden mayoritariamente con los leads duplicados
-- detectados en la exploración de datos (LEAD00001, LEAD00051, LEAD00101 fueron re-registrados).
-- Los otros 2 casos indican errores en el secuenciador de llamadas.

/*
CONCLUSIÓN GENERAL (3 CONDICIONES):
- Condición A (0 filas): Sin problemas de leads ganados sin solicitud
- Condición B (46 filas): Crítico - más de la mitad de aprobaciones no actualizadas en CRM
- Condición C (5 filas): Problemas de numeración principalmente vinculados a leads duplicados
*/
