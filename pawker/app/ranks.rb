module Ranks
  ORDER = [:nothing, :high_card, :pair, :two_pair, :three_of_a_kind, :straight, :flush, :full_house, :four_of_a_kind, :straight_flush, :royal_flush]

  def self.valid(hand)
    [
      Nothing.new(hand),
      HighCard.new(hand),
      Pair.new(hand),
      TwoPair.new(hand),
      ThreeOfAKind.new(hand),
      Straight.new(hand),
      Flush.new(hand),
      FullHouse.new(hand),
      FourOfAKind.new(hand),
      StraightFlush.new(hand),
      RoyalFlush.new(hand)
    ].filter(&:valid?)
  end

  def self.best(hand)
    valid(hand).sort.reverse.first
  end

  class Base
    include Comparable
    include Serializable

    attr_reader :hand

    def initialize(hand)
      @hand = hand
    end

    def valid?
      false
    end

    def relevant_cards
      return [] unless valid?

      @relevant_cards || []
    end

    def kickers
      (hand.cards - relevant_cards).sort_by(&:rank).reverse.slice(0, 5 - @relevant_cards.length)
    end

    def <=>(other)
      return 1 if other.nil?
      return 1 unless other.is_a?(Ranks::Base)

      if name == other.name
        if relevant_cards.first == other.relevant_cards.first
          kickers.first <=> other.kickers.first
        else
          relevant_cards.first <=> other.relevant_cards.first
        end
      else
        Ranks::ORDER.index(name) > Ranks::ORDER.index(other.name) ? 1 : -1
      end
    end

    def name
      raise "TODO"
    end

    # def serialize
    #   {
    #     name: name,
    #     hand: hand.cards.map(&:short),
    #     relevant_cards: @relevant_cards&.map(&:short),
    #   }
    # end
  end

  class Nothing < Base
    def name
      :nothing
    end

    def valid?
      hand.cards.none?
    end
  end

  class HighCard < Base
    def name
      :high_card
    end

    def valid?
      return @valid unless @valid.nil?

      if hand.cards.none?
        @valid = false
        return @valid
      end

      @relevant_cards = [hand.cards.sort.reverse.first]
      @valid = true
    end
  end

  class Pair < Base
    def name
      :pair
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length <= 1

      grouped = hand.cards.group_by { |card| card.rank.rank }.filter { |rank, cards| cards.length >= 2 }

      if grouped.keys.empty?
        @valid = false
        return @valid
      end

      sorted = grouped.values.sort_by { |cards| cards.first.rank }

      @relevant_cards = sorted.reverse.first.first(2)
      @valid = true
    end
  end

  class TwoPair < Base
    def name
      :two_pair
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length <= 2

      grouped = hand.cards.group_by { |card| card.rank.rank }.filter { |rank, cards| cards.length >= 2 }

      if grouped.keys.length < 2
        @valid = false
        return @valid
      end

      sorted = grouped.values.sort_by { |cards| cards.first.rank }.reverse

      @valid = false unless sorted.length >= 2

      @relevant_cards = sorted.first + sorted.second
      @valid = true
    end
  end

  class ThreeOfAKind < Base
    def name
      :three_of_a_kind
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length <= 2

      grouped = hand.cards.group_by { |card| card.rank.rank }.filter { |rank, cards| cards.length >= 3 }

      if grouped.keys.empty?
        @valid = false
        return @valid
      end

      sorted = grouped.values.sort_by { |cards| cards.first.rank }

      @relevant_cards = sorted.reverse.first
      @valid = true
    end
  end

  class Straight < Base
    def name
      :straight
    end

    def valid?
      return @valid unless @valid.nil?

      unique_rank = hand.cards.uniq { |card| card.rank.rank }

      return false if unique_rank.length < 5

      offset = 0
      found = nil

      while true do
        sorted = unique_rank.sort.reverse.slice(offset, 5)

        break if sorted.length < 5

        if sorted[0].rank.to_i == sorted[1].rank.to_i + 1 &&
          sorted[1].rank.to_i == sorted[2].rank.to_i + 1 &&
          sorted[2].rank.to_i == sorted[3].rank.to_i + 1 &&
          sorted[3].rank.to_i == sorted[4].rank.to_i + 1
          found = sorted
          break
        else
          offset += 1
        end
      end

      unless found
        @valid = false
        return
      end

      @relevant_cards = found
      @valid = true
    end
  end

  class Flush < Base
    def name
      :flush
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length < 5

      grouped = hand.cards.group_by { |card| card.suit.suit }.filter { |suit, cards| cards.length >= 5 }

      if grouped.keys.empty?
        @valid = false
        return @valid
      end

      sorted = grouped.values.sort_by { |cards| cards.first.rank }

      @relevant_cards = sorted.reverse.first.slice(0, 5)
      @valid = true
    end
  end

  class FullHouse < Base
    def name
      :full_house
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length < 5

      three_of_a_kind = ThreeOfAKind.new(hand)

      unless three_of_a_kind.valid?
        @valid = false
        return @valid
      end

      pair = Pair.new(Hand.new(cards: (hand.cards - three_of_a_kind.relevant_cards)))

      unless pair.valid?
        @valid = false
        return @valid
      end

      @relevant_cards = three_of_a_kind.relevant_cards + pair.relevant_cards
      @valid = true
    end
  end

  class FourOfAKind < Base
    def name
      :four_of_a_kind
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length <= 3

      grouped = hand.cards.group_by { |card| card.rank.rank }.filter { |rank, cards| cards.length >= 4 }

      if grouped.keys.empty?
        @valid = false
        return @valid
      end

      sorted = grouped.values.sort_by { |cards| cards.first.rank }

      @relevant_cards = sorted.reverse.first
      @valid = true
    end
  end

  class StraightFlush < Base
    def name
      :straight_flush
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length < 5

      found =
        hand.cards
          .group_by { |card| card.suit.suit }
          .filter { |suit, cards| cards.length >= 5 }
          .filter_map do |suit, cards|
            straight = Straight.new(Hand.new(cards: cards))
            straight.relevant_cards if straight.valid?
          end

      if found.none?
        @valid = false
        return @valid
      end

      sorted = found.sort_by { |cards| cards.first.rank }

      @relevant_cards = sorted.reverse.first
      @valid = true
    end
  end

  class RoyalFlush < Base
    def name
      :royal_flush
    end

    def valid?
      return @valid unless @valid.nil?
      return false if hand.cards.length < 5

      found =
        hand.cards
          .group_by { |card| card.suit.suit }
          .filter { |suit, cards| cards.length >= 5 }
          .filter_map do |suit, cards|
            straight = Straight.new(Hand.new(cards: cards))
            if straight.valid? && straight.relevant_cards.first.rank.rank == :ace
              straight.relevant_cards
            end
          end

      if found.none?
        @valid = false
        return @valid
      end

      sorted = found.sort_by { |cards| cards.first.rank }

      @relevant_cards = sorted.reverse.first
      @valid = true
    end
  end
end

$gtk.reset()
