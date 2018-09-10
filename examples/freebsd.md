# Vagrantfileの例(FreeBSDを利用する場合)

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.ssh.username = "root"
  config.ssh.shell = "sh"
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  config.vm.provider :sakura do |sakura, override|
    sakura.os_type = "freebsd"
    
    sakura.public_key_path        = File.expand_path("~/.ssh/id_rsa.pub")
    override.ssh.private_key_path = File.expand_path("~/.ssh/id_rsa")
  end
end
```