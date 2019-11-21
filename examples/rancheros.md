# Vagrantfileの例(RancherOSを利用する場合)

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.ssh.username = "rancher"
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  config.vm.provider :sakura do |sakura, override|
    sakura.os_type = "rancheros"
    
    # 2core/4GBメモリ プラン
    sakura.server_core = 2 
    sakura.server_memory = 4 
    
    sakura.public_key_path        = File.expand_path("~/.ssh/id_rsa.pub")
    override.ssh.private_key_path = File.expand_path("~/.ssh/id_rsa")
  end
end
```