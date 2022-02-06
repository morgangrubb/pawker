class Actors
  class Splat
    def initialize(index:, controller:, **position)
      @index = index
      @controller = controller
      @position =
        position.
          slice(:w, :h, :x, :y, :a, :angle)
          .merge(
            path: "sprites/splat1.png",
            flip_horizontally: [true, false].sample,
            flip_vertically: [true, false].sample
          )
      @remaining_ticks = 300
    end

    def exists?
      @remaining_ticks > 0
    end

    # Assuming 60fps we can choose to not render the splat every other frame
    # as a way of making the remaining bugs easier to see.
    def render(args)
      return unless exists?

      add_splat =
        if @remaining_ticks > 120
          true
        elsif @remaining_ticks > 60
          @remaining_ticks % 3 == 0
        else
          @remaining_ticks % 6 == 0
        end

      @remaining_ticks -= 1

      if add_splat
        args.nokia.sprites << @position
      end
    end
  end
end
