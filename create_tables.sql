DROP SCHEMA IF EXISTS exam CASCADE;
CREATE SCHEMA exam;
CREATE TABLE exam.groups (
    group_id VARCHAR(50) PRIMARY KEY,
    students_num INTEGER NOT NULL CHECK (students_num > 0),
    faculty VARCHAR(100) NOT NULL,
    academic_leave INTEGER DEFAULT 0 CHECK (academic_leave >= 0)
);
CREATE TABLE exam.student (
    student_id INTEGER PRIMARY KEY,
    group_id VARCHAR(50) REFERENCES exam.groups(group_id) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    birth_date DATE NOT NULL,
    enrollment_date DATE NOT NULL CHECK (enrollment_date > birth_date)
);
CREATE TABLE exam.teacher (
    teacher_id INTEGER PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL
);
CREATE TABLE exam.course (
    course_id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL
);
CREATE TABLE exam.curriculum (
    group_id VARCHAR(50) REFERENCES exam.groups(group_id),
    course_id INTEGER REFERENCES exam.course(course_id),
    semester INT NOT NULL CHECK(semester BETWEEN 1 AND 12),
    hour INT NOT NULL CHECK(hour > 0),
    PRIMARY KEY (group_id, course_id)
);
CREATE TABLE exam.exam (
    exam_id INTEGER PRIMARY KEY,
    course_id INTEGER REFERENCES exam.course(course_id) NOT NULL,
    exam_date DATE NOT NULL,
    room VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL,
    exam_format VARCHAR(10) NOT NULL CHECK(exam_format in('spoken', 'written', 'dif_test'))
);
CREATE TABLE exam.ticket (
    ticket_id INTEGER PRIMARY KEY,
    difficulty VARCHAR(10) NOT NULL CHECK(difficulty IN ('high', 'medium', 'low')),
    num_questions INTEGER NOT NULL CHECK(num_questions > 0)
);
CREATE TABLE exam.materials_for_exam (
    material_id INTEGER PRIMARY KEY,
    exam_id INTEGER REFERENCES exam.exam(exam_id) NOT NULL,
    ticket_id INTEGER REFERENCES exam.ticket(ticket_id)
);
CREATE TABLE exam.exam_member (
    teacher_id INTEGER REFERENCES exam.teacher(teacher_id) NOT NULL,
    exam_id INTEGER REFERENCES exam.exam(exam_id) NOT NULL,
    exam_role VARCHAR(100) NOT NULL,
    PRIMARY KEY (teacher_id, exam_id)
);
CREATE TABLE exam.result (
    result_id INTEGER PRIMARY KEY,
    teacher_id INTEGER REFERENCES exam.teacher(teacher_id) NOT NULL,
    student_id INTEGER REFERENCES exam.student(student_id) NOT NULL,
    material_id INTEGER REFERENCES exam.materials_for_exam(material_id) NOT NULL,
    mark NUMERIC(3, 1) NOT NULL CHECK (
        mark >= 0
        AND mark <= 10
    ),
    time_start TIMESTAMP NOT NULL,
    time_end TIMESTAMP NOT NULL CHECK (time_end > time_start)
);
CREATE TABLE exam.appeal (
    appeal_id INTEGER PRIMARY KEY,
    result_id INTEGER REFERENCES exam.result(result_id) NOT NULL,
    longing_mark NUMERIC(3, 1) NOT NULL CHECK (longing_mark >= 0),
    complaint TEXT NOT NULL
);
CREATE TABLE exam.course_assignment (
    teacher_id INTEGER REFERENCES exam.teacher(teacher_id) NOT NULL,
    course_id INTEGER REFERENCES exam.course(course_id) NOT NULL,
    type_teacher VARCHAR(50) NOT NULL,
    PRIMARY KEY (teacher_id, course_id)
);