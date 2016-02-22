require 'minitest/autorun'
require 'test_helper'
require 'convert/ibm390'

include Convert::IBM390

class TestIBM390Converter < Minitest::Test

  context "ascii string to number converters" do

    should "convert a number with no implied decimals" do
      original = "008910"
      assert_equal 8910, ascnum2num(original)
    end

    should "convert a positive signed number with no implied decimals" do
      original = "000299{"
      assert_equal 2990, asc_zoned2num(original)
    end

    should "convert a negative signed number with no implied decimals" do
      original = "000299}"
      assert_equal -2990, asc_zoned2num(original)
    end

    should "convert a number with implied decimals" do
      original = "000299"
      assert_equal 2.99, ascnum2num(original, 2)
    end

    should "convert a negative signed number with implied decimals" do
      original = "000299J"
      assert_equal -29.91, asc_zoned2num(original, 2)
    end

    should "convert a positive signed number with implied decimals" do
      original = "000299{"
      assert_equal 29.90, asc_zoned2num(original, 2)
    end

  end
end
