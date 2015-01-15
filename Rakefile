#!/usr/bin/env rake
require "bundler/gem_tasks"

task default: :all

task all: [:test, :rubocop]

desc "Run unit tests."
task :test do
  ruby "test/lruhash_test.rb"
end

desc "Check code style"
task :rubocop do
  puts `bundle exec rubocop --display-cop-names 2> /dev/null`
end
