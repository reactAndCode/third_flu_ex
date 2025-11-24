# Flutter 설치 가이드 (Windows)

이 프로젝트를 로컬에서 빌드하려면 Flutter SDK가 필요합니다.

## 1. Flutter SDK 다운로드

### 방법 1: 수동 다운로드 (권장)
1. Flutter 공식 사이트 접속: https://docs.flutter.dev/get-started/install/windows
2. "Download Flutter SDK" 버튼 클릭
3. 최신 Stable 버전 다운로드 (flutter_windows_xxx-stable.zip)

### 방법 2: Git으로 클론
```bash
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```

## 2. Flutter SDK 설치

### 압축 해제
- 다운로드한 ZIP 파일을 `C:\flutter` 또는 `C:\src\flutter`에 압축 해제
- **주의**: `C:\Program Files\` 같은 권한이 필요한 경로는 피하세요

예시:
```
C:\flutter\
├── bin\
├── packages\
└── ...
```

## 3. 환경 변수 설정 (PATH)

### 방법 1: PowerShell 사용 (관리자 권한)
```powershell
# Flutter bin 경로를 시스템 PATH에 추가
[System.Environment]::SetEnvironmentVariable(
    "Path",
    [System.Environment]::GetEnvironmentVariable("Path", "User") + ";C:\flutter\bin",
    "User"
)
```

### 방법 2: GUI로 설정
1. `Win + R` → `sysdm.cpl` 입력 → 엔터
2. "고급" 탭 → "환경 변수" 클릭
3. "사용자 변수" 섹션에서 "Path" 선택 → "편집" 클릭
4. "새로 만들기" → `C:\flutter\bin` 입력
5. "확인" 클릭으로 모든 창 닫기

### 방법 3: Git Bash에서 임시 설정
```bash
# 현재 세션에서만 유효 (터미널 닫으면 사라짐)
export PATH="$PATH:/c/flutter/bin"
```

## 4. Flutter 설치 확인

새로운 터미널을 열고 다음 명령어 실행:

```bash
# Flutter 버전 확인
flutter --version

# 설치 상태 점검
flutter doctor

# 웹 지원 활성화
flutter config --enable-web
```

## 5. 추가 도구 설치

Flutter doctor 실행 후 누락된 항목 설치:

### Chrome 설치 (웹 개발용)
- https://www.google.com/chrome/ 에서 다운로드

### Visual Studio Code (선택사항)
```bash
# Flutter 및 Dart 확장 설치
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

## 6. 프로젝트 빌드

Flutter 설치 완료 후:

```bash
# 프로젝트 디렉토리로 이동
cd C:\work\myDev\third_flu_ex

# 의존성 설치
flutter pub get

# 웹 빌드 (릴리즈 모드)
flutter build web --release

# 개발 서버 실행
flutter run -d chrome
```

## 문제 해결

### "flutter: command not found" 에러
- 터미널을 재시작해보세요 (PATH 변경 적용)
- PATH 설정이 올바른지 확인:
  ```bash
  echo $PATH | grep flutter
  ```

### Flutter doctor 경고
- Android SDK 없음: 모바일 앱 개발하지 않으면 무시 가능
- Visual Studio 없음: Windows 앱 개발하지 않으면 무시 가능
- Chrome 없음: 웹 개발 시 필수 (설치 필요)

### 권한 오류
- 관리자 권한으로 터미널 실행
- 또는 사용자 폴더(`C:\Users\사용자명\flutter`)에 설치

## 빠른 시작

설치 후 바로 빌드:

```bash
# 웹 빌드
flutter build web --release

# Git에 추가 및 커밋
git add build/web
git commit -m "build: Update web build"
git push origin main
```

## 참고 자료

- Flutter 공식 문서: https://docs.flutter.dev/
- Flutter 설치 가이드: https://docs.flutter.dev/get-started/install/windows
- Flutter 웹 가이드: https://docs.flutter.dev/platform-integration/web
