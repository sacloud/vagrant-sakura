require "log4r"

module VagrantPlugins
  module Sakura
    module Action
      class Reset
        def initialize(app, env)
          @app    = app
        end

        def call(env)
          api = env[:sakura_api]
          serverid = env[:machine].id

          # when "PUT /server/#{serverid}/reset" returns, power is up.
          api.put("/server/#{serverid}/reset")
          env[:ui].info I18n.t("vagrant_sakura.reset")

          @app.call(env)
        end
      end
    end
  end
end
