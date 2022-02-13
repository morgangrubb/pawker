module Scenes
  class GameOver < Scene
    STACK_ORDER = 1

    def initialize(args, **kwargs)
      super(args, **kwargs)

      args.state.bug_speed = 1.2..1.4

      # Loads of bugs
      @bugs =
        60.times.map do |i|
          Actors::Bug.new(index: i).tap do |bug|
            start_bug(args, bug)
          end
        end

    end

    def tick(args)
      if ticks_elapsed >= 30 && args.inputs.keyboard.space && !new_game_started?
        offscreen = @bugs.filter(&:offscreen?)
        offscreen.each { |bug| bug.stop(args) }
        (@bugs - offscreen).each { |bug| bug.scatter(args, { x: 60, y: 24 }) }

        puts "Starting new game"
        start_new_game(args)

        @teardown = Ease.new(ticks: 120)
        @text_easing = Ease.new(from: 1, to: NOKIA_WIDTH, ticks: 30)
      end

      if @teardown&.complete?(args)
        advance_phase!
      end

      @bugs.each do |bug|
        bug.render(args)

        if bug.walking? && bug.position[:x] >= NOKIA_WIDTH
          bug.stop(args)
          start_bug(args, bug)
        end
      end

      args.nokia.labels << {
        x: @text_easing ? @text_easing.current(args) : 1, y: 30,
        size_enum: NOKIA_FONT_MD,
        font: NOKIA_FONT_PATH,
        text: "Game over".upcase,
        **LIGHT_COLOUR_RGB
      }.label!
    end

    def start_bug(args, bug)
      return if new_game_started?

      bug.start(args, wall: :left)
      bug.position ||= {}
      bug.position[:x] = (((2 * NOKIA_WIDTH) - bug.position[:w]) * rand) * -1
      bug.position[:y] = (NOKIA_HEIGHT - bug.position[:h]) * rand
      bug.position[:speed] = 50 * bug.get_walking_speed(args)
      # puts bug.position.inspect
      bug.mode = {
        name: :walking,
        ticks_per_frame: 4 + rand(4).to_i,
        since: args.state.tick_count + rand(3).to_i
      }
      bug.target = {}
    end

    def new_game_started?
      @new_game_started || false
    end

    def start_new_game(args)
      return if @new_game_started
      @new_game_started = true

      Progression.start(args, defer: 30)
    end

    def stack_order
      STACK_ORDER
    end
  end
end

$gtk.reset()
