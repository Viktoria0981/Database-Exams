DROP INDEX IF EXISTS exam.idx_result_student_mark;
SET enable_seqscan = on;
EXPLAIN ANALYZE 
SELECT avg(mark) FROM exam.result
WHERE student_id = 50;

CREATE INDEX idx_result_student_mark ON exam.result (student_id, mark);
SET enable_seqscan = off;
EXPLAIN ANALYZE 
SELECT avg(mark) FROM exam.result
WHERE student_id = 50;
-индекс для ускорения функции подсчета стипендии + информация об оценках 


DROP INDEX IF EXISTS exam.idx_materials_exam_id;
SET enable_seqscan = on;
EXPLAIN ANALYZE 
SELECT * FROM exam.materials_for_exam 
WHERE exam_id = 15;

CREATE INDEX idx_materials_exam_id ON exam.materials_for_exam (exam_id);
SET enable_seqscan = off;
EXPLAIN ANALYZE
SELECT * FROM exam.materials_for_exam 
WHERE exam_id = 15;
--часто из резульата важно достать не materials, a exam


DROP INDEX IF EXISTS exam.idx_exam_date_room;
SET enable_seqscan = on;
EXPLAIN ANALYZE
SELECT * FROM exam.exam 
WHERE exam_date = '2026-05-20' AND room = 'ГК 402';

CREATE INDEX idx_exam_date_room ON exam.exam (exam_date, room);
SET enable_seqscan = off;
EXPLAIN ANALYZE
SELECT * FROM exam.exam 
WHERE exam_date = '2026-05-20' AND room = 'ГК 402';
--для тригера, узнаем какая дата и аудитория у эказмена
