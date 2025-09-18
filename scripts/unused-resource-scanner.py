#!/usr/bin/env python3
"""
미사용 AWS 리소스 스캐너
자연어 명령으로 제어 가능한 리소스 최적화 도구
"""

import boto3
import json
from datetime import datetime, timedelta
from typing import Dict, List, Any

class UnusedResourceScanner:
    def __init__(self, region='ap-northeast-2'):
        self.region = region
        self.ec2 = boto3.client('ec2', region_name=region)
        self.elbv2 = boto3.client('elbv2', region_name=region)
        self.rds = boto3.client('rds', region_name=region)
        
    def scan_unused_ebs_volumes(self) -> List[Dict]:
        """미연결 EBS 볼륨 스캔"""
        print("🔍 Scanning unused EBS volumes...")
        
        response = self.ec2.describe_volumes(
            Filters=[{'Name': 'status', 'Values': ['available']}]
        )
        
        unused_volumes = []
        for volume in response['Volumes']:
            volume_info = {
                'resource_type': 'EBS Volume',
                'resource_id': volume['VolumeId'],
                'size': f"{volume['Size']}GB",
                'volume_type': volume['VolumeType'],
                'created_date': volume['CreateTime'].strftime('%Y-%m-%d'),
                'estimated_monthly_cost': f"${volume['Size'] * 0.1:.2f}",  # 대략적 비용
                'tags': {tag['Key']: tag['Value'] for tag in volume.get('Tags', [])}
            }
            unused_volumes.append(volume_info)
            
        return unused_volumes
    
    def scan_unattached_eips(self) -> List[Dict]:
        """미할당 Elastic IP 스캔"""
        print("🔍 Scanning unattached Elastic IPs...")
        
        response = self.ec2.describe_addresses()
        
        unattached_eips = []
        for eip in response['Addresses']:
            if 'AssociationId' not in eip:  # 연결되지 않은 EIP
                eip_info = {
                    'resource_type': 'Elastic IP',
                    'resource_id': eip['AllocationId'],
                    'public_ip': eip['PublicIp'],
                    'estimated_monthly_cost': "$3.65",  # 미사용 EIP 비용
                    'tags': {tag['Key']: tag['Value'] for tag in eip.get('Tags', [])}
                }
                unattached_eips.append(eip_info)
                
        return unattached_eips
    
    def scan_unused_security_groups(self) -> List[Dict]:
        """미사용 보안 그룹 스캔"""
        print("🔍 Scanning unused security groups...")
        
        # 모든 보안 그룹 가져오기
        sg_response = self.ec2.describe_security_groups()
        
        # 사용 중인 보안 그룹 찾기
        used_sgs = set()
        
        # EC2 인스턴스에서 사용 중인 SG
        instances = self.ec2.describe_instances()
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                for sg in instance['SecurityGroups']:
                    used_sgs.add(sg['GroupId'])
        
        # RDS에서 사용 중인 SG
        try:
            rds_instances = self.rds.describe_db_instances()
            for db in rds_instances['DBInstances']:
                for sg in db['VpcSecurityGroups']:
                    used_sgs.add(sg['VpcSecurityGroupId'])
        except:
            pass
        
        unused_sgs = []
        for sg in sg_response['SecurityGroups']:
            # default SG는 제외
            if sg['GroupName'] == 'default':
                continue
                
            # 사용되지 않는 SG
            if sg['GroupId'] not in used_sgs:
                sg_info = {
                    'resource_type': 'Security Group',
                    'resource_id': sg['GroupId'],
                    'name': sg['GroupName'],
                    'description': sg['Description'],
                    'vpc_id': sg['VpcId'],
                    'estimated_monthly_cost': "$0.00",  # SG는 무료
                    'tags': {tag['Key']: tag['Value'] for tag in sg.get('Tags', [])}
                }
                unused_sgs.append(sg_info)
                
        return unused_sgs
    
    def scan_old_snapshots(self, days_old=30) -> List[Dict]:
        """오래된 스냅샷 스캔"""
        print(f"🔍 Scanning snapshots older than {days_old} days...")
        
        cutoff_date = datetime.now() - timedelta(days=days_old)
        
        response = self.ec2.describe_snapshots(OwnerIds=['self'])
        
        old_snapshots = []
        for snapshot in response['Snapshots']:
            if snapshot['StartTime'].replace(tzinfo=None) < cutoff_date:
                snapshot_info = {
                    'resource_type': 'EBS Snapshot',
                    'resource_id': snapshot['SnapshotId'],
                    'description': snapshot['Description'],
                    'size': f"{snapshot['VolumeSize']}GB",
                    'created_date': snapshot['StartTime'].strftime('%Y-%m-%d'),
                    'age_days': (datetime.now() - snapshot['StartTime'].replace(tzinfo=None)).days,
                    'estimated_monthly_cost': f"${snapshot['VolumeSize'] * 0.05:.2f}",
                    'tags': {tag['Key']: tag['Value'] for tag in snapshot.get('Tags', [])}
                }
                old_snapshots.append(snapshot_info)
                
        return old_snapshots
    
    def generate_report(self) -> Dict[str, Any]:
        """전체 미사용 리소스 리포트 생성"""
        print("📋 Generating unused resources report...")
        
        report = {
            'scan_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'region': self.region,
            'unused_resources': {
                'ebs_volumes': self.scan_unused_ebs_volumes(),
                'elastic_ips': self.scan_unattached_eips(),
                'security_groups': self.scan_unused_security_groups(),
                'old_snapshots': self.scan_old_snapshots()
            },
            'summary': {}
        }
        
        # 요약 정보 계산
        total_resources = 0
        total_estimated_cost = 0.0
        
        for category, resources in report['unused_resources'].items():
            count = len(resources)
            total_resources += count
            
            category_cost = 0.0
            for resource in resources:
                cost_str = resource['estimated_monthly_cost'].replace('$', '')
                category_cost += float(cost_str)
            
            total_estimated_cost += category_cost
            
            report['summary'][category] = {
                'count': count,
                'estimated_monthly_cost': f"${category_cost:.2f}"
            }
        
        report['summary']['total'] = {
            'resources': total_resources,
            'estimated_monthly_savings': f"${total_estimated_cost:.2f}"
        }
        
        return report
    
    def format_slack_message(self, report: Dict[str, Any]) -> str:
        """Slack 알림용 메시지 포맷"""
        summary = report['summary']
        
        message = f"""🔍 **미사용 리소스 스캔 결과**
        
📅 **스캔 일시**: {report['scan_date']}
🌍 **리전**: {report['region']}

📊 **요약**:
• 총 미사용 리소스: {summary['total']['resources']}개
• 예상 월간 절약 비용: {summary['total']['estimated_monthly_savings']}

📋 **카테고리별 상세**:"""

        for category, info in summary.items():
            if category != 'total':
                category_name = {
                    'ebs_volumes': 'EBS 볼륨',
                    'elastic_ips': 'Elastic IP',
                    'security_groups': '보안 그룹',
                    'old_snapshots': '오래된 스냅샷'
                }.get(category, category)
                
                message += f"\n• {category_name}: {info['count']}개 ({info['estimated_monthly_cost']})"
        
        if summary['total']['resources'] > 0:
            message += f"\n\n💡 **권장사항**: 미사용 리소스를 정리하여 월 {summary['total']['estimated_monthly_savings']} 절약 가능"
        else:
            message += "\n\n✅ **결과**: 미사용 리소스가 발견되지 않았습니다!"
            
        return message

def main():
    """메인 실행 함수"""
    scanner = UnusedResourceScanner()
    
    print("🚀 Starting unused resource scan...")
    report = scanner.generate_report()
    
    # 리포트 저장
    with open('/tmp/unused-resources-report.json', 'w') as f:
        json.dump(report, f, indent=2, default=str)
    
    # Slack 메시지 생성
    slack_message = scanner.format_slack_message(report)
    print("\n" + "="*50)
    print("SLACK MESSAGE:")
    print("="*50)
    print(slack_message)
    
    # 상세 리포트 출력
    print("\n" + "="*50)
    print("DETAILED REPORT:")
    print("="*50)
    print(json.dumps(report, indent=2, default=str))

if __name__ == "__main__":
    main()
