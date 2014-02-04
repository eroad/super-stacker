parameter 'CidrBlock', 'Type' => 'String'

resource 'VPC', 'AWS::EC2::VPC' do
  Properties do
    CidrBlock Ref('CidrBlock')
  end
end

# TODO: we shouldnt' need to output this, we can get it form the parameter
output 'VPCCidrBlock', Ref('CidrBlock')
output 'VPC', Ref('VPC')
