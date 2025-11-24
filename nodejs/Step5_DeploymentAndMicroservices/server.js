// nodejs/Step5_DeploymentAndMicroservices/server.js
// Node.js 학습 계획 - 5단계: 배포 및 마이크로서비스
// 이 파일은 Docker 컨테이너로 실행될 간단한 Express.js 웹 서버 애플리케이션입니다.
//
// 마이크로서비스 아키텍처에서 각 서비스는 독립적으로 배포 가능한 단위이며,
// Docker는 이러한 서비스를 컨테이너화하는 데 이상적인 도구입니다.

const express = require('express');
const app = express();
const port = process.env.PORT || 3000; // 환경 변수에서 포트를 가져오거나 기본값 3000 사용

app.get('/', (req, res) => {
  console.log(`요청 수신 (워커 ${process.pid})`);
  res.send(`Hello from Dockerized Node.js App! Running on port ${port}.`);
});

app.listen(port, () => {
  console.log(`서버가 포트 ${port}에서 실행 중입니다.`);
});

/*
이 코드를 실행하려면:

1. `package.json` 및 `Dockerfile` 파일과 함께 `nodejs/Step5_DeploymentAndMicroservices` 디렉토리에 이 파일을 `server.js`로 저장.
2. `Dockerfile`을 사용하여 Docker 이미지를 빌드하고 실행.
*/
