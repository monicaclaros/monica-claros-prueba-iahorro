# Exploración de Datos — iAhorro Prueba Técnica

## 1. Recuento de filas

| Tabla | Filas reales | Filas esperadas | Diferencia |
|-------|-------------|-----------------|------------|
| leads | 803 | ~800 | +3 (duplicados) |
| calls | 1409 | ~1500 | -91 |
| mortgage_applications | 217 | ~250 | -33 |
| agents | 20 | 20 | 0 ✅ |

Las diferencias en calls y mortgage_applications están dentro de lo razonable para datos de producción. Los 3 leads extra se explican por duplicados (ver punto 4).

## 2. Valores nulos

**leads:**
- `utm_campaign`: 172 nulos (21.4%) — nulo estructural, tráfico directo sin campaña. Se mantiene.
- `requested_amount`: 65 nulos (8.1%) — se excluyen de análisis de importes pero se mantienen en conteos generales.
- `assigned_agent_id`: 0 nulos ✅

**mortgage_applications:**
- `approved_amount`: 129 nulos — exactamente 217-88=129, es decir, solo las solicitudes aprobadas tienen importe. Nulo estructural ✅
- `decision_at`: 95 nulos — coincide con solicitudes pendientes (21) + en revisión (53) + algunas canceladas sin fecha. Nulo estructural ✅

## 3. Consistencia de columnas categóricas

**leads.status** — problema encontrado:
| Valor correcto | Variantes | Frecuencia |
|----------------|-----------|------------|
| perdido | Perdido, PERDIDO | 4 + 3 = 7 filas extra |
| nuevo | Nuevo, NUEVO | 1 + 2 = 3 filas extra |

Decisión: normalizar con `LOWER()` en la vista `leads_clean`.

**calls.outcome** y **mortgage_applications.status**: sin variantes inesperadas ✅

## 4. Registros duplicados

3 lead_ids aparecen exactamente 2 veces: LEAD00001, LEAD00051, LEAD00101.

No son inserciones dobles idénticas: las filas difieren en:
- `created_at` (meses de diferencia)
- `assigned_agent_id` (en 2 de los 3 casos el agente cambió)

**Interpretación:** Leads re-registrados en el sistema, probablemente por reasignación de agente.

**Decisión:** Colapsar con `GROUP BY lead_id`, conservando `MIN(created_at)` como fecha de captación original.
- Resultado: 803 → 800 filas en `leads_clean`

## 5. Inconsistencias entre tablas

**Calls huérfanas:** 8 llamadas (CALL001402–CALL001409) referencian lead_ids LEAD09900–LEAD09907 que no existen en leads.
- Probable causa: leads eliminados del sistema.
- Afecta al 0.6% de calls.
- Decisión: excluir de análisis que requieran join con leads.

**Agentes fantasma:** 40 leads tienen `assigned_agent_id` con valores AGT097, AGT098, AGT099 que no existen en la tabla agents (el equipo activo tiene IDs hasta AGT020).
- Son agentes que ya no están en la empresa.
- Afecta al 5% de leads.
- Decisión: excluir del análisis de rendimiento por agente.

## 6. Valores numéricos anómalos

**calls.duration_sec = 0:** 42 llamadas con duración cero (3% del total).
- Las de outcome `no_contesta` (16) son esperables.
- Las anómalas son las 18 con outcomes activos: `interesado` (5), `cita_agendada` (7), `solicitud_iniciada` (6).
- Es imposible tener esos resultados en 0 segundos. Probable error de registro.
- Decisión: excluir de métricas de duración media.

**leads.requested_amount:** rango 80.000€ — 449.000€, media 268.130€, mediana 272.000€.
- Distribución simétrica sin outliers extremos.
- Sin anomalías ✅

**Inconsistencia CRM:** 46 leads (52% de las 88 solicitudes aprobadas) tienen `mortgage_applications.status = aprobada` pero `leads.status = solicitud_enviada`.
- El CRM no se actualizó tras la aprobación bancaria.
- Es el hallazgo de calidad de dato más relevante del dataset.
- Apunta a un proceso operacional roto que requiere atención inmediata.

**call_number vs conteo real:** 5 leads donde `MAX(call_number) ≠ COUNT(*)` en calls.
- 3 de ellos coinciden con los leads duplicados (LEAD00001, LEAD00051, LEAD00101).
- Los otros 2 (LEAD00218, LEAD00322) tienen 2 llamadas con `call_number = 1`, es decir, el secuenciador no incrementó correctamente.

## 7. Patrones temporales

**Distribución de creación de leads:** Concentración en Q1 2025 (según especificación del test). Sin anomalías de fechas futuras o pasadas.

**Distribución de llamadas:** Correlación esperable con leads (más leads → más llamadas). Sin gaps temporales inexplicados.

**Ciclo de solicitud:** Promedio ~15-30 días desde creación de lead a solicitud de hipoteca. Dentro de parámetros operacionales normales.

## 8. Decisiones de limpieza aplicadas

1. **Vista leads_clean:** Colapsa duplicados, normaliza mayúsculas, conserva MIN(created_at).
2. **Filtros en queries:** Excluir agentes fantasma (AGT097-099), calls huérfanas, duration_sec = 0.
3. **Tratamiento de nulos:** Mantener estructurales, excluir en agregaciones numéricas donde sea necesario.
4. **Validaciones posteriores:** Monitorear la inconsistencia CRM (condición B del test) como métrica de salud operacional.

## Resumen ejecutivo

**Calidad de dato:** Media-Alta
- 97% de integridad referencial (solo 0.6% calls huérfanas)
- Inconsistencia operacional crítica: 52% de aprobaciones no actualizadas en CRM
- Pequeños errores de registro (3% duration=0) manejables con filtros

**Recomendaciones:**
1. Implementar sincronización automática CRM ↔ sistema bancario para estatuses de aprobación
2. Auditar el secuenciador de call_number para evitar resets
3. Mantener vista leads_clean para análisis (duplicados colapsados)
4. Monitorear agentes fantasma: eliminar o reactivar en el sistema
