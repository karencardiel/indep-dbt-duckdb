with source as (
    select * from {{ ref('b2_resultado_eventos_comerciales_2025') }}
)

select
    cast(trim(cast(anio as varchar)) as integer) as anio,
    trim(cast(tipo_evento as varchar)) as tipo_evento,
    trim(cast(evento as varchar)) as evento,
    try_cast(nullif(trim(cast(fecha_convocatoria as varchar)), '') as date) as fecha_convocatoria,
    try_cast(nullif(trim(cast(fecha_fallo as varchar)), '') as date) as fecha_fallo,
    trim(cast(tipo_bien as varchar)) as tipo_bien,
    trim(cast(subtipo_bien as varchar)) as subtipo_bien,
    trim(cast(lote as varchar)) as lote,
    trim(cast(descripcion_lote as varchar)) as descripcion_lote,
    nullif(trim(cast(estado as varchar)), '-') as estado,
    nullif(trim(cast(entidad_transferente as varchar)), '-') as entidad_transferente,
    try_cast(nullif(trim(cast(precio_salida_monto_mxn as varchar)), '') as double) as precio_salida_mxn,
    try_cast(nullif(trim(cast(precio_venta_monto_mxn as varchar)), '') as double) as precio_venta_mxn,
    trim(cast(resultado as varchar)) as resultado_raw,
    case
        when lower(trim(coalesce(cast(resultado as varchar), ''))) in ('vendido', 'ganador') then 'Vendido'
        when lower(trim(coalesce(cast(resultado as varchar), ''))) like '%desiert%' then 'Desierto'
        else 'Otro / sin venta'
    end as resultado_lote,
    'b2_resultado_eventos_comerciales_2025' as archivo_origen,
    2 as prioridad_fuente
from source
