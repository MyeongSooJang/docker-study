# Week02 v2-optimized — 레이어 캐시 최적화
#
# 특징:
#   - 의존성 파일(pom.xml)을 먼저 복사 → 캐시 분리
#   - 소스 코드(src)는 나중에 복사 → 자주 변경되는 것은 마지막
#   - non-root user 추가 (보안)
#
# 개선 효과:
#   - 소스 변경 시 빌드 시간: 수 분 → 수 초로 단축
#   - 의존성 레이어 캐시 재사용으로 반복 빌드 시간 단축
#
# ✅ v1 대비 개선점:
#   1. pom.xml → 의존성 설치 → src → 컴파일 순서로 분리
#   2. non-root user(appuser) 추가로 보안 강화
#
# ❌ 남은 문제:
#   - 여전히 JDK가 최종 이미지에 포함 (v3에서 해결)

FROM eclipse-temurin:17-jdk-alpine

# non-root user 생성
# -m: 홈 디렉토리 생성
# -u 1000: UID 1000 지정 (docker desktop의 기본값)
# -G appuser: appuser 그룹에 속하게 함
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Step 1: 의존성 파일만 먼저 복사
# 캐시 활용 전략: pom.xml이 변경되지 않으면 이 다음 RUN을 캐시에서 재사용
COPY pom.xml pom.xml

# Step 2: 의존성만 다운로드
# Maven wrapper를 사용하는 경우: ./mvnw dependency:resolve
# 표준 Maven의 경우: mvn dependency:resolve
RUN mvn dependency:resolve

# Step 3: 소스 코드 복사 (자주 변경되므로 마지막)
# 캐시 전략: src가 변경되면 이 단계부터 재빌드
COPY src src

# Step 4: 빌드
# 이 전 단계들이 캐시되면, 소스 변경 시에만 이 단계부터 재실행
RUN mvn clean package -DskipTests

EXPOSE 8080

# non-root user로 실행
USER appuser

# 컨테이너 시작 시 jar 실행
CMD ["java", "-jar", "target/app.jar"]
