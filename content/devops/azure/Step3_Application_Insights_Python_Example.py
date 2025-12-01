# Azure Application Insights 애플리케이션 통합 파이썬 예시
# 이 파일은 Azure 모니터링 대시보드 학습 계획의 3단계인 'Application Insights 활용'을 위한
# 개념적인 파이썬 코드 예시입니다.
# 파이썬 애플리케이션에 Application Insights SDK를 통합하여 원격 분석 데이터를 전송하는
# 방법을 보여줍니다.

# 필요한 라이브러리 설치:
# pip install opencensus-ext-azure

# -----------------------------------------------------------------------------
# 1. Application Insights 리소스 생성 (Azure Portal 또는 Azure CLI)
# -----------------------------------------------------------------------------
# Application Insights를 사용하려면 먼저 Azure에서 Application Insights 리소스를
# 생성해야 합니다. 이 리소스는 애플리케이션에서 전송되는 원격 분석 데이터를
# 수집하고 저장합니다.

# Azure CLI를 통한 리소스 생성 예시 (개념적)
# az monitor app-insights component create \
#   --app "my-python-app-insights" \
#   --location "koreacentral" \
#   --resource-group "my-monitor-rg" \
#   --kind web \
#   --application-type python

# 2. Instrumentation Key (계측 키) 또는 Connection String (연결 문자열)
# -----------------------------------------------------------------------------
# Application Insights 리소스를 생성하면 'Instrumentation Key' 또는 'Connection String'을
# 얻을 수 있습니다. 이 값은 애플리케이션이 어떤 Application Insights 리소스로 데이터를
# 보낼지 식별하는 데 사용됩니다. 보안상 환경 변수로 관리하는 것이 좋습니다.

# 예시:
# export APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=YOUR_INSTRUMENTATION_KEY;IngestionEndpoint=https://koreacentral-0.in.applicationinsights.azure.com/"

# -----------------------------------------------------------------------------
# 3. 파이썬 애플리케이션에 Application Insights 통합
# -----------------------------------------------------------------------------

from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.ext.azure.metrics_exporter import AzureMetricsExporter
from opencensus.ext.azure.trace_exporter import AzureExporter
from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module
from opencensus.tags import tag_map as tag_map_module

import logging
import os
import time
import random

# 환경 변수에서 Connection String 가져오기
CONNECTION_STRING = os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING")

if not CONNECTION_STRING:
    print("WARNING: APPLICATIONINSIGHTS_CONNECTION_STRING 환경 변수가 설정되지 않았습니다.")
    print("Application Insights로 데이터가 전송되지 않습니다. 학습 목적으로만 실행됩니다.")
    print("실제 사용 시에는 유효한 Connection String을 설정해야 합니다.")

# -----------------------------------------------------------------------------
# 3.1. 로깅 통합 (Logging Integration)
# -----------------------------------------------------------------------------
# 파이썬의 표준 로깅 모듈을 Application Insights와 통합합니다.
# 애플리케이션에서 발생하는 로그 메시지를 Application Insights로 전송할 수 있습니다.
print("--- 로깅 통합 예시 ---")
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

if CONNECTION_STRING:
    logger.addHandler(AzureLogHandler(connection_string=CONNECTION_STRING))

logger.info("Application Insights로 전송될 정보 로그입니다.")
logger.warning("주의: 이 메시지는 경고 수준의 로그입니다.")
try:
    raise ValueError("강제로 발생시킨 오류입니다!")
except ValueError:
    logger.exception("예외가 발생했습니다. Application Insights에서 추적될 것입니다.")
print("로그 전송 완료.")
print("-" * 30)

# -----------------------------------------------------------------------------
# 3.2. 메트릭 통합 (Metrics Integration)
# -----------------------------------------------------------------------------
# 사용자 지정 메트릭을 정의하고 Application Insights로 전송합니다.
# 예를 들어, 특정 함수의 실행 시간이나 커스텀 이벤트 카운트 등을 모니터링할 수 있습니다.
print("--- 메트릭 통합 예시 ---")
stats = stats_module.stats
mmap = stats.stats_recorder

# 메트릭 정의 (Measure)
m_latency_ms = measure_module.MeasureFloat(
    "task_latency", "The task latency in milliseconds", "ms"
)
m_task_count = measure_module.MeasureInt("task_count", "Number of tasks executed", "1")

# 뷰 정의 (View) - 메트릭 데이터를 어떻게 집계하고 시각화할지 정의
latency_view = view_module.View(
    "task_latency_distribution",
    "The distribution of task latencies",
    [],
    m_latency_ms,
    aggregation_module.DistributionAggregation([10.0, 20.0, 50.0, 100.0, 200.0]),
)
count_view = view_module.View(
    "task_count", "The count of tasks", [], m_task_count, aggregation_module.CountAggregation()
)

# 뷰 등록
stats.view_manager.register_view(latency_view)
stats.view_manager.register_view(count_view)

# 메트릭 익스포터 설정
if CONNECTION_STRING:
    exporter = AzureMetricsExporter(connection_string=CONNECTION_STRING)
    stats.view_manager.register_exporter(exporter)

# 메트릭 기록
print("사용자 지정 메트릭 기록 중...")
for _ in range(5):
    latency = random.uniform(5.0, 150.0)
    mmap.record_measurement(m_latency_ms.create_measurement(latency))
    mmap.record_measurement(m_task_count.create_measurement(1))
    print(f"  - 작업 실행 (지연 시간: {latency:.2f}ms)")
    time.sleep(1) # 실제 환경에서는 비동기적으로 전송될 수 있습니다.

print("메트릭 전송 완료.")
print("-" * 30)

# -----------------------------------------------------------------------------
# 3.3. 분산 추적 (Distributed Tracing) 통합 (OpenCensus Tracer)
# -----------------------------------------------------------------------------
# 여러 서비스에 걸친 요청의 흐름을 추적하여 성능 병목 지점을 파악합니다.
# Flask, Django 등 웹 프레임워크와 쉽게 통합됩니다.
print("--- 분산 추적 통합 예시 ---")
from opencensus.trace.samplers import AlwaysOnSampler
from opencensus.trace.tracer import Tracer

if CONNECTION_STRING:
    tracer = Tracer(
        exporter=AzureExporter(connection_string=CONNECTION_STRING),
        sampler=AlwaysOnSampler(),
    )
else:
    tracer = Tracer(sampler=AlwaysOnSampler()) # Connection String 없으면 콘솔 출력

with tracer.span(name='parent_operation') as span:
    span.add_annotation("부모 작업 시작")
    time.sleep(0.1) # 작업 시뮬레이션
    with tracer.span(name='child_operation_1') as child_span_1:
        child_span_1.add_annotation("자식 작업 1 시작")
        time.sleep(0.05)
        child_span_1.add_annotation("자식 작업 1 완료")
    with tracer.span(name='child_operation_2') as child_span_2:
        child_span_2.add_annotation("자식 작업 2 시작")
        time.sleep(0.08)
        child_span_2.add_annotation("자식 작업 2 완료")
    span.add_annotation("부모 작업 완료")

print("분산 추적 정보 전송 완료.")
print("-" * 30)

print("\nApplication Insights 통합 파이썬 예시 실행 완료.")
print("Application Insights 리소스에서 로그, 메트릭, 추적 데이터를 확인하세요.")
