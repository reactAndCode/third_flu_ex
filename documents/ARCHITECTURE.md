# 아키텍처 설계서
## Architecture Design Document

**프로젝트명**: 윤상민 운동 관리 앱
**버전**: 1.1.0
**작성일**: 2024-11-20

---

## 1. 시스템 개요

### 1.1 아키텍처 스타일
- **클라이언트-서버 아키텍처**: Flutter 클라이언트 + Supabase 서버
- **레이어드 아키텍처**: Presentation - Business Logic - Data

### 1.2 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────┐
│                    Client Layer                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │           Presentation Layer (UI)                │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐       │   │
│  │  │  Login   │  │   Home   │  │  Detail  │       │   │
│  │  │  Screen  │  │  Screen  │  │  Screen  │       │   │
│  │  └──────────┘  └──────────┘  └──────────┘       │   │
│  │                                                   │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │           Widgets Layer                   │   │   │
│  │  │  WorkoutListItem, CustomButton, etc.      │   │   │
│  │  └──────────────────────────────────────────┘   │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                     │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │         Business Logic Layer (Provider)          │   │
│  │  ┌──────────────┐         ┌──────────────┐      │   │
│  │  │    Auth      │         │   Workout    │      │   │
│  │  │   Provider   │         │   Provider   │      │   │
│  │  └──────────────┘         └──────────────┘      │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                     │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │              Data Layer (Services)               │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │         Supabase Service                  │   │   │
│  │  │  - Authentication API                     │   │   │
│  │  │  - Workout CRUD API                       │   │   │
│  │  └──────────────────────────────────────────┘   │   │
│  └─────────────────┬────────────────────────────────┘   │
│                    │                                     │
│  ┌─────────────────▼────────────────────────────────┐   │
│  │              Model Layer                         │   │
│  │  ┌──────────┐                                    │   │
│  │  │ Workout  │                                    │   │
│  │  │  Model   │                                    │   │
│  │  └──────────┘                                    │   │
│  └──────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────┘
                     │ HTTPS / REST API
                     │
┌────────────────────▼────────────────────────────────────┐
│                   Server Layer                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Supabase Backend                    │   │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────┐  │   │
│  │  │  Auth API  │  │  REST API  │  │  Storage │  │   │
│  │  └────────────┘  └────────────┘  └──────────┘  │   │
│  │                                                  │   │
│  │  ┌────────────────────────────────────────┐    │   │
│  │  │      PostgreSQL Database               │    │   │
│  │  │  ┌──────────┐     ┌──────────┐        │    │   │
│  │  │  │  users   │     │ workouts │        │    │   │
│  │  │  │  (Auth)  │     │  (Data)  │        │    │   │
│  │  │  └──────────┘     └──────────┘        │    │   │
│  │  └────────────────────────────────────────┘    │   │
│  │                                                  │   │
│  │  ┌────────────────────────────────────────┐    │   │
│  │  │      Row Level Security (RLS)          │    │   │
│  │  └────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 2. 기술 스택

### 2.1 프론트엔드

| 카테고리 | 기술 | 버전 | 용도 |
|---------|------|------|------|
| 프레임워크 | Flutter | >=3.1.3 | 크로스 플랫폼 UI |
| 언어 | Dart | >=3.1.3 | 프로그래밍 언어 |
| 상태 관리 | Provider | ^6.1.1 | 상태 관리 패턴 |
| HTTP 클라이언트 | Supabase Flutter | ^2.5.0 | API 통신 |
| 날짜 포맷팅 | intl | ^0.18.1 | 국제화 및 날짜 |
| 아이콘 | Cupertino Icons | ^1.0.2 | iOS 스타일 아이콘 |

### 2.2 백엔드

| 카테고리 | 기술 | 용도 |
|---------|------|------|
| BaaS | Supabase | 백엔드 서비스 |
| 데이터베이스 | PostgreSQL | 관계형 데이터베이스 |
| 인증 | Supabase Auth | 사용자 인증 |
| API | Supabase REST API | 데이터 CRUD |

### 2.3 배포

| 플랫폼 | 용도 | URL |
|--------|------|-----|
| Vercel | 웹 호스팅 | https://third-flu-ex.vercel.app |
| GitHub | 소스 코드 저장소 | https://github.com/reactAndCode/third_flu_ex |
| APK | Android 배포 | 로컬 파일 |

---

## 3. 레이어 아키텍처 상세

### 3.1 Presentation Layer (UI)

**책임**:
- 사용자 인터페이스 렌더링
- 사용자 입력 처리
- Provider로부터 상태 구독 및 표시

**주요 컴포넌트**:
```
screens/
├── login_screen.dart          # 로그인 UI
├── signup_screen.dart         # 회원가입 UI
├── home_screen.dart           # 운동 목록 UI
└── workout_detail_screen.dart # 운동 상세 UI

widgets/
└── workout_list_item.dart     # 운동 항목 위젯
```

**데이터 흐름**:
```
User Input → Screen → Provider → Service → Supabase
                ↑                    ↓
                └─── notifyListeners ←┘
```

### 3.2 Business Logic Layer (Provider)

**책임**:
- 비즈니스 로직 처리
- 상태 관리 및 알림
- UI와 Data Layer 중재

**주요 컴포넌트**:
```dart
// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;

  // 로그인
  Future<void> signIn(String email, String password);

  // 회원가입
  Future<void> signUp(String email, String password);

  // 로그아웃
  Future<void> signOut();

  // 인증 상태 확인
  void checkAuthStatus();
}

// providers/workout_provider.dart
class WorkoutProvider extends ChangeNotifier {
  List<Workout> _workouts = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // 운동 목록 로드
  Future<void> loadWorkouts();

  // 운동 추가
  Future<void> addWorkout(Workout workout);

  // 운동 수정
  Future<void> updateWorkout(Workout workout);

  // 운동 삭제
  Future<void> deleteWorkout(String id);

  // 날짜 변경
  void changeDate(DateTime date);
  void nextDay();
  void previousDay();
}
```

**상태 관리 패턴**:
```
Provider (ChangeNotifier)
  ↓
Consumer Widget
  ↓
UI Update
```

### 3.3 Data Layer (Services)

**책임**:
- 외부 API 통신
- 데이터 변환 (DTO ↔ Model)
- 에러 처리

**주요 컴포넌트**:
```dart
// services/supabase_service.dart
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // 인증
  Future<AuthResponse> signUp(String email, String password);
  Future<AuthResponse> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();

  // 운동 CRUD
  Future<List<Workout>> getWorkoutsByDate(DateTime date);
  Future<Workout> insertWorkout(Workout workout);
  Future<Workout> updateWorkout(Workout workout);
  Future<void> deleteWorkout(String id);
}
```

### 3.4 Model Layer

**책임**:
- 데이터 구조 정의
- 직렬화/역직렬화
- 데이터 검증

**주요 컴포넌트**:
```dart
// models/workout.dart
class Workout {
  final String? id;
  final String? userId;
  final String name;
  final String weight;
  final String reps;
  final String sets;
  final String bodyPart;
  final String? notes;
  final DateTime date;

  // JSON 직렬화
  Map<String, dynamic> toMap();

  // JSON 역직렬화
  factory Workout.fromMap(Map<String, dynamic> map);
}
```

---

## 4. 데이터베이스 설계

### 4.1 ERD (Entity Relationship Diagram)

```
┌─────────────────┐           ┌─────────────────┐
│  auth.users     │           │    workouts     │
├─────────────────┤           ├─────────────────┤
│ id (PK)         │───────┬───│ id (PK)         │
│ email           │       │   │ user_id (FK)    │
│ encrypted_pass  │       └──→│ exercise_name   │
│ created_at      │           │ workout_date    │
│ updated_at      │           │ weight          │
└─────────────────┘           │ reps            │
                              │ sets            │
                              │ body_part       │
                              │ notes           │
                              │ date            │
                              └─────────────────┘
```

### 4.2 테이블 스키마

#### 4.2.1 auth.users (Supabase 기본 테이블)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | UUID | PK, NOT NULL | 사용자 고유 ID |
| email | VARCHAR | UNIQUE, NOT NULL | 이메일 |
| encrypted_password | VARCHAR | NOT NULL | 암호화된 비밀번호 |
| created_at | TIMESTAMP | NOT NULL | 생성일시 |
| updated_at | TIMESTAMP | NOT NULL | 수정일시 |

#### 4.2.2 workouts

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGSERIAL | PK, AUTO_INCREMENT | 운동 고유 ID |
| user_id | UUID | FK (auth.users), NOT NULL | 사용자 ID |
| exercise_name | TEXT | NOT NULL | 운동명 |
| workout_date | TEXT | NOT NULL | 운동 날짜 (YYYY-MM-DD) |
| weight | TEXT | | 중량 |
| reps | TEXT | | 횟수 |
| sets | TEXT | | 세트 수 |
| body_part | TEXT | | 운동 부위 |
| notes | TEXT | | 운동방법 상세 |
| date | TIMESTAMP WITH TIME ZONE | NOT NULL | 타임스탬프 |

**인덱스**:
```sql
CREATE INDEX idx_workouts_user_date ON workouts(user_id, workout_date);
CREATE INDEX idx_workouts_user_id ON workouts(user_id);
```

### 4.3 RLS (Row Level Security) 정책

```sql
-- 사용자는 본인의 운동 기록만 조회 가능
CREATE POLICY "Users can view own workouts"
ON workouts FOR SELECT
USING (auth.uid() = user_id);

-- 사용자는 본인의 운동 기록만 추가 가능
CREATE POLICY "Users can insert own workouts"
ON workouts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 사용자는 본인의 운동 기록만 수정 가능
CREATE POLICY "Users can update own workouts"
ON workouts FOR UPDATE
USING (auth.uid() = user_id);

-- 사용자는 본인의 운동 기록만 삭제 가능
CREATE POLICY "Users can delete own workouts"
ON workouts FOR DELETE
USING (auth.uid() = user_id);
```

---

## 5. API 설계

### 5.1 인증 API

#### 5.1.1 회원가입
```
POST /auth/v1/signup
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200 OK):
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2024-11-20T..."
  },
  "session": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token"
  }
}
```

#### 5.1.2 로그인
```
POST /auth/v1/token?grant_type=password
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200 OK):
{
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "user": { ... }
}
```

#### 5.1.3 로그아웃
```
POST /auth/v1/logout
Authorization: Bearer {access_token}

Response (204 No Content)
```

### 5.2 운동 API

#### 5.2.1 운동 목록 조회
```
GET /rest/v1/workouts?user_id=eq.{userId}&workout_date=eq.{date}
Authorization: Bearer {access_token}

Response (200 OK):
[
  {
    "id": "1",
    "user_id": "uuid",
    "exercise_name": "벤치프레스",
    "workout_date": "2024-11-20",
    "weight": "60kg",
    "reps": "10",
    "sets": "3",
    "body_part": "가슴",
    "notes": "정확한 자세로...",
    "date": "2024-11-20T..."
  }
]
```

#### 5.2.2 운동 추가
```
POST /rest/v1/workouts
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "user_id": "uuid",
  "exercise_name": "스쿼트",
  "workout_date": "2024-11-20",
  "weight": "80kg",
  "reps": "8",
  "sets": "4",
  "body_part": "하체",
  "notes": "...",
  "date": "2024-11-20T..."
}

Response (201 Created):
{
  "id": "2",
  ...
}
```

#### 5.2.3 운동 수정
```
PATCH /rest/v1/workouts?id=eq.{id}
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "weight": "65kg",
  "reps": "12"
}

Response (200 OK):
{
  "id": "1",
  ...
}
```

#### 5.2.4 운동 삭제
```
DELETE /rest/v1/workouts?id=eq.{id}
Authorization: Bearer {access_token}

Response (204 No Content)
```

---

## 6. 보안 설계

### 6.1 인증 및 권한

| 항목 | 방식 |
|------|------|
| 인증 방식 | JWT (JSON Web Token) |
| 토큰 저장 | Supabase 클라이언트 자동 관리 |
| 세션 유지 | Refresh Token 자동 갱신 |
| 권한 관리 | RLS (Row Level Security) |

### 6.2 데이터 보안

| 항목 | 방식 |
|------|------|
| 통신 암호화 | HTTPS (TLS 1.3) |
| 비밀번호 암호화 | bcrypt (Supabase 기본) |
| 데이터 격리 | RLS 정책 (사용자별) |
| SQL Injection 방지 | Prepared Statements |

### 6.3 환경 변수 관리

```dart
// 컴파일 타임 상수
const String supabaseUrl = String.fromEnvironment(
  'NEXT_PUBLIC_SUPABASE_URL',
  defaultValue: 'https://...',
);

const String supabaseAnonKey = String.fromEnvironment(
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  defaultValue: 'eyJ...',
);
```

**주의사항**:
- Anon Key는 공개 키이므로 클라이언트 노출 허용
- RLS 정책으로 데이터 접근 제어
- Service Role Key는 서버 사이드만 사용 (클라이언트 노출 금지)

---

## 7. 배포 아키텍처

### 7.1 배포 흐름

```
┌──────────────┐
│  Developer   │
└──────┬───────┘
       │ git push
       ↓
┌──────────────┐
│    GitHub    │
└──────┬───────┘
       │ webhook
       ↓
┌──────────────┐
│    Vercel    │ ← Automatic Build & Deploy
└──────┬───────┘
       │
       ├─→ [Static Files Serving]
       │   └─→ build/web/*
       │
       └─→ [CDN Edge Network]
           └─→ Global Distribution
```

### 7.2 환경별 설정

| 환경 | URL | 용도 |
|------|-----|------|
| Production | https://third-flu-ex.vercel.app | 프로덕션 배포 |
| Development | http://localhost:port | 로컬 개발 |

### 7.3 빌드 프로세스

```bash
# 로컬 빌드
flutter build web --release

# Git 커밋
git add build/web
git commit -m "Deploy web build"
git push origin main

# Vercel 자동 배포
# - GitHub webhook 트리거
# - build/web 폴더 정적 서빙
# - CDN 배포
```

---

## 8. 성능 최적화

### 8.1 프론트엔드 최적화

| 항목 | 방법 |
|------|------|
| 번들 크기 | Tree-shaking (아이콘 99.5% 감소) |
| 이미지 최적화 | WebP 포맷, 적절한 해상도 |
| 코드 스플리팅 | Lazy Loading (미적용) |
| 캐싱 | Service Worker (Flutter 기본) |

### 8.2 백엔드 최적화

| 항목 | 방법 |
|------|------|
| 쿼리 최적화 | 인덱스 사용 (user_id, workout_date) |
| 데이터 페이징 | 미적용 (단일 날짜 조회) |
| 캐싱 | Supabase 기본 캐싱 |

### 8.3 네트워크 최적화

| 항목 | 방법 |
|------|------|
| HTTP/2 | Vercel 기본 지원 |
| CDN | Vercel Edge Network |
| Compression | Gzip/Brotli |

---

## 9. 모니터링 및 로깅

### 9.1 에러 추적
- Flutter DevTools (개발 환경)
- try-catch 블록으로 에러 로깅
- Supabase Dashboard (데이터베이스 로그)

### 9.2 성능 모니터링
- Vercel Analytics (웹 성능)
- Flutter Performance Overlay (개발 환경)

---

## 10. 확장성 고려사항

### 10.1 수평 확장
- Supabase: 자동 스케일링
- Vercel: Serverless 자동 스케일링

### 10.2 수직 확장
- Supabase 플랜 업그레이드 (Free → Pro → Team)

### 10.3 향후 확장 포인트
```
현재 아키텍처
    ↓
Phase 2: 캐싱 레이어 추가 (Redis)
    ↓
Phase 3: 마이크로서비스 분리 (운동 추천 서비스)
    ↓
Phase 4: 메시지 큐 도입 (Push 알림)
```

---

## 11. 기술 부채 및 개선 사항

| 항목 | 현재 상태 | 개선 방안 |
|------|-----------|-----------|
| 에러 처리 | 기본 try-catch | 중앙화된 에러 핸들러 |
| 오프라인 지원 | 미지원 | Local Database (SQLite) + Sync |
| 테스트 | 미작성 | Unit Test, Widget Test 추가 |
| CI/CD | 수동 빌드 | GitHub Actions 자동화 |
| 로깅 | print 문 | 구조화된 로깅 (Logger 패키지) |
