# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소의 코드 작업 시 참고하는 가이드입니다.

## 프로젝트 개요

Flutter 기반 운동 관리 앱으로, 사용자가 일일 운동 루틴을 추적할 수 있습니다. 백엔드 데이터베이스로 Supabase를 사용하고, 상태 관리는 Provider를 사용합니다.

## 명령어

### 개발
```bash
# 의존성 설치
flutter pub get

# 디버그 모드로 앱 실행
flutter run

# 특정 디바이스에서 실행
flutter run -d <device-id>

# 핫 리로드: 터미널에서 'r' 키 입력
# 핫 리스타트: 터미널에서 'R' 키 입력

# Android 빌드
flutter build apk

# Android 릴리즈 빌드
flutter build apk --release
```

### 테스트
```bash
# 전체 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/widget_test.dart
```

### 코드 품질
```bash
# 코드 분석
flutter analyze

# 코드 포맷팅
dart format .
```

## 아키텍처

### 프로젝트 구조
```
lib/
├── main.dart                           # 앱 진입점, Supabase 초기화, 인증 라우팅
├── models/
│   └── workout.dart                    # 운동 데이터 모델 (notes 필드 포함)
├── providers/
│   ├── auth_provider.dart              # 인증 상태 관리
│   └── workout_provider.dart           # 운동 상태 관리
├── services/
│   └── supabase_service.dart          # Supabase API 호출 (Auth 포함)
├── screens/
│   ├── home_screen.dart                # 메인 운동 목록 화면
│   ├── login_screen.dart               # 로그인 화면
│   ├── signup_screen.dart              # 회원가입 화면
│   └── workout_detail_screen.dart      # 운동 상세 화면
└── widgets/
    └── workout_list_item.dart         # 개별 운동 목록 아이템
```

### 주요 아키텍처 패턴

**상태 관리**: Provider 패턴 사용
- `WorkoutProvider`가 운동 상태와 비즈니스 로직 관리
- CRUD 작업 및 날짜 탐색을 위한 메서드 제공
- 데이터 변경 시 리스너에게 알림

**데이터 흐름**:
1. UI (screens/widgets) → Provider → Service → Supabase
2. Supabase → Service → Provider → UI (notifyListeners를 통해)

**데이터베이스**: Supabase PostgreSQL
- 테이블: `workout`
- 컬럼: id, name, weight, reps, sets, body_part, date
- `supabase_flutter` 패키지를 통해 접근

## 환경 설정

### 사전 요구사항
- Flutter SDK (>=3.1.3 <4.0.0)
- Supabase 계정 및 프로젝트

### 환경 변수
루트 디렉토리에 `.env.local` 파일 생성:
```
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

이 파일은 `main.dart`에서 `flutter_dotenv`를 사용하여 로드됩니다.

## 데이터베이스 스키마

### workouts 테이블 (Supabase)
```sql
CREATE TABLE workouts (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  exercise_name TEXT NOT NULL,
  workout_date TEXT NOT NULL,
  weight TEXT NOT NULL,
  reps TEXT NOT NULL,
  sets TEXT NOT NULL,
  body_part TEXT NOT NULL,
  notes TEXT,
  date TIMESTAMP WITH TIME ZONE NOT NULL
);
```

## 주요 의존성

- `supabase_flutter: ^2.5.0` - Supabase 클라이언트
- `provider: ^6.1.1` - 상태 관리
- `flutter_dotenv: ^5.1.0` - 환경 변수
- `intl: ^0.18.1` - 날짜 포맷팅 (한국어 로케일)

## 중요 참고사항

- **날짜 처리**: Supabase에서 날짜는 ISO 8601 형식으로 저장됩니다. 앱은 날짜 범위(하루의 시작부터 끝까지)로 운동을 필터링합니다.
- **모델 매핑**: Supabase는 snake_case (`body_part`)를 사용하고 Dart는 camelCase (`bodyPart`)를 사용합니다. 매핑은 `Workout.toMap()`과 `Workout.fromMap()`에서 처리됩니다.
- **한국어 로케일**: `intl`을 사용한 한국어 날짜 포맷팅의 경우, 초기화되지 않았다면 `intl/date_symbol_data_local.dart`를 import해야 할 수 있습니다.
- **에러 처리**: 모든 서비스 메서드에는 debug print가 포함된 try-catch 블록이 있습니다. 에러는 로깅되지만 현재 구현에서는 사용자에게 표시되지 않습니다.

## 새 기능 추가

새로운 운동 필드를 추가할 때:
1. `lib/models/workout.dart`의 `Workout` 모델 업데이트
2. Supabase 데이터베이스 스키마 업데이트
3. `toMap()`과 `fromMap()` 메서드 업데이트
4. `home_screen.dart`와 `workout_list_item.dart`의 UI 업데이트
5. 필요시 `supabase_service.dart`의 서비스 메서드 업데이트

## 변경 이력

### 2024-11-19 업데이트

#### 1. Supabase Auth 인증 기능 추가
- **로그인/회원가입**: 이메일/비밀번호 기반 인증
- **AuthProvider**: 인증 상태 관리 (`lib/providers/auth_provider.dart`)
- **로그인 화면**: `lib/screens/login_screen.dart`
- **회원가입 화면**: `lib/screens/signup_screen.dart`
- **인증 라우팅**: `AuthWrapper`로 로그인 상태에 따른 화면 전환
- **로그아웃**: 홈 화면 상단 로그아웃 버튼
- **세션 유지**: 자동 인증 상태 감지

#### 2. 운동 상세화면 추가
- **상세화면**: `lib/screens/workout_detail_screen.dart`
- **notes 필드**: Workout 모델에 운동방법상세 필드 추가
- **클릭 이동**: 운동명 클릭 시 상세화면으로 이동 (파란색 밑줄 링크 스타일)
- **상세 정보 표시**: 운동명, 날짜, 운동부위, 중량, 횟수, 세트, 운동방법상세

#### 3. UI 개선
- **아이콘 변경**: 상단 AppBar 로고를 핑크색 하트 아이콘으로 변경
- **글자 크기 조정**: "나의 운동 내역" 글자 크기를 20으로 축소 (My Awesome 24보다 작게)
- **목록 아이템**: 운동명 첫글자 동그라미 크기 축소 (48x48 → 32x32)
- **운동부위**: 지도 아이콘 제거

#### 4. 데이터베이스 스키마 변경
- `user_id` 컬럼 추가 (auth.users 참조)
- `notes` 컬럼 추가 (운동방법상세)

```sql
-- notes 컬럼 추가
ALTER TABLE workouts ADD COLUMN notes TEXT;

-- user_id 컬럼 추가 (이미 있다면 생략)
ALTER TABLE workouts ADD COLUMN user_id UUID REFERENCES auth.users(id);
```

### 2024-11-20 업데이트

#### 1. 웹 배포 설정
- **GitHub 저장소**: https://github.com/reactAndCode/third_flu_ex
- **Vercel 배포**: Flutter 웹 앱을 Vercel로 배포
- **정적 파일 배포**: build/web 폴더를 Git에 커밋하여 빌드 없이 배포
- **크로스 플랫폼 접근**: iPhone, iPad에서도 브라우저로 접근 가능

#### 2. 환경 변수 처리 개선
- **flutter_dotenv 제거**: 웹 빌드에서 런타임 파일 로딩 문제 해결
- **String.fromEnvironment 사용**: 컴파일 타임 환경 변수로 전환
- **기본값 설정**: 환경 변수가 없어도 기본값으로 작동
- **Vercel 환경 변수**: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY

#### 3. Git 설정
- **.gitignore 최적화**:
  - `.env` 파일 제외
  - `.md` 파일 제외 (CLAUDE.md는 예외)
  - `build/web` 폴더는 포함 (웹 배포용)
- **vercel.json**: 정적 파일 서빙 설정

#### 4. 배포 방식
```bash
# 웹 빌드
flutter build web --release

# Git 커밋 및 푸시
git add build/web
git commit -m "Deploy web build"
git push origin main

# Vercel 자동 배포
# GitHub 푸시 시 Vercel이 자동으로 재배포
```

#### 5. main.dart 변경사항
```dart
// 이전: dotenv 사용
await dotenv.load(fileName: '.env.local');
url: dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!

// 현재: 컴파일 타임 상수 사용
const String supabaseUrl = String.fromEnvironment(
  'NEXT_PUBLIC_SUPABASE_URL',
  defaultValue: 'https://uizoxtnvqisiicvcxgty.supabase.co',
);
```
