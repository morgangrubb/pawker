class Scene
  include Serializable

  attr_reader :phase, :defer, :ticks_elapsed

  def initialize(args, defer: nil, **kwargs)
    @phases = [:running, :complete].each
    @phase = @phases.next
    @defer = defer
    @ticks_elapsed = 0

    args.state.screens ||= {}
    args.state.screens[self] ||= {}
  end

  def running?
    @phase == :running
  end

  def complete?
    @phase == :complete
  end

  def advance_phase!
    @phase = @phases.next
  end

  # Using this we can now queue multiple scenes
  def tick_with_defer(args)
    if @defer
      @defer_since ||= args.state.tick_count

      if (@defer_since + @defer) >= args.state.tick_count
        @defer = nil
      end

      return
    end

    @ticks_elapsed += 1

    tick(args)
  end

  # def tick(args)
  #   raise "TODO"
  # end
end

$gtk.reset()
