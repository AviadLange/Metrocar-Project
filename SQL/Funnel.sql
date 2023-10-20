WITH app_download AS (
  SELECT app_download_key
FROM app_downloads),

signup AS (
  SELECT user_id
  FROM signups),

ride_request AS (
  SELECT DISTINCT user_id
  FROM ride_requests),
  
purchase AS (
  SELECT DISTINCT user_id
  FROM transactions
  INNER JOIN ride_requests -- Any type would work
  USING(ride_id)
  INNER JOIN signups -- Any type would work
  USING(user_id)
  WHERE charge_status = 'Approved'),
  
steps AS ( 
	SELECT 1 AS step, 'Visitors' AS step_name, COUNT(*) AS number_of_users FROM app_download
	UNION
	SELECT 2 AS step, 'Sign-ups' AS step_name, COUNT(*) AS number_of_users FROM signup
	UNION
	SELECT 3 AS step, 'Ride-requesters' AS step_name, COUNT(*) AS number_of_users FROM ride_request
	UNION
	SELECT 4 AS step, 'Purchasers' AS step_name, COUNT(*) AS number_of_users FROM purchase)

SELECT *,
	LAG(number_of_users, 1) OVER () AS previous_step,
  ROUND((1.0 - number_of_users::NUMERIC/LAG(number_of_users, 1) OVER ()),2) AS drop_off,
  ROUND(number_of_users/(FIRST_VALUE(number_of_users::NUMERIC) OVER (
  	ORDER BY step)),2) AS percent_of_top
FROM steps
