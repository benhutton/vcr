require 'fileutils'

module VCR
  class Config
    class << self
      attr_reader :cache_dir
      def cache_dir=(cache_dir)
        @cache_dir = cache_dir
        FileUtils.mkdir_p(cache_dir) if cache_dir
      end

      attr_reader :default_cassette_record_mode
      def default_cassette_record_mode=(default_cassette_record_mode)
        VCR::Cassette.raise_error_unless_valid_record_mode(default_cassette_record_mode)
        @default_cassette_record_mode = default_cassette_record_mode
      end
    end
  end
end