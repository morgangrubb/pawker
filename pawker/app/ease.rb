class Ease
  include Serializable

  attr_reader :from, :to, :ticks, :mode, :start_tick, :defer

  def initialize(from: 0, to: 0, ticks:, mode: :quad, start_tick: nil, defer: 0)
    @from = from
    @to = to
    @ticks = ticks
    @start_tick = start_tick
    @mode = mode
    @defer = defer
  end

  def relative(args)
    if defer && defer > 0
      @defer -= 1
      return 0
    end

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
    return false if defer && defer > 0

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

$gtk.reset()
