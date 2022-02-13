module Scenes
  class Round < Scene
    STACK_ORDER = 100

    attr_reader :deck, :bonus_card

    def initialize(args, hand_to_beat:, bonus_card: nil, **kwargs)
      super(args, **kwargs)

      args.state.reticle ||= Actors::Reticle.new
      args.state.paw ||= Actors::Paw.new

      @deck = args.state.deck
      @hand_to_beat = hand_to_beat
      @bonus_card = bonus_card
      @bug_count = args.state.bug_count || 1
      @bug_speed = args.state.bug_speed || 1

      @hand = Hand.new
      @hand.splay!
      @hand.x = 1
      @hand.y = 1

      @splats = Actors.new(klass: Actors::Splat)

      @bugs = Actors.new(klass: Actors::Bug)
      @bugs.add(@bug_count).each { |bug| bug.card = deck.draw }
      @bugs.start(args)

      @complete = false
      @ticks_remaining = nil
      @interactive = true
    end

    def stack_order
      STACK_ORDER
    end

    def tick(args)
      return unless running?

      puts "* Round#00a"

      if !@ticks_remaining.nil? && @ticks_remaining <= 0
        puts "* Round#00b"
        advance_phase!
      elsif @interactive && args.inputs.keyboard.space && args.state.paw.available?
        puts "* Round#00c"

        if @deck.empty? # TODO: This needs to allow targetting the bugs that are still running around
          @complete = true
          @interactive = false
          @ticks_remaining = 300
          args.state.scenes << Scenes::RoundSummary.new(args, hand_to_beat: @hand_to_beat, hand: @hand, bonus_card: bonus_card)
        end

        puts "* Round#00d"

        # Target the paw on the cursor centre
        args.state.paw.attack(args, args.state.reticle.centre)

        puts "* Round#000"

        # Splat bugs directly under the reticle
        @bugs
          .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }
          .actors.each do |bug|
            @splats.add(1, **bug.position)

            if bug.card
              puts "0. Hand to beat: #{@hand_to_beat.inspect}"
              puts "1. Adding: #{bug.card.short}"
              puts "2. To: #{@hand.inspect}"

              @hand.add(bug.card)

              puts "3. Found: #{@hand.rank.inspect}"
              puts "5. Player wins: #{@hand > @hand_to_beat}"

              bug.card = nil
            end

            if @complete
              bug.stop(args)
            else
              if (card = @deck.draw)
                bug.start(args) # Reset offscreen
                bug.card = card
              else
                bug.stop(args)
              end
            end
          end

        puts "* Round#001"

        if @hand > @hand_to_beat
          @complete = true
          @interactive = false
          @ticks_remaining = 300
          args.state.scenes << Scenes::RoundSummary.new(args, hand_to_beat: @hand_to_beat, hand: @hand, bonus_card: bonus_card)
        end

        puts "* Round#002"

        scatter_bugs =
          if @complete
            @bugs
          else
            @bugs.select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius * 2) }
          end

        puts "* Round#003"

        # Scatter any bugs who saw this happen
        scatter_bugs.scatter(args, args.state.reticle.centre, stop: @complete)
      end

      puts "* Round#004"

      @ticks_remaining -= 1 if !@ticks_remaining.nil?

      args.state.reticle.update(args)
      args.state.paw.update(args)

      puts "* Round#005"

      @splats.render(args)

      puts "* Round#006"

      @bugs.render(args)

      puts "* Round#007"

      @bugs.filter(&:walking?).filter(&:offscreen?).each do |bug|
        if @complete
          bug.stop(args)
        elsif (card = @deck.draw)
          bug.stop(args, ticks_remaining: rand(80))
          bug.card = card
        else
          bug.stop(args)
        end
      end

      puts "* Round#008"

      args.nokia.sprites << args.state.reticle

      puts "* Round#009"

      @hand.tick(args)

      puts "* Round#010"

      args.nokia.sprites << args.state.paw
    end
  end
end

$gtk.reset()
