class Actors
  class Background
    include Serializable

    attr_sprite

    EXCESS = 36

    def initialize
      @path = "sprites/title_background2.png"
      @w = 120
      @h = 48
      @y = 0
      @x = @w * -1
      @ease = Ease.new(from: @x, to: EXCESS * -1, ticks: 60, mode: :out_back)
    end

    def update(args)
      @x = @ease.current(args)
    end

    def withdraw!(args)
      @withdraw = true
      @ease = Ease.new(from: @x, to: @w * -1, ticks: 60, mode: :in_back)
    end

    def withdrawn?(args)
      @withdraw && @ease.complete?(args)
    end
  end
end

$gtk.reset()
