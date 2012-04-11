require 'json'

module SwarmConfig
  def self.load_config(file)
    cfg = nil
    File.open(file, "r") do |infile|
      cfg = JSON.parse(infile.read)
    end
    @@vbox_base_vm = cfg["vbox"]["base-vm"]
    @@vbox_ssh_private_key = cfg["vbox"]["ssh-private-key"]
    @@vbox_login_user = cfg["vbox"]["login-user"]
  end

  def self.vbox_base_vm
    @@vbox_base_vm
  end

  def self.vbox_ssh_private_key
    @@vbox_ssh_private_key
  end

  def self.vbox_login_user
    @@vbox_login_user
  end
end
