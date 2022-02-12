module Scenes
  class Title < Scene
    STACK_ORDER = 0

    attr_reader :round

    def initialize(args, round: 0, **kwargs)
      super(args, **kwargs)

      @round = round

      args.state.paw ||= Actors::Paw.new
      args.state.reticle ||= Actors::Reticle.new
      args.state.reticle.ease_to_start!(args)

      @deck = args.state.deck
      @deck.reset!
      @deck.shuffle!

      @hand_to_beat = Hand.new(cards: @deck.pick!("2H", "2D"))
      @hand_to_beat.x = 1
      @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.h * -1, to: 1, ticks: 20, mode: :out_back)
      # raise "@hand_to_beat.h is nil" if @hand_to_beat.h.nil?

      @splats = Actors.new(klass: Actors::Splat)
      @bugs = Actors.new(klass: Actors::Bug)
      @bugs.add(1)
      @bugs.start(args, meander: :true)

      @background = Actors::Background.new

      @instructions = Label.new(x: 2, y: -48, font: NOKIA_FONT_PATH, size_enum: NOKIA_FONT_SM, text: "Paw\nto\nbeat:".upcase, **LIGHT_COLOUR_RGB)
      @instructions.ease_y = Ease.new(from: @instructions.y, to: @hand_to_beat.h + 6, ticks: 60, defer: 20, mode: :out_back)

      @interactive = true
    end

    def stack_order
      STACK_ORDER
    end

    def tick(args)
      return unless running?

      if @interactive && args.inputs.keyboard.space && args.state.paw.available?
        # Target the paw on the cursor centre
        args.state.paw.attack(args, args.state.reticle.centre)

        # Splat bugs directly under the reticle
        splatted =
          @bugs
            .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }

        if splatted.any?
          args.state.scenes << Scenes::Round.new(args, hand_to_beat: @hand_to_beat, round: round)

          @interactive = false

          splatted.actors.each do |bug|
            @splats.add(1, **bug.position)
            bug.stop(args)
          end

          @background.withdraw!(args)

          @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: @hand_to_beat.h * -1, ticks: 20, mode: :in_back)

          @instructions.ease_y = Ease.new(from: @instructions.y, to: -48, ticks: 60, mode: :in_back)

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

      @instructions.tick(args)

      args.state.paw.update(args)
      args.nokia.sprites << args.state.paw
    end
  end
end

$gtk.reset()
