require 'net/ssh'

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

class RemoteBootstrap
  def self.bootstrap_server(server)
    run_remote_command(server, "sudo apt-get update -y") and
    run_remote_command(server, "sudo apt-get install ruby1.9.1 ruby1.9.1-dev -y") and
    run_remote_command(server, "sudo gem1.9.1 install chef --no-ri --no-rdoc") or false
  end
end
