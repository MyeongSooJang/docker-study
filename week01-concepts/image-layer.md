# Image Layer & Caching

---

## 🧠 핵심 개념

**Docker 이미지는 여러 개의 읽기 전용 레이어로 구성되며, 각 레이어는 캐시되어 빌드 속도를 극적으로 개선합니다.**

- Dockerfile의 각 명령어(FROM, RUN, COPY 등) = 레이어 1개
- 변경이 없는 레이어는 이전 빌드의 캐시를 재사용
- 레이어 변경 시, 그 이후 전체가 재빌드됨

이 원리를 모르면 매번 5분씩 비효율적으로 빌드하게 되어, 개발 생산성과 CI/CD 파이프라인 성능을 크게 해친다.

---

## 📖 상세 설명

### 🎯 문제: 느린 빌드

```
매일 코드 한두 줄 수정할 때마다

1회차 빌드
Step 1: 베이스 이미지 다운로드 (100MB)     [30초]
Step 2: 시스템 패키지 설치 (apt-get)      [2분]
Step 3: Maven 의존성 다운로드 (라이브러리)   [3분]
Step 4: 소스 코드 컴파일                  [1분]
─────────────────────────────────────────────
총 시간: ~6분

2회차 빌드 (코드 1줄만 수정)
Step 1: 베이스 이미지 다시 다운로드        [30초] ← 낭비!
Step 2: 시스템 패키지 또 설치               [2분]  ← 낭비!
Step 3: Maven 의존성 또 다운로드          [3분]  ← 낭비!
Step 4: 소스 코드 컴파일                  [1분]
─────────────────────────────────────────────
총 시간: ~6분 (매번!)

💔 하루에 10번 빌드하면? → 60분 낭비
  이걸 한 달이면? → 12시간 낭비!
```

**원인**: 변하지 않는 부분(베이스 이미지, 라이브러리)도 매번 새로 처리

**해결책**: 변하지 않는 부분은 캐시로 재사용 → Layer Caching

---

### 이미지 레이어의 구조

```
Docker 이미지는 스택 형태로 여러 레이어가 쌓여있음:

┌─────────────────────────────┐
│ [Layer 5] COPY app.jar      │ ← 최상단 (변경 빈도: 높음)
├─────────────────────────────┤
│ [Layer 4] RUN gradle build  │ ← 변경 빈도: 가끔
├─────────────────────────────┤
│ [Layer 3] COPY build.gradle │ ← 변경 빈도: 가끔
├─────────────────────────────┤
│ [Layer 2] RUN apt-get ...   │ ← 변경 빈도: 거의 없음
├─────────────────────────────┤
│ [Layer 1] FROM openjdk:17   │ ← 최하단 (변경 빈도: 거의 없음)
└─────────────────────────────┘
```

**각 레이어는 읽기 전용 파일시스템 스냅샷**:
- Layer 1: 베이스 이미지 자체 (파일시스템)
- Layer 2: Layer 1 + apt-get 결과 (추가 파일)
- Layer 3: Layer 2 + build.gradle 파일
- ...
- Layer 5 (최종): 모든 레이어의 합산

각 레이어는 **이전 레이어의 변경 사항만 저장** (union filesystem 사용)

---

### 캐싱 메커니즘

```
Dockerfile을 빌드할 때 Docker는:

1. Dockerfile 명령어를 순차 실행
2. 각 명령어마다 "이 레이어를 이전에 봤나?" 확인
3. 동일한 입력 → 이전 결과 재사용 (캐시)
4. 변경된 입력 → 새로 실행 (캐시 무효)

🔑 핵심: 한 레이어가 변경되면, 그 이후 전체 레이어가 재빌드됨
```

**예시로 이해하기**:

```dockerfile
# 🔴 나쁜 예: 레이어 순서가 최적화되지 않음

FROM openjdk:17                    # [Layer 1] 베이스 이미지
COPY app.jar /app.jar              # [Layer 2] 매일 변함 ← 여기서 변경!
RUN apt-get update && apt-get ...  # [Layer 3] 거의 안 변함 ← 캐시 무효화됨!

빌드 시나리오:
첫 빌드: [Layer 1] 생성 → [Layer 2] 생성 → [Layer 3] 생성
두 번째 빌드 (app.jar만 변경):
  [Layer 1] 캐시 사용 ✅
  [Layer 2] 새로 생성 (app.jar 파일 변경됨)
  [Layer 3] 캐시 무효! 새로 생성 ← 불필요한 apt-get 재실행!
  시간: ~5분 (낭비!)
```

```dockerfile
# ✅ 좋은 예: 레이어 순서 최적화

FROM openjdk:17                    # [Layer 1] 베이스 이미지 (거의 안 변함)
RUN apt-get update && apt-get ...  # [Layer 2] 거의 안 변함 (캐시 보호)
COPY build.gradle .                # [Layer 3] 가끔 변함
RUN gradle dependencies            # [Layer 4] 가끔 변함
COPY app.jar /app.jar              # [Layer 5] 매일 변함 (위로 올림)
RUN gradle build

빌드 시나리오:
첫 빌드: 모든 레이어 생성
두 번째 빌드 (app.jar만 변경):
  [Layer 1] 캐시 사용 ✅
  [Layer 2] 캐시 사용 ✅ (apt-get 재실행 안 함)
  [Layer 3] 캐시 사용 ✅
  [Layer 4] 캐시 사용 ✅ (gradle 재다운로드 안 함)
  [Layer 5] 새로 생성 (jar 파일 변경)
  시간: ~5초! (60배 빠름!)
```

---

## 💻 실습 명령어

### Step 1. 레이어 구조 확인

```bash
# nginx 이미지의 레이어 목록 확인
docker pull nginx:latest
docker history nginx:latest

# 예상 출력
IMAGE          CREATED        CREATED BY                                      SIZE
abc123def      2 days ago     /bin/sh -c #(nop) CMD ["nginx" "-g" "daemon...   0B
def456ghi      2 days ago     /bin/sh -c #(nop) EXPOSE 80                     0B
ghi789jkl      2 days ago     /bin/sh -c apt-get update && apt-get install...  45MB ← 레이어 크기
...
```

각 행이 하나의 레이어입니다.

### Step 2. 캐시 동작 확인 (직접 Dockerfile 작성)

```bash
# 작업 디렉토리 생성
mkdir docker-cache-test && cd docker-cache-test

# 나쁜 예: Dockerfile 작성 (레이어 순서 최악)
cat > Dockerfile.bad << 'EOF'
FROM ubuntu:22.04
COPY app.jar /app/app.jar
RUN apt-get update && apt-get install -y openjdk-17-jre
CMD ["java", "-jar", "/app/app.jar"]
EOF

# 더미 jar 파일 생성
touch app.jar

# 첫 번째 빌드 (캐시 없음)
time docker build -f Dockerfile.bad -t myapp:bad .
# 예상 시간: ~2분

# 두 번째 빌드 (app.jar만 변경, 다른 건 안 변함)
echo "modified" > app.jar
time docker build -f Dockerfile.bad -t myapp:bad .
# 예상 시간: ~2분 (apt-get이 다시 실행됨! 캐시 무효화)
```

```bash
# 좋은 예: 최적화된 Dockerfile
cat > Dockerfile.good << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openjdk-17-jre
COPY app.jar /app/app.jar
CMD ["java", "-jar", "/app/app.jar"]
EOF

# 첫 번째 빌드
time docker build -f Dockerfile.good -t myapp:good .
# 예상 시간: ~2분

# 두 번째 빌드 (app.jar만 변경)
echo "modified again" > app.jar
time docker build -f Dockerfile.good -t myapp:good .
# 예상 시간: ~5초 (apt-get은 캐시 재사용!)
```

### Step 3. 실제 Java 프로젝트 예시 (Multi-stage)

```bash
cat > Dockerfile << 'EOF'
# 🔨 빌드 단계
FROM gradle:8-jdk17 AS builder
WORKDIR /app
COPY build.gradle settings.gradle ./      # 의존성 정의 파일만 먼저 복사
RUN gradle dependencies --no-daemon       # 의존성 다운로드 (캐시됨)
COPY src ./src                            # 소스 코드는 나중에 복사
RUN gradle build -x test --no-daemon

# 🚀 실행 단계 (JRE만, JDK는 제외)
FROM eclipse-temurin:17-jre-alpine
COPY --from=builder /app/build/libs/app.jar /app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
EOF
```

**캐싱 효과**:
```
1회: gradle dependencies 실행 (수 분)     + 코드 컴파일 (1분)
2회: gradle dependencies 캐시 사용 (0초)   + 코드 컴파일 (1분) ← 코드만 변경했으므로
     → 시간: 수 분 → 1~2분으로 단축!
```

---

## 🎤 면접 답변 버전

### 30초 핵심 정의

"Docker 이미지는 여러 레이어의 조합이며, 각 레이어는 이전 빌드의 캐시를 재사용할 수 있습니다. 변경 빈도가 낮은 레이어를 아래에, 높은 레이어를 위에 배치하면 빌드 속도를 극적으로 개선할 수 있습니다."

### 1분 상세 설명

"Docker 이미지는 여러 개의 읽기 전용 레이어로 구성됩니다. Dockerfile의 각 명령어(FROM, RUN, COPY 등)마다 하나의 레이어가 생성되고, 이 레이어들이 스택처럼 쌓여 최종 이미지를 만듭니다.

**캐싱 원리**는 이렇습니다: Docker가 새로운 레이어를 만들 때, 그 입력값(Dockerfile 명령어)이 이전 빌드와 동일하면 이전 결과를 캐시에서 가져옵니다. 하지만 한 레이어가 변경되면, 그 이후 모든 레이어는 새로 빌드됩니다.

**따라서 최적화는** 변경 빈도가 낮은 것(베이스 이미지, 시스템 패키지)을 아래에, 높은 것(소스 코드)을 위에 배치하는 것입니다. 이렇게 하면 코드 변경 시에도 의존성 다운로드는 캐시에서 가져오므로, 빌드 시간을 5분에서 10초 정도로 단축할 수 있습니다."

### Multi-stage Build 추가 설명

"보통 Java 프로젝트는 Multi-stage 빌드를 사용합니다. 첫 번째 단계에서는 gradle로 빌드를 수행하고, 두 번째 단계에서는 결과 jar만 실행 환경에 복사합니다.

**장점**은 첫 번째 단계에서만 gradle 의존성을 다운로드하고, 두 번째 단계의 최종 이미지에는 포함하지 않아 크기를 크게 줄일 수 있습니다. 또한 각 단계마다 캐싱이 적용되어 빌드가 빠릅니다."

---

## ❓ 꼬리 질문 대비

### Q1. "캐시 키"가 뭔가요? Docker가 어떻게 "동일한 입력"을 판단하나요?

**A.** Docker는 각 레이어의 **입력값(Dockerfile 명령어 + 복사할 파일)**의 해시값을 비교합니다.

```
COPY src ./src

Docker가 하는 일:
1. 현재 src 디렉토리의 모든 파일 해시 계산 (sha256)
2. 이전 빌드의 같은 명령어 해시와 비교
3. 동일 → 캐시 사용
   다름 → 새로 빌드
```

**주의**: `RUN apt-get update` 같은 경우, 명령어는 동일하지만 인터넷의 최신 패키지가 변했으므로 매번 새로 실행되어야 합니다. 하지만 Docker는 명령어만 본다. 따라서:

```dockerfile
# ❌ 위험: apt-get이 캐시될 수 있음 (항상 최신 아님)
RUN apt-get update
RUN apt-get install -y openjdk-17-jre

# ✅ 안전: 한 줄에서 update와 install을 함께 수행
RUN apt-get update && apt-get install -y openjdk-17-jre
```

---

### Q2. 그럼 캐시를 강제로 무효화하려면?

**A.** `--no-cache` 옵션을 사용합니다.

```bash
docker build --no-cache -t myapp .
# 모든 레이어를 새로 빌드 (캐시 사용 안 함)
```

**실무 사용 사례**:
- CI/CD에서 최신 패키지를 설치해야 할 때
- 보안 업데이트가 필요할 때
- 캐시가 오래되어 버그를 일으킬 때

---

### Q3. .dockerignore 파일이 캐싱과 무슨 관계가 있나요?

**A.** COPY 명령어의 캐시 키를 결정할 때, **.dockerignore에 나열된 파일은 제외**됩니다.

```dockerfile
# COPY . /app
# "." 디렉토리의 모든 파일을 src/로 복사하려고 함

# 만약 README.md를 .dockerignore에 추가하면:
# README.md 변경 → Docker는 무시 → 캐시 사용
# src/ 파일 변경 → Docker가 감지 → 캐시 무효화
```

**좋은 .dockerignore 예시**:
```
.git
node_modules
.env
.DS_Store
target/        # ← 빌드 결과물 (매번 달라짐)
```

이렇게 설정하면, 개발 중 생기는 임시 파일들이 COPY의 캐시를 무효화하지 않습니다.

---

## 📌 다음 학습과의 연결

이 개념을 이해하면:
- ✅ 느린 빌드를 진단하고 최적화 가능 → **실무 생산성 향상**
- ✅ Multi-stage build의 필요성을 이해 → **다음: 효율적인 Java Dockerfile 작성**
- ✅ CI/CD 파이프라인의 빌드 캐싱 전략 이해 → **다음: Jenkins/GitHub Actions와 연계**

