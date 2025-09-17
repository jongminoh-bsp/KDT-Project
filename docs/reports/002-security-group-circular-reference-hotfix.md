# 작업 리포트 #002: 보안 그룹 순환 참조 핫픽스

## 📋 작업 정보
- **작업일**: 2025-09-17
- **브랜치**: `hotfix/security-group-circular-reference`
- **담당자**: Q Developer + 사용자
- **우선순위**: Critical (Hotfix)

## 🎯 작업 목표
보안 그룹 간 순환 참조로 인한 Terraform 배포 오류 해결

## 🔍 발견된 문제점

### 순환 참조 오류
```hcl
# NodeGroup SG에서 Cluster SG 참조
ingress {
  security_groups = [aws_security_group.cluster.id]
}

# Cluster SG에서 NodeGroup SG 참조  
ingress {
  security_groups = [aws_security_group.ng.id]
}
```

**오류 메시지**: Terraform circular dependency error

## ✅ 구현된 해결책

### 보안 그룹 규칙 분리
- **변경 파일**: `modules/sg/main.tf`
- **해결 방법**: `aws_security_group_rule` 리소스로 규칙 분리

### Before (문제 코드)
```hcl
resource "aws_security_group" "ng" {
  ingress {
    security_groups = [aws_security_group.cluster.id]  # 순환 참조!
  }
}
```

### After (해결 코드)
```hcl
resource "aws_security_group" "ng" {
  # 기본 설정만
}

resource "aws_security_group_rule" "ng_from_cluster" {
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.ng.id
}
```

## 📊 변경 사항 요약
```
1 file changed, 41 insertions(+), 33 deletions(-)
- modules/sg/main.tf: 보안 그룹 규칙을 별도 리소스로 분리
```

### 분리된 규칙들
- `ng_from_cluster`: 컨트롤 플레인 → 노드 그룹 (1025-65535)
- `ng_https_from_cluster`: 컨트롤 플레인 → 노드 그룹 (443)
- `cluster_from_ng`: 노드 그룹 → 컨트롤 플레인 (443)
- `cluster_from_mgmt`: 관리 서버 → 컨트롤 플레인 (443)

## 🔒 보안 정책 유지
- ✅ 동일한 보안 수준 유지
- ✅ 최소 권한 원칙 적용
- ✅ 순환 참조 문제 해결

## 🚀 배포 준비 상태
- [x] 순환 참조 오류 해결
- [x] 보안 정책 검증 완료
- [x] 핫픽스 PR 준비 완료

## 📝 후속 작업
1. 기존 보안 개선 PR과 충돌 해결
2. 통합 테스트 진행
3. 다른 환경에도 동일한 패턴 적용

## 💡 학습 포인트
- Terraform 순환 참조 해결 방법
- `aws_security_group_rule` 리소스 활용
- 핫픽스 브랜치 전략 적용
