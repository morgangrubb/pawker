module Scenes
  class GameOver < Scene
    STACK_ORDER = 1

    def tick(args)
      args.nokia.labels << {
        x: 7, y: 10,
        size_enum: NOKIA_FONT_SM,
        font: NOKIA_FONT_PATH,
        text: "Game over (TODO)".upcase,
        **DARK_COLOUR_RGB
      }.label!

      if args.inputs.keyboard.space
        advance_phase!

        Progression.start(args)
      end
    end

    def stack_order
      STACK_ORDER
    end
  end
end

$gtk.reset()
