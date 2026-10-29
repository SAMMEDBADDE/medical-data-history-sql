USE project_medical_data_history;

ALTER TABLE admissions
RENAME COLUMN attending_doctor_id TO doctor_id;


-- 1. Male patients
SELECT first_name, last_name, gender
FROM patients
WHERE gender = 'M';

-- 2. Patients with no allergies
SELECT first_name, last_name
FROM patients
WHERE allergies IS NULL;

-- 3. First names starting with C
SELECT first_name
FROM patients
WHERE first_name LIKE 'C%';

-- 4. Patients weighing from 100 through 120
SELECT first_name, last_name
FROM patients
WHERE weight BETWEEN 100 AND 120;

-- 5. Replace missing allergies with NKA
UPDATE patients
SET allergies = 'NKA'
WHERE allergies IS NULL;

SELECT
  patient_id,
  allergies AS original_allergies,
  COALESCE(allergies, 'NKA') AS updated_allergies
FROM patients;

-- 6. Full name in one column
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM patients;

-- 7. Patient name with full province name
SELECT p.first_name, p.last_name, pn.province_name
FROM patients AS p
JOIN province_names AS pn
  ON p.province_id = pn.province_id;

-- 8. Number of patients born in 2010
SELECT COUNT(*) AS patients_born_in_2010
FROM patients
WHERE YEAR(birth_date) = 2010;

-- 9. Patient(s) with the greatest height
SELECT first_name, last_name, height
FROM patients
WHERE height = (
  SELECT MAX(height)
  FROM patients
);

-- 10. Patients with specified IDs
SELECT *
FROM patients
WHERE patient_id IN (1, 45, 534, 879, 1000);

-- 11. Total admissions
SELECT COUNT(*) AS total_admissions
FROM admissions;

-- 12. Admissions with same admission and discharge date
SELECT *
FROM admissions
WHERE admission_date = discharge_date;

-- 13. Admissions for patient ID 579
SELECT COUNT(*) AS admissions_for_patient_579
FROM admissions
WHERE patient_id = 579;

-- 14. Unique cities in province NS
SELECT DISTINCT city
FROM patients
WHERE province_id = 'NS';

-- 15. Patients taller than 160 and heavier than 70
SELECT first_name, last_name, birth_date
FROM patients
WHERE height > 160
  AND weight > 70;

-- 16. Unique birth years in ascending order
SELECT DISTINCT YEAR(birth_date) AS birth_year
FROM patients
ORDER BY birth_year;

-- 17. First names that occur only once
SELECT first_name
FROM patients
GROUP BY first_name
HAVING COUNT(*) = 1;

-- 18. Names starting and ending with s, at least six characters
SELECT patient_id, first_name
FROM patients
WHERE first_name LIKE 's%s'
  AND LENGTH(first_name) >= 6;

-- 19. Patients diagnosed with Dementia
SELECT DISTINCT p.patient_id, p.first_name, p.last_name
FROM patients AS p
JOIN admissions AS a
  ON p.patient_id = a.patient_id
WHERE a.diagnosis = 'Dementia';

-- 20. First names ordered by length, then alphabetically
SELECT first_name
FROM patients
ORDER BY LENGTH(first_name), first_name;

-- 21. Male and female totals in one row
SELECT
  SUM(gender = 'M') AS male_patients,
  SUM(gender = 'F') AS female_patients
FROM patients;

-- 22. Same result, using CASE
SELECT
  COUNT(CASE WHEN gender = 'M' THEN 1 END) AS male_patients,
  COUNT(CASE WHEN gender = 'F' THEN 1 END) AS female_patients
FROM patients;

-- 23. Repeated admissions with the same diagnosis
SELECT patient_id, diagnosis
FROM admissions
GROUP BY patient_id, diagnosis
HAVING COUNT(*) > 1;

-- 24. Patient count by city
SELECT city, COUNT(*) AS patient_count
FROM patients
GROUP BY city
ORDER BY patient_count DESC, city ASC;

-- 25. All people, labelled Patient or Doctor
SELECT first_name, last_name, 'Patient' AS role
FROM patients
UNION ALL
SELECT first_name, last_name, 'Doctor' AS role
FROM doctors;

-- 26. Allergies ordered by popularity
SELECT allergies, COUNT(*) AS total_patients
FROM patients
WHERE allergies IS NOT NULL
GROUP BY allergies
ORDER BY total_patients DESC;

-- 27. Patients born in the 1970s
SELECT first_name, last_name, birth_date
FROM patients
WHERE birth_date >= '1970-01-01'
  AND birth_date < '1980-01-01'
ORDER BY birth_date ASC;

-- 28. Formatted full name
SELECT CONCAT(UPPER(last_name), ', ', LOWER(first_name)) AS full_name
FROM patients
ORDER BY first_name DESC;

-- 29. Provinces whose total patient height is at least 7000
SELECT province_id, SUM(height) AS total_height
FROM patients
GROUP BY province_id
HAVING SUM(height) >= 7000;

-- 30. Difference between largest and smallest weight for Maroni
SELECT MAX(weight) - MIN(weight) AS weight_difference
FROM patients
WHERE last_name = 'Maroni';

-- 31. Days 1 to 31 with number of admissions
SELECT
  d.day_number,
  COUNT(a.admission_date) AS admission_count
FROM (
  SELECT ones.n + (tens.n * 10) + 1 AS day_number
  FROM (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9
  ) AS ones
  CROSS JOIN (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
  ) AS tens
  WHERE ones.n + (tens.n * 10) + 1 <= 31
) AS d
LEFT JOIN admissions AS a
  ON DAY(a.admission_date) = d.day_number
GROUP BY d.day_number
ORDER BY admission_count DESC, d.day_number ASC;

-- 32. Patients grouped by 10-kg weight ranges
SELECT
  CONCAT(
    FLOOR(weight / 10) * 10,
    '-',
    FLOOR(weight / 10) * 10 + 9
  ) AS weight_group,
  COUNT(*) AS patient_count
FROM patients
GROUP BY FLOOR(weight / 10) * 10
ORDER BY FLOOR(weight / 10) * 10 DESC;

-- 33. Patient BMI obesity flag: 1 = obese, 0 = not obese
SELECT
  patient_id,
  weight,
  height,
  CASE
    WHEN weight / POWER(height / 100.0, 2) >= 30 THEN 1
    ELSE 0
  END AS isObese
FROM patients;

-- 34. Epilepsy patients whose doctor is Lisa
SELECT
  p.patient_id,
  p.first_name,
  p.last_name,
  d.specialty
FROM patients AS p
JOIN admissions AS a
  ON p.patient_id = a.patient_id
JOIN doctors AS d
  ON a.attending_doctor_id = d.doctor_id
WHERE a.diagnosis = 'Epilepsy'
  AND d.first_name = 'Lisa';
