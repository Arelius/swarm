require 'swarm-config'

def vboxmanage(params)
  return `VBoxManage #{params}`
end

class VBox
  def initialize(name)
    @base_vm = SwarmConfig.vbox_base_vm
    @name = name
    @ssh_key = File.expand_path(File.dirname(__FILE__) + "/" + SwarmConfig.vbox_ssh_private_key)
    @login_user = SwarmConfig.vbox_login_user

    if(exists? && running?)
      get_instance_info()
    end
  end

  def init_server()
    vboxmanage("clonevm #{@base_vm} --name #{@name} --register")
  end

  def start_server()
    vboxmanage("startvm #{@name}") #'headless' if we want to hide it.
    get_instance_info()
  end

  def stop_server()
    vboxmanage("controlvm #{@name} savestate")
  end

  def delete_server()
    vboxmanage("unregistervm #{@name} -delete")
  end

  def exists?()
    vboxmanage("list vms").scan(/"([^"]+)" \{([0-9a-zA-Z\-]+)\}/) do |vm|
      if(vm[0] == @name)
        return true
      end
    end
    return false
  end

  def running?()
    vboxmanage("list runningvms").scan(/"([^"]+)" \{([0-9a-zA-Z\-]+)\}/) do |vm|
      if(vm[0] == @name)
        return true
      end
    end
    return false
  end

  def get_instance_info()
    @mac_address = vboxmanage("showvminfo #{@name}").scan(/NIC ([0-9]):[ \t]*MAC: ([0-9A-Z]+)/)[0][0]
    # Can only set after start.
    ifaces = vboxmanage("guestproperty get #{@name} /VirtualBox/GuestInfo/Net/0/V4/IP").scan(/Value: ([0-9.]+)/)

    if(ifaces.length == 0)
      ifaces = vboxmanage("guestproperty wait #{@name} /VirtualBox/GuestInfo/Net/0/V4/IP").scan(/value: ([0-9.]+)/)

      #FIXME: System is still initializing, so sleep a bit, we should just retry a broken connection.
      sleep(3)
    end

    @ip = ifaces[0][0]
  end

  def connection_address
    return @ip
  end

  def ssh_key
    return @ssh_key
  end

  def login_username
    return @login_user
  end

  def instance_name
    return @name
  end
end

module VBoxRemote
  def self.get_server(node_name)
    vbox = VBox.new(node_name)
    return vbox
  end

  def self.server_list()
    vms = vboxmanage("list vms").scan(/"([^"]+)" \{([0-9a-zA-Z\-]+)\}/) do |vm|
      if block_given?
        yield vm[0]
      else
        vm[0]
      end
    end

    return vms
  end
end
