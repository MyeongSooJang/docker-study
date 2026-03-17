# Week01 - 컨테이너 개념 + CLI

## 📌 먼저 이해해야 할 문제 상황

### 개발자의 고통 (현실)
```
내 노트북에서 잘 돌던 Java 앱
  ↓
서버에 배포하면... 에러! 🔴
  ├─ Java 버전이 다름 (8 vs 11 vs 17)
  ├─ 라이브러리 버전이 다름
  ├─ OS 설정이 다름
  ├─ 환경변수 설정 빠짐
  └─ "내 컴에선 되는데..." 👎

⚠️ 문제의 근본 원인
= 환경이 다르다!
```

### Java의 해결 시도: JVM
- **목표**: 어디서나 같은 Java 코드를 돌리자
- **방식**: JVM이 OS의 차이를 추상화
- **결과**: Java 코드는 어디서나 같지만... **JVM 버전, 라이브러리, 환경설정은 여전히 다르다** 😞

### 더 완벽한 해결책: Container
- **목표**: 환경 전체를 동일하게 하자
- **방식**: 애플리케이션 + JVM + 라이브러리 + 설정을 묶어서 배포
- **결과**: 개발 환경 = 운영 환경 ✅

---

## 🎯 학습 목표

| 항목 | 내용 | 왜 배우나? |
|------|------|-----------|
| 개념 | JVM vs Container vs VM의 역할 이해 | 각 기술이 어떤 문제를 푸는지 알기 위해 |
| 개념 | 이미지 레이어 캐시 원리 | 빠른 빌드 = 빠른 배포 = 생산성 |
| 실습 | Docker CLI 20개 명령어 직접 실행 | 실제로 해봐야 개념이 이해됨 |

---

## 액션 플랜 (과제)

### 🔧 과제 1~4: 기본 동작 원리 이해
- Container 실행 → 포트 포워딩 → 로그 확인
- **학습 포인트**: 컨테이너는 격리된 프로세스일 뿐이다

### 🧹 과제 5~6: 생명주기 관리
- 컨테이너 생성 → 실행 → 정지 → 삭제
- **학습 포인트**: 이미지와 컨테이너는 다르다 (템플릿 vs 실행 인스턴스)

### 📦 과제 7: 이미지 레이어 확인
- Docker inspect로 이미지의 내부 구조 확인
- **학습 포인트**: 이미지는 여러 레이어로 구성되고, 이게 빌드 속도에 영향을 준다

---

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
