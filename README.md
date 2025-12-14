# 📱 PPF

- Portfolio Project with Flutter & AWS

---

## 📌 Overview

### Problem & Needs (문제 및 니즈)
- As digital services expand, there is a growing demand for a super-app platform that integrates user-facing services (such as social networking and e-commerce) with enterprise-level capabilities, including data management, analytics, and operational dashboards.
(SNS, 쇼핑 등 사용자 중심 서비스와 데이터 관리·분석 및 운영 대시보드와 같은 기업 기능을 하나의 플랫폼에서 통합할 필요성이 증가하고 있음)

### Solution & Expected Impact (솔루션 및 기대효과)
- PPF is a scalable super-app platform that unifies consumer features and enterprise management tools within a single mobile application. The platform is designed to support future service expansion and enable data-driven decision-making through integrated analytics and AI features.
(PPF는 사용자 기능과 관리자 기능을 단일 앱에 통합한 확장 가능한 슈퍼앱으로, 향후 서비스 확장과 데이터 기반 의사결정을 지원하는 범용 플랫폼을 목표로 함)

---

## 👤 Role & Responsibilities

### Full-stack IT Service Planner & Developer (풀스택 IT 서비스 기획자 & 개발자)
- Responsible for end-to-end planning, system architecture design, database modeling, frontend and backend development, cloud infrastructure integration, and ML feature implementation.
(프로젝트 전체 기획부터 시스템 아키텍처 설계, ERD 설계, 프론트엔드·백엔드 개발, AWS 클라우드 연동 및 ML 기능 통합까지 End-to-End로 담당)

---

## ⚙️ Tech Stack

### OS
- Windows 11

### IDE
- Visual Studio Code, Android Studio

### Target Platform
- Android (Samsung Galaxy S22)

### Framework
- Flutter (3.29.1)

### Languages
- Dart (3.7.0), Python (3.10), Java (17.0.11), JavaScript, SQL

### Backend (AWS)
- API Gateway, Lambda, RDS (MySQL), S3, SageMaker AI (ProcessingJob)

### Version Control
- Git, GitHub

### Others
- Figma, Photoshop, Canva

---

## 🔍 Rationale for Key Technology & Feature Choices

### Flutter
- Adopted to minimize development and maintenance costs through a single codebase while accelerating feature updates across mobile platforms.
(단일 코드베이스로 Android·iOS 동시 대응이 가능하여 개발·운영 비용을 최소화하고 업데이트 속도를 향상시키기 위해 선택)

### AWS Serverless (API Gateway & Lambda)
- Chosen to enable flexible service expansion, stable traffic handling, and cost-efficient scaling without infrastructure management overhead.
(서버리스 기반으로 인프라 운영 부담을 줄이고 트래픽 변화에 유연하게 대응하며 비용 최적화를 달성하기 위해 채택)

### Amazon RDS (MySQL)
- Utilized to reliably manage structured user, content, and commerce data with strong relational integrity.
(사용자·콘텐츠·상품·주문 데이터를 안정적으로 관리하기 위해 관계형 데이터베이스 선택)

### Amazon S3
- Implemented for high-availability storage and efficient delivery of image and media content in large-scale content environments.
(이미지 및 미디어 콘텐츠의 고가용성 저장과 효율적인 전송을 위해 적용)

### Amazon SageMaker
- Integrated to automate machine learning workflows and support scalable analytics and recommendation processing with optimized latency and cost.
(ML 모델 학습·분석·확장을 자동화하고 Processing Job 기반 분석으로 지연 시간과 비용을 최적화하기 위해 도입)

### Authentication (Signup/Login)
- Established as a foundation for secure user identity management and session-based service architecture.
(안정적인 유저 인증 및 세션 관리 기반의 서비스 구조 확립)

### SNS & Commerce Modules
- Designed to replicate real-world social interaction and e-commerce flows, enabling end-to-end content and transaction management.
(SNS 및 커머스의 실제 서비스 흐름을 반영한 엔드투엔드 콘텐츠·트랜잭션 구조 구현)

### Analytics Dashboards
- Built to aggregate and visualize user behavior, content performance, and sales data, supporting data-driven operational and revenue strategies.
(사용자·콘텐츠·매출 데이터를 시각화하여 운영 인사이트 도출 및 매출 성장 전략 수립을 지원)

---

## 🧱 System Architecture

- The system is built on a serverless AWS architecture. A Flutter-based mobile client communicates with backend services through Amazon API Gateway and AWS Lambda. Data is stored in Amazon RDS and S3, while analytics and machine learning workloads are processed using Amazon SageMaker.
(Flutter 모바일 앱을 클라이언트로 하여 API Gateway와 Lambda 기반의 서버리스 백엔드를 구성하였으며, RDS와 S3를 통해 데이터를 관리하고 SageMaker를 활용해 분석 및 ML 처리를 수행하는 구조)

 

---

## 🗂 Database Design (ERD)

- The relational database schema was designed to support user management, social content, e-commerce transactions, and analytics data, ensuring scalability and data integrity across multiple service domains.
(유저 관리, SNS 콘텐츠, 쇼핑 트랜잭션, 분석 데이터를 통합적으로 관리할 수 있도록 관계형 데이터베이스 구조를 설계하여 확장성과 데이터 정합성을 확보)

 

---

## 🖥 Main Features

### Signup / Login
- User registration, authentication, and session management (회원가입, 로그인 및 세션 관리 기능)

### Weather / VPN
- Location-based weather forecasting and VPN functionality (위치 기반 일기 예보 기능 및 VPN 기능)

### Tweet
- Twitter-style SNS with full CRUD operations (트위터 스타일 SNS의 CRUD 기능)

### Insta
- Instagram-style SNS with image-based CRUD operations (인스타그램 스타일 SNS의 CRUD 기능)

### Shop
- Product management, purchase, and transaction processing (쇼핑 채널의 CRUD 및 구매 기능)

### User Info
- User information management (RUD) and order cancellation (유저 페이지의 유저 RUD 및 구매 취소 기능)

### Dashboard Users
- Analysis of user profiles and behavioral patterns (유저 정보 및 행동 특성 분석)

### Dashboard Contents
- Content analysis using word clouds and image overlays (워드클라우드 및 이미지 오버레이로 컨텐츠 분석)

### Dashboard Sales
- Revenue analysis using similarity heatmaps and Top-N recommendation graphs (유사도 히트맵 및 Top-N 추천 그래프로 매출 관리 및 분석)

---

## 🖼 Screen Shots

 

---

## 📅 Timeline

| 기간               | 주요 작업                |
| ------------------ | ------------------------ |
| 2024.06 - 2024.07 | Planning & System Design (기획 및 설계) |
| 2024.07 - 2024.08 | Core App Development & Environment Setup (기본 앱 개발 및 환경 세팅) |
| 2024.08 - 2024.09 | Feature Expansion & Cloud Integration (기능 확장 및 클라우드 연동) |
| 2024.10 - 2024.12 | Service Enhancement & Stabilization (서비스 고도화 및 안정화) |
| 2025.01 - 2025.04 | Machine Learning Feature Integration (ML 기능 통합) |
| 2025.05 - 2025.08 | Operation & Maintenance (운영 및 유지 보수) |

---

## 🔗 External Resources

### Wireframe (Figma)
- https://www.figma.com/design/qokFuaMidfvWIZtHE8pn3o/Portfolio-Projects?node-id=2-2&t=Tf7gzTz6iSkaWlHf-1

### Demo Video (YouTube)
- https://youtu.be/jz8e4Ejg8G0

---

