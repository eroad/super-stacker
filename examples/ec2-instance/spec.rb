description "Creates a single EC2 Instance."

mapping "RegionMap" do
  FakeRegion do
    AMI 'ami-aaaabbbb'
  end

  escape 'us-west-1' do
    escape 'hyphenated-key', 'somevalue'
    AMI 'ami-aaaabbbb'
  end
end

parameter "InstanceType", "Type" => "String"
parameter "RegionId", "Type" => "String"

resource "WebServer", "AWS::EC2::Instance" do
  Properties do
    AvailabilityZone "us-west-2a"
    ImageId Fn::FindInMap("RegionMap", Ref("RegionId"), "AMI")
    KeyName "keyname"
    InstanceType Ref("InstanceType")
    SubnetId "subnet-aaaabbbb"
    SecurityGroupIds [ "sg-aaaabbbb" ]
  end
end

output "WebServerPublicDnsName", Fn::GetAtt("WebServer", "PrivateDnsName"),
  "Public DNS name of the web server."
