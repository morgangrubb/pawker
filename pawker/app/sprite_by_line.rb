# Pretends to be a sprite but executes each line of the independently.
class SpriteByLine < Sprite
  attr_reader :delay, :lines

  def initialize(delay: 0, **kwargs)
    super(**kwargs)

    @delay = delay

    @lines =
      (0..(@h - 1)).to_a.map do |i|
        Sprite.new(
          **serialize,
          source_x: 0, source_y: i, source_w: w, source_h: 1, x: x, y: y + i, h: 1
        )
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

    lines.each_with_index do |line, i|
      line.tick(args)
    end
  end

  def ease_x=(ease)
    @ease_x = ease

    lines.each_with_index do |line, i|
      puts "#{i}: #{delay * i}"
      line.ease_x = Ease.new(**ease.serialize, defer: delay * i)
    end
  end

  def ease_y=(ease)
    lines.each_with_index do |line, i|
      line.ease_y = Ease.new(**ease.serialize, defer: delay * i)
    end
  end
end

$gtk.reset()
