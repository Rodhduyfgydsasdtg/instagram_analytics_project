-- data_cleaning
-- removing all duplicates
WITH clean_data AS (SELECT DISTINCT 
 post_id,
  account_id,
 account_type,
 follower_count,
 media_type,
 content_category,
 traffic_source,
 has_call_to_action AS has_cta,
 -- Cleaning post_datetime
 REPLACE(post_datetime, '/', '-') AS clean_post_datetime,
day_of_week,
post_hour,
performance_bucket_label,
-- Feature Engineering: Mapping text buckets to numbers for quantitative analysis in Tableau
        CASE 
            WHEN performance_bucket_label = 'low' THEN 1
            WHEN performance_bucket_label = 'medium' THEN 2
            WHEN performance_bucket_label = 'high' THEN 3
            WHEN performance_bucket_label = 'Viral' THEN 4
            WHEN performance_bucket_label = 'Travel' THEN 5
            ELSE 1
        END AS performance_score,
-- Grouping follower_count
CASE
    WHEN follower_count < 10000 THEN '0-10K'
    WHEN follower_count < 50000 THEN '10K-50K'
    ELSE '50K+'
END AS creator_size   ,
-- has_call_to_action(boolean)
CASE	
	WHEN has_call_to_action =1  THEN 'TRUE'
    WHEN has_call_to_action= 0 THEN ' FALSE'
    ELSE 'NUL'
END AS true_false_has_cta


FROM instagram_dataset_cleaning.instagram_analytics)
     
 -- CALCULATION OF THE UNIQUE METRIC:
SELECT * ,
	AVG(performance_score) OVER(PARTITION BY content_category ) AS category_average_score,
	ROUND(CAST(performance_score AS Float) / NULLIF((follower_count/ 10000.0), 0),4) AS attention_efficiency_index 
FROM clean_data
ORDER BY post_id ;
