require 'test/unit'
require "vagrant-sakura/config"

module VagrantPlugins
  module Sakura
    class TestConfig < Test::Unit::TestCase
      def test_load_config
        cases = {
            "config only" => {
                "config" => {
                    "access_token" => "foo",
                    "access_token_secret" => "bar"
                },
                "env" => {},
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "is1b"
                }
            },
            "env(SAKURA_*) only" => {
                "config" => {},
                "env" => {
                    "SAKURA_ACCESS_TOKEN" => "foo",
                    "SAKURA_ACCESS_TOKEN_SECRET" => "bar",
                },
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "is1b"
                }
            },
            "env(SAKURACLOUD_*) only" => {
                "config" => {},
                "env" => {
                    "SAKURACLOUD_ACCESS_TOKEN" => "foo",
                    "SAKURACLOUD_ACCESS_TOKEN_SECRET" => "bar",
                    "SAKURACLOUD_ZONE" => "tk1a",
                },
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "tk1a"
                }
            },
            "env order" => {
                "config" => {},
                "env" => {
                    "SAKURA_ACCESS_TOKEN" => "foo",
                    "SAKURA_ACCESS_TOKEN_SECRET" => "bar",
                    "SAKURACLOUD_ACCESS_TOKEN" => "not_use",
                    "SAKURACLOUD_ACCESS_TOKEN_SECRET" => "not_use",
                    "SAKURACLOUD_ZONE" => "tk1a",
                },
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "tk1a"
                }
            },
            "profile only" => {
                "config" => {},
                "env" => {},
                "profile" => '{"AccessToken": "foo", "AccessTokenSecret": "bar", "Zone": "tk1a"}',
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "tk1a"
                }
            },
            "conf and profile order" => {
                "config" => {
                    "access_token" => "foo",
                    "access_token_secret" => "bar",
                    "zone_id" => "tk1a"
                },
                "env" => {},
                "profile" => '{"AccessToken": "not_use", "AccessTokenSecret": "not_use", "Zone": "not_use"}',
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "tk1a"
                }
            },
            "conf and env order" => {
                "config" => {
                    "access_token" => "foo",
                    "access_token_secret" => "bar",
                    "zone_id" => "tk1a"
                },
                "env" => {
                    "SAKURA_ACCESS_TOKEN" => "not_use",
                    "SAKURA_ACCESS_TOKEN_SECRET" => "not_use",
                    "SAKURACLOUD_ACCESS_TOKEN" => "not_use",
                    "SAKURACLOUD_ACCESS_TOKEN_SECRET" => "not_use",
                    "SAKURACLOUD_ZONE" => "not_use",
                },
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "tk1a"
                }
            },
            "profile and env order" => {
                "config" => {},
                "env" => {
                    "SAKURA_ACCESS_TOKEN" => "not_use",
                    "SAKURA_ACCESS_TOKEN_SECRET" => "not_use",
                    "SAKURACLOUD_ACCESS_TOKEN" => "not_use",
                    "SAKURACLOUD_ACCESS_TOKEN_SECRET" => "not_use",
                    "SAKURACLOUD_ZONE" => "not_use",
                },
                "profile" => '{"AccessToken": "foo", "AccessTokenSecret": "bar", "Zone": "tk1a"}',
                "expects" => {
                    "token" => "foo",
                    "secret" => "bar",
                    "zone" => "tk1a"
                }
            }
        }


        cases.map do |name, c|
          Dir.mktmpdir do |dir|
            env = { "USACLOUD_PROFILE_DIR" => dir }
            ENV.update env

            %w(SAKURA_ACCESS_TOKEN SAKURACLOUD_ACCESS_TOKEN SAKURA_ACCESS_TOKEN_SECRET SAKURACLOUD_ACCESS_TOKEN_SECRET SAKURACLOUD_ZONE).map do |k|
              ENV.delete(k)
            end

            if !c["profile"].nil?
              current_file = File.join(dir, ".usacloud", "current")
              FileUtils.mkdir_p(File.dirname(current_file))
              File.open(current_file, "w") do |file|
                file.puts "default"
              end

              profile_file = File.join(dir, ".usacloud", "default", "config.json")
              FileUtils.mkdir_p(File.dirname(profile_file))
              File.open(profile_file, "w") do |file|
                file.puts c["profile"]
              end
            end

            conf = Config.new
            conf.set_options c["config"]

            ENV.update c["env"]

            conf.finalize!

            assert_equal c["expects"]["token"], conf.access_token
            assert_equal c["expects"]["secret"], conf.access_token_secret
            assert_equal c["expects"]["zone"], conf.zone_id
          end
        end

      end

      def test_startup_scripts_handling
        cases = {
            "startup_scripts is empty" => {
                "config" => {},
                "expects" => {
                    "startup_scripts" => []
                }
            },

            "startup_scripts is a number" => {
                "config" => {
                    "startup_scripts" => 999999999999
                },
                "expects" => {
                    "startup_scripts" => [{"ID" => "999999999999"}]
                }
            },

            "startup_scripts is array" => {
                "config" => {
                    "startup_scripts" => [999999999999,888888888888]
                },
                "expects" => {
                    "startup_scripts" => [{"ID" => "999999999999"}, {"ID" => "888888888888"}]
                }
            },
        }

        cases.map do |name, c|
          conf = Config.new
          conf.set_options c["config"]
          conf.finalize!

          assert_equal c["expects"]["startup_scripts"], conf.startup_scripts
        end

      end
    end
  end
end
