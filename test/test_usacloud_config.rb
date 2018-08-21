require 'test/unit'
require "vagrant-sakura/config"
require 'tmpdir'
require 'fileutils'

module VagrantPlugins
  module Sakura
    class TestUsacloudConfig < Test::Unit::TestCase
      def setup
        %w(SAKURACLOUD_ACCESS_TOKEN SAKURACLOUD_ACCESS_TOKEN_SECRET SAKURACLOUD_ZONE USACLOUD_PROFILE_DIR).map do |k|
          ENV.delete(k)
        end
      end

      def test_choose_profile_dir
        cases = {
            "USACLOUD_PROFILE_DIR is empty" => {
                "env" => {"USACLOUD_PROFILE_DIR" => ""},
                "expect" => File.expand_path("~/.usacloud")
            },
            "USACLOUD_PROFILE_DIR is set" => {
                "env" => {"USACLOUD_PROFILE_DIR" => "/tmp"},
                "expect" => "/tmp/.usacloud"
            }
        }

        cases.map {|name, c|
          conf = Config.new
          ENV.update c["env"]

          assert_equal c["expect"], conf.choose_usacloud_profile_dir
        }

      end

      def test_get_current_profile_name
        cases = {
            "current file is missing" => {
                "prepare" => false,
                "expect" => "default"
            },
            "current file is empty" => {
                "prepare" => true,
                "profile" => "",
                "expect" => "default"
            },
            "current file has valid value" => {
                "prepare" => true,
                "profile" => "test",
                "expect" => "test"
            },
        }


        Dir.mktmpdir do |dir|
          env = { "USACLOUD_PROFILE_DIR" => dir }
          ENV.update env

          cases.map {|name, c|
            conf = Config.new
            if c["prepare"]
              file_path = File.join(dir, ".usacloud", "current")
              FileUtils.mkdir_p(File.dirname(file_path))
              File.open(file_path, "w") do |file|
                file.puts c["profile"]
              end
            end

            assert_equal c["expect"], conf.get_usacloud_profile_name
          }
        end

      end

      def test_get_usacloud_config
        cases = {
            "profile is missing" => {
                "profile_body" => nil,
                "expect" => nil
            },
            "profile is invalid JSON" => {
                "profile_body" => "Invalid JSON",
                "expect" => nil
            },
            "profile has valid value" => {
                "profile_body" => '{"AccessToken": "token", "AccessTokenSecret": "secret", "Zone": "zone"}',
                "expect" => {
                    "AccessToken" => "token",
                    "AccessTokenSecret" => "secret",
                    "Zone" => "zone",
                }
            },
        }


        Dir.mktmpdir do |dir|
          env = { "USACLOUD_PROFILE_DIR" => dir }
          ENV.update env

          cases.map do |name, c|
            conf = Config.new

            current_file = File.join(dir, ".usacloud", "current")
            FileUtils.mkdir_p(File.dirname(current_file))
            File.open(current_file, "w") do |file|
              file.puts "default"
            end

            if !c["profile_body"].nil?
              profile_file = File.join(dir, ".usacloud", "default", "config.json")
              FileUtils.mkdir_p(File.dirname(profile_file))
              File.open(profile_file, "w") do |file|
                file.puts c["profile_body"]
              end
            end

            assert_equal c["expect"], conf.get_usacloud_config
          end
        end
      end
    end
  end
end
