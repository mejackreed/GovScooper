require 'faraday'
require 'faraday_middleware'

module DataGov
  class Client
    ##
    # @return [Hash] a parsed JSON hash
    def get(path, params = {})
      response = connection.get(path) do |req|
        req.params = params
      end
      puts "#{response.status} #{response.env.url}"
      response.body
    end

    def paginated_get(path, accessor, options = {})
      Enumerator.new do |yielder|
        params   = options.dup
        rows     = params.delete(:rows) { 5 }
        start    = params.delete(:start) { 1 }
        max      = params.delete(:max) { 10 }
        total    = 0

        loop do
          data = get(path, { rows: rows, start: start }.merge(params))

          total += data['result'][accessor].length

          data['result'][accessor].each do |element|
            yielder.yield element
          end

          start += rows
          puts "total: #{total}, max: #{max}, count: #{data['result']['count']}"
          break if total >= data['result']['count'] || total >= max
        end
      end
    end

    private

    def connection
      @connection ||= begin
        conn = Faraday.new(url: 'https://catalog.data.gov') do |faraday|
          faraday.adapter Faraday.default_adapter
          faraday.response :json
        end
        conn.options.timeout = 60
        conn.options.open_timeout = 10
        conn
      end
    end
  end
end
