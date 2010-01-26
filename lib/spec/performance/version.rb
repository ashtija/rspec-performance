module Spec
  module Performance
    class Version
      MAJOR_VERSION = 1
      MINOR_VERSION = 0
      TINY_VERSION = 0

      def to_s
        [MAJOR_VERSION, MINOR_VERSION, TINY_VERSION].join(".")
      end

      def to_i
        (MAJOR_VERSION & 0x03 << 6) + (MAJOR_VERSION & 0x03 << 4) + (MAJOR_VERSION & 0x03 << 2)
      end
    end

    VERSION = Version.new
  end
end
