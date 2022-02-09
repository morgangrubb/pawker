class Hand
  attr_accessor :x, :y, :cards

  def initialize(cards: [])
    @cards = cards
    @x = 0
    @y = 0
  end

  # TODO: Update this for the splayed display
  def w
    return 0 if cards.none?

    cards.map { |card| card.w + 1 }.reduce(&:+) - 1
  end

  def h
    return 0 if cards.none?

    cards.first.h
  end

  def add(card)
    @cards << card
  end

  def remove(card)
    @cards.delete!(card)
  end

  def combinations
    # TODO: Find all possible combinations from this hand of cards
  end

  # Render the best combination of cards splayed, then tuck the remaining
  # cards underneath.
  #
  # TODO: When a card gets added or removed, ease it into place
  #
  # TODO: When a card gets added or removed, ease the size of the box
  #
  def tick(args, box: false)
    return if cards.none?

    width = w
    height = h

    x = @x
    y = @y

    if box
      # Draw a light colour box behind everything
      #
      # TODO: Why is this drawing a dark box?
      args.nokia.solids << { x: x + 1, y: y + 1, w: width + 2, h: height + 2 }.merge(LIGHT_COLOUR_RGB)

      # # Borders
      # args.nokia.lines << { x: x + 1, y: y, x2: width + 1, y2: y }.line!(DARK_COLOUR_RGB) # Bottom
      # args.nokia.lines << { x: x, y: y, x2: x, y2: height }.line!(DARK_COLOUR_RGB) # Left
      # args.nokia.lines << { x: x + 1, y: height + 3, x2: width + 1, y2: height + 3 }.line!(DARK_COLOUR_RGB) # Top
      # args.nokia.lines << { x: width + 3, y: y, x2: width + 3, y2: height }.line!(DARK_COLOUR_RGB) # Right

      # # Corners
      # args.nokia.lines << { x: x + 2, y: y + 1, x2: x + 2, y2: y + 1 }.merge(DARK_COLOUR_RGB) # Bottom left
      # args.nokia.lines << { x: width + 3, y: y + 1, x2: width + 3, y2: y + 1 }.merge(DARK_COLOUR_RGB) # Bottom right
      # args.nokia.lines << { x: x + 2, y: height + 2, x2: x + 2, y2: height + 2 }.merge(DARK_COLOUR_RGB) # Top left
      # args.nokia.lines << { x: width + 3, y: height + 2, x2: width + 3, y2: height + 2 }.merge(DARK_COLOUR_RGB) # Top right

      # Now position the cards inside the box
      x = @x + 2
      y = @y + 2
    end



    cards.each do |card|
      card.x = x
      card.y = y

      args.nokia.sprites << card

      x += card.w + 1
    end
  end
end

$gtk.reset(seed: Time.now.to_i)
