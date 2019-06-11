# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'convert/ibm390'

module Convert
  class IBM390Test < Minitest::Test

    describe 'IBM390.ascnum2num' do
      include Convert::IBM390
      it 'converts a number with no implied decimals' do
        original = '008910'
        assert_equal(8910, ascnum2num(original))
      end

      context 'when the number has implied decimals' do
        it 'places the decimal point in the correct position' do
          original = '000299'
          assert_equal(2.99, ascnum2num(original, 2), '000299 with 2 implied decimals is 2.99')
        end
      end
    end

    describe 'IBM390.asc_zoned2num' do
      include Convert::IBM390
      it 'converts a positive signed number with no implied decimals' do
        original = '000299{'
        assert_equal(
          2990,
          asc_zoned2num(original),
          'a sign of "{" means the last digit is 0 and the number is positive'
        )
      end

      it 'converts a negative signed number with no implied decimals' do
        original = '000299}'
        assert_equal(
          -2990,
          asc_zoned2num(original),
          'a sign of "}" means the last digit is 0 and the number is negative'
        )
      end

      it 'converts a negative signed number with implied decimals' do
        original = '000299J'
        assert_equal(
          -29.91,
          asc_zoned2num(original, 2),
          'a sign of "J" means the last digit is 1 and the number is negative'
        )
      end

      it 'converts a positive signed number with implied decimals' do
        original = '000299{'
        assert_equal(
          29.90,
          asc_zoned2num(original, 2),
          'with 2 implied decimals, a zoned "000299{" is 29.9'
        )
      end
    end

    describe 'IBM390.zoned2num' do
      include Convert::IBM390

      it 'converts a negative signed number' do
        nbr = "\xF2\xF9\xF9\xD0".b
        assert_equal(-2990, zoned2num(nbr, 0))
      end
      it 'converts a positive signed number' do
        nbr = "\xF2\xF9\xF9\xC0".b
        assert_equal 2990, zoned2num(nbr, 0)
      end
      it 'converts a signed number with implied decimals' do
        nbr = "\xF2\xF9\xF9\xD0".b
        assert_equal(-29.90, zoned2num(nbr, 2))
      end
    end

    describe 'IBM390.packed2num' do
      include Convert::IBM390

      it 'converts an unsigned packed number' do
        packednbr = "\x1\x30\x50\x8C"
        assert_equal(130_508, packed2num(packednbr))
      end
      it 'converts a signed packed number' do
        packed = "\x0\x0\x0\x70\x10\xD"
        assert_equal(-70_100, packed2num(packed))
      end
      it 'converts a packed number with implied decimals' do
        packed = "\x0\x0\x0\x70\x10\xC"
        assert_equal(701.00, packed2num(packed, 2))
      end
    end

    describe IBM390 do
      it 'can call its functions as class methods' do
        assert_equal('???', IBM390.eb2asc("\x6F\x6F\x6F"))
      end
    end

  end
end
