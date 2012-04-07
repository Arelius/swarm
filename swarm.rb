require 'trollop'

$:.unshift(File.dirname(__FILE__))

#require 'remote-bootstrap'
require 'vbox-remote'
require 'ec2-remote'

opts = Trollop::options do
  banner <<-EOS
The Swarm server provisioning client.

Usage:
    swarm [options] <command> <vm_name>

options:
EOS

  opt :cluster, "Cluster to provision on, EC2 or VBox", :type => :string, :default => "VBox"
end

cluster_remote = case opts[:cluster]
                 when "EC2"
                   EC2Remote
                 when "VBox"
                   VBoxRemote
                 else
                   Trollop::die "Unknown cluster: #{opts[:cluster]}"
                 end

cmd = ARGV.shift or Trollop::die "Missing command"

case cmd
when "list"
  cluster_remote.server_list do |server_name|
    puts "\t#{server_name}"
  end
else

  server_name = ARGV.shift or Trollop::die "Missing vm_name"

  server = cluster_remote.get_server(server_name)

  case cmd
  when "new"
    !server.exists? or Trollop::die "VM #{server_name} already exists!"
    server.init_server()
    server.start_server()
  when "start"
    server.exists? or Trollop::die "VM #{server_name} doesn't exist!"
    !server.running? or Trollop::die "VM #{server_name} is already running."
    server.start_server()
  when "stop"
    server.exists? or Trollop::die "VM #{server_name} doesn't exist!"
    server.running? or Trollop::die "VM #{server_name} isn't running!"
    server.stop_server()
  when "delete"
    server.exists? or Trollop::die "VM #{server_name} doesn't exist!"
    (!server.running?) or Trollop::die "VM #{server_name} is running, needs to be stopped first."
    server.delete_server()
  when "ssh"
    server.exists? or Trollop::die "VM #{server_name} doesn't exist!"
    server.running? or Trollop::die "VM #{server_name} isn't running!"
    Kernel.exec("ssh -i #{server.ssh_key} #{server.login_username}@#{server.connection_address}")
  else
    Trollop::die "Unknown command: #{cmd}"
  end
end

