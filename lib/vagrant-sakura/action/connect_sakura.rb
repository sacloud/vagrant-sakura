require 'vagrant-sakura/driver/api'

module VagrantPlugins
  module Sakura
    module Action
      class ConnectSakura
        def initialize(app, env)
          @app = app
        end

        def call(env)
          token  = env[:machine].provider_config.access_token
          secret = env[:machine].provider_config.access_token_secret
          zone   = env[:machine].provider_config.zone_id
          env[:sakura_api] = Driver::API.new(token, secret, zone)

          @app.call(env)
        end
      end
    end
  end
end
