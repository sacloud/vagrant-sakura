require "pathname"
require "vagrant/action/builder"

module VagrantPlugins
  module Sakura
    module Action
      include Vagrant::Action::Builtin

      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b2.use ConnectSakura
              # b2.use Halt
              b2.use DeleteServer
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use ConnectSakura
              b2.use Halt
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_list_id
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use ListId
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use Call, ReadState do |env, b2|
            case env[:machine_state_id]
            when :up
              b2.use Provision
              b2.use SyncFolders
            when :down, :cleaning
              b2.use MessageDown
            when :not_created
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use ReadSSHInfo
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use ReadState
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use Call, ReadState do |env, b2|
            case env[:machine_state_id]
            when :up
              b2.use Reset
              b2.use action_provision
            when :down, :cleaning
              b2.use MessageDown
            when :not_created
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use Call, ReadState do |env, b2|
            case env[:machine_state_id]
            when :up
              b2.use SSHExec
            when :down, :cleaning
              b2.use MessageDown
            when :not_created
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectSakura
          b.use Call, ReadState do |env, b2|
            case env[:machine_state_id]
            when :up
              b2.use SSHRun
            when :down, :cleaning
              b2.use MessageDown
            when :not_created
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use ConnectSakura
          b.use CompleteArchiveId
          b.use Call, ReadState do |env, b2|
            case env[:machine_state_id]
            when :up
              b2.use MessageAlreadyCreated
            when :down, :cleaning
              b2.use PowerOn
              b2.use Provision
            when :not_created
              b2.use RunInstance
              b2.use action_provision
            end
          end
        end
      end

      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :CompleteArchiveId, action_root.join("complete_archive_id")
      autoload :ConnectSakura, action_root.join("connect_sakura")
      autoload :DeleteServer, action_root.join("delete_server")
      autoload :IsCreated, action_root.join("is_created")
      autoload :Halt, action_root.join("halt")
      autoload :ListId, action_root.join("list_id")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageDown, action_root.join("message_down")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      autoload :PowerOn, action_root.join("power_on")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      autoload :Reset, action_root.join("reset")
      autoload :RunInstance, action_root.join("run_instance")
      autoload :SyncFolders, action_root.join("sync_folders")
    end
  end
end
