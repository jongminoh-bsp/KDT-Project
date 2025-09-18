#!/usr/bin/env python3
"""
자연어 인프라 명령어를 YAML 설정으로 변환하는 스크립트
"""

import re
import yaml
import os

def parse_natural_language(command):
    """자연어 명령을 파싱하여 설정 변경사항 반환"""
    
    changes = {}
    
    # EKS 노드 수 변경
    node_match = re.search(r'노드.*?(\d+)개', command)
    if node_match:
        changes['kubernetes.node_desired_size'] = int(node_match.group(1))
        changes['kubernetes.node_max_size'] = max(int(node_match.group(1)) + 1, 3)
    
    # 인스턴스 타입 변경
    instance_patterns = [
        (r'management.*?(t3\.\w+)', 'compute.mgmt_instance_type'),
        (r'q-?dev.*?(t3\.\w+)', 'compute.q_dev_instance_type'),
        (r'노드.*?(t3\.\w+)', 'kubernetes.node_instance_types')
    ]
    
    for pattern, key in instance_patterns:
        match = re.search(pattern, command, re.IGNORECASE)
        if match:
            instance_type = match.group(1)
            if key == 'kubernetes.node_instance_types':
                changes[key] = [instance_type]
            else:
                changes[key] = instance_type
    
    # RDS 인스턴스 클래스 변경
    rds_match = re.search(r'rds.*?(db\.t3\.\w+)', command, re.IGNORECASE)
    if rds_match:
        changes['database.db_instance_class'] = rds_match.group(1)
    
    # 서브넷 추가
    subnet_match = re.search(r'서브넷.*?(\d+\.\d+\.\d+\.\d+/\d+)', command)
    if subnet_match:
        changes['_new_subnet'] = subnet_match.group(1)
    
    return changes

def apply_changes_to_yaml(yaml_file, changes):
    """YAML 파일에 변경사항 적용"""
    
    with open(yaml_file, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    
    for key, value in changes.items():
        if key == '_new_subnet':
            # 새 서브넷 추가 로직 (복잡하므로 여기서는 스킵)
            continue
            
        keys = key.split('.')
        current = config
        
        # 중첩된 키 탐색
        for k in keys[:-1]:
            if k not in current:
                current[k] = {}
            current = current[k]
        
        # 값 설정
        current[keys[-1]] = value
    
    # 파일 백업
    backup_file = f"{yaml_file}.backup"
    os.rename(yaml_file, backup_file)
    
    # 새 설정 저장
    with open(yaml_file, 'w', encoding='utf-8') as f:
        yaml.dump(config, f, default_flow_style=False, allow_unicode=True, indent=2)
    
    return backup_file

def main():
    """메인 함수"""
    
    # 명령어 예시
    commands = [
        "EKS 노드를 3개로 늘려줘",
        "Management 서버를 t3.large로 업그레이드해줘", 
        "RDS를 db.t3.small로 변경해줘"
    ]
    
    yaml_file = "/home/ojm/KDT-Project/infra/requirements/infrastructure-spec.yml"
    
    print("🤖 자연어 인프라 명령어 파서")
    print("=" * 50)
    
    for cmd in commands:
        print(f"\n📝 명령어: {cmd}")
        changes = parse_natural_language(cmd)
        print(f"🔄 변경사항: {changes}")
    
    # 실제 적용은 주석 처리 (테스트용)
    # backup = apply_changes_to_yaml(yaml_file, changes)
    # print(f"✅ 적용 완료! 백업: {backup}")

if __name__ == "__main__":
    main()
