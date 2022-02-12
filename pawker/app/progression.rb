class Progression
  def self.start(args)
    reset!(args)
    next_round(args)
  end

  def self.reset!(args)
    args.state.lives = 3
    args.state.round = -1
  end

  def self.lose_a_life(args, **kwargs)
    args.state.lives -= 1
    args.state.scenes << Scenes::Lives.new(args, direction: :lose, **kwargs)
  end

  def self.gain_a_life(args, **kwargs)
    args.state.lives += 1
    args.state.scenes << Scenes::Lives.new(args, direction: :gain, **kwargs)
  end

  def self.game_over(args, **kwargs)
    args.state.scenes << Scenes::GameOver.new(args, **kwargs)
  end

  def self.game_won(args, **kwargs)
    args.state.scenes << Scenes::Winner.new(args, **kwargs)
  end

  def self.repeat_round(args, **kwargs)
    args.state.round -= 1
    next_round(args, **kwargs)
  end

  def self.next_round(args, **kwargs)
    args.state.deck.reset!
    args.state.deck.shuffle!

    suits = [:spade, :diamond, :heart, :club].shuffle

    args.state.round += 1

    if args.state.round == 8
      game_won(args)
      return
    end

    hand_to_beat =
      case args.state.round
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

    # Pick a bonus card and then shuffle it back into the deck
    bonus_card = args.state.deck.top unless args.state.round == 0
    args.state.deck.shuffle!

    args.state.scenes << Scenes::Title.new(args, hand_to_beat: hand_to_beat, bonus_card: bonus_card, **kwargs)
  end
end

$gtk.reset()
