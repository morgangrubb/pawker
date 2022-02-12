def tick args

  # if $replay_state == :good && !$recording.is_replaying?
  #   $replay.start "replay.txt"
  # end

  # Game setup on tick 0
  if args.state.tick_count == 0
    # Run tests
    Scenes::RanksTest.new(args).tick(args)

    # Generate all card sprites
    Deck.generate_render_targets!(args)

    # Start the game
    args.state.scenes ||= []
    args.state.scenes << Scenes::Title.new(args)

    deck = Deck.new
    deck.shuffle!
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
