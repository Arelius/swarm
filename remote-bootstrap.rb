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
    run_remote_command(server, "sudo ln -sf /usr/bin/ruby1.9.1 /usr/bin/ruby") and
    run_remote_command(server, "sudo ln -sf /usr/bin/gem1.9.1 /usr/bin/gem") and
    run_remote_command(server, "sudo ln -sf /usr/bin/erb1.9.1 /usr/bin/erb") and
    run_remote_command(server, "sudo ln -sf /usr/bin/irb1.9.1 /usr/bin/irb") and
    run_remote_command(server, "sudo ln -sf /usr/bin/rake1.9.1 /usr/bin/rake") and
    run_remote_command(server, "sudo ln -sf /usr/bin/rdoc1.9.1 /usr/bin/rdoc") and
    run_remote_command(server, "sudo ln -sf /usr/bin/testrb1.9.1 /usr/bin/testrb") and
    run_remote_command(server, "sudo gem install chef ohai --no-ri --no-rdoc") and
    run_remote_command(server, "sudo ln -sf /var/lib/gems/1.9.1/bin/chef-solo /usr/bin/chef-solo") or return false

    remote_upload(server,
                  File.expand_path(File.dirname(__FILE__) + "/kitchen"),
                  "kitchen") or return false;
  end
end
