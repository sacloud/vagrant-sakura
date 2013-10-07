module VagrantPlugins
  module Sakura
    module Action
      class MessageDown
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_sakura.down"))
          @app.call(env)
        end
      end
    end
  end
end
