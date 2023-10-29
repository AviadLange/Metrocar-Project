/* This script aims to relate the users ant their respective rides*/

--Users who didn't complete a ride.
WITH not_completed AS(
	SELECT user_id, COUNT(*) AS number_of_not_completed
	FROM ride_requests
	WHERE pickup_ts IS NULL
	GROUP BY user_id),

--Users who were accepted by a driver.
accepted AS(
	SELECT user_id, COUNT(*) AS number_of_accepted
	FROM ride_requests
	WHERE accept_ts IS NOT NULL
	GROUP BY user_id),

--Users who were accepted.
accepted_users AS(
	SELECT *
	FROM not_completed
	FULL JOIN accepted
	USING(user_id)
	WHERE number_of_accepted IS NOT NULL),

--Users who were accepted and their respective rides.
rides_of_accepted_users AS(
  SELECT user_id, ride_id, accept_ts 
	FROM accepted_users
	INNER JOIN ride_requests
	USING(user_id)),

--Users who weren't accepted.
not_accepted_users AS(
	SELECT *
	FROM not_completed
	FULL JOIN accepted
	USING(user_id)
	WHERE number_of_accepted IS NULL),

--Users who weren't accepted and their respective rides.
rides_of_not_accepted_users AS(
  SELECT user_id, ride_id, accept_ts 
	FROM not_accepted_users
	INNER JOIN ride_requests
	USING(user_id))

--Merged data.
SELECT 'Yes' AS accepted_users,
	COUNT(DISTINCT a.user_id) AS number_of_users,
  COUNT(CASE WHEN accept_ts IS NOT NULL THEN ride_id END) AS accepted_rides,
  COUNT(CASE WHEN accept_ts IS NULL THEN ride_id END) AS not_accepted_rides
FROM rides_of_accepted_users
INNER JOIN accepted_users AS a
USING(user_id)
UNION
SELECT 'No' AS accepted_users,
	COUNT(DISTINCT n.user_id) AS number_of_users,
  COUNT(CASE WHEN accept_ts IS NOT NULL THEN ride_id END) AS accepted_rides,
  COUNT(CASE WHEN accept_ts IS NULL THEN ride_id END) AS not_accepted_rides
FROM rides_of_not_accepted_users
INNER JOIN not_accepted_users AS n
USING(user_id);