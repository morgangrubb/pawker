class Hand
  attr_accessor :x, :y, :cards, :ease_x, :ease_y

  def initialize(cards: [])
    @cards = cards
    @x = 0
    @y = 0
  end

  # TODO: Update this for the splayed display
  def w
    return 0 if cards.none?

    width_of_cards + 2
  end

  def h
    return 0 if cards.none?

    height_of_cards + 2
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

    width = width_of_cards
    height = height_of_cards

    if ease_x
      @x = ease_x.current(args)
      @ease_x = nil if ease_x.complete?(args)
    end

    if ease_y
      @y = ease_y.current(args)
      @ease_y = nil if ease_y.complete?(args)
    end

    x = @x
    y = @y

    # Draw a light colour outline around the cards
    args.nokia.sprites << { x: x + 1, y: y, w: width, h: height + 2, path: :pixel }.merge(LIGHT_COLOUR_RGB)
    args.nokia.sprites << { x: x, y: y + 1, w: width + 2, h: height, path: :pixel }.merge(LIGHT_COLOUR_RGB)

    # Now position the cards inside the outline
    x = @x + 1
    y = @y + 1

    cards.each do |card|
      card.x = x
      card.y = y

      args.nokia.sprites << card

      x += card.w + 1
    end
  end

  private

  def width_of_cards
    return 0 if cards.none?

    cards.map { |card| card.w + 1 }.reduce(&:+) - 1
  end

  def height_of_cards
    return 0 if cards.none?

    cards.first.h
  end
end

$gtk.reset(seed: Time.now.to_i)
