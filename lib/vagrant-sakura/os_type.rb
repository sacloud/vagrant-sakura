module VagrantPlugins
  module Sakura
    module OSType
      OS_TYPE_QUERIES = {
          "centos" => {
              "Tags.Name" => [%w(current-stable distro-centos)]
          },
          "centos8" => {
              "Tags.Name" => [%w(centos-8-latest)]
          },
          "centos7" => {
              "Tags.Name" => [%w(centos-7-latest)]
          },
          "centos6" => {
              "Tags.Name" => [%w(centos-6-latest)]
          },
          "ubuntu" => {
              "Tags.Name" => [%w(current-stable distro-ubuntu)]
          },
          "ubuntu-18.04" => {
              "Tags.Name" => [%w(ubuntu-18.04-latest)]
          },
          "ubuntu-16.04" => {
              "Tags.Name" => [%w(ubuntu-16.04-latest)]
          },
          "debian" => {
              "Tags.Name" => [%w(current-stable distro-debian)]
          },
          "debian10" => {
              "Tags.Name" => [%w(debian-10-latest)]
          },
          "debian9" => {
              "Tags.Name" => [%w(debian-9-latest)]
          },
          "coreos" => {
              "Tags.Name" => [%w(current-stable distro-coreos)]
          },
          "rancheros" => {
              "Tags.Name" => [%w(current-stable distro-rancheros)]
          },
          "k3os" => {
              "Tags.Name" => [%w(current-stable distro-k3os)]
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

