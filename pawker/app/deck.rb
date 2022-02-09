class Deck
  CARDS =
    Rank::RANKS.flat_map do |rank|
      Suit::SUITS.map do |suit|
        Card.new(rank, suit)
      end
    end

  def self.generate_render_targets!(args)
    CARDS.each { |card| card.generate_render_target!(args) }
  end

  attr_reader :cards

  def initialize
    reset!
  end

  def draw
    @cards.shift
  end

  def shuffle!
    @cards.shuffle!
  end

  def sort!
    @cards.sort!
  end

  def reset!
    @cards = CARDS.dup
  end
end
