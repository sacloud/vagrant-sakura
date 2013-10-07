require "pathname"

require "vagrant-sakura/plugin"
require "vagrant-sakura/version"

module VagrantPlugins
  module Sakura
    lib_path = Pathname.new(File.expand_path("../vagrant-sakura", __FILE__))
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
