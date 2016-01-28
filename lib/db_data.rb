class DbData
  @@states = %w(al ap am ba ce df es go ma mt ms mg pa pb pr pe pi rj rn rs rr sc sp se to)
  @@cities = %w(mao mca mns sal for bsb vix goi sls cui cge bhz ctb jpa bel rec trs rjo nat pae bvs fln aju spo plm)

  def self.random_id(size)
    [*('a'..'z'),*('0'..'9')].shuffle[0,size].join
  end

  def self.aliases
    @aliases ||= @@states.map.with_index{|x, i|
      ["#{x}-#{@@cities[i]}-#{random_id(25)}-%05d" % 1,
       "#{x}-#{@@cities[i]}-#{random_id(25)}-%05d" % 2,
       "#{x}-#{@@cities[i]}-#{random_id(25)}-%05d" % 3,
       "#{x}-#{@@cities[i]}-#{random_id(25)}-%05d" % 4]
    }.flatten!
  end

  def self.states
    @states
  end

  def self.cities
    @cities
  end

end
