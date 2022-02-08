class Ease
  attr_reader :from, :to, :ticks, :mode, :start_tick

  def initialize(from:, to:, ticks:, mode: :quad, start_tick: nil)
    @from = from
    @to = to
    @ticks = ticks
    @start_tick = start_tick
    @mode = mode
  end

  def relative(args)
    @start_tick ||= args.state.tick_count

    case mode
    when :out_back
      ease_out_back((args.state.tick_count - @start_tick) / (@ticks * 1.0))
    when :in_back
      ease_in_back((args.state.tick_count - @start_tick) / (@ticks * 1.0))
    else
      args.easing.ease(@start_tick, args.state.tick_count, @ticks, @mode)
    end
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

  private

  # https://easings.net/#easeOutBack
  def ease_out_back(x)
    return 1.0 if x > 1

    c1 = 1.70158
    c3 = c1 + 1

    1 + c3 * ((x - 1) ** 3) + c1 * ((x - 1) ** 2)
  end

  def ease_in_back(x)
    return 1.0 if x > 1

    c1 = 1.70158
    c3 = c1 + 1

    c3 * x * x * x - c1 * x * x
  end
end

$gtk.reset(seed: Time.now.to_i)
