require "log4r"
require "vagrant"

module VagrantPlugins
  module Sakura
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        env = @machine.action("read_ssh_info")
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action("read_state")
        state_id = env[:machine_state_id]
        short = state_id.to_s
        long = I18n.t("vagrant_sakura.state_#{short}")
        Vagrant::MachineState.new(state_id.to_sym, short, long)
      end
    end
  end
end
