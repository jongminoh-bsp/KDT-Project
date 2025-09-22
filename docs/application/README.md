# 애플리케이션 배포 가이드

## 🎯 개요

Skyline 항공예약시스템 Spring Boot 애플리케이션을 분석하고 컨테이너화하는 과정을 설명합니다.

## 📋 애플리케이션 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                   Frontend (React)                      │
│  ┌─────────────────────────────────────────────────────┐│
│  │  • 항공편 검색 (Search)                              ││
│  │  • 예약 관리 (Reservations)                         ││
│  │  • 대시보드 (Dashboard)                              ││
│  │  • SPA 라우팅 지원                                   ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                Backend (Spring Boot)                    │
│  ┌─────────────────────────────────────────────────────┐│
│  │  • REST API (/api/*)                                ││
│  │  • SPA Controller (/* → index.html)                 ││
│  │  • JPA/Hibernate ORM                                ││
│  │  • Health Check (/health)                           ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                   Database (MySQL)                      │
│  ┌─────────────────────────────────────────────────────┐│
│  │  • airports (공항 정보)                              ││
│  │  • flights (항공편 정보)                             ││
│  │  • reservations (예약 정보)                          ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

## 🔍 1단계: 애플리케이션 분석

### 1.1 프로젝트 구조 분석

```bash
skyline_system_demo/
├── src/main/java/com/example/skyline/
│   ├── SkylineApplication.java          # 메인 애플리케이션
│   ├── config/
│   │   └── WebConfig.java              # CORS 설정
│   ├── controller/
│   │   ├── FlightController.java       # 항공편 API
│   │   ├── ReservationController.java  # 예약 API
│   │   └── SpaController.java          # SPA 라우팅
│   ├── entity/
│   │   ├── Airport.java                # 공항 엔티티
│   │   ├── Flight.java                 # 항공편 엔티티
│   │   └── Reservation.java            # 예약 엔티티
│   ├── repository/
│   │   ├── AirportRepository.java
│   │   ├── FlightRepository.java
│   │   └── ReservationRepository.java
│   └── service/
│       ├── FlightService.java
│       └── ReservationService.java
├── src/main/resources/
│   ├── application.yml                 # 설정 파일
│   ├── data.sql                        # 초기 데이터
│   └── static/                         # React 빌드 파일
└── frontend/                           # React 소스
    ├── src/
    │   ├── components/
    │   ├── pages/
    │   └── App.jsx
    └── package.json
```

### 1.2 핵심 기능 분석

#### SPA Controller 구현
```java
@Controller
public class SpaController {
    @RequestMapping(value = {"/", "/search", "/reservations", "/dashboard"})
    public String spa() {
        return "forward:/index.html";
    }
}
```

#### API 엔드포인트
- `GET /api/flights` - 항공편 목록 조회
- `GET /api/flights/search` - 항공편 검색
- `POST /api/reservations` - 예약 생성
- `GET /api/reservations` - 예약 목록 조회

## 🐳 2단계: Docker 이미지 빌드

### 2.1 멀티스테이지 Dockerfile 작성

```dockerfile
# Frontend 빌드 스테이지
FROM node:18-alpine as frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build

# Backend 빌드 스테이지
FROM maven:3.9-eclipse-temurin-17 as backend-build
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline
COPY src/ ./src/
COPY --from=frontend-build /app/frontend/dist ./src/main/resources/static/
RUN mvn clean package -DskipTests

# 런타임 스테이지
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -g 1001 -S skyline && adduser -u 1001 -S skyline -G skyline
WORKDIR /app
COPY --from=backend-build /app/target/*.jar app.jar
RUN chown skyline:skyline app.jar
USER skyline
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
CMD ["java", "-jar", "-Dspring.profiles.active=production", "app.jar"]
```

### 2.2 이미지 빌드 및 푸시

```bash
# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 646558765106.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 빌드
docker build -t skyline-app:latest .

# 태그 및 푸시
docker tag skyline-app:latest 646558765106.dkr.ecr.ap-northeast-2.amazonaws.com/skyline-app-lyjking:1.4
docker push 646558765106.dkr.ecr.ap-northeast-2.amazonaws.com/skyline-app-lyjking:1.4
```

## 🗄️ 3단계: 데이터베이스 초기화

### 3.1 초기 데이터 구조

#### 공항 데이터 (10개)
```sql
INSERT INTO airports (airport_code, airport_name, city, country) VALUES
('ICN', '인천국제공항', '서울', '대한민국'),
('GMP', '김포국제공항', '서울', '대한민국'),
('PUS', '김해국제공항', '부산', '대한민국'),
-- ... 7개 더
```

#### 항공편 데이터 (8개)
```sql
INSERT INTO flights (flight_number, departure_airport, arrival_airport, departure_time, arrival_time, price, available_seats) VALUES
('KE001', 'ICN', 'NRT', '2025-09-23 09:00:00', '2025-09-23 11:30:00', 450000, 180),
-- ... 7개 더
```

#### 예약 데이터 (4개)
```sql
INSERT INTO reservations (passenger_name, passenger_email, flight_id, seat_number, reservation_date, status) VALUES
('김철수', 'kim@example.com', 1, '12A', '2025-09-22 10:00:00', 'CONFIRMED'),
-- ... 3개 더
```

### 3.2 Kubernetes Job으로 DB 초기화

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: skyline-db-init
  namespace: skyline
spec:
  template:
    spec:
      containers:
      - name: db-init
        image: mysql:8.0
        command: ["/bin/sh"]
        args:
        - -c
        - |
          mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME << 'EOF'
          -- 초기 데이터 삽입 SQL
          EOF
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: skyline-db-secret
              key: DB_HOST
      restartPolicy: OnFailure
```

## 📊 4단계: 애플리케이션 검증

### 4.1 기능 테스트

```bash
# 헬스 체크
curl http://localhost:8080/health

# 항공편 조회
curl http://localhost:8080/api/flights

# SPA 라우팅 테스트
curl http://localhost:8080/search  # → index.html 반환
curl http://localhost:8080/dashboard  # → index.html 반환
```

### 4.2 성능 확인

- **메모리 사용량**: ~512MB
- **시작 시간**: ~30초
- **응답 시간**: <100ms (API)
- **동시 접속**: 100+ 지원

## 🔧 트러블슈팅

### 일반적인 문제들

1. **SPA 라우팅 404 에러**
   - SpaController 누락 확인
   - static 리소스 경로 확인

2. **데이터베이스 연결 실패**
   - 환경변수 설정 확인
   - 네트워크 보안 그룹 확인

3. **Docker 빌드 실패**
   - 네트워크 연결 확인
   - 의존성 캐시 정리

## 📝 다음 단계

애플리케이션 준비 완료 후 [Kubernetes 배포](../deployment/) 단계로 진행합니다.
