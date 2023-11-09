-- FINAL TEST
-- Arsya Hendratno Putri

-- 1.
-- dim_user.
CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(255),
    country VARCHAR(255)
);
-- dim_post.
CREATE TABLE dim_post (
    post_id INT PRIMARY KEY,
    post_text TEXT,
    post_date DATE,
    user_id INT REFERENCES dim_user(user_id)
);
-- dim_date.
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    date DATE
);

-- 2.
-- Populating dim_user.
INSERT INTO dim_user (user_id, user_name, country)
SELECT user_id, user_name, country
FROM raw_users;
-- Populating dim_post.
INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT post_id, post_text, post_date, user_id
FROM raw_posts;
-- Populating dim_date.
INSERT INTO dim_date (date)
SELECT DISTINCT post_date
FROM raw_posts;

-- 3. fact_post_performance.
CREATE TABLE fact_post_performance (
    fact_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES dim_post(post_id),
    date_id INT REFERENCES dim_date(date_id),
    views_count INT,
    likes_count INT
);

-- 4. Populating fact_post_performance.
INSERT INTO fact_post_performance (post_id, date_id, likes_count)
SELECT
    rp.post_id,
    dd.date_id,
    COUNT(rl.like_id) AS likes_count
FROM
    raw_posts rp
JOIN
    dim_date dd ON rp.post_date = dd.date
LEFT JOIN
    raw_likes rl ON rp.post_id = rl.post_id
GROUP BY
    rp.post_id, dd.date_id;
-- Setting the view_count by presuming that it is determined by the number of users who like the post.
UPDATE fact_post_performance
SET views_count = (
    SELECT COUNT(DISTINCT rl.user_id)
    FROM raw_likes rl
    WHERE rl.post_id = fact_post_performance.post_id
);

-- 5. CREATE TABLE fact_daily_posts (
    factd_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES dim_user(user_id),
    date_id INT REFERENCES dim_date(date_id),
    posts_count INT
);

-- 6. Populating fact_daily_posts.
INSERT INTO fact_daily_posts (user_id, date_id, posts_count)
SELECT
    du.user_id,
    dd.date_id,
    COUNT(rp.post_id) AS posts_count
FROM
    raw_posts rp
JOIN
    dim_user du ON rp.user_id = du.user_id
JOIN
    dim_date dd ON rp.post_date = dd.date
GROUP BY
    du.user_id, dd.date_id;
