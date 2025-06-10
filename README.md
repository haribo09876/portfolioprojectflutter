# 📱 portfolioprojectflutter

Social and shopping mobile application (소셜과 쇼핑 기능을 갖춘 모바일 어플리케이션)

## 📌 프로젝트 개요

portfolioprojectflutter는 소셜미디어와 쇼핑 기능을 포함한 **생활 플랫폼 모바일 애플리케이션**입니다.  
유저 정보, 소셜미디어 정보, 구매 패턴 등을 확인하고, 머신러닝 등의 데이터 분석 기능을 지원합니다.

- **기획 배경**: 팀원 간 일정 공유의 불편함과 커뮤니케이션 문제를 해결하고자 기획
- **개발 목적**: 실시간 일정 공유 및 마감 알림을 통해 협업 효율을 높이는 도구 개발

---

## 🖥 주요 기능

- 팀 생성 및 멤버 초대 (이메일 기반)
- 월간/주간/일간 보기 제공하는 캘린더 UI
- 역할/업무 기반 일정 필터링 기능
- 마감 1일 전 이메일 알림 발송
- 관리자와 일반 멤버 권한 분리
- 반응형 웹 디자인 적용

---

## ⚙️ 기술 스택

### 💻 프론트엔드

- Flutter
- Dart

### 🖥 백엔드

- AWS Lambda (Node.js, JavaScript)
- AWS API Gateway
- AWS RDS (MySQL)
- AWS S3
- AWS SageMaker ProcessingJob

### 🛠 협업 & 디자인

- GitHub
- Figma
- Photoshop

---

## 📁 프로젝트 구조

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

## 🖼 주요 화면 예시

### 🔹 메인 캘린더 화면

![캘린더 화면](./design/calendar_ui.png)

### 🔹 일정 추가 모달

![일정 추가 모달](./design/schedule_modal.png)

---

## 🔗 외부 자료 링크

- 📄 [Figma 와이어프레임](https://www.figma.com/design/qokFuaMidfvWIZtHE8pn3o/Portfolio-Projects?m=auto&t=lZD8PoA9xJuTEpGh-6)
- 🧾 [Notion 기획서](https://notion.so/your-link)
- 🎬 [시연 영상 (YouTube)](https://youtube.com/your-demo-link)
- 🌐 [배포 링크 (Vercel)](https://smartplanner.vercel.app)

---

## 👥 팀 구성 및 역할

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
        - Created wireframes using Figma (Figma를 활용한 와이어프레임 제작)
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

## 🧪 실행 방법

### 1. 프로젝트 클론

```bash
git clone https://github.com/your-username/smartplanner.git
```

### 2. 프론트엔드 실행

```bash
cd client
npm install
npm run dev
```

### 3. 백엔드 실행

```bash
cd server
npm install
npm run dev
```

> 📌 `.env` 파일은 `/server/.env.example` 참고

---

## 📅 개발 일정

| 기간               | 주요 작업                |
| ------------------ | ------------------------ |
| 2025.01.01 ~ 01.07 | 아이디어 기획 및 팀 구성 |
| 2025.01.08 ~ 01.15 | 요구사항 분석, UX 설계   |
| 2025.01.16 ~ 02.10 | 기능 개발 및 테스트      |
| 2025.02.11 ~ 02.20 | 배포 및 시연 자료 제작   |

---

## 📣 기타 정보

- **프로젝트 기간**: 2025.01 ~ 2025.02
- **진행 방식**: 3인 팀 협업 (GitHub flow 기반)
- **문의**: kimplanner@example.com

---
