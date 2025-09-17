#!/usr/bin/env python3
"""
🚀 Infrastructure Spec to Terraform Variables Generator

이 스크립트는 infrastructure-spec.yml 파일을 읽어서
Terraform 변수 파일을 자동 생성합니다.
"""

import yaml
import json
import sys
import os
from pathlib import Path

def load_infrastructure_spec(spec_file):
    """인프라 스펙 YAML 파일 로드"""
    try:
        with open(spec_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"❌ Error: {spec_file} not found")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"❌ Error parsing YAML: {e}")
        sys.exit(1)

def generate_terraform_vars(spec):
    """스펙을 기반으로 Terraform 변수 생성"""
    
    # 기본 변수들
    tf_vars = {
        "region": "ap-northeast-2",
        "project": spec['metadata']['name'].split('-')[0],
        "environment": spec['metadata']['environment'],
    }
    
    # 네트워크 설정
    if 'network' in spec:
        network = spec['network']
        tf_vars.update({
            "vpc_cidr": network['vpc']['cidr'],
            "public_subnet_cidrs": [subnet['cidr'] for subnet in network['subnets']['public']],
            "private_mgmt_subnet_cidrs": [subnet['cidr'] for subnet in network['subnets']['private_mgmt']],
            "private_ng_subnet_cidrs": [subnet['cidr'] for subnet in network['subnets']['private_nodegroup']],
            "private_rds_subnet_cidrs": [subnet['cidr'] for subnet in network['subnets']['private_rds']],
            "private_qdev_subnet_cidrs": [subnet['cidr'] for subnet in network['subnets']['private_qdev']],
        })
    
    # 컴퓨팅 리소스
    if 'compute' in spec:
        compute = spec['compute']
        if 'ec2' in compute:
            tf_vars.update({
                "ami_id": compute['ec2']['management']['ami'],
                "mgmt_instance_type": compute['ec2']['management']['instance_type'],
                "q_dev_instance_type": compute['ec2']['qdev']['instance_type'],
                "key_name": compute['ec2']['management']['key_name'],
            })
    
    # Kubernetes 설정
    if 'kubernetes' in spec:
        k8s = spec['kubernetes']['eks']
        tf_vars.update({
            "cluster_name": k8s['cluster_name'],
            "cluster_version": k8s['version'],
        })
        
        # 노드 그룹 설정
        if 'node_groups' in k8s and 'main' in k8s['node_groups']:
            ng = k8s['node_groups']['main']
            tf_vars.update({
                "node_instance_types": ng['instance_types'],
                "node_desired_size": ng['scaling']['desired_size'],
                "node_min_size": ng['scaling']['min_size'],
                "node_max_size": ng['scaling']['max_size'],
            })
    
    # 데이터베이스 설정
    if 'database' in spec:
        db = spec['database']['rds']
        tf_vars.update({
            "db_username": db['username'],
            "db_name": db['database_name'],
            "db_engine": db['engine'],
            "db_engine_version": db['engine_version'],
            "db_instance_class": db['instance_class'],
        })
    
    return tf_vars

def write_terraform_vars(tf_vars, output_file):
    """Terraform 변수 파일 작성"""
    
    # HCL 형식으로 작성
    content = []
    content.append("# 🚀 Auto-generated Terraform variables")
    content.append("# Generated from infrastructure-spec.yml")
    content.append("# Do not edit manually - changes will be overwritten")
    content.append("")
    
    # 기본 설정
    content.append("# 🌍 Basic Configuration")
    content.append(f'region = "{tf_vars["region"]}"')
    content.append(f'project = "{tf_vars["project"]}"')
    content.append(f'environment = "{tf_vars["environment"]}"')
    content.append("")
    
    # 네트워크 설정
    if any(key.startswith('vpc_') or key.endswith('_subnet_cidrs') for key in tf_vars.keys()):
        content.append("# 🌐 Network Configuration")
        if 'vpc_cidr' in tf_vars:
            content.append(f'vpc_cidr = "{tf_vars["vpc_cidr"]}"')
        
        for key in ['public_subnet_cidrs', 'private_mgmt_subnet_cidrs', 
                   'private_ng_subnet_cidrs', 'private_rds_subnet_cidrs', 
                   'private_qdev_subnet_cidrs']:
            if key in tf_vars:
                cidrs = '", "'.join(tf_vars[key])
                content.append(f'{key} = ["{cidrs}"]')
        content.append("")
    
    # 컴퓨팅 설정
    if any(key in tf_vars for key in ['ami_id', 'mgmt_instance_type', 'q_dev_instance_type', 'key_name']):
        content.append("# 🖥️ Compute Configuration")
        for key in ['ami_id', 'mgmt_instance_type', 'q_dev_instance_type', 'key_name']:
            if key in tf_vars:
                content.append(f'{key} = "{tf_vars[key]}"')
        content.append("")
    
    # Kubernetes 설정
    if any(key.startswith('cluster_') or key.startswith('node_') for key in tf_vars.keys()):
        content.append("# ☸️ Kubernetes Configuration")
        for key in ['cluster_name', 'cluster_version']:
            if key in tf_vars:
                content.append(f'{key} = "{tf_vars[key]}"')
        
        if 'node_instance_types' in tf_vars:
            types = '", "'.join(tf_vars['node_instance_types'])
            content.append(f'node_instance_types = ["{types}"]')
        
        for key in ['node_desired_size', 'node_min_size', 'node_max_size']:
            if key in tf_vars:
                content.append(f'{key} = {tf_vars[key]}')
        content.append("")
    
    # 데이터베이스 설정
    if any(key.startswith('db_') for key in tf_vars.keys()):
        content.append("# 🗄️ Database Configuration")
        for key in ['db_username', 'db_name', 'db_engine', 'db_engine_version', 'db_instance_class']:
            if key in tf_vars:
                content.append(f'{key} = "{tf_vars[key]}"')
        content.append("")
    
    # 파일 작성
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(content))
        print(f"✅ Generated: {output_file}")
    except Exception as e:
        print(f"❌ Error writing {output_file}: {e}")
        sys.exit(1)

def main():
    """메인 함수"""
    
    # 경로 설정
    project_root = Path(__file__).parent.parent
    spec_file = project_root / "infra" / "requirements" / "infrastructure-spec.yml"
    output_file = project_root / "infra" / "dev" / "terraform" / "terraform.tfvars"
    
    print("🚀 Infrastructure Spec to Terraform Variables Generator")
    print("=" * 60)
    
    # 스펙 파일 로드
    print(f"📖 Loading spec: {spec_file}")
    spec = load_infrastructure_spec(spec_file)
    
    # Terraform 변수 생성
    print("🔄 Generating Terraform variables...")
    tf_vars = generate_terraform_vars(spec)
    
    # 변수 파일 작성
    print(f"💾 Writing variables: {output_file}")
    write_terraform_vars(tf_vars, output_file)
    
    print("=" * 60)
    print("✅ Generation completed successfully!")
    print(f"📁 Generated {len(tf_vars)} variables")
    print(f"🎯 Target environment: {spec['metadata']['environment']}")

if __name__ == "__main__":
    main()
