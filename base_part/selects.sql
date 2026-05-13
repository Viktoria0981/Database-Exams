SELECT t.full_name, t.department
FROM exam.teacher t
LEFT JOIN exam.exam_member m ON t.teacher_id = m.teacher_id
WHERE m.teacher_id IS NULL;
--учителя которые не принимают экзамен

SELECT s.group_id, AVG(r.mark) as avg
FROM exam.student s
JOIN exam.result r on r.student_id = s.student_id
GROUP BY group_id
HAVING AVG(r.mark) >= 8
ORDER BY avg DESC;
--группы с отличным средним баллом

SELECT c.title, AVG(r.mark) as avg
FROM exam.result r
JOIN exam.materials_for_exam m ON r.material_id = m.material_id
JOIN exam.exam e ON m.exam_id = e.exam_id
JOIN exam.course c ON c.course_id = e.course_id
GROUP BY title
ORDER BY AVG(r.mark)
LIMIT 3
--курсы с самым низким средним баллом

SELECT s.full_name
FROM exam.student s
JOIN exam.result r ON r.student_id = s.student_id
WHERE r.mark < 3
GROUP BY s.full_name;
--студенты хотя бы с одной пересдачей


SELECT e.room, COUNT(*) as cnt
FROM exam.exam e
GROUP BY e.room
ORDER BY cnt DESC
--популярные аудитории

SELECT c.department, COUNT(DISTINCT cur.group_id) as num_groups, SUM(cur.hour) as total_hours
FROM exam.curriculum cur
JOIN exam.course c ON cur.course_id = c.course_id
GROUP BY c.department
--нагрузка кафедр


SELECT t.full_name AS teacher_name, c.title AS exam_title, AVG(r.mark) AS teacher_avg
FROM exam.teacher t
JOIN exam.result r ON t.teacher_id = r.teacher_id
JOIN exam.materials_for_exam m ON r.material_id = m.material_id
JOIN exam.exam e ON m.exam_id = e.exam_id
JOIN exam.course c ON e.course_id = c.course_id
GROUP BY t.full_name, c.title, m.exam_id
HAVING AVG(r.mark) <= (
    SELECT AVG(r2.mark)
    FROM exam.result r2
    JOIN exam.materials_for_exam m2 ON r2.material_id = m2.material_id
    WHERE m2.exam_id = m.exam_id
) - 1;
--преподаватели, чей средний
--выставленный балл хотя бы на 1 балл ниже
--чем средний балл по этому же экзамену

SELECT s.full_name, c.title, r.mark, ROUND(EXTRACT(EPOCH FROM (r.time_end - r.time_start))/ 60)  AS duration_spent, e.duration_minutes
FROM exam.result r
JOIN exam.student s ON r.student_id = s.student_id
JOIN exam.materials_for_exam m ON r.material_id = m.material_id
JOIN exam.exam e ON m.exam_id = e.exam_id
JOIN exam.course c ON e.course_id = c.course_id
WHERE (r.time_end - r.time_start) <= (e.duration_minutes * INTERVAL '0.5 minute');
--кто быстро закончил экзамен

SELECT t.ticket_id, t.difficulty, t.num_questions
FROM exam.ticket t
WHERE t.ticket_id NOT IN (
    SELECT m2.ticket_id
    FROM exam.materials_for_exam m2)
--билеты, которые не выдались

SELECT t.full_name AS teacher_name, t.department AS teacher_dept, c.title AS course_title, c.department AS course_dept
FROM exam.exam_member em
JOIN exam.teacher t ON em.teacher_id = t.teacher_id
JOIN exam.exam e ON em.exam_id = e.exam_id
JOIN exam.course c ON e.course_id = c.course_id
WHERE t.department != c.department;
--принимающие с чужой кафедры