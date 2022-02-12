class Debug
  include Serializable

  def initialize(mode: :running)
    @mode = mode
    @remaining_ticks = nil
    @pause_on_click = false

    @play_button =
      Sprite.new(
        x: 1280 - 40,
        y: 720 - 60,
        w: 40,
        h: 40,
        angle: 270,
        path: "sprites/triangle/equilateral/green.png"
      )

    @advance_more_button =
      Sprite.new(
        x: 1280 - 85,
        y: 720 - 60,
        w: 40,
        h: 40,
        angle: 270,
        path: "sprites/triangle/equilateral/blue.png"
      )

    @advance_less_button =
      Sprite.new(
        x: 1280 - 130,
        y: 720 - 60,
        w: 40,
        h: 40,
        angle: 270,
        path: "sprites/triangle/equilateral/red.png"
      )

    @stop_button =
      Sprite.new(
        x: 1280 - 175,
        y: 720 - 60,
        w: 40,
        h: 40,
        path: "sprites/square/red.png"
      )
  end

  def pause!
    @mode = :paused
    @remaining_ticks = nil
  end

  def run!(*args)
    @mode = :running
    @remaining_ticks = args.any? ? args.first : nil
  end

  def click?(args)
    args.inputs.mouse.click.inside_rect?(@stop_button) ||
      args.inputs.mouse.click.inside_rect?(@play_button) ||
      args.inputs.mouse.click.inside_rect?(@advance_less_button) ||
      args.inputs.mouse.click.inside_rect?(@advance_more_button)
  end

  def render(args)
    if @mode == :running
      if @pause_on_click && args.inputs.mouse.click && !click?(args)
        @mode = :paused
        @remaining_ticks = nil
        # @remaining_ticks = 0

        @pause_on_click = false
      elsif !@remaining_ticks.nil?
        @remaining_ticks -= 1

        if @remaining_ticks < 0
          @mode = :paused
          @remaining_ticks = nil
        end
      end
    end

    if args.inputs.mouse.click
      if args.inputs.mouse.click.inside_rect?(@stop_button)
        @mode = :paused
        @remaining_ticks = nil
        @pause_on_click = false
      elsif args.inputs.mouse.click.inside_rect?(@play_button)
        @mode = :running
        @remaining_ticks = nil
        @pause_on_click = false
      elsif args.inputs.mouse.click.inside_rect?(@advance_more_button)
        @mode = :running
        @remaining_ticks = 60
        @pause_on_click = false
      elsif args.inputs.mouse.click.inside_rect?(@advance_less_button)
        @mode = :running
        @remaining_ticks = nil
        @pause_on_click = true
      end
    end

    render_debug(args)

    args.outputs.debug << {
      x: 1280,
      y: 720,
      text: "#{@mode} #{"(pause on click)" if @pause_on_click}",
      size_enum: -1.5,
      r: 255, g: 255, b: 255,
      alignment_enum: 2
    }

    args.outputs.sprites << @play_button
    args.outputs.sprites << @advance_more_button
    args.outputs.sprites << @advance_less_button
    args.outputs.sprites << @stop_button
  end

  def running?
    @mode == :running
  end

  def paused?
    @mode == :paused
  end

  # Taken from the sample app
  def render_debug(args)
    if !args.state.grid_rendered
      (NOKIA_HEIGHT + 1).map_with_index do |i|
        args.outputs.static_debug << {
          x:  NOKIA_X_OFFSET,
          y:  NOKIA_Y_OFFSET + (i * NOKIA_ZOOM),
          x2: NOKIA_X_OFFSET + NOKIA_ZOOMED_WIDTH,
          y2: NOKIA_Y_OFFSET + (i * NOKIA_ZOOM),
          r: 128,
          g: 128,
          b: 128,
          a: 80
        }.line
      end

      (NOKIA_WIDTH + 1).map_with_index do |i|
        args.outputs.static_debug << {
          x:  NOKIA_X_OFFSET + (i * NOKIA_ZOOM),
          y:  NOKIA_Y_OFFSET,
          x2: NOKIA_X_OFFSET + (i * NOKIA_ZOOM),
          y2: NOKIA_Y_OFFSET + NOKIA_ZOOMED_HEIGHT,
          r: 128,
          g: 128,
          b: 128,
          a: 80
        }.line
      end
    end

    args.state.grid_rendered = true

    args.state.last_click ||= 0
    args.state.last_up    ||= 0
    args.state.last_click   = args.state.tick_count if args.nokia.mouse_down # you can also use args.nokia.click
    args.state.last_up      = args.state.tick_count if args.nokia.mouse_up
    args.state.label_style  = { size_enum: -1.5 }

    args.state.watch_list = [
      "args.state.tick_count is:      #{args.state.tick_count}",
      # "args.nokia.mouse_position is:  #{args.nokia.mouse_position.x}, #{args.nokia.mouse_position.y}",
      # "args.nokia.mouse_down tick:    #{args.state.last_click || "never"}",
      # "args.nokia.mouse_up tick:      #{args.state.last_up || "false"}",
    ]

    args.state.bugs.actors.first(2).each_with_index do |bug, i|
      args.state.watch_list << "bugs[#{i}]: #{bug.describe(args)}"
    end

    args.outputs.debug << args.state
                              .watch_list
                              .map_with_index do |text, i|
      {
        x: 5,
        y: 720 - (i * 18),
        text: text,
        size_enum: -1.5,
        r: 255, g: 255, b: 255
      }.label!
    end

    # args.outputs.debug << {
    #   x: 640,
    #   y:  25,
    #   text: "INFO: dev mode is currently enabled. Comment out the invocation of ~render_debug~ within the ~tick~ method to hide the debug layer.",
    #   size_enum: -0.5,
    #   alignment_enum: 1,
    #   r: 255, g: 255, b: 255
    # }.label!
  end

end

$gtk.reset()
