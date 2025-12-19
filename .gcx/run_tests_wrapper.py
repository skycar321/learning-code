import sys
import os
import unittest

# 구현 코드가 있는 경로를 시스템 경로에 추가
sys.path.append(os.path.abspath(".gcx/02_implementation"))

# 테스트 실행
if __name__ == "__main__":
    loader = unittest.TestLoader()
    # 테스트 파일이 있는 디렉토리 지정
    start_dir = ".gcx/02_implementation/tests"
    suite = loader.discover(start_dir)

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    if not result.wasSuccessful():
        sys.exit(1)
