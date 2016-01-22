class DBData
  @states = %w(al ap am ba ce df es go ma mt ms mg pa pb pr pe pi rj rn rs rr sc sp se to)
  @cities = %w(mao mca mns sal for bsb vix goi sls cui cge bhz ctb jpa bel rec trs rjo nat pae bvs fln aju spo plm)

  @dns_servers_4 = %w(8.8.8.8 8.8.4.4 200.172.100.1 200.172.200.2 144.144.166.166)
  @dns_servers_6 = %w(2001:4860:4860::8888 2001:4860:4860::8844 5442:10:56:230:1 1337:1337:1337:1337:1337 caf3:c4f3:c4f3::1337)
  @dns_status = %w(ok nxdomain formerr servfail timeout refused other)

  def random_id(size)
    [*('a'..'z'),*('0'..'9')].shuffle[0,size].join
  end

  def self.aliases
    @states.map.with_index{|x, i| ["#{x}-#{@cities[i]}-#{random_id(25)}-%05d" % 1, "#{x}-#{@cities[i]}-#{random_id(25)}-%05d" % 2]}.flatten!
  end

  def self.states
    @states
  end

  def self.cities
    @cities
  end

  def self.dns_status
    @dns_status
  end

  def self.random_dns_status
    @dns_status.sample
  end

  def vl_int(mini,maxi)
    (mini..maxi).sample
  end
end
