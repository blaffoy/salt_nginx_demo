from boto import ec2


def security_group(name,
                   description,
                   region,
                   aws_access_key_id,
                   aws_secret_access_key):
    ret = {'name': name, 'result': None, 'comment': '', 'changes': {}}
    ec2_conn = ec2.connect_to_region(
        region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )
    sgs = ec2_conn.get_all_security_groups()

    if name in (sg.name for sg in sgs):
        ret['result'] = True
        ret['comment'] = "Security Group \'{}\' already exists in region \'{}\'".format(name, region)
        return ret

    ec2_conn.create_security_group(name, description)

    ret['result'] = True
    ret['comment'] = "Successfully created security group \'{}\' in region \'{}\'".format(name, region)
    ret['changes'][name] = 'Created'
    return ret


def security_group_rule(name,
                        group_name,
                        ip_protocol,
                        from_port,
                        to_port,
                        cidr_ip,
                        region,
                        aws_access_key_id,
                        aws_secret_access_key):
    ret = {'name': name, 'result': None, 'comment': '', 'changes': {}}
    ec2_conn = ec2.connect_to_region(
        region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key
    )

    sgs = ec2_conn.get_all_security_groups()
    security_group = None
    for sg in sgs:
        if sg.name == group_name:
            security_group = sg

    if security_group == None:
        ret['result'] = False
        ret['comment'] = "Security Group \'{}\' does not exist in region \'{}\'".format(name, region)
        return ret

    for rule in security_group.rules:
        if rule.ip_protocol == ip_protocol and int(rule.from_port) == from_port and int(rule.to_port) == to_port:
            ret['result'] = True
            ret['comment'] = "Rule {}:{}-{}:{} already present in Security Group \'{}\' in region \'{}\'".format(ip_protocol, from_port, to_port, cidr_ip, group_name, region)
            return ret

    security_group.authorize(ip_protocol, from_port, to_port, cidr_ip)

    ret['result'] = True
    ret['comment'] = "Added rule {}:{}-{}:{} to Security Group \'{}\' in region \'{}\'".format(ip_protocol, from_port, to_port, cidr_ip, group_name, region)
    ret['changes']['name'] = "Security group rule set"
    return ret
