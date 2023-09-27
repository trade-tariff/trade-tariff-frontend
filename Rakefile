#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# rubocop:disable Style/ExpandPathArguments
require File.expand_path('../config/application', __FILE__)
# rubocop:enable Style/ExpandPathArguments

TradeTariffFrontend::Application.load_tasks

task default: %w[
  spec
]
