class Deck
  include Serializable

  # CARDS ||=
  #   Rank::RANKS.flat_map do |rank|
  #     Suit::SUITS.map do |suit|
  #       Card.new(rank, suit)
  #     end
  #   end

  # def self.generate_render_targets!(args)
  #   CARDS.each { |card| card.generate_render_target!(args) }
  # end

  attr_reader :cards

  def initialize
    @cards = []
  end

  def generate_cards!(args)
    @raw_cards ||=
      Rank::RANKS.flat_map do |rank|
        Suit::SUITS.map do |suit|
          Card.new(rank: rank, suit: suit).tap { |card| card.generate_render_target!(args) }
        end
      end

    @cards = @raw_cards.dup
  end

  def top
    @cards.first
  end

  def draw
    @cards.shift
  end

  def empty?
    @cards.none?
  end

  def pick(*shorts, rank: [], suit: [])
    ranks =
      if rank.is_a?(Array)
        rank
      else
        [rank]
      end

    suits =
      if suit.is_a?(Array)
        suit
      else
        [suit]
      end

    shorts = shorts.map(&:to_s).map(&:upcase)

    @cards.filter do |card|
      if shorts.any?
        shorts.include?(card.short)
      else
        (ranks.empty? || ranks.include?(card.rank.rank) || ranks.include?(card.rank.to_i)) &&
          (suits.empty? || suits.include?(card.suit.suit))
      end
    end
  end

  def pick!(*shorts, **kwargs)
    picked = pick(*shorts, **kwargs)
    @cards -= picked
    picked
  end

  def place(card)
    @cards << card
  end

  def shuffle!
    @cards.shuffle!
  end

  def sort!
    @cards.sort!
  end

  def reset!
    @cards = @raw_cards.dup
  end
end

$gtk.reset()
