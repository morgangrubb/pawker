class Actors
  attr_reader :actors, :klass

  def initialize(klass:, actors: [])
    @klass = klass
    @actors = actors
  end

  def in_range_of(args, circle)
    self.class.new(klass: klass, actors: actors.filter { |actor| actor.in_range_of?(args, circle) })
  end

  def select
    self.class.new(klass: klass, actors: actors.select { |actor| yield(actor) })
  end

  def any?
    @actors.any?
  end

  def add(count, **args)
    count.times { |i| @actors << @klass.new(index: @actors.length, controller: self, **args) }
  end

  def start(args, **options)
    @actors.each { |actor| actor.start(args, **options) }
  end

  def stop(args)
    @actors.each { |actor| actor.stop(args) }
  end

  def scatter(args, from_point, **options)
    @actors.each { |actor| actor.scatter(args, from_point, **options) }
  end

  def splat(args)
    @actors.each { |actor| actor.scatter(args) }
  end

  def render(args)
    @actors.each { |actor| actor.render(args) }
  end

  def collision?(position)
    @actors.any? { |actor| actor.collision?(position) }
  end
end
