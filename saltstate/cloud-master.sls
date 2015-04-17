/etc/salt/cloud:
  file.managed:
    - contents: |
        sync_after_install: all
        start_action: state.highstate

/etc/salt/cloud.profiles:
  file.managed:
    - source: salt://cloud.profiles
    - template: jinja

/etc/salt/cloud.providers:
  file.managed:
    - source: salt://cloud.providers
    - template: jinja

/etc/salt/cloud.conf.d/{{pillar.get('aws_ssh_key_name')}}.pem:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - contents_pillar: aws_ssh_key_file

python-pip:
  pkg.installed

awscli:
  pip.installed

{{pillar.get('aws_prod_sec_group')}}:
  ec2_state.security_group:
    - description: "Production Security Group"
    - region: {{pillar.get('aws_region')}}
    - aws_access_key_id: {{pillar.get('aws_iam_id')}}
    - aws_secret_access_key: {{pillar.get('aws_iam_key')}}

{{pillar.get('aws_test_sec_group')}}:
  ec2_state.security_group:
    - description: "Test Security Group"
    - region: {{pillar.get('aws_region')}}
    - aws_access_key_id: {{pillar.get('aws_iam_id')}}
    - aws_secret_access_key: {{pillar.get('aws_iam_key')}}

prod-allow-ssh:
  ec2_state.security_group_rule:
    - group_name: {{pillar.get('aws_prod_sec_group')}}
    - ip_protocol: tcp
    - from_port: 22
    - to_port: 22
    - cidr_ip: "{{grains.get('public_ip')}}/0"
    - region: {{pillar.get('aws_region')}}
    - aws_access_key_id: {{pillar.get('aws_iam_id')}}
    - aws_secret_access_key: {{pillar.get('aws_iam_key')}}

test-allow-ssh:
  ec2_state.security_group_rule:
    - group_name: {{pillar.get('aws_test_sec_group')}}
    - ip_protocol: tcp
    - from_port: 22
    - to_port: 22
    - cidr_ip: "{{grains.get('public_ip')}}/0"
    - region: {{pillar.get('aws_region')}}
    - aws_access_key_id: {{pillar.get('aws_iam_id')}}
    - aws_secret_access_key: {{pillar.get('aws_iam_key')}}

prod-allow-web:
  ec2_state.security_group_rule:
    - group_name: {{pillar.get('aws_prod_sec_group')}}
    - ip_protocol: tcp
    - from_port: 8080
    - to_port: 8080
    - cidr_ip: 0.0.0.0/0
    - region: {{pillar.get('aws_region')}}
    - aws_access_key_id: {{pillar.get('aws_iam_id')}}
    - aws_secret_access_key: {{pillar.get('aws_iam_key')}}

test-allow-web:
  ec2_state.security_group_rule:
    - group_name: {{pillar.get('aws_test_sec_group')}}
    - ip_protocol: tcp
    - from_port: 8080
    - to_port: 8080
    - cidr_ip: {{grains.get('public_ip')}}/0
    - region: {{pillar.get('aws_region')}}
    - aws_access_key_id: {{pillar.get('aws_iam_id')}}
    - aws_secret_access_key: {{pillar.get('aws_iam_key')}}
