require "log4r"

module VagrantPlugins
  module Sakura
    module Action
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::read_ssh_info")
        end

        def call(env)
          api      = env[:sakura_api]
          serverid = env[:machine].id

          if serverid.nil?
            env[:machine_ssh_info] = nil 
          else
            begin
              response = api.get("/server/#{serverid}")
              env[:machine_ssh_info] = {
                :host => response["Server"]["Interfaces"][0]["IPAddress"],
                :port => 22
              }
            rescue Driver::NotFoundError
              @logger.info("Machine couldn't be found, assuming it has been destroyed.")
              env[:machine].id = nil
              env[:machine_ssh_info] = nil
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
