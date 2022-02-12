module Scenes
  class Winner < Scene
    def tick(args)
      args.nokia.labels << {
        x: 11 , y: 10,
        size_enum: NOKIA_FONT_SM,
        font: NOKIA_FONT_PATH,
        text: "You win! (TODO)".upcase,
        **DARK_COLOUR_RGB
      }.label!

      if args.inputs.keyboard.space
        advance_phase!

        Progression.start(args)
      end
    end
  end
end
