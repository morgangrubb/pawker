class Sprite
  attr_sprite

  attr_accessor :ease_x, :ease_y, :ease_angle

  def initialize(**options)
    update(**options)
  end

  def update(**options)
    options.each do |(key, value)|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def tick(args)
    if ease_x
      @x = ease_x.current(args)
      @ease_x = nil if ease_x.complete?(args)
    end

    if ease_y
      @y = ease_y.current(args)
      @ease_y = nil if ease_y.complete?(args)
    end

    if ease_angle
      puts ease_angle.inspect
      @angle = ease_angle.current(args)
      @ease_angle = nil if ease_angle.complete?(args)
    end

    args.nokia.sprites << self
  end

  def serialize
    instance_variables.inject({}) do |memo, name|
      memo[name.to_s[1..-1].to_sym] = instance_variable_get(name)
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

$gtk.reset()
