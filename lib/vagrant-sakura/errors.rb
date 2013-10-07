require "vagrant"

module VagrantPlugins
  module Sakura
    module Errors
      class VagrantSakuraError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_sakura.errors")
      end

      class InstanceReadyTimeout < VagrantSakuraError
        error_key(:instance_ready_timeout)
      end

      class RsyncError < VagrantSakuraError
        error_key(:rsync_error)
      end
    end
  end
end
