# Container vs VM

## 핵심 개념 비교

| 항목 | VM | Container |
|------|-----|-----------|
| 격리 단위 | OS 전체 | 프로세스 |
| 부팅 시간 | 수 분 | 수 초 |
| 용량 | GB 단위 | MB 단위 |
| 커널 | 독립된 커널 보유 | 호스트 커널 공유 |
| 이식성 | 낮음 | 높음 |

## 구조 비교

### VM
```
Host OS
└── Hypervisor
    ├── VM1: Guest OS + App
    ├── VM2: Guest OS + App
    └── VM3: Guest OS + App
```

### Container
```
Host OS
└── Docker Engine
    ├── Container1: App
    ├── Container2: App
    └── Container3: App
```

## 면접 답변 템플릿

Q. VM과 Container의 차이는?

A. VM은 하이퍼바이저 위에 Guest OS 전체를 올리는 방식으로
   리소스 사용량이 크고 부팅이 느립니다.
   Container는 호스트 OS 커널을 공유하고 프로세스 단위로 격리하므로
   가볍고 빠르며 이식성이 높습니다.
   Docker는 Container 기술을 쉽게 사용할 수 있도록 해주는 도구입니다.

## 핵심 요약

| 키워드 | 설명 |
|--------|------|
| 격리 | 다른 컨테이너와 독립된 환경 |
| 이미지 | 컨테이너 실행을 위한 읽기 전용 템플릿 |
| 컨테이너 | 이미지를 실행한 인스턴스 (프로세스) |
| Docker Engine | 컨테이너를 관리하는 런타임 |
