require 'pg'

class ConnectPsql
  def initialize(options)
    @conn = PG.connect( host: options[:host], port: options[:port], dbname: options[:dbname], user: options[:user], sslmode: 'disable' )
    self
  end

  def send(command)
    @conn.exec( command )
  end

  def close
    @conn.finish()
  end
end
