module VagrantPlugins
  module Sakura
    module Action
      class MessageAlreadyCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t("vagrant_sakura.already_created"))
          @app.call(env)
        end
      end
    end
  end
end
