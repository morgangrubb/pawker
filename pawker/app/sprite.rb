class Sprite
  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b,
    :source_x, :source_y, :source_w, :source_h,
    :tile_x, :tile_y, :tile_w, :tile_h,
    :flip_horizontally, :flip_vertically,
    :angle_anchor_x, :angle_anchor_y, :blendmode_enum

  def initialize(**options)
    update(**options)
  end

  def update(**options)
    options.each do |(key, value)|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def primitive_marker
    :sprite
  end

  def serialize
    instance_variables.inject({}) do |memo, name|
      memo[name] = instance_variable_get(name)
      memo
    end
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
