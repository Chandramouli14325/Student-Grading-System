-- ============================================================
-- Project: Student Grading System
-- Database: MySQL 8.0+
-- Purpose: Manage students, subjects, marks, grades, and results.
-- ============================================================

CREATE DATABASE IF NOT EXISTS student_grading_system;
USE student_grading_system;

-- WARNING: This setup section drops and recreates project tables.
-- Back up existing data before rerunning this script.
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS student_result_summary;
DROP VIEW IF EXISTS subject_performance;
DROP VIEW IF EXISTS students_at_risk;

DROP PROCEDURE IF EXISTS calculate_student_result;
DROP PROCEDURE IF EXISTS search_students;
DROP PROCEDURE IF EXISTS record_marks;

DROP TABLE IF EXISTS marks;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS academic_terms;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- 1. Academic terms / semesters
-- ------------------------------------------------------------
CREATE TABLE academic_terms (
    term_id INT AUTO_INCREMENT PRIMARY KEY,
    term_name VARCHAR(50) NOT NULL UNIQUE,
    academic_year VARCHAR(9) NOT NULL,
    start_date DATE,
    end_date DATE,
    CONSTRAINT chk_term_dates CHECK (
        start_date IS NULL OR end_date IS NULL OR end_date >= start_date
    )
);

-- ------------------------------------------------------------
-- 2. Students
-- ------------------------------------------------------------
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    roll_number VARCHAR(30) NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    course VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    admission_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 3. Subjects
-- max_marks and pass_marks define each subject's grading rules.
-- ------------------------------------------------------------
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) NOT NULL UNIQUE,
    subject_name VARCHAR(150) NOT NULL,
    term_id INT NOT NULL,
    credits DECIMAL(3,1) NOT NULL DEFAULT 3.0,
    max_marks DECIMAL(6,2) NOT NULL DEFAULT 100.00,
    pass_marks DECIMAL(6,2) NOT NULL DEFAULT 40.00,
    CONSTRAINT chk_subject_credits CHECK (credits > 0),
    CONSTRAINT chk_subject_max_marks CHECK (max_marks > 0),
    CONSTRAINT chk_subject_pass_marks CHECK (
        pass_marks >= 0 AND pass_marks <= max_marks
    ),
    CONSTRAINT fk_subjects_term
        FOREIGN KEY (term_id) REFERENCES academic_terms(term_id)
);

-- ------------------------------------------------------------
-- 4. Marks
-- One marks record per student per subject.
-- ------------------------------------------------------------
CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    marks_obtained DECIMAL(6,2) NOT NULL,
    exam_type ENUM('Internal', 'Midterm', 'Final', 'Practical')
        NOT NULL DEFAULT 'Final',
    exam_date DATE,
    remarks VARCHAR(255),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_marks_nonnegative CHECK (marks_obtained >= 0),
    CONSTRAINT fk_marks_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_marks_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    UNIQUE KEY uq_student_subject_exam (student_id, subject_id, exam_type),
    INDEX idx_marks_subject (subject_id),
    INDEX idx_marks_student (student_id)
);

-- ------------------------------------------------------------
-- 5. Sample academic terms
-- ------------------------------------------------------------
INSERT INTO academic_terms
(term_name, academic_year, start_date, end_date) VALUES
('Semester 1', '2025-2026', '2025-07-01', '2025-12-15'),
('Semester 2', '2025-2026', '2026-01-05', '2026-05-30');

-- ------------------------------------------------------------
-- 6. Sample students (fictional demonstration data)
-- ------------------------------------------------------------
INSERT INTO students
(roll_number, first_name, last_name, date_of_birth, email, phone,
 course, department, admission_year) VALUES
('CSE2025001', 'Aarav', 'Sharma', '2006-02-12',
 'aarav.sharma@example.com', '9000001001',
 'B.Tech', 'Computer Science', 2025),
('CSE2025002', 'Diya', 'Reddy', '2005-11-20',
 'diya.reddy@example.com', '9000001002',
 'B.Tech', 'Computer Science', 2025),
('CSE2025003', 'Rahul', 'Patel', '2006-05-08',
 'rahul.patel@example.com', '9000001003',
 'B.Tech', 'Computer Science', 2025),
('CSE2025004', 'Meera', 'Das', '2005-09-17',
 'meera.das@example.com', '9000001004',
 'B.Tech', 'Computer Science', 2025),
('CSE2025005', 'Kabir', 'Kumar', '2006-01-25',
 'kabir.kumar@example.com', '9000001005',
 'B.Tech', 'Computer Science', 2025);

-- ------------------------------------------------------------
-- 7. Sample subjects
-- ------------------------------------------------------------
INSERT INTO subjects
(subject_code, subject_name, term_id, credits, max_marks, pass_marks) VALUES
('CS101', 'Programming Fundamentals', 1, 4.0, 100.00, 40.00),
('CS102', 'Database Management Systems', 1, 4.0, 100.00, 40.00),
('CS103', 'Computer Organization', 1, 3.0, 100.00, 40.00),
('CS104', 'Mathematics', 1, 4.0, 100.00, 40.00),
('CS201', 'Data Structures', 2, 4.0, 100.00, 40.00),
('CS202', 'Java Programming', 2, 4.0, 100.00, 40.00);

-- ------------------------------------------------------------
-- 8. Sample marks
-- exam_type is Final for these example records.
-- ------------------------------------------------------------
INSERT INTO marks
(student_id, subject_id, marks_obtained, exam_type, exam_date, remarks) VALUES
(1, 1, 85, 'Final', '2025-12-01', 'Good performance'),
(1, 2, 78, 'Final', '2025-12-03', 'Good performance'),
(1, 3, 69, 'Final', '2025-12-05', NULL),
(1, 4, 88, 'Final', '2025-12-08', 'Very good'),
(2, 1, 92, 'Final', '2025-12-01', 'Excellent'),
(2, 2, 89, 'Final', '2025-12-03', 'Excellent'),
(2, 3, 95, 'Final', '2025-12-05', 'Excellent'),
(2, 4, 91, 'Final', '2025-12-08', 'Excellent'),
(3, 1, 55, 'Final', '2025-12-01', NULL),
(3, 2, 38, 'Final', '2025-12-03', 'Below passing marks'),
(3, 3, 61, 'Final', '2025-12-05', NULL),
(3, 4, 47, 'Final', '2025-12-08', NULL),
(4, 1, 72, 'Final', '2025-12-01', NULL),
(4, 2, 66, 'Final', '2025-12-03', NULL),
(4, 3, 74, 'Final', '2025-12-05', NULL),
(4, 4, 70, 'Final', '2025-12-08', NULL),
(5, 1, 35, 'Final', '2025-12-01', 'Below passing marks'),
(5, 2, 42, 'Final', '2025-12-03', NULL),
(5, 3, 39, 'Final', '2025-12-05', 'Below passing marks'),
(5, 4, 51, 'Final', '2025-12-08', NULL),
(1, 5, 82, 'Final', '2026-05-01', NULL),
(1, 6, 90, 'Final', '2026-05-03', NULL),
(2, 5, 94, 'Final', '2026-05-01', 'Excellent'),
(2, 6, 96, 'Final', '2026-05-03', 'Excellent'),
(3, 5, 58, 'Final', '2026-05-01', NULL),
(3, 6, 64, 'Final', '2026-05-03', NULL),
(4, 5, 77, 'Final', '2026-05-01', NULL),
(4, 6, 80, 'Final', '2026-05-03', NULL),
(5, 5, 49, 'Final', '2026-05-01', NULL),
(5, 6, 55, 'Final', '2026-05-03', NULL);

-- ------------------------------------------------------------
-- 9. Views
-- ------------------------------------------------------------

-- One row per student and subject, including grade and pass/fail.
CREATE VIEW student_result_summary AS
SELECT
    s.student_id,
    s.roll_number,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    sub.subject_id,
    sub.subject_code,
    sub.subject_name,
    t.term_name,
    t.academic_year,
    m.exam_type,
    m.marks_obtained,
    sub.max_marks,
    ROUND((m.marks_obtained / sub.max_marks) * 100, 2) AS percentage,
    CASE
        WHEN m.marks_obtained < sub.pass_marks THEN 'F'
        WHEN (m.marks_obtained / sub.max_marks) * 100 >= 90 THEN 'A+'
        WHEN (m.marks_obtained / sub.max_marks) * 100 >= 80 THEN 'A'
        WHEN (m.marks_obtained / sub.max_marks) * 100 >= 70 THEN 'B'
        WHEN (m.marks_obtained / sub.max_marks) * 100 >= 60 THEN 'C'
        WHEN (m.marks_obtained / sub.max_marks) * 100 >= 50 THEN 'D'
        ELSE 'E'
    END AS grade,
    CASE
        WHEN m.marks_obtained >= sub.pass_marks THEN 'Pass'
        ELSE 'Fail'
    END AS result_status
FROM marks m
JOIN students s ON m.student_id = s.student_id
JOIN subjects sub ON m.subject_id = sub.subject_id
JOIN academic_terms t ON sub.term_id = t.term_id;

-- Average score and pass/fail counts for each subject.
CREATE VIEW subject_performance AS
SELECT
    sub.subject_id,
    sub.subject_code,
    sub.subject_name,
    t.term_name,
    COUNT(m.mark_id) AS students_assessed,
    ROUND(AVG(m.marks_obtained), 2) AS average_marks,
    MAX(m.marks_obtained) AS highest_marks,
    MIN(m.marks_obtained) AS lowest_marks,
    SUM(CASE WHEN m.marks_obtained >= sub.pass_marks THEN 1 ELSE 0 END)
        AS passed_count,
    SUM(CASE WHEN m.marks_obtained < sub.pass_marks THEN 1 ELSE 0 END)
        AS failed_count
FROM subjects sub
JOIN academic_terms t ON sub.term_id = t.term_id
LEFT JOIN marks m ON sub.subject_id = m.subject_id
GROUP BY sub.subject_id, sub.subject_code, sub.subject_name, t.term_name;

-- Students with at least one recorded failing subject result.
CREATE VIEW students_at_risk AS
SELECT
    s.student_id,
    s.roll_number,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(*) AS failed_subject_count
FROM students s
JOIN marks m ON s.student_id = m.student_id
JOIN subjects sub ON m.subject_id = sub.subject_id
WHERE m.marks_obtained < sub.pass_marks
GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name;

-- ------------------------------------------------------------
-- 10. Stored procedures
-- ------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE search_students(IN p_keyword VARCHAR(100))
BEGIN
    SELECT student_id, roll_number, first_name, last_name,
           course, department, email
    FROM students
    WHERE roll_number LIKE CONCAT('%', p_keyword, '%')
       OR first_name LIKE CONCAT('%', p_keyword, '%')
       OR last_name LIKE CONCAT('%', p_keyword, '%')
    ORDER BY roll_number;
END$$

CREATE PROCEDURE record_marks(
    IN p_student_id INT,
    IN p_subject_id INT,
    IN p_marks DECIMAL(6,2),
    IN p_exam_type VARCHAR(20),
    IN p_exam_date DATE
)
BEGIN
    DECLARE v_max_marks DECIMAL(6,2);

    IF NOT EXISTS (
        SELECT 1 FROM students WHERE student_id = p_student_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    SELECT max_marks INTO v_max_marks
    FROM subjects
    WHERE subject_id = p_subject_id;

    IF v_max_marks IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Subject does not exist';
    ELSEIF p_marks < 0 OR p_marks > v_max_marks THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Marks must be between zero and maximum marks';
    ELSE
        INSERT INTO marks
            (student_id, subject_id, marks_obtained, exam_type, exam_date)
        VALUES
            (p_student_id, p_subject_id, p_marks, p_exam_type, p_exam_date)
        ON DUPLICATE KEY UPDATE
            marks_obtained = VALUES(marks_obtained),
            exam_date = VALUES(exam_date);
    END IF;
END$$

CREATE PROCEDURE calculate_student_result(IN p_student_id INT)
BEGIN
    SELECT
        s.student_id,
        s.roll_number,
        CONCAT(s.first_name, ' ', s.last_name) AS student_name,
        COUNT(m.mark_id) AS subjects_recorded,
        ROUND(SUM(m.marks_obtained), 2) AS total_marks,
        ROUND(SUM(sub.max_marks), 2) AS maximum_possible_marks,
        ROUND(100 * SUM(m.marks_obtained) / NULLIF(SUM(sub.max_marks), 0), 2)
            AS overall_percentage,
        CASE
            WHEN SUM(CASE
                WHEN m.marks_obtained < sub.pass_marks THEN 1 ELSE 0
            END) > 0 THEN 'Fail'
            WHEN COUNT(m.mark_id) = 0 THEN 'No Results'
            ELSE 'Pass'
        END AS overall_result
    FROM students s
    LEFT JOIN marks m ON s.student_id = m.student_id
    LEFT JOIN subjects sub ON m.subject_id = sub.subject_id
    WHERE s.student_id = p_student_id
    GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name;
END$$

DELIMITER ;

-- ============================================================
-- 11. Example queries
-- Run these statements individually after running the script.
-- ============================================================

-- View all students:
-- SELECT * FROM students ORDER BY roll_number;

-- View all subjects:
-- SELECT sub.*, t.term_name, t.academic_year
-- FROM subjects sub
-- JOIN academic_terms t ON sub.term_id = t.term_id;

-- View each student's marks, grade, and result:
-- SELECT * FROM student_result_summary
-- ORDER BY roll_number, subject_code;

-- Calculate one student's overall result:
-- CALL calculate_student_result(1);

-- Search students by name or roll number:
-- CALL search_students('CSE2025001');

-- Add or update marks for a student and subject:
-- CALL record_marks(1, 1, 87, 'Final', '2025-12-01');

-- View subject-wise performance:
-- SELECT * FROM subject_performance ORDER BY subject_code;

-- Find students with failing marks:
-- SELECT * FROM students_at_risk ORDER BY failed_subject_count DESC;

-- Calculate average marks for each student (across recorded assessments):
-- SELECT s.roll_number, CONCAT(s.first_name, ' ', s.last_name) AS student_name,
--        ROUND(AVG(m.marks_obtained), 2) AS average_marks
-- FROM students s
-- JOIN marks m ON s.student_id = m.student_id
-- GROUP BY s.student_id, s.roll_number, s.first_name, s.last_name
-- ORDER BY average_marks DESC;

-- Count students in each department:
-- SELECT department, COUNT(*) AS student_count
-- FROM students
-- GROUP BY department
-- ORDER BY student_count DESC;

-- End of Student Grading System SQL script.
