CREATE DATABASE flikr;
USE flikr;

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE book (
	identifier LONGTEXT,
    edition VARCHAR(500),
    publication_place VARCHAR(500),
    publication_date VARCHAR(500),
    publisher VARCHAR(500),
    title LONGTEXT,
    author VARCHAR(500),
    contributors VARCHAR(5000),
    corporate_author VARCHAR(500),
    corporate_contributors VARCHAR(500),
    former_owner VARCHAR(500),
    engraver VARCHAR(500),
    issuance_type VARCHAR(500),
    flicker_url VARCHAR(500),
    shelfmarks VARCHAR(500)
    );

DESC book;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/BL-Flickr-Images-Book.csv"
INTO TABLE book
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM book;

ALTER TABLE book 
ADD 		id INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST,
ADD         PRIMARY KEY (id);

SELECT COUNT(*) FROM book;

SELECT COUNT(*) FROM book WHERE corporate_author IS NULL OR corporate_author = ''; #empty column
SELECT COUNT(*) FROM book WHERE corporate_contributors IS NULL OR corporate_contributors = ''; #empty column
SELECT COUNT(*) FROM book WHERE former_owner IS NULL OR former_owner = '';
SELECT COUNT(*) FROM book WHERE engraver IS NULL OR engraver = ''; #empty column
SELECT * FROM book WHERE former_owner != '';

ALTER TABLE book DROP COLUMN corporate_author;
ALTER TABLE book DROP COLUMN corporate_contributors;
ALTER TABLE book DROP COLUMN engraver;

SELECT * FROM book;

SELECT COUNT(*) FROM book WHERE identifier != ''; #no null data
SELECT COUNT(*) FROM book WHERE publication_place != ''; #no null data
SELECT COUNT(*) FROM book WHERE title != ''; #no null data
SELECT COUNT(*) FROM book WHERE contributors != ''; #no null data
SELECT COUNT(*) FROM book WHERE issuance_type != ''; #no null data
SELECT COUNT(*) FROM book WHERE flicker_url != ''; #no null data
SELECT COUNT(*) FROM book WHERE shelfmarks != ''; #no null data

UPDATE book
SET    publication_date = NULL
WHERE  publication_date LIKE '%?%';

UPDATE book
SET    publication_date = NULLIF(publication_date, '');

SELECT SUBSTRING_INDEX(publication_date, ',', -1) from book;

UPDATE book
SET    publication_date = SUBSTRING_INDEX(publication_place, ',', -1)
WHERE  RIGHT(publication_place, 4) REGEXP '[0-9]' AND publication_date IS NULL AND SUBSTRING_INDEX(publication_place, ',', -1) NOT LIKE '%?%';

UPDATE book
SET    publication_date = REPLACE(publication_date, ' ', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, 'c.', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, '.', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, ',', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, '-', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, '/', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, '[', '');

UPDATE book
SET    publication_date = REPLACE(publication_date, ']', '');

UPDATE book
SET    publication_date = NULL
WHERE  CHAR_LENGTH(publication_date) < 4;

UPDATE book
SET    publication_date = LEFT(publication_date, 4) ;

UPDATE book
SET    publication_date = NULL
WHERE  publication_date NOT REGEXP '^[[:digit:]]+$';

UPDATE book
SET    publication_date = 1895
WHERE  id = 8264;

SELECT * FROM book;

ALTER TABLE book MODIFY publication_date SMALLINT;


SELECT * FROM book WHERE publisher REGEXP '[0-9]';

SELECT * FROM book WHERE publication_place LIKE 'pp%';

SELECT * FROM book WHERE publisher REGEXP '[0-9]';


#=====================================================================================================================

UPDATE book
SET publisher = NULLIF(publisher, '');

UPDATE book
SET    publisher = SUBSTRING_INDEX(publication_place,':',1)
WHERE  publication_place REGEXP '[0-9]' AND publisher IS NULL AND publication_place LIKE 'pp%' OR publication_place LIKE 'ff%' OR publication_place LIKE '%vol%';

SELECT * FROM book
WHERE  publisher IS NULL AND publication_place LIKE '%:%' AND publication_place LIKE 'London%';

SELECT publication_place, RIGHT(publication_place, CHAR_LENGTH(publication_place) - LOCATE(':', publication_place,1)) FROM book
WHERE  publisher IS NULL AND publication_place LIKE '%:%' AND publication_place LIKE 'London：%';

UPDATE book
SET    publisher = RIGHT(publication_place, CHAR_LENGTH(publication_place) - LOCATE(':', publication_place,1))
WHERE  publisher IS NULL AND publication_place LIKE '%:%' AND publication_place LIKE 'London：%';

SELECT publication_place, SUBSTRING_INDEX(publication_place, ':',1) FROM book
WHERE  publisher IS NULL AND publication_place LIKE '%: London%' AND publication_place NOT LIKE 'Privately printed%';

Update book
SET    publisher = SUBSTRING_INDEX(publication_place, ':',1)
WHERE  publisher IS NULL AND publication_place LIKE '%: London%' AND publication_place NOT LIKE 'Privately printed%';

UPDATE book
SET    publisher = REPLACE(publisher,'0','');

UPDATE book
SET    publisher = REPLACE(publisher,'1','');

UPDATE book
SET    publisher = REPLACE(publisher,'2','');

UPDATE book
SET    publisher = REPLACE(publisher,'3','');

UPDATE book
SET    publisher = REPLACE(publisher,'4','');

UPDATE book
SET    publisher = REPLACE(publisher,'5','');

UPDATE book
SET    publisher = REPLACE(publisher,'6','');

UPDATE book
SET    publisher = REPLACE(publisher,'7','');

UPDATE book
SET    publisher = REPLACE(publisher,'8','');

UPDATE book
SET    publisher = REPLACE(publisher,'9','');

SELECT publisher, RIGHT(publisher, char_length(publisher) - LOCATE('.', publisher,5)) FROM book
WHERE  publication_place LIKE '%:%' AND publisher LIKE '%. .%';

UPDATE book
SET    publisher = RIGHT(publisher, char_length(publisher) - LOCATE('.', publisher,5))
WHERE  publication_place LIKE '%:%' AND publisher LIKE '%. .%';

SELECT publisher, RIGHT(publisher, char_length(publisher) - LOCATE('.', publisher,1)) FROM book
WHERE  publication_place LIKE '%:%' AND publisher LIKE '%. .%' OR publisher LIKE '%vol%';

UPDATE book
SET    publisher = RIGHT(publisher, char_length(publisher) - LOCATE('.', publisher,1))
WHERE  publication_place LIKE '%:%' AND publisher LIKE '%. .%' OR publisher LIKE '%vol%';

UPDATE book
SET    publisher = LTRIM(publisher);

UPDATE book
SET    publisher = RTRIM(publisher);

UPDATE book
SET    publisher = trim(LEADING '.' FROM publisher)
WHERE  publisher LIKE '.%';

UPDATE book
SET    publisher = LTRIM(publisher);

UPDATE book
SET    publisher = REPLACE(publisher, ',','')
WHERE  publisher LIKE ',%' OR publisher LIKE '%,';

UPDATE book
SET    publisher = REPLACE(publisher, '?','')
WHERE  publisher LIKE '%?%';

UPDATE book
SET    publisher = REPLACE(publisher, ']','')
WHERE  publisher LIKE ']%' OR publisher LIKE '%]' OR publisher LIKE '%]%';

UPDATE book
SET    publisher = REPLACE(publisher, '[','')
WHERE  publisher LIKE '[%' OR publisher LIKE '%[' OR publisher LIKE '%[%';

UPDATE book
SET    publisher = REPLACE(publisher, 'Co', 'Co.')
WHERE  publisher LIKE '%Co';

UPDATE book
SET    publisher = REPLACE(publisher, '“', '')
WHERE  publisher LIKE '“%' OR publisher LIKE '%“' OR publisher LIKE '%“%';

UPDATE book
SET    publisher = REPLACE(publisher, '”', '')
WHERE  publisher LIKE '”%' OR publisher LIKE '%”' OR publisher LIKE '%”%';

UPDATE book
SET    publisher = NULL
WHERE  id = 1082 OR id = 8196;

UPDATE book
SET    publisher = 'T. C. Newbey'
WHERE  id = 373;

UPDATE book
SET    publisher = REPLACE(publisher, '.','')
WHERE  id = 387;

UPDATE book
SET    publisher = 'G. G. J. & J. Robinson' 
WHERE  id = 1051;

UPDATE book
SET    publisher = 'Nichols & Co.' 
WHERE  id = 1165;

UPDATE book
SET    publisher = 'John Murray' 
WHERE  id = 2963;

UPDATE book
SET    publisher = 'E. P. for H. Seyle' 
WHERE  id = 3095;

UPDATE book
SET    publisher = 'Ward & Downey'
WHERE  id = 5401;

UPDATE book
SET    publisher = SUBSTRING_INDEX(publisher,',',1)
WHERE  id = 5462;

UPDATE book
SET    publisher = 'W. Blackwood & Sons' 
WHERE  id = 7145;

UPDATE book
SET    publisher = 'Willoughby & Co.' 
WHERE  id = 7156;

UPDATE book
SET    publisher = 'BEAN & SON'
WHERE  id = 7995;

UPDATE book
SET    publisher = 'Jackson, Walford & Hodder'
WHERE  id = 8268;



#=============================================================================================================

UPDATE book
SET    publication_place = 'London'
WHERE  publication_place LIKE '%London' OR publication_place LIKE 'London%' OR publication_place LIKE '%London%';

SELECT * FROM BOOK
WHERE  NOT(publication_place LIKE '%London' OR publication_place LIKE 'London%' OR publication_place LIKE '%London%');

SELECT * FROM book
WHERE  publication_place LIKE '%:%' AND NOT(publication_place LIKE '%London' OR publication_place LIKE 'London%' OR publication_place LIKE '%London%');

SELECT publication_place, RIGHT(publication_place, CHAR_LENGTH(publication_place) - LOCATE(':', publication_place, 1)) FROM book
WHERE  NOT(publication_place LIKE '%London' OR publication_place LIKE 'London%' OR publication_place LIKE '%London%') AND publication_place LIKE '%:%';

UPDATE book
SET    publication_place = RIGHT(publication_place, CHAR_LENGTH(publication_place) - LOCATE(':', publication_place, 1))
WHERE  NOT(publication_place LIKE '%London' OR publication_place LIKE 'London%' OR publication_place LIKE '%London%') AND publication_place LIKE '%:%';


UPDATE book
SET    publication_place = LTRIM(publication_place);

UPDATE book
SET    publication_place = RTRIM(publication_place);

UPDATE book
SET    publication_place = REPLACE(publication_place, '0','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '1','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '2','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '3','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '4','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '5','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '6','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '7','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '8','');

UPDATE book
SET    publication_place = REPLACE(publication_place, '9','');

SELECT * FROM book
WHERE  NOT(publication_place LIKE '%London' OR publication_place LIKE 'London%' OR publication_place LIKE '%London%');

UPDATE book
SET    publication_place = ''
WHERE  publication_place LIKE '%?';

UPDATE book
SET    publication_place = REPLACE(publication_place, 'xxu', 'United States')
WHERE  publication_place = 'xxu';

UPDATE book
SET    publication_place = REPLACE(publication_place, 'enk', 'England')
WHERE  publication_place = 'enk';

UPDATE book
SET    publisher = REPLACE(publisher, 'ru', ', Russia (Federation)')
WHERE  publisher = 'ru';

SELECT publication_place FROM book
WHERE publication_place LIKE '%Reprinted%';

UPDATE book
SET    publication_place = REPLACE(publication_place, 'Mass.', ', Mass.');

UPDATE book
SET    publication_place = 'Edinburgh' 
WHERE  id = 132 OR id = 477;

UPDATE book
SET    publication_place = '' 
WHERE  id = 1158 OR id = 2730 OR id = 7474;

SELECT * FROM book WHERE publication_place LIKE '%John Murray%';

UPDATE book
SET    publication_place = 'London' 
WHERE  id = 2963 OR id = 7156;

UPDATE book
SET    publisher = SUBSTRING_INDEX(publisher, ';', 1) 
WHERE  id = 7381;


UPDATE book
SET    publisher = REPLACE (publisher,'pp. .','')
WHERE  id = 8196;

Update book
SET    publication_place = LTRIM(publication_place);

UPDATE book
SET    publication_place = RTRIM(publication_place);

UPDATE book
SET    publisher = REPLACE(publisher, 'U.S.', ', U.S.'); 

UPDATE book
SET    publisher = REPLACE(publisher, 'Chilo', ', Chilo'); 

UPDATE book
SET    publisher = REPLACE(publisher, 'Conn', ', Conn.');

UPDATE book
SET    publisher = REPLACE(publisher, 'N.H.', ', N.H.'); 

UPDATE book
SET    publisher = REPLACE(publisher, 'Stirling', ', Stirling.');

UPDATE book
SET    publisher = REPLACE (publisher,'Newcastle upon Tyne','Newcastle-upon-Tyne');

UPDATE book
SET    publication_place = REPLACE(publication_place, 'New-York', 'New York');

UPDATE book
SET    publication_place = REPLACE(publication_place, '[','')
WHERE  publication_place LIKE '%[%' OR publication_place LIKE '[%' OR publication_place LIKE '%[';

UPDATE book
SET    publication_place = REPLACE(publication_place, ']','')
WHERE  publication_place LIKE '%]%' OR publication_place LIKE ']%' OR publication_place LIKE '%]';

UPDATE book
SET    publication_place = REPLACE(publication_place, '.','')
WHERE  publication_place LIKE '%.' OR publication_place LIKE '.%';

UPDATE book
SET    publication_place = REPLACE(publication_place, ',','')
WHERE  publication_place LIKE '%,' OR publication_place LIKE ',%';

UPDATE book
SET    publication_place = REPLACE(publication_place, ';','')
WHERE  publication_place LIKE '%;' OR publication_place LIKE ';%';

UPDATE book
SET    publication_place = REPLACE(publication_place, '&','')
WHERE  publication_place LIKE '%&' OR publication_place LIKE '&%';

UPDATE book
SET    publication_place = REPLACE(publication_place, ', ,', ',');

UPDATE book
SET    publication_place = ''
WHERE  publication_place LIKE '%?';

UPDATE book
SET    publication_place = NULLIF(publication_place, '');

#====================================================================================
UPDATE book
SET edition = NULLIF(edition,'');

UPDATE book
SET former_owner = NULLIF(former_owner,'');

UPDATE book
SET author = NULLIF(author,'');

SELECT * FROM book;

ALTER TABLE book MODIFY publisher VARCHAR(100);

ALTER TABLE book MODIFY publication_place VARCHAR(50);