# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/byebug'
require 'shoulda/context'
require 'pathname'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

THISDIR = Pathname.new(__dir__).realpath
DATADIR = File.join(THISDIR, 'data')
