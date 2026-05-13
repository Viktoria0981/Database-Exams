DROP VIEW IF EXISTS exam.v_comming_exams;
CREATE VIEW exam.v_comming_exams AS
SELECT c.title, c.department, e.exam_date, e.room, e.exam_format
FROM exam.exam e
JOIN exam.course c ON c.course_id = e.course_id
WHERE e.exam_date >= CURRENT_DATE AND e.exam_date <= CURRENT_DATE + 7
ORDER BY exam_date;

SELECT * FROM exam.v_comming_exams;
--расписание экзаменов на ближайшую неделю


DROP VIEW IF EXISTS exam.v_teacher_availability;
CREATE MATERIALIZED VIEW exam.v_teacher_availability AS
SELECT t.full_name, t.department, COUNT(DISTINCT em.exam_id) as exams_count,
CASE 
    WHEN COUNT(DISTINCT em.exam_id) = 0 THEN 'Свободен'
    WHEN COUNT(DISTINCT em.exam_id) < 3 THEN 'Малая нагрузка'
    ELSE 'Занят'
END as availability_status
FROM exam.teacher t
LEFT JOIN exam.exam_member em ON t.teacher_id = em.teacher_id
LEFT JOIN exam.exam e ON em.exam_id = e.exam_id
LEFT JOIN exam.materials_for_exam mfe ON e.exam_id = mfe.exam_id
LEFT JOIN exam.result r ON mfe.material_id = r.material_id
GROUP BY t.teacher_id, t.full_name, t.department
ORDER BY exams_count ASC;

SELECT * FROM exam.v_teacher_availability;
--REFRESH MATERIALIZED VIEW exam.v_teacher_availability;
--узнаем кого из учителей можно задействовать в экзамен