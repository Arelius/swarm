require 'AWS'
require 'json'

class EC2
  def initialize(name)
  end
end

module EC2Remote
  def self.get_server(node_name)
    ec2 = EC2.new(node_name)
    return ec2
  end
end
