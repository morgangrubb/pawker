def tick args

  if args.state.tick_count == 0
    Deck.generate_render_targets!(args)

    args.state.game_state = State.new(args)
    args.state.game_state.start(args, :title)
    # args.state.game_state.start(args, :ranks_test)
  end


  args.state.game_state.tick(args)
end

$gtk.reset(seed: Time.now.to_i)
