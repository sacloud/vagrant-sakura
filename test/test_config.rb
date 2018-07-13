require 'test/unit'
require "vagrant-sakura/config"

module VagrantPlugins
  module Sakura
    class TestConfig < Test::Unit::TestCase

      def setup
        %w("SAKURACLOUD_ACCESS_TOKEN" "SAKURACLOUD_ACCESS_TOKEN_SECRET" "SAKURACLOUD_ZONE").map do |k|
          ENV.delete(k)
        end
      end

      def test_apikeys
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
            }
        }

        cases.map {|name, c|
          puts "Case: #{name}"
          conf = Config.new
          conf.set_options c["config"]

          ENV.update c["env"]

          conf.finalize!
          assert_equal c["expects"]["token"], conf.access_token
          assert_equal c["expects"]["secret"], conf.access_token_secret
          assert_equal c["expects"]["zone"], conf.zone_id
        }
      end
    end
  end
end
