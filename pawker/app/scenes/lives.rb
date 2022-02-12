module Scenes
  class Lives < Scene
    STACK_ORDER = 1

    attr_reader :direction, :bonus_card

    def initialize(args, direction:, bonus_card: nil, **kwargs)
      super(args, **kwargs)

      @direction = direction
      @bonus_card = bonus_card

      render_paw_count =
        case direction
        when :gain
          args.state.lives
        when :lose
          args.state.lives + 1
        end

      if render_paw_count > 4
        distance_between_paws = (((NOKIA_WIDTH - 8) - 17) / ((render_paw_count - 1) * 1.0)).round
        width = (render_paw_count - 1) * distance_between_paws + 17
      else
        distance_between_paws = 18
        width = render_paw_count * distance_between_paws - 1
      end

      x = ((NOKIA_WIDTH - width) / 2)
      @paws = render_paw_count.times.map do |i|
        paw = Sprite.new(x: x, y: -17, w: 17, h: 17, path: "sprites/paw-print.png")
        x += distance_between_paws
        paw
      end

      paws_to_slide_in =
        case direction
        when :gain
          @paws[0..-2]
        when :lose
          @paws
        end

      paws_to_slide_in.each_with_index do |paw, i|
        paw.ease_y = Ease.new(from: paw.y, to: 0 , mode: :out_back, ticks: 30, defer: 3 * i)
      end

      case direction
      when :gain
        @paws.last.ease_x = Ease.new(from: NOKIA_WIDTH, to: @paws.last.x, ticks: 30, mode: :out_back, defer: 90)
        @paws.last.x = NOKIA_WIDTH
        @paws.last.y = 0
      when :lose
        # What do?
      end

      case direction
      when :gain
        @text = Label.new(x: -1 * NOKIA_WIDTH, y: 35, text: "Bonus card!".upcase, font: NOKIA_FONT_PATH, size_enum: NOKIA_FONT_SM, **DARK_COLOUR_RGB)
        @text.ease_x = Ease.new(from: @text.x, to: 18, ticks: 60, mode: :out_back)

        @bonus_card.x = NOKIA_WIDTH
        @bonus_card.y = 24
        @bonus_card.ease_x = Ease.new(from: @bonus_card.x, to: (NOKIA_WIDTH - @bonus_card.w) / 2, ticks: 30, mode: :out_back, defer: 30)
      when :lose
        if args.state.lives > 0
          text = "The bugs win this\nround\n\nYou'll get them\nnext time"
          @text = Label.new(x: -1 * NOKIA_WIDTH, y: 21, text: text.upcase, font: NOKIA_FONT_PATH, size_enum: NOKIA_FONT_SM, **DARK_COLOUR_RGB)
          @text.ease_x = Ease.new(from: @text.x, to: 5, ticks: 60, mode: :out_back)
        end
      end

      @wrap_up_timer = Ease.new(ticks: 300)
      @complete_timer = nil
    end

    # TODO: If losing a life, have a bug come in and carry off the last icon
    # TODO: If gaining a life, have a bug come in and drop off the last icon
    # TODO: Have a dithered light green background slide in from both sides
    def tick(args)
      if @complete_timer
        if @complete_timer.complete?(args)
          advance_phase!
        end
      elsif @wrap_up_timer&.complete?(args) || (ticks_elapsed > 10 && args.inputs.keyboard.space)
        @wrap_up_timer = nil

        @complete_timer = Ease.new(ticks: 60)

        # Start the wrap up procedure
        @paws.reverse.each_with_index do |paw, i|
          paw.ease_y = Ease.new(from: paw.y, to: -17 , mode: :in_back, ticks: 30, defer: 3 * i)
        end

        if @text
          @text.ease_x = Ease.new(from: @text.x, to: NOKIA_WIDTH , ticks: 30)
        end

        if @bonus_card
          @bonus_card.ease_x = Ease.new(from: @bonus_card.x, to: -1 * @bonus_card.w, ticks: 30)
        end

        # Where to next?
        if direction == :gain
          Progression.next_round(args, defer: 40)
        else
          if args.state.lives == 0
            Progression.game_over(args, defer: 40)
          else
            Progression.repeat_round(args, defer: 40)
          end
        end
      end

      if @direction == :lose
        if ticks_elapsed == 60
          @cross = Sprite.new(x: @paws.last.x, y: 0, w: 17, h: 17, path: "sprites/paw-print-cross.png")
          @paws.last.ease_y = Ease.new(from: @paws.last.y, to: -17, ticks: 60)
          @paws.last.ease_angle = Ease.new(from: 0, to: -45, ticks: 60, defer: 10)
        elsif ticks_elapsed > 90
          @cross = nil
        end
      end

      @paws.each { |paw| paw.tick(args) }
      @cross&.tick(args)
      @text&.tick(args)
      @bonus_card&.tick(args)
    end

    def stack_order
      STACK_ORDER
    end
  end
end

$gtk.reset()
