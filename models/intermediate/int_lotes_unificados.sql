with union_lotes as (
    select * from {{ ref('stg_indep__ventas_2024') }}
    union all
    select * from {{ ref('stg_indep__2025_b2') }}
    union all
    select * from {{ ref('stg_indep__2025_nov') }}
    union all
    select * from {{ ref('stg_indep__2026_ago') }}
    union all
    select * from {{ ref('stg_indep__2026_may') }}
),

con_clave as (
    select
        md5(
            concat_ws(
                '|',
                coalesce(cast(anio as varchar), ''),
                coalesce(lower(trim(evento)), ''),
                coalesce(lower(trim(lote)), '')
            )
        ) as lote_sk,
        *
    from union_lotes
    where evento is not null
      and lote is not null
)

select *
from con_clave
qualify row_number() over (
    partition by lote_sk
    order by
        prioridad_fuente desc,
        case when precio_venta_mxn is not null then 1 else 0 end desc,
        fecha_fallo desc nulls last
) = 1
