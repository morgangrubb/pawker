class Actors
  include Enumerable
  include Serializable

  attr_reader :actors, :klass

  def initialize(klass:, actors: [])
    @klass = klass
    @actors = actors
  end

  def each
    @actors.each { |actor| yield actor }
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
    new_actors = []
    count.times { |i| new_actors << @klass.new(index: @actors.length + i, controller: self, **args) }
    @actors += new_actors
    new_actors
  end

  def start(args, **options)
    @actors.each { |actor| actor.start(args, **options) }
  end

  def stop(args)
    @actors.each { |actor| actor.stop(args) }
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

  def serialize
    { actors: @actors }
  end
end

$gtk.reset()
