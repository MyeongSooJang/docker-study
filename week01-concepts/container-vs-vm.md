# Container vs VM vs JVM

---

## 🧠 핵심 개념

**Container와 VM은 모두 "격리" 기술이지만, 격리의 수준과 방식이 다릅니다.**

- **VM**: OS 전체를 격리 (무겁지만 완벽한 격리)
- **Container**: 프로세스만 격리 (가볍지만 같은 OS 커널 사용)
- **JVM**: 애플리케이션 코드는 OS에 무관하지만, 환경(버전, 라이브러리)은 여전히 의존

이 차이를 모르면 실무에서 "왜 우리 팀은 Docker를 써야 하는가?"라는 질문에 답할 수 없고, 면접에서 "Docker 도입 효과"를 설명할 수 없게 됩니다.

---

## 📖 상세 설명

### 🎯 문제 정의: 환경 차이

```
개발자 노트북 (Windows)        →  빌드 서버 (Linux)  →  운영 서버 (Linux)
├─ Java 17                       Java 11             Java 17
├─ PostgreSQL 14                 PostgreSQL 15       PostgreSQL 14
├─ Maven 3.8                     Maven 3.9           Maven 3.8
└─ 환경변수: TEST=dev           TEST=prod           TEST=prod

결과: "내 컴에선 되는데 서버에선 안 됨" 💥
```

세 가지 해결책:

### 1️⃣ JVM의 시도: Write Once, Run Anywhere

```
JVM이 하는 일:
Java 소스코드 (.java)
  ↓ javac
바이트코드 (.class)
  ↓ JVM (OS별 다른 구현)
기계어 실행 (OS에 맞게 번역)

효과:
✅ Java 바이트코드는 어디서나 같음
❌ 문제: JVM 버전, 라이브러리 버전, 설정이 환경마다 다르면 같은 .jar도 다르게 동작
```

**JVM의 한계 예시**:
```bash
# 개발 환경
java -jar app.jar  # JVM 17로 실행, 성공

# 운영 서버
java -jar app.jar  # JVM 11로 실행, 에러! (버전 호환성 문제)
```

---

### 2️⃣ VM의 방식: 전체 OS를 격리

```
Host OS (Linux)
└─ Hypervisor (자원 분할 계층)
   ├─ VM1
   │  ├─ Guest OS (Linux 전체)      ← 700MB~2GB
   │  ├─ Java Runtime
   │  ├─ PostgreSQL
   │  └─ App.jar
   │
   ├─ VM2
   │  ├─ Guest OS (Linux 전체)      ← 700MB~2GB
   │  ├─ Java Runtime
   │  ├─ PostgreSQL
   │  └─ App.jar

효과:
✅ 완벽한 격리 (OS 전체가 다름)
✅ 환경이 정확히 같음
❌ 부팅 시간: 1~2분
❌ 메모리 사용: VM 하나에 2GB 이상 (3개면 6GB+)
❌ 배포 용량: 각 VM마다 수 GB
```

---

### 3️⃣ Container의 방식: 커널 공유 + 파일시스템/프로세스 격리

```
Host OS (Linux Kernel + cgroups + namespace)
└─ Docker Engine (격리 계층, 하지만 OS 재부팅 불필요)
   ├─ Container1
   │  ├─ /app (격리된 파일시스템)
   │  ├─ Java Runtime (레이어로 공유 가능)
   │  ├─ PostgreSQL
   │  └─ App.jar (프로세스)
   │
   ├─ Container2
   │  ├─ /app (격리된 파일시스템)
   │  ├─ Java Runtime (레이어로 공유)
   │  ├─ PostgreSQL
   │  └─ App.jar (프로세스)

효과:
✅ 가볍다: 이미지 크기 100~200MB (VM은 2GB)
✅ 빠르다: 부팅 시간 초 단위 (VM은 분 단위)
✅ 효율적: 같은 커널 공유해서 리소스 절약
✅ 이식성: Dockerfile이 있으면 어디서나 같은 환경
❌ 격리 수준은 VM보다 약함 (하지만 실무에서 충분)
```

---

## 구조 비교 다이어그램

### ❌ VM 방식

```
┌──────────────────────────────────────────────────┐
│ Host OS (Linux Kernel)                           │
│ ┌────────────────────────────────────────────┐   │
│ │ Hypervisor (KVM, VirtualBox 등)           │   │
│ │                                            │   │
│ │ ┌───────────────┬───────────────┐         │   │
│ │ │    VM1        │     VM2       │         │   │
│ │ ├─────────────┬─┼─────────────┬─┤         │   │
│ │ │ Linux       │ │ Linux       │ │         │   │
│ │ │ (700MB)     │ │ (700MB)     │ │         │   │
│ │ ├─────────────┼─┼─────────────┼─┤         │   │
│ │ │ Java11      │ │ Java17      │ │ ← 각각 다른 버전   │   │
│ │ ├─────────────┼─┼─────────────┼─┤         │   │
│ │ │ App (jar)   │ │ App (jar)   │ │         │   │
│ │ └─────────────┴─┴─────────────┴─┘         │   │
│ └────────────────────────────────────────────┘   │
│                                                  │
│ 부팅: 1~2분, 메모리: VM당 2GB+, 용량: VM당 2~5GB │
└──────────────────────────────────────────────────┘
```

### ✅ Container 방식

```
┌────────────────────────────────────────────────┐
│ Host OS (Linux Kernel) ← 모든 컨테이너가 공유   │
│ ┌──────────────────────────────────────────┐   │
│ │ Docker Engine (namespace + cgroups)      │   │
│ │                                          │   │
│ │ ┌──────────────┬──────────────┐         │   │
│ │ │ Container1   │ Container2   │         │   │
│ │ ├──────────┬───┼──────────┬───┤         │   │
│ │ │ /app     │   │ /app     │   │ ← 격리된 FS     │   │
│ │ ├──────────┼───┼──────────┼───┤         │   │
│ │ │ Java17   │   │ Java17   │   │ ← 레이어 공유   │   │
│ │ ├──────────┼───┼──────────┼───┤         │   │
│ │ │App.jar   │   │App.jar   │   │ ← 프로세스    │   │
│ │ │(PID 123) │   │(PID 456) │   │         │   │
│ │ └──────────┴───┴──────────┴───┘         │   │
│ │                                          │   │
│ │ 메모리 사용: 기본 이미지 100MB + 컨테이너당 수MB  │   │
│ └──────────────────────────────────────────┘   │
│                                                │
│ 부팅: 초 단위, 용량: 이미지 100~200MB, 배포 빠름 │
└────────────────────────────────────────────────┘
```

---

### 성능 비교 (정량적 수치)

| 항목 | VM | Container | 차이 |
|------|-----|-----------|------|
| 부팅 시간 | 60~120초 | 1~3초 | **40~120배 빠름** |
| 이미지 크기 | 2~5GB | 100~300MB | **5~50배 작음** |
| 메모리 오버헤드 | VM당 512MB~2GB | 컨테이너당 10~50MB | **100배 효율적** |
| 한 서버에 띄울 수 있는 개수 | 3~5개 | 100개+ | **20배 이상** |
| 빌드 + 배포 시간 | 20~30분 | 1~5분 | **5배 빠름** |

---

## 💻 실습 명령어

### Step 1. 이미지 상세 정보 확인 (레이어 구조)

```bash
# 이미지 풀
docker pull nginx:latest

# 레이어 목록 확인 (각 Dockerfile 명령어가 1개 레이어)
docker history nginx:latest

# 이미지 크기 확인
docker images | grep nginx
```

**예상 출력**:
```
REPOSITORY   TAG       IMAGE ID     CREATED      SIZE
nginx        latest    abc123def    2 days ago   142MB  ← 여기가 Container 크기
```

### Step 2. 컨테이너 격리 확인 (프로세스)

```bash
# 호스트에서 컨테이너 내부 프로세스 확인 (PID가 격리됨)
docker run -d --name nginx-test nginx
docker inspect nginx-test | grep Pid  # 호스트 입장의 PID
docker exec nginx-test ps aux  # 컨테이너 입장의 PID (1부터 시작)
```

**핵심**: 호스트에서 보는 PID ≠ 컨테이너 내부에서 보는 PID (namespace로 격리)

### Step 3. 메모리 효율성 비교

```bash
# 여러 컨테이너 실행
docker run -d --name app1 nginx
docker run -d --name app2 nginx
docker run -d --name app3 nginx

# 메모리 사용량 확인
docker stats

# 이미지 레이어 재사용 확인 (3개 컨테이너가 같은 nginx 레이어 공유)
docker system df
```

**예상**: 3개 컨테이너가 전부 띄워져 있어도 메모리는 수십 MB (VM이면 6GB 이상)

---

## 🎤 면접 답변 버전

### 30초 핵심 정의

"Container와 VM은 모두 격리 기술이지만, VM은 OS 전체를 격리하고 Container는 호스트 커널을 공유하면서 프로세스만 격리합니다. 때문에 Container가 VM보다 훨씬 가볍고 빠릅니다."

### 1분 상세 설명

"VM은 Hypervisor 위에 Guest OS 전체를 올리는 방식입니다. 각 VM마다 2GB 이상의 OS를 부팅해야 하므로 부팅 시간이 1~2분 걸리고 리소스를 많이 씁니다.

반면 Container는 호스트 OS의 커널을 공유하고, 파일시스템과 프로세스만 namespace와 cgroup으로 격리합니다. 때문에 부팅이 초 단위로 빠르고, 이미지 크기도 100~200MB 수준으로 매우 작습니다.

실무에서는 이런 이점이 크면 한 서버에서 100개 이상의 Container를 띄울 수 있어서, 클라우드 비용을 크게 절감할 수 있고, CI/CD 파이프라인도 빠르게 만들 수 있습니다."

### JVM과의 관계

"JVM은 바이트코드를 OS에 맞게 번역해주는 계층이라 Java 코드의 이식성을 높입니다. 하지만 JVM 버전, 라이브러리 버전이 다르면 같은 jar도 다르게 동작할 수 있습니다.

Container는 JVM 자체를 포함해서 **전체 실행 환경(Java 17 + PostgreSQL 14 + 라이브러리 + 설정)을 함께 패키징**해서 배포하기 때문에, 개발 환경 = 운영 환경이 되어 환경 차이로 인한 버그를 원천 차단합니다."

---

## ❓ 꼬리 질문 대비

### Q1. 그럼 Container도 완벽하게 격리되나요? VM보다 뭐가 떨어지나요?

**A.** Container는 Linux Kernel을 공유하기 때문에, **Kernel 레벨의 보안 취약점은 공유**됩니다.
예를 들어, 한 Container의 악의적인 프로세스가 Kernel을 교란하면 다른 Container들도 영향받을 수 있습니다.
VM은 Guest OS 전체가 격리되어 있어서 이런 위험이 훨씬 낮습니다.

하지만 **대부분의 실무 환경에서는 Container의 격리 수준으로 충분**합니다.
신뢰할 수 있는 코드만 돌리기 때문입니다.

(만약 완벽한 격리가 필요하면 "gVisor" 같은 secure container runtime을 사용하기도 합니다.)

---

### Q2. Container 말고 왜 JVM의 "쓰기 한 번, 어디서나 실행" 전략으로 안 되나요?

**A.** JVM이 해결하는 건 **애플리케이션 코드의 이식성**뿐입니다.

```
개발자 노트북          운영 서버
java -jar app.jar    java -jar app.jar
(JVM 17)            (JVM 11) ← 다르면?
(PostgreSQL 14)     (PostgreSQL 15) ← 다르면?
(env: TEST=dev)     (env: TEST=prod) ← 다르면?
```

코드는 같지만 **실행 환경이 다르면** 결과가 달라집니다.

Container는 **코드 + JVM + DB + 설정 전체를 함께 배포**해서 이 모든 환경 차이를 없앱니다.

---

### Q3. 그럼 Kubernetes는 뭔가요?

**A.** Kubernetes(K8s)는 **수백 개의 Container를 대규모로 관리하는 오케스트레이션 플랫폼**입니다.

Container 하나를 실행하는 건 `docker run` 명령어면 되지만,
실무에서는 "장애 시 자동 재시작", "스케일링", "로드 밸런싱", "롤링 업데이트" 같은 고급 기능이 필요합니다.

Kubernetes가 이런 기능들을 제공합니다.

**Container와의 관계**:
- Container: 애플리케이션 패키징 도구
- Kubernetes: Container 대규모 배포 및 관리 플랫폼

(Week04에서 배울 예정입니다.)

---

## 📌 다음 학습과의 연결

이 개념을 이해하면:
- ✅ 왜 Docker를 써야 하는지 설명 가능 → **면접 기본 질문 대응**
- ✅ 이미지 vs 컨테이너 개념이 이해됨 → **다음: 이미지 레이어 학습**
- ✅ 환경 격리의 중요성을 앎 → **다음: docker-compose, Kubernetes 이해**

