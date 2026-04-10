# EduNova: Comprehensive Feature & Functional Specification

EduNova is a state-of-the-art, AI-powered educational ecosystem designed to streamline the learning process for students and the management process for lecturers. This document provides a detailed breakdown of all features currently implemented within the application.

---

## 🏗 System Overview & Architecture

EduNova follows a modern client-server architecture designed for high availability and data persistence.

*   **Frontend**: Built with **Flutter**, supporting Android, iOS, and Web. It utilizes the `Provider` pattern for state management and `Dio` for high-performance API communication.
*   **Backend**: A **FastAPI** (Python) server that handles complex business logic, AI integrations, and real-time data processing.
*   **Database**: Uses **PostgreSQL** in production with an automated migration system to ensure schema consistency across deployments.
*   **File Persistence**: Unlike traditional ephemeral storage, EduNova stores all uploaded files (PDFs, Images, Assignments) directly in the database as `LargeBinary` blobs, ensuring no data loss during cloud redeployments.

---

## 🔐 Security & User Lifecycle

### 1. Identity Management
*   **Dual-Role Support**: Separate registration and login flows for **Students** and **Lecturers**, each with their own unique dashboards and permission levels.
*   **Profile Personalization**: Users can update their full name, department, academic stage, and years of experience.
*   **Profile Pictures**: High-quality photo upload support, serving as a visual identity throughout the chat and social modules.

### 2. Security Systems
*   **OTP Verification**: Secure password reset flow using One-Time Passwords sent via a dedicated notification bridge.
*   **Account Controls**: Users have full control over their data, including the ability to change passwords securely or permanently delete their accounts.
*   **Online Presence**: Real-time tracking of user status (`is_online`) and `last_seen` timestamps for better team collaboration.

---

## 🎓 Student Core Features

The student experience is centered around academic excellence and convenience.

### 1. Intelligent Dashboard
*   **Progress Tracking**: Visual circular indicator showing overall academic completion percentage.
*   **Rank Visibility**: Real-time rank calculation based on academic performance.
*   **Total Marks**: Summary of points earned across all subjects.
*   **AI Greeting**: Personalized messages that adapt to the time of day and student's name.

### 2. Academic Modules
*   **Lectures & Resources**: A dedicated portal to view and download course materials (PDFs, Slides, recorded links).
*   **Marks & Performance**: Detailed view of Midterm, Final, and Quiz marks per subject.
*   **Timetable**: Integrated schedule view for class timings and deadlines.
*   **Faculty View**: Quick access to profiles of all lecturers, their specializations, and office hours.

### 3. Financial Management
*   **Fees Management**: Detailed tracking of tuition installments.
*   **Payment Status**: Clearly marked "Paid" vs "Due" installments with specific due dates.
*   **Payment Proof**: Capability to view or upload digital receipts/proof of bank transfers.

### 4. Engagement & Gamification
*   **Medal System**: Virtual achievements for academic milestones (Gold, Silver, and Bronze rankings).
*   **Weekly Challenges**: A "Weekly Master Challenge" system where students earn productivity points.
*   **Medal Board**: A dedicated UI to showcase all unlocked academic medals.

---

## 👨‍🏫 Lecturer Core Features

Lecturers are equipped with powerful tools to manage and inspire their classes.

### 1. Material Management
*   **Universal Upload**: One-click uploading of PDFs, assignments, and quizzes to specific courses.
*   **Dynamic Deadlines**: Set specific dates for assignment and quiz submissions.
*   **Content Catalog**: Organize resources by category (Assignments, Lectures, Exams).

### 2. Evaluation & Grading
*   **Submission Review**: View all student submissions (text or files) in a streamlined interface.
*   **Grading Tools**: Assign marks and provide detailed "Lecturer Notes" for each student.
*   **Auto-Calculation**: Backend automatically updates student GPA and ranks based on entered marks.

### 3. Student Analysis
*   **Performance Trends**: Advanced analytics view showing which students are at risk and who are top performers.
*   **Engagement Tracking**: View counts on uploaded materials to see which resources are most helpful.

---

## 💬 Collaboration & Community

### 1. Messaging Suite
*   **1-on-1 Chat**: Direct, real-time communication between students and lecturers.
*   **Group Chats**: Collaborative channels for specific classes or project groups, with full member management.
*   **Attachments**: Share files, images, and documents directly within the chat interface.

### 2. Social Learning (Campus Feed)
*   **Post Creation**: Share updates, educational news, or event announcements.
*   **Community Interaction**: Interactive feed allowing users to `Like` and `Comment` on posts.
*   **Social Connectivity**: See post authorship and interact with the campus community.

---

## 🤖 AI & Productivity Features

### 1. Smart Chatbot (AI Assistant)
*   **Multi-Model Support**: Integration with Gemini, DeepSeek, and Groq models.
*   **Context-Aware**: Provides help on lecture content and educational queries.
*   **Role Identification**: The AI understands whether it is talking to a student or a lecturer to provide tailored advice.

### 2. Focus Zone (Music & Productivity)
*   **Ambient Library**: Built-in library involving "Calming Rain", "Birds & Nature", and "Study Piano".
*   **Custom Tracks**: Students can add their own audio files for study sessions.
*   **Productivity Timer**: Integrated with audio for timed study sessions.

---

## 🌍 Technical & UX Excellence
*   **Localization**: Full Kurdish (Sorani) and English translation throughout every page.
*   **Visual Design**: Glassmorphic UI, Lottie animations, and a polished dark/light mode system.
*   **Cross-Platform Consistency**: Unified experience across Mobile (Android/iOS) and Web.
