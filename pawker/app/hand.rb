class Hand
  include Comparable
  include Serializable

  attr_accessor :x, :y, :cards, :ease_x, :ease_y

  def initialize(cards: [])
    @cards = cards
    @x = 0
    @y = 0

    tuck!
  end

  def splay!
    @display = :splayed
  end

  def splay?
    @display == :splayed
  end

  def tuck!
    @display = :tucked
  end

  def tuck?
    @display == :tucked
  end

  def include?(card)
    cards.any? { |card| card.short == card.is_a?(Card) ? card.short : card }
  end

  def w
    return 0 if cards.none?

    width_of_cards + 2
  end

  def h
    return 0 if cards.none?

    height_of_cards + 2
  end

  def add(card)
    @rank = nil
    @cards << card
  end

  def rank
    @rank ||= Ranks.best(self)
  end

  def <=>(other)
    rank <=> (other.is_a?(Hand) ? other.rank : other)
  end

  def remove(card)
    @rank = nil
    @cards.delete!(card)
  end

  def serialize
    { cards: @cards.map(&:short) }
  end

  def inspect
    serialize.to_s
  end

  # Render the best combination of cards splayed, then tuck the remaining
  # cards underneath.
  #
  # TODO: When a card gets added or removed, ease it into place
  #
  # TODO: When a card gets added or removed, ease the size of the box
  #
  def tick(args)
    return if cards.none?

    if ease_x
      @x = ease_x.current(args)
      @ease_x = nil if ease_x.complete?(args)
    end

    if ease_y
      @y = ease_y.current(args)
      @ease_y = nil if ease_y.complete?(args)
    end

    # Position all the cards
    splayed_cards, tucked_cards = splay_and_tuck

    # Calculate the final width
    all_cards = (splayed_cards + tucked_cards)
    width = all_cards.last.x + all_cards.last.w - all_cards.first.x

    # Final height
    height = height_of_cards

    # Draw a light colour outline around the cards
    args.nokia.sprites << { x: x + 1, y: y, w: width, h: height + 2, path: :pixel }.merge(LIGHT_COLOUR_RGB) # Narrow, tall
    args.nokia.sprites << { x: x, y: y + 1, w: width + 2, h: height, path: :pixel }.merge(LIGHT_COLOUR_RGB) # Wide, short

    (splayed_cards + tucked_cards).reverse.each do |card|
      args.nokia.sprites << card
    end
  end

  private

  def splay_and_tuck
    x = @x
    y = @y

    # Now position the cards inside the outline
    x = @x + 1
    y = @y + 1

    splayed_cards, tucked_cards =
      if splay?
        # puts "Splay"
        [cards.sort.reverse, []]
      else
        # puts "Tuck"
        [rank.relevant_cards, rank.kickers]
      end

    # puts "Hand: #{cards.sort.reverse.map(&:short)}"
    # puts "Rank: #{rank.class.name}"
    # puts "Splayed: #{splayed_cards.map(&:short)}"
    # puts "Tucked: #{tucked_cards.map(&:short)}"

    # Use this so that if we're tucking a wide card under a narrow card we can
    # push the wide card around a bit.
    last_card_width = nil

    splayed =
      splayed_cards.each_with_index.map do |card, i|
        x -= 2 if i > 0

        card.y = y
        card.x = x

        x += card.w

        last_card_width = card.w

        card
      end

    tucked =
      tucked_cards.each_with_index.map do |card, i|
        if last_card_width && (last_card_width + 3) < card.w
          x += card.w - last_card_width
        end

        x -= card.w

        if i == 0
          x += 3
        else
          x += 2
        end

        card.y = y
        card.x = x

        x += card.w

        last_card_width = card.w

        card
      end

    [splayed, tucked]
  end

  def width_of_cards
    return 0 if cards.none?

    splayed_cards, tucked_cards = splay_and_tuck
    all_cards = (splayed_cards + tucked_cards)
    all_cards.last.x + all_cards.last.w - all_cards.first.x
  end

  def height_of_cards
    return 0 if cards.none?

    cards.first.h
  end
end

$gtk.reset()
