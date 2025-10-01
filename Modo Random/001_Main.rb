# require 'set'

# ***********************************************************
# - MAIN -
# ***********************************************************

class PokemonGlobalMetadata
  attr_accessor :random_enabled, :progressive_random, :randomize_pokemon, :random_moves,
                :enable_random_moves, :banohko, :random_gens,
                :enable_random_tm_compat, :tm_compatibility_random, :enable_random_evolutions,
                :enable_random_evolutions_similar_bst,
                :enable_random_evolutions_respect_restrictions, :enable_random_types,
                :random_types, :randomize_items, :randomize_held_items,
                :random_encounter_table, :consistent_wild_encounters, :dont_randomize, :wild_paused, 
                :given_tm_moves, :randomize_trainers, :randomize_starters, :semi_random_mode,
                :remember_trainer_teams, :random_trainer_teams, :randomize_trainers_items, :randomize_pokemon,
                :reviving_fossil, :fossil_species, :raid_battle_type, :prioritize_stab_in_learnset

  def initialize_random_params(without_defaults = false)
    unless without_defaults
      @enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
      @progressive_random = RandomizedChallenge::PROGRESSIVE_RANDOM_DEFAULT_VALUE
      @enable_random_tm_compat = RandomizedChallenge::RANDOM_TM_COMPAT_DEFAULT_VALUE
      @enable_random_evolutions = RandomizedChallenge::RANDOM_EVOLUTIONS_DEFAULT_VALUE
      @enable_random_evolutions_similar_bst = RandomizedChallenge::RANDOM_EVOLUTIONS_SIMILAR_BST_DEFAULT_VALUE
      @enable_random_evolutions_respect_restrictions = RandomizedChallenge::RANDOM_EVOLUTIONS_RESPECT_RESTRICTIONS
      @enable_random_types = RandomizedChallenge::RANDOM_TYPES_DEFAULT_VALUE
      @banohko = RandomizedChallenge::BAN_OHKO_MOVES
      @randomize_items = RandomizedChallenge::RANDOMIZE_ITEMS
      @randomize_held_items = RandomizedChallenge::RANDOMIZE_HELD_ITEMS
      @consistent_wild_encounters = RandomizedChallenge::CONSISTENT_WILD_ENCOUNTERS
      @randomize_trainers = RandomizedChallenge::RANDOM_TRAINER_TEAM_DEFAULT_VALUE
      @randomize_starters = RandomizedChallenge::RANDOMIZE_STARTERS
      @randomize_trainers_items = RandomizedChallenge::RANDOM_TRAINER_ITEMS_DEFAULT_VALUE
      @randomize_pokemon = RandomizedChallenge::RANDOMIZE_POKEMON
      @prioritize_stab_in_learnset = RandomizedChallenge::PRIORIZE_STAB_IN_LEARNSET
    end
    @reviving_fossil = nil
    @fossil_species = nil
    # @random_gens = []
    @random_types = {}
    @tm_compatibility_random = {}
    @random_encounter_table = {}
    @wild_paused = false
    @dont_randomize = []
    # Migrate from Array to Set if needed, otherwise initialize as Set
    ensure_given_tm_moves_as_set
    @tm_move_map = {}
    @semi_random_mode = false
    @random_trainer_teams = {}
    @raid_battle_type = nil
  end

  def disable_random_params
    @enable_random_moves = false
    @progressive_random = false
    @enable_random_tm_compat = false
    @enable_random_evolutions = false
    @enable_random_evolutions_similar_bst = false
    @enable_random_evolutions_respect_restrictions = false
    @enable_random_types = false
    @random_types = {}
    @banohko = false
    @randomize_items = false
    @randomize_held_items = false
    @random_encounter_table = {}
    @consistent_wild_encounters = false
    @wild_paused = true
    @dont_randomize = []
    # Migrate from Array to Set if needed, otherwise initialize as Set
    ensure_given_tm_moves_as_set
    @tm_move_map = {}
    @randomize_trainers = false
    @randomize_starters = false
    @semi_random_mode = false
    @random_trainer_teams = {}
    @randomize_trainers_items = false
    @randomize_pokemon = false
    @raid_battle_type = nil
    @prioritize_stab_in_learnset = false
  end

  private

  def ensure_given_tm_moves_as_set
    @given_tm_moves = @given_tm_moves.is_a?(Array) ? Set.new(@given_tm_moves) : Set.new
  end
end

module RandomizedChallenge
  def self.enable(without_defaults = false)
    return unless $game_switches

    $PokemonGlobal.initialize_random_params(without_defaults)
    RandomizerConfigurator.ability_mode = RandomizedChallenge::RANDOM_ABILITY_METHOD
    # $game_switches[RandomizedChallenge::SWITCH] = true
    $PokemonGlobal.random_enabled = true
    generate_random_starters #if randomize_starters?
  end

  def self.disable
    # $game_switches[RandomizedChallenge::SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = false
    RandomizedChallenge::Ability.reset_randomized_data
    $PokemonGlobal.disable_random_params
    $PokemonGlobal.random_enabled = false
  end

  def self.pause
    $PokemonGlobal.random_enabled = false
  end

  def self.resume
    $PokemonGlobal.random_enabled = true
  end

  def self.pause_random_species
    $PokemonGlobal.wild_paused = true
  end

  def self.resume_random_species
    $PokemonGlobal.wild_paused = false
  end

  def self.wild_paused?
    !!($PokemonGlobal&.wild_paused)
  end

  def self.randomize_pokemon?
    !!($PokemonGlobal&.randomize_pokemon)
  end
  
  class << self
    alias random_species_paused? wild_paused?
  end

  def self.enabled?
    # $game_switches && $game_switches[RandomizedChallenge::SWITCH] ? true : false
    !!($PokemonGlobal&.random_enabled)
  end

  def self.random_abilities?
    enabled? && $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] #&& !semi_random_mode?
  end

  def self.ability_mode
    return :NO if !random_abilities?
    return :MAPABILITIES if random_abilities? && $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH]
    return :SAMEINEVOLUTION if random_abilities? && $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH]
    return :FULLRANDOM if random_abilities? && $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH]
  end

  def self.moves_on?
    enabled? && $PokemonGlobal.enable_random_moves #&& !semi_random_mode?
  end

  def self.tm_compat_on?
    enabled? && $PokemonGlobal.enable_random_tm_compat #&& !semi_random_mode?
  end

  def self.progressive?
    enabled? && !!$PokemonGlobal.progressive_random
  end

  def self.gens
    $PokemonGlobal.random_gens ||= []
    $PokemonGlobal.random_gens
  end

  def self.types_on?
    enabled? && $PokemonGlobal.enable_random_types #&& !semi_random_mode?
  end

  def self.ohko_banned?
    !!($PokemonGlobal&.banohko)
  end

  def self.consistent_wild_encounters?
    enabled? && !!($PokemonGlobal&.consistent_wild_encounters)
  end

  def self.randomize_trainers?
    enabled? && $PokemonGlobal.randomize_trainers #&& !semi_random_mode?
  end

  def self.randomize_starters?
    enabled? && !!($PokemonGlobal&.randomize_starters)
  end

  def self.semi_random_mode?
    enabled? && !!($PokemonGlobal&.semi_random_mode)
  end

  def self.remember_trainer_teams?
    enabled? && !!($PokemonGlobal&.remember_trainer_teams)
  end

  def self.randomize_trainers_items?
    enabled? && !!($PokemonGlobal&.randomize_trainers_items)
  end

  def self.ensure_damaging_moves?
    RandomizedChallenge::ENSURE_DAMAGING_MOVES
  end

  def self.different_moveset_per_form?
    return DIFFERENT_MOVESETS_PER_FORM if $PokemonGlobal&.different_movesets_per_form.nil?
    enabled? && !!($PokemonGlobal&.different_movesets_per_form)
  end

  def self.gen_included?(gen)
    gens.include?(gen) || gens.empty?
  end

  def self.prioritize_stab_in_learnset?
    enabled? && !!($PokemonGlobal&.prioritize_stab_in_learnset)
  end

  def self.save_tm_compatibility_data(data)
    file_path = get_tm_compatibility_file_path
    File.open(file_path, 'wb') { |f| Marshal.dump(data, f) }
  end

  def self.load_tm_compatibility_data
    file_path = get_tm_compatibility_file_path
    return {} unless File.exist?(file_path)
    
    begin
      File.open(file_path, 'rb') { |f| Marshal.load(f) }
    rescue
      return {}
    end
  end

  def self.get_tm_compatibility_file_path
    # Use save-slot specific filename to ensure independence between saves
    if defined?($player.save_slot) && $player.save_slot
      save_slot = $player&.save_slot || "Default"
      safe_slot_name = save_slot.gsub(/[^a-zA-Z0-9]/, "_") # Replace special chars with underscore
      RTP.getSaveFileName("tm_compatibility_#{safe_slot_name}.dat")
    else
      RTP.getSaveFileName("tm_compatibility.dat")
    end
  end
end

def max_bst_cap(badge_count = nil)
  badge_count ||= $player.badge_count
  max_caps = {
    1 => 400,
    2 => 440,
    3 => 480,
    4 => 520,
    5 => 560,
    6 => 600,
    7 => 800
  }
  min_key = max_caps.keys.min
  max_key = max_caps.keys.max

  # Si el jugador tiene menos medallas que las definidas en max_caps se devuelve el valor de la mas baja
  # Si el jugador tiene mas medallas que las definidas en max_caps se devuelve el valor de la mas alta
  badge_count < min_key ? max_caps[min_key] : max_caps.fetch(badge_count, max_caps[max_key])
end

def reviving_fossil(item)
  return if !GameData::Item.try_get(item)&.is_fossil?
  $PokemonGlobal.reviving_fossil = item
end

def raid_battle(type)
  return if !RandomizedChallenge.enabled?
  return if !RandomizedChallenge.randomize_pokemon?
  return if !GameData::Type.exists?(type)
  $PokemonGlobal.raid_battle_type = type
end

def min_bst_cap(badge_count = nil)
  badge_count ||= $player.badge_count
  min_caps = {
    7 => 460,
    6 => 440,
    5 => 420,
    4 => 375,
    3 => 350
  }
  max_key = min_caps.keys.max

  # Si el jugador tiene mas medallas que las definidas en min_caps se devuelve el valor de la mas alta
  badge_count > max_key ? min_caps[max_key] : min_caps.fetch(badge_count, 0)
end

def random_species(with_mega = false)
  species_list = GameData::Species.keys
  if with_mega
    species_list = species_list.select { |s| GameData::Species.get(s).mega_stone }
    species = species_list.sample
    species = GameData::Species.get(species).species
  else
    species = species_list.sample
    species_id = GameData::Species.get(species).species
    rand_count = RandomizedChallenge::MULTIPLE_FORM_POOL[species_id]
    rand_val = rand(rand_count)
    if rand_count && rand_val != 0
      while RandomizedChallenge::MULTIPLE_FORM_POOL.has_key?(species_id)
        species = species_list.sample
        species_id = GameData::Species.get(species).species
      end
    end
  end
  GameData::Species.get(species)
end

def valid_pokemon?(species, ignore_bst = false, badge_count = nil, type = nil, bst_range = nil)
  return false if species.nil?
  species_data = GameData::Species.get(species)
  base_species = GameData::Species.get(species_data.get_baby_species)
  bst = species_data.base_stats.values.sum
  badge_count ||= $player.badge_count
  ignore_bst = true if !RandomizedChallenge.progressive?
  return false if species_data.form != 0 && species_data.form_name&.downcase&.include?("mega")
  return false if !ignore_bst && !valid_bst?(bst, badge_count)
  return false if type && !species_data.types.include?(type)
  return false if bst_range && !bst_range.include?(bst)
  return false if RandomizedChallenge::BLACKLISTED_POKEMON.include?(species_data.id)
  return false if !RandomizedChallenge.gens.empty? && !RandomizedChallenge.gens.include?(species_data.generation) && !RandomizedChallenge.gens.include?(base_species.generation)
  return true
end

def valid_random_species(badge_count = nil, ignore_bst = false, type = nil, bst_range = nil)
  badge_count ||= $player.badge_count
  attempts = 0
  max_attempts = 1000 # Prevent infinite loops
  species = nil
  
  loop do
    species = random_species
    return species if valid_pokemon?(species, ignore_bst, badge_count, type, bst_range)
    
    attempts += 1
    break if attempts >= max_attempts
  end
  species
end

def valid_bst?(bst, badge_count = nil)
  return true unless RandomizedChallenge.progressive?

  badge_count ||= $player.badge_count
  bst.between?(min_bst_cap(badge_count), max_bst_cap(badge_count))
end

class Pokemon
  attr_accessor :traded
  attr_accessor :randomized
  alias randomized_init initialize

  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    @randomized = false
    return randomized_init(species, level, owner, withMoves, recheck_form) if !RandomizedChallenge.enabled?
    original_species = species
    if RandomizedChallenge.randomize_pokemon? && !RandomizedChallenge::UNRANDOMIZABLE_POKEMON.include?(species)
      if RandomizedChallenge::KEEP_SAME_FOSSIL_POKEMON && $PokemonGlobal.reviving_fossil
        if $PokemonGlobal.fossil_species && $PokemonGlobal.fossil_species[$PokemonGlobal.reviving_fossil]
          species = $PokemonGlobal.fossil_species[$PokemonGlobal.reviving_fossil]
        else
          species = valid_random_species
          $PokemonGlobal.fossil_species ||= {}
          $PokemonGlobal.fossil_species[$PokemonGlobal.reviving_fossil] = species
        end
        $PokemonGlobal.reviving_fossil = nil
      else
        species = RandomizedChallenge::WHITELISTED_POKEMON.sample || species unless RandomizedChallenge.wild_paused?
        if RandomizedChallenge::WHITELISTED_POKEMON.empty? && !RandomizedChallenge.wild_paused?
          $PokemonGlobal.random_gens = [] unless RandomizedChallenge.gens
          if $PokemonGlobal.raid_battle_type
            species_data = GameData::Species.get(species)
            bst_range = create_bst_range(species_data.base_stats.values.sum)
            species = valid_random_species(nil, true, $PokemonGlobal.raid_battle_type, bst_range)
            $PokemonGlobal.raid_battle_type = nil
          else
            species = valid_random_species
          end
        end  
      end
    end

    species ||= original_species
    @randomized = (species != original_species)
    randomized_init(species, level, owner, withMoves, recheck_form)
    
    # Ensure the final moveset has at least one damaging move if moves were generated
    if withMoves && RandomizedChallenge.enabled? && RandomizedChallenge.moves_on? && RandomizedChallenge.ensure_damaging_moves?
      ensure_has_damaging_move!
    end
    
  end

  def traded?
    !!@traded
  end

  def traded=(value)
    @traded = value
  end

  def randomized?
    !!@randomized
  end

  def randomized=(value)
    @randomized = value
  end

  def random_types
    types = Set.new
    current_types = GameData::Species.get(@species).types

    until types.size == current_types.size
      type = GameData::Type.keys.sample
      types.add(type) unless RandomizedChallenge::INVALID_TYPES.include?(type)
    end
    types.to_a
  end

  alias randomized_types types
  def types
    return randomized_types unless RandomizedChallenge.enabled? && RandomizedChallenge.types_on? && self.randomized?

    unless $PokemonGlobal.random_types[@species]
      types = random_types
      $PokemonGlobal.random_types[@species] = types
    end

    $PokemonGlobal.random_types[@species]
  end

  def random_moveset(progresive = RandomizedChallenge.progressive?, num_moves = 4, existing_moves = [])
    moves = []
    num_moves.times do
      move = nil
      if RandomizedChallenge.prioritize_stab_in_learnset? && rand(100) < RandomizedChallenge::STAB_IN_LEARNSET
        move = find_valid_move(0, self.types, false, progresive)
      else
        move = find_valid_move(0, [], false, progresive)
      end

      if move
        move = GameData::Move.get(move.id)
      elsif move.nil? && !existing_moves.empty?
        move = GameData::Move.get(existing_moves.sample)
      end

      moves << move if move
    end

    # make moves uniq
    moves.uniq!

    # Convert to Pokemon::Move objects for damage checking
    move_objects = moves.map { |move_data| Pokemon::Move.new(move_data.id) }
    
    # Ensure at least one damaging move
    move_objects = ensure_damaging_move(move_objects, progresive)
    
    move_objects
  end

  # Ensures the movelist contains at least one damaging move
  def ensure_damaging_move(movelist, progressive = RandomizedChallenge.progressive?)
    return movelist if movelist.empty? || !RandomizedChallenge.ensure_damaging_moves? || !RandomizedChallenge.moves_on?

    # Check if any move already deals damage
    has_damage_move = movelist.any? do |move|
      move_data = GameData::Move.get(move.id)
      move_data.display_power(self) > 10
    end
    
    return movelist if has_damage_move
    
    # If no damaging move found, replace one move with a damaging move
    damaging_move_data = find_valid_move(10, [], false, progressive)
    return movelist unless damaging_move_data # Safety check
    
    damaging_move = Pokemon::Move.new(damaging_move_data.id)
    
    # Replace the first non-damaging move
    movelist[0] = damaging_move
    
    movelist
  end

  # Ensures the learnset contains at least one damaging move
  def ensure_damaging_move_in_learnset(learnset)
    return learnset if learnset.empty? || !RandomizedChallenge.ensure_damaging_moves? || !RandomizedChallenge.moves_on?

    # Check if any move in the learnset is damaging
    has_damage_move = learnset.any? do |level_move|
      move_data = GameData::Move.get(level_move[1].id)
      move_data.display_power(self) > 10
    end
    
    return learnset if has_damage_move
    
    # If no damaging move found, replace the first move with a damaging move
    damaging_move_data = find_valid_move(10)
    return learnset unless damaging_move_data # Safety check
    
    # Keep the same level, replace the move
    original_level = learnset[0][0]
    learnset[0] = [original_level, damaging_move_data]
    
    learnset
  end

  # Public method to ensure any Pokémon has at least one damaging move
  # Can be called on existing Pokémon to fix movesets without damaging moves
  def ensure_has_damaging_move!
    return unless RandomizedChallenge.enabled? && RandomizedChallenge.moves_on? && RandomizedChallenge.ensure_damaging_moves?
    
    # Check if any current move is damaging
    has_damage_move = @moves.any? do |move|
      move_data = GameData::Move.get(move.id)
      move_data.display_power(self) > 10
    end
    
    return if has_damage_move
    
    # Find a damaging move to replace one of the existing moves
    damaging_move_data = find_valid_move(10)
    return unless damaging_move_data # Safety check
    
    # Replace the first move (or add if no moves exist)
    if @moves.empty? || @moves.length < 4
      @moves << Pokemon::Move.new(damaging_move_data.id)
    else
      @moves[0] = Pokemon::Move.new(damaging_move_data.id)
    end
  end

  alias random_getMoveList getMoveList
  def getMoveList
    moves = random_getMoveList
    return moves unless RandomizedChallenge.enabled? && RandomizedChallenge.moves_on? && !RandomizedChallenge::UNRANDOMIZABLE_POKEMON.include?(self.species_data.id)

    $PokemonGlobal.random_moves = {} unless $PokemonGlobal.random_moves
    
    # Determine form key based on configuration
    form_key = RandomizedChallenge.different_moveset_per_form? ? form : 0
    
    return $PokemonGlobal.random_moves[species][form_key] if $PokemonGlobal.random_moves[species] && $PokemonGlobal.random_moves[species][form_key]

    $PokemonGlobal.random_moves[species] ||= {}
    $PokemonGlobal.random_moves[species][form_key] ||= []

    moves.each do |item|
      level = item[0]
      if RandomizedChallenge.prioritize_stab_in_learnset? && rand(100) < RandomizedChallenge::STAB_IN_LEARNSET
        move = find_valid_move(0, self.types)
      else
        move = find_valid_move
      end
      $PokemonGlobal.random_moves[species][form_key] << [level, move]
    end
    $PokemonGlobal.random_moves[species][form_key]
  end

  alias compatible_with_move_random? compatible_with_move?
  def compatible_with_move?(move_id)
    return compatible_with_move_random?(move_id) unless RandomizedChallenge.enabled? && RandomizedChallenge.tm_compat_on?

    # RAND Compatibility #TM - Use in-memory storage
    $PokemonGlobal.tm_compatibility_random ||= {}
    species_compatibility = $PokemonGlobal.tm_compatibility_random[species] ||= []

    existing_compatibility = species_compatibility.find { |item| item[0] == move_id }
    return existing_compatibility[1] if existing_compatibility

    move_type = GameData::Move.get(move_id).type
    if self.types.include?(move_type)
      is_compatible = rand(100) < 70
    else
      is_compatible = rand(100) < 40
    end
    $PokemonGlobal.tm_compatibility_random[species] << [move_id, is_compatible]
    RandomizedChallenge.save_tm_compatibility_data($PokemonGlobal.tm_compatibility_random)
    is_compatible
  end

end

# ********************************************************
# STARTERS RANDOMIZADOS CON DOS ETAPAS EVOLUTIVAS
# ********************************************************

def generate_random_starters(type = nil)
  type ||= MonotypeChallenge.type if defined?(MonotypeChallenge) && MonotypeChallenge.enabled?
  starter_count = RandomizedChallenge::RANDOM_STARTER_VARIABLES.length || 3
  # Selecciona 3 iniciales unicos de la lista
  if RandomizedChallenge::RANDOM_STARTERS_LIST.empty?
    if RandomizedChallenge.progressive?
      species_list = [] 
      GameData::Species.each_species do |species|
        next if !RandomizedChallenge.gens.empty? && !RandomizedChallenge.gens.include?(species.generation)
        evolutions = species.get_family_evolutions
        species_list << species if evolutions.size >= 2 && evolutions.one? {|e| e[0] == species.id }
      end
      species_list.shuffle!
      species_list = species_list.select { |s| s.types.include?(type) } if type
      starters = species_list.sample(starter_count)
    end
  else
    valid_starters = RandomizedChallenge.gens.empty? ? RandomizedChallenge::RANDOM_STARTERS_LIST : RandomizedChallenge::RANDOM_STARTERS_LIST.select { |s| RandomizedChallenge.gens.include?(GameData::Species.get(s).generation) }
    starters = valid_starters.sample(starter_count)
  end

  # Asigna los iniciales a las variables
  if RandomizedChallenge.progressive?
    RandomizedChallenge.pause_random_species
    RandomizedChallenge::RANDOM_STARTER_VARIABLES.each_with_index do |var, i|
      pokemon = Pokemon.new(starters[i], 5)
      pokemon.randomized = true
      pbSet(var, pokemon)
    end
    RandomizedChallenge.resume_random_species
  else
    RandomizedChallenge::RANDOM_STARTER_VARIABLES.each_with_index do |var, i|
      pokemon = Pokemon.new(:PIKACHU, 5)
      pokemon.randomized = true
      pbSet(var, pokemon)
    end
  end

end

def get_starter(index = 0, var = nil)
  # return nil unless RandomizedChallenge.randomize_starters?
  return pbGet(var) if var

  pbGet(RandomizedChallenge::RANDOM_STARTER_VARIABLES[index])
end

def show_random_starter_picture(index = 0, var = nil)
  pokemon = get_starter(index, var)
  pbSet(3, pokemon.name)
  pbMostrarPkmnAnimado(pokemon, true, Graphics.width/2, Graphics.height/2)
  # SpeciesIntro.new(species).set_mark_as_seen(false).show
end

def give_starter_random(index = 0, var = nil, level = 5)
  pokemon = get_starter(index, var)
  if !pokemon.is_a?(Pokemon)
    RandomizedChallenge.pause_random_species
    pokemon = Pokemon.new(pokemon, level)
    RandomizedChallenge.resume_random_species
  end
  pokemon.obtain_map = $game_map.map_id
  pokemon.reset_moves if !RandomizedChallenge.moves_on?
  pbAddPokemon(pokemon)
end

class PokemonEncounters
  alias setup_random setup
  def setup(map_ID)
    setup_random(map_ID)
    return unless RandomizedChallenge.consistent_wild_encounters?

    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    if encounter_data
      encounter_data.types.each do |enc_type|
        next unless @encounter_tables[enc_type]

        @encounter_tables[enc_type].map! do |enc|
          chance, original_species_id, min_level, max_level = enc
          original_species = GameData::Species.get(original_species_id)
          new_species = find_similar_bst_species(original_species, 0.12) # 12% margin
          [chance, new_species.id, min_level, max_level]
        end
        $PokemonGlobal.random_encounter_table ||= {}
        $PokemonGlobal.random_encounter_table[map_ID] ||= {}
        $PokemonGlobal.random_encounter_table[map_ID][enc_type] = @encounter_tables[enc_type]
      end
    end
  end

  alias choose_wild_pokemon_random choose_wild_pokemon
  def choose_wild_pokemon(enc_type, chance_rolls = 1)
    return choose_wild_pokemon_random(enc_type, chance_rolls) unless RandomizedChallenge.consistent_wild_encounters?

    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("El tipo de encuentro {1} no existe", enc_type))
    end

    enc_list = @encounter_tables[enc_type]
    return nil if !enc_list || enc_list.empty?
    
    # Ensure the random encounter table is properly initialized for this map and encounter type
    ensure_random_encounter_table_for_map_and_type($game_map.map_id, enc_type, enc_list)
    
    # Use the cached randomized encounters
    @encounter_tables[enc_type] = $PokemonGlobal.random_encounter_table[$game_map.map_id][enc_type]

    wild = choose_wild_pokemon_random(enc_type, chance_rolls)
    # if !voe_enabled?
    RandomizedChallenge.pause_random_species
    $PokemonGlobal.dont_randomize << wild[0]
    # end
    wild
  end

  private

  def ensure_random_encounter_table_for_map_and_type(map_id, enc_type, enc_list)
    initialize_encounter_table(map_id)
    return if encounter_table_exists?(map_id, enc_type)
    
    $PokemonGlobal.random_encounter_table[map_id][enc_type] = generate_randomized_encounters(enc_list)
  end

  def initialize_encounter_table(map_id)
    $PokemonGlobal.random_encounter_table ||= {}
    $PokemonGlobal.random_encounter_table[map_id] ||= {}
  end

  def encounter_table_exists?(map_id, enc_type)
    $PokemonGlobal.random_encounter_table[map_id][enc_type] && 
      !$PokemonGlobal.random_encounter_table[map_id][enc_type].empty?
  end

  def generate_randomized_encounters(enc_list)
    enc_list.map do |enc|
      chance, original_species_id, min_level, max_level = enc
      original_species = GameData::Species.get(original_species_id)
      new_species = find_similar_bst_species(original_species, 0.12) # 12% margin
      [chance, new_species.id, min_level, max_level]
    end
  end

  def find_similar_bst_species(original_species, margin = 0.12)
    original_bst = original_species.base_stats.values.sum
    bst_range = create_bst_range(original_bst, margin)
    
    attempts = 0
    max_attempts = 1000
    
    loop do
      candidate = random_species
      return candidate if valid_pokemon?(candidate, true, nil, nil, bst_range)
      
      attempts += 1
      if attempts >= max_attempts
        # Fallback to any valid species if we can't find a similar BST
        return random_species
      end
    end
  end


end

def create_bst_range(bst, margin = 0.12)
  bst_range = ((bst * (1 - margin)).to_i..(bst * (1 + margin)).to_i)
  bst_range
end

module Game
  class << self
    alias load_without_tm_compat load
    
    def load(save_data)
      load_without_tm_compat(save_data)
      # Always sync TM compatibility data with the file for this save slot
      if RandomizedChallenge.enabled? && RandomizedChallenge.tm_compat_on?
        file_path = RandomizedChallenge.get_tm_compatibility_file_path
        if File.exist?(file_path)
          $PokemonGlobal.tm_compatibility_random = RandomizedChallenge.load_tm_compatibility_data
        else
          # For old saves, persist current in-memory data to the new file
          RandomizedChallenge.save_tm_compatibility_data($PokemonGlobal.tm_compatibility_random || {})
        end
      end
    end
  end
end