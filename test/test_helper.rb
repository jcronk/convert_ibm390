require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/byebug'
require 'shoulda/context'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

THISDIR = File.expand_path("..",__FILE__)
DATADIR = File.join(THISDIR, 'data')

