class DnsData < DbData
  @dns_servers = %w(8.8.8.8 8.8.4.4 200.172.100.1 200.172.200.2 144.144.166.166 2001:4860:4860::8888 2001:4860:4860::8844 2001:db8:85a3::8a2e:370:7334 2001:db8:85a3:0:0:8a2e:370:7334 caf3:c4f3:c4f3::1337)
  @dns_status = %w(ok nxdomain formerr servfail timeout refused other)

  @dns_filters_psql = { alias: 'char(32)', ipv6: 'boolean', url: 'char(256)', dns_server: 'char(64)'}
  @dns_filters_influx = { alias: 'string', ipv6: 'boolean', url: 'string', dns_server: 'string'}

  @dns_values_psql = { rtt: 'int', status: 'char(8)' }
  @dns_values_influx = { rtt: 'int', status: 'string' }

  @window_size = 1800

  @urls = %w(google.com.br
          facebook.com
          youtube.com
          google.com
          uol.com.br
          globo.com
          live.com
          msn.com
          yahoo.com
          mercadolivre.com.br
          blogspot.com.br
          bing.com
          wikipedia.org
          netflix.com
          twitter.com
          instagram.com
          olx.com.br
          americanas.com.br
          xvideos.com
          fatosdesconhecidos.com.br
          abril.com.br
          linkedin.com
          whatsapp.com
          reclameaqui.com.br
          caixa.gov.br
          wordpress.com
          amazon.com
          submarino.com.br
          microsoft.com
          folha.uol.com.br
          ig.com.br
          buscape.com.br
          blogger.com
          itau.com.br
          outbrain.com
          ask.com
          filmesonlinegratis.net
          bb.com.br
          tumblr.com
          aliexpress.com
          sp.gov.br
          baixaki.com.br
          t.co
          bradesco.com.br
          pinterest.com
          mec.gov.br
          terra.com.br
          vagalume.com.br
          correios.com.br
          extra.com.br)
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

  def self.field_type?(field,db_type)
    values(db_type)[field]
  end

  def self.window_size
    @window_size
  end
end
