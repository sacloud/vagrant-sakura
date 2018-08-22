require "vagrant"
require "json"

module VagrantPlugins
  module Sakura
    class Config < Vagrant.plugin("2", :config)
      # The ACCESS TOKEN to access Sakura Cloud API.
      #
      # @return [String]
      attr_accessor :access_token

      # The ACCESS TOKEN SECRET to access Sakura Cloud API.
      #
      # @return [String]
      attr_accessor :access_token_secret

      # The ID of the disk to be connected to the server.
      #
      # @return [Fixnum]
      attr_accessor :disk_id

      # The plan ID of the disk to be connected to the server.
      #
      # @return [Fixnum]
      attr_accessor :disk_plan

      # The source archive of the disk image to be copied to the instance.
      #
      # @return [String]
      attr_accessor :disk_source_archive

      # The pathname of the SSH public key to register on the server.
      #
      # @return [String]
      attr_accessor :public_key_path

      # The name of the server.
      # 
      # @return [String]
      attr_accessor :server_name

      # The Plan ID of the server.
      # 
      # @return [Fixnum]
      attr_accessor :server_plan

      # The resource ID of the SSH public key to login the server.
      # 
      # @return [String]
      attr_accessor :sshkey_id

      # Use insecure default key to login the server.
      #
      # @return [Boolean]
      attr_accessor :use_insecure_key

      # The ID of the zone.
      attr_accessor :zone_id

      # The path of the usacloud config.
      #
      # @return [String]
      attr_accessor :config_path

      # The tags of the server and disk.
      #
      # @return [Array<String>]
      attr_accessor :tags

      # The description of the server and disk.
      #
      # @return [String]
      attr_accessor :description

      def initialize
        @access_token        = UNSET_VALUE
        @access_token_secret = UNSET_VALUE
        @disk_id             = UNSET_VALUE
        @disk_plan           = UNSET_VALUE
        @disk_source_archive = UNSET_VALUE
        @public_key_path     = UNSET_VALUE
        @server_name         = UNSET_VALUE
        @server_plan         = UNSET_VALUE
        @sshkey_id           = UNSET_VALUE
        @use_insecure_key    = UNSET_VALUE
        @zone_id             = UNSET_VALUE
        @config_path         = UNSET_VALUE
        @tags                = UNSET_VALUE
        @description         = UNSET_VALUE
      end

      def finalize!

        usacloud_config = get_usacloud_config(@config_path)

        if @access_token == UNSET_VALUE
          if usacloud_config.nil?
            @access_token = nil
          else
            @access_token = usacloud_config["AccessToken"]
          end
          @access_token = ENV['SAKURA_ACCESS_TOKEN'] if @access_token.nil?
          @access_token = ENV['SAKURACLOUD_ACCESS_TOKEN'] if @access_token.nil?
        end

        if @access_token_secret == UNSET_VALUE
          if usacloud_config.nil?
            @access_token_secret = nil
          else
            @access_token_secret = usacloud_config["AccessTokenSecret"]
          end
          @access_token_secret = ENV['SAKURA_ACCESS_TOKEN_SECRET'] if @access_token_secret.nil?
          @access_token_secret = ENV['SAKURACLOUD_ACCESS_TOKEN_SECRET'] if @access_token_secret.nil?
        end

        if @disk_id == UNSET_VALUE
          @disk_id = nil  # create a new disk
        end

        if @disk_plan == UNSET_VALUE
          @disk_plan = 4  # SSD
        end

        if @disk_source_archive == UNSET_VALUE
          @disk_source_archive = 113000423772 # Ubuntu Server 16.04.4 LTS 64bit on is1b
        end

        @public_key_path = nil if @public_key_path == UNSET_VALUE

        if @server_name == UNSET_VALUE
          @server_name = nil
        end

        if @server_plan == UNSET_VALUE
          @server_plan = 1001  # 1Core-1GB - cheapest
        end

        @sshkey_id = nil if @sshkey_id == UNSET_VALUE

        @use_insecure_key = false if @use_insecure_key == UNSET_VALUE

        if @zone_id == UNSET_VALUE
          if usacloud_config.nil?
            @zone_id = nil
          else
            @zone_id = usacloud_config["Zone"]
          end
          @zone_id = ENV['SAKURACLOUD_ZONE'] if @zone_id.nil?
          @zone_id = "is1b" if @zone_id.nil?
        end

        @tags = [] if @tags == UNSET_VALUE
        @tags = [@tags] unless @tags.is_a?(Array)
        @tags.map!(&:to_s)

        @description = "" if @description == UNSET_VALUE
        @description = @description.to_s
      end

      def validate(machine)
        errors = _detected_errors

        if @access_token.nil?
          errors << I18n.t("vagrant_sakura.config.access_token_required")
        end
        if @access_token_secret.nil?
          errors << I18n.t("vagrant_sakura.config.access_token_secret_required")
        end

        if not (@sshkey_id or @public_key_path or @use_insecure_key)
          errors << I18n.t("vagrant_sakura.config.need_ssh_key_config")
        end

        { "Sakura Provider" => errors }
      end

      def choose_usacloud_profile_dir
        profile_path = ENV.fetch("USACLOUD_PROFILE_DIR", "")
        if profile_path.empty?
          File.expand_path("~/.usacloud")
        else
          File.join(File.expand_path(profile_path), ".usacloud")
        end
      end

      def get_usacloud_profile_name
        profile_dir = choose_usacloud_profile_dir
        current_file = File.join(profile_dir, "current")

        return "default" unless FileTest.exist? current_file
        File.open(current_file) do |file|
          file.read.split("\n").each do |line|
            return line
          end
        end
        "default"
      end

      def get_usacloud_config(config_path = nil)
        if config_path.nil? || config_path == UNSET_VALUE
          profile_dir = choose_usacloud_profile_dir
          profile_name = get_usacloud_profile_name

          return nil if profile_name.empty?
          config_path = File.join(profile_dir, profile_name, "config.json")
        end

        if FileTest.exist?(config_path)
          File.open(config_path) do |file|
            begin
              json = JSON.load(file)
              return json
            rescue JSON::ParserError
              return nil
            end
          end
        end

        nil
      end
    end
  end
end
