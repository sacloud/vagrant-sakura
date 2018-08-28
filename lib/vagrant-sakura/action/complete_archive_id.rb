require 'log4r'
require 'vagrant-sakura/driver/api'
require "vagrant-sakura/os_type"

module VagrantPlugins
  module Sakura
    module Action
      class CompleteArchiveId
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::complete_archive_id")
        end

        def call(env)
          config = env[:machine].provider_config
          if config.disk_source_mode == :os_type
            api = env[:sakura_api]

            filter = VagrantPlugins::Sakura::OSType::OS_TYPE_QUERIES[config.os_type]
            raise 'invalid os_type' if filter.nil?

            data = {
                "Filter" => filter
            }
            response = api.get("/archive", data)
            raise "os_type `#{config.os_type}` is not found" if response.nil? || response["Archives"].nil? || response["Archives"].empty?

            config.disk_source_archive = response["Archives"][0]["ID"]
          else
            config.os_type = ""
          end
          @app.call(env)
        end

      end
    end
  end
end
