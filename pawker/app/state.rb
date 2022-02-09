class State
  attr_reader :screens

  def initialize(args)
    @mode = :game
    @screen = nil

    @screens = []
  end

  def start(args, screen, **kwargs)
    new_screen =
      case screen
      when :card_test
        Screens::CardTest.new(args, **kwargs)
      when :game
        Screens::Game.new(args, **kwargs)
      when :title
        Screens::Title.new(args, **kwargs)
      end

    @screens << new_screen
  end

  def tick(args)
    @screens.each do |screen|
      screen.tick(args, self)
      @screens.delete(screen) if screen.complete?
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
