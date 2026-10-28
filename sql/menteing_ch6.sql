-- ============================================================
--  MENTEING CH6
-- ============================================================

-- ------------------------------------------------------------
-- 1. LIMPIEZA TOTAL DE TABLAS
-- ------------------------------------------------------------
DROP TABLE IF EXISTS NotaClinica CASCADE;
DROP TABLE IF EXISTS Sesion CASCADE;
DROP TABLE IF EXISTS Cita CASCADE;
DROP TABLE IF EXISTS ProfesionalAsignado CASCADE;
DROP TABLE IF EXISTS Alerta CASCADE;
DROP TABLE IF EXISTS EstadoAnimo CASCADE;
DROP TABLE IF EXISTS HorasSueno CASCADE;
DROP TABLE IF EXISTS RegistroDiario CASCADE;
DROP TABLE IF EXISTS HorarioDisponible CASCADE;
DROP TABLE IF EXISTS Profesional CASCADE;
DROP TABLE IF EXISTS Examen CASCADE;
DROP TABLE IF EXISTS Asistencia CASCADE;
DROP TABLE IF EXISTS Curso CASCADE;
DROP TABLE IF EXISTS Materia CASCADE;
DROP TABLE IF EXISTS Estudiante CASCADE;
DROP TABLE IF EXISTS Carrera CASCADE;

-- ------------------------------------------------------------
-- 2. CREACIÓN DE TABLAS (CHALLENGE 4)
-- ------------------------------------------------------------
CREATE TABLE Carrera (
    IdCarrera SERIAL PRIMARY KEY, 
    NombreCarrera VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Materia (
    IdMateria SERIAL PRIMARY KEY, 
    NombreMateria VARCHAR(100) NOT NULL, 
    IdCarrera INT NOT NULL REFERENCES Carrera(IdCarrera)
);

CREATE TABLE Estudiante (
    Matricula VARCHAR(20) PRIMARY KEY, 
    NombreCompleto VARCHAR(150) NOT NULL, 
    Email VARCHAR(150) NOT NULL UNIQUE, 
    IdCarrera INT NOT NULL REFERENCES Carrera(IdCarrera)
);

CREATE TABLE Curso (
    IdCurso SERIAL PRIMARY KEY, 
    Matricula VARCHAR(20) NOT NULL REFERENCES Estudiante(Matricula), 
    IdMateria INT NOT NULL REFERENCES Materia(IdMateria), 
    PeriodoAcademico VARCHAR(20) NOT NULL, 
    EstadoCurso VARCHAR(20) DEFAULT 'En Curso' CHECK (EstadoCurso IN ('En Curso','Aprobado','Reprobado'))
);

CREATE TABLE Asistencia (
    IdAsistencia SERIAL PRIMARY KEY, 
    IdCurso INT NOT NULL REFERENCES Curso(IdCurso), 
    FechaAsistencia DATE NOT NULL, 
    EstadoAsistencia VARCHAR(20) NOT NULL CHECK (EstadoAsistencia IN ('Presente','Ausente','Justificado','Tardía')), 
    Observacion TEXT
);

CREATE TABLE Examen (
    IdExamen SERIAL PRIMARY KEY, 
    IdCurso INT NOT NULL REFERENCES Curso(IdCurso), 
    TipoExamen VARCHAR(50) NOT NULL CHECK (TipoExamen IN ('Primer Parcial','Segundo Parcial','Final','Trabajo Práctico')), 
    Oportunidad VARCHAR(20) NOT NULL CHECK (Oportunidad IN ('1ra Oportunidad','2da Oportunidad','3ra Oportunidad','Supletorio')), 
    FechaExamen DATE NOT NULL, 
    Calificacion NUMERIC(3,1) CHECK (Calificacion BETWEEN 1.0 AND 5.0), 
    AsistioExamen BOOLEAN DEFAULT TRUE, 
    Comentarios TEXT
);

CREATE TABLE Profesional (
    IdProfesional SERIAL PRIMARY KEY, 
    NombreCompleto VARCHAR(150) NOT NULL, 
    Especialidad VARCHAR(50) NOT NULL CHECK (Especialidad IN ('Psicología','Orientación','Psiquiatría')), 
    EstadoActivo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE HorarioDisponible (
    IdHorario SERIAL PRIMARY KEY, 
    IdProfesional INT NOT NULL REFERENCES Profesional(IdProfesional), 
    DiaSemana VARCHAR(20) NOT NULL CHECK (DiaSemana IN ('Lunes','Martes','Miércoles','Jueves','Viernes')), 
    HoraInicio TIME NOT NULL, 
    HoraFin TIME NOT NULL, 
    CHECK (HoraFin > HoraInicio)
);

CREATE TABLE RegistroDiario (
    IdRegistro SERIAL PRIMARY KEY, 
    Matricula VARCHAR(20) NOT NULL REFERENCES Estudiante(Matricula), 
    FechaRegistro TIMESTAMP NOT NULL DEFAULT NOW(), 
    NivelEstres INT NOT NULL CHECK (NivelEstres BETWEEN 1 AND 10)
);

CREATE TABLE HorasSueno (
    IdHorasSueno SERIAL PRIMARY KEY, 
    IdRegistro INT NOT NULL REFERENCES RegistroDiario(IdRegistro), 
    RangoHoras VARCHAR(50) NOT NULL CHECK (RangoHoras IN ('sin dormir','menos de 3 h','menos de 6 h','8 horas en promedio','entre 8 y 12h','más de 12 h')), 
    TipoSueno VARCHAR(50) DEFAULT 'Nocturno', 
    FechaHoraRegistro TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE EstadoAnimo (
    IdEstadoAnimo SERIAL PRIMARY KEY, 
    IdRegistro INT NOT NULL REFERENCES RegistroDiario(IdRegistro), 
    NivelAnimo INT NOT NULL CHECK (NivelAnimo BETWEEN 1 AND 10), 
    EtiquetaAnimo VARCHAR(50) NOT NULL CHECK (EtiquetaAnimo IN ('Triste','Feliz','Enojado','Energico','Alegre','Neutral','Agotado','Ansioso','Frustrado','Motivado','Apatico')), 
    Comentario TEXT, 
    FechaHoraRegistro TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE Alerta (
    IdAlerta SERIAL PRIMARY KEY, 
    Matricula VARCHAR(20) NOT NULL REFERENCES Estudiante(Matricula), 
    TipoAlerta VARCHAR(50) NOT NULL CHECK (TipoAlerta IN ('Estrés Alto','Sueño Bajo','Riesgo Burnout','Bajo Rendimiento')), 
    FechaAlerta TIMESTAMP NOT NULL DEFAULT NOW(), 
    EstadoAlerta VARCHAR(20) NOT NULL DEFAULT 'Nueva' CHECK (EstadoAlerta IN ('Nueva','En Revisión','Atendida','Cerrada')), 
    Descripcion TEXT
);

-- CORRECCIÓN: Tabla ProfesionalAsignado
CREATE TABLE ProfesionalAsignado (
    IdProfesionalAsignado SERIAL PRIMARY KEY, 
    IdAlerta INT NOT NULL REFERENCES Alerta(IdAlerta), 
    IdProfesional INT NOT NULL REFERENCES Profesional(IdProfesional), 
    FechaAsignacion TIMESTAMP NOT NULL DEFAULT NOW(), 
    ObservacionesTecnicas TEXT, 
    Activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE Cita (
    IdCita SERIAL PRIMARY KEY, 
    Matricula VARCHAR(20) NOT NULL REFERENCES Estudiante(Matricula), 
    IdProfesional INT NOT NULL REFERENCES Profesional(IdProfesional), 
    IdAlerta INT UNIQUE REFERENCES Alerta(IdAlerta), 
    FechaHora TIMESTAMP NOT NULL, 
    EstadoCita VARCHAR(20) NOT NULL DEFAULT 'Pendiente' CHECK (EstadoCita IN ('Pendiente','Completada','Cancelada','Ausente'))
);

CREATE TABLE Sesion (
    IdSesion SERIAL PRIMARY KEY, 
    IdCita INT NOT NULL REFERENCES Cita(IdCita), 
    FechaSesion TIMESTAMP NOT NULL DEFAULT NOW(), 
    NumeroSesion INT NOT NULL, 
    Modalidad VARCHAR(20) CHECK (Modalidad IN ('Presencial','Virtual')), 
    ResumenObjetivo TEXT
);

CREATE TABLE NotaClinica (
    IdNota SERIAL PRIMARY KEY, 
    IdSesion INT NOT NULL REFERENCES Sesion(IdSesion), 
    Contenido TEXT NOT NULL, 
    TipoNota VARCHAR(30) CHECK (TipoNota IN ('Evolución','Evaluación','Seguimiento')), 
    FechaNota TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- 3. CARGA DE DATOS MAESTROS BASE
-- ------------------------------------------------------------
INSERT INTO Carrera (NombreCarrera) VALUES ('Ingeniería en Sistemas'), ('Ingeniería Civil'), ('Ingeniería Electrónica'), ('Ingeniería Industrial');
INSERT INTO Estudiante (Matricula, NombreCompleto, Email, IdCarrera) VALUES ('2021-0001', 'Ana Lopez Garcia', 'ana.lopez@gmail.com', 1), ('2021-0002', 'Carlos Martinez Ruiz', 'carlos.mtz@gmail.com', 1), ('2020-0010', 'Sofia Benitez Torres', 'sofia.benitez@gmail.com',2), ('2022-0033', 'Diego Ramirez Flores', 'diego.rmz@gmail.com', 3), ('2021-0045', 'Valentina Sosa Nunez', 'vale.sosa@gmail.com', 4), ('2019-0088', 'Lucia Fernandez Pardo', 'lucia.fer@gmail.com', 2), ('2023-0005', 'Mateo Gonzalez Vera', 'mateo.glez@gmail.com', 1), ('2022-0099', 'Camila Rojas Mendoza', 'camila.rojas@gmail.com', 1);
INSERT INTO Profesional (NombreCompleto, Especialidad, EstadoActivo) VALUES ('Dra. Laura Peralta', 'Psicología', TRUE), ('Lic. Jorge Aquino', 'Orientación', TRUE), ('Dr. Marcos Villalba', 'Psiquiatría', TRUE), ('Lic. Patricia Duarte', 'Psicología', TRUE);

-- ------------------------------------------------------------
-- 4. CREACIÓN DE LAS 4 FUNCIONES (CHALLENGE 5)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION ReporteAlertasPorCarrera(p_fecha_inicio DATE, p_fecha_fin DATE) RETURNS TABLE (NombreCarrera VARCHAR, TotalEstudiantes BIGINT, TipoAlertaFrecuente VARCHAR, TotalAlertas BIGINT) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT c.NombreCarrera::VARCHAR, COUNT(DISTINCT e.Matricula) AS TotalEstudiantes, MODE() WITHIN GROUP (ORDER BY a.TipoAlerta)::VARCHAR AS TipoAlertaFrecuente, COUNT(a.IdAlerta) AS TotalAlertas FROM Alerta a JOIN Estudiante e ON a.Matricula = e.Matricula JOIN Carrera c ON e.IdCarrera = c.IdCarrera WHERE a.FechaAlerta BETWEEN p_fecha_inicio AND p_fecha_fin GROUP BY c.NombreCarrera ORDER BY TotalAlertas DESC; END; $$;
CREATE OR REPLACE FUNCTION HistorialBienestarEstudiante(p_matricula VARCHAR(20)) RETURNS TABLE (FechaRegistro TIMESTAMP, NivelEstres INT, RangoHoras VARCHAR, TipoSueno VARCHAR, EtiquetaAnimo VARCHAR, NivelAnimo INT, Comentario TEXT) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT rd.FechaRegistro, rd.NivelEstres, hs.RangoHoras::VARCHAR, hs.TipoSueno::VARCHAR, ea.EtiquetaAnimo::VARCHAR, ea.NivelAnimo, ea.Comentario FROM RegistroDiario rd LEFT JOIN HorasSueno hs ON hs.IdRegistro = rd.IdRegistro LEFT JOIN EstadoAnimo ea ON ea.IdRegistro = rd.IdRegistro WHERE rd.Matricula = p_matricula ORDER BY rd.FechaRegistro DESC; END; $$;
CREATE OR REPLACE FUNCTION PromedioEstresEstudiante(p_matricula VARCHAR(20), p_fecha_inicio DATE, p_fecha_fin DATE) RETURNS TABLE (Mes TEXT, PromedioEstres NUMERIC(4,2)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT TO_CHAR(DATE_TRUNC('month', FechaRegistro), 'Month YYYY') AS Mes, ROUND(AVG(NivelEstres), 2) AS PromedioEstres FROM RegistroDiario WHERE Matricula = p_matricula AND FechaRegistro BETWEEN p_fecha_inicio AND p_fecha_fin GROUP BY DATE_TRUNC('month', FechaRegistro) ORDER BY DATE_TRUNC('month', FechaRegistro); END; $$;
CREATE OR REPLACE FUNCTION TotalCitasCompletadasProfesional(p_id_profesional INT, p_fecha_inicio DATE, p_fecha_fin DATE) RETURNS INTEGER LANGUAGE plpgsql AS $$ DECLARE v_total INTEGER; BEGIN SELECT COUNT(*) INTO v_total FROM Cita WHERE IdProfesional = p_id_profesional AND EstadoCita = 'Completada' AND FechaHora BETWEEN p_fecha_inicio AND p_fecha_fin; RETURN COALESCE(v_total, 0); END; $$;

-- ------------------------------------------------------------
-- 5. GENERACIÓN MASIVA (1.000.000 DE REGISTROS)
-- ------------------------------------------------------------
INSERT INTO RegistroDiario (Matricula, FechaRegistro, NivelEstres) 
SELECT (ARRAY['2021-0001','2021-0002','2020-0010','2022-0033','2021-0045','2019-0088','2023-0005','2022-0099'])[floor(random() * 8 + 1)], NOW() - ((random() * 730)::int * INTERVAL '1 day'), floor(random() * 10 + 1)::int 
FROM generate_series(1, 600000);

INSERT INTO Alerta (Matricula, TipoAlerta, FechaAlerta, EstadoAlerta) 
SELECT (ARRAY['2021-0001','2021-0002','2020-0010','2022-0033','2021-0045','2019-0088','2023-0005','2022-0099'])[floor(random() * 8 + 1)], (ARRAY['Estrés Alto', 'Sueño Bajo', 'Riesgo Burnout', 'Bajo Rendimiento'])[floor(random() * 4 + 1)], NOW() - ((random() * 730)::int * INTERVAL '1 day'), (ARRAY['Nueva', 'En Revisión', 'Atendida', 'Cerrada'])[floor(random() * 4 + 1)] 
FROM generate_series(1, 200000);

ALTER TABLE Cita DISABLE TRIGGER ALL;
INSERT INTO Cita (Matricula, IdProfesional, IdAlerta, FechaHora, EstadoCita) 
SELECT (ARRAY['2021-0001','2021-0002','2020-0010','2022-0033','2021-0045','2019-0088','2023-0005','2022-0099'])[floor(random() * 8 + 1)], floor(random() * 4 + 1)::int, NULL, NOW() - ((random() * 730)::int * INTERVAL '1 day'), (ARRAY['Pendiente','Completada','Cancelada','Ausente'])[floor(random() * 4 + 1)] 
FROM generate_series(1, 200000);
ALTER TABLE Cita ENABLE TRIGGER ALL;