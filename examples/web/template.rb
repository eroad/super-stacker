parameter 'PublicSubnets', 'Type' => 'CommaDelimitedList'
parameter 'VPC', 'Type' => 'String'
parameter 'WebAMI', 'Type' => 'String'
parameter 'WebKey', 'Type' => 'String'

resource 'WebSecurityGroup', 'AWS::EC2::SecurityGroup' do
  Properties do
    GroupDescription 'Security Group for the Web instances'
    SecurityGroupIngress [ { 'IpProtocol' => 'tcp', 'FromPort' => '22',
                             'ToPort' => '22', 'CidrIp' => '0.0.0.0/0' } ]
    VpcId Ref('VPC')
  end
end

resource 'WebA', 'AWS::EC2::Instance' do
  Properties do
    ImageId Ref('WebAMI')
    KeyName Ref('WebKey')
    InstanceType 't1.micro'
    SecurityGroupIds [ Ref('WebSecurityGroup') ]
    SubnetId Fn::Select('0', Ref('PublicSubnets'))
  end
end

resource 'WebB', 'AWS::EC2::Instance' do
  Properties do
    ImageId Ref('WebAMI')
    KeyName Ref('WebKey')
    InstanceType 't1.micro'
    SecurityGroupIds [ Ref('WebSecurityGroup') ]
    SubnetId Fn::Select('1', Ref('PublicSubnets'))
  end
end

output 'WebSecurityGroup', Ref('WebSecurityGroup')
