with pivoted as (

    select
        dguid,

        -- Tenure
        max(case when characteristic_id = 1414 then count_total end) as total_households_by_tenure,
        max(case when characteristic_id = 1415 then count_total end) as owner_households,
        max(case when characteristic_id = 1416 then count_total end) as renter_households,

        -- Suitability
        max(case when characteristic_id = 1437 then count_total end) as total_by_suitability,
        max(case when characteristic_id = 1438 then count_total end) as suitable_housing,
        max(case when characteristic_id = 1439 then count_total end) as not_suitable_housing,

        -- Dwelling condition
        max(case when characteristic_id = 1449 then count_total end) as total_by_condition,
        max(case when characteristic_id = 1450 then count_total end) as regular_maintenance_only,
        max(case when characteristic_id = 1451 then count_total end) as major_repairs_needed,

        -- Shelter cost to income ratio
        max(case when characteristic_id = 1465 then count_total end) as total_by_shelter_cost_ratio,
        max(case when characteristic_id = 1466 then count_total end) as spending_under_30_pct_on_shelter,
        max(case when characteristic_id = 1467 then count_total end) as spending_30_plus_pct_on_shelter,

        -- Owner / tenant detail
        max(case when characteristic_id = 1483 then count_total end) as pct_owner_with_mortgage,
        max(case when characteristic_id = 1484 then count_total end) as pct_owner_spending_30_plus_on_shelter,
        max(case when characteristic_id = 1486 then count_total end) as median_monthly_shelter_cost_owned,
        max(case when characteristic_id = 1488 then count_total end) as median_dwelling_value,
        max(case when characteristic_id = 1492 then count_total end) as pct_tenant_spending_30_plus_on_shelter,
        max(case when characteristic_id = 1494 then count_total end) as median_monthly_shelter_cost_rented

    from {{ source('raw', 'CENSUS_PROFILES') }}
    where geo_level = 'Federal electoral district (2013 Representation Order)'
    group by dguid

)

select
    s.dguid,
    s.geo_name,
    s.geo_level,

    p.total_households_by_tenure,
    p.owner_households,
    p.renter_households,

    p.suitable_housing,
    p.not_suitable_housing,

    p.regular_maintenance_only,
    p.major_repairs_needed,

    p.spending_under_30_pct_on_shelter,
    p.spending_30_plus_pct_on_shelter,

    p.pct_owner_with_mortgage,
    p.pct_owner_spending_30_plus_on_shelter,
    p.median_monthly_shelter_cost_owned,
    p.median_dwelling_value,
    p.pct_tenant_spending_30_plus_on_shelter,
    p.median_monthly_shelter_cost_rented,

    -- Calculated percentages
    round(100.0 * p.owner_households  / nullif(p.total_households_by_tenure, 0), 2)
        as pct_owner_households,
    round(100.0 * p.renter_households / nullif(p.total_households_by_tenure, 0), 2)
        as pct_renter_households,
    round(100.0 * p.not_suitable_housing / nullif(p.total_by_suitability, 0), 2)
        as pct_not_suitable_housing,
    round(100.0 * p.major_repairs_needed / nullif(p.total_by_condition, 0), 2)
        as pct_major_repairs_needed,
    round(100.0 * p.spending_30_plus_pct_on_shelter / nullif(p.total_by_shelter_cost_ratio, 0), 2)
        as pct_spending_30_plus_on_shelter

from {{ ref('stg_census_profiles') }} s
left join pivoted p using (dguid)
