// nodejs/Step4_AdvancedFeatures/index.js
// Node.js 학습 계획 - 4단계: 고급 기능 및 모범 사례
// 이 파일은 Node.js의 클러스터링(`cluster`) 모듈을 이용한 다중 코어 활용,
// `dotenv`를 이용한 환경 변수 관리, 그리고 `winston`을 이용한 로깅 모범 사례를 보여줍니다.
//
// Node.js는 단일 스레드 모델이지만, 클러스터링을 통해 멀티 코어 CPU를 최대한 활용하고,
// 환경 변수 및 체계적인 로깅을 통해 운영 환경에 적합한 애플리케이션을 구축할 수 있습니다.

const cluster = require('cluster'); // 클러스터 모듈 임포트
const os = require('os'); // 운영체제 정보 모듈
const express = require('express'); // 간단한 웹 서버 구축용 Express.js 임포트
const dotenv = require('dotenv'); // 환경 변수 로드를 위한 dotenv 임포트
const winston = require('winston'); // 로깅 라이브러리 임포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: 환경 변수 관리 (`dotenv`)
// - `.env` 파일에 정의된 환경 변수를 `process.env` 객체에 로드합니다.
// - 민감한 정보(DB 비밀번호, API 키)는 환경 변수를 통해 관리하는 것이 안전합니다.
// -----------------------------------------------------------------------------
dotenv.config(); // `.env` 파일에서 환경 변수를 로드
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const API_KEY = process.env.API_KEY || 'default_api_key';

console.log(`환경 변수 로드 완료: NODE_ENV=${NODE_ENV}, PORT=${PORT}, API_KEY=${API_KEY.substring(0, 5)}...`);

// -----------------------------------------------------------------------------
// 학습 포인트 2: 로깅 (`winston`)
// - Node.js의 표준 로깅 라이브러리로, 다양한 전송(콘솔, 파일, 외부 서비스) 및
//   레벨(debug, info, warn, error) 설정을 통해 유연한 로깅을 제공합니다.
// -----------------------------------------------------------------------------
const logger = winston.createLogger({
  level: NODE_ENV === 'production' ? 'info' : 'debug', // 운영 환경에서는 info, 개발에서는 debug 레벨 로깅
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.json() // JSON 형식으로 로그 출력
  ),
  transports: [
    new winston.transports.Console(), // 콘솔로 로그 출력
    new winston.transports.File({ filename: 'error.log', level: 'error' }), // 에러 로그는 파일로 저장
    new winston.transports.File({ filename: 'combined.log' }) // 모든 로그는 파일로 저장
  ],
  // 나쁜 예시: `console.log`만 사용하여 로깅하거나, 로그 레벨을 구분하지 않는 것.
  // - 운영 환경에서 중요한 에러를 놓치거나, 불필요한 로그로 인해 디버깅이 어려워집니다.
  // - `winston`과 같은 로깅 라이브러리를 사용하여 체계적인 로깅 전략을 구축해야 합니다.
});

// -----------------------------------------------------------------------------
// 학습 포인트 3: 클러스터링 (`cluster` 모듈)
// - Node.js는 기본적으로 단일 스레드이지만, `cluster` 모듈을 사용하면
//   멀티 코어 CPU를 최대한 활용하여 여러 워커 프로세스를 생성할 수 있습니다.
// - 마스터 프로세스가 워커 프로세스를 관리합니다.
// -----------------------------------------------------------------------------
if (cluster.isMaster) { // 현재 프로세스가 마스터 프로세스인 경우
  logger.info(`마스터 프로세스 ${process.pid} 시작.`);
  const numCPUs = os.cpus().length; // CPU 코어 수 확인

  // 나쁜 예시: `cluster` 모듈을 사용하지 않고 단일 프로세스로만 애플리케이션을 실행하는 것.
  // - 멀티 코어 CPU의 이점을 활용하지 못하고, 단일 프로세스 장애 시 전체 서비스가 중단됩니다.
  // - Node.js 애플리케이션의 고가용성과 성능을 위해 클러스터링을 사용하는 것이 좋습니다.

  // CPU 코어 수만큼 워커 프로세스 생성
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork(); // 워커 프로세스 생성
  }

  // 워커 프로세스 종료 시 이벤트 처리
  cluster.on('exit', (worker, code, signal) => {
    logger.warn(`워커 ${worker.process.pid} 종료됨 (Code: ${code}, Signal: ${signal}).`);
    logger.info('새로운 워커를 시작합니다.');
    cluster.fork(); // 워커 프로세스가 죽으면 다시 생성하여 서비스의 안정성 유지
  });

} else { // 현재 프로세스가 워커 프로세스인 경우
  const app = express();

  app.get('/', (req, res) => {
    logger.info(`워커 ${process.pid}: 요청 처리.`);
    res.send(`워커 ${process.pid}에서 응답: Hello World! API_KEY: ${API_KEY.substring(0, 5)}...`);
  });

  app.listen(PORT, () => {
    logger.info(`워커 ${process.pid}: 서버가 http://localhost:${PORT} 에서 실행 중입니다.`);
  });
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 프로세스 관리 (PM2) (개념)
// - PM2는 Node.js 애플리케이션을 위한 고급 프로세스 관리자입니다.
// - 클러스터링 자동화, 무중단 배포, 로드 밸런싱, 로깅, 모니터링 등의 기능을 제공합니다.
// - `npm install -g pm2` 설치 후 `pm2 start index.js -i max` 명령으로 클러스터 모드 실행.
// -----------------------------------------------------------------------------
logger.info("--- 4단계: 고급 기능 및 모범 사례 학습 ---");
logger.info("PM2와 같은 프로세스 관리자를 사용하면 클러스터링 및 무중단 배포를 더 쉽게 할 수 있습니다.");
logger.info("--- 학습 완료 ---");

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `nodejs/Step4_AdvancedFeatures` 디렉토리를 생성.
2. `index.js` 파일을 이 파일의 내용으로 저장.
3. `nodejs/Step4_AdvancedFeatures` 디렉토리에 `.env` 파일을 생성하고 다음 내용을 추가.
   ```
   PORT=3000
   NODE_ENV=development
   API_KEY=your_super_secret_api_key_12345
   ```
4. 터미널에서 `nodejs/Step4_AdvancedFeatures` 디렉토리로 이동.
5. `npm install` 명령을 실행하여 의존성 설치 (`dotenv`, `express`, `winston`).
6. `npm start` 명령으로 애플리케이션 실행.
   - 마스터 프로세스가 여러 워커 프로세스를 생성하는 것을 콘솔에서 확인할 수 있습니다.
   - `http://localhost:3000`으로 접근하여 워커 프로세스가 요청을 번갈아 처리하는 것을 확인.
   - `error.log` 및 `combined.log` 파일이 생성되어 로그가 기록되는지 확인.
*/
