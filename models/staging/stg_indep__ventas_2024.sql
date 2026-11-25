with source as (
    select * from {{ ref('INDEP_5_Resultados_de_Ventas') }}
)

select
    cast(trim(cast(anio as varchar)) as integer) as anio,
    trim(cast(tipoevento as varchar)) as tipo_evento,
    trim(cast(evento as varchar)) as evento,
    try_cast(nullif(trim(cast(fechaconvocatoria as varchar)), '') as date) as fecha_convocatoria,
    try_cast(nullif(trim(cast(fechafallo as varchar)), '') as date) as fecha_fallo,
    trim(cast(tipobien as varchar)) as tipo_bien,
    trim(cast(subtipobien as varchar)) as subtipo_bien,
    trim(cast(lote as varchar)) as lote,
    trim(cast(descripcionlote as varchar)) as descripcion_lote,
    nullif(trim(cast(estado as varchar)), '-') as estado,
    nullif(trim(cast(entidadtransferente as varchar)), '-') as entidad_transferente,
    try_cast(nullif(trim(cast(preciosalidamontoenmxn as varchar)), '') as double) as precio_salida_mxn,
    try_cast(nullif(trim(cast(precioventamontoenmxn as varchar)), '') as double) as precio_venta_mxn,
    trim(cast(resultado as varchar)) as resultado_raw,
    case
        when lower(trim(coalesce(cast(resultado as varchar), ''))) in ('vendido', 'ganador') then 'Vendido'
        when lower(trim(coalesce(cast(resultado as varchar), ''))) like '%desiert%' then 'Desierto'
        else 'Otro / sin venta'
    end as resultado_lote,
    'INDEP_5_Resultados_de_Ventas' as archivo_origen,
    1 as prioridad_fuente
from source
