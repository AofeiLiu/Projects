SET SQL_SAFE_UPDATES = 0;

DROP DATABASE IF EXISTS competition;

CREATE DATABASE competition;


USE competition;


#============================================================================================================================
CREATE TABLE company_info (
	comp_name VARCHAR(50),
    ticker VARCHAR(50),
    industry ENUM('technology', 'energy', 'healthcare', 'consumer_defensive', 'financial_services', 'utilities'),
    market_cap ENUM('small', 'medium', 'large')
);

DROP TABLE IF EXISTS historial_full;

CREATE TABLE historial_full (
	company_name VARCHAR(50),
    dates VARCHAR(50),
    open_price VARCHAR(50),
    high VARCHAR(50),
    low VARCHAR(50),
    close_price VARCHAR(50),
    adj_close_price VARCHAR(50),
    volume VARCHAR(50),
    ask VARCHAR(50),
    bid VARCHAR(50)
);

INSERT INTO company_info (
	comp_name, 
    ticker, 
    industry, 
    market_cap)
VALUES 
	('TECSYS Inc.', 'TCS', 'technology', 'small'),
    ('Kinaxis', 'KXS', 'technology', 'medium'),
    ('Constellation Software', 'CSU', 'technology', 'large'),
    ('TerraVest Industries Inc.', 'TVK', 'energy', 'small'),
    ('Parkland Fuel Corporation', 'PKI', 'energy', 'medium'),
    ('Suncor Energy Inc.', 'SU', 'energy', 'large'),
    ('Zymeworks', 'ZYME', 'Healthcare', 'small'),
    ('Chartwell Retirement Residences', 'CSH.UN', 'Healthcare', 'medium'),
    ('Canopy Growth Corporation', 'WEED', 'Healthcare', 'large'),
    ('AGT Food and Ingredients', 'AGT', 'consumer_defensive', 'small'),
    ('Maple Leaf Foods', 'MFI', 'consumer_defensive', 'medium'),
    ('Dollarama', 'DOL', 'consumer_defensive', 'large'),
    ('Alaris Royalty Corp.', 'AD', 'financial_services', 'small'),
    ('TMX Group Limited', 'X', 'financial_services', 'medium'),
    ('Royal Bank of Canada', 'RY', 'financial_services', 'large'),
    ('Superior Plus Corp.', 'SPB', 'utilities', 'small'),
    ('Northland Power', 'NPI', 'utilities', 'medium'),
    ('Hydro One Limited', 'H', 'utilities', 'large');

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/_historial_price_Bid-Ask full data_new.csv"
INTO TABLE historial_full
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM historial_full WHERE open_price = 'null';

UPDATE historial_full
SET open_price = NULL
WHERE open_price = 'null';

UPDATE historial_full
SET high = NULL
WHERE high = 'null';

UPDATE historial_full
SET low = NULL
WHERE low = 'null';

UPDATE historial_full
SET close_price = NULL
WHERE close_price = 'null';

UPDATE historial_full
SET adj_close_price = NULL
WHERE adj_close_price = 'null';

UPDATE historial_full
SET volume = NULL
WHERE volume = 'null';

UPDATE historial_full
SET ask = NULL
WHERE ask = '';

UPDATE historial_full
SET bid = REPLACE(bid, CHAR(13) + CHAR(10),'');

UPDATE historial_full
SET company_name = 'Superior Plus Corp.'
WHERE company_name = 'superior plus corp';

UPDATE historial_full
SET company_name = 'TerraVest Industries Inc.'
WHERE company_name = 'TerraVest Industries Inc';

UPDATE historial_full
SET dates =  STR_TO_DATE(dates, '%m/%d/%Y');

ALTER TABLE historial_full MODIFY dates DATE;

SELECT * FROM historial_full;

ALTER TABLE historial_full MODIFY open_price FLOAT(10,6);

ALTER TABLE historial_full MODIFY high FLOAT(10,6);

ALTER TABLE historial_full MODIFY low FLOAT(10,6);

ALTER TABLE historial_full MODIFY close_price FLOAT(10,6);

ALTER TABLE historial_full MODIFY adj_close_price FLOAT(10,6);

ALTER TABLE historial_full MODIFY volume INT;

ALTER TABLE historial_full MODIFY ask FLOAT(8,2);

ALTER TABLE company_info ADD primary key(comp_name);

#ALTER TABLE historial_full ADD FOREIGN KEY(company_name) REFERENCES company_info(company_name);

SELECT * FROM historial_full
LEFT JOIN company_info
ON historial_full.company_name = company_info.comp_name;

CREATE TABLE full_data 
SELECT * FROM historial_full
LEFT JOIN company_info
ON historial_full.company_name = company_info.comp_name;

DESCRIBE full_data;
SELECT * FROM full_data WHERE ticker IS NULL;
SELECT DISTINCT company_name FROM full_data;

ALTER TABLE full_data DROP COLUMN comp_name;



#=========================================================== r_m - r_f ==============================================================

DROP TABLE IF EXISTS GSPTSE; 

CREATE TABLE GSPTSE (
	datess VARCHAR(50),
    open_price_total VARCHAR(50),
    high_total VARCHAR(50),
    low_total VARCHAR(50),
    close_price_total VARCHAR(50),
    adj_close_price_total VARCHAR(50),
    volume_total VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/^GSPTSE.csv"
INTO TABLE GSPTSE
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE GSPTSE MODIFY datess DATE;

ALTER TABLE GSPTSE MODIFY open_price_total FLOAT(11, 6);

ALTER TABLE GSPTSE MODIFY high_total FLOAT(11,6);

ALTER TABLE GSPTSE MODIFY low_total FLOAT(11,6);

ALTER TABLE GSPTSE MODIFY close_price_total FLOAT(11,6);

ALTER TABLE GSPTSE MODIFY adj_close_price_total FLOAT(11,6);

ALTER TABLE GSPTSE MODIFY volume_total INTEGER;

SELECT * FROM GSPTSE;

DROP TABLE IF EXISTS full_data_tsx;
CREATE TABLE full_data_tsx
SELECT * FROM GSPTSE
LEFT JOIN full_data
ON GSPTSE.datess = full_data.dates;

ALTER TABLE full_data_tsx DROP COLUMN dates;
ALTER TABLE full_data_tsx RENAME COLUMN datess to dates;

ALTER TABLE full_data_tsx DROP COLUMN open_price_total;
ALTER TABLE full_data_tsx DROP COLUMN high_total;
ALTER TABLE full_data_tsx DROP COLUMN low_total;
ALTER TABLE full_data_tsx DROP COLUMN close_price_total;
ALTER TABLE full_data_tsx DROP COLUMN adj_close_price_total;
ALTER TABLE full_data_tsx DROP COLUMN volume_total;

SELECT * FROM full_data_tsx;

CREATE TABLE treasury_bill_rate (
	dates VARCHAR(50),
    rate VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/treasury_bill_rate.csv"
INTO TABLE treasury_bill_rate
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM treasury_bill_rate;

UPDATE treasury_bill_rate 
SET rate = NULL
WHERE rate LIKE '%Bank holiday%';

UPDATE treasury_bill_rate 
SET rate = REPLACE(rate, CHAR(13) + CHAR(10),'');

ALTER TABLE treasury_bill_rate MODIFY dates DATE;

CREATE TABLE tsx
SELECT * FROM GSPTSE
LEFT JOIN treasury_bill_rate
ON GSPTSE.datess = treasury_bill_rate.dates;

SELECT * FROM tsx;

ALTER TABLE tsx DROP COLUMN dates;
ALTER TABLE tsx RENAME COLUMN datess to dates;



#============================================================= smb ==================================================================
DROP TABLE IF EXISTS return_data;
CREATE TABLE return_data(
	ind INTEGER,
    company_name VARCHAR(50),
    ticker VARCHAR(50),
    dates DATE,
    return_val VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/return_data.csv"
INTO TABLE return_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(DISTINCT dates) FROM return_data WHERE ticker = 'tvk+.';


#small mc company
SELECT DISTINCT ticker FROM full_data_tsx WHERE market_cap = 'small';

SELECT * FROM return_data;

DROP TABLE IF EXISTS AD;
DROP TABLE IF EXISTS AGT;
DROP TABLE IF EXISTS SPB;
DROP TABLE IF EXISTS TCS;
DROP TABLE IF EXISTS TVK;
DROP TABLE IF EXISTS ZYME;
DROP TABLE IF EXISTS s1;
DROP TABLE IF EXISTS s2;
DROP TABLE IF EXISTS s3;
DROP TABLE IF EXISTS s4;
DROP TABLE IF EXISTS s5;

CREATE TABLE AD
SELECT dates AS d1, return_val AS r1 FROM return_data
WHERE ticker = 'AD';

CREATE TABLE AGT
SELECT dates AS d2, return_val AS r2 FROM return_data
WHERE ticker = 'AGT';

CREATE TABLE SPB
SELECT dates AS d3, return_val AS r3 FROM return_data
WHERE ticker = 'SPB';

CREATE TABLE TCS
SELECT dates AS d4, return_val AS r4 FROM return_data
WHERE ticker = 'TCS';

CREATE TABLE TVK
SELECT dates AS d5, return_val AS r5 FROM return_data
WHERE ticker = 'TVK';

CREATE TABLE ZYME
SELECT dates AS d6, return_val AS r6 FROM return_data
WHERE ticker = 'ZYME';

CREATE TABLE s1
SELECT * FROM AD
LEFT JOIN AGT
ON AD.d1 = AGT.d2;

CREATE TABLE s2
SELECT * FROM s1
LEFT JOIN SPB
ON s1.d1 = SPB.d3;

CREATE TABLE s3
SELECT * FROM s2
LEFT JOIN TCS
ON s2.d1 = TCS.d4;

CREATE TABLE s4
SELECT * FROM s3
LEFT JOIN TVK
ON s3.d1 = TVK.d5;

CREATE TABLE s5
SELECT * FROM s4
LEFT JOIN ZYME
ON s4.d1 = ZYME.d6;

DROP TABLE IF EXISTS s1;
DROP TABLE IF EXISTS s2;
DROP TABLE IF EXISTS s3;
DROP TABLE IF EXISTS s4;
DROP TABLE IF EXISTS total;
DROP TABLE IF EXISTS small_mc_data;

DROP TABLE IF EXISTS avg_small;

CREATE TABLE avg_small
SELECT d1 AS dates, (IFNULL(r1,0) + IFNULL(r2,0) + IFNULL(r3,0) + IFNULL(r4,0) + IFNULL(r5,0) + IFNULL(r6,0)) /COUNT(*) AS avg_small
FROM s5
GROUP BY d1;

CREATE TABLE small_mc_data
SELECT * FROM s5
LEFT JOIN avg_small
ON s5.d1 = avg_small.dates;

SELECT * FROM small_mc_data;
ALTER TABLE small_mc_data DROP COLUMN d2;
ALTER TABLE small_mc_data DROP COLUMN d3;
ALTER TABLE small_mc_data DROP COLUMN d4;
ALTER TABLE small_mc_data DROP COLUMN d5;
ALTER TABLE small_mc_data DROP COLUMN d6;
ALTER TABLE small_mc_data DROP COLUMN dates;

#large mc company
SELECT DISTINCT ticker FROM full_data_tsx WHERE market_cap = 'large';

DROP TABLE IF EXISTS WEED;
DROP TABLE IF EXISTS CSU;
DROP TABLE IF EXISTS DOL;
DROP TABLE IF EXISTS H;
DROP TABLE IF EXISTS RY;
DROP TABLE IF EXISTS SU;
DROP TABLE IF EXISTS l1;
DROP TABLE IF EXISTS l2;
DROP TABLE IF EXISTS l3;
DROP TABLE IF EXISTS l4;
DROP TABLE IF EXISTS l5;

CREATE TABLE WEED
SELECT dates AS d1, return_val AS r1 FROM return_data
WHERE ticker = 'WEED';

CREATE TABLE CSU
SELECT dates AS d2, return_val AS r2 FROM return_data
WHERE ticker = 'CSU';

CREATE TABLE DOL
SELECT dates AS d3, return_val AS r3 FROM return_data
WHERE ticker = 'DOL';

CREATE TABLE H
SELECT dates AS d4, return_val AS r4 FROM return_data
WHERE ticker = 'H';

CREATE TABLE RY
SELECT dates AS d5, return_val AS r5 FROM return_data
WHERE ticker = 'RY';

CREATE TABLE SU
SELECT dates AS d6, return_val AS r6 FROM return_data
WHERE ticker = 'SU';

SELECT COUNT(*) FROM CSU;

CREATE TABLE l1
SELECT * FROM CSU
LEFT JOIN WEED
ON CSU.d2 = WEED.d1;

CREATE TABLE l2
SELECT * FROM l1
LEFT JOIN DOL
ON l1.d2 = DOL.d3;

CREATE TABLE l3
SELECT * FROM l2
LEFT JOIN H
ON l2.d2 = H.d4;

CREATE TABLE l4
SELECT * FROM l3
LEFT JOIN RY
ON l3.d2 = RY.d5;

CREATE TABLE l5
SELECT * FROM l4
LEFT JOIN SU
ON l4.d2 = SU.d6;

DROP TABLE IF EXISTS l1;
DROP TABLE IF EXISTS l2;
DROP TABLE IF EXISTS l3;
DROP TABLE IF EXISTS l4;
DROP TABLE IF EXISTS total_large;
DROP TABLE IF EXISTS large_mc_data;
DROP TABLE IF EXISTS avg_large;

CREATE TABLE avg_large
SELECT d2 AS dates, (IFNULL(r1,0) + IFNULL(r2,0) + IFNULL(r3,0) + IFNULL(r4,0) + IFNULL(r5,0) + IFNULL(r6,0)) / COUNT(*) AS avg_large
FROM l5
GROUP BY d2;

CREATE TABLE large_mc_data
SELECT * FROM l5
LEFT JOIN avg_large
ON l5.d2 = avg_large.dates;

SELECT * FROM large_mc_data;

SELECT * FROM large_mc_data;
ALTER TABLE large_mc_data DROP COLUMN d1;
ALTER TABLE large_mc_data DROP COLUMN d3;
ALTER TABLE large_mc_data DROP COLUMN d4;
ALTER TABLE large_mc_data DROP COLUMN d5;
ALTER TABLE large_mc_data DROP COLUMN d6;
ALTER TABLE large_mc_data DROP COLUMN dates;

DROP TABLE IF EXISTS SMB;
CREATE TABLE SMB
SELECT avg_small.dates, avg_small.avg_small - avg_large.avg_large AS SMB_val FROM 
avg_small 
LEFT JOIN avg_large
ON avg_small.dates = avg_large.dates;

SELECT COUNT(DISTINCT dates) FROM return_data WHERE ticker = 'TCS';



#=============================================================== hml ================================================================

#pb_data
DROP TABLE IF EXISTS pb_data;
CREATE TABLE pb_data(
	ticker VARCHAR(50),
    dates DATE,
    pb VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/p-b.csv"
INTO TABLE pb_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n';

DELETE FROM pb_data WHERE ticker = 'DOL';

DROP TABLE IF EXISTS low_pb_data;
DROP TABLE IF EXISTS high_pb_data;

CREATE TABLE low_pb_data
SELECT dates AS d1, pb AS pb_val_low
FROM pb_data
WHERE pb < 2.5;

CREATE TABLE high_pb_data
SELECT dates AS d2, pb AS pb_val_high
FROM pb_data
WHERE pb > 7;

DROP TABLE IF EXISTS HML1;
CREATE TABLE HML1
SELECT d1, SUM(IFNULL(high_pb_data.pb_val_high,0))/ COUNT(*) - SUM(IFNULL(low_pb_data.pb_val_low,0)) / COUNT(*) AS HML_val
FROM low_pb_data 
LEFT JOIN high_pb_data
ON low_pb_data.d1 = high_pb_data.d2
GROUP BY d1;

DROP TABLE IF EXISTS HML;
CREATE TABLE HML
SELECT * FROM HML1
RIGHT JOIN tsx
ON tsx.dates = HML1.d1;

SELECT distinct dates FROM pb_data;
ALTER TABLE HML DROP COLUMN dates;
ALTER TABLE HML DROP COLUMN open_price_total;
ALTER TABLE HML DROP COLUMN high_total;
ALTER TABLE HML DROP COLUMN low_total;
ALTER TABLE HML DROP COLUMN close_price_total;
ALTER TABLE HML DROP COLUMN adj_close_price_total;
ALTER TABLE HML DROP COLUMN rate;
ALTER TABLE HML DROP COLUMN volume_total;

SELECT COUNT(DISTINCT d1) FROM HML;



#============================================================ ff model ==============================================================

DROP TABLE IF EXISTS first_reg_data;
CREATE TABLE first_reg_data(
	ind INTEGER,
	dates DATE,
    return_val VARCHAR(50)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/first_reg_data.csv"
INTO TABLE first_reg_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE data1
SELECT dates AS datess FROM first_reg_data
LEFT JOIN SMB
ON first_reg_data.datess = SMB.dates;

CREATE TABLE data2
SELECT datess FROM data1
LEFT JOIN HML
ON data1.dates = HML.d1;

ALTER TABLE data2 DROP COLUMN dates;
ALTER TABLE data2 DROP COLUMN d1;

CREATE TABLE ff_model_data 
SELECT dates, company_name, ticker FROM ff_model_tsx
LEFT JOIN data2
ON data3.dates = data2.datess;

ALTER TABLE ff_model_data DROP COLUMN datass;

SELECT * FROM tsx;
SELECT * FROM return_data;
ALTER TABLE return_data DROP COLUMN ind;

DROP TABLE IF EXISTS response_data;

SELECT COUNT(*) FROM return_data;

CREATE TABLE response_data
SELECT return_data.dates, (return_data.return_val - tsx.rate)
FROM return_data
LEFT JOIN tsx
ON return_data.dates = tsx.dates
GROUP BY return_data.dates;

SELECT * FROM tsx;

#=====================================================================================================================================================

CREATE TABLE DBRS (
	company_name VARCHAR(50),
    ticker VARCHAR(50),
    industry ENUM('technology', 'energy', 'healthcare', 'consumer_defensive', 'financial_services', 'utilities'),
	credit_rating VARCHAR(50),
    rating_level VARCHAR(50)
);

INSERT INTO DBRS (
	company_name, 
    ticker, 
    industry, 
    credit_rating,
    rating_level)
VALUES 
	('TECSYS Inc.', 'TCS', 'technology', 'BBB', 'low'),
    ('Kinaxis', 'KXS', 'technology', 'BBB', 'high'),
    ('Constellation Software', 'CSU', 'technology', 'BBB', 'medium'),
    ('TerraVest Industries Inc.', 'TVK', 'energy', 'BB', 'low'),
    ('Parkland Fuel Corporation', 'PKI', 'energy', 'BB', 'high'),
    ('Suncor Energy Inc.', 'SU', 'energy', 'A', 'low'),
    ('Zymeworks', 'ZYME', 'Healthcare', 'BB', 'high'),
    ('Chartwell Retirement Residences', 'CSH.UN', 'Healthcare', 'BBB','low'),
    ('Canopy Growth Corporation', 'WEED', 'Healthcare', 'BB', 'medium'),
    ('AGT Food and Ingredients', 'AGT', 'consumer_defensive', 'B', 'medium'),
    ('Maple Leaf Foods', 'MFI', 'consumer_defensive', 'A', 'medium'),
    ('Dollarama', 'DOL', 'consumer_defensive', 'BBB','medium'),
    ('Alaris Royalty Corp.', 'AD', 'financial_services', 'A','low'),
    ('TMX Group Limited', 'X', 'financial_services', 'A','high'),
    ('Royal Bank of Canada', 'RY', 'financial_services', 'AA', 'medium'),
    ('Superior Plus Corp.', 'SPB', 'utilities', 'BB', 'medium'),
    ('Northland Power', 'NPI', 'utilities', 'BBB', 'medium'),
    ('Hydro One Limited', 'H', 'utilities', 'A', 'medium');
    
SELECT * FROM DBRS;


#=====================================================================================================================================================
DROP TABLE IF EXISTS month_data;

CREATE TABLE month_data(
	ind INTEGER,
    ticker VARCHAR(50),
    return_val VARCHAR(50),
    months CHAR(2),
    dates DATE
);

DESC month_data;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/month_data.csv"
INTO TABLE month_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM month_data;

DELETE FROM month_data WHERE return_val = 'Inf';

ALTER TABLE month_data MODIFY return_val FLOAT(35,20);

SELECT * FROM month_data WHERE ind = 1246;

SELECT * FROM month_data WHERE return_val != 'Inf';

CREATE TABLE TCS_data
SELECT * FROM month_data
WHERE ticker = 'TCS';

CREATE TABLE KXS_data
SELECT * FROM month_data
WHERE ticker = 'KXS';

CREATE TABLE CSU_data
SELECT * FROM month_data
WHERE ticker = 'CSU';

CREATE TABLE TVK_data
SELECT * FROM month_data
WHERE ticker = 'TVK';

CREATE TABLE PHI_data
SELECT * FROM month_data
WHERE ticker = 'PKI';

CREATE TABLE SU_data
SELECT * FROM month_data
WHERE ticker = 'SU';

CREATE TABLE ZYME_data
SELECT * FROM month_data
WHERE ticker = 'ZYME';

CREATE TABLE CSH_data
SELECT * FROM month_data
WHERE ticker = 'CSH.UN';

CREATE TABLE WEED_data
SELECT * FROM month_data
WHERE ticker = 'WEED';

CREATE TABLE AGT_data
SELECT * FROM month_data
WHERE ticker = 'AGT';

CREATE TABLE MFI_data
SELECT * FROM month_data
WHERE ticker = 'MFI';

CREATE TABLE DOL_data
SELECT * FROM month_data
WHERE ticker = 'DOL';

CREATE TABLE AD_data
SELECT * FROM month_data
WHERE ticker = 'AD';

CREATE TABLE X_data
SELECT * FROM month_data
WHERE ticker = 'X';

CREATE TABLE RY_data
SELECT * FROM month_data
WHERE ticker = 'RY';

CREATE TABLE SPB_data
SELECT * FROM month_data
WHERE ticker = 'SPB';

CREATE TABLE NPI_data
SELECT * FROM month_data
WHERE ticker = 'NPI';

CREATE TABLE H_data
SELECT * FROM month_data
WHERE ticker = 'H';


CREATE TABLE TCS_stddev
SELECT ticker, dates, months, STD(return_val) FROM TCS_data
GROUP BY months;

CREATE TABLE KXS_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM KXS_data
GROUP BY months;

CREATE TABLE CSU_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM CSU_data
GROUP BY months;

CREATE TABLE TVK_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM TVK_data
GROUP BY months;

CREATE TABLE PHI_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM PHI_data
GROUP BY months;

CREATE TABLE SU_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM SU_data
GROUP BY months;

CREATE TABLE ZYME_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM ZYME_data
GROUP BY months;

CREATE TABLE CSH_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM CSH_data
GROUP BY months;

CREATE TABLE WEED_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM WEED_data
GROUP BY months;

CREATE TABLE AGT_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM AGT_data
GROUP BY months;

CREATE TABLE MFI_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM MFI_data
GROUP BY months;

CREATE TABLE DOL_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM DOL_data
GROUP BY months;

CREATE TABLE AD_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM AD_data
GROUP BY months;

CREATE TABLE X_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM X_data
GROUP BY months;


CREATE TABLE RY_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM RY_data
GROUP BY months;


CREATE TABLE SPB_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM SPB_data
GROUP BY months;

CREATE TABLE NPI_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM NPI_data
GROUP BY months;

CREATE TABLE H_stddev
SELECT ticker, dates, months, STD(return_val) AS stdd  FROM H_data
GROUP BY months;


CREATE TABLE month_sd_data
SELECT * FROM TCS_stddev
UNION
SELECT * FROM KXS_stddev
UNION
SELECT * FROM CSU_stddev
UNION
SELECT * FROM TVK_stddev
UNION
SELECT * FROM PHI_stddev
UNION
SELECT * FROM SU_stddev
UNION
SELECT * FROM ZYME_stddev
UNION
SELECT * FROM CSH_stddev
UNION
SELECT * FROM WEED_stddev
UNION
SELECT * FROM AGT_stddev
UNION
SELECT * FROM MFI_stddev
UNION
SELECT * FROM DOL_stddev
UNION
SELECT * FROM AD_stddev
UNION
SELECT * FROM X_stddev
UNION
SELECT * FROM RY_stddev
UNION
SELECT * FROM SPB_stddev
UNION
SELECT * FROM NPI_stddev
UNION
SELECT * FROM H_stddev;







