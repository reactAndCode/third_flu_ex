# Changelog

이 프로젝트의 주요 변경사항을 기록합니다.

## [1.5.0] - 2024-11-21 (로컬 변경사항 - 미배포)

### Added
- 하단 네비게이션 바 (Bottom Navigation Bar):
  - 5개 메뉴: 홈, 운동, 대시보드, 채팅, My
  - 다크 그린 배경 (`#0F1D0F`)
  - 네온 그린 선택 색상 (`#00E676`)
  - 운동 탭에서만 플로팅 액션 버튼(+한개) 표시
  - 각 탭별 플레이스홀더 화면 구현
- 새로운 이미지 리소스:
  - `cuteCat_tread2.png` - 귀여운 고양이 러닝머신 이미지
  - `cute_cat_treadmill.png` - 고양이 운동 이미지
  - `bottomMemnu.png` - 하단 메뉴 참고 이미지

### Changed
- 운동 사진 표시 개선:
  - 이미지 fit 모드: `BoxFit.cover` → `BoxFit.contain`
  - 이미지 높이: 150px → 200px
  - 이미지 너비: `double.infinity`로 설정하여 전체 너비 사용
  - 비율 유지하면서 잘림 없이 표시
- 이미지 파일명 규칙 개선:
  - 이전: `{workoutId}_{timestamp}.jpg`
  - 현재: `{YYYYMMDDHHmmss}_{sequence}.png`
  - 시퀀스: photo1=a, photo2=b, photo3=c
  - 예시: `20241121143025_a.png`
- APK 파일명 변경:
  - `my-awesome-workout-v1.x.apk` → `workouts_v1_x.apk`
- 홈 화면 구조 개선:
  - `_buildBody()` 메서드로 탭별 컨텐츠 분리
  - 운동 목록은 인덱스 1(운동 탭)에서만 표시

### Technical Details
- Bottom Navigation Bar: `BottomNavigationBarType.fixed`
- 현재 탭 인덱스: `_currentIndex` 상태로 관리
- 조건부 FAB 렌더링: `_currentIndex == 1`일 때만 표시
- 각 탭 전환 시 `setState()`로 UI 업데이트

### Notes
- 이 버전은 로컬에서만 변경되었으며 아직 GitHub에 푸시되지 않음
- 빌드 및 배포 필요

## [1.4.0] - 2024-11-20

### Added
- 운동 사진 업로드 기능:
  - 운동 수정 화면에서 최대 2장의 사진 업로드 가능
  - Supabase Storage 연동 (bucket: `my-real-estate`, folder: `myUp33`)
  - 이미지 선택 시 실시간 미리보기
  - 업로드 중 로딩 인디케이터 표시
- 운동 상세 화면 사진 표시:
  - 업로드된 운동 사진을 상세 화면에서 확인 가능
  - 2장의 사진을 나란히 표시
  - 둥근 모서리 디자인 적용
- 사용자 정보 표시:
  - AppBar에 로그인한 사용자 이메일의 처음 5글자 표시
  - "My Awesome" 타이틀 아래에 작은 회색 글씨로 표시

### Changed
- 데이터베이스 스키마 업데이트:
  - `photo_url_1` 컬럼 추가 (TEXT 타입)
  - `photo_url_2` 컬럼 추가 (TEXT 타입)
- Workout 모델 확장:
  - `photoUrl1`, `photoUrl2` 필드 추가
  - `toMap()`, `fromMap()`, `copyWith()` 메서드 업데이트
- 수정 다이얼로그 개선:
  - `StatefulBuilder` 사용으로 이미지 선택 시 UI 즉시 업데이트
  - 2개의 사진 선택 버튼 추가
  - 선택된 이미지 또는 기존 이미지 미리보기

### Technical Details
- 새로운 패키지:
  - `image_picker: ^1.0.7` - 갤러리에서 이미지 선택
- 새로운 서비스 메서드:
  - `SupabaseService.uploadWorkoutImage()` - Supabase Storage에 이미지 업로드
- 파일 명명 규칙: `{workoutId}_{timestamp}.jpg`
- 이미지 데이터 타입: `Uint8List` (dart:typed_data)

## [1.1.0] - 2024-11-20

### Added
- 웹 배포 지원: Vercel을 통한 Flutter 웹 앱 배포
- 크로스 플랫폼 접근: iPhone, iPad에서 브라우저로 접근 가능
- GitHub 저장소 연동: https://github.com/reactAndCode/third_flu_ex
- 정적 파일 배포: build/web 폴더를 Git에 커밋하여 빌드 없이 배포
- vercel.json 설정 파일 추가

### Changed
- 환경 변수 처리 방식 개선:
  - `flutter_dotenv` 제거하고 `String.fromEnvironment` 사용
  - 런타임 파일 로딩에서 컴파일 타임 상수로 전환
  - 기본값 설정으로 환경 변수 없이도 작동 가능
- Git 설정 최적화:
  - `.env` 파일 제외
  - `.md` 파일 제외 (CLAUDE.md, CHANGELOG.md는 예외)
  - `build/web` 폴더는 포함 (웹 배포용)

### Fixed
- 웹 빌드에서 `.env.local` 파일 로딩 실패 문제 해결
- GitHub Pages 경로 문제 해결 (Vercel로 마이그레이션)

## [1.0.0] - 2024-11-19

### Added
- Supabase Auth 인증 기능:
  - 이메일/비밀번호 기반 로그인 및 회원가입
  - `AuthProvider`를 통한 인증 상태 관리
  - 로그인 화면 (`login_screen.dart`)
  - 회원가입 화면 (`signup_screen.dart`)
  - `AuthWrapper`로 자동 라우팅
  - 로그아웃 버튼
  - 세션 자동 유지
- 운동 상세 화면 (`workout_detail_screen.dart`):
  - 운동명 클릭 시 상세 정보 표시
  - 파란색 밑줄 링크 스타일
  - 운동방법상세(notes) 필드 표시
- 데이터베이스 스키마:
  - `user_id` 컬럼 추가 (auth.users 참조)
  - `notes` 컬럼 추가 (운동방법상세)

### Changed
- UI 개선:
  - 앱 로고를 핑크색 하트 아이콘으로 변경
  - "나의 운동 내역" 글자 크기 축소 (24 → 20)
  - 운동명 첫글자 동그라미 크기 축소 (48x48 → 32x32)
  - 운동부위 지도 아이콘 제거

### Removed
- 불필요한 UI 버튼 제거:
  - 5개일력 버튼
  - 여러개 버튼
  - 리스트형표시 버튼
  - 카드형표시 버튼

## [0.1.0] - 2024-11-14

### Added
- 초기 프로젝트 생성
- Flutter 기반 운동 관리 앱 기본 구조
- Supabase 데이터베이스 연동
- Provider 상태 관리
- 운동 CRUD 기능:
  - 운동 추가 (운동명, 중량, 횟수, 세트, 운동부위)
  - 운동 조회 (날짜별)
  - 운동 수정
  - 운동 삭제
- 날짜 탐색 기능 (이전/다음 날짜)
- Android APK 빌드
- 앱 이름: "윤상민"
- 한국어 날짜 표시 (요일 포함)

### Technical Details
- Flutter SDK: >=3.1.3 <4.0.0
- 주요 패키지:
  - supabase_flutter: ^2.5.0
  - provider: ^6.1.1
  - intl: ^0.18.1
- 데이터베이스: Supabase PostgreSQL
- 상태 관리: Provider 패턴
