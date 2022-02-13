module Scenes
  class RanksTest < Scene
    attr_reader :deck

    def initialize(args, **kwargs)
      super(args, **kwargs)

      @deck = args.state.deck
    end

    def stack_order
      0
    end

    def tick(args)
      if running?
        # On space, start the next screen
        if args.inputs.keyboard.space
          advance_phase!

          # Start the next screen
          args.state.scenes << Scenes::Title.new(args)
        elsif args.state.tick_count % 60 == 0
          test_high_card
          test_pair
          test_two_pair
          test_three_of_a_kind
          test_straight
          test_flush
          test_full_house
          test_four_of_a_kind
          test_straight_flush
          test_royal_flush

          test_ranks_ordering

          test_best
        end
      end
    end

    def assert_true(value, message = nil)
      assert_equal true, value, message
    end

    def assert_false(value, message = nil)
      assert_equal false, value, message
    end

    def assert_equal(expected, value, message = nil)
      if expected != value
        raise "#{message}\nExpected: #{expected.inspect}, got: #{value.inspect}"
      end
    end

    def test_high_card
      rank = Ranks::HighCard.new(Hand.new(cards: []))
      assert_false rank.valid?, "HighCard should not be found"

      cards = deck.pick(rank: [:two, :three, :four], suit: :heart)
      rank_low = Ranks::HighCard.new(Hand.new(cards: cards))
      assert_equal ["4H"], rank_low.relevant_cards.map(&:short)
      assert_equal ["3H", "2H"], rank_low.kickers.map(&:short)
      assert_true rank_low.valid?, "HighCard should be found"

      cards = deck.pick(rank: [:ace, :king, :queen], suit: :heart)
      rank_high = Ranks::HighCard.new(Hand.new(cards: cards))
      assert_equal ["AH"], rank_high.relevant_cards.map(&:short)
      assert_equal ["KH", "QH"], rank_high.kickers.map(&:short)
      assert_true rank_high.valid?, "HighCard should be found"

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_pair
      cards = deck.pick(rank: [:two, :three], suit: :heart)
      rank = Ranks::Pair.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No pair should be found"

      cards = deck.pick("2H", "9C", "8C", "7H", "6C", "10C", "AS", "5D", "8D", "10H", "9D", "10S")
      rank = Ranks::Pair.new(Hand.new(cards: cards))
      assert_true rank.valid?, "Pair should be found"
      assert_equal ["10H", "10S"], rank.relevant_cards.map(&:short).sort

      cards = deck.pick(rank: :three, suit: [:diamond, :heart])
      rank_low = Ranks::Pair.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "Pair of 3H, 3D should be found"

      cards = deck.pick(rank: [:three, :seven], suit: [:diamond, :heart])
      cards += deck.pick(rank: :nine, suit: :spade)
      rank_high = Ranks::Pair.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "Pair of 7H, 7D should be found"
      assert_equal ["7D", "7H"], rank_high.relevant_cards.map(&:short).sort, "Pair of 7D, 7H should be found"
      assert_equal ["9S", "3D", "3H"], rank_high.kickers.map(&:short)

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_two_pair
      cards = deck.pick(rank: [:two, :three, :four], suit: :heart)
      rank = Ranks::TwoPair.new(Hand.new(cards: cards))
      assert_false rank.valid?, "TwoPair should not be found"

      cards = deck.pick(rank: [:three, :four], suit: [:diamond, :heart])
      rank_low = Ranks::TwoPair.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "TwoPair should be found"

      cards = deck.pick(rank: [:four, :seven], suit: [:diamond, :heart])
      cards += deck.pick(rank: :nine, suit: :spade)
      rank_high = Ranks::TwoPair.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "TwoPair should be found"
      assert_equal ["7H", "7D", "4H", "4D"], rank_high.relevant_cards.map(&:short), "TwoPair should be found"
      assert_equal ["9S"], rank_high.kickers.map(&:short)

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_three_of_a_kind
      cards = deck.pick(rank: [:two, :three, :four], suit: :heart)
      rank = Ranks::ThreeOfAKind.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No ThreeOfAKind should be found"

      cards = deck.pick(rank: :three, suit: [:diamond, :heart, :club])
      rank_low = Ranks::ThreeOfAKind.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "ThreeOfAKind of 3H, 3D, 3C should be found"

      cards = deck.pick(rank: [:three, :seven], suit: [:diamond, :heart, :club])
      cards += deck.pick(rank: :nine, suit: :spade)
      rank_high = Ranks::ThreeOfAKind.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "ThreeOfAKind of 7H, 7D, 7C should be found"
      assert_equal ["7C", "7D", "7H"], rank_high.relevant_cards.map(&:short).sort
      assert_equal ["9S", "3C"], rank_high.kickers.map(&:short)

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_straight
      cards = deck.pick(rank: [:two, :three, :four, :five], suit: :club)
      rank = Ranks::Straight.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No Straight should be found"

      cards = deck.pick(rank: [:two, :three, :four, :five, :six, :eight], suit: :club)
      rank_low = Ranks::Straight.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "Straight should be found"
      assert_equal ["6C", "5C", "4C", "3C", "2C"], rank_low.relevant_cards.map(&:short)
      assert_true rank_low.kickers.empty?, "Straight has no kickers"

      cards = deck.pick("2C", "3C", "4C", "4H", "5H", "6H")
      rank_middle = Ranks::Straight.new(Hand.new(cards: cards))
      assert_true rank_middle.valid?, "Straight should be found"
      assert_equal ["6H", "5H", "4H", "3C", "2C"], rank_middle.relevant_cards.map(&:short)
      assert_true rank_middle.kickers.empty?, "Straight has no kickers"

      cards = deck.pick(rank: [:nine, :ten, :jack, :queen, :king], suit: :club)
      cards += deck.pick(rank: :ace, suit: :spade)
      rank_high = Ranks::Straight.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "Straight should be found"
      assert_equal ["AS", "KC", "QC", "JC", "10C"], rank_high.relevant_cards.map(&:short)
      assert_true rank_low.kickers.empty?, "Straight has no kickers"

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_flush
      cards = deck.pick(rank: [:two, :three, :four, :five], suit: :club)
      cards += deck.pick(rank: :six, suit: :spade)
      rank = Ranks::Flush.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No Flush should be found"

      cards = deck.pick(rank: [:two, :four, :six, :seven, :eight], suit: :club)
      rank_low = Ranks::Flush.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "Flush should be found"
      assert_true rank_low.kickers.empty?, "Flush has no kickers"

      cards = deck.pick(rank: [:nine, :ten, :jack, :queen, :king], suit: :club)
      cards += deck.pick(rank: :ace, suit: :spade)
      rank_high = Ranks::Flush.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "Flush should be found"
      assert_equal ["KC", "QC", "JC", "10C", "9C"], rank_high.relevant_cards.map(&:short)
      assert_true rank_low.kickers.empty?, "Flush has no kickers"

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_full_house
      cards = deck.pick(rank: [:two, :three, :four, :five, :six], suit: :club)
      cards += deck.pick(rank: :six, suit: :spade)
      rank = Ranks::FullHouse.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No FullHouse should be found"

      cards = deck.pick("AS", "AC", "AH", "KS", "KC", "KH", "QD", "QS")
      rank = Ranks::FullHouse.new(Hand.new(cards: cards))
      assert_true rank.valid?, "FullHouse should be found"
      assert_equal 5, rank.relevant_cards.length
      assert_equal 0, rank.kickers.length
      assert_equal ["AC", "AH", "AS", "KH", "KS"], rank.relevant_cards.map(&:short).sort

      cards = deck.pick(rank: :two, suit: [:club, :heart, :spade])
      cards += deck.pick(rank: :three, suit: [:diamond, :heart])
      rank_low = Ranks::FullHouse.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "FullHouse should be found"
      assert_true rank_low.kickers.empty?, "FullHouse has no kickers"

      cards = deck.pick(rank: :three, suit: [:club, :heart, :spade])
      cards += deck.pick(rank: :two, suit: [:diamond, :heart])
      cards += deck.pick(rank: :ace, suit: :heart)
      cards += deck.pick(rank: :king, suit: :club)
      rank_high = Ranks::FullHouse.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "FullHouse should be found"
      assert_equal ["3S", "3H", "3C", "2H", "2D"], rank_high.relevant_cards.map(&:short)
      assert_true rank_low.kickers.empty?, "FullHouse has no kickers"

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_four_of_a_kind
      cards = deck.pick(rank: [:two, :three, :four], suit: :heart)
      rank = Ranks::FourOfAKind.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No FourOfAKind should be found"

      cards = deck.pick(rank: :three, suit: [:diamond, :heart, :club, :spade])
      cards += deck.pick(rank: :four, suit: [:diamond, :heart])
      rank_low = Ranks::FourOfAKind.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "FourOfAKind should be found"

      cards = deck.pick(rank: :seven, suit: [:diamond, :heart, :club, :spade])
      cards += deck.pick(rank: :nine, suit: :spade)
      cards += deck.pick(rank: :four, suit: [:diamond, :heart])
      rank_high = Ranks::FourOfAKind.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "FourOfAKind should be found"
      assert_equal ["7C", "7D", "7H", "7S"], rank_high.relevant_cards.map(&:short).sort
      assert_equal ["9S"], rank_high.kickers.map(&:short)

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_straight_flush
      cards = deck.pick(rank: [:two, :three, :four, :five], suit: :club)
      cards += deck.pick(rank: :six, suit: :spade)
      rank = Ranks::StraightFlush.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No StraightFlush should be found"

      cards = deck.pick(rank: [:two, :three, :four, :five, :six], suit: :club)
      rank_low = Ranks::StraightFlush.new(Hand.new(cards: cards))
      assert_true rank_low.valid?, "StraightFlush should be found"
      assert_true rank_low.kickers.empty?, "StraightFlush has no kickers"

      cards = deck.pick(rank: [:nine, :ten, :jack, :queen, :king], suit: :club)
      cards += deck.pick(rank: :ace, suit: :spade)
      rank_high = Ranks::StraightFlush.new(Hand.new(cards: cards))
      assert_true rank_high.valid?, "StraightFlush should be found"
      assert_equal ["KC", "QC", "JC", "10C", "9C"], rank_high.relevant_cards.map(&:short)
      assert_true rank_low.kickers.empty?, "StraightFlush has no kickers"

      assert_true rank_low < rank_high
      assert_false rank_high < rank_low
      assert_true rank_high == rank_high
    end

    def test_royal_flush
      cards = deck.pick(rank: [:two, :three, :four, :five, :six], suit: :club)
      cards += deck.pick(rank: :six, suit: :spade)
      rank = Ranks::RoyalFlush.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No RoyalFlush should be found"

      cards = deck.pick(rank: [:ace, :king, :queen, :jack], suit: :heart)
      cards += deck.pick(rank: :ten, suit: :spade)
      rank = Ranks::RoyalFlush.new(Hand.new(cards: cards))
      assert_false rank.valid?, "No RoyalFlush should be found"

      cards = deck.pick(rank: [:ace, :king, :queen, :jack, :ten], suit: :heart)
      rank_heart = Ranks::RoyalFlush.new(Hand.new(cards: cards))
      assert_true rank_heart.valid?, "RoyalFlush should be found"
      assert_equal ["AH", "KH", "QH", "JH", "10H"], rank_heart.relevant_cards.map(&:short)
      assert_true rank_heart.kickers.empty?, "RoyalFlush has no kickers"

      cards = deck.pick(rank: [:ace, :king, :queen, :jack, :ten], suit: :diamond)
      rank_diamond = Ranks::RoyalFlush.new(Hand.new(cards: cards))
      assert_true rank_diamond.valid?, "RoyalFlush should be found"
      assert_equal ["AD", "KD", "QD", "JD", "10D"], rank_diamond.relevant_cards.map(&:short)
      assert_true rank_diamond.kickers.empty?, "RoyalFlush has no kickers"

      assert_true rank_heart == rank_diamond
    end

    def test_ranks_ordering
      cards = deck.pick(rank: [:two, :three, :four], suit: :heart)
      high_card = Ranks::HighCard.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:three, :seven], suit: [:diamond, :heart])
      pair = Ranks::Pair.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:three, :seven], suit: [:diamond, :heart, :club])
      three_of_a_kind = Ranks::ThreeOfAKind.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:three, :four], suit: [:diamond, :heart])
      two_pair = Ranks::TwoPair.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:two, :three, :four, :five, :six], suit: :club)
      straight = Ranks::Straight.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:two, :four, :six, :seven, :eight], suit: :club)
      flush = Ranks::Flush.new(Hand.new(cards: cards))

      cards = deck.pick(rank: :two, suit: [:club, :heart, :spade])
      cards += deck.pick(rank: :three, suit: [:diamond, :heart])
      full_house = Ranks::FullHouse.new(Hand.new(cards: cards))

      cards = deck.pick(rank: :three, suit: [:diamond, :heart, :club, :spade])
      four_of_a_kind = Ranks::FourOfAKind.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:two, :three, :four, :five, :six], suit: :club)
      straight_flush = Ranks::StraightFlush.new(Hand.new(cards: cards))

      cards = deck.pick(rank: [:ace, :king, :queen, :jack, :ten], suit: :heart)
      royal_flush = Ranks::RoyalFlush.new(Hand.new(cards: cards))

      assert_true pair > high_card
      assert_true two_pair > pair
      assert_true three_of_a_kind > two_pair
      assert_true straight > three_of_a_kind
      assert_true flush > straight
      assert_true full_house > flush
      assert_true four_of_a_kind > full_house
      assert_true straight_flush > four_of_a_kind
      assert_true royal_flush > straight_flush
    end

    def test_best
      cards = deck.pick(rank: :two, suit: [:club, :heart, :spade])
      cards += deck.pick(rank: :three, suit: [:diamond, :heart])
      hand = Hand.new(cards: cards)

      best = Ranks.best(hand)

      # Not a Pair, ThreeOfAKind, or TwoPair
      assert_equal Ranks::FullHouse, best.class
    end
  end
end

$gtk.reset()
