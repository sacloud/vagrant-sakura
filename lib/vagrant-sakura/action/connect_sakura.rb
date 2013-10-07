require "log4r"
require 'vagrant-sakura/driver/api'

module VagrantPlugins
  module Sakura
    module Action
      class ConnectSakura
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::connect_sakura")
        end

        def call(env)
          token  = env[:machine].provider_config.access_token
          secret = env[:machine].provider_config.access_token_secret
          env[:sakura_api] = Driver::API.new(token, secret)

          @app.call(env)
        end
      end
    end
  end
end
