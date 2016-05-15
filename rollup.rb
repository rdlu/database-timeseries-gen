STDERR.puts "Roll up results in windows of seconds"
file = File.new("#{ARGV[0]}",'r')
seconds = ARGV[1].to_i
STDERR.puts "SECONDS: #{seconds}"

out_results = Array.new
@previous = 0
while !file.eof
  @aux = Array.new
  timestamp = false
  (0..(seconds)).each do |i|
    line_a = file.gets
    if !file.eof
      line = line_a.split(';')
      timestamp ||= line[0].to_i
      current = line[1].to_f
      @aux << current - @previous
      @previous = current
    end
  end
  sorted = @aux.sort
  median = @aux.length % 2 == 1 ? sorted[@aux.length/2] : (sorted[@aux.length/2 - 1] + sorted[@aux.length/2]).to_f / 2
  out_results << { timestamp: timestamp, sum: @aux.reduce(:+), points: @aux.length, avg: @aux.reduce(:+)/@aux.count, min: @aux.min, max: @aux.max, median: median }
end

STDOUT.puts "Timestamp;Sum;Avg;Min;Max;Median"
out_results.each do |res|
  STDOUT.puts "#{res[:timestamp]};#{res[:sum]};#{res[:avg]};#{res[:min]};#{res[:max]};#{res[:median]}"
end
