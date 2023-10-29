/* This script aims to show that there is no full relation
between the rides and users droped in any step of the funnel*/

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

--Users who weren't accepted by a driver.
not_accepted_users AS(
	SELECT *
	FROM not_completed
	FULL JOIN accepted
	USING(user_id)
	WHERE number_of_accepted IS NULL),

--Rides that weren't accepted.
not_accepted_rides AS(
	SELECT user_id, COUNT(*) AS number_of_rides
	FROM not_accepted_users
	INNER JOIN ride_requests
	USING(user_id)
	GROUP BY user_id),

--Users who were accepted with the amount of rides per user.
accepted_users AS(
	SELECT *
	FROM not_completed
	FULL JOIN accepted
	USING(user_id)
	WHERE number_of_accepted IS NOT NULL),

--Number of users.
users AS(
  SELECT 'Yes' AS status, COUNT(*) AS number_of_users FROM accepted_users
	UNION
	SELECT 'No' AS status, COUNT(*) AS number_of_users FROM not_accepted_users),

--Number of accepted rides for each user.
accepted_rides AS(
  SELECT user_id, COUNT(*) AS number_of_rides
	FROM accepted_users
	INNER JOIN ride_requests
	USING(user_id)
	GROUP BY user_id),

--Combines all data together.
merged_data AS(
	SELECT 'No' AS status, TRUE AS credibility, SUM(number_of_rides) AS rides
	FROM not_accepted_rides
	UNION
	SELECT 'Yes' AS status, TRUE AS credibility, SUM(number_of_rides) AS rides
	FROM accepted_rides
  UNION
	SELECT 'Yes' AS status, FALSE AS credibility, COUNT(*) AS rides
	FROM ride_requests
	WHERE accept_ts IS NOT NULL
	UNION
	SELECT 'No' AS status, FALSE AS credibility, COUNT(*) AS rides
	FROM ride_requests
	WHERE accept_ts IS NULL)

--Add the rides' rates.
SELECT *, ROUND((rides/number_of_users),2) AS rides_rate
FROM merged_data
JOIN users
USING(status);
