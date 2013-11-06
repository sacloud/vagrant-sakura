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

      # The ID of the zone.
      attr_accessor :zone_id

      def initialize
        @access_token        = UNSET_VALUE
        @access_token_secret = UNSET_VALUE
        @disk_id             = UNSET_VALUE
        @disk_plan           = UNSET_VALUE
        @disk_source_archive = UNSET_VALUE
        @server_name         = UNSET_VALUE
        @server_plan         = UNSET_VALUE
        @sshkey_id           = UNSET_VALUE
        @zone_id             = UNSET_VALUE
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
          @disk_source_archive = 112500182464  # Ubuntu 12.04
        end

        if @server_name == UNSET_VALUE
          @server_name = nil
        end

        if @server_plan == UNSET_VALUE
          @server_plan = 1001  # 1Core-1GB - cheapest
        end

        if @sshkey_id == UNSET_VALUE
          @sshkey_id = nil
        end

        if @zone_id == UNSET_VALUE
          @zone_id = "is1a"  # the first zone
        end
      end

      def validate(machine)
        errors = []

        if config.access_token.nil?
          errors << I18n.t("vagrant_sakura.config.access_token_required")
        end
        if config.access_token_secret.nil?
          errors << I18n.t("vagrant_sakura.config.access_token_secret_required")
        end

        { "Sakura Provider" => errors }
      end
    end
  end
end
