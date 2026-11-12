DROP DATABASE stock_market_analysis ;
CREATE DATABASE stock_market_analysis;
USE stock_market_analysis;

DESCRIBE stock_prices;

SELECT *
FROM stock_prices
LIMIT 10;

SELECT
    MIN(STR_TO_DATE(`Date`, '%c/%e/%Y')) AS first_date,
    MAX(STR_TO_DATE(`Date`, '%c/%e/%Y')) AS last_date
FROM stock_prices;

SELECT
    YEAR(STR_TO_DATE(`Date`, '%c/%e/%Y')) AS Year,
    MONTH(STR_TO_DATE(`Date`, '%c/%e/%Y')) AS Month,
    ROUND(AVG(AMZN), 2) AS Amazon_Avg,
    ROUND(AVG(DPZ), 2) AS Domino_Avg,
    ROUND(AVG(BTC), 2) AS Bitcoin_Avg,
    ROUND(AVG(NFLX), 2) AS Netflix_Avg
FROM stock_prices
GROUP BY
    YEAR(STR_TO_DATE(`Date`, '%c/%e/%Y')),
    MONTH(STR_TO_DATE(`Date`, '%c/%e/%Y'))
ORDER BY Year, Month;

WITH asset_prices AS (
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y') AS trade_date,
           'AMZN' AS asset, AMZN AS closing_price
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'DPZ', DPZ
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'BTC', BTC
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'NFLX', NFLX
    FROM stock_prices
),
daily_changes AS (
    SELECT
        trade_date,
        asset,
        closing_price,
        LAG(closing_price) OVER (
            PARTITION BY asset
            ORDER BY trade_date
        ) AS previous_price

    FROM asset_prices 
)
SELECT
    trade_date,
    asset,
    closing_price,
    previous_price,
    ROUND(
        ((closing_price - previous_price) / previous_price) * 100,
        2
    ) AS daily_change_percent
FROM daily_changes
WHERE previous_price IS NOT NULL
ORDER BY daily_change_percent DESC
LIMIT 10;

WITH asset_prices AS (
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y') AS trade_date,
           'AMZN' AS asset, AMZN AS closing_price
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'DPZ', DPZ
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'BTC', BTC
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'NFLX', NFLX
    FROM stock_prices
),
daily_changes AS (
    SELECT
        trade_date,
        asset,
        closing_price,
        LAG(closing_price) OVER (
            PARTITION BY asset
            ORDER BY trade_date
        ) AS previous_price
    FROM asset_prices
)
SELECT
    trade_date,
    asset,
    closing_price,
    previous_price,
    ROUND(
        ((closing_price - previous_price) / previous_price) * 100,
        2
    ) AS daily_change_percent
FROM daily_changes
WHERE previous_price IS NOT NULL
ORDER BY daily_change_percent ASC
LIMIT 10;

WITH asset_prices AS (
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y') AS trade_date,
           'AMZN' AS asset, AMZN AS closing_price
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'DPZ', DPZ
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'BTC', BTC
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'NFLX', NFLX
    FROM stock_prices
),
daily_returns AS (
    SELECT
        asset,
        (
            (closing_price - LAG(closing_price) OVER (
                PARTITION BY asset
                ORDER BY trade_date
            )) /
            LAG(closing_price) OVER (
                PARTITION BY asset
                ORDER BY trade_date
            )
        ) * 100 AS daily_return
    FROM asset_prices
)
SELECT
    asset,
    ROUND(AVG(daily_return), 4) AS average_daily_return,
    ROUND(STDDEV_SAMP(daily_return), 4) AS volatility
FROM daily_returns
WHERE daily_return IS NOT NULL
GROUP BY asset
ORDER BY volatility DESC;

SELECT
    YEAR(STR_TO_DATE(`Date`, '%c/%e/%Y')) AS Year,
    ROUND(AVG(AMZN), 2) AS Amazon_Avg,
    ROUND(AVG(DPZ), 2) AS Domino_Avg,
    ROUND(AVG(BTC), 2) AS Bitcoin_Avg,
    ROUND(AVG(NFLX), 2) AS Netflix_Avg
FROM stock_prices
GROUP BY YEAR(STR_TO_DATE(`Date`, '%c/%e/%Y'))
ORDER BY Year;

WITH asset_prices AS (
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y') AS trade_date,
           'AMZN' AS asset, AMZN AS closing_price
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'DPZ', DPZ
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'BTC', BTC
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'NFLX', NFLX
    FROM stock_prices
),
daily_returns AS (
    SELECT
        asset,
        (
            closing_price -
            LAG(closing_price) OVER (
                PARTITION BY asset
                ORDER BY trade_date
            )
        ) /
        LAG(closing_price) OVER (
            PARTITION BY asset
            ORDER BY trade_date
        ) * 100 AS daily_return
    FROM asset_prices
),
asset_performance AS (
    SELECT
        asset,
        AVG(daily_return) AS average_return
    FROM daily_returns
    WHERE daily_return IS NOT NULL
    GROUP BY asset
)
SELECT
    asset,
    ROUND(average_return, 4) AS average_daily_return,
    RANK() OVER (
        ORDER BY average_return DESC
    ) AS performance_rank
FROM asset_performance;

WITH asset_prices AS (
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y') AS trade_date,
           'AMZN' AS asset, AMZN AS closing_price
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'DPZ', DPZ
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'BTC', BTC
    FROM stock_prices
    UNION ALL
    SELECT STR_TO_DATE(`Date`, '%c/%e/%Y'),
           'NFLX', NFLX
    FROM stock_prices
),
daily_returns AS (
    SELECT
        asset,
        (
            closing_price -
            LAG(closing_price) OVER (
                PARTITION BY asset
                ORDER BY trade_date
            )
        ) /
        LAG(closing_price) OVER (
            PARTITION BY asset
            ORDER BY trade_date
        ) * 100 AS daily_return
    FROM asset_prices
),
asset_average AS (
    SELECT
        asset,
        AVG(daily_return) AS average_return
    FROM daily_returns
    WHERE daily_return IS NOT NULL
    GROUP BY asset
)
SELECT
    asset,
    ROUND(average_return, 4) AS average_daily_return
FROM asset_average
WHERE average_return > (
    SELECT AVG(average_return)
    FROM asset_average
)
ORDER BY average_return DESC;






1. BTC recorded the highest average daily return at 0.5838%.

2. BTC showed the highest daily return volatility at 10.4611%.

3. DPZ had the lowest daily return volatility at 1.5845%.

4. The asset ranking by average daily return was BTC, NFLX, AMZN, and DPZ.

5. The dataset contains 1,520 records, covering May 2013 to May 2019.