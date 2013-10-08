require "log4r"
require "vagrant"

module VagrantPlugins
  module Sakura
    class Plugin < Vagrant.plugin("2")
      name "Sakura"
      description <<-DESC
      This plugin installs a provider that allows Vagrant to manage
      server instances in Sakura Cloud.
      DESC

      config(:sakura, :provider) do
        require_relative "config"
        Config
      end

      provider(:sakura) do
        setup_i18n
        setup_logging

        require_relative "provider"
        Provider
      end

      command(:'sakura-list-id') do
        require_relative "command"
        Command
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml", Sakura.source_root)
        I18n.reload!
      end

      def self.setup_logging
        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
          level = nil if !level.is_a?(Integer)
        rescue NameError
        end

        if level
          logger = Log4r::Logger.new("vagrant_sakura")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end
