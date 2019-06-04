# frozen_string_literal: false

require 'convert/ibm390/version'
# Functions for converting EBCDIC to ASCII and unpacking COMP, COMP-3,
# and zoned fields.
# A partial port to Ruby of the Perl module {https://metacpan.org/pod/Convert::IBM390 Convert::IBM390} by Geoffrey Rommel
# @author Jeremy Cronk
module Convert
  # :reek:UtilityFunction
  # :reek:FeatureEnvy
  # :reek:UncommunicativeModuleName
  module IBM390
    ConversionError = Class.new(StandardError)

    AE_HEX_TABLE = '00010203372d2e2f1605150b0c0d0e0f101112133c3d322618193f271c1d1e1f'\
      '405a7f7b5b6c507d4d5d5c4e6b604b61f0f1f2f3f4f5f6f7f8f97a5e4c7e6e6f'\
      '7cc1c2c3c4c5c6c7c8c9d1d2d3d4d5d6d7d8d9e2e3e4e5e6e7e8e9ade0bd5f6d'\
      '79818283848586878889919293949596979899a2a3a4a5a6a7a8a9c04fd0a107'\
      '202122232425061728292a2b2c090a1b30311a333435360838393a3b04143eff'\
      '41aa4ab19fb26ab5bbb49a8ab0caafbc908feafabea0b6b39dda9b8bb7b8b9ab'\
      '6465626663679e687471727378757677ac69edeeebefecbf80fdfefbfcbaae59'\
      '4445424643479c4854515253585556578c49cdcecbcfcce170dddedbdc8d8edf'.freeze

    EA_HEX_TABLE = '000102039c09867f978d8e0b0c0d0e0f101112139d0a08871819928f1c1d1e1f'\
      '808182838485171b88898a8b8c050607909116939495960498999a9b14159e1a'\
      '20a0e2e4e0e1e3e5e7f1a22e3c282b7c26e9eaebe8edeeefecdf21242a293b5e'\
      '2d2fc2c4c0c1c3c5c7d1a62c255f3e3ff8c9cacbc8cdcecfcc603a2340273d22'\
      'd8616263646566676869abbbf0fdfeb1b06a6b6c6d6e6f707172aabae6b8c6a4'\
      'b57e737475767778797aa1bfd05bdeaeaca3a5b7a9a7b6bcbdbedda8af5db4d7'\
      '7b414243444546474849adf4f6f2f3f57d4a4b4c4d4e4f505152b9fbfcf9faff'\
      '5cf7535455565758595ab2d4d6d2d3d530313233343536373839b3dbdcd9da9f'.freeze

    E2AP_TABLE =
      ' ' * 64 + \
      '           .<(+|&         !$*); -/         ,%_>?         `:#@\'="'\
      ' abcdefghi       jklmnopqr       ~stuvwxyz   [               ]  '\
      '{ABCDEFGHI      }JKLMNOPQR      \\ STUVWXYZ      0123456789      '

    A2E_TABLE = [AE_HEX_TABLE].pack 'H512' # see http://jruby.org/apidocs/org/jruby/util/Pack.html
    E2A_TABLE = [EA_HEX_TABLE].pack 'H512'

    private_constant :AE_HEX_TABLE, :EA_HEX_TABLE, :E2AP_TABLE, :A2E_TABLE, :E2A_TABLE

    # @note original documentation from Perl IBM390::Convert
    # Full Collating Sequence Translate -- like tr///, but assumes that
    # the searchstring is a complete 8-bit collating sequence
    # (x'00' - x'FF').  I couldn't get tr to do this, and I have my
    # doubts about whether it would be possible on systems where char
    # is signed.  This approach works on AIX, where char is unsigned,
    # and at least has a fighting chance of working elsewhere.
    # The second argument is one of the translation tables defined
    # above ($a2e_table, etc.).
    def fcs_xlate(instring, to_table)
      outstring = ''
      instring.each_byte do |b|
        outstring << to_table[b]
      end
      outstring
    end

    # Translate ASCII to EBCDIC
    def asc2eb(string)
      return '' if string.empty?

      fcs_xlate(string, A2E_TABLE)
    end

    # Translate EBCDIC to ASCII
    def eb2asc(string)
      return '' if string.empty?

      fcs_xlate(string, E2A_TABLE)
    end

    # Translate packed (COMP-3) data to unpacked ASCII data
    # @param [String] packed The packed data
    # @param [Integer] ndec The number of implied decimals
    # @return [Integer] if no implied decimals
    # @return [Float] if implied decimals
    def packed2num(packed, ndec = 0)
      w = packed.length * 2
      xdigits = packed.unpack("H#{w}").first.split(//)
      sign = xdigits.pop # last character
      arabic = xdigits.join # rest of characters
      if arabic !~ /^\d+$/ || sign !~ /^[a-f]$/
        raise ConversionError, "Invalid packed value '#{xdigits.join('').upcase}'"
      end

      arabic = arabic.to_i
      arabic = 0 - arabic if sign =~ /[bd]/
      add_decimals(arabic, ndec)
    end

    # Apply implied decimals to an integer
    def add_decimals(value, ndec = 0)
      return value if ndec.zero?

      value /= 10.0**ndec
    end

    # Translate EBCDIC to ASCII (printable characters only)
    def eb2ascp(string)
      return '' if string.empty?

      fcs_xlate(string, E2AP_TABLE)
    end

    # Translate a zoned value to ASCII
    # @param [String] the value
    # @param [Integer] The number of implied decimals
    # @return [Integer] if no implied decimals
    # @return [Float] if implied decimals
    def zoned2num(zoned, ndec = 0)
      sign = (zoned =~ /[\xD0-\xD9]/n ? -1 : 1)
      asc_zoned = eb2asc(zoned)
      sign * asc_zoned2num(asc_zoned, ndec)
    rescue ConversionError => e
      raise e, "Error converting EBCDIC string '#{zoned}' (#{zoned.size} chars) into number.  Hex of original string: #{hexify(zoned)}\n#{e.message}"
    end

    def hexify(string)
      string.unpack('H*').first.split(//).each_slice(2).to_a.map do |chrs|
        chrs.join('').to_s
      end.join(' ')
    end

    def hexdump(string, startad = 0, charset = 'ascii')
      range = 0..string.length
      outlines = []
      range.step(32) do |offset|
        substr = string[offset...offset + 32]
        printstr = if charset =~ /ebc/i
                     eb2ascp(substr)
                   else
                     substr.encode('UTF-8', invalid: :replace, replace: ' ').tr(
                       "\000-\037\377",
                       ' '
                     )
              end
        hexes = substr.unpack('H64').first
        hexes = hexes.tr('a-f', 'A-F')
        if (string.length - offset) < 32
          printstr = [printstr].pack('A32')
          hexes = [hexes].pack('A64')
        end
        line = format('%06X: ', (startad + offset))
        (0..64).step(8) do |nbr|
          line << hexes[nbr...nbr + 8] << ' '
          line << ' ' if nbr == 24
        end
        line << " *#{printstr}*\n"
        outlines << line
      end
      outlines
    end

    # def unpackeb(template, record)
    #   pointer_pos = 0
    #   template_pos =
    # end

    def num2ascnum(num, _ndec = 0)
      ascnum2num(eb2asc(num))
    end

    def ascnum2num(num, ndec = 0)
      num = num.to_i
      add_decimals(num, ndec)
    end

    def asc_zoned2num(zoned, ndec = 0)
      sign = asc_zoned_sign(zoned)
      zoned = zoned.tr(' {ABCDEFGHI}JKLMNOPQR', '001234567890123456789').strip
      raise ConversionError, "Invalid zoned value '#{zoned}' (#{zoned.unpack('H*').map { |c| "x#{c}" }.join})" unless zoned =~ /^\d+/

      final = zoned.to_i * sign
      add_decimals(final, ndec)
    end

    # Convert a zoned decimal that has been re-encoded to
    # ASCII from EBCDIC into a number with the correct sign
    def asc_zoned_sign(zoned)
      zoned =~ /[}J-R]$/ ? -1 : 1
    end

    # convert packed fullword to number
    def fullwd2num(int)
      byt = int.unpack('cC3')
      16_777_216 * byt[0] +
        65_536 * byt[1] +
        256 * byt[2] +
        byt[3]
    end

    # Convert packed halfword to a numeric value
    def halfwd2num(int)
      byt = int.unpack('cC')
      256 * byt[0] + byt[1]
    end
  end
end
