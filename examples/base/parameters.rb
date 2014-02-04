require 'ipaddress'

derive 'PublicSubnetCidrBlocks', from: 'VPCCidrBlock' do |cidr_addr|
  vpc_net = IPAddress(cidr_addr)
  prefix = vpc_net.prefix + 2
  vpc_net.subnet(prefix)[2..-1].map { |subnet| subnet.to_string }.join(',')
end

derive 'PrivateSubnetCidrBlocks', from: 'VPCCidrBlock' do |cidr_addr|
  vpc_net = IPAddress(cidr_addr)
  prefix = vpc_net.prefix + 2
  vpc_net.subnet(prefix)[0..1].map { |subnet| subnet.to_string }.join(',')
end
