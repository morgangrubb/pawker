module Scenes
  class CardTest < Scene
    def initialize(args, **kwargs)
      super(args, **kwargs)

      @deck = Deck.new
      # @card = @deck.draw
    end

    def stack_order
      0
    end

    def tick(args, state)
      if running?
        # On space, start the next screen
        if args.inputs.keyboard.space
          advance_phase!

          # Start the next screen
          args.state.scenes << Scenes::Title.new(args)
        else
          x = 0
          y = 0

          @deck.cards.each do |card|
            card.x = x
            card.y = y

            args.nokia.sprites << card

            x += card.w + 1

            if x >= 84
              x = 0
              y += card.h + 1
            end

            if y >= 48
              break
            end
          end

          # Render a card
          # args.nokia.sprites << @card
        end
      end
    end
  end
end

$gtk.reset()
