class Actors
  class Paw
    include Serializable

    attr_sprite

    def initialize
      @w = 23
      @h = 60
      @x = -1 * @w
      @y = -1 * @h
      @angle = 0
      @path = "sprites/paw.png"
      @easing = nil
    end

    def serialize
      { w: @w, h: @h, x: @x, y: @y, angle: @angle, path: @path }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    # If the paw is already being rendered somewhere then it isn't available
    def available?
      @easing.nil?
    end

    def attack(args, target)
      # Closest edge
      edge =
        [
          { from: :left, distance: target.x },
          { from: :right, distance: NOKIA_WIDTH - target.x },
          { from: :bottom, distance: target.y },
          { from: :top, distance: NOKIA_HEIGHT - target.y }
        ].min_by { |edge| edge[:distance] }[:from]

      case edge
      when :left
        @angle = 270
        @x = target.x - 30
        @y = target.y - 30
        @direction = :left
        @easing = Ease.new(from: @x, to: @h * -1, ticks: 45, start_tick: args.state.tick_count)
        # @speed = 1
      when :right
        @angle = 90
        @x = target.x + 11
        @y = target.y - 30
        @direction = :right
        @easing = Ease.new(from: @x, to: NOKIA_WIDTH + @h, ticks: 45, start_tick: args.state.tick_count)
      when :bottom
        @angle = 0
        @x = target.x - 11
        @y = target.y - 50
        @direction = :down
        @easing = Ease.new(from: @y, to: @h * -1, ticks: 45, start_tick: args.state.tick_count)
      when :top
        @angle = 180
        @x = target.x - 11
        @y = target.y - 9
        @direction = :up
        @easing = Ease.new(from: @y, to: NOKIA_HEIGHT + @h, ticks: 45, start_tick: args.state.tick_count)
      end
    end

    # If currently on-screen then move off-screen at an accelerating rate.
    def update(args)
      return unless @easing

      # For now just target the mouse cursor
      # attack(args, args.nokia.mouse)
      #

      case @direction
      when :left, :right
        @x = @easing.current(args)
      when :up, :down
        @y = @easing.current(args)
      end

      if @easing.complete?(args)
        @easing = nil
      end
    end
  end
end

$gtk.reset()
