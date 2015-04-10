module SolarScoutUtil

  def build_id(str)
    str.gsub(/\W/, ' ').
      gsub(/ +/, '-').
      strip.
      downcase.
      gsub(/\-+$/, '')
  end

end
