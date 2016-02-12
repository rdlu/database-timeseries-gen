require 'typhoeus'

class ConnectInflux
  def initialize(options)
    @host = options[:host]
    @db = options[:db]
    @port = options[:port]
    self
  end

  def send(query, type = 'post')
    if(type == 'post')
      post(query)
    else
      get(query)
    end
  end

  def get(query)
    request = Typhoeus::Request.new(
      "http://#{@host}:#{@port}/query",
      method: :get,
      params: { q: query, db: @db}
    )

    request.on_complete do |response|
      if response.success?

      else
        # Received a non-successful http response.
        raise "Error sending GET to influx - code: #{response.code}, msg: #{response.return_message}, query: #{query}"
      end
    end

    request.run
  end

  def post(line)
    request = Typhoeus::Request.new(
      "http://#{@host}:#{@port}/write",
      method: :post,
      params: { db: @db },
      body: line
    )

    request.on_complete do |response|
      if response.success?

      else
        # Received a non-successful http response.
        raise "Error sending POST to Influx - code: #{response.code}, msg: #{response.return_message}, query: #{line}"
      end
    end

    request.run
  end

  def close
  end
end
