# require 'set'

class PokemonGlobalMetadata
  attr_accessor :given_tm_moves, :tm_list, :tm_mart, :tm_move_map
end

module GameData
  class Item
    def move=(move)
      @move = move
      $PokemonGlobal.tm_move_map ||= {}
      $PokemonGlobal.tm_move_map[self.id] = move
    end

    def move
      if $PokemonGlobal.tm_move_map && $PokemonGlobal.tm_move_map.has_key?(self.id)
        return $PokemonGlobal.tm_move_map[self.id]
      end
      return @move
    end
  end
end

#-------------------------------------------------------------------------------
# Overrides of pbItemBall and pbReceiveItem
#-------------------------------------------------------------------------------
# Picking up an item found on the ground
#-------------------------------------------------------------------------------
alias pbItemBall_random pbItemBall
def pbItemBall(item, quantity = 1, outfit_change = nil, randomize = true)
  return pbItemBall_random(item, quantity, outfit_change) unless RandomizedChallenge.randomize_items? && randomize
  
  random_item = RandomizedChallenge.determine_random_item(item)
  pbItemBall_random(random_item, quantity, outfit_change)
end

alias pbReceiveItem_random pbReceiveItem
def pbReceiveItem(item, quantity = 1, outfit_change = nil, randomize = true)
  return pbReceiveItem_random(item, quantity, outfit_change) unless RandomizedChallenge.randomize_items? && randomize

  random_item = RandomizedChallenge.determine_random_item(item)
  pbReceiveItem_random(random_item, quantity, outfit_change)
end

alias pbGenerateWildPokemon_randomized pbGenerateWildPokemon
def pbGenerateWildPokemon(species, level, isRoamer = false)
  return pbGenerateWildPokemon_randomized(species, level, isRoamer) unless RandomizedChallenge.consistent_wild_encounters?

  # Handle randomization logic differently for VOE vs normal encounters
  if RandomizedChallenge.randomize_pokemon? && !$PokemonGlobal.dont_randomize&.include?(species)
    # For VOE spawning, we need to ensure the visual sprite matches the battle species
    if defined?(voe_enabled?) && voe_enabled? && defined?($PokemonGlobal.creatingSpawningPokemon) && $PokemonGlobal.creatingSpawningPokemon
      # During VOE spawning, the species should already be randomized from choose_wild_pokemon
      # So we need to prevent additional randomization in Pokemon.initialize
      RandomizedChallenge.pause_random_species
      $PokemonGlobal.dont_randomize ||= []
      $PokemonGlobal.dont_randomize << species
    else
      # For all other cases (normal encounters, manual wild battles, VOE disabled):
      # Resume random species if consistent wild encounters are enabled
      RandomizedChallenge.resume_random_species if RandomizedChallenge.consistent_wild_encounters?
    end
    $PokemonGlobal.dont_randomize.delete(species) if $PokemonGlobal.dont_randomize&.include?(species) && ( !defined?(voe_enabled?) || !($PokemonGlobal.creatingSpawningPokemon && voe_enabled?))
  end
  wild_poke = pbGenerateWildPokemon_randomized(species, level, isRoamer)
  
  # Mark Pokemon as randomized when using consistent wild encounters
  # Since the species was already randomized in choose_wild_pokemon, we need to manually set the flag
  if RandomizedChallenge.randomize_pokemon?
    wild_poke.randomized = true
  end

  # Clean up after VOE spawning
  if voe_enabled? && $PokemonGlobal.creatingSpawningPokemon
    $PokemonGlobal.dont_randomize.delete(species) if $PokemonGlobal.dont_randomize&.include?(species)
    RandomizedChallenge.resume_random_species if RandomizedChallenge.consistent_wild_encounters?
  end
  
  wild_poke
end

EventHandlers.add(:on_wild_pokemon_created, :randomize_wild_pokemon_item,
  proc { |pokemon|
    if pokemon.item && RandomizedChallenge.randomize_held_items? && !RandomizedChallenge.unrandomizable_item?(pokemon.item)
      pokemon.item = RandomizedChallenge.random_held_item
    end
  }
)

# Ensure proper cleanup after VOE spawning
EventHandlers.add(:on_wild_pokemon_created_for_spawning_end, :cleanup_voe_randomization,
  proc {
    # Ensure randomization state is properly restored after VOE spawning
    if RandomizedChallenge.consistent_wild_encounters? && RandomizedChallenge.randomize_pokemon?
      RandomizedChallenge.resume_random_species
    end
  }
)

EventHandlers.add(:on_end_battle, :gift_random_item,
  proc { |decision, _canLose, battle|
    next if !RandomizedChallenge::TRAINERS_CAN_GIVE_RANDOM_ITEMS || !RandomizedChallenge.randomize_items? || decision != 1 || !battle ||!battle.trainerBattle?
    chance = RandomizedChallenge::PROBABILITY_OF_RANDOM_ITEMS_FROM_TRAINERS || 15
    give_item = rand < (chance / 100)
    pbReceiveItem(:POKEBALL) if give_item
  }
)

module RandomizedChallenge
  # Add missing error class
  class RandomizationError < StandardError; end

  def self.ensure_tm_moves_set
    $PokemonGlobal.given_tm_moves ||= Set.new
    if $PokemonGlobal.given_tm_moves.is_a?(Array)
      $PokemonGlobal.given_tm_moves = Set.new($PokemonGlobal.given_tm_moves)
    end
  end

  def self.randomize_items?
    enabled? && $PokemonGlobal.randomize_items ? true : false
  end

  def self.randomize_held_items?
    enabled? && $PokemonGlobal.randomize_held_items ? true : false
  end

  def self.random_item(ignore_exclusions = false, no_tm = false, is_held_item = false)
    # Cache filtered lists based on parameters
    cache_key = "#{ignore_exclusions}_#{no_tm}_#{is_held_item}"
    @@filtered_items ||= {}

    unless @@filtered_items[cache_key]
      all_items = GameData::Item.keys
      @@filtered_items[cache_key] = all_items.select do |item_id|
        item = GameData::Item.get(item_id)
        next false if !ignore_exclusions && excluded_item?(item, is_held_item)
        next false if item.is_machine? && no_tm
        true
      end
    end

    return nil if @@filtered_items[cache_key].empty?
    item = GameData::Item.get(@@filtered_items[cache_key].sample)

    if (item.is_TM? || item.is_TR?) && $bag.has?(item)
      return fallback_to_random_item
    end

    # Add TM move assignment logic
    if (item.is_TM? || item.is_TR?) && RANDOMIZE_TM_MOVES
      random_move = random_move_for_tm
      if !random_move
        return fallback_to_random_item
      end
      item.move = random_move
    end
    
    item
  end

  def self.random_held_item
    no_tm = !RandomizedChallenge::WILD_CAN_HAVE_TMS
    random_item(false, no_tm, true)
  end

  def self.random_move_for_tm
    ensure_tm_moves_set
    move = find_valid_move(0, [], true)
    counter = 0
    while $PokemonGlobal.given_tm_moves.include?(move.id)
      move = find_valid_move(0, [], true)
      counter += 1
      return nil if counter >= 1000
    end
    $PokemonGlobal.given_tm_moves.add(move.id)
    move 
  end

  def self.random_tm(check_allow_list = true, allow_duplicates = ALLOW_DUPLICATE_TMS)
    validate_tm_generation_preconditions!
    ensure_tm_moves_set
    
    if check_allow_list && !MTLIST_RANDOM.empty?
      return find_available_tm_from_allowlist || fallback_to_random_item
    end
    
    find_unique_tm(allow_duplicates) || fallback_to_random_item
  rescue StandardError => e
    log_error("TM generation failed", e)
    fallback_to_random_item
  end

  def self.get_tm_list
    $PokemonGlobal.tm_list ||= []
    if !$PokemonGlobal.tm_list.empty?
      $PokemonGlobal.tm_list.delete_if { |tm| $bag.has?(tm) }
      return $PokemonGlobal.tm_list.shuffle
    end
    tms = []  # Get all item IDs
    GameData::Item.each do |item|
      tms << item if item.is_TM? && !$bag.has?(item)
    end
    $PokemonGlobal.tm_list = tms
    $PokemonGlobal.tm_list.shuffle
  end

  def self.determine_random_item(original_item)
    return original_item if unrandomizable_item?(original_item)
    item = GameData::Item.get(original_item)
    if item.is_machine? && RANDOMIZE_TM_MOVES
      if $bag.has?(item)
        return fallback_to_random_item
      end
      random_move = random_move_for_tm
      if !random_move
        item = fallback_to_random_item
      else
        item.move = random_move
      end
    else
      item = random_item
    end

    item
  end

  def has_all_tms?
    tm_list = get_tm_list
    return true if tm_list.empty?
    tm_list.all? { |tm| $bag.has?(tm) }
  end

  def self.unrandomizable_item?(item)
    item_data = GameData::Item.get(item)
    UNRANDOMIZABLE_ITEMS.include?(item) || item_data.is_key_item? || item_data.is_HM? || item_data.is_mega_stone? ? true : false
  end

  def self.excluded_item?(item, is_held_item = false)
    item_data = GameData::Item.get(item.id)
    ITEM_BLACK_LIST.include?(item.id) || (is_held_item && HELD_ITEM_BLACK_LIST.include?(item.id)) || item_data.is_key_item? || item_data.is_mail? || item_data.is_snag_ball? || item_data.is_HM? ? true : false
  end

  def self.randomize_tm_moves(tms, types = [])
    return unless tms.is_a?(Array) && !tms.empty?
    
    # Ensure given_tm_moves is properly initialized as a Set
    ensure_tm_moves_set
    
    tms.each do |tm|
      next unless tm.respond_to?(:is_TM?) && (tm.is_TM? || tm.is_TR?)
      
      # Find a valid move, considering type restrictions if provided
      move = find_valid_move(0, types, true)
      while $PokemonGlobal.given_tm_moves.include?(move.id)
        move = find_valid_move(0, types, true)
      end

      # Assign the move to the TM and track it globally
      tm.move = move.id
      $PokemonGlobal.given_tm_moves.add(move.id)
    end
  end

  
  def self.get_random_tms(amount = 5)
    tms = Set.new
    max_attempts = amount * 10  # Allow more attempts for larger requests
    attempts = 0
    
    while tms.size < amount && attempts < max_attempts
      tm = RandomizedChallenge.random_tm
      next if !tm 
      tms.add(tm) if tm  # Set automatically handles duplicates
      attempts += 1
    end
    
    return tms.to_a
  end
  
  def self.tm_mart(id, amount = 5, types=[])
    $PokemonGlobal.tm_mart ||= {}
    tms = $PokemonGlobal.tm_mart[id]
    return tms if tms
    tms = get_random_tms(amount)
    tms.delete_if { |tm| !GameData::Item.get(tm).is_TM? }
    tms.map! { |tm| GameData::Item.get(tm).move = RandomizedChallenge.random_move_for_tm; tm }
    # randomize_tm_moves(tms, types) if RANDOMIZE_TM_MOVES
    $PokemonGlobal.tm_mart[id] = tms
    return tms
  end

  # Performance limits
  MAX_TM_SEARCH_ATTEMPTS = 150
  TM_GENERATION_MULTIPLIER = 10

  # Add missing helper methods
  def self.should_randomize_gifted_items?
    GIFTED_POKEMON_CAN_HAVE_ITEMS && enabled? && randomize_items? ? true : false
  end

  def self.find_available_tm_from_allowlist
    random_tms = MTLIST_RANDOM.shuffle
    random_tms.find { |tm_id| !$bag.has?(GameData::Item.get(tm_id)) }
  end

  def self.fallback_to_random_item
    random_item(false, true)
  end

  private

  def self.validate_tm_generation_preconditions!
    tm_list = get_tm_list
    raise RandomizationError, "No TMs available for randomization" if tm_list.empty?
  end

  def self.find_unique_tm(allow_duplicates)
    tm_list = get_tm_list
    max_attempts = [tm_list.length, MAX_TM_SEARCH_ATTEMPTS].min
    
    max_attempts.times do
      tm = tm_list.sample
      if RandomizedChallenge::RANDOMIZE_TM_MOVES
        move = find_valid_move(0, [], true)
        counter = 0
        while $PokemonGlobal.given_tm_moves.include?(move.id)
          move = find_valid_move(0, [], true)
          counter += 1
          break if counter >= 1000
        end
        tm.move = move.id
      end
      return tm if allow_duplicates || !$bag.has?(tm)
    end
    nil
  end

  def self.log_error(message, error)
    puts "RandomizedChallenge Error: #{message} - #{error.message}" if $DEBUG
  end
end

module RandomizedChallenge
  def self.with_pokemon_item_randomization(pokemon, level)
    wild_paused = wild_paused?
    resume_random_species if wild_paused && randomize_pokemon?
    
    pokemon = Pokemon.new(pokemon, level) unless pokemon.is_a?(Pokemon)
    
    if should_give_random_item?
      pokemon.item = random_held_item
    end
    
    result = yield(pokemon, level)
    
    pause_random_species if wild_paused && randomize_pokemon?
    result
  end
  
  private
  
  def self.should_give_random_item?
    return false unless GIFTED_POKEMON_CAN_HAVE_ITEMS && enabled? && randomize_items?
    
    chance = GIFTED_POKEMON_ITEM_PROBABILITY.between?(0, 100) ? GIFTED_POKEMON_ITEM_PROBABILITY : 15
    rand < (chance / 100.0)
  end
end

alias pbAddPokemon_random pbAddPokemon unless defined?(pbAddPokemon_random)
def pbAddPokemon(pkmn, level = 1, see_form = true)
  return pbAddPokemon_random(pkmn, level, see_form) unless RandomizedChallenge.should_randomize_gifted_items?
  
  RandomizedChallenge.with_pokemon_item_randomization(pkmn, level) do |pokemon, lvl|
    pbAddPokemon_random(pokemon, lvl, see_form)
  end
end

alias pbAddPokemonSilent_random pbAddPokemonSilent
def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return pbAddPokemonSilent_random(pkmn, level, see_form) unless RandomizedChallenge.should_randomize_gifted_items?
  
  RandomizedChallenge.with_pokemon_item_randomization(pkmn, level) do |pokemon, lvl|
    pbAddPokemonSilent_random(pokemon, lvl, see_form)
  end
end
