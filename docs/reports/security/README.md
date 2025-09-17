# 🔒 Security Reports

보안 강화, 취약점 수정, 권한 관리 등 보안 관련 리포트

## 📚 리포트 목록

| 번호 | 제목 | 날짜 | 상태 | 요약 |
|------|------|------|------|------|
| 001 | [보안 개선](./001-security-improvements.md) | 2025-09-17 | ✅ 완료 | AWS Secrets Manager 통합 및 보안 그룹 권한 최소화 |
| 002 | [보안 그룹 순환 참조 핫픽스](./002-security-group-circular-reference-hotfix.md) | 2025-09-17 | ✅ 완료 | Terraform 순환 참조 문제 해결 |
| 006 | [EKS 접근 권한 문제 해결](./006-eks-access-permission-fix.md) | 2025-09-17 | ✅ 완료 | EKS 클러스터 접근 권한 설정 및 자동화 |

## 🎯 주요 성과
- 평문 패스워드 → AWS Secrets Manager 마이그레이션
- 보안 그룹 권한 최소화 (0.0.0.0/0 제거)
- Terraform 순환 참조 문제 해결
- EKS 접근 권한 자동화 및 보안 강화
- 클러스터 접근 로깅 및 IMDSv2 강제 적용
