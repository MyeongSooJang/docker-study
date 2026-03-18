# Week02 — Dockerfile 작성 & 이미지 최적화

---

## 📌 이 주의 목표

### 🎯 실무 레벨
- Dockerfile의 각 명령어(FROM, COPY, RUN, CMD 등)를 이해하고 직접 작성할 수 있다
- 이미지 레이어 캐시 원리를 이해해 빌드 시간을 단축하는 구조로 작성할 수 있다
- 멀티스테이지 빌드로 최종 이미지 크기를 최소화할 수 있다
- 컨테이너 보안 원칙(non-root user, 최소 권한)을 적용해 Dockerfile을 작성할 수 있다

### 🎤 면접 레벨
- "Dockerfile 명령어 하나가 왜 레이어 하나를 만드나"를 설명할 수 있다
- "레이어 순서를 왜 신경써야 하나"를 캐시 무효화로 설명할 수 있다
- "멀티스테이지 빌드가 뭐고 왜 쓰는가"를 구체적으로 설명할 수 있다
- "Dockerfile에서 non-root user를 설정하는 이유"를 보안 관점으로 설명할 수 있다

---

## 📚 학습 구조

| 순서 | 개념 | 학습 목표 | 지금 모르면 막히는 이유 | 실습 범위 |
|------|------|---------|------------------|----------|
| **1단계** | Dockerfile 기본 문법 | FROM, RUN, COPY, CMD의 역할 이해 | Dockerfile을 못 읽음 → 문제 해결 불가 | v1-basic 파일 작성 |
| **2단계** | 레이어 캐시 최적화 | 자주 변경되는 것은 나중에 복사 | 매번 전체 재빌드 → 배포 시간 수 분 → 실무 불편 | v2-optimized 최적화 |
| **3단계** | 멀티스테이지 빌드 | 빌드 단계와 런타임 단계 분리 | 빌드 도구가 최종 이미지에 남음 → 보안 위협, 용량 낭비 | v3-multistage 적용 |
| **4단계** | 베스트 프랙티스 | non-root user, 최소 권한, 헬스체크 | 컨테이너를 root로 실행 → 보안 침해 시 전체 시스템 영향 | 모든 버전에 적용 |

---

## 🚀 실습 액션 플랜

### Phase 1: 기본 Dockerfile 작성 (과제 1~3)

**목표**: Dockerfile 문법을 이해하고 직접 이미지 빌드하기

| 과제 | 주제 | 학습 명령어 | 배우는 것 |
|------|------|---------|---------|
| **과제 1** | v1-basic 이해하기 | `docker build -t myapp:v1 ./v1-basic` | Dockerfile 각 명령어의 역할 |
| **과제 2** | 레이어 확인하기 | `docker history myapp:v1` | Dockerfile 1줄 = 이미지 레이어 1개 |
| **과제 3** | 컨테이너 실행 후 동작 확인 | `docker run -d -p 8080:8080 myapp:v1` | 빌드된 이미지가 정상 동작하는지 검증 |

### Phase 2: 캐시 최적화 (과제 4~6)

**목표**: 빌드 시간을 단축하는 레이어 구조 이해하기

| 과제 | 주제 | 비교 명령어 | 배우는 것 |
|------|------|---------|---------|
| **과제 4** | v1과 v2 Dockerfile 비교 | `diff v1-basic/Dockerfile v2-optimized/Dockerfile` | COPY 순서가 캐시에 영향 주는 방식 |
| **과제 5** | v2로 빌드하고 캐시 확인 | `docker build --no-cache -t myapp:v2 ./v2-optimized` | `--no-cache` 플래그의 의미 (모든 레이어 재빌드) |
| **과제 6** | 캐시 효율성 비교 | 소스 코드만 변경 후 재빌드 | v1은 npm install 다시, v2는 건너뜀 (수 분 vs 수 초) |

### Phase 3: 멀티스테이지 빌드 (과제 7~9)

**목표**: 빌드 환경과 런타임 환경 분리로 이미지 크기 축소

| 과제 | 주제 | 명령어 | 배우는 것 |
|------|------|--------|---------|
| **과제 7** | v1, v2, v3 이미지 크기 비교 | `docker images \| grep myapp` | 멀티스테이지로 80%+ 크기 감소 |
| **과제 8** | v3 Dockerfile 분석 | `cat v3-multistage/Dockerfile \| grep -E "^(FROM\|AS\|COPY --from)"` | `COPY --from=builder` 의미 |
| **과제 9** | 보안 검증: root vs non-root | `docker exec myapp whoami` 또는 `docker inspect myapp` | 컨테이너 실행 사용자 확인 |

---

## ✅ 학습 체크리스트

### 실습 완료 체크

- [ ] 과제 1: v1-basic 빌드 성공 + 컨테이너 정상 실행
- [ ] 과제 2: `docker history myapp:v1` 에서 5개 이상 레이어 확인
- [ ] 과제 3: http://localhost:8080 에서 앱 정상 동작 확인
- [ ] 과제 4: v1과 v2의 Dockerfile 차이점 (COPY 순서) 파악
- [ ] 과제 5: `--no-cache` 플래그로 모든 레이어 재빌드 확인
- [ ] 과제 6: 소스 코드만 수정 후 v2는 빠르게 재빌드되는 것 확인 (v1은 느림)
- [ ] 과제 7: `docker images` 에서 v1, v2, v3 크기 비교 (v3가 가장 작음)
- [ ] 과제 8: v3의 `COPY --from=builder` 라인 찾아서 의미 설명
- [ ] 과제 9: 실행 중인 컨테이너에서 `whoami` 명령어로 root가 아님 확인

### 개념 이해 체크 (면접 대비)

- [ ] "Dockerfile의 각 명령어(FROM, COPY, RUN, CMD)가 뭔가"를 설명할 수 있다
- [ ] "왜 COPY 순서를 신경써야 하나"를 캐시 무효화로 설명할 수 있다
- [ ] "멀티스테이지 빌드가 왜 필요한가"를 이미지 크기 + 보안 관점으로 설명할 수 있다
- [ ] "non-root user는 왜 필요한가"를 보안 침해 시나리오로 설명할 수 있다
- [ ] "package.json을 먼저 복사하고 source code는 나중에 복사하는 이유"를 설명할 수 있다

---

## 📖 학습 자료

### Dockerfile 명령어 완벽 가이드

```dockerfile
# FROM — 베이스 이미지 지정 (반드시 첫 줄)
# 역할: 어떤 OS/런타임을 기반으로 시작할 것인지 지정
# 선택 기준:
#   - eclipse-temurin:17-jre-alpine  ← 경량 JRE (이 프로젝트 선택)
#   - eclipse-temurin:17-jdk-alpine  ← 빌드 시에만 필요 (멀티스테이지의 builder)
#   - ubuntu:22.04                    ← 크기 크지만 자유도 높음 (학습용)
FROM eclipse-temurin:17-jre-alpine

# WORKDIR — 컨테이너 내 작업 디렉토리 지정
# 역할: 이 이후 RUN, COPY, CMD 명령어들이 실행되는 디렉토리
# 팁: cd /app 과 비슷하지만, WORKDIR은 레이어를 만들지 않음
WORKDIR /app

# COPY — 호스트 파일을 컨테이너로 복사
# 역할: Dockerfile 있는 디렉토리에서 지정된 파일을 컨테이너로 복사
# 문법: COPY [호스트경로] [컨테이너경로]
# 주의: 자주 변경되는 파일은 마지막에 복사 (캐시 무효화 방지)
COPY pom.xml pom.xml
COPY src src

# RUN — 컨테이너 내에서 명령어 실행
# 역할: Dockerfile 빌드 중에 실행 (컨테이너 시작 후가 아니라 빌드 시)
# 레이어 생성: 예, RUN은 항상 새 레이어 생성
# 최적화: 여러 RUN을 연결하면 1개 레이어로 통합 가능
#   ❌ RUN apt-get update
#   ❌ RUN apt-get install -y curl
#   ✅ RUN apt-get update && apt-get install -y curl
RUN mvn clean package

# EXPOSE — 컨테이너가 리스닝할 포트 선언 (실제 바인드 X)
# 역할: "이 컨테이너는 이 포트에서 리스닝합니다"라는 문서화 목적
# 실제 포트 포워딩은 docker run -p 로 한다
# 문법: EXPOSE [포트번호]
EXPOSE 8080

# USER — 컨테이너 실행 사용자 지정
# 역할: 컨테이너 프로세스를 이 사용자로 실행
# 보안: root 사용자로 실행하면 침해 시 전체 시스템이 위험
# 팁: RUN 명령어로 미리 사용자 생성 필요
# 예: RUN useradd -m -u 1000 appuser && USER appuser
USER appuser

# CMD — 컨테이너 시작 시 실행할 명령어 (기본 명령어)
# 역할: docker run [이미지] 할 때 자동 실행되는 명령어
# 문법: CMD ["실행파일", "arg1", "arg2"]  (권장 - JSON 형식)
#       CMD 명령어 arg1 arg2             (쉘 형식, 비권장)
# 주의: CMD는 docker run 의 뒤에 나오는 명령어로 오버라이드 가능
#   docker run myapp              ← CMD 실행
#   docker run myapp bash         ← bash 실행 (CMD 무시)
CMD ["java", "-jar", "target/app.jar"]
```

---

## 🔄 Before / After 패턴

### 패턴 1 — 레이어 캐시 최적화

**❌ v1-basic (비효율적)**
```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY . .               # ← 모든 파일을 한 번에 복사
RUN mvn clean package  # ← 의존성 + 소스코드 함께 빌드
EXPOSE 8080
CMD ["java", "-jar", "target/app.jar"]
```

**문제**: 소스 코드 한 줄만 바꿔도 mvn clean package가 다시 실행됨 (수 분 소요)

**원인**: COPY . . 이 변경되면, 그 다음 RUN 레이어 캐시가 무효화됨

**효과**: 빌드 시간이 매번 수 분 (의존성 다운로드 + 전체 컴파일)

---

**✅ v2-optimized (최적화됨)**
```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY pom.xml pom.xml         # ← 의존성 파일만 먼저 복사
RUN mvn dependency:resolve   # ← 의존성만 다운로드
COPY src src                 # ← 소스코드는 나중에 복사
RUN mvn clean package
EXPOSE 8080
CMD ["java", "-jar", "target/app.jar"]
```

**개선 이유**:
- pom.xml이 변경되지 않으면, RUN mvn dependency:resolve 는 캐시 재사용
- 소스 코드만 바뀐 경우, COPY src 이후부터만 재빌드

**개선 효과**:
- 첫 빌드: 수 분 (의존성 다운로드 포함)
- 소스 변경 후 재빌드: 수 초 (컴파일만)
- **속도 개선: ~90% 단축**

---

### 패턴 2 — 멀티스테이지 빌드

**❌ 단일 스테이지 (보안 + 용량 문제)**
```dockerfile
FROM eclipse-temurin:17-jdk-alpine  # ← JDK 전체 (약 400MB)
WORKDIR /app
COPY . .
RUN mvn clean package
EXPOSE 8080
CMD ["java", "-jar", "target/app.jar"]
```

**문제**:
- JDK, Maven, 컴파일 중간 파일이 모두 최종 이미지에 포함
- 보안: 빌드 도구가 있으면 공격자가 소스 재컴파일 가능
- 용량: 불필요한 도구로 인한 저장소 용량 낭비

**최종 이미지 크기**: ~450MB

---

**✅ 멀티스테이지 (최적화 + 보안)**
```dockerfile
# 스테이지 1: 빌드
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY pom.xml pom.xml
RUN mvn dependency:resolve
COPY src src
RUN mvn clean package -DskipTests

# 스테이지 2: 런타임 (빌드 결과물만 복사)
FROM eclipse-temurin:17-jre-alpine  # ← JRE만 (약 120MB)
WORKDIR /app
COPY --from=builder /app/target/app.jar ./app.jar
EXPOSE 8080
USER appuser
CMD ["java", "-jar", "app.jar"]
```

**개선 이유**:
- `AS builder`: 첫 번째 스테이지를 "builder"라고 이름 붙임
- `COPY --from=builder`: builder 스테이지에서만 빌드 결과물을 가져옴
- 두 번째 스테이지: JRE만으로 최소화

**개선 효과**:
- 최종 이미지 크기: 150MB
- **크기 감소: ~67% 축소**
- 보안: 빌드 도구 없음 → 공격 표면 최소화

---

### 패턴 3 — 보안: non-root user

**❌ root 사용자로 실행**
```dockerfile
# USER 지정 없음 = root로 실행
FROM alpine
RUN apk add --no-cache curl
CMD ["curl", "http://example.com"]
```

**위험성**:
- 컨테이너 안에서 보안 취약점 발생 시, 공격자가 전체 호스트 시스템에 접근 가능
- 예: 컨테이너 탈출(container escape) 시 root 권한 으로 호스트 제어

**시나리오**:
```
호스트: /root/db-password.txt (민감 정보)
공격자: 컨테이너 탈출 → root 권한 → /root/db-password.txt 읽음
결과: 데이터베이스 침해
```

---

**✅ non-root 사용자로 실행**
```dockerfile
FROM alpine
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser
RUN apk add --no-cache curl
USER appuser  # ← root이 아닌 appuser로 실행
CMD ["curl", "http://example.com"]
```

**개선 이유**:
- appuser는 제한된 권한만 가짐
- 컨테이너 탈출 시에도 appuser 권한만 얻음

**개선 효과**:
- 컨테이너 침해 → 호스트 전체 시스템 보호
- 최소 권한 원칙(Principle of Least Privilege) 구현

**확인 방법**:
```bash
docker run myapp whoami  # appuser 출력 (root이 아님)
```

---

## 💻 실습 명령어

### 단계 1: v1-basic 빌드 및 실행

```bash
# Dockerfile 빌드 (이미지 생성)
docker build -t myapp:v1 ./week02-dockerfile/v1-basic

# 이미지 레이어 확인
docker history myapp:v1

# 컨테이너 실행
docker run -d -p 8080:8080 --name myapp-v1 myapp:v1

# 로그 확인
docker logs myapp-v1

# 브라우저에서 http://localhost:8080 접속 후 앱 정상 동작 확인
curl http://localhost:8080/api/health

# 컨테이너 내부에서 실행 사용자 확인
docker exec myapp-v1 whoami
```

### 단계 2: v2-optimized 빌드 및 캐시 비교

```bash
# v2 빌드 (캐시 사용)
docker build -t myapp:v2 ./week02-dockerfile/v2-optimized
# 출력: Step 2/6 : COPY pom.xml ... (캐시 히트!)
#       Step 4/6 : COPY src src ... (새 빌드)

# 소스 코드만 수정 후 재빌드
# vi week02-dockerfile/v2-optimized/src/main/java/... (뭔가 수정)
docker build -t myapp:v2-refresh ./week02-dockerfile/v2-optimized
# 출력: Step 2/6 : COPY pom.xml ... (캐시 히트!)
#       Step 3/6 : RUN mvn ... (캐시 히트!)
#       Step 4/6 : COPY src src ... (캐시 미스 - 소스 변경됨)
#       Step 5/6 : RUN mvn clean package ... (새 빌드)

# 빌드 시간이 v1보다 훨씬 빠름을 확인
```

### 단계 3: v3-multistage 빌드 및 이미지 크기 비교

```bash
# v3 빌드 (멀티스테이지)
docker build -t myapp:v3 ./week02-dockerfile/v3-multistage

# 이미지 크기 비교
docker images myapp

# 예상 결과:
# REPOSITORY  TAG  SIZE
# myapp       v1   450MB  (JDK + 빌드 도구 포함)
# myapp       v2   450MB  (동일, 멀티스테이지 미사용)
# myapp       v3   150MB  (JRE만, 빌드 도구 제외)

# non-root user 확인
docker run --rm myapp:v3 whoami  # appuser 출력
```

---

## 🎤 면접 답변 준비

### Q1. Dockerfile의 각 명령어가 뭔가?

**30초 버전**
```
FROM은 베이스 이미지 지정, COPY는 파일 복사, RUN은 빌드 중 명령어 실행,
CMD는 컨테이너 시작 시 실행할 기본 명령어입니다.
```

**1분 버전**
```
FROM은 어떤 OS나 런타임을 기반으로 할지 지정합니다.
COPY는 호스트의 파일을 컨테이너로 복사해서 이미지에 포함시킵니다.
RUN은 이미지 빌드 중에 명령어를 실행하는데, 의존성 설치나 빌드가 이에 해당합니다.
CMD는 docker run 할 때 자동으로 실행될 명령어입니다.
이들을 조합하면 자동화된 이미지 생성이 가능합니다.
```

**꼬리 질문 대비**
- Q. COPY와 ADD는 뭐가 다른가?
  A. ADD는 URL에서 다운로드하거나 tar 파일을 자동 압축 해제합니다. 보안상 COPY를 권장합니다.

- Q. RUN과 CMD의 차이는?
  A. RUN은 이미지 빌드 시(docker build), CMD는 컨테이너 시작 시(docker run) 실행됩니다.

---

### Q2. 왜 멀티스테이지 빌드를 쓰는가?

**30초 버전**
```
빌드 도구와 런타임을 분리해서 최종 이미지 크기를 줄이고 보안을 강화합니다.
```

**1분 버전**
```
보통 Java 앱을 빌드하려면 JDK, Maven 같은 도구가 필요한데,
실행할 때는 JRE만 있으면 됩니다.
멀티스테이지 빌드는 빌드 스테이지에서 jar 파일을 만들고,
런타임 스테이지에서는 jar 파일만 복사합니다.
그러면 최종 이미지에는 JRE만 들어가서 크기가 450MB → 150MB로 줄어듭니다.
보안으로도, 빌드 도구가 없으면 공격자가 소스 재컴파일을 못 하니까 좋습니다.
```

**꼬리 질문 대비**
- Q. 빌드 시간은 어떻게 되는가?
  A. 스테이지가 2개가 되므로 빌드는 같은 시간이 걸리지만, 최종 이미지를 배포할 때 다운로드 시간이 66% 단축됩니다.

- Q. 런타임 스테이지에서 builder 스테이지의 파일을 어떻게 가져오나?
  A. `COPY --from=builder /app/target/app.jar ./` 형식으로 특정 스테이지의 경로에서 파일을 가져옵니다.

---

### Q3. non-root user는 왜 필요한가?

**30초 버전**
```
컨테이너 침해 시 피해를 제한하기 위해 root가 아닌 일반 사용자로 실행합니다.
```

**1분 버전**
```
만약 root 사용자로 컨테이너를 실행하면, 컨테이너 안의 보안 취약점이 exploited될 때
공격자가 root 권한을 얻게 됩니다.
root는 호스트 파일 시스템에 접근 권한이 있어서,
극단적으로는 호스트 전체 시스템이 침해될 수 있습니다.
하지만 non-root 사용자로 실행하면, 침해되더라도 그 사용자의 권한만 얻을 수 있어서
전체 시스템 피해를 제한할 수 있습니다.
```

**꼬리 질문 대비**
- Q. 그럼 관리자 권한이 필요한 작업은 어떻게 하나?
  A. 도커 빌드 시 root로 작업을 하고(RUN 명령어), 마지막에 USER로 non-root로 전환합니다.

---

## ❓ 이 개념과 연결되는 다음 학습 주제

Week02를 완료하면, Week03 에서는:
- **볼륨 & 데이터 영속성**: 컨테이너 내 파일이 삭제되지 않도록 호스트와 연결
- **환경변수**: 본 파일과 프로덕션 파일을 다르게 설정 (DATABASE_URL, API_KEY 등)
- **헬스체크**: 컨테이너가 정상 작동하는지 주기적으로 확인

---

## 📋 학습 검증 질문

마지막으로 다음 질문에 답변할 수 있으면 week02 완료:

1. "Dockerfile의 COPY 명령어를 왜 package.json 먼저 하고 src는 나중에 하나?" → 캐시 최적화
2. "이미지 1개를 빌드하면 레이어는 몇 개 생기는가?" → Dockerfile 명령어 개수만큼
3. "멀티스테이지 빌드에서 builder 스테이지의 파일을 어떻게 가져오는가?" → `COPY --from=builder`
4. "왜 root 사용자로 컨테이너를 실행하면 안 되는가?" → 침해 시 호스트 전체 영향
5. "docker build --no-cache 플래그는 뭐 하는 건가?" → 캐시 무시하고 모든 레이어 재빌드

---

*이 파일을 참고해서 week02의 Dockerfile들을 직접 작성하고, 각 버전을 빌드해서 실습하세요.*
