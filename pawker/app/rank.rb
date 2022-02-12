class Rank
  include Comparable
  include Serializable

  RANKS = [:ace, :king, :queen, :jack, :ten, :nine, :eight, :seven, :six, :five, :four, :three, :two]
  NUMERIC = RANKS.reverse.each_with_index.inject({}) { |obj, (k, i)| obj[k] = i; obj }
  SHORT = {
    ace: "A",
    king: "K",
    queen: "Q",
    jack: "J",
    ten: "10",
    nine: "9",
    eight: "8",
    seven: "7",
    six: "6",
    five: "5",
    four: "4",
    three: "3",
    two: "2"
  }

  attr_reader :rank

  def initialize rank
    @rank = rank
  end

  def to_i
    NUMERIC[rank]
  end

  def short
    SHORT[rank]
  end

  def <=> other
    return 0 if rank == other.rank
    RANKS.index(rank) < RANKS.index(other.rank) ? 1 : -1
  end
end
