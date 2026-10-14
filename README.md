# Student Grading System

A MySQL-based database project for managing students, academic terms, subjects, marks, grades, and examination results.

## Project Overview

The Student Grading System stores student details, manages subjects and academic terms, records examination marks, calculates grades, and generates student performance reports.

## Features

- Manage student details and roll numbers
- Manage academic terms and semesters
- Store subject details, credits, maximum marks, and passing marks
- Record examination marks
- Calculate percentages, grades, and pass/fail results
- Generate student result summaries
- Analyze subject-wise performance
- Identify students who have failed in one or more subjects
- Search students by name or roll number
- Add or update marks using stored procedures
- Calculate overall student results
- Use database views, indexes, and constraints

## Technologies Used

- **Database:** MySQL 8.0+
- **Language:** SQL
- **Tools:** MySQL Workbench

## Database Tables

| Table Name | Description |
|---|---|
| `academic_terms` | Stores academic years and semester details |
| `students` | Stores student information |
| `subjects` | Stores subject details and grading rules |
| `marks` | Stores examination marks for students |

## Database Views

- `student_result_summary` — Displays marks, percentage, grade, and result status.
- `subject_performance` — Shows average, highest, and lowest marks, along with pass/fail counts.
- `students_at_risk` — Identifies students with at least one failing subject result.

## Stored Procedures

- `search_students` — Searches students by name or roll number.
- `record_marks` — Validates and records or updates examination marks.
- `calculate_student_result` — Calculates total marks, overall percentage, and result status.

## How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Open MySQL Workbench and connect to your MySQL server.
3. Select **File → Open SQL Script**.
4. Open `student_grading_system.sql`.
5. Execute the SQL script.
6. Refresh the **Schemas** panel.
7. Open the `student_grading_system` database to view the tables, views, and stored procedures.

## Sample Queries

View all students:

```sql
SELECT * FROM students;
```

View student grades and results:

```sql
SELECT * FROM student_result_summary;
```

View subject performance:

```sql
SELECT * FROM subject_performance;
```

View students at risk:

```sql
SELECT * FROM students_at_risk;
```

Calculate a student's overall result:

```sql
CALL calculate_student_result(1);
```

Search for a student:

```sql
CALL search_students('CSE2025001');
```

## Sample Data

The project includes sample academic terms, fictional student records, subjects, and examination marks for testing the database.

## Important Note

The SQL script drops and recreates the project's tables, views, and stored procedures during setup. Back up existing project data before running the script again.

## Repository Structure

```text
Student-Grading-System/
├── student_grading_system.sql
└── README.md
```

## Author

- **Name:** 
- **Domain:** 
- **Internship ID:** 
