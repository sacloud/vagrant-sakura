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
          server_name = env[:machine].provider_config.server_name
          server_name ||= env[:machine].name
          server_plan = env[:machine].provider_config.server_plan
          disk_plan = env[:machine].provider_config.disk_plan
          disk_source_mode = env[:machine].provider_config.disk_source_mode
          os_type = env[:machine].provider_config.os_type
          disk_source_archive = env[:machine].provider_config.disk_source_archive
          sshkey_id = env[:machine].provider_config.sshkey_id
          public_key_path = env[:machine].provider_config.public_key_path
          use_insecure_key = env[:machine].provider_config.use_insecure_key
          enable_pw_auth = env[:machine].provider_config.enable_pw_auth
          packet_filter = env[:machine].provider_config.packet_filter.to_s
          startup_scripts = env[:machine].provider_config.startup_scripts
          tags = env[:machine].provider_config.tags
          description = env[:machine].provider_config.description

          env[:ui].info(I18n.t("vagrant_sakura.creating_instance"))
          env[:ui].info(" -- Server Name: #{server_name}")
          env[:ui].info(" -- Server Plan: #{server_plan}")
          env[:ui].info(" -- Disk Plan: #{disk_plan}")
          env[:ui].info(" -- Disk Source OS Type: #{os_type}") if os_type
          env[:ui].info(" -- Disk Source Archive: #{disk_source_archive}")
          env[:ui].info(" -- Packet Filter: #{packet_filter}") unless packet_filter.empty?
          env[:ui].info(" -- Startup Scripts: #{startup_scripts.map {|item| item["ID"]}}") unless startup_scripts.empty?
          env[:ui].info(" -- Tags: #{tags}") unless tags.empty?
          env[:ui].info(" -- Description: \"#{description}\"") unless description.empty?

          api = env[:sakura_api]

          if env[:machine].provider_config.disk_id
            diskid = env[:machine].provider_config.disk_id
          else
            data = {
              "Disk" => {
                "Name" => server_name,
                "Plan" => { "ID" => disk_plan },
                "Connection" => "virtio",
                "SourceArchive" => {
                  "ID" => disk_source_archive
                },
                "Tags" => tags,
                "Description" => description
              }
            }
            response = api.post("/disk", data)
            unless response["Disk"]["ID"]
              raise 'no Disk ID returned'
            end
            diskid = response["Disk"]["ID"]

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
          end

          data = {
            "Server" => {
              "Name" => server_name,
              "ServerPlan" => { "ID" => server_plan },
              "ConnectedSwitches" => [
                { "Scope" => "shared", "BandWidthMbps" => 100 }
              ],
              "Tags" => tags,
              "Description" => description
            }
          }
          response = api.post("/server", data)
          unless response["Server"]["ID"]
            raise 'no Server ID returned'
          end
          env[:machine].id = serverid = response["Server"]["ID"]
          interface_id = response["Server"]["Interfaces"][0]["ID"]
          # Server Created

          unless packet_filter.empty?
            response = api.put("/interface/#{interface_id}/to/packetfilter/#{packet_filter}")
            # Packet Filter connected to Server
          end

          begin
            response = api.put("/disk/#{diskid}/to/server/#{serverid}")
            # Disk mounted to Server
          rescue VagrantPlugins::Sakura::Driver::NotFoundError
            terminate(env)
            raise
          end

          data = {
            "UserSubnet" => {},
            "Notes" => startup_scripts,
            "DisablePWAuth" => !enable_pw_auth
          }
          if sshkey_id
            data["SSHKey"] = { "ID" => sshkey_id }
          elsif public_key_path
            data["SSHKey"] = { "PublicKey" => File.read(public_key_path) }
          elsif use_insecure_key
            pubkey = Vagrant.source_root.join("keys", "vagrant.pub").read.chomp
            data["SSHKey"] = { "PublicKey" => pubkey }
          else
            raise 'failsafe'
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
