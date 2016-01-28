class DnsData < DbData
  @dns_servers = %w(8.8.8.8 8.8.4.4 200.172.100.1 200.172.200.2 144.144.166.166 2001:4860:4860::8888 2001:4860:4860::8844 2001:db8:85a3::8a2e:370:7334 2001:db8:85a3:0:0:8a2e:370:7334 caf3:c4f3:c4f3::1337)
  @dns_status = %w(ok nxdomain formerr servfail timeout refused other)

  @dns_filters_psql = { alias: 'char(32)', ipv6: 'boolean', url: 'char(256)', dns_server: 'char(64)'}
  @dns_filters_influx = { alias: 'string', ipv6: 'boolean', url: 'string', dns_server: 'string'}

  @dns_values_psql = { rtt: 'int', status: 'char(8)' }
  @dns_values_influx = { rtt: 'int', status: 'string' }

  @window_size = 1800

  @urls = %w(facebook.com)
  #equals to 50

  def self.dns_servers
    @dns_servers
  end

  def self.urls
    @urls
  end

  def self.dns_status
    @dns_status
  end

  def self.random_dns_status
    if rand > 0.8
      @dns_status.sample
    else
      'ok'
    end
  end

  def self.filters(type)
    case type
    when 'sql'
      @dns_filters_psql
    when 'influx'
      @dns_filters_influx
    else
      raise "Filter type #{type} doesn't exists"
    end
  end

  def self.values(type)
    case type
    when 'sql'
      @dns_values_psql
    when 'influx'
      @dns_values_influx
    else
      raise "Value type #{type} doesn't exists"
    end
  end

  def self.window_size
    @window_size
  end
end
