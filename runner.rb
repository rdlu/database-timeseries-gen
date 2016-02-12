require_relative 'lib/dns_data.rb'
require_relative 'lib/connect_influx.rb'
require_relative 'lib/connect_psql.rb'
require_relative 'lib/connect_netcat.rb'
require_relative 'lib/psql.rb'
require_relative 'lib/influxlang.rb'

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

@host = ARGV[1]
@port = ARGV[2]

case ARGV[0]
when 'nc' then
  begin
    #control experiment with NETCAT
    STDERR.puts "Teste 1 - Controle com Netcat: Deixe o Netcat rodando na máquina de destino."
    STDERR.puts "Use o comando 'netcat -l 35562 > testfile.sql' na máquina de destino"
    STDERR.puts "Aperte qualquer tecla para continuar..."
    STDIN.gets
    dns_psql_file = File.new("records/dns_data_psql.sql",'r')
    nc = ConnectNetcat.new({host: @host, port: @port})
    #contador global de linha
    $line_counter = 0
    #Thread separada monitorando a vazao
    time_thread = Thread.new do
      #YES, I CAN dirty read line_counter
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
    STDERR.puts "Final do Teste 1: Limpe o arquivo de teste na máquina de destino! Colete o arquivo de resultados."
  end
when 'psql-insert' then
  begin
    #inserting PSQL
    STDERR.puts "Teste 2 - Inserção com PSQL: Deixe o PostgreSQL rodando na máquina de destino."
    STDERR.puts "Aperte qualquer tecla para continuar..."
    STDIN.gets
    dns_psql_file = File.new("records/dns_data_psql.sql",'r')
    psql = ConnectPsql.new({host: @host, port: @port, user: 'postgres'})
    psql.send(Psql.create_db)
    psql.close
    psql = ConnectPsql.new({host: @host, port: @port, dbname: 'rdlu', user: 'postgres'})
    psql.send(Psql.create_table('dns_results', DnsData.filters('sql'), DnsData.values('sql'), 'brin'))

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
    STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    psql.close
    dns_psql_file.close
    STDERR.puts "Final do Teste 2: Colete o arquivo com os resultados, inicie a fase 3!"
  end
when 'psql-select' then
  begin
    #selecting PSQL
    STDERR.puts "Teste 3a - Seleção com PSQL, distribuição recentes: Deixe o PostgreSQL rodando na máquina de destino."
    STDERR.puts "Aperte qualquer tecla para continuar..."
    STDIN.gets
    dns_psql_file_recent = File.new("records/dns_recent_psql.sql",'r')
    psql = ConnectPsql.new({host: @host, port: @port, dbname: 'rdlu', user: 'postgres'})
    #contador global de linha
    $line_counter = 0
    #Thread separada monitorando a vazao
    STDOUT.puts "#RECENT"
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_psql_file_recent.eof == false
      line = dns_psql_file_recent.gets
      begin
        psql.send(line)
        $line_counter += 1
      rescue Exception => e
        STDERR.puts "ERROR:: #{e.message}"
        break
      end
    end
    time_thread.kill
    STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    dns_psql_file_recent.close
    STDERR.puts "Final do Teste 3a: Já podes coletar o arquivo com os resultados!"
    STDERR.puts "Teste 3b - Seleção com PSQL, distribuição zipfian."
    STDOUT.puts "#ZIPFIAN"
    dns_psql_file_zipfian = File.new("records/dns_zipfian_psql.sql",'r')
    $line_counter = 0
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    while dns_psql_file_zipfian.eof == false
      line = dns_psql_file_zipfian.gets
      begin
        psql.send(line)
        $line_counter += 1
      rescue Exception => e
        STDERR.puts "ERROR:: #{e.message}"
        break
      end
    end
    time_thread.kill
    STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    psql.close
    dns_psql_file_zipfian.close
    STDERR.puts "Final do Teste 3b: Já podes coletar o arquivo com os resultados!"
  end
when 'influx-insert' then
  begin
    #inserting Influx
    STDERR.puts "Teste 4 - Inserção com InfluxDB: Deixe o InfluxDB rodando na máquina de destino."
    STDERR.puts "Aperte qualquer tecla para continuar..."
    STDIN.gets
    dns_influx_file = File.new("records/dns_data_influx.line",'r')
    influx = ConnectInflux.new({host: @host, port: @port, db: 'rdlu'})
    influx.get(Influxlang.create_db)
    $line_counter = 0
    #Thread separada monitorando a vazao
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_influx_file.eof == false
      line = dns_influx_file.gets
      begin
        influx.post(line)
        $line_counter += 1
      rescue Exception => e
        STDERR.puts "ERROR:: #{e.message}"
        break
      end
    end
    time_thread.kill
    STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    dns_influx_file.close
    STDERR.puts "Final do Teste 4: Colete o arquivo com os resultados, inicie a fase 5!"
  end
when 'influx-select' then
  begin
    STDERR.puts "Teste 5a - Seleção com InfluxDB, distribuição recentes: Deixe o InfluxDB rodando na máquina de destino."
    STDERR.puts "Aperte qualquer tecla para continuar..."
    STDIN.gets

    influx = ConnectInflux.new({host: @host, port: @port, db: 'rdlu'})
    dns_influx_file_recent = File.new("records/dns_recent_influx.sql",'r')
    $line_counter = 0
    STDOUT.puts "#RECENT"
    #Thread separada monitorando a vazao
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_influx_file_recent.eof == false
      line = dns_influx_file_recent.gets
      begin
        influx.get(line)
        $line_counter += 1
      rescue Exception => e
        STDERR.puts "ERROR:: #{e.message}"
        break
      end
    end
    time_thread.kill
    STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    dns_influx_file_recent.close


    STDERR.puts "Final do Teste 5a: Já podes coletar o arquivo com os resultados!"
    STDERR.puts "Teste 5b - Seleção com InfluxDB, distribuição zipfian."
    dns_influx_file_zipfian = File.new("records/dns_zipfian_influx.sql",'r')

    $line_counter = 0
    STDOUT.puts "#ZIPFIAN"
    #Thread separada monitorando a vazao
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_influx_file_zipfian.eof == false
      line = dns_influx_file_zipfian.gets
      begin
        influx.get(line)
        $line_counter += 1
      rescue Exception => e
        STDERR.puts "ERROR:: #{e.message}"
        break
      end
    end
    time_thread.kill
    STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
    dns_influx_file_zipfian.close
  end
else
  STDERR.puts "Erro: Argumento obrigatorio faltando [nc,psql-insert,psql-select,influx-insert,influx-select]"
end
