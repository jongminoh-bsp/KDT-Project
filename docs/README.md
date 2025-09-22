# KDT-Project Documentation

## 📋 프로젝트 개요

Skyline 항공예약시스템을 AWS EKS 환경에 배포하는 전체 과정을 문서화합니다.

## 📚 문서 구조

### 1. [인프라 구축](./infrastructure/)
- Terraform 코드 자동 생성
- AWS 리소스 프로비저닝
- EKS 클러스터 설정

### 2. [애플리케이션 배포](./application/)
- Spring Boot 애플리케이션 분석
- Docker 이미지 빌드
- 데이터베이스 초기화

### 3. [Kubernetes 배포](./deployment/)
- K8s 매니페스트 작성
- Ingress 및 도메인 설정
- 모니터링 및 로깅

## 🎯 최종 결과

- **도메인**: `www.greenbespinglobal.store`
- **인프라**: AWS EKS + RDS + VPC
- **애플리케이션**: Spring Boot + React SPA
- **배포**: Kubernetes + ALB Ingress

## 🚀 주요 성과

1. ✅ **완전 자동화된 인프라 코드 생성**
2. ✅ **SPA 라우팅 완벽 지원**
3. ✅ **도메인 기반 HTTPS 접근**
4. ✅ **확장 가능한 K8s 아키텍처**

---

각 섹션별 상세 문서는 해당 디렉터리를 참조하세요.
