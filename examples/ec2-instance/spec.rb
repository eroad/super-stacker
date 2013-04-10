description "Creates a single EC2 Instance."

parameter "InstanceType", "Type" => "String"

resource "WebServer", "AWS::EC2::Instance" do
  Properties do
    AvailabilityZone "us-west-2a"
    ImageId "ami-aaaabbbb"
    KeyName "keyname"
    InstanceType Ref("InstanceType")
    SubnetId "subnet-aaaabbbb"
    SecurityGroupIds [ "sg-aaaabbbb" ]
  end
end
