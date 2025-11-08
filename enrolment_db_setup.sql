-- ================================================================
-- PROJECT: Online Course Enrolment and Progress Tracking System
-- ================================================================

-- STEP 1: Create database
CREATE DATABASE OnlineLearningDB;
USE OnlineLearningDB;

-- ================================================================
-- STEP 2: Create Tables
-- ================================================================

CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL COMMENT 'Student, Instructor, Admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES Users(id) ON DELETE SET NULL
);

CREATE TABLE Enrolments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    date_enrolled DATE NOT NULL,
    completion_status VARCHAR(20) DEFAULT 'Enrolled' COMMENT 'Enrolled, In Progress, Completed',
    UNIQUE KEY unique_enrolment (user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(id) ON DELETE CASCADE
);

CREATE TABLE Progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrolment_id INT NOT NULL,
    module_name VARCHAR(100) NOT NULL,
    score INT DEFAULT 0 CHECK (score BETWEEN 0 AND 100),
    status VARCHAR(20) DEFAULT 'Not Started' COMMENT 'Not Started, In Progress, Completed',
    last_updated DATE,
    UNIQUE KEY unique_module_progress (enrolment_id, module_name),
    FOREIGN KEY (enrolment_id) REFERENCES Enrolments(id) ON DELETE CASCADE
);

-- ================================================================
-- STEP 3: Insert Data
-- ================================================================
INSERT INTO Users (name, email, role) VALUES
('System Admin', 'admin@lms.com', 'Admin'),
('Dr.P M Shaik', 'shaikpm2@gmail.com', 'Instructor'),
('Srinivas', 'srinivas.govulakonda@gmail.com', 'Instructor'),
('Akhila', 'akhilakoyada22@gmail.com', 'Student'),
('Aishwarya', 'aishwarya.godugu@gmail.com', 'Student'),
('Anusha', 'anushahanumandla07@gmail.com', 'Student'),
('Soumya', 'soumya.bairi@gmail.com', 'Student'),
('Nithin', 'nithin.kumar@gmail.com', 'Student'),
('Kalyan Ram', 'kalyanram.adepu@gmail.com', 'Student'),
('Akshaya', 'akshaya.gurrala@gmail.com', 'Student'),
('Anveshitha', 'anvinamindla24@gmail.com', 'Student'),
('Harshitha', 'harshitha.marka@gmail.com', 'Student'),
('Shravaneshwari', 'shravaneshwaridevunuri97@gmail.com', 'Student'),
('Balu', 'balu@gmail.com', 'Student'),
('Sumanth', 'sumanth.koyada@gmail.com', 'Student'),
('Sai', 'sai.abhi@gmail.com', 'Student'),
('Rugved', 'rugvedanad245@gmail.com', 'Student'),
('Sakshith', 'sakshith.padala@gmail.com', 'Student');

INSERT INTO Courses (course_name, description, instructor_id) VALUES
('Database Systems', 'Relational DBMS and SQL principles', 2),
('Web Development', 'MERN Stack full course', 3),
('Machine Learning', 'Introduction to ML', 2),
('Public Speaking', 'Key skills for speech delivery', 3);

INSERT INTO Enrolments (user_id, course_id, date_enrolled, completion_status) VALUES
(4, 1, '2025-10-15', 'Completed'),
(5, 2, '2025-10-16', 'In Progress'),
(6, 1, '2025-10-16', 'In Progress'),
(7, 3, '2025-10-17', 'Completed'),
(8, 2, '2025-10-17', 'In Progress'),
(9, 4, '2025-10-18', 'In Progress');

INSERT INTO Progress (enrolment_id, module_name, score, status, last_updated) VALUES
(1, 'SQL Basics', 95, 'Completed', '2025-10-20'),
(1, 'Normalization', 88, 'Completed', '2025-10-25'),

(2, 'React Basics', 90, 'Completed', '2025-10-22'),
(2, 'Express API', 75, 'In Progress', '2025-10-29'),

(3, 'SQL Basics', 78, 'In Progress', '2025-10-28'),

(4, 'ML Beginner', 88, 'Completed', '2025-10-30'),
(4, 'Model Training', 85, 'Completed', '2025-10-31'),

(5, 'HTML & CSS', 82, 'Completed', '2025-10-25'),
(5, 'Node Basics', 65, 'In Progress', '2025-10-28'),

(6, 'Public Speaking Intro', 80, 'In Progress', '2025-10-31'),
(6, 'Presentation Skills', 70, 'In Progress', '2025-11-01');

-- ================================================================
-- STEP 4: Stored Procedures
-- ================================================================

DELIMITER $$

CREATE PROCEDURE EnrolStudent (
    IN p_user_id INT,
    IN p_course_id INT
)
BEGIN
    INSERT INTO Enrolments (user_id, course_id, date_enrolled, completion_status)
    VALUES (p_user_id, p_course_id, CURDATE(), 'Enrolled');

    SELECT 'Enrolment successful.' AS Message, LAST_INSERT_ID() AS Enrolment_ID;
END$$

CREATE PROCEDURE UpdateProgress (
    IN p_enrolment_id INT,
    IN p_module_name VARCHAR(100),
    IN p_score INT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Progress
    SET score = p_score,
        status = p_status,
        last_updated = CURDATE()
    WHERE enrolment_id = p_enrolment_id
    AND module_name = p_module_name;

    SELECT CONCAT('Progress updated for Enrolment ID: ', p_enrolment_id, ' and Module: ', p_module_name) AS Message;

    IF p_status = 'Completed' THEN
        SELECT COUNT(*) INTO @total_modules
        FROM Progress WHERE enrolment_id = p_enrolment_id;

        SELECT COUNT(*) INTO @completed_modules
        FROM Progress WHERE enrolment_id = p_enrolment_id AND status = 'Completed';

        IF @total_modules = @completed_modules AND @total_modules > 0 THEN
            UPDATE Enrolments
            SET completion_status = 'Completed'
            WHERE id = p_enrolment_id;
        END IF;
    END IF;
END$$
DELIMITER ;

-- ================================================================
-- STEP 5: Create Views (Reports)
-- ================================================================

-- 🔹 View 1: Student Average Score
CREATE VIEW StudentAverageScore AS
SELECT
    U.name AS student_name,
    AVG(P.score) AS average_score
FROM Users U
JOIN Enrolments E ON U.id = E.user_id
JOIN Progress P ON E.id = P.enrolment_id
GROUP BY U.name
ORDER BY average_score DESC;

-- 🔹 View 2: Course Completion Rates
CREATE VIEW CourseCompletionRates AS
SELECT
    C.course_name,
    COUNT(E.id) AS total_enrolments,
    SUM(CASE WHEN E.completion_status = 'Completed' THEN 1 ELSE 0 END) AS completed_count,
    ROUND((SUM(CASE WHEN E.completion_status = 'Completed' THEN 1 ELSE 0 END) * 100.0) / COUNT(E.id), 2) AS completion_rate_percentage
FROM Courses C
JOIN Enrolments E ON C.id = E.course_id
GROUP BY C.course_name
ORDER BY completion_rate_percentage DESC;

-- 🔹 View 3: Top Performers Per Course
CREATE VIEW TopPerformersPerCourse AS
WITH CourseAvgScores AS (
    SELECT
        C.course_name,
        U.name AS student_name,
        AVG(P.score) AS avg_module_score,
        RANK() OVER (PARTITION BY C.course_name ORDER BY AVG(P.score) DESC) AS rank_within_course
    FROM Users U
    JOIN Enrolments E ON U.id = E.user_id
    JOIN Courses C ON E.course_id = C.id
    JOIN Progress P ON E.id = P.enrolment_id
    GROUP BY C.course_name, U.name
)
SELECT course_name, student_name, avg_module_score
FROM CourseAvgScores
WHERE rank_within_course = 1;

-- ================================================================
-- STEP 6: TEST CASE EXECUTION
-- ================================================================

# TC01 – Verify Course Enrolment
CALL EnrolStudent(15, 2);
SELECT * FROM Enrolments WHERE user_id = 15 AND course_id = 2;

# TC02 – Verify Progress Update
SELECT score, status FROM Progress WHERE enrolment_id = 3 AND module_name = 'SQL Basics';
CALL UpdateProgress(3, 'SQL Basics', 90, 'Completed');
SELECT score, status FROM Progress WHERE enrolment_id = 3 AND module_name = 'SQL Basics';

#TCO3-verify that the view Exists
SHOW CREATE VIEW StudentAverageScore;


# TC03 – Verify Student Average Score Report
SELECT * FROM StudentAverageScore;

# TC04 – Verify Course Completion Report
SELECT * FROM CourseCompletionRates;

# TC05 – Verify Top Performers Report
SELECT * FROM TopPerformersPerCourse;
