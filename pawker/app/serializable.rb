module Serializable
  # 1. Create a serialize method that returns a hash with all of
  #    the values you care about.
  def serialize
    { }
  end

  # 2. Override the inspect method and return ~serialize.to_s~.
  def inspect
    serialize.to_s
  end

  # 3. Override to_s and return ~serialize.to_s~.
  def to_s
    serialize.to_s
  end
end
