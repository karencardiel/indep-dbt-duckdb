# Pipeline de Datos INDEP con dbt Core y DuckDB

Pipeline ETL/ELT construido con **dbt Core** y **DuckDB** (`indep.duckdb`) para limpiar, unificar, deduplicar y modelar los resultados de eventos comerciales del **INDEP** correspondientes a **2024, 2025 y 2026**.

---

## 1. Arquitectura del Proyecto

```text
indep_pipeline/
├── dbt_project.yml
├── seeds/                     # 5 archivos CSV originales del INDEP
├── models/
│   ├── staging/               # 1 vista por CSV: renombre, casteo y normalización de resultado
│   ├── intermediate/          # Unificación de años, clave única (lote_sk) y deduplicación
│   ├── marts/                 # Tabla de hechos (fct_eventos) y 3 tablas de resumen
│   └── schema.yml             # Tests de calidad (unique, not_null, accepted_values)
└── README.md

```

---

## 2. Exploración de los Datos (Hallazgos)

Se analizaron los 5 archivos CSV originales cargados como `seeds`:

| Archivo CSV | Año | Filas | Particularidades y problemas detectados |
| --- | --- | --- | --- |
| `INDEP_5_Resultados_de_Ventas.csv` | 2024 | 18,275 | Columnas sin guiones bajos (`tipoevento`, `fechaconvocatoria`, `preciosalidamontoenmxn`, etc.), columna extra `estadocomprador_etq`, 23 registros duplicados internos por `(anio, evento, lote)` y 151 filas con regiones (`Pacífico`, `Norte`) en `estado`. |
| `b2_resultado_eventos_comerciales_2025.csv` | 2025 | 5,235 | Esquema en `snake_case`; se traslapa con el corte de noviembre 2025. |
| `resultado_eventos_comerciales_noviembre_2025.csv` | 2025 | 4,844 | Corte parcial de 2025 incluido dentro del consolidado anual de 2025. |
| `b3_resultado_eventos_comerciales_mayo_2026.csv` | 2026 | 967 | Corte parcial a mayo 2026; sus lotes se traslapan con el archivo de agosto 2026. |
| `b2_resultado_eventos_comerciales_7_agosto_2026.csv` | 2026 | 1,425 | Corte acumulado a agosto 2026; incluye los lotes de mayo 2026 más eventos posteriores. |

### Principales problemas de calidad resueltos

* **Diferencia de nombres de columnas:** Homologación de encabezados sin separador de 2024 hacia `snake_case` en `staging`.
* **Inconsistencias en `resultado`:** Variaciones de mayúsculas/minúsculas y etiquetas (`Vendido`, `VENDIDO`, `Ganador`, `Desierto`, `DESIERTO`, `desierto`, `Baja`, `Baja total`, `BAJA`, `Retirado`, `RETIRADO`, `Venta cancelada`), normalizadas en 3 categorías: `'Vendido'`, `'Desierto'` y `'Otro / sin venta'`.
* **Valores vacíos y guiones:** Limpieza de cadenas vacías y valores `'-'` convertidos a `NULL`.
* **Duplicados entre y dentro de archivos:** Deduplicación en `int_lotes_unificados` mediante clave subrogada `lote_sk` (`md5(anio | evento | lote)`) conservando el registro más completo y actualizado.

---

## 3. Modelos y Métricas Principales

* **Staging (`models/staging/`):** 5 vistas (`stg_indep__*`) sin `JOIN`s que limpian tipos de dato y normalizan `resultado_lote`.
* **Intermediate (`models/intermediate/int_lotes_unificados.sql`):** Unión de los 3 años con generación de `lote_sk` y deduplicación con `QUALIFY row_number()`.
* **Marts (`models/marts/`):**
* `fct_eventos`: Tabla a nivel lote con cálculo de `dias_convocatoria_fallo`, `sobreprecio_mxn` y `sobreprecio_pct`.
* `mart_resumen_por_anio`: Métricas agregadas y `tasa_venta` por año.
* `mart_resumen_por_tipo_evento`: Métricas agregadas y `tasa_venta` por tipo de evento.
* `mart_resumen_por_tipo_bien`: Métricas agregadas y `tasa_venta` por tipo de bien.



---

## 4. Cómo ejecutar el proyecto

1. Instalar dependencias en un entorno virtual:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-duckdb

```


2. Configurar `~/.dbt/profiles.yml` con el perfil `indep_pipeline` apuntando a `path: indep.duckdb` (`type: duckdb`).
3. Ejecutar el pipeline completo, pruebas y documentación:
```bash
dbt debug
dbt build
dbt docs generate
dbt docs serve
```
