
require './lib/db_data.rb'
require './lib/dns_data.rb'
require './lib/psql.rb'
require './lib/influxlang.rb'
require './lib/scrambled_zipfian.rb'
require 'date'

def format_psql_time(unix_timestamp)
  Time.at(unix_timestamp).utc.strftime("%F %T")
end

record_target = ARGV[0].to_i
dns_psql_file = File.new("records/dns_data_psql.sql",'w')
dns_influx_file = File.new("records/dns_data_influx.line",'w')

STDERR.puts "Generating INSERT records... please wait"

record_counter = 0
or_window_start = 1388534400
window_start = or_window_start
window_end = window_start + DnsData.window_size - 1
while record_counter < record_target
  DnsData.aliases.each do |aliaz|
    current_timestamp = rand(window_start..window_end)
    DnsData.dns_servers.each do |dns_server|
      DnsData.urls.each do |url|
        rtt = rand(1..500)
        dns_psql_file.puts Psql.insert('dns_results', {stamp: format_psql_time(current_timestamp), metric: 'dns', alias: aliaz, dns_server: dns_server, url: url, ipv6: DnsData.random_ipv6_boolean, rtt: rtt, status: DnsData.random_dns_status})
        dns_influx_file.puts Influxlang.insert('dns', {alias: aliaz, dns_server: dns_server, url: url, ipv6: DnsData.random_ipv6_boolean}, {rtt: rtt, status: DnsData.random_dns_status}, current_timestamp, DnsData.values('influx'))
        record_counter += 1
      end
    end
  end
  window_start += DnsData.window_size
  window_end += DnsData.window_size
end
window_start -= DnsData.window_size
window_end -= DnsData.window_size

dns_psql_file.close
dns_influx_file.close

STDERR.puts "Generated INSERT records: #{record_counter}, Last timestamp: #{window_end+1}"
STDERR.puts "Generating SELECT/recent records... please wait"

dns_psql_file_recent = File.new("records/dns_recent_psql.sql",'w')
dns_influx_file_recent = File.new("records/dns_recent_influx.sql",'w')
s_record_counter = 0
distribuition = [0,0,0]
#Take all dns_servers from the most recent time window
(0..100).each do |i|
  DnsData.dns_servers.shuffle.each do |dns_server|
    dns_psql_file_recent.puts Psql.select('dns_results', {start: format_psql_time(window_start), end: format_psql_time(window_end)}, {dns_server: dns_server})
    dns_influx_file_recent.puts Influxlang.select('dns', {start: window_start, end: window_end}, {dns_server: dns_server})
    s_record_counter += 1
    distribuition[0] += 1

    #Have 1/2 of chance to also select the previous time window
    if rand() >= 0.5
      dns_psql_file_recent.puts Psql.select('dns_results', {start: format_psql_time(window_start-DnsData.window_size), end: format_psql_time(window_end-DnsData.window_size)}, {dns_server: dns_server})
      dns_influx_file_recent.puts Influxlang.select('dns', {start: window_start-DnsData.window_size, end: window_end-DnsData.window_size}, {dns_server: dns_server})
      s_record_counter += 1
      distribuition[1] += 1
    end

    #Have 1/3 of chance to also select the second previous time window
    if rand() >= 0.666
      dns_psql_file_recent.puts Psql.select('dns_results', {start: format_psql_time(window_start-(DnsData.window_size*2)), end: format_psql_time(window_end-(DnsData.window_size*2))}, {dns_server: dns_server})
      dns_influx_file_recent.puts Influxlang.select('dns', {start: window_start-(DnsData.window_size*2), end: window_end-(DnsData.window_size*2)}, {dns_server: dns_server})
      s_record_counter += 1
      distribuition[2] += 1
    end
  end
end
dns_psql_file_recent.close
dns_influx_file_recent.close
STDERR.puts "Generated SELECT/recent records: #{s_record_counter}, distribuition: (#{distribuition.join(", ")})"

dns_psql_file_recent_2 = File.new("records/dns_recent_psql_2.sql",'w')
dns_influx_file_recent_2 = File.new("records/dns_recent_influx_2.sql",'w')
s_record_counter = 0
distribuition = [0,0,0]
#Take all dns_servers from the most recent time window
(0..100).each do |i|
  DnsData.dns_servers.shuffle.each do |dns_server|
    dns_psql_file_recent_2.puts Psql.select('dns_results', {start: format_psql_time(window_start), end: format_psql_time(window_end)}, {dns_server: dns_server})
    dns_influx_file_recent_2.puts Influxlang.select('dns', {start: window_start-DnsData.window_size, end: window_end}, {dns_server: dns_server})
    s_record_counter += 1
    distribuition[0] += 1

    #Have 1/2 of chance to also select the previous time window
    if rand() >= 0.5
      dns_psql_file_recent_2.puts Psql.select('dns_results', {start: format_psql_time(window_start-DnsData.window_size), end: format_psql_time(window_end-DnsData.window_size)}, {dns_server: dns_server})
      dns_influx_file_recent_2.puts Influxlang.select('dns', {start: window_start-(DnsData.window_size*2), end: window_end-DnsData.window_size}, {dns_server: dns_server})
      s_record_counter += 1
      distribuition[1] += 1
    end

    #Have 1/3 of chance to also select the second previous time window
    if rand() >= 0.666
      dns_psql_file_recent_2.puts Psql.select('dns_results', {start: format_psql_time(window_start-(DnsData.window_size*2)), end: format_psql_time(window_end-(DnsData.window_size*2))}, {dns_server: dns_server})
      dns_influx_file_recent_2.puts Influxlang.select('dns', {start: window_start-(DnsData.window_size*3), end: window_end-(DnsData.window_size*2)}, {dns_server: dns_server})
      s_record_counter += 1
      distribuition[2] += 1
    end
  end
end
dns_psql_file_recent_2.close
dns_influx_file_recent_2.close
STDERR.puts "Generated SELECT/recent (double sized time window) records: #{s_record_counter}, distribuition: (#{distribuition.join(", ")})"

STDERR.puts "Generating SELECT/zipfian records... please wait"

dns_psql_file_zipfian = File.new("records/dns_zipfian_psql.sql",'w')
dns_influx_file_zipfian = File.new("records/dns_zipfian_influx.sql",'w')
z_record_counter = 0
num_of_time_windows = (window_end+1 - or_window_start).div(DnsData.window_size)
puts "Zipfian:: Time windows: #{num_of_time_windows} | #{or_window_start} ~ #{window_end} / #{DnsData.window_size}"
z = ScrambledZipfian.new num_of_time_windows
(0..100).each do |i|
  j = z.next_value
  DnsData.dns_servers.shuffle.each do |dns_server|
    dns_psql_file_zipfian.puts Psql.select('dns_results', {start: format_psql_time(or_window_start+(DnsData.window_size*j)), end: format_psql_time(or_window_start+(DnsData.window_size*(j+1))-1) }, {dns_server: dns_server})
    dns_influx_file_zipfian.puts Influxlang.select('dns', {start: or_window_start+(DnsData.window_size*j), end: or_window_start+(DnsData.window_size*(j+1))-1}, {dns_server: dns_server})
    z_record_counter += 1
  end
end
dns_psql_file_zipfian.close
dns_influx_file_zipfian.close
STDERR.puts "Generated SELECT/zipfian records: #{z_record_counter}"

dns_psql_file_zipfian_2 = File.new("records/dns_zipfian_psql_2.sql",'w')
dns_influx_file_zipfian_2 = File.new("records/dns_zipfian_influx_2.sql",'w')
z_record_counter = 0
num_of_time_windows = (window_end+1 - or_window_start).div(DnsData.window_size)
puts "Zipfian:: Time windows: #{num_of_time_windows/2} | #{or_window_start} ~ #{window_end} / #{DnsData.window_size*2}"
z = ScrambledZipfian.new num_of_time_windows
(0..100).each do |i|
  j = z.next_value
  DnsData.dns_servers.shuffle.each do |dns_server|
    dns_psql_file_zipfian_2.puts Psql.select('dns_results', {start: format_psql_time(or_window_start+(DnsData.window_size*j)), end: format_psql_time(or_window_start+(DnsData.window_size*(j+2))-1) }, {dns_server: dns_server})
    dns_influx_file_zipfian_2.puts Influxlang.select('dns', {start: or_window_start+(DnsData.window_size*j), end: or_window_start+(DnsData.window_size*(j+2))-1}, {dns_server: dns_server})
    z_record_counter += 1
  end
end
dns_psql_file_zipfian_2.close
dns_influx_file_zipfian_2.close
STDERR.puts "Generated SELECT/zipfian (double sized time window) records: #{z_record_counter}"
