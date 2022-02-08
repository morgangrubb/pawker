class Actors
  class Reticle
    attr_sprite

    MAX_VELOCITY = 1

    attr_reader :radius, :velocity_x, :velocity_y, :ease_x, :ease_y

    def initialize
      @w = 23
      @h = 23
      @path = "sprites/reticle2.png"
      @radius = 10

      # Default to just offscreen
      @x = NOKIA_WIDTH + 1
      @y = 1

      @velocity_x = 0
      @velocity_y = 0
    end

    def ease_to_start!(args, ticks: 60)
      puts({ from: @x, to: NOKIA_WIDTH - @w - 1, ticks: ticks, start_tick: args.state.tick_count, mode: :out_back })
      @ease_x = Ease.new(from: @x, to: NOKIA_WIDTH - @w - 1, ticks: ticks, start_tick: args.state.tick_count, mode: :out_back)
      @ease_y = Ease.new(from: @y, to: 1, ticks: ticks, start_tick: args.state.tick_count, mode: :out_back)
    end

    def ease_offscreen!(args, ticks: 60)
      @ease_x = Ease.new(from: @x, to: NOKIA_WIDTH + 1, ticks: ticks, start_tick: args.state.tick_count)
      @ease_y = Ease.new(from: @y, to: 1, ticks: ticks, start_tick: args.state.tick_count)
    end

    def update(args)
      if @ease_x
        @x = @ease_x.current(args)
        @ease_x = nil if @ease_x.complete?(args)
      else
        x_delta =
          if args.inputs.left_right != 0
            args.inputs.left_right
          elsif @velocity_x > 0
            -1
          elsif @velocity_x < 0
            1
          else
            0
          end

        @velocity_x += x_delta
        @velocity_x = [MAX_VELOCITY * -1, @velocity_x].max
        @velocity_x = [MAX_VELOCITY, @velocity_x].min

        @x += @velocity_x
        @x = [0, @x].max
        @x = [@x, NOKIA_WIDTH - @w].min
      end

      if @ease_y
        @y = @ease_y.current(args)
        @ease_y = nil if @ease_y.complete?(args)
      else
        y_delta =
          if args.inputs.up_down != 0
            args.inputs.up_down
          elsif @velocity_y > 0
            -1
          elsif @velocity_y < 0
            1
          else
            0
          end

        @velocity_y += y_delta
        @velocity_y = [MAX_VELOCITY * -1, @velocity_y].max
        @velocity_y = [MAX_VELOCITY, @velocity_y].min

        @y += @velocity_y
        @y = [0, @y].max
        @y = [@y, NOKIA_HEIGHT - @h].min
      end
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
