SELECT TO_CHAR(request_ts, 'HH24') AS request_time,
	COUNT(ride_id) AS number_of_rides, platform, age_range
FROM signups AS s
JOIN app_downloads AS a
ON a.app_download_key = s.session_id
JOIN ride_requests
USING(user_id)
GROUP BY request_time, platform, age_range
ORDER BY request_time;