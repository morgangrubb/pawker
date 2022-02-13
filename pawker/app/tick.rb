def tick args
  # Game setup on tick 0
  if args.state.tick_count == 0
    # Generate a deck of cards
    args.state.deck = Deck.new
    args.state.deck.generate_cards!(args)

    # Run tests
    Scenes::RanksTest.new(args).tick(args)
    args.state.deck.reset!

    # Start the game
    args.state.scenes ||= []
    Progression.reset!(args)

    # Start at a specific level
    # args.state.lives = 1
    # args.state.round = 0; Progression.next_round(args)
    # args.state.round = 1; Progression.next_round(args)
    # args.state.round = 2; Progression.next_round(args)
    # args.state.round = 3; Progression.next_round(args)
    # args.state.round = 4; Progression.next_round(args)
    # args.state.round = 5; Progression.next_round(args)
    # args.state.round = 6; Progression.next_round(args)
    # args.state.round = 7; Progression.next_round(args)

    # Start at the round summary screen
    # args.state.round = 3
    # args.state.lives = 1
    # args.state.scenes << Scenes::RoundSummary.new(args,
    #   hand: Hand.new(cards: args.state.deck.pick("AS", "10D")), # , "AC"
    #   hand_to_beat: Hand.new(cards: args.state.deck.pick("2H", "2S")),
    #   bonus_card: args.state.deck.pick("AS")
    # )

    # Start at the lives scene
    # args.state.lives = 3
    # args.state.round = 2
    # Progression.gain_a_life(args, bonus_card: args.state.deck.pick("AS").first)
    # Progression.lose_a_life(args)

    # Test the game over screen
    # args.state.scenes << Scenes::GameOver.new(args)

    # Test the game won screen
    # args.state.scenes << Scenes::Winner.new(args)

    # Default entry point for the game
    if args.state.scenes.empty?
      Progression.start(args)
    end
  end

  args.state.scenes.sort { |scene| scene.stack_order }.reverse.each do |scene|
    scene.tick_with_defer(args)
    args.state.scenes.delete(scene) if scene.complete?
  end

  # puts args.state.scenes.inspect

  # grouped = args.state.scenes.group_by { |scene| scene.class.name }
  # if grouped.values.any? { |scenes| scenes.length >= 2 }
  #   puts "Duplicate scenes detected"
  #   # puts args.state.scenes.inspect
  #   raise "boom"
  # end
end

$gtk.reset()
