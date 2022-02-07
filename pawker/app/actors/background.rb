class Actors
  class Background
    attr_sprite

    def initialize
      @path = "sprites/title_background.png"
      @w = NOKIA_WIDTH
      @h = NOKIA_HEIGHT
      @y = 0
      @x = NOKIA_WIDTH * -1
      @ease = Ease.new(from: @x, to: 0, ticks: 60)
    end

    def update(args)
      @x = @ease.current(args)
    end

    def withdraw!(args)
      @withdraw = true
      @ease = Ease.new(from: @x, to: NOKIA_WIDTH * -1, ticks: 60)
    end

    def withdrawn?(args)
      @withdraw && @ease.complete?(args)
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
