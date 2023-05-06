# frozen_string_literal: true

require "libexec"

require_relative "lib/error"
require_relative "lib/dir"
require_relative "lib/console"

MACHINE_TARGETS = {
  "light-lpi4a" => ["thead-image-linux"]
}.freeze

Libexec.code("sudo apt-get -y install file python bison flex", Eapt)
Libexec.run("sudo chown -R ubuntu:ubuntu workdir/")

Dir.chdir("workdir/xuantie-yocto") do
  env_cmd = "source openembedded-core/oe-init-build-env thead-build/light-fm"

  Libexec.run("sudo chown -R ubuntu:ubuntu workdir/")

  MACHINE_TARGETS.each do |mach, targets|
    targets.each do |target|
      build_cmd = "MACHINE=#{mach} bitbake #{target}"

      exit_code = Libexec.code("#{env_cmd} && #{build_cmd}")

      if exit_code.zero?
        Console.info("Build yocto succeeded.")
      else
        Console.error("Build yocto failed!")
      end
    end
  end
end
