class Psql
  def self.create_db
    "CREATE USER `rdlu` WITH ENCRYPTED PASSWORD `rdlu`;
    CREATE DATABASE `rdlu` OWNER `rdlu` ENCODING `UTF8`;"
  end

  def self.create_table(table, filters)
    "CREATE TABLE #{table} (`timestamp` timestamp)"
  end
  def self.insert(table, data)
    "INSERT INTO #{table} (#{data.keys.join(',')}) VALUES ('#{data.values.join('\',\'')}');"
  end

  def self.select(table, timerange, filters)
    "SELECT * FROM #{table} WHERE timestamp BETWEEN AND "
  end
end
