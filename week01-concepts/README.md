# Week01 — 컨테이너 개념 + CLI

---

## 📌 이 주의 목표

### 🎯 실무 레벨
- Docker 이미지와 컨테이너의 관계를 이해하고 명령어로 생성/실행할 수 있다
- 이미지 레이어 구조와 캐싱 원리를 이해해 최적화된 Dockerfile을 구상할 수 있다
- 컨테이너 생명주기를 이해하고 상태 변화를 모니터링할 수 있다

### 🎤 면접 레벨
- "VM과 Container의 구조적 차이"를 1분 안에 설명 가능
- "Docker 이미지 레이어와 캐시가 왜 중요한가"를 설명 가능
- "이미지와 컨테이너는 뭐가 다른가"를 구체적으로 설명 가능

---

## 📚 학습 구조

| 순서 | 개념 | 학습 목표 | 지금 모르면 막히는 이유 | 실습 범위 |
|------|------|---------|------------------|----------|
| **1단계** | JVM vs Container vs VM | 각 기술의 역할과 차이점 파악 | 왜 Docker를 써야 하는지 모름 → 면접 답변 불가 | 개념 학습 |
| **2단계** | 이미지와 컨테이너 | 템플릿(이미지) vs 인스턴스(컨테이너) 구분 | 이미지를 컨테이너로 착각 → 명령어 사용 오류 | CLI 20개 명령어 |
| **3단계** | 레이어와 캐싱 | 빌드 최적화 원리 이해 | 비효율적인 Dockerfile 작성 → 느린 배포 | 레이어 구조 파악 |

---

## 🚀 실습 액션 플랜

### Phase 1: 기본 동작 (과제 1~3)

**목표**: 컨테이너가 "격리된 프로세스"임을 직관적으로 이해

| 과제 | 명령어 | 배우는 것 | 다음 단계와의 연결 |
|------|--------|---------|------------------|
| **과제 1** | `docker run hello-world` | 첫 컨테이너 실행 | 이미지 vs 컨테이너 구분 ← 과제 2에서 명확해짐 |
| **과제 2** | `docker run -d -p 8080:80 nginx` | 포트 포워딩, 백그라운드 실행 | `-p` 플래그가 왜 필요한가 ← VM과의 차이(격리)에서 나옴 |
| **과제 3** | `docker exec -it nginx /bin/bash` | 실행 중인 컨테이너 내부 접속 | 컨테이너 내부 파일시스템 확인 ← 레이어의 개념 선행 |

### Phase 2: 생명주기 관리 (과제 4~6)

**목표**: 이미지와 컨테이너의 관계 명확히 하기

| 과제 | 명령어 | 배우는 것 | 체크포인트 |
|------|--------|---------|-----------|
| **과제 4** | `docker logs -f nginx` | 실시간 로그 모니터링 | 컨테이너가 실제 프로세스임을 확인 |
| **과제 5** | `docker stop`, `docker rm`, `docker rmi` | 컨테이너 삭제 ≠ 이미지 삭제 | 이미지 재사용 가능함을 이해 |
| **과제 6** | `docker run --rm ubuntu` | 자동 삭제 옵션 | 임시 컨테이너와 영구 컨테이너 구분 |

### Phase 3: 내부 구조 (과제 7)

**목표**: 이미지의 레이어 구조 가시화

| 과제 | 명령어 | 배우는 것 | 심화 학습 |
|------|--------|---------|----------|
| **과제 7** | `docker inspect nginx` + `grep Layers` | 이미지가 여러 레이어로 구성됨 | Week02에서 레이어 순서 최적화 배움 |

---

## ✅ 학습 체크리스트

### 실습 완료 체크

- [ ] 과제 1: hello-world 이미지 실행 + 정상 메시지 확인
- [ ] 과제 2: nginx 컨테이너 실행 + 브라우저에서 접속 확인
- [ ] 과제 3: 컨테이너 내부에서 `find / -name index.html` 실행하여 위치 확인
- [ ] 과제 4: `docker logs -f` 로 접근 로그 실시간 확인
- [ ] 과제 5: stop → rm → rmi 순서대로 정리
- [ ] 과제 6: `docker ps -a` 에서 ubuntu 컨테이너가 없음 확인
- [ ] 과제 7: `docker inspect` 에서 Layers 항목 확인

### 개념 이해 체크 (면접 대비)

- [ ] "VM과 Container의 차이"를 30초 핵심 정의 + 1분 상세 설명으로 말할 수 있다
- [ ] "이미지와 컨테이너는 뭐가 다른가"를 설명할 수 있다 (템플릿 vs 인스턴스)
- [ ] "Docker 이미지 레이어가 뭔가"를 설명할 수 있다 (Dockerfile 명령어 1개 = 레이어 1개)
- [ ] "왜 레이어 순서가 중요한가"를 설명할 수 있다 (캐시 무효화 방지)

---

## 📖 학습 자료

### 과제 1. hello-world 실행

Docker Desktop 설치 후 첫 번째 컨테이너 실행
```bash
docker run hello-world
```

**정답 출력 결과**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

### 과제 2. nginx 컨테이너 실행 후 브라우저 확인
```bash
docker run -d -p 8080:80 --name my-nginx nginx
```

**정답**
- 브라우저에서 http://localhost:8080 접속 시 "Welcome to nginx!" 페이지 출력
- `docker ps` 실행 시 아래와 같이 출력
```
CONTAINER ID   IMAGE   COMMAND   PORTS                  NAMES
xxxxxxxxxxxx   nginx   ...       0.0.0.0:8080->80/tcp   my-nginx
```

---

### 과제 3. 실행 중인 nginx 컨테이너 내부 접속 후 index.html 위치 확인
```bash
docker exec -it my-nginx bash
find / -name index.html 2>/dev/null
```

**정답**
```
/usr/share/nginx/html/index.html
```

---

### 과제 4. nginx 로그 실시간 확인 후 브라우저 새로고침으로 로그 발생 확인
```bash
docker logs -f my-nginx
```

**정답**
브라우저에서 http://localhost:8080 새로고침 시 아래와 같은 접근 로그 출력
```
172.17.0.1 - - [날짜] "GET / HTTP/1.1" 200 615 "-" "Mozilla/5.0 ..."
```

---

### 과제 5. 컨테이너 중지 → 삭제 → 이미지 삭제 순서로 정리
```bash
docker stop my-nginx
docker rm my-nginx
docker rmi nginx
```

**정답**
```bash
docker ps      # 출력 없음 (실행 중인 컨테이너 없음)
docker images  # nginx 이미지 없음
```

---

### 과제 6. ubuntu 컨테이너 실행 후 자동 삭제 확인
```bash
docker run --rm ubuntu echo "study complete"
docker ps -a
```

**정답**
```
study complete
```
`docker ps -a` 실행 시 ubuntu 컨테이너 없음 (--rm 으로 자동 삭제됨)

---

### 과제 7. (심화) 이미지 레이어 확인
```bash
docker pull nginx
docker inspect nginx | grep -A 5 "Layers"
```

**정답**
Layers 항목에 sha256 해시값으로 구성된 레이어 목록 출력
각 레이어가 Dockerfile 명령어 1개에 대응됨을 확인

---

## 면접 체크리스트

| 질문 | 답변 가능 여부 |
|------|---------------|
| VM과 Container의 차이는? | |
| Docker 이미지와 컨테이너의 차이는? | |
| 이미지 레이어 캐시는 어떻게 동작하는가? | |
| docker run -d -p 8080:80 각 옵션의 의미는? | |
| 실행 중인 컨테이너 내부에 접속하는 명령어는? | |

학습 완료 후 위 질문에 답변 가능하면 week02 진행
