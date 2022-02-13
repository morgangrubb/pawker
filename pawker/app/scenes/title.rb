module Scenes
  class Title < Scene
    STACK_ORDER = 0

    attr_reader :bonus_card, :hand, :hand_to_beat

    def initialize(args, hand_to_beat:, bonus_card: nil, **kwargs)
      super(args, **kwargs)

      if args.state.round == 0
        @title = SpriteByLine.new(path: "sprites/title.png", h: 14, w: 67, x: -67, y: NOKIA_HEIGHT - 14 - 2, delay: 1)
        @title.ease_x = Ease.new(from: @title.x, to: 2, mode: :out_back, ticks: 60)
      end

      args.state.paw ||= Actors::Paw.new
      args.state.reticle ||= Actors::Reticle.new
      args.state.reticle.ease_to_start!(args)

      @deck = args.state.deck

      @bonus_card = bonus_card

      if bonus_card
        bonus_card.x = NOKIA_WIDTH
        bonus_card.y = NOKIA_HEIGHT - bonus_card.h - 2
        bonus_card.ease_x = Ease.new(from: bonus_card.x, to: NOKIA_WIDTH - bonus_card.w - 2, ticks: 30, defer: 30, mode: :out_back)

        @bonus_text = Label.new(text: "Bonus card:".upcase, size_enum: NOKIA_FONT_SM, font: NOKIA_FONT_PATH, x: NOKIA_WIDTH, y: 40, **DARK_COLOUR_RGB)
        @bonus_text.ease_x = Ease.new(from: @bonus_text.x, to: 19, ticks: 30, defer: 15, mode: :out_back)

        @bonus_box = Sprite.new(x: NOKIA_WIDTH, y: 38, w: 60, h: 8, path: :pixel, **LIGHT_COLOUR_RGB)
        @bonus_box.ease_x = Ease.new(from: @bonus_box.x, to: 17, ticks: 30, defer: 15, mode: :out_back)
      end

      @hand_to_beat = hand_to_beat
      @hand_to_beat.x = 1
      @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.h * -1, to: 1, ticks: 20, mode: :out_back)

      @splats = Actors.new(klass: Actors::Splat)
      @bugs = Actors.new(klass: Actors::Bug)
      @bugs.add(1)
      @bugs.start(args, meander: :true)

      @background = Actors::Background.new

      @instructions = Label.new(x: 2, y: -20, font: NOKIA_FONT_PATH, size_enum: NOKIA_FONT_SM, text: "Paw\nto\nbeat:".upcase, **LIGHT_COLOUR_RGB)
      @instructions.ease_y = Ease.new(from: @instructions.y, to: @hand_to_beat.h + 6, ticks: 60, defer: 20, mode: :out_back)

      # TODO: Display the bonus card

      @interactive = true
    end

    def stack_order
      STACK_ORDER
    end

    def tick(args)
      return unless running?

      if @interactive && ticks_elapsed >= 30 && args.inputs.keyboard.space && args.state.paw.available?
        # Target the paw on the cursor centre
        args.state.paw.attack(args, args.state.reticle.centre)

        # Splat bugs directly under the reticle
        splatted =
          @bugs
            .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }

        if splatted.any?
          args.state.scenes << Scenes::Round.new(args, hand_to_beat: @hand_to_beat, bonus_card: bonus_card)

          @interactive = false

          splatted.actors.each do |bug|
            @splats.add(1, **bug.position)
            bug.stop(args)
          end

          if @bonus_card
            @bonus_card.ease_x = Ease.new(from: bonus_card.x, to: NOKIA_WIDTH, ticks: 30)
            @bonus_text.ease_x = Ease.new(from: @bonus_text.x, to: NOKIA_WIDTH, ticks: 30, defer: 15)
            @bonus_box.ease_x = Ease.new(from: @bonus_box.x, to: NOKIA_WIDTH, ticks: 30, defer: 15)
          end

          @background.withdraw!(args)

          @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: @hand_to_beat.h * -1, ticks: 20, mode: :in_back)

          @instructions.ease_y = Ease.new(from: @instructions.y, to: -48, ticks: 60, mode: :in_back)

          if @title
            @title.ease_x = Ease.new(from: @title.x, to: -67, ticks: 60)
          end

          @start_game = true
        end
      elsif !@interactive && @splats.any? && !@splats.actors.first.exists?
        advance_phase!
      end

      @background.update(args)
      args.nokia.sprites << @background

      @bugs.render(args)
      @splats.render(args)

      @bonus_box&.tick(args)
      @bonus_text&.tick(args)
      @bonus_card&.tick(args)

      args.state.reticle.update(args)
      args.nokia.sprites << args.state.reticle

      @hand_to_beat.tick(args)

      @instructions.tick(args)

      @title.tick(args) if @title

      args.state.paw.update(args)
      args.nokia.sprites << args.state.paw
    end
  end
end

$gtk.reset()
