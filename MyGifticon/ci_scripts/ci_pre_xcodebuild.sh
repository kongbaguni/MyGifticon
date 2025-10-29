#!/bin/sh

echo "환경 변수에서 GoogleService-Info.plist 파일을 생성합니다..."

# 1. Base64로 인코딩된 환경 변수 값을 가져옵니다.
#    (App Store Connect에 입력했던 변수 이름과 동일해야 합니다.)
GOOGLE_SERVICE_INFO_BASE64_VALUE=$GOOGLE_SERVICE_INFO_BASE64

# 2. 변수 값이 비어있는지 확인합니다.
if [ -z "$GOOGLE_SERVICE_INFO_BASE64_VALUE" ]; then
  echo "오류: GOOGLE_SERVICE_INFO_BASE64 환경 변수가 설정되지 않았습니다."
  exit 1
fi

# 3. Base64 값을 디코딩하여 파일로 저장합니다.
#    ★★★★★ 중요 ★★★★★
#    파일이 저장될 경로를 실제 프로젝트 구조에 맞게 수정해야 합니다.
#    예: $CI_WORKSPACE/YourAppName/SupportingFiles/GoogleService-Info.plist

FILE_PATH="$CI_WORKSPACE/YourAppName/GoogleService-Info.plist"

echo "파일을 $FILE_PATH 경로에 생성합니다."

# Base64 디코딩 및 파일 생성
echo $GOOGLE_SERVICE_INFO_BASE64_VALUE | base64 --decode > $FILE_PATH

# 파일 생성 확인 (선택 사항)
if [ -f "$FILE_PATH" ]; then
  echo "GoogleService-Info.plist 파일 생성 성공."
else
  echo "오류: 파일 생성에 실패했습니다."
  exit 1
fi
