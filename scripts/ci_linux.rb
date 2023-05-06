# frozen_string_literal: true

require "libexec"

require_relative "lib/error"
require_relative "lib/dir"
require_relative "lib/console"

top_dir = git_top_dir()

CI_CACHE = true
CI_CACHE_ARG = CI_CACHE ? "O=#{top_dir}/#{BUILD_DIR}/linux" : ""
BUILD_PKG_DIR = CI_CACHE ? "#{top_dir}/#{BUILD_DIR}/linux" : "."

CONFIGS = {
  "revyos_defconfig" => ["riscv", "riscv64-unknown-linux-gnu-"]
}.freeze
FILES = "*.tar"

Libexec.run("cd #{top_dir} && mkdir -p #{arg_dirs}")

Dir.chdir("#{top_dir}/external/revyos/thead-kernel") do
  CONFIGS.each do |config, arr|
    arch = arr[0]
    cross = arr[1]

    # https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/README.rst
    config_cmd = if arch.empty?
                   "make #{config} #{CI_CACHE_ARG}"
                 else
                   "ARCH=#{arch} CROSS_COMPILE=#{cross} make #{config} #{CI_CACHE_ARG}"
                 end
    Libexec.code(config_cmd, Econfig)

    make_cmd = if arch.empty?
                 "make tar-pkg -j$(nproc) #{CI_CACHE_ARG}"
               else
                 "ARCH=#{arch} CROSS_COMPILE=#{cross} make tar-pkg -j$(nproc) #{CI_CACHE_ARG}"
               end
    result = Libexec.code(make_cmd).zero?
    next unless result

    pre = config.delete_suffix("_defconfig")
    Libexec.run("git config --global --add safe.directory #{top_dir}/external/revyos/thead-kernel")
    git_rev = Libexec.output("git rev-parse --short HEAD")

    target = "#{top_dir}/#{TARGET_DIR}/linux/#{git_rev}/#{pre}"
    Libexec.run("mkdir -p #{target}")
    FILES.split(" ").each do |file|
      Libexec.run("cp #{BUILD_PKG_DIR}/#{file} #{top_dir}/#{UPLOAD_DIR}")
      Libexec.run("mv #{BUILD_PKG_DIR}/#{file} #{target}")
    end
  end
end
