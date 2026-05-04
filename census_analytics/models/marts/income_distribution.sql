with brackets as (

    select
        dguid,

        max(case when characteristic_id = 155 then count_total end) as total_income_recipients,
        max(case when characteristic_id = 156 then count_total end) as without_income,
        max(case when characteristic_id = 157 then count_total end) as with_income,

        max(case when characteristic_id = 158 then count_total end) as income_under_10k,
        max(case when characteristic_id = 159 then count_total end) as income_10k_to_19k,
        max(case when characteristic_id = 160 then count_total end) as income_20k_to_29k,
        max(case when characteristic_id = 161 then count_total end) as income_30k_to_39k,
        max(case when characteristic_id = 162 then count_total end) as income_40k_to_49k,
        max(case when characteristic_id = 163 then count_total end) as income_50k_to_59k,
        max(case when characteristic_id = 164 then count_total end) as income_60k_to_69k,
        max(case when characteristic_id = 165 then count_total end) as income_70k_to_79k,
        max(case when characteristic_id = 166 then count_total end) as income_80k_to_89k,
        max(case when characteristic_id = 167 then count_total end) as income_90k_to_99k,
        max(case when characteristic_id = 168 then count_total end) as income_100k_and_over,
        max(case when characteristic_id = 169 then count_total end) as income_100k_to_149k,
        max(case when characteristic_id = 170 then count_total end) as income_150k_and_over

    from {{ source('raw', 'CENSUS_PROFILES') }}
    where geo_level = 'Federal electoral district (2013 Representation Order)'
    group by dguid

)

select
    s.dguid,
    s.geo_name,
    s.geo_level,

    s.median_total_income_2020,

    b.total_income_recipients,
    b.without_income,
    b.with_income,

    b.income_under_10k,
    b.income_10k_to_19k,
    b.income_20k_to_29k,
    b.income_30k_to_39k,
    b.income_40k_to_49k,
    b.income_50k_to_59k,
    b.income_60k_to_69k,
    b.income_70k_to_79k,
    b.income_80k_to_89k,
    b.income_90k_to_99k,
    b.income_100k_and_over,
    b.income_100k_to_149k,
    b.income_150k_and_over,

    -- Distribution as % of recipients with income
    round(100.0 * b.income_under_10k     / nullif(b.with_income, 0), 2) as pct_under_10k,
    round(100.0 * (b.income_10k_to_19k
                 + b.income_20k_to_29k
                 + b.income_30k_to_39k)  / nullif(b.with_income, 0), 2) as pct_10k_to_39k,
    round(100.0 * (b.income_40k_to_49k
                 + b.income_50k_to_59k
                 + b.income_60k_to_69k)  / nullif(b.with_income, 0), 2) as pct_40k_to_69k,
    round(100.0 * (b.income_70k_to_79k
                 + b.income_80k_to_89k
                 + b.income_90k_to_99k)  / nullif(b.with_income, 0), 2) as pct_70k_to_99k,
    round(100.0 * b.income_100k_and_over / nullif(b.with_income, 0), 2) as pct_100k_and_over,
    round(100.0 * b.income_150k_and_over / nullif(b.with_income, 0), 2) as pct_150k_and_over

from {{ ref('stg_census_profiles') }} s
left join brackets b using (dguid)
