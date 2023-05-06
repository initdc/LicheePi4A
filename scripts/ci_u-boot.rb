# frozen_string_literal: true

require "libexec"

require_relative "lib/error"
require_relative "lib/dir"
require_relative "lib/console"

top_dir = git_top_dir()

CONFIGS = {
  "light_lpi4a_defconfig" => "riscv64-unknown-linux-gnu-"
}.freeze
FILES = "*.map u-boot*"

Libexec.run("cd #{top_dir} && mkdir -p #{arg_dirs}")

Dir.chdir("#{top_dir}/external/revyos/thead-u-boot") do
  CONFIGS.each do |config, cross|
    Libexec.code("make #{config}", Econfig)
    make_cmd = if cross.empty?
                 "make -j$(nproc)"
               else
                 "CROSS_COMPILE=#{cross} make -j$(nproc)"
               end
    result = Libexec.code(make_cmd).zero?
    next unless result

    pre = config.delete_suffix("_defconfig")
    Libexec.run("git config --global --add safe.directory #{top_dir}/external/revyos/thead-u-boot")
    git_rev = Libexec.output("git rev-parse --short HEAD")
    tar_file = "#{pre}_#{git_rev}.tgz"

    target = "#{top_dir}/#{TARGET_DIR}/u-boot/#{git_rev}/#{pre}"
    puts target
    puts "#{top_dir}/#{UPLOAD_DIR}"
    Libexec.run("mkdir -p #{target}")
    Libexec.code("tar -zcvf #{tar_file} #{FILES}", Etar)
    Libexec.run("mv #{tar_file} #{top_dir}/#{UPLOAD_DIR}")
    FILES.split(" ").each do |file|
      Libexec.run("mv #{file} #{target}")
    end
  end
end
