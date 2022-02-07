class Actors
  class Reticle
    attr_sprite

    attr_reader :radius

    def initialize
      @w = 23
      @h = 23
      @x = (NOKIA_WIDTH - @w) * 0.5
      @y = (NOKIA_HEIGHT - @h) * 0.5
      @path = "sprites/reticle2.png"
      @radius = 10
    end

    def update(args)
      @y += args.inputs.up_down
      @x += args.inputs.left_right

      @y = [0, @y].max
      @y = [@y, NOKIA_HEIGHT - @h].min

      @x = [0, @x].max
      @x = [@x, NOKIA_WIDTH - @w].min
    end

    def centre
      {
        x: @x + @w * 0.5,
        y: @y + @h * 0.5
      }
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
