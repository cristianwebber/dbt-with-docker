select *
from {{ metrics.calculate(
    metric_list=['ids'],
    grain='week',
    dimensions=['id']
) }}
