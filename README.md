# MenteIng - Sistema de Alerta Temprana y Seguimiento Clínico para Estudiantes de Ingeniería

Base de datos relacional en **PostgreSQL** para monitorear el bienestar emocional de estudiantes de ingeniería, cruzarlo con su desempeño académico y detectar a tiempo señales de estrés alto, falta de sueño o riesgo de burnout, para derivarlos a profesionales de la salud.

Proyecto desarrollado para la materia **Bases de Datos** (Ingeniería Informática, Universidad Católica "Nuestra Señora de la Asunción"), construido de forma incremental a lo largo de varios *challenges*: modelado, normalización, funciones SQL y optimización con índices.

---

## Problema que resuelve

Los datos de bienestar estudiantil suelen ser subjetivos y estar dispersos. MenteIng los convierte en información objetiva y consultable para tres tipos de usuarios:

| Actor | Qué hace en el sistema |
|---|---|
| **Estudiante** | Registra a diario su nivel de estrés, horas de sueño y estado de ánimo; reserva citas con especialistas. |
| **Profesional de salud** (psicología, orientación, psiquiatría) | Revisa el historial del paciente, atiende citas y registra sesiones y notas clínicas. |
| **Administrador** | Mantiene catálogos (carreras, profesionales) y consulta reportes para intervenciones institucionales. |

---

## 🗂️ Modelo de datos

El esquema final tiene **16 tablas** normalizadas hasta **3FN**, organizadas en tres módulos:

- **Académico:** `Carrera`, `Materia`, `Estudiante`, `Curso`, `Asistencia`, `Examen`
- **Bienestar:** `RegistroDiario`, `HorasSueno`, `EstadoAnimo`, `Alerta`
- **Clínico:** `Profesional`, `HorarioDisponible`, `ProfesionalAsignado`, `Cita`, `Sesion`, `NotaClinica`

Decisiones de diseño destacadas:

- Relación **Alerta (1) → Cita (1)** garantizada con `UNIQUE` sobre `Cita.IdAlerta`.
- Tabla intermedia `ProfesionalAsignado` para asignar profesionales a alertas.
- Restricciones de dominio con `CHECK` (p. ej. nivel de estrés 1–10, especialidades permitidas, estados de cita y de alerta).
- Bajas lógicas (`EstadoActivo`) para no perder integridad referencial del historial clínico.

> 📐 Diagrama lógico: ver [`docs/diagramas/`](docs/diagramas/).

---

## ⚙️ Funciones SQL (PL/pgSQL)

| Función | Qué devuelve |
|---|---|
| `ReporteAlertasPorCarrera(p_fecha_inicio, p_fecha_fin)` | Por carrera: estudiantes distintos con alertas, tipo de alerta más frecuente y total de alertas en el período. |
| `HistorialBienestarEstudiante(p_matricula)` | Historial cronológico de estrés, sueño y estado de ánimo de un estudiante. |
| `PromedioEstresEstudiante(p_matricula, p_fecha_inicio, p_fecha_fin)` | Promedio mensual de estrés de un estudiante. |
| `TotalCitasCompletadasProfesional(p_id_profesional, p_fecha_inicio, p_fecha_fin)` | Cantidad de citas completadas de un profesional (métrica de productividad). |

Ejemplos de uso:

```sql
SELECT * FROM ReporteAlertasPorCarrera('2025-01-01', '2026-12-31');
SELECT * FROM HistorialBienestarEstudiante('2021-0001');
SELECT * FROM PromedioEstresEstudiante('2021-0001', '2025-01-01', '2026-12-31');
SELECT TotalCitasCompletadasProfesional(1, '2025-01-01', '2026-12-31');
```

---

## 🚀 Optimización con índices (1.000.000 de registros)

Para probar la escalabilidad se generaron **1.000.000 de registros ficticios** (600.000 registros diarios, 200.000 alertas y 200.000 citas). Con ese volumen, las funciones sufrían *Sequential Scans* en sus cláusulas `WHERE`. Se diseñaron tres índices B-Tree:

```sql
CREATE INDEX idx_alerta_fecha ON Alerta(FechaAlerta);
CREATE INDEX idx_registro_matricula_fecha ON RegistroDiario(Matricula, FechaRegistro DESC);
CREATE INDEX idx_cita_prof_estado_fecha ON Cita(IdProfesional, EstadoCita, FechaHora);
```

Resultados medidos con `EXPLAIN ANALYZE` sobre PostgreSQL local:

| Función | Sin índice | Con índice | Mejora |
|---|---:|---:|---:|
| `ReporteAlertasPorCarrera` | 654.340 ms | 409.846 ms | 37,36 % |
| `HistorialBienestarEstudiante` | 152.022 ms | 32.748 ms | **78,46 %** |
| `PromedioEstresEstudiante` | 95.195 ms | 48.064 ms | 49,51 % |
| `TotalCitasCompletadasProfesional` | 32.196 ms | 11.231 ms | 65,12 % |

> Los tiempos pueden variar según el hardware y porque los datos se generan con `random()`.

---

## 📁 Estructura del repositorio

```
menteing/
├── README.md
├── sql/
│   ├── menteing_ch6.sql      # Tablas, datos base, funciones y carga masiva (1M de registros)
│   └── indices.sql           # Índices del Challenge 6 + consultas EXPLAIN ANALYZE
└── docs/
    ├── challenge3_diseno_logico_fisico.pdf
    ├── challenge4_normalizacion_3fn.pdf
    ├── challenge5_funciones_y_reportes.pdf
    ├── challenge6_optimizacion_indices.pdf
    └── diagramas/
        └── MenteingLogico.jpg
```

---

## ▶️ Cómo ejecutarlo

**Requisitos:** PostgreSQL 13 o superior y `psql`.

```bash
# 1. Crear la base de datos
createdb -U postgres menteing

# 2. Crear tablas, funciones y generar los datos (puede tardar unos minutos)
psql -U postgres -d menteing -f sql/menteing_ch6.sql

# 3. Aplicar los índices
psql -U postgres -d menteing -f sql/indices.sql
```

> ⚠️ El script de carga masiva ejecuta `ALTER TABLE Cita DISABLE TRIGGER ALL`, que requiere un usuario **superusuario** (por ejemplo `postgres`).
> ⚠️ El script comienza con `DROP TABLE IF EXISTS ... CASCADE`: está pensado para una base de datos de pruebas.

Para comparar rendimiento, ejecutá `EXPLAIN ANALYZE` sobre las funciones antes y después de crear los índices (ver `sql/indices.sql`).

---

## 🛠️ Tecnologías

- PostgreSQL 13+ · SQL · PL/pgSQL
- draw.io (diagramas de entidad-relación)

## Qué aprendí

- Modelado relacional y normalización hasta 3FN, incluyendo corrección de cardinalidades.
- Restricciones de integridad (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`).
- Funciones almacenadas que devuelven tablas y valores escalares.
- Generación de datos masivos con `generate_series` y análisis de planes de ejecución con `EXPLAIN ANALYZE`.
- Diseño de índices simples y compuestos según los patrones reales de consulta.

---

## Autores

- **Guillermo Cuenca** - [GitHub](https://github.com/GuilleCuenca)
- **Sebastian Laguardia** - [GitHub](https://github.com/laguardiia)

> Datos de estudiantes, profesionales y registros 100 % ficticios, generados con fines académicos.
