class Actors
  class Bug
    POSITION_KEYS = [:x, :y, :angle, :w, :h, :path, :a, :speed, :angle_anchor_x, :angle_anchor_y, :tile_x, :tile_y, :tile_w, :tile_h]

    WIDTH = 16
    HEIGHT = 16

    # TODO: Move this to nokia.rb?
    NOKIA_SCREEN = { w: NOKIA_WIDTH, h: NOKIA_HEIGHT, x: 0, y: 0 }

    attr_accessor :index, :controller, :position, :target, :mode

    def initialize(index:, controller:, deck: nil)
      @index = index
      @controller = controller
      @deck = deck
      @mode = {
        name: :purgatory
      }
    end

    def exists?
      !@position.nil? && @mode[:name] != :purgatory
    end

    def describe(args)
      case @mode[:name]
      when :purgatory
        "purgatory"
      when :readying
        "readying (x: #{@position[:x]} -> #{@target[:x]}, y: #{@position[:y]} -> #{@target[:y]})"
      when :walking
        "walking (#{@position.except(:path).inspect})"
      end
    end

    def start(args, meander: false)
      if meander
        generate_non_colliding_start_position(args, wall: :right)
        @position[:y] = (NOKIA_HEIGHT - @position[:h]) * 0.5
        @target[:y] = @position[:y]
        @target[:x] = (NOKIA_WIDTH - 2.5 * @position[:w])
        @mode = {
          name: :meandering,
          ticks_remaining: 100 + rand(200).to_i,
          ticks_per_frame: 12 + rand(12).to_i,
          since: args.state.tick_count
        }
      else
        generate_non_colliding_start_position(args)
        @mode = {
          name: :readying,
          ticks_remaining: 100 + rand(200).to_i,
          ticks_per_frame: 12 + rand(12).to_i,
          since: args.state.tick_count
        }
        @card = @deck.draw if @deck
      end
    end

    def scatter(args, from_point, stop: false)
      return unless @position

      @mode = {
        name: :walking,
        ticks_per_frame: 12 + rand(12).to_i,
        since: args.state.tick_count
      }

      # Scatter from the mouse point
      angle = args.geometry.angle_from(from_point, as_centre) + 90

      # If the difference is >180 degrees then we're going the wrong way to get to our new heading
      if @position[:angle] - angle < -180
        angle -= 360
      end

      @target.merge!({
        x: nil,
        y: nil,
        angle: Ease.new(from: @position[:angle], to: angle, ticks: 10),
        speed: Ease.new(from: @position[:speed], to: 80 + rand(70), ticks: 20)
      })

      @stop_after_offscreen = stop
    end

    def stop(args)
      @position = nil
      @mode = {
        name: :purgatory
      }
    end

    def stopped?
      @mode[:name] == :purgatory
    end

    def render(args)
      calculate(args) unless args.state.debug.paused?

      unless @mode[:name] == :purgatory
        # .frame_index(how_many_frames_in_sprite_sheet,
        #              how_many_ticks_to_hold_each_frame,
        #              should_the_index_repeat)
        tile_index = @mode[:since].frame_index(4, @mode[:ticks_per_frame], true)

        @position[:tile_x] = 0 + (tile_index * WIDTH)
        @position[:tile_y] = 0

        if @mode[:name] == :readying || @mode[:name] == :meandering
          @position[:path] = "sprites/idle1.png"
        else
          @position[:path] = "sprites/walk.png"
        end

        args.nokia.sprites << @position.slice(*POSITION_KEYS)
      end

      update_mode(args) unless args.state.debug.paused?
    end

    # TODO: Do a circle collision check from the centre of the bug
    def collision?(other)
      return false unless @position

      @position.intersect_rect?(other)
    end

    def in_range_of?(args, other)
      centre = as_centre

      return false unless centre

      args.geometry.point_inside_circle?(other.slice(:x, :y), centre, other[:radius])
    end

    # This relies on angle_anchor_[x|y] to be set as 0.5 (midpoint)
    def as_centre
      return {} unless @position

      {
        x: @position[:x] + @position[:w] * 0.5,
        y: @position[:y] + @position[:h] * 0.5
      }
    end

    def radius
      return unless @position

      @position[:w] * 0.5
    end

    private

    def calculate(args)
      case mode[:name]
      when :purgatory
        @mode[:ticks_remaining] -= 1 if @mode[:ticks_remaining]

      when :readying, :meandering
        # Keep counting down time until we start moving
        @mode[:ticks_remaining] -= 1
        update_position(args)

      when :walking
        update_position(args)

      else
        raise "Unknown mode: #{mode}"

      end
    end

    def update_position(args, **overrides)
      update_position_x(args, **overrides) unless at_target_x?
      update_position_y(args, **overrides) unless at_target_y?
      update_position_angle(args, **overrides)
      update_position_speed(args, **overrides)
    end

    def update_position_x(args, speed: nil, move: nil, **)
      @position[:x] += Math.sin((360 - @position[:angle]).to_radians) * (move || ((speed || @position[:speed]) / 100.0))
    end

    def at_target_x?
      @target[:x] && @position[:x].to_i == @target[:x].to_i
    end

    def update_position_x(args, speed: nil, move: nil, **)
      @position[:x] += Math.sin((360 - @position[:angle]).to_radians) * (move || ((speed || @position[:speed]) / 100.0))
    end

    def update_position_y(args, speed: nil, move: nil, **)
      @position[:y] += Math.cos((360 - @position[:angle]).to_radians) * (move || ((speed || @position[:speed]) / 100.0))
    end

    def at_target_y?
      @target[:y] && @position[:y].to_i == @target[:y].to_i
    end

    def update_position_angle(args, **)
      return unless @target[:angle]

      @position[:angle] = @target[:angle].current(args)

      @target.delete(:angle) if @target[:angle].complete?(args)
    end

    def update_position_speed(args, **)
      return unless @target[:speed]

      @position[:speed] = @target[:speed].current(args)

      @target.delete(:speed) if @target[:speed].complete?(args)
    end

    def update_mode(args)
      case mode[:name]
      when :purgatory
        start(args) if @mode.key?(:ticks_remaining) && @mode[:ticks_remaining] < 0

      when :readying
        if @mode[:ticks_remaining] <= 0
          @mode = {
            name: :walking,
            ticks_per_frame: 4 + rand(4).to_i,
            since: args.state.tick_count
          }
          @target = {
            speed: Ease.new(from: 0, to: 50 + rand(50).to_i, ticks: 50, mode: :quad)
          }
        end

      when :walking
        # If off-screen switch to purgatory for a while
        if !@position.intersect_rect?(NOKIA_SCREEN)
          stop(args)
          @mode[:ticks_remaining] = rand(80) unless @stop_after_offscreen
        end
      end
    end

    # This can take quite a few goes to figure out a non-colliding starting
    # position but we're just going to be okay with that.
    def generate_non_colliding_start_position(args, wall: nil)
      @target =
        while true do
          target = generate_start_target(args, wall: wall)
          break target unless controller.collision?(target.slice(*POSITION_KEYS))
        end

      # Set the starting position with a random starting speed
      @position = @target.slice(*POSITION_KEYS).merge(speed: 10)
      @position[:angle_anchor_x] = 0.5
      @position[:angle_anchor_y] = 0.5
      @position[:tile_w] = WIDTH
      @position[:tile_h] = HEIGHT
      @position[:flip_horizontally] = [true, false].sample

      # Get rid of the angle
      @target.delete(:angle)

      # Set a speed on the target to get to it
      @target[:speed] = Ease.new(from: 0, to: 25, ticks: 50)

      # Now make the bug take a few steps back so that they can work their way
      # towards the starting position.
      update_position_x(args, move: -1 * HEIGHT)
      update_position_y(args, move: -1 * HEIGHT)
    end

    # Ideally the start target is 2-4 pixels in from the edge of the screen.
    #
    # This is so that the bug slowly approaches the edge of the screen to give
    # warning about where they're coming from before they take off.
    def generate_start_target(args, wall: nil)
      random =
        case wall || [:left, :top, :right, :bottom].sample
        when :left
          {
            x: -1 * (rand(WIDTH / 2) + WIDTH / 2),
            y: rand(NOKIA_HEIGHT - HEIGHT) + HEIGHT / 2,
            angle: 270
          }

        when :top
          {
            x: rand(NOKIA_WIDTH - WIDTH) + WIDTH / 2,
            y: NOKIA_HEIGHT - rand(WIDTH / 2),
            angle: 180
          }

        when :right
          {
            x: NOKIA_WIDTH - rand(WIDTH / 2),
            y: rand(NOKIA_HEIGHT - HEIGHT) + HEIGHT / 2,
            angle: 90
          }

        when :bottom
          {
            x: rand(NOKIA_WIDTH - WIDTH) + WIDTH / 2,
            y: -1 * rand(WIDTH / 2) - WIDTH / 2,
            angle: 0
          }

        end

      random.merge({
        w: WIDTH,
        h: HEIGHT,
        path: 'sprites/bug.png',
        a: 255,
        speed: 0,
      })
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
