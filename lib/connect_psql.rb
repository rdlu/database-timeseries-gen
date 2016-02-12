require 'pg'

class ConnectPsql
  def initialize(options)
    @conn = PG.connect( options )
    self
  end

  def send(command)
    @conn.exec( command )
  end

  def close
    @conn.finish()
  end
end
