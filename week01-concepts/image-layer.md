# Image Layer

## 레이어 구조

이미지는 여러 레이어의 합으로 구성됩니다.
각 Dockerfile 명령어(RUN, COPY 등)가 레이어 1개를 생성합니다.
```
[Layer 4] COPY app.jar /app.jar       <- 변경 빈도 높음 (위로)
[Layer 3] RUN apt-get install curl    <- 변경 빈도 낮음 (아래로)
[Layer 2] RUN apt-get update
[Layer 1] FROM eclipse-temurin:17-jre-alpine
```

## 캐시 동작 원리

| 상황 | 결과 |
|------|------|
| 레이어 변경 없음 | 캐시 사용 (빌드 빠름) |
| 레이어 변경 발생 | 해당 레이어부터 전체 재빌드 |

## 최적화 원칙

변경 빈도가 낮은 레이어를 아래에, 높은 레이어를 위에 배치

| 순서 | 내용 | 변경 빈도 |
|------|------|-----------|
| 1 | FROM (베이스 이미지) | 거의 없음 |
| 2 | RUN apt-get (시스템 패키지) | 거의 없음 |
| 3 | COPY build.gradle (의존성 파일) | 가끔 |
| 4 | RUN gradle dependencies | 가끔 |
| 5 | COPY app.jar (애플리케이션) | 자주 |

## 면접 답변 템플릿

Q. Docker 이미지 레이어란?

A. Dockerfile의 각 명령어가 실행될 때마다 레이어가 생성됩니다.
   레이어는 캐싱되므로, 변경이 없는 레이어는 재사용됩니다.
   변경이 생기면 해당 레이어 이후 전체를 재빌드합니다.
   따라서 변경 빈도가 낮은 명령어를 Dockerfile 상단에,
   자주 바뀌는 COPY 명령어를 하단에 배치하면 빌드 속도를 최적화할 수 있습니다.
