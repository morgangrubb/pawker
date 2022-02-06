def tick args
  $debug ||= Debug.new

  args.state.reticle ||= Actors::Reticle.new
  args.state.splats ||= Actors.new(klass: Actors::Splat)

  if !args.state.bugs
    args.state.bugs = Actors.new(klass: Actors::Bug)
    args.state.bugs.add(10)
    args.state.bugs.start(args)
  end

  if args.inputs.mouse.click && !$debug.click?(args)

    # Find any bugs that are under the cursor and splat them
    args.state.bugs
      .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.nokia.mouse, 8) }
      .actors.each do |bug|
        args.state.splats.add(1, **bug.position)
        bug.start(args) # Reset offscreen
      end

    # Find all bugs in range of the cursor and scatter them
    args.state.bugs
      .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.nokia.mouse, 25) }
      .scatter(args)
  end

  if args.inputs.keyboard.space
    # Splat bugs directly under the reticle
    args.state.bugs
      .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }
      .actors.each do |bug|
        args.state.splats.add(1, **bug.position)
        bug.start(args) # Reset offscreen
      end

    # Scatter any bugs who saw this happen
    args.state.bugs
      .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius * 4) }
      .scatter(args)
  end

  args.state.reticle.update(args)

  args.state.bugs.render(args)
  args.state.splats.render(args)
  args.nokia.sprites << args.state.reticle

  $debug.render(args)
end

def hello_world args
  # args.outputs.labels  << [640, 500, 'Hello World!', 5, 1]
  # args.outputs.labels  << [640, 460, 'Go to docs/docs.html and read it!', 5, 1]
  # args.outputs.labels  << [640, 420, 'Join the Discord! http://discord.dragonruby.org', 5, 1]
  # args.outputs.sprites << [576, 280, 128, 101, 'dragonruby.png']

  # args.nokia.solids  << { x: 0, y: 64, w: 10, h: 10, r: 255 }

  # args.nokia.labels  << {
  #   x: 42,
  #   y: 46,
  #   text: "nokia 3310 jam 3",
  #   size_enum: NOKIA_FONT_SM,
  #   alignment_enum: 1,
  #   r: 0,
  #   g: 0,
  #   b: 0,
  #   a: 255,
  #   font: NOKIA_FONT_PATH
  # }

  args.nokia.sprites << {
    x: 42 - 10,
    y: 26 - 10,
    w: 20,
    h: 20,
    path: 'sprites/monochrome-ship.png',
    a: 255,
    # angle: args.state.tick_count % 360
  }
end

$gtk.reset(seed: Time.now.to_i)
