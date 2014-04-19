module VagrantPlugins
  module Sakura
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        "query Sakura for available archives and server plans"
      end

      def execute
        with_target_vms(nil, { :provider => "sakura" }) do |vm|
          vm.action(:list_id)
        end
        0
      end
    end
  end
end
