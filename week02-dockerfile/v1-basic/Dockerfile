# Week02 v1-basic — 기본 Dockerfile (비효율적)
#
# 특징:
#   - 모든 파일을 한 번에 복사
#   - 소스 코드 변경 시마다 의존성 재설치
#   - 빌드 도구(JDK)가 최종 이미지에 포함
#
# 학습 목표:
#   - Dockerfile 기본 문법 학습 (FROM, COPY, RUN, CMD)
#   - 이 버전의 문제를 인식한 후 v2, v3로 개선
#
# ❌ 문제점:
#   1. 소스 1줄 변경 → 의존성부터 다시 설치 (수 분)
#   2. 최종 이미지에 JDK 포함 (불필요, 보안 위협)

FROM eclipse-temurin:17-jdk-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 모든 파일을 한 번에 복사 (문제: pom.xml만 변경해도 캐시 무효화)
COPY . .

# Maven으로 빌드 (모든 의존성 다운로드 + 컴파일)
# 문제: 소스 코드 변경 시마다 이 명령이 다시 실행됨
RUN mvn clean package -DskipTests

# 포트 선언 (실제 포트 포워딩은 docker run -p로)
EXPOSE 8080

# 컨테이너 시작 시 jar 실행
# 주의: root 사용자로 실행됨 (보안 문제)
CMD ["java", "-jar", "target/app.jar"]
