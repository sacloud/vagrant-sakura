module VagrantPlugins
  module Sakura
    module Action
      class ListId
        def initialize(app, env)
          @app = app
        end

        def call(env)
          api = env[:sakura_api]

          puts "Zone: %s" % env[:machine].provider_config.zone_id
          puts ""

          puts "---- Archives ----"
          puts "%-14s %5s  %s" % ["ID", "Size", "Name"]
          r = api.get("/archive")
          r["Archives"].sort { |a, b|
            a["DisplayOrder"].to_i <=> b["DisplayOrder"].to_i
          }.each { |archive|
            gb = archive["SizeMB"] / 1024
            puts "%-14u %3uGB  %s" % [archive["ID"], gb, archive["Name"]]
          }
          puts ""

          puts "---- Server Plans ----"
          puts "%-7s %-70s" % ["ID",  "Name"]
          r = api.get("/product/server")
          r["ServerPlans"].each { |plan|
            puts "%-7u %s" % [plan["ID"], plan["Name"]]
          }
          puts ""

          @app.call(env)
        end
      end
    end
  end
end
