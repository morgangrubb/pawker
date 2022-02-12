module Scenes
  class Game < Scene
    STACK_ORDER = 10

    def initialize(args, **kwargs)
      super(args, **kwargs)
    end

    def stack_order
      STACK_ORDER
    end

    def tick(args, state)
      return unless running?

      #
      # TODO: This is where we're going to put the control logic for progressing
      #   through the levels. Each one will start a round with the new settings.
      #
    end

    # 1. Create a serialize method that returns a hash with all of
    #    the values you care about.
    def serialize
      { }
    end

    # 2. Override the inspect method and return ~serialize.to_s~.
    def inspect
      serialize.to_s
    end

    # 3. Override to_s and return ~serialize.to_s~.
    def to_s
      serialize.to_s
    end
  end
end

$gtk.reset()
