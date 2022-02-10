module Screens
  class Title < Screen
    def initialize(args, **kwargs)
      super(args, **kwargs)

      args.state.paw ||= Actors::Paw.new
      args.state.reticle ||= Actors::Reticle.new
      args.state.reticle.ease_to_start!(args)

      @deck = Deck.new
      cards = @deck.pick!(suit: [:heart, :diamond], rank: :two)
      cards += @deck.pick(suit: :spade, rank: [:nine, :six, :three])
      @hand_to_beat = Hand.new(cards: cards)
      @deck.shuffle!

      @hand_to_beat.x = 1
      @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.h * -1, to: 1, ticks: 20, mode: :out_back)

      @splats = Actors.new(klass: Actors::Splat)
      @bugs = Actors.new(klass: Actors::Bug)
      @bugs.add(1)
      @bugs.start(args, meander: :true)

      @background = Actors::Background.new

      @interactive = true

      # TODO: Set a start position off screen with a target on the right half
      #   of the screen and the mode set to meandering so the bug just twitches
      #   and walks occasionally.

      # args.state.bugs.actors.first.tap do |bug|
      #   bug.meandering!(args, { x: })
      # end
      # .meandering!(args)
      # args.state.bugs.actors.first
      #

      # @start_game = false
    end

    def tick(args, state)
      return unless running?

      if @interactive && args.inputs.keyboard.space && args.state.paw.available?
        # Target the paw on the cursor centre
        args.state.paw.attack(args, args.state.reticle.centre)

        # Splat bugs directly under the reticle
        splatted =
          @bugs
            .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }

        if splatted.any?
          state.start(args, :game, deck: @deck, hand_to_beat: @hand_to_beat)

          @interactive = false

          splatted.actors.each do |bug|
            @splats.add(1, **bug.position)
            bug.stop(args)
          end

          @background.withdraw!(args)

          @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: @hand_to_beat.h * -1, ticks: 20, mode: :in_back)

          @start_game = true
        end
      elsif !@interactive && @splats.any? && !@splats.actors.first.exists?
        advance_phase!
      end

      @background.update(args)
      args.nokia.sprites << @background

      @bugs.render(args)
      @splats.render(args)

      args.state.reticle.update(args)
      args.nokia.sprites << args.state.reticle

      @hand_to_beat.tick(args)

      args.state.paw.update(args)
      args.nokia.sprites << args.state.paw
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
