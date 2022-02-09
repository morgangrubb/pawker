class Screen
  attr_reader :phase

  def initialize(args, **kwargs)
    @phases = [:running, :complete].each
    @phase = @phases.next

    args.state.screens ||= {}
    args.state.screens[self] ||= {}
  end

  def running?
    @phase == :running
  end

  def complete?
    @phase == :complete
  end

  # def state(args)
  #   args.state.screens[self]
  # end

  def advance_phase!
    @phase = @phases.next
  end

  def advance_phase?(args)
    raise "TODO"
  end

  def tick(args, state)
    raise "TODO"
  end
end
