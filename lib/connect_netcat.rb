require 'socket'

class ConnectNetcat
  def initialize(options)
    @conn = TCPSocket.new options[:host], options[:port]
    self
  end

  def send(line)
    @conn.puts line
  end

  def receive
    @conn.gets
  end

  def close
    @conn.close
  end
end
