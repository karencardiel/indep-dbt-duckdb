select
    lote_sk,
    anio,
    tipo_evento,
    evento,
    fecha_convocatoria,
    fecha_fallo,
    datediff('day', fecha_convocatoria, fecha_fallo) as dias_convocatoria_fallo,
    tipo_bien,
    subtipo_bien,
    lote,
    descripcion_lote,
    estado,
    entidad_transferente,
    resultado_lote,
    resultado_raw,
    precio_salida_mxn,
    precio_venta_mxn,
    case
        when resultado_lote = 'Vendido'
         and precio_venta_mxn is not null
         and precio_salida_mxn is not null
        then precio_venta_mxn - precio_salida_mxn
        else 0.0
    end as sobreprecio_mxn,
    case
        when resultado_lote = 'Vendido'
         and precio_venta_mxn is not null
         and nullif(precio_salida_mxn, 0) is not null
        then ((precio_venta_mxn - precio_salida_mxn) / precio_salida_mxn) * 100.0
        else null
    end as sobreprecio_pct,
    archivo_origen
from {{ ref('int_lotes_unificados') }}
