/* 1. Selezionare tutti gli studenti nati nel 1990 (160) */
SELECT * -- seleziona colonne
FROM students  -- table
WHERE YEAR(students.date_of_birth) = 1990; -- WHERE filtra. YEAR restituisce solo l'anno (formato YYYY-MM-DD)

/*2. Selezionare tutti i corsi che valgono più di 10 crediti (479)*/
SELECT * 
FROM courses
WHERE courses.cfu > 10;

/*3. Selezionare tutti gli studenti che hanno più di 30 anni */
SELECT *
FROM students
WHERE YEAR(CURDATE()) - YEAR(students.date_of_birth) > 30; -- CURDATE restituisce data di oggi
-- anno di oggi - anno di nascita = età.  Seleziono solo chi ha compiuto 30 anni: Età > 30.

/*4. Selezionare tutti i corsi del primo semestre del primo anno di un qualsiasi corso di laurea (286)*/
SELECT * 
FROM db_university.courses
WHERE courses.period = 'I semestre' 
AND courses.year = 1;   --  AND concatena piu filtri tutti true ( && )  
                        --  OR invece basta che una condizione sia soddisfatta( || )

/*5. Selezionare tutti gli appelli d'esame che avvengono nel pomeriggio (dopo le 14) del
20/06/2020 (21) */
SELECT * 
FROM db_university.exams
WHERE date = '2020-06-20'
AND hour > '14:00:00';

/*6. Selezionare tutti i corsi di laurea magistrale (38) */
SELECT * 
FROM db_university.degrees
WHERE degrees.level = 'magistrale';

/*7. Da quanti dipartimenti è composta l'università? (12) */
SELECT COUNT(*) AS n_dipartimenti -- alias
FROM db_university.departments;

/*8. Quanti sono gli insegnanti che non hanno un numero di telefono? (50) */
SELECT COUNT(teachers.phone)  -- i null non vengono contati
FROM db_university.teachers;

/* GROUP BY */

/* 1. Contare quanti iscritti ci sono stati ogni anno */
SELECT YEAR(enrolment_date) AS Anno,
COUNT(*) AS Iscritti
FROM db_university.students
GROUP BY YEAR(enrolment_date) 
ORDER BY YEAR(enrolment_date) 

/* 2. Contare gli insegnanti che hanno l'ufficio nello stesso edificio */
SELECT office_address AS Indirizzo_edificio,
COUNT(*) AS Insegnanti
FROM db_university.teachers
GROUP BY office_address;

/* 3. Calcolare la media dei voti di ogni appello d'esame */
SELECT ES.exam_id AS Appello, 
ROUND(AVG(ES.vote),1) AS Media_voti -- AVG(average(MEDIA) = SUM(vote)/COUNT(vote)  -- ROUND(NUM,N_decimali) arrotonda il numero 
FROM exam_student ES
GROUP BY ES.exam_id;

/* 4. Contare quanti corsi di laurea ci sono per ogni dipartimento */
SELECT degrees.department_id, 
COUNT(*) AS  N_CORSI
FROM db_university.degrees
GROUP BY department_id; 

/* JOIN */

/* 1. Selezionare tutti gli studenti iscritti al Corso di Laurea in Economia */
SELECT D.name, S.*
FROM db_university.students AS S
JOIN degrees AS D
ON S.degree_id = D.id
WHERE D.name LIKE '%Economia%'

/* 2. Selezionare tutti i Corsi di Laurea Magistrale del Dipartimento di Neuroscienze */
SELECT * 
FROM db_university.degrees C
JOIN departments D
ON C.department_id = D.id
WHERE D.name LIKE '%Neuroscienze%'
AND C.level = 'departmentsmagistrale';

/* 3. Selezionare tutti i corsi in cui insegna Fulvio Amato (id=44) */
SELECT DISTINCT C.*    -- DISTINCT evita duplicati         
FROM db_university.courses C
JOIN course_teacher CT ON CT.course_id = C.id   -- tabella ponte
JOIN teachers T ON CT.teacher_id = T.id
WHERE T.name = 'Fulvio'
AND T.surname = 'Amato'
-- oppure WHERE T.id = 44 ;

/* 4. Selezionare tutti gli studenti con i dati relativi al corso di laurea a cui sono iscritti 
e il relativo dipartimento, in ordine alfabetico per cognome e nome */
SELECT 	S.surname Cognome, S.name Nome, S.date_of_birth Data_di_nascita, S.registration_number Matricola,
		C.name Corso_di_Laurea, C.level Livello, C.address indirizzo_corso, C.email email_corso, C.website website_corso,
        D.name Dipartimento, D.address indirizzo_dip, D.phone tel_dip, D.email email_dip, D.website website_dip, D.head_of_department Capodipartimento
FROM db_university.students AS S
JOIN degrees AS C ON S.degree_id = C.id
JOIN departments AS D ON C.department_id = D.id
ORDER BY S.surname, S.name;

/* 5. Selezionare tutti i corsi di laurea con i relativi corsi e insegnanti */
SELECT DISTINCT * 
FROM db_university.degrees D
JOIN courses C ON C.degree_id = D.id
JOIN course_teacher CT ON CT.course_id = C.id
JOIN teachers T ON CT.teacher_id = T.id;

/* 6. Selezionare tutti i docenti che insegnano nel Dipartimento di Matematica (54) */
SELECT DISTINCT T.*, DEP.name 
FROM db_university.degrees D
JOIN courses C ON C.degree_id = D.id
JOIN course_teacher CT ON CT.course_id = C.id
JOIN teachers T ON CT.teacher_id = T.id
JOIN departments DEP ON D.department_id = DEP.id
WHERE DEP.name LIKE '%Matematica%' ;

/* 7. BONUS: Selezionare per ogni studente il numero di tentativi sostenuti per ogni esame, 
stampando anche il voto massimo. Successivamente, filtrare i tentativi con voto minimo 18. */
SELECT S.name Nome, S.surname Cognome, C.name Corso, 
COUNT(*) AS Tentativi,
MAX(ES.vote) AS Voto_piu_alto,  -- MAX()
SUM(CASE WHEN ES.vote < 18 THEN 1 ELSE 0 END)AS Tentativi_falliti -- CASE WHEN codizione THEN (se true) valorizza 1 ELSE (se false) valorizza 0 END (chiude case). SUM sommo gli 1
FROM db_university.students S
JOIN exam_student ES ON ES.student_id = S.id
JOIN exams E ON ES.exam_id = E.id
JOIN courses C ON E.course_id = C.id
WHERE S.surname BETWEEN 'A' AND 'FZ'  -- BETWEEN '' AND '' seleziona un Range 
GROUP BY S.id, C.id		-- raggruppo per studente e per corso
HAVING MAX(ES.vote) >=18  -- HAVING filtro dopo il raggruppamento
ORDER BY S.id, C.id;