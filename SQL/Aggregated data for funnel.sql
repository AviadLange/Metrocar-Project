WITH app_download AS (
  SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(app_download_key) AS users, 0 AS rides
	FROM signups AS s
	FULL JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
	GROUP BY platform, age_range, download_date),

signup AS (
  SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(user_id) AS users, 0 AS rides
	FROM signups AS s
	JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
	GROUP BY platform, age_range, download_date),

ride_requested AS (
  SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(DISTINCT user_id) AS users, COUNT(ride_id) AS rides
  FROM signups AS s
	JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
 	JOIN ride_requests
  USING(user_id)
  GROUP BY platform, age_range, download_date),

ride_accepted AS (
  SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(DISTINCT user_id) AS users, COUNT(ride_id) AS rides
  FROM signups AS s
	JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
 	JOIN ride_requests
  USING(user_id)
  WHERE accept_ts IS NOT NULL
  GROUP BY platform, age_range, download_date),
 
ride_completed AS (
  SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(DISTINCT user_id) AS users, COUNT(ride_id) AS rides
  FROM signups AS s
	JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
 	JOIN ride_requests
  USING(user_id)
  WHERE dropoff_ts IS NOT NULL
  GROUP BY platform, age_range, download_date),

ride_paid AS (
  SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(DISTINCT user_id) AS users, COUNT(ride_id) AS rides
  FROM signups AS s
	JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
 	JOIN ride_requests
  USING(user_id)
  JOIN transactions
  USING(ride_id)
  WHERE charge_status = 'Approved'
  GROUP BY platform, age_range, download_date),

reviewed AS(
	SELECT platform, age_range, DATE_TRUNC('day', download_ts) AS download_date, COUNT(DISTINCT user_id) AS users, COUNT(ride_id) AS rides
  FROM signups AS s
	JOIN app_downloads AS a
	ON a.app_download_key = s.session_id
 	JOIN reviews
  USING(user_id)
  GROUP BY platform, age_range, download_date)


SELECT 1 AS step, 'Downloads' AS step_name, * FROM app_download
UNION
SELECT 2 AS step, 'Signups' AS step_name, * FROM signup
UNION
SELECT 3 AS step, 'Requests' AS step_name, * FROM ride_requested
UNION
SELECT 4 AS step, 'Accepted' AS step_name, * FROM ride_accepted
UNION
SELECT 5 AS step, 'Completed' AS step_name, * FROM ride_completed
UNION
SELECT 6 AS step, 'Payments' AS step_name, * FROM ride_paid
UNION
SELECT 7 AS step, 'Reviews' AS step_name, * FROM reviewed
ORDER BY step