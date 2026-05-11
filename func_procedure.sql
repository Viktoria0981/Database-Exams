CREATE OR REPLACE FUNCTION exam.scholarship(
    st_id INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT
AS $$
DECLARE
    avg_mark NUMERIC;
BEGIN
    SELECT avg(mark) INTO avg_mark
    FROM exam.result r
    WHERE r.student_id = st_id;
    IF avg_mark IS NULL THEN
        RAISE EXCEPTION 'У студента с ID % нет оценок в базе', st_id;
    END IF;
    CASE
        WHEN avg_mark >= 8 THEN
            RETURN 7000;
        WHEN avg_mark >= 6.5 THEN
            RETURN 5000;
        WHEN avg_mark >= 5 THEN
            RETURN 3000;
        WHEN avg_mark < 5 THEN
            RETURN 0;
    END CASE;
END;
$$;
SELECT exam.scholarship(3);
--узнаем размер стипендии по результатам экзамена


CREATE OR REPLACE PROCEDURE exam.analize_appeal(
    ap_id INTEGER,
    final_mark NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    res INTEGER;
BEGIN
    SELECT result_id INTO res
    FROM exam.appeal
    WHERE appeal_id = ap_id;

    IF res IS NULL THEN
        RAISE EXCEPTION 'Аппеляции с id % не существует', ap_id;
    END IF;

    UPDATE exam.result
    SET mark = final_mark
    WHERE result_id = res;

    EXECUTE 'ALTER TABLE exam.appeal ADD COLUMN IF NOT EXISTS status_appeal TEXT DEFAULT ''Вопрос открыт''';

    UPDATE exam.appeal
    SET status_appeal = 'Вопрос закрыт'
    WHERE appeal_id = ap_id;
END;
$$;
CALL exam.analize_appeal(1, 5.0);
--обрабатываем апелляции(обновляем статус апелляции и меняем оценку в результатах)


CREATE OR REPLACE FUNCTION exam.statistic(
    sub_id INTEGER
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    ex INTEGER;
    material INTEGER;
    res INTEGER;
    num_participants INTEGER;
    num_bad_students INTEGER;
BEGIN
    SELECT count(*) INTO num_participants
    FROM exam.exam e
    JOIN exam.materials_for_exam m on e.exam_id = m.exam_id
    JOIN exam.result r on m.material_id = r.material_id
    WHERE e.course_id = sub_id;

    SELECT count(*) INTO num_bad_students
    FROM exam.exam e
    JOIN exam.materials_for_exam m on e.exam_id = m.exam_id
    JOIN exam.result r on m.material_id = r.material_id
    WHERE e.course_id = sub_id and r.mark < 3;

    IF num_participants = 0 THEN
        RETURN 'По данному предмету еще нет результатов экзаменов.';
    END IF;

    RETURN format('Всего сдавало %s человек, не сдали %s.', num_participants, num_bad_students);
END;
$$
SELECT exam.statistic(6)
--вывод статистики по одному экзамену


CREATE OR REPLACE FUNCTION exam.full_statistic_table()
RETURNS TABLE(
    course_name TEXT,
    lines TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    i RECORD;
BEGIN
    FOR i IN SELECT course_id, title FROM exam.course LOOP
        course_name := i.title; 
        lines := exam.statistic(i.course_id);
        RETURN NEXT; 
    END LOOP;
END;
$$;
SELECT * FROM exam.full_statistic_table();
--вывод статистики по всем экзаменам



