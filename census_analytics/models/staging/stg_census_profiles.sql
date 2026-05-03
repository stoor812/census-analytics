with source as (

    select * from {{ source('raw', 'CENSUS_PROFILES') }}

)

select
    dguid,
    max(geo_name)  as geo_name,
    max(geo_level) as geo_level,

    -- Population & geography
    max(case when characteristic_id = 1   then count_total end) as population_2021,
    max(case when characteristic_id = 2   then count_total end) as population_2016,
    max(case when characteristic_id = 3   then count_total end) as population_pct_change_2016_2021,
    max(case when characteristic_id = 4   then count_total end) as total_private_dwellings,
    max(case when characteristic_id = 5   then count_total end) as private_dwellings_occupied,
    max(case when characteristic_id = 6   then count_total end) as population_density_per_sq_km,
    max(case when characteristic_id = 7   then count_total end) as land_area_sq_km,

    -- Age structure
    max(case when characteristic_id = 8   then count_total end) as total_population_by_age,
    max(case when characteristic_id = 9   then count_total end) as age_0_to_14,
    max(case when characteristic_id = 13  then count_total end) as age_15_to_64,
    max(case when characteristic_id = 24  then count_total end) as age_65_and_over,
    max(case when characteristic_id = 39  then count_total end) as average_age,
    max(case when characteristic_id = 40  then count_total end) as median_age,

    -- Households
    max(case when characteristic_id = 50  then count_total end) as total_private_households,
    max(case when characteristic_id = 51  then count_total end) as households_1_person,
    max(case when characteristic_id = 52  then count_total end) as households_2_persons,
    max(case when characteristic_id = 53  then count_total end) as households_3_persons,
    max(case when characteristic_id = 54  then count_total end) as households_4_persons,
    max(case when characteristic_id = 55  then count_total end) as households_5_or_more_persons,
    max(case when characteristic_id = 57  then count_total end) as average_household_size,

    -- Income
    max(case when characteristic_id = 113 then count_total end) as median_total_income_2020,
    max(case when characteristic_id = 115 then count_total end) as median_after_tax_income_2020,
    max(case when characteristic_id = 117 then count_total end) as median_market_income_2020,
    max(case when characteristic_id = 119 then count_total end) as median_employment_income_2020,
    max(case when characteristic_id = 128 then count_total end) as average_total_income_2020,
    max(case when characteristic_id = 130 then count_total end) as average_after_tax_income_2020,

    -- Housing (structural type)
    max(case when characteristic_id = 41   then count_total end) as total_dwellings_by_structure,
    max(case when characteristic_id = 42   then count_total end) as dwellings_single_detached,
    max(case when characteristic_id = 43   then count_total end) as dwellings_semi_detached,
    max(case when characteristic_id = 44   then count_total end) as dwellings_row_house,
    max(case when characteristic_id = 45   then count_total end) as dwellings_apartment_duplex,
    max(case when characteristic_id = 46   then count_total end) as dwellings_apartment_lt_5_storeys,
    max(case when characteristic_id = 47   then count_total end) as dwellings_apartment_5_plus_storeys,

    -- Housing (tenure & shelter cost)
    max(case when characteristic_id = 1482 then count_total end) as owner_households_total,
    max(case when characteristic_id = 1483 then count_total end) as pct_owner_households_with_mortgage,
    max(case when characteristic_id = 1484 then count_total end) as pct_owner_spending_30_plus_on_shelter,
    max(case when characteristic_id = 1485 then count_total end) as pct_owner_in_core_housing_need,
    max(case when characteristic_id = 1486 then count_total end) as median_monthly_shelter_cost_owned,
    max(case when characteristic_id = 1488 then count_total end) as median_dwelling_value,
    max(case when characteristic_id = 1490 then count_total end) as tenant_households_total,
    max(case when characteristic_id = 1491 then count_total end) as pct_tenant_in_subsidized_housing,
    max(case when characteristic_id = 1492 then count_total end) as pct_tenant_spending_30_plus_on_shelter,
    max(case when characteristic_id = 1493 then count_total end) as pct_tenant_in_core_housing_need,
    max(case when characteristic_id = 1494 then count_total end) as median_monthly_shelter_cost_rented,

    -- Education (population aged 25 to 64)
    max(case when characteristic_id = 2014 then count_total end) as total_education_25_to_64,
    max(case when characteristic_id = 2015 then count_total end) as edu_no_certificate_diploma_or_degree,
    max(case when characteristic_id = 2016 then count_total end) as edu_high_school_diploma,
    max(case when characteristic_id = 2017 then count_total end) as edu_postsecondary_certificate_or_higher,
    max(case when characteristic_id = 2022 then count_total end) as edu_college_cegep_diploma,
    max(case when characteristic_id = 2024 then count_total end) as edu_bachelors_degree_or_higher,
    max(case when characteristic_id = 2025 then count_total end) as edu_bachelors_degree,
    max(case when characteristic_id = 2028 then count_total end) as edu_masters_degree

from source
where geo_level = 'Federal electoral district (2013 Representation Order)'
group by dguid