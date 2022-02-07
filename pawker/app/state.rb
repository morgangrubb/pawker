class State
  def initialize(args)
    @mode = :game
    @screen = nil

    start(args, :title)
  end

  # def switch(args, mode)
  #   case mode
  #   when :title
  #     @title_screen = Screens::Title.new(args)
  #   when :game
  #     @game_screen = Screens::Game.new(args)
  #   end
  # end

  def start(args, screen)
    # puts "start: #{screen}"
    case screen
    when :game
      @game_screen ||= Screens::Game.new(args)
    when :title
      @title_screen ||= Screens::Title.new(args)
    end
  end

  def render(args)
    render_title_screen(args)
    render_game_screen(args)
  end

  def render_title_screen(args)
    return unless @title_screen

    @title_screen.render(args)

    start(args, @title_screen.start_other_screen(args))

    if @title_screen.complete?(args)

      @title_screen.teardown(args)
      @title_screen = nil
    end
  end

  def render_game_screen(args)
    return unless @game_screen

    @game_screen.render(args)

    start(args, @game_screen.start_other_screen(args))

    if @game_screen.complete?(args)
      @game_screen.teardown(args)
      @game_screen = nil
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
