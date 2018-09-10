module VagrantPlugins
  module Sakura
    class CommandReinstall < Vagrant.plugin(2, :command)
      def self.synopsis
        "Reinstall Sakura cloud disk"
      end

      def execute
        with_target_vms(nil, { :provider => "sakura" }) do |vm|
          vm.action(:reinstall)
        end
        0
      end
    end
  end
end
