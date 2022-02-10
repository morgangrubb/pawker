class Suit
  SUITS = [:spade, :heart, :diamond, :club]
  SHORT = {
    spade: "S",
    heart: "H",
    diamond: "D",
    club: "C"
  }

  attr_reader :suit

  def initialize suit
    @suit = suit
  end

  def short
    SHORT[suit]
  end

  def <=> other
    # return 0 if suit == other.suit
    # SUITS.index(suit) < SUITS.index(other.suit) ? 1 : -1
    #

    # Suits aren't ranked in pawker
    0
  end
end
