with stg as (

    select * from {{ ref('stg_census_profiles') }}

)

select
    dguid,
    geo_name,
    geo_level,

    -- Population
    population_2021,
    population_2016,
    population_pct_change_2016_2021,
    population_density_per_sq_km,
    land_area_sq_km,

    -- Age
    average_age,
    median_age,

    -- Households
    total_private_households,
    average_household_size,

    -- Income
    median_total_income_2020,
    median_after_tax_income_2020,
    median_employment_income_2020,

    -- Housing
    owner_households_total,
    tenant_households_total,
    median_dwelling_value,
    median_monthly_shelter_cost_owned,
    median_monthly_shelter_cost_rented,

    -- Education
    edu_bachelors_degree_or_higher,
    edu_no_certificate_diploma_or_degree,

    -- Calculated percentages
    round(100.0 * age_65_and_over / nullif(total_population_by_age, 0), 2)
        as pct_population_65_and_over,

    round(100.0 * age_0_to_14 / nullif(total_population_by_age, 0), 2)
        as pct_population_under_15,

    round(100.0 * owner_households_total
                  / nullif(owner_households_total + tenant_households_total, 0), 2)
        as pct_households_owner_occupied,

    round(100.0 * edu_bachelors_degree_or_higher / nullif(total_education_25_to_64, 0), 2)
        as pct_bachelors_or_higher_25_to_64

from stg
