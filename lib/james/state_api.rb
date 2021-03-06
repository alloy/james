module James

  # A state is defined in a dialogue.
  #
  # It has a name with which it can be targeted.
  #
  # A state has three methods:
  #  * hear: If this phrase (or one of these phrases) is heard, move to that state. Takes a hash.
  #  * into: A block that is called on entering.
  #  * exit: A block that is called on exit.
  #
  # Example:
  #   state :time do
  #     hear ['What time is it?', 'And now?'] => :time
  #     into { time = Time.now; "It is currently #{time.hour} #{time.min}." }
  #     exit { "And that was the time." }
  #   end
  #
  class State

    attr_reader :name, :context

    def initialize name, context
      @name    = name
      @context = context

      @transitions = {}

      instance_eval(&Proc.new) if block_given?
    end

    # How do I get from this state to another?
    #
    # Example:
    #   hear 'What time is it?' => :time,
    #        'What? This late?' => :yes
    #
    # Example for staying in the same state:
    #   hear 'What time is it?' # Implicitly staying.
    #
    # Example for staying in the same state and doing something:
    #   hear 'What time is it?' => ->() { "I'm staying in the same state" }
    #
    def hear transitions
      transitions = { transitions => name } unless transitions.respond_to?(:to_hash)
      @transitions.merge! expand(transitions)
    end

    # Execute this block when entering this state.
    #
    def into &block
      @into_block = block
    end

    # Execute this block when exiting this state.
    #
    def exit &block
      @exit_block = block
    end

    # By default, a state is not chainable.
    #
    def chainable?
      @chainable
    end
    def chainable
      @chainable = true
    end

    # Description of self using name and transitions.
    #
    def to_s
      "#{self.class.name}(#{name}, #{context}, #{transitions})"
    end

    # The naughty privates of this class.
    #

      # Expands a hash in the form
      #  * [a, b] => c to a => c, b => c
      # but leaves a non-array key alone.
      #
      def expand transitions
        results = {}
        transitions.each_pair do |phrases, state_name|
          [*phrases].each do |phrase|
            results[phrase] = state_name
          end
        end
        results
      end

  end

end