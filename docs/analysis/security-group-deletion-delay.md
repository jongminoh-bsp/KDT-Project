# 보안 그룹 삭제 지연 문제 분석

## 🔍 문제 현상
- **발생 시점**: 2025-09-17 인프라 정리 작업 중
- **대상 리소스**: `mgmt-sg` (sg-0d662f4b448f41be1)
- **소요 시간**: 14분 13초
- **상태**: "Still destroying..." 반복 출력

## 📊 삭제 시간 분석

### 리소스별 삭제 시간
```
EC2 인스턴스 (q-dev):    1분 11초  ✅ 정상
EC2 인스턴스 (mgmt):     1분 21초  ✅ 정상
RDS 인스턴스:           4분 03초  ✅ 정상 (스냅샷 생성)
EKS 노드 그룹:          2분 16초  ✅ 정상
mgmt-sg 보안 그룹:      14분 13초 ❌ 비정상
```

## 🔍 원인 분석

### 1. 의존성 문제
보안 그룹이 다른 리소스에서 참조되고 있을 가능성:
- EC2 인스턴스의 네트워크 인터페이스
- EKS 노드 그룹의 ENI (Elastic Network Interface)
- Lambda 함수 또는 기타 서비스

### 2. AWS API 제한
- 보안 그룹 삭제 시 AWS 내부 검증 과정
- 네트워크 인터페이스 정리 대기
- 의존성 체크 지연

### 3. Terraform 상태 불일치
- 실제 AWS 리소스와 Terraform 상태 간 불일치
- 이미 삭제된 리소스에 대한 반복 시도

## 🛠️ 개선 방안

### 1. 명시적 의존성 관리
```hcl
# 현재 (문제 있는 구조)
resource "aws_instance" "mgmt" {
  vpc_security_group_ids = [aws_security_group.mgmt.id]
}

resource "aws_security_group" "mgmt" {
  # 의존성이 명시적이지 않음
}

# 개선된 구조
resource "aws_security_group" "mgmt" {
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "mgmt" {
  vpc_security_group_ids = [aws_security_group.mgmt.id]
  
  depends_on = [aws_security_group.mgmt]
}
```

### 2. 삭제 순서 최적화
```hcl
# 보안 그룹에 명시적 의존성 추가
resource "aws_security_group" "mgmt" {
  lifecycle {
    prevent_destroy = false
  }
  
  # 다른 리소스가 먼저 삭제되도록 보장
  depends_on = [
    aws_instance.mgmt,
    aws_instance.q_dev
  ]
}
```

### 3. 타임아웃 설정
```hcl
resource "aws_security_group" "mgmt" {
  timeouts {
    delete = "5m"  # 5분 후 타임아웃
  }
}
```

### 4. 삭제 전 검증 스크립트
```bash
#!/bin/bash
# check-sg-dependencies.sh

SG_ID=$1
echo "Checking dependencies for Security Group: $SG_ID"

# 네트워크 인터페이스 확인
aws ec2 describe-network-interfaces \
  --filters "Name=group-id,Values=$SG_ID" \
  --query 'NetworkInterfaces[*].{ID:NetworkInterfaceId,Status:Status}'

# EC2 인스턴스 확인
aws ec2 describe-instances \
  --filters "Name=instance.group-id,Values=$SG_ID" \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name}'
```

## 🚀 구현 계획

### Phase 1: 즉시 적용 가능한 개선
1. **lifecycle 규칙 추가**: create_before_destroy, 타임아웃 설정
2. **명시적 depends_on**: 리소스 간 의존성 명확화
3. **삭제 순서 최적화**: 보안 그룹을 마지막에 삭제

### Phase 2: 고급 최적화
1. **사전 검증 스크립트**: 삭제 전 의존성 체크
2. **병렬 삭제 최적화**: 독립적인 리소스 동시 삭제
3. **모니터링 추가**: 삭제 시간 추적 및 알림

## 📈 예상 개선 효과
- **삭제 시간**: 14분 → 2-3분으로 단축
- **안정성**: 의존성 오류 방지
- **예측 가능성**: 일관된 삭제 시간
