require 'net/ssh'
require 'net/scp'

def run_remote_command(server, cmd)
  Net::SSH.start(server.connection_address,
                 server.login_username,
                 :auth_methods => ["publickey"],
                 :keys => [server.ssh_key]) do |ssh|
    ssh.exec!(cmd) do |channel, stream, data|
      puts data
    end
  end
  # TODO: Add failure detection support.
  return true
end

def remote_upload(server, local, remote)
  Net::SSH.start(server.connection_address,
                 server.login_username,
                 :auth_methods => ["publickey"],
                 :keys => [server.ssh_key]) do |ssh|
    ssh.scp.upload!(local, remote, :recursive => true)
  end
  return true
end

class RemoteBootstrap
  def self.bootstrap_server(server)
    run_remote_command(server, "sudo apt-get update -y") and
    run_remote_command(server, "sudo apt-get install ruby1.9.1 ruby1.9.1-dev -y") and
    run_remote_command(server, "sudo gem1.9.1 install chef ohai --no-ri --no-rdoc") and
    run_remote_command(server, "sudo ln -sf /var/lib/gems/1.9.1/bin/chef-solo /usr/bin/chef-solo") or return false;
  end

  def self.cook(server)
    run_remote_command(server, "sudo mkdir /etc/chef") and
    run_remote_command(server, "sudo rm -rf /etc/chef/*") and
    remote_upload(server,
                  File.expand_path(File.dirname(__FILE__) + "/kitchen"),
                  "tmpup") and
    run_remote_command(server, "sudo mv tmpup/* /etc/chef/") and
    run_remote_command(server, "sudo rm -rf tmpup") and
    run_remote_command(server, "sudo chef-solo -c /etc/chef/solo.rb -j /etc/chef/solo.json -N #{server.instance_name}") or return false;
  end
end
