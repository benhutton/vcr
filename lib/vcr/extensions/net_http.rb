require 'net/http'

module Net
  class HTTP
    def request_with_vcr(request, body = nil, &block)
      @__request_with_vcr_call_count = (@__request_with_vcr_call_count || 0) + 1
      response = request_without_vcr(request, body, &block)
      __store_response_with_vcr__(response, request) if @__request_with_vcr_call_count == 1
      response
    ensure
      @__request_with_vcr_call_count -= 1
    end
    alias_method :request_without_vcr, :request
    alias_method :request, :request_with_vcr

    private

    def __store_response_with_vcr__(response, request)
      if cassette = VCR.current_cassette
        # Copied from: http://github.com/chrisk/fakeweb/blob/fakeweb-1.2.8/lib/fake_web/ext/net_http.rb#L39-52
        protocol = use_ssl? ? "https" : "http"

        path = request.path
        path = URI.parse(request.path).request_uri if request.path =~ /^http/

        if request["authorization"] =~ /^Basic /
          userinfo = FakeWeb::Utility.decode_userinfo_from_header(request["authorization"])
          userinfo = FakeWeb::Utility.encode_unsafe_chars_in_userinfo(userinfo) + "@"
        else
          userinfo = ""
        end

        uri = "#{protocol}://#{userinfo}#{self.address}:#{self.port}#{path}"
        method = request.method.downcase.to_sym

        unless FakeWeb.registered_uri?(method, uri)
          cassette.store_recorded_response!(VCR::RecordedResponse.new(method, uri, response))
        end
      end
    end
  end
end