#!/usr/bin/env ruby

ADDED_OR_MODIFIED = /^\s*(A|AM|M)/.freeze

def detect_changed_files
  changed_files  = `git status --porcelain`.split(/\n/)
  unstaged_files = `git ls-files -m`.split(/\n/)

  changed_files = changed_files.select { |f| f =~ ADDED_OR_MODIFIED }
  changed_files = changed_files.map { |f| f.split(" ")[1] }

  changed_files -= (unstaged_files - changed_files)

  # changed_files = changed_files.select { |file_name| File.extname(file_name) == ".rb" }
  changed_files = changed_files.join(" ")

  exit(0) if changed_files.empty?
  changed_files
end

files = detect_changed_files
success = system(%(
  rubocop -A --format simple --display-cop-names --extra-details  --force-exclusion #{files}
))

if success == false
  RED = '\033[0;31m'.freeze
  NC = '\033[0m'.freeze # No Color
  puts "\e[31m Files listed above has errors please fix and recommit \e[0m  \n"
  exit(1)
end

puts "\e[32m  Adding files  : \e[0m "
puts files.split(" ").join("\n")
puts

system("git add #{files}")
exit(0)
