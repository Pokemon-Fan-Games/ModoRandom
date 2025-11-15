module GameData
  class Move
    # Power calculation constants for various move types
    HIDDEN_POWER_MAX = 70
    NATURAL_GIFT_MAX_GEN6_PLUS = 100
    NATURAL_GIFT_MAX_PRE_GEN6 = 80
    FLING_MAX_POWER = 130
    ERUPTION_WATER_SPOUT_MAX = 150
    REVERSAL_FLAIL_MAX = 200
    RETURN_FRUSTRATION_MAX = 102
    TRUMP_CARD_MAX = 200
    CRITICAL_HIT_MULTIPLIER = 1.5
    
    # Returns the maximum possible power this move can achieve under ideal conditions
    # @param ignore_multihit [Boolean] whether to ignore multi-hit calculations
    # @return [Integer] the maximum power value
    def display_max_power(ignore_multihit = false)
      case @function_code
      when "TypeDependsOnUserIVs"
        # Hidden Power maximum is 70 (in modern generations)
        HIDDEN_POWER_MAX
      when "TypeAndPowerDependOnUserBerry"
        # Natural Gift maximum power varies by berry, highest is 100 (in Gen 6+)
        Settings::MECHANICS_GENERATION >= 6 ? NATURAL_GIFT_MAX_GEN6_PLUS : NATURAL_GIFT_MAX_PRE_GEN6
      when "DoublePowerIfUserHasNoItem"
        # Acrobatics doubles when no item
        @power * 2
      when "ThrowUserItemAtTarget"
        # Fling maximum power is 130 (Iron Ball)
        FLING_MAX_POWER
      when "PowerHigherWithUserHP"
        # Eruption/Water Spout maximum is 150
        ERUPTION_WATER_SPOUT_MAX
      when "PowerLowerWithUserHP"
        # Reversal/Flail maximum is 200 (at 1 HP)
        REVERSAL_FLAIL_MAX
      when "PowerHigherWithUserHappiness"
        # Return maximum is 102 (at max happiness)
        RETURN_FRUSTRATION_MAX
      when "PowerLowerWithUserHappiness"
        # Frustration maximum is 102 (at min happiness)
        RETURN_FRUSTRATION_MAX
      when "PowerHigherWithLessPP"
        # Trump Card maximum is 200 (when 1 PP left)
        TRUMP_CARD_MAX
      when "HitThreeTimesPowersUpWithEachHit", "HitThreeTimesPowersUpWithEachHitFlinchTarget"
        # return @power if ignore_multihit
        # Each hit increases in power: 1st hit = base power, 2nd hit = base power * 2, 3rd hit = base power * 3
        # Example: Triple Kick with base power 20 = 20 + 40 + 60 = 120 total power
        max_power = 0
        3.times do |i|
          max_power += @power * (i + 1)
        end
        return max_power
      when "HitTwoToFiveTimes"
        return @power if ignore_multihit
        # Multi-hit moves maximum (5 hits)
        @power * 5
      when "HitThreeTimesAlwaysCriticalHit"
        # Triple hit with critical hit multiplier
        (@power * 3 * CRITICAL_HIT_MULTIPLIER).to_i
      when "HitTwoTimes", "HitTwoTimesFlinchTarget", "HitTwoTimesPoisonTarget", "HitTwoTimesTargetThenTargetAlly"
        # Double hit moves
        @power * 2
      else
        # For all other moves, return base power
        @power || 0
      end
    end

    # Checks if this move is a One-Hit KO move
    # @return [Boolean] true if move has OHKO capability
    def ohko?
      ohko = false
      ohko = (@function_code.downcase.include?("ohko") || @flags&.any? { |flag| flag.downcase.include?("ohko") } )
      return ohko
    end
  end
end

# Move randomization constants
module MoveRandomizer
  # Progressive difficulty thresholds
  EARLY_GAME_BADGES = 3
  LATE_GAME_BADGES = 4
  LATE_GAME_BANNED_MOVES = Set.new([:TACKLE, :KARATECHOP, :POUND, :DOUBLESLAP, :COMETPUNCH, :PAYDAY,
                            :SCRATCH, :VICEGRIP, :WINGATTACK, :GUST, :BIND, :VINEWHIP, :DOUBLEKICK, :STOMP,
                            :SANDATTACK, :HORNATTACK, :FURYATTACK, :WRAP, :TAILWHIP, :POISONSTING, :TWINEDDLE, :LEER,
                            :BITE, :GROWL, :SUPERSONIC, :SONICBOOM, :ACID, :EMBER, :WATERGUN, :PSYBEAM,
                            :BUBBLEBEAM, :PECK, :ABSORB, :MEGADRAIN, :STRINGSHOT, :DRAGONRAGE, :THUNDERSHOCK, :ROCKTHROW,
                            :CONFUSION, :MEDITATE, :RAGE, :TELEPORT, :DIG, :MIMIC, :DOUBLETEAM, :HARDEN,
                            :SMOKESCREEN, :WITHDRAW, :DEFENSECURL, :LICK, :SMOG, :SLUDGE, :BONECLUB, :CLAMP,
                            :SWIFT, :CONSTRICT, :KINESIS, :POISONGAS, :BUBBLE, :FLASH, :FURYSWIPES, :SHARPEN,
                            :STRUGGLE, :CHATTER, :FLAMEWHEEL, :POWDERSNOW, :FAINTATTACK, :SNORE, :SPITUP, :SWALLOW,
                            :MUDSLAP, :FALSESWIPE, :SPARK, :DRAGONBREATH, :PURSUIT, :METALCLAW, :TWISTER, :ROCKSMASH,
                            :STRUGGLE, :CHATTERI, :FLAMEWHEEL, :POWDERSNOW, :FAINTATTACK, :SNORE, :SPITUP, :SWALLOW,
                            :BEATUP, :INGRAIN, :RECYCLE, :IMPRISON, :CAMOUFLAGE, :MUDSPORT, :ASTONISH, :SING,
                            :WATERSPORT, :HOWL, :MUDSHOT, :POISONTAIL, :COVET, :MAGICALLEAF, :SHOCKWAVE, :WATERPULSE,
                            :FLING, :WORRYSEED, :COPYCAT, :MIRRORSHOT, :MAGNETBOMB, :BUGBITE, :OMINOUSWIND, :POWERSWAP,
                            :GUARDSWAP, :TELEKINESIS, :MAGICROOM, :SMACKDOWN, :AFTERYOU, :ROUND, :ECHOEDVOICE, :ALLYSWITCH,
                            :HEALPULSE, :SKYDROP, :QUASH, :WORKUP, :DISARMINGVOICE, :FAIRYWIND, :BRINCO, :CONFIDE, :BURNUP, :DOUBLESHOCK])
  POWER_THRESHOLD = 70
  MAX_ATTEMPTS = 1000  # Prevent infinite loops
end

# Checks if a move is invalid for the given context
# @param move [GameData::Move, Symbol] the move to check
# @param move_data [GameData::Move] the move data object
# @param for_tm [Boolean] whether this is for a TM move
# @return [Boolean] true if move should be rejected
def invalid_move?(move, move_data, for_tm = false)
  return true unless move_data  # Safety check for nil move data
  
  # Check if move is blacklisted
  move_id = move.is_a?(GameData::Move) ? move.id : move
  return true if RandomizedChallenge::MOVEBLACKLIST.include?(move_id)
  
  # Check if move already exists for this Pokémon (only if not for TM)
  unless for_tm
    form_key = RandomizedChallenge.different_moveset_per_form? ? form : 0
    move_exists = $PokemonGlobal.random_moves&.dig(species, form_key)&.any? { |elem| elem[1] == move }
    return true if move_exists
  end
  
  # Check if OHKO moves are banned for this Pokémon
  return true if move_data.ohko? && RandomizedChallenge.ohko_banned?
  
  # Check if this TM move was already given (only for TMs)
  if for_tm && RandomizedChallenge::RANDOMIZE_TM_MOVES
    RandomizedChallenge.ensure_tm_moves_set
    return true if $PokemonGlobal.given_tm_moves&.include?(move_id)
  end
  
  false
end

# Finds a valid move based on progressive difficulty and other constraints
# @param min_damage [Integer] minimum power requirement
# @param types [Array<Symbol>] allowed types (empty = any type)
# @param for_tm [Boolean] whether this is for a TM move
# @param progressive [Boolean] whether to use progressive difficulty
# @return [GameData::Move, nil] valid move or nil if none found
def find_valid_move(min_damage = 0, types = [], for_tm = false, progressive = RandomizedChallenge.progressive?)
  badge_count = $player&.badge_count || 0
  attempts = 0
  move = nil
  loop do
    return move if attempts >= MoveRandomizer::MAX_ATTEMPTS  # Prevent infinite loops
    
    move = random_move(min_damage, types, for_tm)
    return nil unless move  # Safety check
    
    move_data = GameData::Move.get(move.id)
    return nil unless move_data  # Safety check
    
    # Check progressive difficulty constraints
    if progressive
      power = move_data.display_max_power(true)

      case badge_count
      when 0...MoveRandomizer::EARLY_GAME_BADGES
        # Early game: prefer weaker moves
        valid = power <= MoveRandomizer::POWER_THRESHOLD
      when MoveRandomizer::LATE_GAME_BADGES..Float::INFINITY
        # Late game: prefer stronger moves
        valid = !MoveRandomizer::LATE_GAME_BANNED_MOVES.include?(move.id)
      else
        # Mid game: any power level is fine
        valid = true
      end
      
      break if valid && !invalid_move?(move, move_data, for_tm)
    else
      break unless invalid_move?(move, move_data, for_tm)
    end
    
    attempts += 1
  end
  move
end

# Generates a random move that meets the specified criteria
# @param min_damage [Integer] minimum power requirement
# @param types [Array<Symbol>] allowed types (empty = any type)
# @param for_tm [Boolean] whether this is for a TM move (unused in current implementation)
# @return [GameData::Move, nil] random move meeting criteria or nil if none found
def random_move(min_damage = 0, types = [], for_tm = false)
  moves = GameData::Move.keys
  if RandomizedChallenge.ohko_banned?
    moves.reject! { |m| GameData::Move.get(m)&.ohko? }
  end
  return nil if moves.empty?  # Safety check
  
  # Pre-filter moves to avoid infinite loops
  valid_moves = moves.filter_map do |move_key|
    move_data = GameData::Move.get(move_key)
    next unless move_data
    
    # Check power requirement
    if min_damage.positive? && move_data.display_max_power < min_damage
      next
    end
    
    # Check type requirement
    if !types.empty? && !types.include?(move_data.type)
      next
    end
    
    move_data
  end
  
  return nil if valid_moves.empty?  # No valid moves found
  
  valid_moves.sample
end