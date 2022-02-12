def tick args

  # Game setup on tick 0
  if args.state.tick_count == 0

    # Run tests
    Scenes::RanksTest.new(args).tick(args, nil)

    # Generate all card sprites
    Deck.generate_render_targets!(args)

    # Start the game
    args.state.scenes ||= []
    args.state.scenes << Scenes::Title.new(args)

    deck = Deck.new
    deck.shuffle!
  end

  args.state.scenes.sort { |scene| scene.stack_order }.reverse.each do |scene|
    scene.tick(args, self)
    args.state.scenes.delete(scene) if scene.complete?
  end
end

$gtk.reset()
