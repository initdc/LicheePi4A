# frozen_string_literal: true

require "libexec"

CACHE_DIR = "cache"
BUILD_DIR = "build"
TARGET_DIR = "target"
UPLOAD_DIR = "upload"

def dirs_arr
  [CACHE_DIR, BUILD_DIR, TARGET_DIR, UPLOAD_DIR]
end

def arg_dirs
  dirs_arr.join(" ")
end

def git_top_dir
  Libexec.output("git rev-parse --show-toplevel")
end
