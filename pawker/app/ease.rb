class Ease
  attr_reader :from, :to, :ticks, :mode, :start_tick

  def initialize(from:, to:, ticks:, mode: :quad)
    @from = from
    @to = to
    @ticks = ticks
    @start_tick = nil
    @mode = mode
  end

  def relative(args)
    @start_tick ||= args.state.tick_count

    args.easing.ease(@start_tick, args.state.tick_count, @ticks, @mode)
  end

  def current(args)
    @from + ((@to - @from) * relative(args))
  end

  def complete?(args)
    @start_tick ||= args.state.tick_count

    args.state.tick_count >= (@start_tick + @ticks)
  end

  def serialize
    {
      from: @from,
      to: @to,
      ticks: @ticks,
      mode: @mode,
      start_tick: @start_tick
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
