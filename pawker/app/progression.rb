class Progression
  def self.start(args)
    advance(args, round: -1)
  end

  def self.advance(args, win: nil, round:)
    args.state.deck.reset!
    args.state.deck.shuffle!

    suits = [:spade, :diamond, :heart, :club].shuffle

    if round >= 0 && !win
      args.state.scenes << Scenes::GameOver.new(args)
      return
    elsif round >= 7 && win
      args.state.scenes << Scenes::Winner.new(args)
      return
    end

    next_round = round + 1

    hand_to_beat =
      case next_round
      when -1
        # TODO: Can't get here
        # TODO: High card

      when 0 # One pair
        cards = args.state.deck.pick!(rank: rand(4), suit: suits[0..1])
        Hand.new(cards: cards.sort.reverse)

      when 1 # Two pair
        cards  = args.state.deck.pick!(rank: rand(5), suit: suits[0..1])
        cards += args.state.deck.pick!(rank: rand(4), suit: suits[2..3])
        Hand.new(cards: cards.sort.reverse)

      when 2 # Three of a kind
        cards = args.state.deck.pick!(rank: rand(5), suit: suits[0..2])
        Hand.new(cards: cards)

      when 3 # Straight
        shorts = (2..6).to_a.map { |rank| "#{rank}#{suits.sample.to_s[0].upcase}" }
        cards = args.state.deck.pick!(*shorts)
        Hand.new(cards: cards)

      when 4 # Flush
        cards = args.state.deck.pick!(rank: [[:two, :three].sample, :four, [:five, :six].sample, :seven, :eight], suit: suits.first).sort.reverse
        Hand.new(cards: cards)

      when 5 # Full house
        cards  = args.state.deck.pick!(rank: (0..3).to_a.sample, suit: suits[0..2])
        cards += args.state.deck.pick!(rank: (4..5).to_a.sample, suit: suits[2..3])
        Hand.new(cards: cards.sort.reverse)

      when 6 # Four of a kind
        cards = args.state.deck.pick!(rank: (0..3).to_a.sample)
        Hand.new(cards: cards.sort.reverse)

      when 7 # Straight flush
        cards = args.state.deck.pick!(rank: (0..4).to_a, suit: suits.first)
        Hand.new(cards: cards)

      end

    args.state.scenes << Scenes::Title.new(args, hand_to_beat: hand_to_beat, round: next_round)
  end
end

$gtk.reset()
