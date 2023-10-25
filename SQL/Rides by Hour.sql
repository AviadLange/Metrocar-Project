--This query groups the rides' data by the hour of the day.
SELECT TO_CHAR(request_ts, 'HH24') AS request_time,
	TO_CHAR(request_ts, 'DD/MM/YYYY') AS request_day,
	COUNT(ride_id) AS number_of_rides,
	platform,
	age_range
FROM signups AS s
JOIN app_downloads AS a
ON a.app_download_key = s.session_id
JOIN ride_requests
USING(user_id)
GROUP BY request_time, request_day, platform, age_range
ORDER BY request_time
