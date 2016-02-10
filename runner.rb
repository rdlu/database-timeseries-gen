require_relative 'lib/connect_influx.rb'
require_relative 'lib/connect_psql.rb'
require_relative 'lib/connect_netcat.rb'
require_relative 'lib/psql.rb'

#aux function to count time
=begin
every_so_many_seconds(1) do
  p Time.now
end
=end
def every_so_many_seconds(seconds)
  last_tick = Time.now
  loop do
    sleep 0.1
    if Time.now - last_tick >= seconds
      last_tick += seconds
      yield
    end
  end
end

#inserting generated data on psql



case ARGV[0]
when 'nc'
  #control experiment with NETCAT
  STDERR.puts "Fase 1 - Controle com Netcat: Deixe o Netcat rodando na máquina de destino."
  STDERR.puts "Use o comando 'netcat -l 35562 > testfile.sql' na máquina de destino"
  STDERR.puts "Aperte qualquer tecla para continuar..."
  STDIN.gets
  dns_psql_file = File.new("records/dns_data_psql.sql",'r')
  nc = ConnectNetcat.new({host: 'localhost', port: 35562})
  #contador global de linha
  $line_counter = 0
  #Thread separada monitorando a vazao
  time_thread = Thread.new do
    every_so_many_seconds(1) do
      STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    end
  end
  #lendo do arquivo e enviando para o BD
  while dns_psql_file.eof == false
    line = dns_psql_file.gets
    begin
      nc.send(line)
      $line_counter += 1
    rescue Exception => e
      STDERR.puts "ERROR:: #{e.message}"
      break
    end
  end
  time_thread.kill
  STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
  nc = nil
  dns_psql_file.close
  STDERR.puts "Final da Fase 1: Limpe o arquivo de teste na máquina de destino!"
when 'psql-insert'
  dns_psql_file = File.new("records/dns_data_psql.sql",'r')
  psql = ConnectPsql.new({host: 'localhost', port: 3306, dbname: 'rdlu', user: 'rdlu', password: 'xinfunrinfula'})
  psql.send(Psql.create_db)

  #contador global de linha
  $line_counter = 0
  #Thread separada monitorando a vazao
  time_thread = Thread.new do
    every_so_many_seconds(1) do
      STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    end
  end
  #lendo do arquivo e enviando para o BD
  while dns_psql_file.eof == false
    line = dns_psql_file.gets
    begin
      psql.send(line)
      $line_counter += 1
    rescue Exception => e
      STDERR.puts "ERROR:: #{e.message}"
      break
    end
  end
  time_thread.kill
  psql.close
  dns_psql_file.close
when 'influx-insert'
  dns_influx_file = File.new("records/dns_data_influx.line",'r')
when 'psql-select'
  dns_psql_file_recent = File.new("records/dns_recent_psql.sql",'r')
  dns_psql_file_zipfian = File.new("records/dns_zipfian_psql.sql",'r')
when 'influx-select'
  dns_influx_file_recent = File.new("records/dns_recent_influx.sql",'r')
  dns_influx_file_zipfian = File.new("records/dns_zipfian_influx.sql",'r')
else
  STDERR.puts "Erro: Argumento obrigatorio faltando [nc,psql-insert,psql-select,influx-insert,influx-select]"
end
