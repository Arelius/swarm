def vboxmanage(params)
  return `VBoxManage #{params}`
end

class VBox
  def initialize(name, base)
    @base_vm = base
    @name = name

    vboxmanage("clonevm #{@base_vm} --name #{@name} --register")

    #nics = vboxmanage("showvminfo #{@name}").scan(/NIC ([0-9]):[ \t]*MAC: ([0-9A-Z]+)/)
  end

  def start()
    vboxmanage("startvm #{@name}") #'headless' if we want to hide it.

    # Can only set after start.
    @ip = vboxmanage("guestproperty wait #{@name} /VirtualBox/GuestInfo/Net/0/V4/IP").scan(/value: ([0-9.]+)/)[0]
  end
end

module VBoxRemote
  @BaseVM = "server-base"


  def self.init_server(node_name)
    vbox = VBox.new(node_name, @BaseVM)
    vbox.start

    return vbox
  end
end
