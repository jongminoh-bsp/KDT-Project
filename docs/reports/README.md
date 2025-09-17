# 작업 리포트 관리

## 📚 리포트 목록

| 번호 | 제목 | 날짜 | 우선순위 | 상태 | 브랜치 |
|------|------|------|----------|------|--------|
| 000 | [브랜치 전략 수립](./000-branch-strategy-setup.md) | 2025-09-17 | High | ✅ 완료 | `main`, `develop`, `staging` |
| 001 | [보안 개선](./001-security-improvements.md) | 2025-09-17 | Critical | ✅ 완료 | `feature/security-improvements` |
| 002 | [보안 그룹 순환 참조 핫픽스](./002-security-group-circular-reference-hotfix.md) | 2025-09-17 | Critical | ✅ 완료 | `hotfix/security-group-circular-reference` |

## 📋 리포트 작성 가이드

### 파일명 규칙
```
{번호}-{작업명}.md
예: 001-security-improvements.md
```

### 필수 포함 항목
- 작업 정보 (날짜, 브랜치, 담당자)
- 작업 목표
- 발견된 문제점
- 구현된 해결책
- 변경 사항 요약
- 후속 작업

### 우선순위 분류
- **Critical**: 보안, 장애 관련
- **High**: 성능, 안정성 개선
- **Medium**: 기능 추가, 리팩토링
- **Low**: 문서화, 코드 정리

## 🔄 업데이트 프로세스
1. 작업 완료 시 리포트 작성
2. 이 README.md 테이블 업데이트
3. 관련 브랜치와 함께 커밋
