module Screens
  class Game < Screen
    MAX_SWATS = 5

    def initialize(args, **kwargs)
      super(args, **kwargs)

      args.state.reticle ||= Actors::Reticle.new
      args.state.paw ||= Actors::Paw.new

      @deck = Deck.new
      @deck.shuffle!

      @splats = Actors.new(klass: Actors::Splat)

      @bugs = Actors.new(klass: Actors::Bug)
      @bugs.add(10, deck: @deck)
      @bugs.start(args)

      @swats = 0

      @complete = false
      @ticks_remaining = nil
      @interactive = true
    end

    def tick(args, state)
      return unless running?

      if !@ticks_remaining.nil? && @ticks_remaining <= 0
        advance_phase!
      elsif @interactive && args.inputs.keyboard.space && args.state.paw.available?
        @swats += 1

        if @swats >= MAX_SWATS
          @complete = true
          @interactive = false
          @ticks_remaining = 300
          state.start(args, :title)
        end

        # Target the paw on the cursor centre
        args.state.paw.attack(args, args.state.reticle.centre)

        # Splat bugs directly under the reticle
        @bugs
          .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }
          .actors.each do |bug|
            @splats.add(1, **bug.position)

            if @complete
              bug.stop(args)
            else
              bug.start(args) # Reset offscreen
            end
          end

        scatter_bugs =
          if @complete
            @bugs
          else
            @bugs.select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius * 4) }
          end

        # Scatter any bugs who saw this happen
        scatter_bugs.scatter(args, args.state.reticle.centre, stop: @complete)
      end

      @ticks_remaining -= 1 if !@ticks_remaining.nil?

      args.state.reticle.update(args)
      args.state.paw.update(args)

      @bugs.render(args)
      @splats.render(args)

      args.nokia.sprites << args.state.reticle
      args.nokia.sprites << args.state.paw
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
