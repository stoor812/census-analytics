with source as (

    select * from {{ source('raw', 'CENSUS_PROFILES') }}
    where geo_level = 'Province'

),

pivoted as (

    select
        dguid,
        max(geo_name)  as geo_name,
        max(geo_level) as geo_level,

        -- Population
        max(case when characteristic_id = 1   then count_total end) as population_2021,
        max(case when characteristic_id = 2   then count_total end) as population_2016,
        max(case when characteristic_id = 3   then count_total end) as population_pct_change_2016_2021,
        max(case when characteristic_id = 6   then count_total end) as population_density_per_sq_km,
        max(case when characteristic_id = 7   then count_total end) as land_area_sq_km,

        -- Age (raw counts kept so we can derive percentages)
        max(case when characteristic_id = 8   then count_total end) as total_population_by_age,
        max(case when characteristic_id = 9   then count_total end) as age_0_to_14,
        max(case when characteristic_id = 24  then count_total end) as age_65_and_over,
        max(case when characteristic_id = 39  then count_total end) as average_age,
        max(case when characteristic_id = 40  then count_total end) as median_age,

        -- Households
        max(case when characteristic_id = 50  then count_total end) as total_private_households,
        max(case when characteristic_id = 57  then count_total end) as average_household_size,

        -- Income
        max(case when characteristic_id = 113 then count_total end) as median_total_income_2020,
        max(case when characteristic_id = 115 then count_total end) as median_after_tax_income_2020,
        max(case when characteristic_id = 119 then count_total end) as median_employment_income_2020,

        -- Housing
        max(case when characteristic_id = 1482 then count_total end) as owner_households_total,
        max(case when characteristic_id = 1490 then count_total end) as tenant_households_total,
        max(case when characteristic_id = 1488 then count_total end) as median_dwelling_value,
        max(case when characteristic_id = 1486 then count_total end) as median_monthly_shelter_cost_owned,
        max(case when characteristic_id = 1494 then count_total end) as median_monthly_shelter_cost_rented,

        -- Education
        max(case when characteristic_id = 2014 then count_total end) as total_education_25_to_64,
        max(case when characteristic_id = 2015 then count_total end) as edu_no_certificate_diploma_or_degree,
        max(case when characteristic_id = 2024 then count_total end) as edu_bachelors_degree_or_higher

    from source
    group by dguid

)

select
    dguid,
    geo_name,
    geo_level,

    population_2021,
    population_2016,
    population_pct_change_2016_2021,
    population_density_per_sq_km,
    land_area_sq_km,

    average_age,
    median_age,

    total_private_households,
    average_household_size,

    median_total_income_2020,
    median_after_tax_income_2020,
    median_employment_income_2020,

    owner_households_total,
    tenant_households_total,
    median_dwelling_value,
    median_monthly_shelter_cost_owned,
    median_monthly_shelter_cost_rented,

    edu_bachelors_degree_or_higher,
    edu_no_certificate_diploma_or_degree,

    -- Same calculated percentages as riding_demographics
    round(100.0 * age_65_and_over / nullif(total_population_by_age, 0), 2)
        as pct_population_65_and_over,

    round(100.0 * age_0_to_14 / nullif(total_population_by_age, 0), 2)
        as pct_population_under_15,

    round(100.0 * owner_households_total
                  / nullif(owner_households_total + tenant_households_total, 0), 2)
        as pct_households_owner_occupied,

    round(100.0 * edu_bachelors_degree_or_higher / nullif(total_education_25_to_64, 0), 2)
        as pct_bachelors_or_higher_25_to_64

from pivoted
