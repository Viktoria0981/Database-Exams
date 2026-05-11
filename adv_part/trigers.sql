CREATE OR REPLACE FUNCTION exam.set_exam_date()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    dates DATE;
    rooms TEXT;
    ex INTEGER;
BEGIN
    SELECT exam_date, room, exam_id INTO dates, rooms,ex
    FROM exam.exam
    WHERE exam_date = NEW.exam_date and room = NEW.room;
    IF dates IS NOT NULL  THEN
        RAISE EXCEPTION 'В аудитории % на дату % уже назначен экзамен (ID: %)', rooms, dates, ex;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER new_exam ON exam.exam;
CREATE TRIGGER new_exam
BEFORE UPDATE OR INSERT
ON exam.exam
FOR EACH ROW
EXECUTE FUNCTION exam.set_exam_date();

INSERT INTO exam.exam(exam_id, course_id, exam_date, room, duration_minutes, exam_format) VALUES
(1, 1, '2026-06-05', 'ГК 401', 180, 'written');
--запрещаем проводить в один день несколько экзаменов в одной аудитории



CREATE TABLE IF NOT EXISTS exam.result_archive (
    archive_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    exam_id INTEGER,
    old_mark INTEGER,
    changed_by TEXT,
    changed_at TIMESTAMP,
    operation_type TEXT
);

CREATE OR REPLACE FUNCTION exam.archive()
RETURNS trigger 
LANGUAGE plpgsql
AS $$
DECLARE 
    ex INTEGER;
BEGIN

    SELECT m.exam_id INTO ex
    FROM exam.materials_for_exam m
    WHERE m.material_id = OLD.material_id;

    INSERT INTO exam.result_archive(student_id, exam_id, old_mark, changed_by, changed_at, operation_type) VALUES (
        OLD.student_id, 
        ex, 
        OLD.mark, 
        CURRENT_USER,
        NOW(),
        TG_OP
    );
    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

DROP TRIGGER backup_results ON exam.result;
CREATE TRIGGER backup_results
AFTER UPDATE OR DELETE ON exam.result
FOR EACH ROW
EXECUTE FUNCTION exam.archive();

DELETE FROM exam.result WHERE result_id = 1;
SELECT * FROM exam.result_archive;
--при изменении существующих строк записываем историю в таблицу