module Scenes
  class RoundSummary < Scene
    STACK_ORDER = 1

    attr_reader :hand, :hand_to_beat, :round

    def initialize(args, hand:, hand_to_beat:, round:, **kwargs)
      super(args, **kwargs)

      @round = round

      @hand = hand
      @hand.tuck!

      @hand_to_beat = hand_to_beat
      @hand_to_beat.x = NOKIA_WIDTH - @hand_to_beat.w - 1
      @hand_to_beat.y = NOKIA_HEIGHT + 1
      @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: NOKIA_HEIGHT - @hand_to_beat.h - 1, ticks: 60, mode: :out_back)

      @background = Sprite.new(path: "sprites/dither-swipe.png", w: 168, h: 48, x: NOKIA_WIDTH, y: 0)
      @background.ease_x = Ease.new(from: @background.x, to: NOKIA_WIDTH * -1, ticks: 60)

      path =
        if @hand > @hand_to_beat
          "sprites/star-border.png"
        else
          "sprites/sad.png"
        end

      @star = Sprite.new(path: path, w: 17, h: 16, x: -17, y: @hand.y + @hand.h - 5, angle: 0)
      @star.ease_x = Ease.new(from: @star.x, to: @hand.x + @hand.w - 10, mode: :out_back, ticks: 60)

      # 3 seconds to display the success page, then wipe back to title for the next round
      @withdraw_at = args.state.tick_count + 180
    end

    def stack_order
      STACK_ORDER
    end

    def tick(args)
      return unless running?

      if @withdraw_at && args.state.tick_count >= @withdraw_at
        @withdraw_at = nil
        @complete_at = args.state.tick_count += 60

        # @background.ease_x = Ease.new(from: @background.x, to: NOKIA_WIDTH, ticks: 60)
        @hand_to_beat.ease_y = Ease.new(from: @hand_to_beat.y, to: NOKIA_HEIGHT + 1, ticks: 60, mode: :in_back)
        @hand.ease_y = Ease.new(from: @hand.y, to: @hand.h * -1, ticks: 60, mode: :in_back)
        @star.ease_y = Ease.new(from: @star.y, to: @star.y * -1, mode: :in_back, ticks: 60)
        args.state.scenes << Scenes::Title.new(args, round: round + 1)
      elsif @complete_at && args.state.tick_count >= @complete_at
        advance_phase!
      end

      @background.tick(args)
      @hand_to_beat.tick(args)
      @hand.tick(args)

      if @star
        @star.angle += 1
        @star.tick(args)
      end
    end
  end
end

$gtk.reset()
