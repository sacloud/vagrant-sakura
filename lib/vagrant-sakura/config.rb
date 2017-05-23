require "vagrant"

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
        @tags                = UNSET_VALUE
        @description         = UNSET_VALUE
      end

      def finalize!
        if @access_token == UNSET_VALUE
          @access_token = ENV['SAKURA_ACCESS_TOKEN']
        end

        if @access_token_secret == UNSET_VALUE
          @access_token_secret = ENV['SAKURA_ACCESS_TOKEN_SECRET']
        end

        if @disk_id == UNSET_VALUE
          @disk_id = nil  # create a new disk
        end

        if @disk_plan == UNSET_VALUE
          @disk_plan = 4  # SSD
        end

        if @disk_source_archive == UNSET_VALUE
          @disk_source_archive = 112800438454
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
          @zone_id = "is1a"  # the first zone
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
    end
  end
end
