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
    args.state.scenes << Scenes::Title.new(args)

    # Start at the round summary screen
    # args.state.scenes << Scenes::RoundSummary.new(args,
    #   hand: Hand.new(cards: args.state.deck.pick("4H", "4C", "AS", "10D")),
    #   hand_to_beat: Hand.new(cards: args.state.deck.pick("2H", "2S")),
    #   round: 1
    # )
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
