
require './lib/db_data.rb'
require './lib/dns_data.rb'
require './lib/psql.rb'

record_target = ARGV[0].to_i
dns_psql_file = File.new("records/dns_data_psql.sql",'w')

STDERR.puts "Generating INSERT records... please wait"

record_counter = 0
window_start = 1388534400
window_end = window_start + DnsData.window_size - 1
while record_counter < record_target
  DnsData.aliases.each do |aliaz|
    current_timestamp = rand(window_start..window_end)
    DnsData.dns_servers.each do |dns_server|
      DnsData.urls.each do |url|
        dns_psql_file.puts Psql.insert('dns_results', {stamp: current_timestamp, metric: 'dns', alias: aliaz, dns_server: dns_server, url: url, rtt: rand(1..500), status: DnsData.random_dns_status})
        record_counter += 1
      end
    end
  end
  window_start += DnsData.window_size
  window_end += DnsData.window_size
end

STDERR.puts "Generated INSERT records: #{record_counter}, Last timestamp: #{window_end+1}"
STDERR.puts "Generating SELECT/recent records... please wait"

dns_psql_file_recent = File.new("records/dns_recent_psql.sql",'w')
record_counter = 0
distribuition = [0,0,0]
#Take all dns_servers from the most recent time window
(1..4).each do |i|
  DnsData.dns_servers.shuffle.each do |dns_server|
    dns_psql_file_recent.puts Psql.select('dns_results', {start: window_start, end: window_end}, {dns_server: dns_server})
    record_counter += 1
    distribuition[0] += 1

    #Have 1/2 of chance to also select the previous time window
    if rand() >= 0.5
      dns_psql_file_recent.puts Psql.select('dns_results', {start: window_start-DnsData.window_size, end: window_end-DnsData.window_size}, {dns_server: dns_server})
      record_counter += 1
      distribuition[1] += 1
    end

    #Have 1/3 of chance to also select the second previous time window
    if rand() >= 0.666
      dns_psql_file_recent.puts Psql.select('dns_results', {start: window_start-(DnsData.window_size*2), end: window_end-(DnsData.window_size*2)}, {dns_server: dns_server})
      record_counter += 1
      distribuition[2] += 1
    end
  end
end
STDERR.puts "Generated SELECT/recent records: #{record_counter}, distribuition: (#{distribuition.join(", ")})"
