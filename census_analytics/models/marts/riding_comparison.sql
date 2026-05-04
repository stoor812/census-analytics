with ridings as (

    select
        r.dguid,
        r.geo_name,
        r.geo_level,

        r.population_2021,
        r.median_total_income_2020,
        r.median_dwelling_value,
        r.pct_bachelors_or_higher_25_to_64,
        r.pct_population_65_and_over,
        h.pct_spending_30_plus_on_shelter

    from {{ ref('riding_demographics') }} r
    left join {{ ref('housing_analysis') }} h using (dguid)

)

select
    dguid,
    geo_name,
    geo_level,

    population_2021,
    median_total_income_2020,
    median_dwelling_value,
    pct_bachelors_or_higher_25_to_64,
    pct_population_65_and_over,
    pct_spending_30_plus_on_shelter,

    rank() over (order by median_total_income_2020         desc nulls last) as income_rank,
    rank() over (order by median_dwelling_value            desc nulls last) as dwelling_value_rank,
    rank() over (order by pct_bachelors_or_higher_25_to_64 desc nulls last) as education_rank,
    rank() over (order by pct_population_65_and_over       desc nulls last) as senior_population_rank,
    rank() over (order by pct_spending_30_plus_on_shelter  desc nulls last) as shelter_burden_rank

from ridings
