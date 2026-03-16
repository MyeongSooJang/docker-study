# Docker CLI Cheatsheet
# 실제 실행 명령어 모음

# ========================
# 이미지 관련
# ========================

# Docker Hub에서 이미지 다운로드
docker pull nginx

# 로컬 이미지 목록 조회
docker images

# 이미지 삭제
docker rmi nginx

# 이미지 상세 정보 (레이어 확인)
docker inspect nginx

# ========================
# 컨테이너 실행
# ========================

# 기본 실행
docker run nginx

# 백그라운드 실행 (-d)
docker run -d nginx

# 포트 바인딩 (-p 호스트포트:컨테이너포트)
docker run -d -p 8080:80 nginx

# 이름 지정 (--name)
docker run -d -p 8080:80 --name my-nginx nginx

# 환경변수 전달 (-e)
docker run -d -e SPRING_PROFILES_ACTIVE=local my-spring-app

# 볼륨 마운트 (-v 호스트경로:컨테이너경로)
docker run -d -v /my/data:/var/lib/mysql mysql

# 실행 후 자동 삭제 (--rm)
docker run --rm ubuntu echo "hello"

# 컨테이너 내부 접속 (-it)
docker run -it ubuntu bash

# ========================
# 컨테이너 관리
# ========================

# 실행 중인 컨테이너 목록
docker ps

# 전체 컨테이너 목록 (종료 포함)
docker ps -a

# 컨테이너 중지
docker stop my-nginx

# 컨테이너 재시작
docker restart my-nginx

# 컨테이너 삭제
docker rm my-nginx

# 중지 + 삭제 한번에
docker stop my-nginx && docker rm my-nginx

# 실행 중인 컨테이너에 명령어 실행
docker exec my-nginx ls /etc/nginx

# 실행 중인 컨테이너 내부 접속
docker exec -it my-nginx bash

# ========================
# 로그 / 모니터링
# ========================

# 로그 조회
docker logs my-nginx

# 로그 실시간 확인 (-f)
docker logs -f my-nginx

# 컨테이너 리소스 사용량 확인
docker stats

# ========================
# 정리 명령어
# ========================

# 사용하지 않는 컨테이너/이미지/네트워크 전체 삭제
docker system prune

# 이미지까지 포함해서 삭제
docker system prune -a
