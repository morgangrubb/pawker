class Label
  include Serializable

  attr_accessor :x, :y, :text, :size_enum, :alignment_enum, :vertical_alignment_enum,
    :r, :g, :b, :a, :font, :ease_x, :ease_y, :blendmode_enum

  attr_reader :w, :h, :sub_labels

  def initialize(**options)
    update(**options)
  end

  def update(**options)
    options.each do |(key, value)|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def tick(args)
    if @w.nil?
      @w, @h = args.gtk.calcstringbox(text, size_enum, font)
      @y += @h - 1 # Makes fonts behave like sprites
    end

    if sub_labels.nil?
      lines = text.split("\n")

      if lines.count > 1
        @text = lines[-1]

        @sub_labels =
          lines[0..-2].reverse.each_with_index.map do |line, i|
            Label.new(**serialize.merge(y: @y + (i + 1) * h, text: line))
          end

        @h = (lines.count * @h) + (lines.count - 1)
      else
        @sub_labels ||= []
      end
    end

    if ease_x
      x_before = @x
      @x = ease_x.current(args)
      @ease_x = nil if ease_x.complete?(args)

      x_delta = @x - x_before
      sub_labels.each { |sub_label| sub_label.x += x_delta }
    end

    # Something about this is resulting in the label being rendered lower than
    # it should.
    if ease_y
      y_before = @y
      @y = ease_y.current(args)
      @ease_y = nil if ease_y.complete?(args)

      y_delta = @y - y_before
      sub_labels.each { |sub_label| sub_label.y += y_delta }
    end

    args.nokia.labels << self

    sub_labels.each do |sub_label|
      args.nokia.labels << sub_label
    end
  end

  def serialize
    # %i(x y text size_enum r g b a font).inject({}) do |memo, key|
    #   memo[key] = instance_variable_get(:"@#{name}")
    #   memo
    # end
    instance_variables.inject({}) do |memo, name|
      memo[name.to_s[1..-1].to_sym] = instance_variable_get(name)
      memo
    end.dup
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def primitive_marker
    :label
  end

  def label
    self
  end
end

$gtk.reset()
