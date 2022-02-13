module Scenes
  class RoundSummary < Scene
    STACK_ORDER = 2

    attr_reader :hand, :hand_to_beat, :bonus_card

    def initialize(args, hand:, hand_to_beat:, bonus_card: nil, **kwargs)
      super(args, **kwargs)

      if args.state.round == 7 && hand > hand_to_beat
        Progression.next_round(args, **kwargs)
        advance_phase!
        return
      end

      @hand = hand
      @hand.tuck!
      @hand.x = 1
      @hand.y = 1

      @hand_to_beat = hand_to_beat
      @hand_to_beat.tuck!
      @hand_to_beat.x = NOKIA_WIDTH - @hand_to_beat.w - 1
      @hand_to_beat.y = NOKIA_HEIGHT + 1
      @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: NOKIA_HEIGHT - @hand_to_beat.h - 1, ticks: 60, mode: :out_back)

      @bonus_card = bonus_card

      @background_top = Sprite.new(path: "sprites/dither-swipe-short.png", w: 84, h: 24, x: NOKIA_WIDTH * -1, y: 24, flip_horizontally: true, flip_vertically: true)
      @background_top.ease_x = Ease.new(from: @background_top.x, to: 0 -1, ticks: 60, mode: :out_back)

      @background_bottom = Sprite.new(path: "sprites/dither-swipe-short.png", w: 84, h: 24, x: NOKIA_WIDTH, y: 0)
      @background_bottom.ease_x = Ease.new(from: @background_bottom.x, to: 0, ticks: 60, mode: :out_back)

      @dark_line_left = Sprite.new(x: -42, y: 23, h: 3, w: 42, path: :pixel, **DARK_COLOUR_RGB)
      @dark_line_left.ease_x = Ease.new(from: @dark_line_left.x, to: 0, ticks: 30)
      @light_line_left = Sprite.new(x: -41, y: 24, h: 1, w: 41, path: :pixel, **LIGHT_COLOUR_RGB)
      @light_line_left.ease_x = Ease.new(from: @light_line_left.x, to: 0, ticks: 30)

      @dark_line_right = Sprite.new(x: NOKIA_WIDTH, y: 23, h: 3, w: 42, path: :pixel, **DARK_COLOUR_RGB)
      @dark_line_right.ease_x = Ease.new(from: @dark_line_right.x, to: 44, ticks: 30)
      @light_line_right = Sprite.new(x: NOKIA_WIDTH, y: 24, h: 1, w: 41, path: :pixel, **LIGHT_COLOUR_RGB)
      @light_line_right.ease_x = Ease.new(from: @light_line_left.x, to: 45, ticks: 30)

      if @hand > @hand_to_beat
        position = { x: -20, y: @hand.y + @hand.h - 5 }
        ease_x_to = @hand.x + @hand.w - 10
      else
        position = { x: NOKIA_WIDTH, y: @hand_to_beat.y - 22 }
        ease_x_to = @hand_to_beat.x - 10
      end

      @star = Sprite.new(path: "sprites/star-border.png", w: 17, h: 16, angle: 0, **position)
      @star.ease_x = Ease.new(from: @star.x, to: ease_x_to, mode: :out_back, ticks: 60, defer: 60)

      # 3 seconds to display the success page, then wipe back to title for the next round
      @ticks_remaining = 420
    end

    def stack_order
      STACK_ORDER
    end

    def start_next_scene(args, **kwargs)
      if hand > hand_to_beat
        if bonus_card && hand.include?(bonus_card)
          Progression.gain_a_life(args, bonus_card: bonus_card, **kwargs)
        else
          Progression.next_round(args, **kwargs)
        end
      else
        Progression.lose_a_life(args, **kwargs)
      end
    end

    def tick(args)
      return unless running?

      if @ticks_remaining
        @ticks_remaining = 0 if ticks_elapsed >= 30 && args.inputs.keyboard.space

        if @ticks_remaining > 0
          @ticks_remaining -= 1
        elsif @ticks_remaining == 0
          @ticks_remaining = false

          @background_top.ease_x = Ease.new(from: @background_top.x, to: NOKIA_WIDTH, ticks: 60, mode: :in_back)
          @background_bottom.ease_x = Ease.new(from: @background_bottom.x, to: NOKIA_WIDTH * -1, ticks: 60, mode: :in_back)

          @dark_line_left.ease_x = Ease.new(from: @dark_line_left.x, to: -42, ticks: 30)
          @light_line_left.ease_x = Ease.new(from: @light_line_left.x, to: -41, ticks: 30)

          @dark_line_right.ease_x = Ease.new(from: @dark_line_right.x, to: NOKIA_WIDTH, ticks: 30)
          @light_line_right.ease_x = Ease.new(from: @light_line_right.x, to: NOKIA_WIDTH, ticks: 30)

          if @hand > @hand_to_beat
            @star.ease_x = Ease.new(from: @star.x, to: -20, ticks: 30, mode: :in_back)
          else
            @star.ease_x = Ease.new(from: @star.x, to: NOKIA_WIDTH, ticks: 30, mode: :in_back)
          end

          @hand.ease_y = Ease.new(from: @hand.y, to: @hand.h * -1, ticks: 60, mode: :in_back)
          @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: NOKIA_HEIGHT, ticks: 60, mode: :in_back)

          start_next_scene(args, defer: 40)

          @complete_timer = Ease.new(ticks: 60)
        end
      end

      if @complete_timer&.complete?(args)
        advance_phase!
      else
        @background_top.tick(args)
        @background_bottom.tick(args)

        @dark_line_left.tick(args)
        @light_line_left.tick(args)

        @dark_line_right.tick(args)
        @light_line_right.tick(args)

        @hand_to_beat.tick(args)
        @hand.tick(args)

        @star.angle += args.state.tick_count % 2
        @star.tick(args)
      end

    end
  end
end

$gtk.reset()
