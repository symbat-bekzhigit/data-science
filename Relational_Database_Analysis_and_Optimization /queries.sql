-- TODO: write the task number and description followed by the query



-- 1. Write a View

CREATE OR REPLACE VIEW my_view AS
SELECT
    ae.id,
    ae.name,
    ae.sex,
    ae.age,
    ae.height,
    ae.weight,
    ae.team,
    ae.noc,
    ae.games,
    ae.year,
    ae.season,
    ae.city,
    ae.sport,
    ae.event,
    ae.medal,
    COALESCE(nr.region, 
             CASE ae.noc 
                WHEN 'SGP' THEN 'Singapore'
                WHEN 'ROT' THEN 'Refugee'
                WHEN 'TUV' THEN 'Tuvalu'
                WHEN 'UNK' THEN 'Unknown'
                ELSE ae.team
             END) AS region,
    nr.note,
    COUNT(*) AS medal_count
FROM
    athlete_event ae
LEFT JOIN
    noc_region nr ON ae.noc = nr.noc
WHERE
    ae.medal IS NOT NULL
GROUP BY
    ae.id,
    ae.name,
    ae.sex,
    ae.age,
    ae.height,
    ae.weight,
    ae.team,
    ae.noc,
    ae.games,
    ae.year,
    ae.season,
    ae.city,
    ae.sport,
    ae.event,
    ae.medal,
    nr.region,
    nr.note;






-- 2. Use the Window Function, rank()

WITH FencingGoldMedalRank AS (
    SELECT
        event,
        region,
        COUNT(*) AS gold_medals,
        RANK() OVER (PARTITION BY event ORDER BY COUNT(*) DESC) AS rank
    FROM
        my_view
    WHERE
        event LIKE '%Fencing%' AND medal = 'Gold'
    GROUP BY
        event, region
)
SELECT
    region,
    event,
    gold_medals,
    rank
FROM
    FencingGoldMedalRank
WHERE
    rank <= 3
ORDER BY
    event ASC, rank ASC;






-- 3. Using Aggregate Functions as Window Functions

WITH RollingSumPerRegion AS (
    SELECT
        region,
        year,
        medal,
        COUNT(*) AS c,
        SUM(COUNT(*)) OVER (PARTITION BY region, medal ORDER BY year) AS sum
    FROM
        my_view
    GROUP BY
        region, year, medal
)
SELECT
    region,
    year,
    medal,
    c,
    sum
FROM
    RollingSumPerRegion
ORDER BY
    region ASC, year ASC, medal ASC;





-- 4. Use the Window Function, lag()

WITH PoleVaultGoldMedals AS (
    SELECT
        event,
        year,
        height,
        LAG(height,1) OVER (PARTITION BY event ORDER BY year) AS previous_height
    FROM
        my_view
    WHERE
        event LIKE '%Pole Vault%' AND medal = 'Gold' AND height IS NOT NULL
)
SELECT
    event,
    year,
    height,
    CASE WHEN previous_height IS NULL THEN 'NULL' ELSE previous_height::TEXT END AS previous_height
FROM
    PoleVaultGoldMedals
ORDER BY
    event ASC, year ASC;

