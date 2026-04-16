---running the first table 
SELECT *
FROM workspace.default.user_profile;

---running new table
SELECT *
FROM workspace.default.audience;

---extract dates
SELECT Record_date,
       Dayofmonth(Record_date) AS day_of_month
FROM workspace.default.audience;

---extracting months
SELECT Record_date,
       Monthname(Record_date) AS Month_Name
FROM workspace.default.audience;

---extracting day name
SELECT Record_date,
       Dayname(Record_date) AS Dayname
FROM workspace.default.audience;

---combining the dates columns
SELECT Record_date,
       Dayofmonth(Record_date) AS day_of_month,
        Monthname(Record_date) AS Month_Name,
        Dayname(Record_date) AS Dayname
FROM workspace.default.audience;

---combining dates
SELECT Record_date,
Dayofmonth(Record_date) AS day_of_month,
Monthname(Record_date) AS Month_Name,
Dayname(Record_date) AS Dayname
FROM workspace.default.audience;

---combining the two tables
SELECT B.UserID,A.Name,A.Surname,A.Email,A.Gender,A.Race,A.Age,A.Province,A.`Social Media Handle`,B.Channel2,B.Record_date,B.Record_time,B.Duration
FROM workspace.default.user_profile AS A
FULL OUTER JOIN workspace.default.audience AS B
ON A.UserID = B.UserID;


---checking for total count of nulls
SELECT COUNT(*) AS rows_with_nulls
FROM workspace.default.user_profile AS A
FULL OUTER JOIN workspace.default.audience AS B
ON A.UserID = B.UserID
WHERE B.UserID IS NULL
OR Gender IS NULL
OR Race IS NULL
OR Age IS NULL
OR Province IS NULL
OR Name IS NULL
OR SURNAME IS NULL
OR Email IS NULL
OR `Social Media Handle`IS NULL
OR Channel2 IS NULL
OR Record_date IS NULL
OR Record_time IS NULL
OR Duration IS NULL;


---checking for columns with nulls
SELECT *
FROM workspace.default.user_profile AS A
FULL OUTER JOIN workspace.default.audience AS B
ON A.UserID = B.UserID
WHERE B.UserID IS NULL
OR A.UserID IS NULL
OR Gender IS NULL
OR Race IS NULL
OR Age IS NULL
OR Province IS NULL
OR Name IS NULL
OR SURNAME IS NULL
OR Email IS NULL
OR `Social Media Handle`IS NULL
OR Channel2 IS NULL
OR Record_date IS NULL
OR Record_time IS NULL
OR Duration IS NULL;


---replacing nulls
SELECT
COALESCE(A.UserID, B.UserID, '0') AS UserID,
COALESCE(NULLIF(LOWER(Gender), 'none'), 'no gender') AS Gender,
COALESCE(NULLIF(LOWER(Province), 'none'), 'no province') AS Province,
COALESCE(NULLIF(LOWER(Race), 'none'), 'not specified') AS Race,
IFNULL(Channel2, 'no channel') AS Channel2,
IFNULL(Record_time, 'no time') AS Record_time,
IFNULL(Duration, 'no duration') AS Duration
FROM workspace.default.user_profile AS A
LEFT JOIN workspace.default.audience AS B
ON A.UserID = B.UserID;

---checking the gender that views channel 2 the most
SELECT COALESCE(NULLIF(LOWER(Gender), 'none'), 'no gender') AS Gender ,
       COUNT(*) AS `Total views per gender`
FROM workspace.default.user_profile AS A
LEFT JOIN workspace.default.audience AS B
ON A.UserID = B.UserID
WHERE Channel2 IS NOT NULL
GROUP BY Gender
ORDER BY `Total views per gender` DESC;

---checking the race that views TV the most

SELECT COALESCE(NULLIF(LOWER(Race), 'none'), 'not specified') AS Race,
       Count(*) AS `Top views by race`
FROM workspace.default.user_profile AS A
LEFT JOIN workspace.default.audience AS B
ON A.UserID = B.UserID
WHERE Channel2 IS NOT NULL
GROUP BY Race
ORDER BY `Top views by race` DESC;

---checking the province that views channel 2 the most
SELECT COALESCE(NULLIF(LOWER(Province), 'none'), 'no province') AS Province,
       COUNT(*) AS `Total views per province`
FROM workspace.default.user_profile AS A
LEFT JOIN workspace.default.audience AS B
ON A.UserID = B.UserID
WHERE Channel2 IS NOT NULL
GROUP BY Province
ORDER BY `Total views per province` DESC;

---checking the total number of viewers
SELECT COUNT(DISTINCT A.UserID) AS `Total unique viewers`
FROM workspace.default.user_profile AS A
INNER JOIN workspace.default.audience AS B
ON A.UserID = B.UserID;

---checking for total number of shows
SELECT COUNT(DISTINCT Channel2) AS `Number of shows`
FROM workspace.default.audience;

---checking for the most viewed show on Channel2
SELECT Channel2,
       COUNT(*) AS `Most viewed show`
FROM workspace.default.audience
WHERE Channel2 IS NOT NULL
GROUP BY Channel2
ORDER BY `Most viewed show`DESC;

---checking the minimum and maximum screen views
SELECT MIN(Duration) AS `Lowest screen time`,
       MAX(Duration) AS `Highest screen time`
FROM workspace.default.audience;

---checking a show with most viewing time
SELECT Channel2,
       MAX(Duration) AS `Most viewed show`
FROM workspace.default.audience
GROUP BY Channel2
ORDER BY `Most viewed show` DESC
LIMIT 1;

---checking a show with least viewing time
SELECT Channel2,
       MIN(Duration) AS `Least viewed show`
FROM workspace.default.audience
GROUP BY Channel2
ORDER BY `Least viewed show` ASC
LIMIT 1;
---creating time buckets and adding new columns
SELECT 
---old columns first
   DISTINCT A.UserID,
   Age,
   COALESCE(NULLIF(LOWER(Gender), 'none'), 'no gender') AS Gender,
   COALESCE(NULLIF(LOWER(Race), 'none'), 'not specified') AS Race,
   COALESCE(NULLIF(LOWER(Province), 'none'), 'no province') AS Province,
   Channel2,
   Record_date,
   Record_time,
   Duration,
   Dayofmonth(Record_date) AS day_of_month,
   Monthname(Record_date) AS Month_Name,
   Dayname(Record_date) AS Dayname,
---adding new columns
CASE 
    WHEN Record_time BETWEEN '05:59:59' AND '11:59:59' THEN 'Morning views'
    WHEN Record_time BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon views'
    WHEN Record_time BETWEEN '18:00:00' AND '20:59:59' THEN 'Evening views'
    WHEN Record_time BETWEEN '21:00:00' AND '23:59:59' THEN 'Late views'
    ELSE 'Graveyard views'
END AS Viewership,
---creating age buckets and adding new columns
CASE 
    WHEN Age < '5' THEN 'Toddler' 
    WHEN Age BETWEEN '5' AND '12' THEN 'Child'
    WHEN Age BETWEEN '13' AND '19' THEN 'Teenager'
    WHEN Age BETWEEN '20' AND '29' THEN 'Youth'
    WHEN Age BETWEEN '30' AND '45' THEN 'Adult'
    WHEN Age BETWEEN '45' AND '59' THEN 'Middle Aged'
    WHEN Age >= '60' THEN 'Seniors'
    ELSE 'Other'
END AS `Age Group`
FROM workspace.default.user_profile AS A
LEFT JOIN workspace.default.audience AS B
ON A.UserID = B.UserID
GROUP BY  A.UserID,
    Age,
   Gender,
   Race,
   Province,
   Channel2,
   Record_date,
   Record_time,
   Duration,
   day_of_month,
   Month_Name,
   Dayname;

