# Skyline Kubernetes Deployment

Skyline 항공예약시스템의 Kubernetes 배포 매니페스트입니다.

## 📁 구조

```
skyline-k8s/
├── base/                    # 기본 Kubernetes 리소스
│   ├── namespace.yaml       # 네임스페이스
│   ├── configmap.yaml       # 애플리케이션 설정
│   ├── secret.yaml          # 데이터베이스 자격증명
│   ├── deployment.yaml      # 애플리케이션 배포
│   ├── service.yaml         # 서비스
│   ├── ingress.yaml         # ALB 인그레스
│   ├── hpa.yaml            # 오토스케일링
│   └── kustomization.yaml   # Kustomize 설정
├── overlays/dev/           # 개발환경 오버레이
│   ├── kustomization.yaml   # 개발환경 설정
│   └── deployment-patch.yaml # 개발환경 패치
├── build-and-push.sh       # Docker 빌드 및 ECR 푸시
├── deploy.sh              # 배포 스크립트
└── README.md              # 이 파일
```

## 🚀 배포 방법

### 1. 사전 준비

```bash
# EKS 클러스터 접근 설정
aws eks update-kubeconfig --region ap-northeast-2 --name skyline-dev-cluster

# 클러스터 연결 확인
kubectl get nodes
```

### 2. Docker 이미지 빌드 및 푸시

```bash
# ECR에 이미지 빌드 및 푸시
./build-and-push.sh
```

### 3. 애플리케이션 배포

```bash
# 자동 배포 스크립트 실행
./deploy.sh
```

또는 수동 배포:

```bash
# 네임스페이스 생성
kubectl apply -f base/namespace.yaml

# 데이터베이스 비밀번호 설정
DB_PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id skyline-dev-db-credentials \
    --region ap-northeast-2 \
    --query SecretString --output text | jq -r .password)

kubectl create secret generic skyline-db-secret \
    --namespace=skyline \
    --from-literal=DB_HOST=skyline-dev-db.c5d2wfqufspp.ap-northeast-2.rds.amazonaws.com \
    --from-literal=DB_PORT=3306 \
    --from-literal=DB_NAME=skyline \
    --from-literal=DB_USER=skyline_user \
    --from-literal=DB_PASSWORD="$DB_PASSWORD"

# Kustomize로 배포
kubectl apply -k overlays/dev/
```

## 📊 배포된 리소스

### 애플리케이션
- **Deployment**: `skyline-app` (2 replicas)
- **Service**: `skyline-service` (ClusterIP)
- **Ingress**: `skyline-ingress` (ALB)
- **HPA**: CPU/Memory 기반 오토스케일링 (2-10 pods)

### 설정
- **ConfigMap**: `skyline-config` (애플리케이션 설정)
- **Secret**: `skyline-db-secret` (데이터베이스 자격증명)

### 네트워킹
- **Namespace**: `skyline`
- **Load Balancer**: AWS ALB (인터넷 연결)

## 🔍 모니터링 및 확인

### 배포 상태 확인
```bash
# Pod 상태 확인
kubectl get pods -n skyline

# 서비스 확인
kubectl get services -n skyline

# 인그레스 확인
kubectl get ingress -n skyline

# HPA 상태 확인
kubectl get hpa -n skyline
```

### 로그 확인
```bash
# 애플리케이션 로그
kubectl logs -f deployment/skyline-app -n skyline

# 특정 Pod 로그
kubectl logs -f <pod-name> -n skyline
```

### 애플리케이션 접근
```bash
# Load Balancer URL 확인
kubectl get ingress skyline-ingress -n skyline -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# 헬스체크
curl http://<ALB-URL>/health

# API 테스트
curl http://<ALB-URL>/api/flights
```

## 🔧 설정 변경

### 환경별 설정
- **개발환경**: `overlays/dev/`
- **운영환경**: `overlays/prod/` (추가 예정)

### 리소스 조정
```bash
# 레플리카 수 변경
kubectl scale deployment skyline-app --replicas=3 -n skyline

# HPA 설정 변경
kubectl edit hpa skyline-hpa -n skyline
```

## 🚨 문제해결

### 일반적인 문제들

1. **Pod가 시작되지 않는 경우**
   ```bash
   kubectl describe pod <pod-name> -n skyline
   kubectl logs <pod-name> -n skyline
   ```

2. **데이터베이스 연결 오류**
   ```bash
   # Secret 확인
   kubectl get secret skyline-db-secret -n skyline -o yaml
   
   # RDS 연결 테스트
   kubectl run mysql-client --image=mysql:8.0 -it --rm --restart=Never -- \
     mysql -h skyline-dev-db.c5d2wfqufspp.ap-northeast-2.rds.amazonaws.com -u skyline_user -p
   ```

3. **Load Balancer 접근 불가**
   ```bash
   # ALB 상태 확인
   kubectl describe ingress skyline-ingress -n skyline
   
   # AWS Load Balancer Controller 로그
   kubectl logs -n kube-system deployment/aws-load-balancer-controller
   ```

## 📈 성능 최적화

### 리소스 요청/제한
- **CPU**: 250m (요청) / 500m (제한)
- **Memory**: 512Mi (요청) / 1Gi (제한)

### 오토스케일링
- **최소**: 2 pods
- **최대**: 10 pods
- **CPU 임계값**: 70%
- **Memory 임계값**: 80%

## 🔄 업데이트 및 롤백

### 이미지 업데이트
```bash
# 새 이미지 빌드 및 푸시
./build-and-push.sh

# 배포 업데이트
kubectl set image deployment/skyline-app skyline=646558765106.dkr.ecr.ap-northeast-2.amazonaws.com/skyline-dev:new-tag -n skyline

# 롤아웃 상태 확인
kubectl rollout status deployment/skyline-app -n skyline
```

### 롤백
```bash
# 롤아웃 히스토리 확인
kubectl rollout history deployment/skyline-app -n skyline

# 이전 버전으로 롤백
kubectl rollout undo deployment/skyline-app -n skyline
```
