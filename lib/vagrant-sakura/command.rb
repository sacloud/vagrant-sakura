module VagrantPlugins
  module Sakura
    class Command < Vagrant.plugin(2, :command)
      def execute
        with_target_vms do |vm|
          vm.action(:plans)
        end
        0
      end
    end
  end
end
