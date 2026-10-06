
CREATE DATABASE telco_churn;

USE telco_churn;
CREATE TABLE customers (
    CustomerID VARCHAR(50) PRIMARY KEY,
    Gender VARCHAR(20),
    SeniorCitizen INT,
    Partner VARCHAR(10),
    Dependents VARCHAR(10),
    Tenure INT,
    PhoneService VARCHAR(10),
    MultipleLines VARCHAR(30),
    InternetService VARCHAR(30),
    OnlineSecurity VARCHAR(30),
    OnlineBackup VARCHAR(30),
    DeviceProtection VARCHAR(30),
    TechSupport VARCHAR(30),
    StreamingTV VARCHAR(30),
    StreamingMovies VARCHAR(30),
    Contract VARCHAR(30),
    PaperlessBilling VARCHAR(10),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10, 2),
    TotalCharges DECIMAL(10, 2),
    Churn VARCHAR(10),
    Churn_Binary INT
);
LOAD DATA LOCAL INFILE 'C:\Users\Eva Arya\Downloads\telco_churn_cleaned.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_records
FROM customers;
SELECT 
    Contract,
    COUNT(*) AS total_customers,

    SUM(
        CASE 
            WHEN Churn = 'Yes' THEN 1 
            ELSE 0 
        END
    ) AS churned_count,

    ROUND(
        100.0 * 
        SUM(
            CASE 
                WHEN Churn = 'Yes' THEN 1 
                ELSE 0 
            END
        ) / COUNT(*),
        1
    ) AS churn_rate_pct,

    ROUND(AVG(TotalCharges), 2) AS avg_ltv,

    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge

FROM customers

GROUP BY Contract

ORDER BY churn_rate_pct DESC;
SELECT 
    CASE 
        WHEN Tenure <= 6 THEN '0-6 months (New)'
        WHEN Tenure <= 12 THEN '6-12 months'
        WHEN Tenure <= 24 THEN '1-2 years'
        ELSE '2+ years (Established)'
    END AS tenure_segment,

    COUNT(*) AS customer_count,

    SUM(
        CASE 
            WHEN Churn = 'Yes' THEN 1 
            ELSE 0 
        END
    ) AS churned_count,

    ROUND(
        100.0 *
        SUM(
            CASE 
                WHEN Churn = 'Yes' THEN 1 
                ELSE 0 
            END
        ) / COUNT(*),
        1
    ) AS churn_rate_pct,

    ROUND(AVG(TotalCharges), 2) AS avg_ltv

FROM customers

GROUP BY 
    CASE 
        WHEN Tenure <= 6 THEN '0-6 months (New)'
        WHEN Tenure <= 12 THEN '6-12 months'
        WHEN Tenure <= 24 THEN '1-2 years'
        ELSE '2+ years (Established)'
    END

ORDER BY 
    CASE 
        WHEN tenure_segment = '0-6 months (New)' THEN 1
        WHEN tenure_segment = '6-12 months' THEN 2
        WHEN tenure_segment = '1-2 years' THEN 3
        ELSE 4
    END;
SELECT 
    InternetService,
    Contract,

    COUNT(*) AS customer_count,

    SUM(
        CASE 
            WHEN Churn = 'Yes' THEN 1 
            ELSE 0 
        END
    ) AS churned_count,

    ROUND(
        100.0 *
        SUM(
            CASE 
                WHEN Churn = 'Yes' THEN 1 
                ELSE 0 
            END
        ) / COUNT(*),
        1
    ) AS churn_rate_pct,

    ROUND(AVG(TotalCharges), 2) AS avg_ltv

FROM customers

GROUP BY InternetService, Contract

ORDER BY churn_rate_pct DESC;
WITH service_count AS (

    SELECT 

        (
            CASE 
                WHEN OnlineSecurity = 'Yes' THEN 1 
                ELSE 0 
            END

            +

            CASE 
                WHEN OnlineBackup = 'Yes' THEN 1 
                ELSE 0 
            END

            +

            CASE 
                WHEN DeviceProtection = 'Yes' THEN 1 
                ELSE 0 
            END

            +

            CASE 
                WHEN TechSupport = 'Yes' THEN 1 
                ELSE 0 
            END

            +

            CASE 
                WHEN StreamingTV = 'Yes' THEN 1 
                ELSE 0 
            END

            +

            CASE 
                WHEN StreamingMovies = 'Yes' THEN 1 
                ELSE 0 
            END

        ) AS num_services,

        Churn

    FROM customers
)

SELECT 

    CASE 
        WHEN num_services = 0 THEN 'No Add-ons'
        WHEN num_services <= 2 THEN '1-2 Add-ons'
        WHEN num_services <= 4 THEN '3-4 Add-ons'
        ELSE '5-6 Add-ons'
    END AS service_level,

    COUNT(*) AS customer_count,

    SUM(
        CASE 
            WHEN Churn = 'Yes' THEN 1 
            ELSE 0 
        END
    ) AS churned_count,

    ROUND(
        100.0 *
        SUM(
            CASE 
                WHEN Churn = 'Yes' THEN 1 
                ELSE 0 
            END
        ) / COUNT(*),
        1
    ) AS churn_rate_pct

FROM service_count

GROUP BY 
    CASE 
        WHEN num_services = 0 THEN 'No Add-ons'
        WHEN num_services <= 2 THEN '1-2 Add-ons'
        WHEN num_services <= 4 THEN '3-4 Add-ons'
        ELSE '5-6 Add-ons'
    END

ORDER BY customer_count DESC;
SELECT 

    CASE 
        WHEN TotalCharges > 2200 
             AND Churn = 'Yes'
            THEN 'High-Value Churned'

        WHEN TotalCharges > 2200 
             AND Churn = 'No'
            THEN 'High-Value Retained'

        WHEN Churn = 'Yes'
            THEN 'Standard Churned'

        ELSE 'Standard Retained'
    END AS segment,

    COUNT(*) AS customer_count,

    ROUND(AVG(TotalCharges), 2) AS avg_ltv,

    ROUND(SUM(TotalCharges), 0) AS total_ltv,

    SUM(
        CASE 
            WHEN Churn = 'Yes' THEN 1 
            ELSE 0 
        END
    ) AS churned_in_segment

FROM customers

GROUP BY segment

ORDER BY total_ltv DESC;