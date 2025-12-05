# Docker CLI Cheatsheet

> 컨테이너화된 애플리케이션을 만들고 배포하고 실행하기 위한 필수 명령어 모음입니다.

## 1. 컨테이너 실행 및 관리 (Lifecycle)
가장 많이 사용하는 기본 명령어입니다.

```bash
# 백그라운드(-d)에서 포트 연결(-p)하여 실행
docker run -d -p 8080:80 --name my-web nginx

# 실행 중인 컨테이너 목록 확인
docker ps

# 중지된 컨테이너 포함 모든 목록 확인
docker ps -a

# 컨테이너 중지 및 삭제
docker stop my-web
docker rm my-web
```

## 2. 컨테이너 내부 진입 및 로그
디버깅할 때 필수적입니다.

```bash
# 컨테이너 로그 실시간 확인 (-f)
docker logs -f my-web

# 실행 중인 컨테이너에 접속 (Shell 실행)
docker exec -it my-web /bin/bash
# (Alpine 이미지의 경우 /bin/sh 사용)
```

## 3. 이미지 관리
```bash
# 이미지 다운로드 (실행은 안 함)
docker pull ubuntu:20.04

# 로컬 이미지 목록 확인
docker images

# 이미지 삭제
docker rmi <image_id>
```

## 4. 청소 (Cleanup)
디스크 공간 확보를 위해 사용합니다. (주의: 삭제된 데이터 복구 불가)

```bash
# 사용하지 않는 모든 리소스(중지된 컨테이너, 미사용 네트워크/이미지) 삭제
docker system prune -a
```
