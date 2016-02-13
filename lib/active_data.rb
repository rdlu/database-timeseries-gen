require_relative 'db_data.rb'

class ActiveData < DbData
  @filters_psql = { alias: 'char(64)', ipv6: 'boolean', city: 'char(256)', state: 'char(3)', connection_tech: 'char(10)', device_model: 'char(32)', device_maker: 'char(32)', longitude: 'float', latitude: 'float', aggregator_1: 'char(32)', aggregator_2: 'char(32)'}
  @filters_influx = { alias: 'string', ipv6: 'boolean', city: 'string', state: 'string', connection_tech: 'string', device_model: 'string', device_maker: 'string', longitude: 'float', latitude: 'float', aggregator_1: 'string', aggregator_2: 'string' }

  @dns_values_psql = { up: 'int', down: 'int' }
  @dns_values_influx = { up: 'int', down: 'int' }

  @insert_window_size = 1800
  @select_window_size = 86400

  @metrics = %w(throughput_tcp throughput throughput_http throughput_http_na loss jitter owd pom availability sites_loadtime sites_size sites_bytesdown sites_throughput sites_efficiency)

  def self.state(aliaz)
    aliaz.byteslice(0,2)
  end

  def self.city(aliaz)
    aliaz.byteslice(3,3)
  end

  def self.random_connection_tech
    %w(wifi 3g lte fiber dsl cable).sample
  end

  def self.random_device_model
    %w(sgh-1010 mbg-0987 xt1097 xt1060 firefly ghost a2_rbc).sample
  end

  def self.random_device_maker
    %w(motorola samsung asus huawei nokia)
  end

  def self.random_longitude
    rand * 360
  end

  def self.random_latitude
    (rand * 360) - 180
  end

  def self.random_aggregator(aliaz)
    aliaz.byteslice(0,6)
  end

  def self.metrics
    @metrics
  end

  def self.filters(type)
    case type
    when 'sql'
      @filters_psql
    when 'influx'
      @filters_influx
    else
      raise "Filter type #{type} doesn't exists"
    end
  end

  def self.values(type)
    case type
    when 'sql'
      @values_psql
    when 'influx'
      @values_influx
    else
      raise "Value type #{type} doesn't exists"
    end
  end

  def self.field_type?(field,db_type)
    values(db_type)[field]
  end

  def self.window_size
    @window_size
  end

  def self.random_ipv6_boolean
    rand > 0.5
  end
end
