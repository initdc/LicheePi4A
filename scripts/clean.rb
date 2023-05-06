# frozen_string_literal: true

require "libexec"
require_relative "lib/dir"
require_relative "lib/console"

top_dir = git_top_dir()
rm_cmd = "cd #{top_dir} && rm -rf #{arg_dirs}"

puts rm_cmd
exit_code = Libexec.code(rm_cmd)

exit_code.zero? ? Console.info("Clean completed.") : Console.error("Clean failed!")
