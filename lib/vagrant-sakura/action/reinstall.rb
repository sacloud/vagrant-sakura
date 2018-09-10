require 'vagrant/util/retryable'

require 'vagrant-sakura/driver/api'
#require 'vagrant-sakura/util/timer'
require 'log4r'

module VagrantPlugins
  module Sakura
    module Action
      class Reinstall
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_sakura::action::run_instance")
        end

        def call(env)
          disk_source_archive = env[:machine].provider_config.disk_source_archive
          os_type = env[:machine].provider_config.os_type
          sshkey_id = env[:machine].provider_config.sshkey_id
          public_key_path = env[:machine].provider_config.public_key_path
          use_insecure_key = env[:machine].provider_config.use_insecure_key
          enable_pw_auth = env[:machine].provider_config.enable_pw_auth
          startup_scripts = env[:machine].provider_config.startup_scripts

          api = env[:sakura_api]
          serverid = env[:machine].id
          diskid = env[:machine].provider_config.disk_id

          unless env[:machine].provider_config.disk_id
            begin
              response = api.get("/server/#{serverid}")
            rescue Driver::NotFoundError
              raise 'server not found'
            end
            diskid = response["Server"]["Disks"][0]["ID"]
          end

          env[:ui].info(I18n.t("vagrant_sakura.reinstalling_disk"))
          env[:ui].info(" -- Target Disk ID: #{diskid}") if os_type
          env[:ui].info(" -- Disk Source OS Type: #{os_type}") if os_type
          env[:ui].info(" -- Disk Source Archive: #{disk_source_archive}")
          env[:ui].info(" -- Startup Scripts: #{startup_scripts.map {|item| item["ID"]}}") unless startup_scripts.empty?

         data = {
             "Disk" => {
                 "SourceArchive" => {
                     "ID" => disk_source_archive
                 },
             }
         }
         response = api.put("/disk/#{diskid}/install", data)

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

          @app.call(env)
        end

      end
    end
  end
end
