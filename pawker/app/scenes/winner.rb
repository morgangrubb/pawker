module Scenes
  class Winner < Scene
    STACK_ORDER = 1

    attr_reader :deck

    def initialize(args, **kwargs)
      super(args, **kwargs)

      @teardown = nil

      @deck = args.state.deck
      @deck.reset!
      @deck.shuffle!

      @cannonballs = []
      @waterfall = []

      title_final_x = ((NOKIA_WIDTH - 67) / 2) + 2
      @title = SpriteByLine.new(path: "sprites/title.png", h: 14, w: 67, x: -67, y: (NOKIA_HEIGHT - 14) / 2, delay: 1)
      @title.ease_x = Ease.new(from: @title.x, to: title_final_x, mode: :out_back, ticks: 60)

      @left_star = Sprite.new(path: "sprites/star-border.png", w: 17, h: 16, angle: 0, x: -20, y: @title.y)
      @left_star.ease_x = Ease.new(from: @left_star.x, to: title_final_x - 8, mode: :out_back, ticks: 60, defer: 30)

      @right_star = Sprite.new(path: "sprites/star-border.png", w: 17, h: 16, angle: 0, x: NOKIA_WIDTH, y: @title.y)
      @right_star.ease_x = Ease.new(from: @right_star.x, to: NOKIA_WIDTH - title_final_x - 8, mode: :out_back, ticks: 60, defer: 30)

      args.outputs.sounds << "sounds/bad_melody.wav"
    end

    def tick(args)
      if ticks_elapsed >= 30 && args.inputs.keyboard.space && !@teardown
        Progression.start(args, defer: 120)
        @teardown = Ease.new(ticks: 150)

        @left_star.ease_x = Ease.new(from: @left_star.x, to: -16, mode: :out_back, ticks: 60)
        @right_star.ease_x = Ease.new(from: @right_star.x, to: NOKIA_WIDTH + 10, mode: :out_back, ticks: 60)
        @title.ease_x = Ease.new(from: @title.x, to: -67, mode: :out_back, ticks: 60)
      end

      advance_phase! if @teardown&.complete?(args)

      # if !@teardown && args.state.tick_count % 2 == 0
      #   card_cannon_fire(args)
      # end

      # @cannonballs.each do |cannonball|
      #   cannonball[:velocity_y] -= 0.5

      #   cannonball[:card].x += cannonball[:velocity_x]
      #   cannonball[:card].y += cannonball[:velocity_y]

      #   args.nokia.sprites << cannonball[:card]

      #   if cannonball[:card].y < -1 * cannonball[:card].h || cannonball[:card].x > NOKIA_WIDTH || cannonball[:card].x < -1 * cannonball[:card].w
      #     @deck.place(cannonball[:card])
      #     @cannonballs.delete(cannonball)
      #   end
      # end

      if !@teardown
        card_waterfall(args)
      end

      @waterfall.each do |waterfall|
        waterfall[:velocity_y] -= 0.08

        waterfall[:card].y += waterfall[:velocity_y]

        args.nokia.sprites << waterfall[:card]

        if waterfall[:card].y < -1 * waterfall[:card].h
          @deck.place(waterfall[:card])
          @waterfall.delete(waterfall)
        end
      end

      @left_star.angle += args.state.tick_count % 2
      @left_star.tick(args)

      @right_star.angle -= args.state.tick_count % 2
      @right_star.tick(args)

      @title.tick(args)
    end

    def card_cannon_fire(args)
      card = deck.draw
      return unless card

      card.x = (NOKIA_WIDTH - card.w) / 2
      card.y = (NOKIA_HEIGHT - card.h) / 2

      @cannonballs << {
        card: card,
        velocity_x: 2 + rand * 3 * [-1, 1].sample,
        velocity_y: 2 + rand * 3
      }
    end

    def card_waterfall(args)
      (args.state.tick_count % 4).times do
        card = deck.draw
        break unless card

        card.x = rand * (NOKIA_WIDTH - card.w)
        card.y = NOKIA_HEIGHT

        @waterfall << {
          card: card,
          velocity_x: 0,
          velocity_y: 0
        }

        # @waterfall << @waterfall.last.inspect
      end
    end

    def stack_order
      STACK_ORDER
    end
  end
end

$gtk.reset()
