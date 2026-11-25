<h1> <img src = "https://slackmojis.com/emojis/5019-dbt/download" width="35"/> Pipeline INDEP: dbt + DuckDB </h1>

Este proyecto es un pipeline hecho con **dbt Core** y **DuckDB** (`indep.duckdb`) para limpiar los datos de los eventos comerciales del **INDEP** (2024 a 2026). Los archivos originales venían bastante desordenados, así que se dejaron sin duplicados y listos para analizar.

---

## Cómo está organizado

```text
indep_pipeline/
├── seeds/                  # Los 5 CSV originales del INDEP
├── models/
│   ├── staging/            # Una vista por CSV (nombres de columnas, tipos y resultado_lote)
│   ├── intermediate/       # Unión 2024–2026, clave lote_sk y deduplicación
│   ├── marts/              # fct_eventos y 3 tablas resumen
│   └── schema.yml          # Tests de calidad
├── evidence/               # Capturas de la ejecución y del linaje
└── dbt_project.yml
```

---

## Qué se encontró en los datos

Antes de empezar se revisó cada archivo para ver cómo venía. Esto fue lo que se encontró:

- **2024** (`INDEP_5_Resultados_de_Ventas.csv`, 18,275 filas): las columnas no tenían guiones bajos, traía una columna de más (`estadocomprador_etq`), 23 duplicados dentro del mismo archivo y regiones mezcladas en el campo `estado`.
- **2025** (`b2_resultado_eventos_comerciales_2025.csv` con 5,235 filas y `resultado_eventos_comerciales_noviembre_2025.csv` con 4,844): varios registros del corte de noviembre ya venían en el consolidado del año, así que se repiten en los dos archivos.
- **2026** (`b3_resultado_eventos_comerciales_mayo_2026.csv` con 967 filas y `b2_resultado_eventos_comerciales_7_agosto_2026.csv` con 1,425): el corte de agosto ya incluye los lotes de mayo, más los eventos nuevos.

### Cómo se limpiaron

- `resultado_lote` quedó con solo tres valores: `'Vendido'`, `'Desierto'` y `'Otro / sin venta'`.
- Los vacíos y los `'-'` se convirtieron a `NULL`.
- Se creó una clave única, `lote_sk`, y con esa se quitaron los duplicados en `int_lotes_unificados`.

---

## Los modelos

- **Staging:** 5 vistas `stg_indep__*`, sin joins. Aquí solo se renombran columnas, se les asigna su tipo y se limpian.
- **Intermediate:** `int_lotes_unificados` junta todo y queda con **24,912 lotes únicos**, cada uno con su `lote_sk`.
- **Marts:**
  - `fct_eventos`: calcula los días que pasan entre la convocatoria y el fallo, y el sobreprecio.
  - `mart_resumen_por_anio`, `mart_resumen_por_tipo_evento` y `mart_resumen_por_tipo_bien`: resúmenes por año, por tipo de evento y por tipo de bien, todos con la tasa de venta.

---

## Cómo correrlo

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-duckdb
dbt debug
dbt build
dbt docs generate && dbt docs serve
```

---

## Lineage Graph

Así se conectan los modelos, desde los seeds hasta los marts:

![Lineage graph del pipeline](evidence/lineage_graph.png)
