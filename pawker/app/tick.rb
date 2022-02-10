def tick args

  # Game setup on tick 0
  if args.state.tick_count == 0

    # Run tests
    Screens::RanksTest.new(args).tick(args, nil)

    # Generate all card sprites
    Deck.generate_render_targets!(args)

    # Start the game
    args.state.game_state = State.new(args)
    args.state.game_state.start(args, :title)
    # args.state.game_state.start(args, :hands_test)
  end

  args.state.game_state.tick(args)
end

$gtk.reset(seed: Time.now.to_i)
