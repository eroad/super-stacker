parameter 'VPC', 'Type' => 'String'
parameter 'PublicSubnetCidrBlocks', 'Type' => 'CommaDelimitedList'
parameter 'PrivateSubnetCidrBlocks', 'Type' => 'CommaDelimitedList'

# TODO: Would be nice if Fn::Select indexes could be a number. test?


resource 'PublicSubnetA', 'AWS::EC2::Subnet' do
  Properties do
    VpcId Ref('VPC')
    AvailabilityZone Fn::Select('0', Fn::GetAZs())
    CidrBlock Fn::Select('0', Ref('PublicSubnetCidrBlocks'))
  end
end

resource 'PublicSubnetB', 'AWS::EC2::Subnet' do
  Properties do
    VpcId Ref('VPC')
    AvailabilityZone Fn::Select('1', Fn::GetAZs())
    CidrBlock Fn::Select('1', Ref('PublicSubnetCidrBlocks'))
  end
end

resource 'PrivateSubnetA', 'AWS::EC2::Subnet' do
  Properties do
    VpcId Ref('VPC')
    AvailabilityZone Fn::Select('0', Fn::GetAZs())
    CidrBlock Fn::Select('0', Ref('PrivateSubnetCidrBlocks'))
  end
end

resource 'PrivateSubnetB', 'AWS::EC2::Subnet' do
  Properties do
    VpcId Ref('VPC')
    AvailabilityZone Fn::Select('1', Fn::GetAZs())
    CidrBlock Fn::Select('1', Ref('PrivateSubnetCidrBlocks'))
  end
end

output 'PublicSubnets', Fn::Join(',', [ Ref('PublicSubnetA'), Ref('PublicSubnetB') ] )
output 'PrivateSubnets', Fn::Join(',', [ Ref('PrivateSubnetA'), Ref('PrivateSubnetB') ] )
