-- ============================================================
-- MenteIng - Challenge 6: Optimización mediante índices
-- Ejecutar DESPUÉS de menteing_ch6.sql
-- ============================================================

-- Función 1: ReporteAlertasPorCarrera (filtro por rango de fechas)
CREATE INDEX idx_alerta_fecha
    ON Alerta(FechaAlerta);

-- Funciones 2 y 3: HistorialBienestarEstudiante y PromedioEstresEstudiante
-- (búsqueda por matrícula y ordenamiento por fecha)
CREATE INDEX idx_registro_matricula_fecha
    ON RegistroDiario(Matricula, FechaRegistro DESC);

-- Función 4: TotalCitasCompletadasProfesional
-- (filtro por profesional, estado de cita y fecha)
CREATE INDEX idx_cita_prof_estado_fecha
    ON Cita(IdProfesional, EstadoCita, FechaHora);

-- ------------------------------------------------------------
-- Comparación de rendimiento (opcional)
-- Para medir "sin índice", ejecutar primero:
--   DROP INDEX idx_alerta_fecha, idx_registro_matricula_fecha, idx_cita_prof_estado_fecha;
-- y luego volver a crearlos.
-- ------------------------------------------------------------
-- EXPLAIN ANALYZE SELECT * FROM ReporteAlertasPorCarrera('2025-01-01', '2026-12-31');
-- EXPLAIN ANALYZE SELECT * FROM HistorialBienestarEstudiante('2021-0001');
-- EXPLAIN ANALYZE SELECT * FROM PromedioEstresEstudiante('2021-0001', '2025-01-01', '2026-12-31');
-- EXPLAIN ANALYZE SELECT TotalCitasCompletadasProfesional(1, '2025-01-01', '2026-12-31');
