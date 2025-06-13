# 📱 portfolioprojectflutter

Social and shopping mobile application
(소셜과 쇼핑 기능을 갖춘 모바일 어플리케이션)

## 📌 Project Overview

portfolioprojectflutter는 소셜미디어와 쇼핑 기능을 포함한 **생활 플랫폼 모바일 애플리케이션**입니다.  
유저 정보, 소셜미디어 정보, 구매 패턴 등을 확인하고, 머신러닝 등의 데이터 분석 기능을 지원합니다.

- **기획 배경**: 팀원 간 일정 공유의 불편함과 커뮤니케이션 문제를 해결하고자 기획
- **개발 목적**: 실시간 일정 공유 및 마감 알림을 통해 협업 효율을 높이는 도구 개발

---

## 🖥 Main Features

- 팀 생성 및 멤버 초대 (이메일 기반)
- 월간/주간/일간 보기 제공하는 캘린더 UI
- 역할/업무 기반 일정 필터링 기능
- 마감 1일 전 이메일 알림 발송
- 관리자와 일반 멤버 권한 분리
- 반응형 웹 디자인 적용

---

## ⚙️ Tech Stack

### 🖥 Development Environment
- OS: Windows 11
- IDE & Tools: VS Code, Android Studio, Flutter DevTools
- Version Control: Git, GitHub

### 📝 Programming Languages
- Dart (Flutter app development) (Flutter 앱 개발)
- Python (SageMakerAI processing) (SageMakerAI 처리 로직)
- JavaScript (Lambda scripting, minor frontend logic) (Lambda 스크립트 및 간단한 프론트엔드 로직)
- Java (Android-specific integration, SDK usage) (Android SDK 연동 등 플랫폼 특화 기능)

### ☁️ Cloud & Backend (AWS)
- API Gateway (connects Flutter app with serverless backend) (Flutter 앱과 서버리스 백엔드 연동)
- Lambda (backend logic using JavaScript) (백엔드 로직, JavaScript 기반)
- RDS (MySQL – user and app data storage) (MySQL – 사용자 및 앱 데이터 저장)
- S3 (image and static asset storage) (이미지 및 정적 리소스 저장)
- SageMakerAI ProcessingJob (data preprocessing and machine learning) (데이터 전처리 및 머신러닝)

### 📱 Platform
- Target OS: Android (Flutter-based build and deployment) (Flutter 기반 빌드 및 배포)

### 🎨 Design & Architecture
- Figma (UI/UX wireframing and prototyping) (UI/UX 설계 및 프로토타이핑)
- ERD editor (ERD and database modeling) (ERD 및 데이터베이스 모델링)

### 🛠 Other Tools
- Photoshop, Canva (image and video editing) (이미지 및 비디오 편집)

---

## 📁 Project Structure

```
📁 MyApp/
 ┣ 📂android/
 ┣ 📂ios/
 ┣ 📂lib/
 ┣ 📜.gitignore
 ┣ 📜README.md
 ┣ 📜.env.example
 ┣ 📜myapp-v1.0.0.apk ← GitHub Release에 업로드 (또는 링크로 제공)
/client         # 프론트엔드 소스코드
/server         # 백엔드 소스코드
/design         # 와이어프레임, UX 플로우 등 기획자료
```

---

## 🖼 Main Screens Examples

### 🔹 기능 화면 (tweet, insta, shop)

![기능 화면](./design/calendar_ui.png)

### 🔹 분석 화면 (user, contents, sales)

![분석 화면](./design/schedule_modal.png)

---

## 🔗 External Resources

- 📄 [Figma 와이어프레임](https://www.figma.com/design/qokFuaMidfvWIZtHE8pn3o/Portfolio-Projects?m=auto&t=lZD8PoA9xJuTEpGh-6)
- 🧾 [Notion 기획서](https://notion.so/your-link)
- 🎬 [시연 영상 (YouTube)](https://youtube.com/your-demo-link)
- 🌐 [배포 링크 (Vercel)](https://smartplanner.vercel.app)

---

## 👥 Team Structure and Roles

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Role</th>
      <th>Key Contributions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="3">Yongwon Kim (김용원)</td>
      <td>Planning / Design</td>
      <td>
        - Initiated project ideas (프로젝트 아이디어 도출)<br>
        - Defined requirements (요구사항 명세 작성)<br>
        - Designed UX (UX 설계)<br>
        - Created wireframes (와이어프레임 제작)
      </td>
    </tr>
    <tr>
      <td>Frontend Development</td>
      <td>
        - Implemented full UI (전체 UI 구성 및 개발)<br>
        - Developed calendar view (캘린더 뷰 기능 구현)<br>
        - Handled notification UX (알림 관련 UX 처리)
      </td>
    </tr>
    <tr>
      <td>Backend Development</td>
      <td>
        - Built API server (API 서버 구축)<br>
        - Modeled database schema (DB 모델링)<br>
        - Developed database (DB 구축)
      </td>
    </tr>
  </tbody>
</table>

---

## 🧪 Setup Instructions

### 1. Clone the Project

```bash
git clone https://github.com/your-username/smartplanner.git
```

### 2. Run Frontend

```bash
cd client
npm install
npm run dev
```

### 3. Run Backend

```bash
cd server
npm install
npm run dev
```

> 📌 `.env` 파일은 `/server/.env.example` 참고

---

## 📅 Project Timeline

| 기간               | 주요 작업                |
| ------------------ | ------------------------ |
| 2025.01.01 ~ 01.07 | 아이디어 기획 및 팀 구성 |
| 2025.01.08 ~ 01.15 | 요구사항 분석, UX 설계   |
| 2025.01.16 ~ 02.10 | 기능 개발 및 테스트      |
| 2025.02.11 ~ 02.20 | 배포 및 시연 자료 제작   |

---

## 📣 Other Info

- **Project Duration**: 2025.01 ~ 2025.02
- **Workflow**: 3인 팀 협업 (GitHub flow 기반)
- **Contact**: haribo09876@gmail.com

---
