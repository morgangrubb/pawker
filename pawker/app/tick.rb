def tick args

  # if $replay_state == :good && !$recording.is_replaying?
  #   $replay.start "replay.txt"
  # end

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

    # Start at a specific level
    # Progression.advance(args, round: 0)
    # Progression.advance(args, round: 1, win: true)
    # Progression.advance(args, round: 2, win: true)
    # Progression.advance(args, round: 3, win: true)
    # Progression.advance(args, round: 4, win: true)
    # Progression.advance(args, round: 5, win: true)
    # Progression.advance(args, round: 6, win: true)
    # Progression.advance(args, round: 7, win: true)

    # Start at the round summary screen
    # args.state.scenes << Scenes::RoundSummary.new(args,
    #   hand: Hand.new(cards: args.state.deck.pick("AS", "10D")),
    #   hand_to_beat: Hand.new(cards: args.state.deck.pick("2H", "2S")),
    #   round: 0
    # )

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
    scene.tick(args)
    args.state.scenes.delete(scene) if scene.complete?
  end

# rescue Exception => e
#   $replay.stop if $recording.is_replaying?
#   $replay_state = :bad
#   $gtk.write_file "refactoring.txt", "#{e}\n#{e.backtrace}"
#   $gtk.notify! "EXCEPTION OCCURRED!!"
#   puts "#{e}\n#{e.backtrace}"
end

# $replay_state = :good
# $gtk.write_file "refactoring.txt", "no exceptions"

$gtk.reset()
