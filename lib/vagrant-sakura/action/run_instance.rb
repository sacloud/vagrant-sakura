require 'vagrant/util/retryable'

require 'vagrant-sakura/driver/api'
#require 'vagrant-sakura/util/timer'
require 'log4r'

module VagrantPlugins
  module Sakura
    module Action
      class RunInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::run_instance")
        end

        def call(env)
          server_name = env[:machine].name
          server_name ||= env[:machine].provider_config.server_name
          server_plan = env[:machine].provider_config.server_plan
          disk_plan = env[:machine].provider_config.disk_plan
          disk_source_archive = env[:machine].provider_config.disk_source_archive
          sshkey_id = env[:machine].provider_config.sshkey_id

          env[:ui].info(I18n.t("vagrant_sakura.creating_instance"))
          env[:ui].info(" -- Server Name: #{server_name}")
          env[:ui].info(" -- Server Plan: #{server_plan}")
          env[:ui].info(" -- Disk Plan: #{disk_plan}")
          env[:ui].info(" -- Disk Source Archive: #{disk_source_archive}")

          api = env[:sakura_api]
          data = {
            "Disk" => {
              "Name" => server_name,
              "Zone" => { "ID" => 31001 },      # Ishikari only
              "Plan" => { "ID" => disk_plan },
              "Connection" => "virtio",
              "SourceArchive" => {
                "ID" => disk_source_archive
              } 
            }
          }
          response = api.post("/disk", data)
          unless response["Disk"]["ID"]
            raise 'no Disk ID returned'
          end
          diskid = response["Disk"]["ID"]
          # Disk Created

          while true
            response = api.get("/disk/#{diskid}")
            case response["Disk"]["Availability"]
            when "available"
              break
            when "migrating"
              migrated = response["Disk"]["MigratedMB"]
              size = response["Disk"]["SizeMB"]
              env[:ui].info("Disk #{diskid} is migrating (#{migrated}/#{size})")
            else
              status = presponse["Disk"]["Availability"]
              env[:ui].info("Disk #{diskid} is #{status}")
            end
            sleep 3
          end
          # Wait for Disk is available

          data = {
            "Server" => {
              "Name" => server_name,
              "Zone" => { "ID" => 31001 },        # Ishikari
              "ServerPlan" => { "ID" => server_plan },
              "ConnectedSwitches" => [
                { "Scope" => "shared", "BandWidthMbps" => 100 }
              ]
            }
          }
          response = api.post("/server", data)
          unless response["Server"]["ID"]
            raise 'no Server ID returned'
          end
          env[:machine].id = serverid = response["Server"]["ID"]
          # Server Created

          response = api.put("/disk/#{diskid}/to/server/#{serverid}")
          # Disk mounted to Server

          data = {
            "UserSubnet" => {}
          }
          if sshkey_id
            data["SSHKey"] = { "ID" => sshkey_id }
          else
            path = env[:machine].ssh_info[:private_key_path] + '.pub'
            data["SSHKey"] = { "PublicKey" => File.read(path) }
          end
          response = api.put("/disk/#{diskid}/config", data)
          # Config

          response = api.put("/server/#{serverid}/power")
          # Power On

          if !env[:interrupted]
            # Wait for SSH to be ready.
            env[:ui].info(I18n.t("vagrant_sakura.waiting_for_ssh"))
            while true
              break if env[:interrupted]
              break if env[:machine].communicate.ready?
              sleep 2
            end

            #@logger.info("Time for SSH ready: #{env[:metrics]["instance_ssh_time"]}")

            # Ready and booted!
            env[:ui].info(I18n.t("vagrant_sakura.ready"))
          end

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]

          @app.call(env)
        end

        def recover(env)
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          if env[:machine].provider.state.id != :not_created
            # Undo the import
            terminate(env)
          end
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end
      end
    end
  end
end
