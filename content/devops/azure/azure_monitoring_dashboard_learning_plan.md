# Azure 모니터링 대시보드 사용법 학습 계획

## 개요 (Overview)
Azure 모니터링 대시보드는 클라우드 환경에서 실행되는 애플리케이션, 인프라 및 네트워크의 성능과 가용성을 통합적으로 파악하고 관리하기 위한 핵심 도구입니다. 이 학습 계획은 Azure Monitor, Log Analytics, Application Insights 등 Azure의 다양한 모니터링 서비스를 활용하여 효과적인 대시보드를 구성하고 운영하는 방법을 실무적인 관점에서 다루는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Azure Monitor의 기본 개념 및 구성 요소 이해
*   Log Analytics 워크스페이스를 활용한 로그 데이터 수집 및 분석
*   Application Insights를 이용한 애플리케이션 성능 모니터링
*   Azure 대시보드 생성, 사용자 지정 및 공유
*   경고(Alerts) 및 자동화된 응답 구성

## 학습 내용 (Learning Content)

### 1단계: Azure Monitor 기본 (Azure Monitor Basics)
*   Azure Monitor란 무엇인가? (What is Azure Monitor?) - 기능 및 아키텍처
*   메트릭(Metrics) 및 로그(Logs) 이해 (Understanding Metrics & Logs)
*   Azure 리소스에 대한 기본 모니터링 설정
*   모니터링 데이터 소스 (Monitoring Data Sources) - VM, Web Apps, Database 등

### 2단계: Log Analytics 및 KQL (Log Analytics & KQL)
*   Log Analytics 워크스페이스 생성 및 관리 (Creating & Managing Log Analytics Workspace)
*   데이터 수집 구성 (Configuring Data Collection) - VM 확장, 에이전트
*   Kusto Query Language (KQL) 기초 (KQL Basics) - 쿼리 작성 및 실행
*   일반적인 KQL 쿼리 활용 (Common KQL Queries) - 성능 분석, 오류 진단
*   워크북(Workbooks)을 이용한 대화형 보고서 생성

### 3단계: Application Insights 활용 (Utilizing Application Insights)
*   Application Insights란 무엇인가? (What is Application Insights?) - APM 기능
*   애플리케이션에 Application Insights 통합 (Integrating App Insights with Applications) - SDK 설치
*   Live Metrics Stream (실시간 메트릭스 스트림)
*   성능 병목 현상 및 예외 추적 (Tracking Performance Bottlenecks & Exceptions)
*   사용자 행동 분석 (User Behavior Analysis) - 트래픽, 사용량
*   분산 추적(Distributed Tracing) 및 종속성 모니터링

### 4단계: Azure 대시보드 구성 및 사용자 지정 (Configuring & Customizing Azure Dashboards)
*   새 대시보드 생성 (Creating New Dashboards)
*   타일 추가 및 사용자 지정 (Adding & Customizing Tiles) - 메트릭 차트, 로그 쿼리, Application Insights 시각화
*   대시보드 공유 및 접근 제어 (Sharing Dashboards & Access Control)
*   템플릿(Templates)을 이용한 대시보드 관리

### 5단계: 경고 및 자동화된 응답 (Alerts & Automated Responses)
*   경고 규칙 생성 (Creating Alert Rules) - 메트릭 기반, 로그 기반
*   경고 조건 및 임계값 설정 (Setting Alert Conditions & Thresholds)
*   액션 그룹(Action Groups) 구성 (Configuring Action Groups) - 이메일, SMS, 웹훅
*   자동 복구 및 자동 확장 (Auto-healing & Auto-scaling) - Logic Apps, Azure Functions 연동

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-5시간 (총 15-25시간)

## 실습 과제 (Practical Exercises)
*   Azure 웹 앱 또는 VM에 대한 모니터링 대시보드 구축 (Build a monitoring dashboard for an Azure Web App or VM)
*   특정 성능 지표에 대한 경고 규칙 설정 및 알림 수신 (Set up alert rules for specific performance metrics)
*   Log Analytics를 사용하여 웹 서버 로그 분석 및 시각화 (Analyze and visualize web server logs using Log Analytics)
*   간단한 애플리케이션에 Application Insights 통합 및 성능 데이터 확인 (Integrate App Insights into a simple application)

## 참고 자료 (References)
*   Azure Monitor 공식 문서 (Azure Monitor Official Documentation)
*   Microsoft Learn - Azure 모니터링 관련 모듈 (Microsoft Learn - Azure Monitoring Modules)
*   Azure Application Insights by Mike Bridge
