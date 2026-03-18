#!/bin/bash

# Week02 학습용 CLI 명령어 모음
# 복붙해서 실행 가능한 형태로 정리

# ═══════════════════════════════════════════════════════════════════
# 1. v1-basic 빌드 및 실행
# ═══════════════════════════════════════════════════════════════════

# 1-1. v1 이미지 빌드
docker build -t myapp:v1 ./week02-dockerfile/v1-basic

# 1-2. 빌드된 이미지 확인
docker images myapp:v1

# 1-3. 이미지 레이어 확인 (Dockerfile 각 명령어가 레이어가 됨)
docker history myapp:v1

# 1-4. v1 컨테이너 실행
docker run -d -p 8080:8080 --name myapp-v1 myapp:v1

# 1-5. 컨테이너 로그 확인
docker logs myapp-v1

# 1-6. 컨테이너가 정상 작동하는지 확인
curl http://localhost:8080/api/health 2>/dev/null || echo "앱이 아직 시작 중입니다"

# 1-7. 컨테이너 내부에서 실행 사용자 확인 (root일 것)
docker exec myapp-v1 whoami

# 1-8. 컨테이너 정지 및 삭제
docker stop myapp-v1 && docker rm myapp-v1


# ═══════════════════════════════════════════════════════════════════
# 2. v2-optimized 빌드 및 캐시 비교
# ═══════════════════════════════════════════════════════════════════

# 2-1. v2 이미지 빌드 (첫 빌드: 모든 레이어 새로 생성)
docker build -t myapp:v2 ./week02-dockerfile/v2-optimized
# 출력에 주목:
#   Step 1/8 : FROM eclipse-temurin:17-jdk-alpine
#   Step 2/8 : RUN addgroup ...
#   Step 3/8 : WORKDIR /app
#   Step 4/8 : COPY pom.xml pom.xml
#   Step 5/8 : RUN mvn dependency:resolve
#   ...

# 2-2. 이미지 레이어 확인
docker history myapp:v2

# 2-3. v2 컨테이너 실행
docker run -d -p 8081:8080 --name myapp-v2 myapp:v2

# 2-4. non-root user 확인 (appuser일 것)
docker exec myapp-v2 whoami

# 2-5. 컨테이너 정지
docker stop myapp-v2 && docker rm myapp-v2

# 2-6. 소스 코드 수정 후 재빌드 (캐시 효과 확인)
# v2-optimized/src/main/java/.../Application.java 파일을 열어서 코드 한 줄 수정
# 그 다음 아래 명령어 실행
docker build -t myapp:v2-refresh ./week02-dockerfile/v2-optimized
# 출력에 주목:
#   Step 1/8 : FROM eclipse-temurin:17-jdk-alpine
#   ...
#   Step 5/8 : RUN mvn dependency:resolve ... CACHED  ← 캐시 재사용!
#   Step 6/8 : COPY src src                            ← 여기부터 새 빌드
#   Step 7/8 : RUN mvn clean package ...
#
# v1과 비교하면:
#   v1: 전체 재빌드 (수 분)
#   v2: 소스 레이어부터 재빌드 (수 초)


# ═══════════════════════════════════════════════════════════════════
# 3. v3-multistage 빌드 및 이미지 크기 비교
# ═══════════════════════════════════════════════════════════════════

# 3-1. v3 이미지 빌드
docker build -t myapp:v3 ./week02-dockerfile/v3-multistage

# 3-2. 이미지 크기 비교 (v1, v2, v3)
docker images myapp
# 예상 결과:
# REPOSITORY   TAG      SIZE
# myapp        v1       450MB  ← JDK 포함
# myapp        v2       450MB  ← JDK 포함 (캐시만 개선)
# myapp        v3       150MB  ← JRE만 포함 (67% 축소!)

# 3-3. v3 컨테이너 실행
docker run -d -p 8082:8080 --name myapp-v3 myapp:v3

# 3-4. non-root user 확인
docker exec myapp-v3 whoami  # appuser 출력

# 3-5. 컨테이너 정지
docker stop myapp-v3 && docker rm myapp-v3


# ═══════════════════════════════════════════════════════════════════
# 4. 심화: 빌드 캐시 전략 테스트
# ═══════════════════════════════════════════════════════════════════

# 4-1. --no-cache 플래그로 캐시 무시하고 전체 재빌드
# (모든 레이어를 다시 생성, 시간 소요)
docker build --no-cache -t myapp:v2-no-cache ./week02-dockerfile/v2-optimized

# 4-2. 빌드 스텝 중 캐시 확인
# docker build 출력에서 "CACHED" 메시지 찾기
# 캐시가 있으면: Step 5/8 : RUN mvn ... CACHED
# 캐시 없으면: Step 5/8 : RUN mvn ...

# 4-3. pom.xml 수정 후 재빌드 (의존성 레이어 캐시 무효화)
# vi ./week02-dockerfile/v2-optimized/pom.xml (버전이나 dependency 수정)
# 그 다음:
docker build -t myapp:v2-pom-changed ./week02-dockerfile/v2-optimized
# 출력 확인:
#   Step 5/8 : RUN mvn dependency:resolve      ← CACHED 없음 (pom.xml 변경됨)
#   Step 7/8 : RUN mvn clean package ...       ← 새 빌드


# ═══════════════════════════════════════════════════════════════════
# 5. 청소 (모든 myapp 이미지 및 컨테이너 삭제)
# ═══════════════════════════════════════════════════════════════════

# 5-1. 실행 중인 myapp 컨테이너 모두 정지
docker stop $(docker ps -q --filter "ancestor=myapp*" 2>/dev/null) 2>/dev/null || true

# 5-2. 모든 myapp 컨테이너 삭제
docker rm $(docker ps -aq --filter "ancestor=myapp*" 2>/dev/null) 2>/dev/null || true

# 5-3. 모든 myapp 이미지 삭제
docker rmi $(docker images -q myapp 2>/dev/null) 2>/dev/null || true

# 5-4. 확인
docker images myapp 2>/dev/null || echo "✅ 모든 myapp 이미지 삭제 완료"


# ═══════════════════════════════════════════════════════════════════
# 6. 디버깅 및 심화 학습
# ═══════════════════════════════════════════════════════════════════

# 6-1. 특정 이미지의 모든 정보 확인
docker inspect myapp:v3 | less

# 6-2. 실행 중인 컨테이너의 상세 정보 확인
docker inspect myapp-v3

# 6-3. 컨테이너 내부 파일시스템 확인
docker exec -it myapp-v3 ls -la /app

# 6-4. 컨테이너 내부에서 대화형 쉘 접속
docker exec -it myapp-v3 /bin/sh
# 내부에서:
#   whoami                # appuser 출력
#   java -version         # JRE 버전 확인
#   ls -la /app           # 파일 확인
#   exit                  # 종료

# 6-5. 이미지 빌드 상세 로그 확인
docker build --progress=plain -t myapp:v3 ./week02-dockerfile/v3-multistage 2>&1 | tee build.log

# 6-6. 특정 레이어의 변경사항 확인
docker history --no-trunc myapp:v3

# ═══════════════════════════════════════════════════════════════════
# 팁: 한 번에 모든 단계 실행하기
# ═══════════════════════════════════════════════════════════════════

# 아래를 복붙하면 v1, v2, v3를 차례로 빌드하고 크기 비교
set -e
echo "=== v1 빌드 ==="
docker build -t myapp:v1 ./week02-dockerfile/v1-basic
echo ""
echo "=== v2 빌드 ==="
docker build -t myapp:v2 ./week02-dockerfile/v2-optimized
echo ""
echo "=== v3 빌드 ==="
docker build -t myapp:v3 ./week02-dockerfile/v3-multistage
echo ""
echo "=== 크기 비교 ==="
docker images myapp
