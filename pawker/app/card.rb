class Card
  include Serializable

  attr_sprite

  FONT_PATH = NOKIA_FONT_PATH
  FONT_SIZE_ENUM = NOKIA_FONT_SM

  attr_reader :rank, :suit

  def initialize rank, suit
    @rank, @suit = Rank.new(rank), Suit.new(suit)
  end

  def short
    "#{rank.short}#{suit.short}"
  end

  def render_target_name
    @render_target_name ||= :"card_#{short}"
  end

  def generate_render_target!(args)
    target = args.render_target(render_target_name)

    # Get the size of the text to be en-box-ened
    text_w, text_h = args.gtk.calcstringbox(short, FONT_SIZE_ENUM, FONT_PATH)

    # Set the render target size before we apply anything to it
    target.w = text_w + 2
    target.h = text_h + 3

    # Draw a solid box of the light colour
    target.solids << { x: 1, y: 1, w: text_w + 2, h: text_h + 1 }.solid!(LIGHT_COLOUR_RGB)

    # Draw a border
    target.lines << { x: 1, y: 1, x2: text_w, y2: 1 }.merge(DARK_COLOUR_RGB) # Bottom
    target.lines << { x: 0, y: 1, x2: 0, y2: text_h + 1 }.merge(DARK_COLOUR_RGB) # Left
    target.lines << { x: text_w + 1, y: 1, x2: text_w + 1, y2: text_h + 1 }.merge(DARK_COLOUR_RGB) # Right
    target.lines << { x: 1, y: text_h + 3, x2: text_w, y2: text_h + 3 }.merge(DARK_COLOUR_RGB) # Top

    # Draw corners
    target.lines << { x: 2, y: 2, x2: 2, y2: 2 }.merge(DARK_COLOUR_RGB) # Bottom left
    target.lines << { x: text_w + 1, y: 2, x2: text_w + 1, y2: 2 }.merge(DARK_COLOUR_RGB) # Bottom right
    target.lines << { x: 2, y: text_h + 2, x2: 2, y2: text_h + 2 }.merge(DARK_COLOUR_RGB) # Top left
    target.lines << { x: text_w + 1, y: text_h + 2, x2: text_w + 1, y2: text_h + 2 }.merge(DARK_COLOUR_RGB) # Top right

    # Draw a label
    target.labels << {
      text: short,
      x: 2,
      y: text_h + 1,
      size_enum: FONT_SIZE_ENUM,
      font: FONT_PATH,
    }.merge(DARK_COLOUR_RGB)

    # Now draw another light line directly underneath the text to cover an artifact that crops up
    # when the card is a spade (extra pixels under the preceeding character)
    target.lines << { x: 2, y: 2, x2: text_w - 2, y2: 2 }.merge(LIGHT_COLOUR_RGB)

    @x = 0
    @y = 0
    @w = target.w
    @h = target.h
    @path = render_target_name
  end

  def <=> other
    return 0 if rank == other.rank #&& suit == other.suit
    return 1 if rank >= other.rank #&& suit >= other.suit
    return -1
  end

  def serialize
    {
      w: @w, h: @h, x: @x, y: @y, a: @a, angle: @angle,
      path: @path,
      source_x: @source_x, source_y: @source_y, source_w: @source_w, source_h: @source_h
    }.compact
  end

  def to_s
    serialize.to_s
  end
end

$gtk.reset()
