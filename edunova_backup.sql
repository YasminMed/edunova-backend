-- EduNova Database Backup
-- Exported at: 2026-03-29T17:41:39.837037
-- Source: Railway PostgreSQL

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;


-- Table: activities
DROP TABLE IF EXISTS activities CASCADE;
CREATE TABLE IF NOT EXISTS activities (id integer NOT NULL, type character varying NOT NULL, user_id integer, lecturer_id integer, description character varying, created_at timestamp without time zone);
-- (no data in activities)

-- Table: assignment_submissions
DROP TABLE IF EXISTS assignment_submissions CASCADE;
CREATE TABLE IF NOT EXISTS assignment_submissions (id integer NOT NULL, assignment_id integer, student_id integer, solution_text character varying, file_url character varying, grade character varying, lecturer_note character varying, submitted_at timestamp without time zone, is_graded integer);

-- Data for table: assignment_submissions
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (1, 1, 2, 'uyhjhfcfghjkijhv', NULL, '80', '', '2026-03-16T20:21:01.311806', 1);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (2, 1, 3, 'ghujhg', NULL, '90', '', '2026-03-16T20:24:09.021948', 1);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (3, 2, 3, 'hellisesdf', NULL, NULL, NULL, '2026-03-17T12:30:35.397295', 0);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (4, 1, 1, 'asdf', NULL, NULL, NULL, '2026-03-18T18:10:29.748572', 0);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (5, 3, 1, 'asdf', NULL, '70', '', '2026-03-18T18:10:41.486302', 1);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (6, 4, 6, 'hello there', NULL, '99', 'perfect', '2026-03-19T19:55:03.032003', 1);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (7, 4, 2, 'hello there', NULL, NULL, NULL, '2026-03-28T10:55:01.878669', 0);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (8, 5, 2, 'hello there', NULL, '90', '', '2026-03-28T11:00:44.337998', 1);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (9, 6, 2, 'heillio', NULL, '60', 'perfect', '2026-03-28T11:01:31.778728', 1);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (10, 7, 2, 'dfjohe', NULL, NULL, NULL, '2026-03-28T13:35:33.249480', 0);
INSERT INTO "assignment_submissions" ("id", "assignment_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (11, 8, 2, 'ashudfkl', NULL, NULL, NULL, '2026-03-28T13:35:46.843326', 0);

-- Table: assignments
DROP TABLE IF EXISTS assignments CASCADE;
CREATE TABLE IF NOT EXISTS assignments (id integer NOT NULL, course_id integer, title character varying NOT NULL, content character varying NOT NULL, file_url character varying, created_at timestamp without time zone, category character varying, deadline timestamp without time zone);

-- Data for table: assignments
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (1, 4, 'u', 'o', NULL, '2026-03-16T20:19:43.746374', 'assignment', NULL);
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (2, 4, 'hello', 'hi', NULL, '2026-03-17T10:41:47.373891', 'assignment', NULL);
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (3, 3, 'ass2', 'answer', NULL, '2026-03-18T18:09:25.383487', 'assignment', NULL);
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (4, 6, 'ass1', 'write', NULL, '2026-03-19T19:54:18.110571', 'assignment', NULL);
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (5, 11, 'ass one', 'answer', NULL, '2026-03-28T10:59:30.044117', 'assignment', NULL);
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (6, 11, 'ass two', 'answer', NULL, '2026-03-28T10:59:38.729220', 'assignment', NULL);
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (7, 11, 'deadline ass', 'hie', NULL, '2026-03-28T13:32:49.704231', 'assignment', '2026-04-04T00:00:00');
INSERT INTO "assignments" ("id", "course_id", "title", "content", "file_url", "created_at", "category", "deadline") VALUES (8, 11, 'heeelllppp', 'jasdf', NULL, '2026-03-28T13:33:04.042206', 'assignment', '2026-04-04T00:00:00');

-- Table: attendance_records
DROP TABLE IF EXISTS attendance_records CASCADE;
CREATE TABLE IF NOT EXISTS attendance_records (id integer NOT NULL, course_id integer, student_name character varying NOT NULL, status character varying NOT NULL, date timestamp without time zone, student_id integer);

-- Data for table: attendance_records
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (1, 4, 'Ali Hassan', 'Attended', '2026-03-16T11:58:30.547547', NULL);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (2, 4, 'Sarah Ahmed', 'Late', '2026-03-16T11:58:30.547551', NULL);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (3, 4, 'Ali Hassan', 'Attended', '2026-03-16T20:58:25.588292', NULL);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (4, 4, 'Dalia Saman', 'Late', '2026-03-16T20:58:25.588298', NULL);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (5, 4, 'Unknown', 'Late', '2026-03-17T12:20:04.878370', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (6, 4, 'Unknown', 'Attended', '2026-03-17T12:20:04.881155', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (7, 4, 'Unknown', 'Attended', '2026-03-18T18:08:59.599380', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (8, 4, 'Unknown', 'Attended', '2026-03-18T18:08:59.601920', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (9, 7, 'Unknown', 'Attended', '2026-03-25T13:35:05.280028', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (10, 7, 'Unknown', 'Late', '2026-03-25T13:35:05.283343', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (11, 7, 'Unknown', 'Absent', '2026-03-25T13:35:05.287423', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (12, 7, 'Unknown', 'Attended', '2026-03-25T13:35:05.290818', 4);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (13, 7, 'Unknown', 'Attended', '2026-03-28T10:58:02.547540', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (14, 7, 'Unknown', 'Attended', '2026-03-28T10:58:02.550439', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (15, 7, 'Unknown', 'Attended', '2026-03-28T10:58:02.553390', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (16, 7, 'Unknown', 'Attended', '2026-03-28T10:58:02.555991', 4);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (17, 11, 'Unknown', 'Attended', '2026-03-28T16:39:07.893000', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (18, 11, 'Unknown', 'Attended', '2026-03-28T16:39:07.893000', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (21, 11, 'Unknown', 'Late', '2026-03-29T00:00:00', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (22, 11, 'Unknown', 'Late', '2026-03-29T00:00:00', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (23, 11, 'Unknown', 'Late', '2026-03-29T00:00:00', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (24, 11, 'Unknown', 'Late', '2026-03-29T00:00:00', 4);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (25, 11, 'Unknown', 'Absent', '2026-03-30T00:00:00', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (26, 11, 'Unknown', 'Absent', '2026-03-30T00:00:00', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (27, 11, 'Unknown', 'Absent', '2026-03-30T00:00:00', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (28, 11, 'Unknown', 'Absent', '2026-03-30T00:00:00', 4);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (29, 11, 'Unknown', 'Attended', '2026-03-27T00:00:00', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (30, 11, 'Unknown', 'Late', '2026-03-27T00:00:00', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (31, 11, 'Unknown', 'Attended', '2026-03-27T00:00:00', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (32, 11, 'Unknown', 'Absent', '2026-03-27T00:00:00', 4);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (19, 11, 'Unknown', 'Late', '2026-03-28T16:39:07.893000', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (20, 11, 'Unknown', 'Late', '2026-03-28T16:39:07.893000', 4);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (33, 11, 'Unknown', 'Attended', '2026-03-23T00:00:00', 6);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (34, 11, 'Unknown', 'Attended', '2026-03-23T00:00:00', 1);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (35, 11, 'Unknown', 'Attended', '2026-03-23T00:00:00', 2);
INSERT INTO "attendance_records" ("id", "course_id", "student_name", "status", "date", "student_id") VALUES (36, 11, 'Unknown', 'Attended', '2026-03-23T00:00:00', 4);

-- Table: challenge_completions
DROP TABLE IF EXISTS challenge_completions CASCADE;
CREATE TABLE IF NOT EXISTS challenge_completions (id integer NOT NULL, challenge_id integer, student_id integer, completed_at timestamp without time zone);
-- (no data in challenge_completions)

-- Table: chat_messages
DROP TABLE IF EXISTS chat_messages CASCADE;
CREATE TABLE IF NOT EXISTS chat_messages (id integer NOT NULL, session_id integer, sender_id integer, content character varying NOT NULL, created_at timestamp without time zone, is_read integer);

-- Data for table: chat_messages
INSERT INTO "chat_messages" ("id", "session_id", "sender_id", "content", "created_at", "is_read") VALUES (1, 1, 1, 'hello smsm', '2026-03-18T12:07:38.348587', 1);
INSERT INTO "chat_messages" ("id", "session_id", "sender_id", "content", "created_at", "is_read") VALUES (2, 1, 1, 'how u doin!', '2026-03-18T12:24:18.907045', 0);
INSERT INTO "chat_messages" ("id", "session_id", "sender_id", "content", "created_at", "is_read") VALUES (3, 3, 4, 'hello', '2026-03-24T09:09:14.436761', 0);
INSERT INTO "chat_messages" ("id", "session_id", "sender_id", "content", "created_at", "is_read") VALUES (4, 6, 2, 'hi dr', '2026-03-29T10:13:56.230889', 0);

-- Table: chat_sessions
DROP TABLE IF EXISTS chat_sessions CASCADE;
CREATE TABLE IF NOT EXISTS chat_sessions (id integer NOT NULL, user1_id integer, user2_id integer, created_at timestamp without time zone);

-- Data for table: chat_sessions
INSERT INTO "chat_sessions" ("id", "user1_id", "user2_id", "created_at") VALUES (1, 1, 3, '2026-03-18T12:07:30.875972');
INSERT INTO "chat_sessions" ("id", "user1_id", "user2_id", "created_at") VALUES (2, 9, 8, '2026-03-23T11:24:48.063751');
INSERT INTO "chat_sessions" ("id", "user1_id", "user2_id", "created_at") VALUES (3, 4, 5, '2026-03-24T09:09:09.306858');
INSERT INTO "chat_sessions" ("id", "user1_id", "user2_id", "created_at") VALUES (4, 2, 6, '2026-03-26T20:34:03.354805');
INSERT INTO "chat_sessions" ("id", "user1_id", "user2_id", "created_at") VALUES (5, 2, 5, '2026-03-26T20:35:09.226686');
INSERT INTO "chat_sessions" ("id", "user1_id", "user2_id", "created_at") VALUES (6, 2, 3, '2026-03-29T10:13:50.752634');

-- Table: comments
DROP TABLE IF EXISTS comments CASCADE;
CREATE TABLE IF NOT EXISTS comments (id integer NOT NULL, post_id integer, user_id integer, content character varying NOT NULL, created_at timestamp without time zone);
-- (no data in comments)

-- Table: course_resources
DROP TABLE IF EXISTS course_resources CASCADE;
CREATE TABLE IF NOT EXISTS course_resources (id integer NOT NULL, course_id integer, category character varying NOT NULL, title character varying NOT NULL, file_url character varying NOT NULL, created_at timestamp without time zone, views integer);

-- Data for table: course_resources
INSERT INTO "course_resources" ("id", "course_id", "category", "title", "file_url", "created_at", "views") VALUES (1, 1, 'pdfs', 'Introduction to Calculus', '/uploads/sample.pdf', '2026-03-15T21:02:15.616452', 0);
INSERT INTO "course_resources" ("id", "course_id", "category", "title", "file_url", "created_at", "views") VALUES (2, 1, 'assignments', 'Homework 1: Derivatives', '/uploads/hw1.pdf', '2026-03-15T21:02:15.616460', 0);
INSERT INTO "course_resources" ("id", "course_id", "category", "title", "file_url", "created_at", "views") VALUES (3, 4, 'pdfs', 'ju', '/uploads/58e171db7624eb19_01_intro.pdf', '2026-03-16T11:54:49.592670', 0);
INSERT INTO "course_resources" ("id", "course_id", "category", "title", "file_url", "created_at", "views") VALUES (4, 4, 'pdfs', 'week 8', '/uploads/ac02df24583c4028_ransomware_report.docx', '2026-03-16T19:30:44.285875', 0);
INSERT INTO "course_resources" ("id", "course_id", "category", "title", "file_url", "created_at", "views") VALUES (5, 7, 'pdfs', 'ijunh', '/uploads/1d5be47b4e4e9169_Screenshot 2026-03-27 224551.png', '2026-03-29T09:07:11.189758', 0);

-- Table: courses
DROP TABLE IF EXISTS courses CASCADE;
CREATE TABLE IF NOT EXISTS courses (id integer NOT NULL, name character varying NOT NULL, code character varying NOT NULL, image_url character varying, lecturer_id integer, department character varying, stage character varying);

-- Data for table: courses
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (1, 'Advanced Mathematics', 'MATH401', NULL, 1, 'Software Engineering', '1st');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (2, 'Quantum Physics', 'PHYS302', NULL, 1, 'Software Engineering', '1st');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (3, 'Software Engineering', 'SE201', NULL, 1, 'Software Engineering', '1st');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (4, 'math', 'ph234', NULL, 1, 'Software Engineering', '1st');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (5, 'new', 'new', NULL, 1, 'Software Engineering', '1st');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (6, 'newcourse', 'asd', NULL, 5, 'Software Engineering', 'Fourth Stage');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (7, 'soft', 'as23', NULL, 3, 'Software Engineering', 'Fourth Stage');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (8, 'it course', 'lhkl12', NULL, 8, 'IT', 'Fourth Stage');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (9, 'secong IT', 'asdfji', NULL, 8, 'IT', 'Fourth Stage');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (10, 'newnew', 'asdf', NULL, 5, 'Software Engineering', 'Third Stage');
INSERT INTO "courses" ("id", "name", "code", "image_url", "lecturer_id", "department", "stage") VALUES (11, 'newone', '1234', NULL, 3, 'Software Engineering', 'Fourth Stage');

-- Table: exam_marks
DROP TABLE IF EXISTS exam_marks CASCADE;
CREATE TABLE IF NOT EXISTS exam_marks (id integer NOT NULL, course_id integer, student_id integer, exam_type character varying NOT NULL, mark character varying NOT NULL, created_at timestamp without time zone);

-- Data for table: exam_marks
INSERT INTO "exam_marks" ("id", "course_id", "student_id", "exam_type", "mark", "created_at") VALUES (1, 4, 1, 'Midterm Exam', '30', '2026-03-17T12:29:12.042987');
INSERT INTO "exam_marks" ("id", "course_id", "student_id", "exam_type", "mark", "created_at") VALUES (2, 4, 2, 'Final Exam', '12', '2026-03-17T12:38:42.846111');
INSERT INTO "exam_marks" ("id", "course_id", "student_id", "exam_type", "mark", "created_at") VALUES (3, 7, 1, 'Final Exam', '39', '2026-03-28T10:58:44.146385');

-- Table: fee_installments
DROP TABLE IF EXISTS fee_installments CASCADE;
CREATE TABLE IF NOT EXISTS fee_installments (id integer NOT NULL, student_id integer, title character varying NOT NULL, amount character varying NOT NULL, status character varying, due_date character varying, paid_at timestamp without time zone, proof_url character varying);

-- Data for table: fee_installments
INSERT INTO "fee_installments" ("id", "student_id", "title", "amount", "status", "due_date", "paid_at", "proof_url") VALUES (2, 2, '2nd Installment', '750,000', 'due', 'Dec 1, 2026', NULL, NULL);
INSERT INTO "fee_installments" ("id", "student_id", "title", "amount", "status", "due_date", "paid_at", "proof_url") VALUES (3, 2, '3rd Installment', '750,000', 'due', 'Feb 1, 2027', NULL, NULL);
INSERT INTO "fee_installments" ("id", "student_id", "title", "amount", "status", "due_date", "paid_at", "proof_url") VALUES (4, 2, '4th Installment', '750,000', 'due', 'Apr 1, 2027', NULL, NULL);
INSERT INTO "fee_installments" ("id", "student_id", "title", "amount", "status", "due_date", "paid_at", "proof_url") VALUES (1, 2, '1st Installment', '750,000', 'paid', 'Oct 1, 2026', '2026-03-27T21:46:16.174273', NULL);

-- Table: group_chats
DROP TABLE IF EXISTS group_chats CASCADE;
CREATE TABLE IF NOT EXISTS group_chats (id integer NOT NULL, name character varying NOT NULL, photo_url character varying, admin_id integer, created_at timestamp without time zone);

-- Data for table: group_chats
INSERT INTO "group_chats" ("id", "name", "photo_url", "admin_id", "created_at") VALUES (1, 'new group', NULL, 3, '2026-03-18T12:23:32.358628');
INSERT INTO "group_chats" ("id", "name", "photo_url", "admin_id", "created_at") VALUES (2, 'hello', NULL, 3, '2026-03-18T12:34:19.452648');

-- Table: group_members
DROP TABLE IF EXISTS group_members CASCADE;
CREATE TABLE IF NOT EXISTS group_members (id integer NOT NULL, group_id integer, user_id integer, joined_at timestamp without time zone);

-- Data for table: group_members
INSERT INTO "group_members" ("id", "group_id", "user_id", "joined_at") VALUES (1, 1, 3, '2026-03-18T12:23:32.383954');
INSERT INTO "group_members" ("id", "group_id", "user_id", "joined_at") VALUES (2, 1, 1, '2026-03-18T12:23:32.383960');
INSERT INTO "group_members" ("id", "group_id", "user_id", "joined_at") VALUES (4, 2, 3, '2026-03-18T12:34:19.477433');
INSERT INTO "group_members" ("id", "group_id", "user_id", "joined_at") VALUES (5, 2, 1, '2026-03-18T12:34:19.477438');
INSERT INTO "group_members" ("id", "group_id", "user_id", "joined_at") VALUES (6, 2, 2, '2026-03-18T12:34:19.477439');

-- Table: group_messages
DROP TABLE IF EXISTS group_messages CASCADE;
CREATE TABLE IF NOT EXISTS group_messages (id integer NOT NULL, group_id integer, sender_id integer, content character varying NOT NULL, created_at timestamp without time zone);

-- Data for table: group_messages
INSERT INTO "group_messages" ("id", "group_id", "sender_id", "content", "created_at") VALUES (1, 1, 1, 'hi all!', '2026-03-18T12:24:34.800792');
INSERT INTO "group_messages" ("id", "group_id", "sender_id", "content", "created_at") VALUES (2, 1, 3, 'hello', '2026-03-18T12:25:30.241284');
INSERT INTO "group_messages" ("id", "group_id", "sender_id", "content", "created_at") VALUES (3, 1, 1, 'how are you', '2026-03-18T12:43:26.488694');

-- Table: posts
DROP TABLE IF EXISTS posts CASCADE;
CREATE TABLE IF NOT EXISTS posts (id integer NOT NULL, user_id integer, title character varying NOT NULL, description character varying, image_url character varying, video_url character varying, created_at timestamp without time zone);

-- Data for table: posts
INSERT INTO "posts" ("id", "user_id", "title", "description", "image_url", "video_url", "created_at") VALUES (2, 1, 'hello', 'hi there', NULL, NULL, '2026-03-15T20:20:16.858904');

-- Table: quiz_submissions
DROP TABLE IF EXISTS quiz_submissions CASCADE;
CREATE TABLE IF NOT EXISTS quiz_submissions (id integer NOT NULL, quiz_id integer, student_id integer, solution_text character varying, file_url character varying, grade character varying, lecturer_note character varying, submitted_at timestamp without time zone, is_graded integer);

-- Data for table: quiz_submissions
INSERT INTO "quiz_submissions" ("id", "quiz_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (1, 1, 3, 'hello', NULL, '65', '', '2026-03-17T12:30:22.419846', 1);
INSERT INTO "quiz_submissions" ("id", "quiz_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (2, 1, 1, 'hello', NULL, '80', '', '2026-03-17T13:01:15.481650', 1);
INSERT INTO "quiz_submissions" ("id", "quiz_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (3, 2, 2, 'asohf', NULL, '20', 'good', '2026-03-28T11:01:51.513900', 1);
INSERT INTO "quiz_submissions" ("id", "quiz_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (4, 3, 2, 'uhasofh', NULL, '70', '', '2026-03-28T11:02:00.074715', 1);
INSERT INTO "quiz_submissions" ("id", "quiz_id", "student_id", "solution_text", "file_url", "grade", "lecturer_note", "submitted_at", "is_graded") VALUES (5, 4, 2, 'suoiafh', NULL, '59', '', '2026-03-28T11:02:07.697021', 1);

-- Table: quizzes
DROP TABLE IF EXISTS quizzes CASCADE;
CREATE TABLE IF NOT EXISTS quizzes (id integer NOT NULL, course_id integer, title character varying NOT NULL, content character varying NOT NULL, file_url character varying, created_at timestamp without time zone, deadline timestamp without time zone);

-- Data for table: quizzes
INSERT INTO "quizzes" ("id", "course_id", "title", "content", "file_url", "created_at", "deadline") VALUES (1, 4, 'quiz one', 'wirte', NULL, '2026-03-17T12:19:44.243818', NULL);
INSERT INTO "quizzes" ("id", "course_id", "title", "content", "file_url", "created_at", "deadline") VALUES (2, 11, 'quiz one', 'oih', NULL, '2026-03-28T10:59:48.809166', NULL);
INSERT INTO "quizzes" ("id", "course_id", "title", "content", "file_url", "created_at", "deadline") VALUES (3, 11, 'quiz one', 'oih', NULL, '2026-03-28T10:59:49.588106', NULL);
INSERT INTO "quizzes" ("id", "course_id", "title", "content", "file_url", "created_at", "deadline") VALUES (4, 11, 'two', 'asdf', NULL, '2026-03-28T10:59:57.401131', NULL);

-- Table: users
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE IF NOT EXISTS users (id integer NOT NULL, email character varying NOT NULL, password character varying NOT NULL, full_name character varying, gender character varying, role character varying, department character varying, stage character varying, years_of_experience integer, image_url character varying, total_academic_marks integer);

-- Data for table: users
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (6, 'yaso3@gmail.com', 'yasoyaso', 'yaso3', 'Female', 'student', 'Software Engineering', 'Fourth Stage', 0, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (1, 'yaso@gmail.com', 'yasoyaso', 'yasmen', 'Female', 'student', 'Software Engineering', 'Fourth Stage', 0, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (2, 'yaso1@gmail.com', 'yasoyaso', 'yasmen', 'Male', 'student', 'Software Engineering', 'Fourth Stage', 0, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (4, 'yaso2@gmail.com', 'yasoyaso', 'yaso2', 'Male', 'student', 'Software Engineering', 'Fourth Stage', 0, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (7, 'yaso4@gmail.com', 'yasoyaso', 'yaso4', 'Male', 'student', 'Civil Engineering', 'Second Stage', 0, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (9, 'yait@gmail.com', 'yasoyaso', 'yasmenIT', 'Male', 'student', 'IT', 'Fourth Stage', 0, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (5, 'smsm2@gmail.com', 'yasoyaso', 'smsm2', 'Male', 'lecturer', 'Software Engineering', 'Third Stage, Fourth Stage', 12, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (3, 'smsm@gmail.com', 'yasoyaso', 'smsm', 'Female', 'lecturer', 'Software Engineering', 'Third Stage, Fourth Stage', 10, NULL, 0);
INSERT INTO "users" ("id", "email", "password", "full_name", "gender", "role", "department", "stage", "years_of_experience", "image_url", "total_academic_marks") VALUES (8, 'smsm3@gmail.com', 'yasoyaso', 'smsm3', 'Male', 'lecturer', 'IT', 'Fourth Stage', 5, NULL, 0);

-- Table: weekly_challenges
DROP TABLE IF EXISTS weekly_challenges CASCADE;
CREATE TABLE IF NOT EXISTS weekly_challenges (id integer NOT NULL, title character varying NOT NULL, description character varying, points integer, created_at timestamp without time zone);
-- (no data in weekly_challenges)