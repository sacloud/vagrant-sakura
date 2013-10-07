require "log4r"

module VagrantPlugins
  module Sakura
    module Action
      class Halt
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::halt")
        end

        def call(env)
          api      = env[:sakura_api]
          serverid = env[:machine].id

          env[:ui].info(I18n.t("vagrant_sakura.power_off"))

          response = api.delete("/server/#{serverid}/power")
          sleep 3
          while true
            response = api.get("/server/#{serverid}/power")
            break if response["Instance"]["Status"] == "down"
            sleep 1
          end

          @app.call(env)
        end
      end
    end
  end
end
