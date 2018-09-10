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

