# Terraform 변수 보안 가이드

## 🔒 변수 보안 분류

### ✅ 안전한 변수 (tfvars 파일에 저장 가능)

#### 인프라 메타데이터
- `region`: AWS 리전 (공개 정보)
- `project`, `environment`: 프로젝트 식별자
- `cluster_name`: EKS 클러스터 이름 (공개)
- `cluster_version`: Kubernetes 버전 (공개)

#### 리소스 설정
- `instance_type`: EC2 인스턴스 타입 (공개)
- `ami_id`: AMI ID (공개)
- `db_name`: 데이터베이스 이름 (일반적으로 비민감)
- `db_username`: 데이터베이스 사용자명 (일반적으로 비민감)

#### 네트워크 설정
- `vpc_cidr`: VPC CIDR 블록
- `subnet_cidrs`: 서브넷 CIDR 블록들
- RDS endpoint (자동 생성, 공개 정보)

### ⚠️ 주의가 필요한 변수

#### EC2 키페어
```hcl
# 현재 방식 (허용되지만 권장하지 않음)
key_name = "ojm-key"

# 권장 방식: SSM Session Manager 사용
# EC2 인스턴스에 키페어 없이 접근
```

#### 태그 정보
```hcl
# 조직 구조가 노출될 수 있음
common_tags = {
  Owner       = "team-name"  # 팀 구조 노출 가능
  CostCenter  = "12345"      # 비용 센터 정보
}
```

### ❌ 절대 변수로 두면 안 되는 것들

#### 인증 정보
- `db_password`: ✅ AWS Secrets Manager로 이동 완료
- API 키, 토큰
- 인증서 내용
- SSH 프라이빗 키

#### 민감한 네트워크 정보
- VPN 설정
- 내부 IP 주소 (경우에 따라)
- 보안 그룹 규칙의 특정 IP (경우에 따라)

## 🛡️ 보안 강화 방법

### 1. AWS Secrets Manager 활용
```hcl
# 현재 구현 (올바름)
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.name_prefix}-rds-password"
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
}
```

### 2. 환경 변수 사용
```bash
# 민감한 정보는 환경 변수로
export TF_VAR_key_name="ojm-key"
terraform apply
```

### 3. .gitignore 설정
```gitignore
# 이미 설정됨
*.tfvars
!terraform.tfvars.example
terraform.tfstate*
.terraform/
```

### 4. Terraform Cloud/Enterprise 사용
```hcl
# 민감한 변수를 UI에서 관리
variable "sensitive_data" {
  description = "Sensitive information"
  type        = string
  sensitive   = true
}
```

## 📋 현재 프로젝트 보안 상태

### ✅ 잘 구현된 부분
- 패스워드를 Secrets Manager로 이동
- .gitignore에 민감한 파일 제외
- terraform.tfvars.example 제공

### 🔄 개선 가능한 부분
- EC2 키페어 → SSM Session Manager 전환 고려
- 환경별 변수 분리 (dev/staging/prod)
- Terraform Cloud 도입 검토

## 💡 권장사항

### 즉시 적용 가능
1. **주석 추가**: 각 변수의 보안 수준 명시
2. **문서화**: 보안 가이드라인 팀 공유
3. **정기 검토**: 분기별 보안 변수 점검

### 장기 계획
1. **SSM Session Manager**: EC2 키페어 의존성 제거
2. **환경 분리**: dev/staging/prod 변수 분리
3. **자동화**: 민감한 정보 자동 로테이션

## 🔍 보안 체크리스트

- [ ] 패스워드가 평문으로 저장되지 않았는가?
- [ ] API 키가 코드에 하드코딩되지 않았는가?
- [ ] .gitignore에 민감한 파일이 제외되었는가?
- [ ] 변수에 sensitive = true 플래그가 적절히 설정되었는가?
- [ ] 팀원들이 보안 가이드라인을 숙지했는가?

현재 구조는 보안상 적절합니다. db_name, db_username, RDS endpoint는 변수로 두어도 안전합니다!
