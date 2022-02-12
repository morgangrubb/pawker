class Scene
  include Serializable

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

  def advance_phase!
    @phase = @phases.next
  end

  def tick(args, state)
    raise "TODO"
  end
end
