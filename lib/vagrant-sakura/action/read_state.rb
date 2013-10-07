require 'log4r'
require 'vagrant-sakura/driver/api'

module VagrantPlugins
  module Sakura
    module Action
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env[:sakura_api], env[:machine])
          @app.call(env)
        end

        # returns one of [ :cleaning, :down, :not_created, :up,  ]
        def read_state(api, machine)

          return :not_created if machine.id.nil?

          serverid = machine.id
          begin
            response = api.get("/server/#{serverid}")
          rescue Driver::NotFoundError
            machine.id = nil
            return :not_created
          end
          return response["Server"]["Instance"]["Status"].to_sym
        end
      end
    end
  end
end
