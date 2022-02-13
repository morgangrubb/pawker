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
      @interactive = true
      @teardown = nil
    end

    def stack_order
      STACK_ORDER
    end

    def start_summary(args, **kwargs)
      return if @summary_started
      @summary_started = true

      Progression.round_summary(args, hand_to_beat: @hand_to_beat, hand: @hand, bonus_card: bonus_card, **kwargs)
    end

    def start_teardown(args, defer: 120)
      @teardown ||= Ease.new(ticks: defer)
    end

    def tick(args)
      return unless running?

      if ticks_elapsed >= 20
        if @interactive && args.inputs.keyboard.space && args.state.paw.available?
          # Target the paw on the cursor centre
          args.state.paw.attack(args, args.state.reticle.centre)

          # Splat bugs directly under the reticle
          @bugs
            .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius) }
            .each do |bug|
              @splats.add(1, **bug.position)

              if bug.card
                @hand.add(bug.card)
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

          # If we have now won the round, end early
          if @hand > @hand_to_beat
            @complete = true
            @interactive = false

            start_teardown(args, defer: 90)
            start_summary(args, defer: 60)
          end

          # Find any bugs that need to scatter after the impact
          scatter_bugs =
            if @complete
              @bugs
            else
              @bugs
                .select { |bug| bug.exists? && args.geometry.point_inside_circle?(bug.as_centre, args.state.reticle.centre, args.state.reticle.radius * 2) }
                # .each do |bug|
                #   if bug.card && !@hand.cards.include?(bug.card)
                #     @deck.place(bug.card)
                #     bug.card = nil
                #   end
                # end
            end

          # Scatter any bugs who saw this happen
          scatter_bugs.each do |bug|
            bug.scatter(args, args.state.reticle.centre)
            bug.stop_after_offscreen = true if @complete
          end
        end
      end

      if @interactive && @deck.empty?
        @complete = true # Now wait for all the bugs to leave the screen,
        @bugs.each { |bug| bug.stop_after_offscreen = true }
      end

      if @complete && @bugs.all?(&:offscreen?)
        start_teardown(args, defer: 0)
        start_summary(args, defer: 0)
      end

      advance_phase! if @teardown&.complete?(args)

      args.state.reticle.update(args)
      args.state.paw.update(args)

      @splats.render(args)

      @bugs.render(args)

      @bugs.filter(&:walking?).filter(&:offscreen?).each do |bug|
        if @complete || bug.stop_after_offscreen
          bug.stop(args)
        elsif (card = @deck.draw)
          bug.stop(args, ticks_remaining: rand(80))
          bug.card = card
        else
          bug.stop(args)
        end
      end

      args.nokia.sprites << args.state.reticle

      @hand.tick(args)

      args.nokia.sprites << args.state.paw
    end
  end
end

$gtk.reset()
