require "log4r"

module VagrantPlugins
  module Sakura
    module Action
      class PowerOn
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::power_on")
        end

        def call(env)
          api      = env[:sakura_api]
          serverid = env[:machine].id

          env[:ui].info(I18n.t("vagrant_sakura.power_on"))
          api.put("/server/#{serverid}/power")
          @app.call(env)
        end
      end
    end
  end
end
