# Week02 v3-multistage — 멀티스테이지 빌드
#
# 특징:
#   - 스테이지 1 (builder): JDK로 빌드 → jar 생성
#   - 스테이지 2 (runtime): JRE만 사용 → jar 실행
#   - 빌드 도구를 최종 이미지에서 제거
#
# 개선 효과:
#   - 이미지 크기: 450MB (v1/v2) → 150MB (v3) = 67% 축소
#   - 보안: 빌드 도구 없음 → 공격 표면 최소화
#   - 배포 시간: 이미지 다운로드 시간 단축
#
# ✅ v2 대비 개선점:
#   1. JDK → JRE로 변경해서 크기 단축
#   2. COPY --from=builder로 빌드 결과물만 복사
#   3. 보안 강화: 불필요한 컴파일러/도구 제거
#
# 멀티스테이지 원리:
#   1. AS builder: 첫 스테이지에 이름 붙이기
#   2. FROM ... AS runtime: 새 스테이지 시작 (이전 레이어 모두 무시)
#   3. COPY --from=builder: builder 스테이지의 파일 참조

# ═══════════════════════════════════════════════════════════════════
# 스테이지 1: 빌드 환경 (builder)
# ═══════════════════════════════════════════════════════════════════
FROM eclipse-temurin:17-jdk-alpine AS builder

# non-root user 생성
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# 의존성 파일 복사
COPY pom.xml pom.xml

# 의존성 다운로드
RUN mvn dependency:resolve

# 소스 코드 복사
COPY src src

# 빌드 (jar 생성)
RUN mvn clean package -DskipTests

# 이 시점의 파일 시스템:
#   /app/target/app.jar (생성됨)
#   /app/pom.xml
#   /app/src/
#   /root/.m2/  (Maven 캐시, 불필요)


# ═══════════════════════════════════════════════════════════════════
# 스테이지 2: 런타임 환경 (runtime)
# ═══════════════════════════════════════════════════════════════════
FROM eclipse-temurin:17-jre-alpine

# non-root user 생성
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# builder 스테이지에서 jar 파일만 복사
# 문법: COPY --from=[스테이지이름] [원본경로] [대상경로]
# 효과: builder의 /app/target/app.jar를 현재 이미지의 /app/app.jar로 복사
#       나머지 파일(pom.xml, src/, Maven 캐시)은 복사되지 않음
COPY --from=builder /app/target/app.jar ./app.jar

# 최종 이미지에 포함된 것:
#   ✅ eclipse-temurin:17-jre-alpine (120MB)
#   ✅ /app/app.jar (30MB)
#   ❌ JDK, Maven, 소스 코드 등 제거됨

EXPOSE 8080

# non-root user로 실행
USER appuser

# 컨테이너 시작 시 jar 실행
CMD ["java", "-jar", "app.jar"]

# ═══════════════════════════════════════════════════════════════════
# 빌드 및 실행 명령어
# ═══════════════════════════════════════════════════════════════════
#
# 빌드:
#   docker build -t myapp:v3 ./v3-multistage
#
# 실행:
#   docker run -d -p 8080:8080 myapp:v3
#
# 이미지 크기 확인:
#   docker images myapp:v3
#   # 약 150MB 출력
#
# 실행 사용자 확인:
#   docker run --rm myapp:v3 whoami
#   # appuser 출력 (root이 아님)
