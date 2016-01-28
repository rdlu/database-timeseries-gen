class Psql
  def self.create_db
    "CREATE USER `rdlu` WITH ENCRYPTED PASSWORD `rdlu`;
    CREATE DATABASE `rdlu` OWNER `rdlu` ENCODING `UTF8`;"
  end

  def self.create_table(table, filters, values, index, size = 128)
    "CREATE TABLE #{table} (`stamp` timestamp NOT NULL, `metric` char(64) NOT NULL, #{ filters.map do |f| "`#{f[0]}` #{f[1]}" end.join(', ') }, #{ values.map do |f| "`#{f[0]}` #{f[1]}" end.join(', ')});\n" << case index
    when 'brin'
      "CREATE INDEX idx_ts_brin_#{size} ON #{table} USING BRIN (stamp) WITH (pages_per_range = #{size});"
    when 'btree'
      "CREATE INDEX idx_ts_btree ON #{table} USING BTREE (stamp);"
    else
      ""
    end
  end

  def self.insert(table, data)
    "INSERT INTO #{table} (#{data.keys.join(',')}) VALUES (`#{data.values.join('`,`')}`);"
  end

  def self.select(table, timerange, filters)
    "SELECT * FROM #{table} WHERE (stamp BETWEEN #{timerange[:start]} AND #{timerange[:end]})" << if filters.to_a.count > 0
      " AND (#{ filters.map do |f| "#{f[0]} = `#{f[1]}`" end.join(' AND ') });"
    else
      ";"
    end
  end
end
