# Week01 - 컨테이너 개념 + CLI

## 학습 목표

| 항목 | 내용 |
|------|------|
| 개념 | VM vs Container 차이 설명 가능 |
| 개념 | 이미지 레이어 캐시 원리 설명 가능 |
| 실습 | CLI 20개 명령어 직접 실행 |

---

## 액션 플랜 (과제)

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
