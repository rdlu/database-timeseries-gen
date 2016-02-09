require 'shellwords'

class Influxlang
  def self.create_db
    "CREATE DATABASE rdlu"
  end

  def self.create_table()
    #no need to create tables
    ""
  end

  def self.insert(metric, tags, values, timestamp, value_types)
    "#{metric},#{ tags.sort.map do |t| "#{t[0]}=#{escape_tags(t[1])}" end.join(',') } #{ values.sort.map do |v| "#{v[0]}=#{escape_values(v[1], value_types[v[0]])}" end.join(',') } #{timestamp}000000000"
  end

  def self.select(metric, range, filters)
    "SELECT * FROM #{metric} WHERE (time >= #{format_time(range[:start])} AND time <= #{format_time(range[:end])})" << if filters.to_a.count > 0
      " AND (#{ filters.map do |f| "#{f[0]} = #{escape_tag_value_select(f[1])}" end.join(' AND ') });"
    else
      ";"
    end
  end

  def self.escape_values(value, type)
    if type == 'string'
      "\"#{value}\""
    else
      value
    end
  end

  def self.escape_tags(value)
    if value.is_a?(String)
      Shellwords.shellescape value
    elsif value.is_a?(Integer)
      "#{value}i"
    else
      value
    end
  end

  def self.format_time(value)
    "#{value}s"
  end

  def self.escape_tag_value_select(value)
    if value.is_a?(String)
      "\'#{value}\'"
    else
      value
    end
  end
end
