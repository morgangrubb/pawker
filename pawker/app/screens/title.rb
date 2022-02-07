module Screens
  class Title
    def initialize(args)
      args.state.title.splats = Actors.new(klass: Actors::Splat)
      args.state.title.paw = Actors::Paw.new
      args.state.title.bugs = Actors.new(klass: Actors::Bug)
      args.state.title.bugs.add(1)
      args.state.title.bugs.start(args, meander: :true)

      # TODO: Start the reticle off the right side of the screen and use easing
      #   to bring it to the centre.
      # TODO: If the reticle already exists, ease it to the new position quickly
      args.state.reticle ||= Actors::Reticle.new
      args.state.reticle.x = NOKIA_WIDTH - args.state.reticle.w - 1
      args.state.reticle.y = 1

      args.state.title.background = Actors::Background.new

      # TODO: Set a start position off screen with a target on the right half
      #   of the screen and the mode set to meandering so the bug just twitches
      #   and walks occasionally.

      # args.state.bugs.actors.first.tap do |bug|
      #   bug.meandering!(args, { x: })
      # end
      # .meandering!(args)
      # args.state.bugs.actors.first
      #


      @start_game = false
    end

    def start_other_screen(args)
      :game if @start_game
    end

    def complete?(args)
      args.state.title.background.withdrawn?(args) && args.state.title.splats.any? && !args.state.title.splats.actors.first.exists?
    end

    def render(args)
      if args.inputs.keyboard.space && args.state.title.paw.available?
        # Target the paw on the cursor centre
        args.state.title.paw.attack(args, args.state.reticle.centre)

        # Splat bugs directly under the reticle
        splatted =
          args.state.title.bugs
            .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }

        if splatted.any?
          splatted.actors.each do |bug|
            args.state.title.splats.add(1, **bug.position)
            bug.stop(args)
          end

          args.state.title.background.withdraw!(args)

          @start_game = true
        end
      end

      args.state.title.background.update(args)
      args.nokia.sprites << args.state.title.background

      args.state.title.bugs.render(args)
      args.state.title.splats.render(args)

      args.state.title.paw.update(args)
      args.nokia.sprites << args.state.title.paw

      args.state.reticle.update(args)
      args.nokia.sprites << args.state.reticle
    end

    def teardown(args)
      args.state.title = nil
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
