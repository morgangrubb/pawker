module Screens
  class Game
    MAX_SWATS = 5

    def initialize(args)
      puts "Starting game!"

      args.state.reticle ||= Actors::Reticle.new
      args.state.paw ||= Actors::Paw.new

      args.state.game = {}
      args.state.game.splats = Actors.new(klass: Actors::Splat)
      args.state.game.bugs = Actors.new(klass: Actors::Bug)
      args.state.game.bugs.add(10)
      args.state.game.bugs.start(args)

      @swats = 0

      @complete = false
      @ticks_remaining = nil
    end

    def start_other_screen(args)
      :title if @swats >= MAX_SWATS
    end

    def complete?(args)
      @complete &&
        !args.state.game.splats.actors.any?(&:exists?) &&
        !@ticks_remaining.nil? && @ticks_remaining <= 0
    end

    def render(args)
      if !@complete && args.inputs.keyboard.space && args.state.paw.available?
        @swats += 1

        puts "@swats: #{@swats}"

        if @swats >= MAX_SWATS
          @complete = true
          @ticks_remaining = 300
        end

        # Target the paw on the cursor centre
        args.state.paw.attack(args, args.state.reticle.centre)

        # Splat bugs directly under the reticle
        args.state.game.bugs
          .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }
          .actors.each do |bug|
            args.state.game.splats.add(1, **bug.position)
            bug.start(args) # Reset offscreen
          end

        scatter_radius =
          if @complete
            NOKIA_WIDTH
          else
            args.state.reticle.radius * 4
          end

        # Scatter any bugs who saw this happen
        args.state.game.bugs
          .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, scatter_radius) }
          .scatter(args, args.state.reticle.centre, stop: @complete)

      end

      @ticks_remaining -= 1 if !@ticks_remaining.nil?

      args.state.reticle.update(args)
      args.state.paw.update(args)

      args.state.game.bugs.render(args)
      args.state.game.splats.render(args)

      args.nokia.sprites << args.state.reticle
      args.nokia.sprites << args.state.paw
    end

    def teardown(args)
      args.state.game = nil
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
