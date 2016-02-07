#direct copy from https://github.com/andyjeffries/digestfnv/blob/master/lib/digestfnv.rb
class FNV
  def self.offset(length)
    case length
    when 32
      2166136261
    when 64
      14695981039346656037
    when 128
      144066263297769815596495629667062367629
    when 256
      100029257958052580907070968620625704837092796014241193945225284501741471925557
    when 512
      9659303129496669498009435400716310466090418745672637896108374329434462657994582932197716438449813051892206539805784495328239340083876191928701583869517785
    when 1024
      14197795064947621068722070641403218320880622795441933960878474914617582723252296732303717722150864096521202355549365628174669108571814760471015076148029755969804077320157692458563003215304957150157403644460363550505412711285966361610267868082893823963790439336411086884584107735010676915
    else
      raise ArgumentError.new("Invalid length for FNV - should be one of 32, 64, 128, 256, 512, 1024")
    end
  end

  def self.prime(length)
    case length
    when 32
      16777619
    when 64
      1099511628211
    when 128
      309485009821345068724781371
    when 256
      374144419156711147060143317175368453031918731002211
    when 512
      35835915874844867368919076489095108449946327955754392558399825615420669938882575126094039892345713852759
    when 1024
      5016456510113118655434598811035278955030765345404790744303017523831112055108147451509157692220295382716162651878526895249385292291816524375083746691371804094271873160484737966720260389217684476157468082573
    else
      raise ArgumentError.new("Invalid length for FNV - should be one of 32, 64, 128, 256, 512, 1024")
    end
  end

  def self.calculate(input, length=32)
    hash = self.offset(length)
    prime = self.prime(length)
    input.each_byte { |b| hash = (hash * prime) ^ b }
    mask = (2 ** length) -1
    hash & mask
  end

  def self.hexdigest(input, length=32)
    self.calculate(input, length).to_s(16)
  end
end
