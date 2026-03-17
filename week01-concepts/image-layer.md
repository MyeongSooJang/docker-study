# Image Layer (Docker 이미지의 최적화 원칙)

## 🤔 왜 레이어가 필요한가?

```
상황: Docker 이미지를 매번 빌드할 때마다 시간이 오래 걸린다

예를 들어, 간단한 코드 수정만 했는데도
전체 이미지를 처음부터 새로 만든다면?
- Java 런타임 다운로드 (수 MB)
- 라이브러리 다운로드 (수 MB~GB)
- 앱 코드 컴파일
- 최종 이미지 생성
→ 매번 5분, 10분, 그 이상...

💡 해결책: 변하지 않는 부분은 재사용하자!
   = Layer Caching
```

## 레이어 구조

이미지는 여러 **읽기 전용 레이어의 합**으로 구성됩니다.
Dockerfile의 각 명령어(RUN, COPY, ADD 등)가 새로운 레이어를 생성합니다.

```
┌─────────────────────────────────────────────┐
│ [Layer 4] COPY app.jar /app.jar             │ ← 자주 변함
├─────────────────────────────────────────────┤
│ [Layer 3] RUN apt-get install curl          │ ← 가끔 변함
├─────────────────────────────────────────────┤
│ [Layer 2] RUN apt-get update                │ ← 거의 안 변함
├─────────────────────────────────────────────┤
│ [Layer 1] FROM eclipse-temurin:17-jre       │ ← 안 변함
└─────────────────────────────────────────────┘
```

🔑 핵심: 아래 레이어(변경 빈도 낮음)는 캐시되고,
         위 레이어(변경 빈도 높음)만 새로 빌드된다!

## ⚡ 캐시 동작 원리

```
1️⃣ 첫 번째 빌드 (캐시 없음)
   $ docker build .
   [Layer 1] FROM ... ✅ 생성됨
   [Layer 2] RUN apt-get ... ✅ 생성됨
   [Layer 3] RUN apt-get install ... ✅ 생성됨
   [Layer 4] COPY app.jar ... ✅ 생성됨
   → 총 시간: ~3분

2️⃣ 두 번째 빌드 (코드 변경, 나머지는 같음)
   $ docker build .
   [Layer 1] FROM ... 💾 캐시 사용! (이전과 동일)
   [Layer 2] RUN apt-get ... 💾 캐시 사용! (이전과 동일)
   [Layer 3] RUN apt-get install ... 💾 캐시 사용! (이전과 동일)
   [Layer 4] COPY app.jar ... ✅ 새로 생성 (파일 변경됨)
   → 총 시간: ~10초

3️⃣ 잘못된 순서로 짜면? (라이브러리 후에 코드)
   [Layer 1] FROM ...
   [Layer 2] COPY app.jar ... ← 코드 변경!
   [Layer 3] RUN apt-get install ... ← 캐시 무효!
   → 라이브러리까지 다시 설치됨
   → 총 시간: ~3분 (낭비!)
```

## 🎯 최적화 원칙: 변경 빈도 낮음 → 아래, 높음 → 위

```dockerfile
# ❌ 나쁜 예: 코드가 변경될 때마다 라이브러리까지 재설치
FROM eclipse-temurin:17-jre-alpine
COPY app.jar /app.jar           ← 매일 변함
RUN apt-get update && apt-get install curl  ← 거의 안 변함 (캐시 낭비!)

# ✅ 좋은 예: 코드 변경은 캐시하고, 라이브러리 설치만 재사용
FROM eclipse-temurin:17-jre-alpine                ← Layer 1: 거의 안 변함 (캐시)
RUN apt-get update && apt-get install curl       ← Layer 2: 거의 안 변함 (캐시)
COPY build.gradle gradle.properties ./            ← Layer 3: 가끔 변함
RUN gradle dependencies                          ← Layer 4: 가끔 변함
COPY . .                                         ← Layer 5: 매번 변함
RUN gradle build
```

### 실전 팁: Java + Docker의 Multi-stage Build 예시

```dockerfile
# 빌드 단계 (빌드 도구 포함, 최종 이미지에는 제외)
FROM gradle:8-jdk17 AS builder
WORKDIR /app
COPY build.gradle .
RUN gradle dependencies --no-daemon
COPY src ./src
RUN gradle build --no-daemon

# 런타임 단계 (실제 배포되는 이미지)
FROM eclipse-temurin:17-jre-alpine
COPY --from=builder /app/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

**왜 Multi-stage를 쓰나?**
- 빌드 도구(gradle)를 최종 이미지에 포함하지 않음 → 가벼움
- 의존성은 별도 레이어로 캐싱 → 빠른 빌드
- 최종 이미지: 100MB vs 1GB+ (크기 차이 엄청남!)

**캐싱 동작:**
```
첫 번째 빌드: gradle dependencies 실행 (수 분)
두 번째 빌드 (코드만 변경): gradle dependencies 캐시 사용 (초 단위)
```

## 💼 면접 답변 템플릿

**Q. Docker 이미지 레이어란 무엇이고, 왜 중요한가요?**

A. Docker 이미지는 여러 **읽기 전용 레이어**의 합입니다.
   Dockerfile의 각 명령어(FROM, RUN, COPY 등)마다 하나의 레이어가 생성됩니다.

   **캐싱 메커니즘:**
   - 이전 빌드에서 변경 없는 레이어는 캐시에서 재사용됩니다
   - 어떤 레이어가 변경되면, 그 레이어 **이후 전체**를 새로 빌드합니다
   - 이는 빌드 속도에 직결됩니다

   **최적화 원칙:**
   ```
   1. 변경 빈도가 낮은 것 아래: FROM, RUN apt-get (거의 안 변함)
   2. 변경 빈도가 높은 것 위: COPY (매일 변함)
   ```

   코드 변경이 있을 때마다 의존성(라이브러리)를 다시 설치하는 낭비를 피할 수 있습니다.
   CI/CD 파이프라인에서 빌드 속도가 매우 중요하므로, 이런 최적화가 생산성에 큰 영향을 미칩니다.

**Q. Multi-stage build는 왜 쓰나요?**

A. 빌드 단계와 런타임 단계를 분리해서 **최종 이미지 크기를 줄입니다.**
   - 빌드 도구(gradle, maven)는 최종 이미지에 포함하지 않음
   - 의존성 캐싱으로 빠른 재빌드 가능
   - 결과: 이미지 크기 1GB → 100MB, 배포 속도 향상

---

## 🎯 핵심 정리

| 개념 | 의미 | 개발자에게 주는 영향 |
|------|------|-----------------|
| 레이어 | Dockerfile 명령어 1개 = 레이어 1개 | 각 레이어는 독립적으로 캐싱됨 |
| 캐시 | 이전 빌드의 같은 레이어 재사용 | 변경 없으면 다시 빌드하지 않음 |
| 캐시 무효화 | 레이어 변경 → 그 이후 전체 재빌드 | 순서 잘못하면 매번 라이브러리 재설치 |
| 최적화 | 변경 빈도 낮음 아래, 높음 위 | 수 분 → 초 단위로 빌드 시간 단축 |

### 실제 개발 시나리오

```
👨‍💻 개발자: "코드 한 줄 수정해서 테스트하고 싶은데..."

❌ 최적화 안 된 Dockerfile:
   → gradle dependencies 매번 다시 실행
   → 빌드 시간: 5분 이상 (매번!)
   → 개발 흐름 끊김, 생산성 떨어짐

✅ 최적화된 Dockerfile:
   → 첫 빌드만 의존성 설치 (수 분)
   → 이후 코드만 변경할 때 (캐시 사용)
   → 빌드 시간: 10초
   → 빠른 피드백, 생산성 향상
   → CI/CD 파이프라인도 빠르게!
```

### 왜 배웠는가?

```
Container 기술
├─ 문제: 환경 차이로 인한 버그
└─ 해결: 환경 전체를 패키징 (Docker)

레이어 캐싱 최적화
├─ 문제: 느린 빌드 = 개발 생산성 저하
└─ 해결: 레이어 순서로 빌드 시간 단축

둘이 합쳐진 효과
├─ "내 컴에서 되는데 서버에선 왜 안 돼?" → 해결 ✅
├─ "빌드 너무 오래 걸려" → 해결 ✅
└─ 진정한 DevOps 개발자가 되는 길 🚀
```
