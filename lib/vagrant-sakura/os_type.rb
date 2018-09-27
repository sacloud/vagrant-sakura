module VagrantPlugins
  module Sakura
    module OSType
      OS_TYPE_QUERIES = {
          "centos" => {
              "Tags.Name" => [%w(current-stable distro-centos)]
          },
          "centos6" => {
              "Tags.Name" => [%w(distro-centos distro-ver-6.10)]
          },
          "ubuntu" => {
              "Tags.Name" => [%w(current-stable distro-ubuntu)]
          },
          "ubuntu-16.04" => {
              "Tags.Name" => [%w(distro-ubuntu distro-ver-16.04.4)]
          },
          "ubuntu-18.04" => {
              "Tags.Name" => [%w(distro-ubuntu distro-ver-18.04)]
          },
          "debian" => {
              "Tags.Name" => [%w(current-stable distro-debian)]
          },
          "coreos" => {
              "Tags.Name" => [%w(current-stable distro-coreos)]
          },
          "rancheros" => {
              "Tags.Name" => [%w(current-stable distro-rancheros)]
          },
          "freebsd" => {
              "Tags.Name" => [%w(current-stable distro-freebsd)]
          },
      }

      def self.os_types
        OS_TYPE_QUERIES.keys
      end
    end
  end
end

