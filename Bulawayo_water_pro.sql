-- ====================================================
-- 1. Create Database and Use It
-- ====================================================
CREATE DATABASE IF NOT EXISTS Bulawayo_Water_Pro;
USE Bulawayo_Water_Pro;

-- ====================================================
-- 2. Create Tables
-- ====================================================

-- 2.1 Suburbs
CREATE TABLE IF NOT EXISTS Suburbs (
    suburb_id INT AUTO_INCREMENT PRIMARY KEY,
    suburb_name VARCHAR(50),
    average_water_rate DECIMAL(5,2)
);

-- 2.2 Households
CREATE TABLE IF NOT EXISTS Households (
    household_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_name VARCHAR(50),
    suburb_id INT,
    house_size VARCHAR(20),
    FOREIGN KEY (suburb_id) REFERENCES Suburbs(suburb_id)
);

-- 2.3 Water Usage
CREATE TABLE IF NOT EXISTS Water_Usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    household_id INT,
    usage_date DATE,
    water_used_liters DECIMAL(10,2),
    FOREIGN KEY (household_id) REFERENCES Households(household_id)
);

-- 2.4 Water Sources
CREATE TABLE IF NOT EXISTS Water_Sources (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    source_name VARCHAR(50),
    suburb_id INT,
    capacity_liters DECIMAL(10,2),
    FOREIGN KEY (suburb_id) REFERENCES Suburbs(suburb_id)
);

-- 2.5 Water Alerts
CREATE TABLE IF NOT EXISTS Water_Alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    household_id INT,
    usage_date DATE,
    water_used_liters DECIMAL(10,2),
    alert_message VARCHAR(100),
    FOREIGN KEY (household_id) REFERENCES Households(household_id)
);

-- ====================================================
-- 3. Insert Suburbs
-- ====================================================
INSERT INTO Suburbs (suburb_name, average_water_rate) VALUES
('Pumula', 1.2),
('Luveve', 1.0),
('Nkulumane', 1.1),
('Mpopoma', 1.3),
('Emganwini', 1.0);

-- ====================================================
-- 4. Insert Households
-- ====================================================
INSERT INTO Households (owner_name, suburb_id, house_size) VALUES
('Tafadzwa Sibanda', 1, 'Medium'),
('Memory Dube', 2, 'Large'),
('Trust Moyo', 3, 'Small'),
('Rudo Ncube', 1, 'Medium'),
('Tinashe Moyo', 2, 'Small'),
('Anesu Chikomo', 1, 'Small'),
('Ruvimbo Dube', 2, 'Medium'),
('Tendai Moyo', 3, 'Large'),
('Farai Ncube', 1, 'Medium'),
('Chipo Sibanda', 2, 'Small'),
('Brian Moyo', 3, 'Large'),
('Linda Dube', 1, 'Small'),
('Tatenda Ndlovu', 2, 'Medium'),
('Shingai Moyo', 3, 'Medium'),
('Hope Ncube', 1, 'Large'),
('Precious Dube', 4, 'Medium'),
('Simba Ncube', 4, 'Large'),
('Patricia Moyo', 5, 'Small'),
('Blessing Sibanda', 5, 'Medium'),
('Tawanda Ndlovu', 5, 'Large');

-- ====================================================
-- 5. Insert Water Sources
-- ====================================================
INSERT INTO Water_Sources (source_name, suburb_id, capacity_liters) VALUES
('Nkulumane Dam', 3, 1000000),
('Pumula Borehole', 1, 500000),
('Luveve Reservoir', 2, 750000),
('Mpopoma Well', 4, 600000),
('Emganwini Spring', 5, 400000);

-- ====================================================
-- 6. Insert 30-Day Water Usage for All Households
-- ====================================================
-- We'll use a pattern for simplicity: household_id * random value + day offset
-- You can copy and extend this if needed for more realism

DELIMITER $$

CREATE PROCEDURE populate_water_usage()
BEGIN
    DECLARE h INT;
    DECLARE d INT;
    SET h = 1;
    WHILE h <= 20 DO
        SET d = 1;
        WHILE d <= 30 DO
            INSERT INTO Water_Usage (household_id, usage_date, water_used_liters)
            VALUES (
                h,
                DATE_ADD('2026-01-01', INTERVAL (d-1) DAY),
                ROUND((300 + FLOOR(RAND()*400)),2)
            );
            SET d = d + 1;
        END WHILE;
        SET h = h + 1;
    END WHILE;
END$$

DELIMITER ;

CALL populate_water_usage();

DROP PROCEDURE populate_water_usage;

-- ====================================================
-- 7. Professional Analysis Queries
-- ====================================================

-- 7.1 Total Water Usage by Suburb
SELECT s.suburb_name, SUM(w.water_used_liters) AS total_water
FROM Water_Usage w
JOIN Households h ON w.household_id = h.household_id
JOIN Suburbs s ON h.suburb_id = s.suburb_id
GROUP BY s.suburb_name;

-- 7.2 Average Daily Water Usage per Household
SELECT h.owner_name, AVG(w.water_used_liters) AS avg_daily_usage
FROM Water_Usage w
JOIN Households h ON w.household_id = h.household_id
GROUP BY h.owner_name;

-- 7.3 Top 5 Households with Highest Total Usage
SELECT h.owner_name, SUM(w.water_used_liters) AS total_usage
FROM Water_Usage w
JOIN Households h ON w.household_id = h.household_id
GROUP BY h.owner_name
ORDER BY total_usage DESC
LIMIT 5;

-- 7.4 Average Water Usage per Suburb
SELECT s.suburb_name, AVG(w.water_used_liters) AS avg_usage
FROM Water_Usage w
JOIN Households h ON w.household_id = h.household_id
JOIN Suburbs s ON h.suburb_id = s.suburb_id
GROUP BY s.suburb_name;

-- 7.5 Create Alerts for Households Using More Than 650 Liters/Day
INSERT INTO Water_Alerts (household_id, usage_date, water_used_liters, alert_message)
SELECT household_id, usage_date, water_used_liters, 'High Water Usage'
FROM Water_Usage
WHERE water_used_liters > 650;

-- 7.6 View All Water Alerts
SELECT a.alert_id, h.owner_name, a.usage_date, a.water_used_liters, a.alert_message
FROM Water_Alerts a
JOIN Households h ON a.household_id = h.household_id;

-- 7.7 Daily Total Water Usage Across City
SELECT usage_date, SUM(water_used_liters) AS total_daily_usage
FROM Water_Usage
GROUP BY usage_date
ORDER BY usage_date;

-- 7.8 Highest Water Usage per Suburb
SELECT s.suburb_name, h.owner_name, MAX(w.water_used_liters) AS max_usage
FROM Water_Usage w
JOIN Households h ON w.household_id = h.household_id
JOIN Suburbs s ON h.suburb_id = s.suburb_id
GROUP BY s.suburb_name, h.owner_name
ORDER BY max_usage DESC;

