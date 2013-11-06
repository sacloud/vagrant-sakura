require "log4r"

module VagrantPlugins
  module Sakura
    module Action
      class DeleteServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::delete_server")
        end

        def call(env)
          api      = env[:sakura_api]
          serverid = env[:machine].id

          env[:ui].info(I18n.t("vagrant_sakura.terminating"))

          response = api.get("/server/#{serverid}")
          unless response["Server"]["Instance"]["Status"] == "down"
            api.delete("/server/#{serverid}/power", { "Force" => true })
            while true
              r = api.get("/server/#{serverid}/power")
              break if r["Instance"]["Status"] == "down"
              sleep 1
            end
          end

          disks = response["Server"]["Disks"].map { |disk| disk["ID"] }
          disks.delete_if { |diskid|
            diskid == env[:machine].provider_config.disk_id.to_s
          }
          data = { "WithDisk" => disks }
          response = api.delete("/server/#{serverid}", data)
          # error check
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
