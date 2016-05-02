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
@index_type = ARGV[3]
@index_size = ARGV[3] == 'brin' ? ARGV[4] : nil

STDOUT.sync = true
STDERR.sync = true

case ARGV[0]
when 'nc' then
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
when 'psql-insert' then
    #inserting PSQL
    STDERR.puts "Teste 2 - Inserção com PSQL: Deixe o PostgreSQL rodando na máquina de destino."
    STDERR.puts "Aperte qualquer tecla para continuar..."
    STDIN.gets
    dns_psql_file = File.new("records/dns_data_psql.sql",'r')
    psql = ConnectPsql.new({host: @host, port: @port, user: 'postgres'})
    psql.send(Psql.create_db)
    psql.close
    STDERR.puts "BD Criado..."
    psql = ConnectPsql.new({host: @host, port: @port, dbname: 'rdlu', user: 'postgres'})
    psql.send(Psql.create_table('dns_results', DnsData.filters('sql'), DnsData.values('sql'), @index_type, @index_size))

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
when 'psql-select' then
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
    STDERR.puts "Final do Teste 3a! Inicio x2."

    #select recent double sized
    dns_psql_file_recent_2 = File.new("records/dns_recent_psql_2.sql",'r')
    #contador global de linha
    $line_counter = 0
    #Thread separada monitorando a vazao
    STDOUT.puts "#RECENTx2"
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_psql_file_recent_2.eof == false
      line = dns_psql_file_recent_2.gets
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
    dns_psql_file_recent_2.close
    STDERR.puts "Final do Teste 3a! Fim x2."


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
    STDERR.puts "Final do Teste 3b: janela simples."

    #Zipfian PSQL x2
    STDERR.puts "Teste 3b - Seleção com PSQL, distribuição zipfian. Janela de tempo dobrada"
    STDOUT.puts "#ZIPFIANx2"
    dns_psql_file_zipfian_2 = File.new("records/dns_zipfian_psql_2.sql",'r')
    $line_counter = 0
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    while dns_psql_file_zipfian_2.eof == false
      line = dns_psql_file_zipfian_2.gets
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
    dns_psql_file_zipfian_2.close
when 'influx-insert' then
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
when 'influx-select' then
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

    #recent double sized
    dns_influx_file_recent_2 = File.new("records/dns_recent_influx_2.sql",'r')
    $line_counter = 0
    STDERR.puts "#RECENTx2"
    STDOUT.puts "#RECENTx2"
    #Thread separada monitorando a vazao
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_influx_file_recent_2.eof == false
      line = dns_influx_file_recent_2.gets
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
    dns_influx_file_recent_2.close


    STDERR.puts "Final do Teste 5a."
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

    #zipfian double sized
    dns_influx_file_zipfian_2 = File.new("records/dns_zipfian_influx_2.sql",'r')

    $line_counter = 0
    STDERR.puts "#ZIPFIANx2"
    STDOUT.puts "#ZIPFIANx2"
    #Thread separada monitorando a vazao
    time_thread = Thread.new do
      every_so_many_seconds(1) do
        STDOUT.puts "#{Time.now.to_f};#{$line_counter}"
      end
    end
    #lendo do arquivo e enviando para o BD
    while dns_influx_file_zipfian_2.eof == false
      line = dns_influx_file_zipfian_2.gets
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
    dns_influx_file_zipfian_2.close
else
  STDERR.puts "Erro: Argumento obrigatorio faltando [nc,psql-insert,psql-select,influx-insert,influx-select]"
end
