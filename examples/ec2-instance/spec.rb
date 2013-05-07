description 'Creates a single EC2 Instance and Security Group.'

mapping 'RegionMap' do
  escape 'us-west-1' do
    AMI 'ami-2928076c'
  end

  escape 'us-west-2' do
    AMI 'ami-09e27439'
  end
end

parameter 'InstanceType', 'Type' => 'String'
parameter 'RegionId', 'Type' => 'String'
parameter 'KeyName', 'Type' => 'String'

resource 'WebServerSecurityGroup', 'AWS::EC2::SecurityGroup' do
  Properties do
    GroupDescription 'Security Group for the WebServer instance.'
    SecurityGroupIngress [
      { 'IpProtocol' => 'tcp', 'FromPort' => '22', 'ToPort' => '22', 'CidrIp' => '0.0.0.0/0' }
    ]
  end
end

resource 'WebServer', 'AWS::EC2::Instance' do
  Properties do
    ImageId Fn::FindInMap('RegionMap', 'us-west-2', 'AMI')
    KeyName Ref('KeyName')
    InstanceType Ref('InstanceType')
    SecurityGroupIds [ Ref('WebServerSecurityGroup') ]
  end
end

output 'WebServerPublicDnsName', Fn::GetAtt('WebServer', 'PrivateDnsName'),
  'Public DNS name of the web server.'
