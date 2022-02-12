module Scenes
  class HandsTest < Scene
    def initialize(args, **kwargs)
      super(args, **kwargs)

      @deck = Deck.new
      @deck.shuffle!

      @hands = [
        Hand.new(cards: 5.times.map { @deck.draw }).tap do |hand|
          hand.x = 1
          hand.y = 37
        end,
        Hand.new(cards: 5.times.map { @deck.draw }).tap do |hand|
          hand.x = 1
          hand.y = 26
        end,
        Hand.new(cards: 5.times.map { @deck.draw }).tap do |hand|
          hand.splay!
          hand.x = 1
          hand.y = 12
        end,
        Hand.new(cards: 5.times.map { @deck.draw }).tap do |hand|
          hand.splay!
          hand.x = 1
          hand.y = 1
        end,
      ]
    end

    def stack_order
      0
    end

    def tick(args)
      if running?
        # On space, start the next screen
        if args.inputs.keyboard.space
          advance_phase!

          # Start the next screen
          args.state.scenes << Scenes::Title.new(args)
        else
          args.nokia.sprites << { x: 0, y: 0, w: NOKIA_WIDTH, h: NOKIA_HEIGHT, path: :pixel }.merge(DARK_COLOUR_RGB)

          @hands.each do |hand|
            hand.tick(args)
          end
        end
      end
    end
  end
end

$gtk.reset()
