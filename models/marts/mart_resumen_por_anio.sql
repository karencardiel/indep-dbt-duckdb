select
    anio,
    count(*) as total_lotes,
    count(*) filter (where resultado_lote = 'Vendido') as lotes_vendidos,
    count(*) filter (where resultado_lote = 'Desierto') as lotes_desiertos,
    count(*) filter (where resultado_lote = 'Otro / sin venta') as lotes_otro_sin_venta,
    round(
        count(*) filter (where resultado_lote = 'Vendido') * 1.0 / nullif(count(*), 0),
        4
    ) as tasa_venta,
    round(avg(dias_convocatoria_fallo), 2) as prom_dias_convocatoria_fallo,
    coalesce(sum(precio_salida_mxn), 0.0) as monto_salida_total_mxn,
    coalesce(sum(precio_venta_mxn) filter (where resultado_lote = 'Vendido'), 0.0) as monto_venta_total_mxn,
    coalesce(sum(sobreprecio_mxn) filter (where resultado_lote = 'Vendido'), 0.0) as sobreprecio_total_mxn,
    round(avg(sobreprecio_pct) filter (where resultado_lote = 'Vendido'), 2) as prom_sobreprecio_pct
from {{ ref('fct_eventos') }}
group by anio
order by anio
