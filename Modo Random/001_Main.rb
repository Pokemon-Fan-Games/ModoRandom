# ***********************************************************
# - MAIN -
# ***********************************************************

class PokemonGlobalMetadata
  attr_accessor :progressive_random, :random_moves,
                :enable_random_moves, :banohko, :random_gens,
                :enable_random_tm_compat, :tm_compatibility_random, :enable_random_evolutions,
                :enable_random_evolutions_similar_bst,
                :enable_random_evolutions_respect_restrictions, :enable_random_types,
                :random_types, :randomize_items, :randomize_held_items,
                :random_encounter_table, :consistent_wild_encounters, :dont_randomize, :wild_paused
  alias initialize_random initialize
  def initialize
    initialize_random
    initialize_random_params
  end

  def initialize_random_params
    @enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
    @progressive_random = RandomizedChallenge::PROGRESSIVE_RANDOM_DEFAULT_VALUE
    @enable_random_tm_compat = RandomizedChallenge::RANDOM_TM_COMPAT_DEFAULT_VALUE
    @enable_random_evolutions = RandomizedChallenge::RANDOM_EVOLUTIONS_DEFAULT_VALUE
    @enable_random_evolutions_similar_bst = RandomizedChallenge::RANDOM_EVOLUTIONS_SIMILAR_BST_DEFAULT_VALUE
    @enable_random_evolutions_respect_restrictions = RandomizedChallenge::RANDOM_EVOLUTIONS_RESPECT_RESTRICTIONS
    @random_gens = []
    @enable_random_types = RandomizedChallenge::RANDOM_TYPES_DEFAULT_VALUE
    @random_types = {}
    @tm_compatibility_random = {}
    @banohko = RandomizedChallenge::BAN_OHKO_MOVES
    @randomize_items = RandomizedChallenge::RANDOMIZE_ITEMS
    @randomize_held_items = RandomizedChallenge::RANDOMIZE_HELD_ITEMS
    @random_encounter_table = {}
    @consistent_wild_encounters = RandomizedChallenge::CONSISTENT_WILD_ENCOUNTERS
    @wild_paused = false
    @dont_randomize = []
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
  end
end

module RandomizedChallenge
  def self.enable
    return unless $game_switches

    $PokemonGlobal.initialize_random_params
    case RandomizedChallenge::RANDOM_ABILITY_METHOD
    when :FULLRANDOM, :MAPABILITIES
      $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
      $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = RandomizedChallenge::RANDOM_ABILITY_METHOD == :MAPABILITIES
    when :SAMEINEVOLUTION
      $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
      $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = true
    end
    generate_random_starters
    $game_switches[RandomizedChallenge::SWITCH] = true
  end

  def self.disable
    $game_switches[RandomizedChallenge::SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = false
    $PokemonGlobal.disable_random_params
  end

  def self.pause
    $game_switches[RandomizedChallenge::SWITCH] = false
  end

  def self.pause_wild_species
    $PokemonGlobal.wild_paused = true
  end

  def self.resume_wild_species
    $PokemonGlobal.wild_paused = false
  end

  def self.wild_paused?
    $PokemonGlobal.wild_paused ? true : false
  end

  def self.resume
    $game_switches[RandomizedChallenge::SWITCH] = true
  end

  def self.enabled?
    $game_switches && $game_switches[RandomizedChallenge::SWITCH]
  end

  def self.moves_on?
    $PokemonGlobal.enable_random_moves ? true : false
  end

  def self.tm_compat_on?
    $PokemonGlobal.enable_random_tm_compat ? true : false
  end

  def self.progressive?
    $PokemonGlobal.progressive_random ? true : false
  end

  def self.evolutions_on?
    $PokemonGlobal.enable_random_evolutions ? true : false
  end

  def self.evolutions_similar_bst_on?
    $PokemonGlobal.enable_random_evolutions_similar_bst ? true : false
  end

  def self.evos_respect_restrictions?
    $PokemonGlobal.enable_random_evolutions_respect_restrictions
  end

  def self.gens
    $PokemonGlobal.random_gens || []
  end

  def self.types_on?
    $PokemonGlobal.enable_random_types ? true : false
  end

  def self.ohko_banned?
    $PokemonGlobal.banohko ? true : false
  end

  def self.consistent_wild_encounters?
    enabled? && $PokemonGlobal.keep_wild_encounters ? true : false
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

def min_bst_cap(badge_count = nil)
  badge_count ||= $player.badge_count
  min_caps = {
    7 => 440,
    6 => 425,
    5 => 400,
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
    return species_list[rand(species_list.length - 1) + 1]
  end
  species = species_list[rand(species_list.length - 1) + 1]
  GameData::Species.get(species)
end

def valid_pokemon?(species, ignore_bst = false, badge_count = nil)
  bst = species.base_stats.values.sum
  badge_count ||= $player.badge_count
  previous_species = GameData::Species.get(species.get_previous_species)
  valid_bst = ignore_bst || valid_bst?(bst, badge_count)
  blacklisted = RandomizedChallenge::BLACKLISTED_POKEMON.include?(species)
  valid_gen = RandomizedChallenge.gens.empty? || RandomizedChallenge.gens.include?(species.generation) || RandomizedChallenge.gens.include?(previous_species.generation)
  species && !blacklisted && valid_bst && valid_gen
end

def valid_random_species(badge_count = nil)
  badge_count ||= $player.badge_count
  species = random_species
  species = random_species until valid_pokemon?(species, false, badge_count)
  species
end

def valid_bst?(bst, badge_count = nil)
  return true unless RandomizedChallenge.progressive?

  badge_count ||= $player.badge_count
  bst.between?(min_bst_cap(badge_count), max_bst_cap(badge_count))
end

class Pokemon
  alias randomized_init initialize

  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    if RandomizedChallenge.enabled?
      species = RandomizedChallenge::WHITELISTED_POKEMON.sample || species unless RandomizedChallenge.wild_paused?
      if RandomizedChallenge::WHITELISTED_POKEMON.empty? && !RandomizedChallenge.wild_paused?
        $PokemonGlobal.random_gens = [] unless RandomizedChallenge.gens
        species = valid_random_species
      end
    end
    randomized_init(species, level, owner, withMoves, recheck_form)
  end

  def random_types
    types = Set.new
    current_types = GameData::Species.get(@species).types

    until types.size == current_types.size
      type = GameData::Type.keys[rand(GameData::Type.count)]
      types.add(type) unless RandomizedChallenge::INVALID_TYPES.include?(type)
    end
    types.to_a
  end

  alias randomized_types types
  def types
    return randomized_types unless RandomizedChallenge.enabled? && RandomizedChallenge.types_on?

    unless $PokemonGlobal.random_types[@species]
      types = random_types
      $PokemonGlobal.random_types[@species] = types
    end

    $PokemonGlobal.random_types[@species]
  end

  def random_move(min_damage = 0, types = [])
    moves = GameData::Move.keys
    move = moves[rand(moves.length - 1) + 1]
    move = GameData::Move.get(move)
    return move unless (min_damage.positive? && move.display_real_damage(self, move) < min_damage) || (!types.empty? && !types.include?(move.type))

    if min_damage.positive? && !types.empty?
      until move.display_real_damage(self, move) >= min_damage && types.include?(move.type)
        move = moves[rand(moves.length - 1) + 1]
        move = GameData::Move.get(move)
      end
    elsif min_damage.positive?
      until move.display_real_damage(self, move) >= min_damage
        move = moves[rand(moves.length - 1) + 1]
        move = GameData::Move.get(move)
      end
    elsif type
      until types.include?(move.type)
        move = moves[rand(moves.length - 1) + 1]
        move = GameData::Move.get(move)
      end
    end

    Pokemon::Move.new(move.id)
  end

  def invalid_move?(move, move_data)
    move_exists = $PokemonGlobal.random_moves[@species]&.detect { |elem| elem[1] == move }
    RandomizedChallenge::MOVEBLACKLIST.include?(move) || move_exists || (move_data.ohko? && ohko_banned?) ? true : false
  end

  alias reset_moves_random reset_moves
  def reset_moves
    reset_moves_random
    movelist = improve_moves_with_stab_and_damage

    movelist.each_with_index do |m, i|
      @moves[i] = Pokemon::Move.new(m.id)
    end
  end

  def improve_moves_with_stab_and_damage(movelist = nil)
    movelist ||= @moves

    stab_index, damage_index = find_stab_and_damage_indices(types, movelist)

    return movelist if stab_index && damage_index

    movelist = add_or_replace_damage_move(stab_index, movelist) unless damage_index

    movelist = add_or_replace_stab_move(damage_index, types, movelist) unless stab_index

    movelist
  end

  def find_stab_and_damage_indices(types, movelist = nil)
    stab_index = nil
    damage_index = nil

    movelist.each_with_index do |m, i|
      movedata = GameData::Move.get(m.id)
      stab_index = i if types.include?(movedata.type) && !stab_index

      damage_index = i if movedata.display_real_damage(self) > 10 && !damage_index

      break if stab_index && damage_index
    end

    [stab_index, damage_index]
  end

  def add_or_replace_damage_move(stab_index, movelist)
    damage_move = find_valid_move(10)

    if movelist.length < 4
      movelist.push(damage_move)
    else
      movelist = replace_move(stab_index ? [stab_index] : [], damage_move, movelist)
    end
    movelist
  end

  def add_or_replace_stab_move(damage_index, types, movelist)
    return movelist unless RandomizedChallenge::PROBABILITY_OF_STAB.positive?

    chance_of_stab = RandomizedChallenge::PROBABILITY_OF_STAB / 100.0
    return movelist unless rand < chance_of_stab

    max_power = RandomizedChallenge.progressive? && $player.badge_count < 3 ? 70 : 0
    stab_move = find_valid_move(max_power, types)

    if movelist.length < 4
      movelist.push(stab_move)
    else
      movelist = replace_move(damage_index ? [damage_index] : [], stab_move, movelist)
    end
    movelist
  end

  def replace_move(index_to_avoid, move, movelist)
    possible_indices = [0, 1, 2, 3] - index_to_avoid
    return movelist if possible_indices.empty?

    replace_index = possible_indices.sample
    movelist[replace_index] = Pokemon::Move.new(move.id)
    movelist
  end

  def find_valid_move(min_damage = 0, types = [])
    badge_count = $player.badge_count
    move = random_move(min_damage, types)
    loop do
      move_data = GameData::Move.get(move.id)

      if RandomizedChallenge.progressive? && badge_count < 3
        break unless move_data.display_real_damage(self) > 70 || invalid_move?(move, move_data)
      elsif RandomizedChallenge.progressive? && badge_count >= 6
        break unless move_data.display_real_damage(self) < 55 || invalid_move?(move, move_data)
      else
        break unless invalid_move?(move, move_data)
      end

      move = random_move(min_damage, types)
    end

    move
  end

  alias random_getMoveList getMoveList
  def getMoveList
    moves = random_getMoveList
    return moves unless RandomizedChallenge.enabled? && RandomizedChallenge.moves_on?

    $PokemonGlobal.random_moves = {} unless $PokemonGlobal.random_moves
    return $PokemonGlobal.random_moves[@species] if $PokemonGlobal.random_moves[@species]

    $PokemonGlobal.random_moves[@species] = []

    moves.each do |item|
      level = item[0]
      move = find_valid_move
      $PokemonGlobal.random_moves[@species].push([level, move])
    end
    $PokemonGlobal.random_moves[@species]
  end

  alias compatible_with_move_random? compatible_with_move?
  def compatible_with_move?(move_id)
    return compatible_with_move_random?(move_id) unless RandomizedChallenge.enabled? && RandomizedChallenge.tm_compat_on?

    # RAND Compatibility #TM
    $PokemonGlobal.tm_compatibility_random ||= {}
    species_compatibility = $PokemonGlobal.tm_compatibility_random[species] ||= []

    existing_compatibility = species_compatibility.find { |item| item[0] == move_id }
    return existing_compatibility[1] if existing_compatibility

    is_compatible = rand(2).zero?
    $PokemonGlobal.tm_compatibility_random[species] << [move_id, is_compatible]
    is_compatible
  end

  def get_random_evo(_current_species, new_species)
    species_list = GameData::Species.keys
    # species_list.shuffle!
    return species_list.sample unless RandomizedChallenge.evolutions_similar_bst_on? || RandomizedChallenge.evos_respect_restrictions?

    filtered_species = species_list.select do |species|
      species_bst = GameData::Species.get(species).base_stats.values.sum

      if RandomizedChallenge.evolutions_similar_bst_on?
        new_species_bst = GameData::Species.get(new_species).base_stats.values.sum
        species_bst.between?(new_species_bst * 0.9, new_species_bst * 1.1) && valid_pokemon?(species, true)
      elsif RandomizedChallenge.evos_respect_restrictions?
        valid_pokemon?(species)
      end
    end

    filtered_species.sample
  end

  def check_evolution_internal
    return nil if egg? || shadowPokemon?
    return nil if hasItem?(:EVERSTONE)
    return nil if hasAbility?(:BATTLEBOND)

    species_data.get_evolutions(true).each do |evo| # [new_species, method, parameter, boolean]
      next if evo[3] # Prevolution

      random_evo = RandomizedChallenge.evolutions_on? ? get_random_evo(self, evo[0]) : evo[0]
      ret = yield self, random_evo, evo[1], evo[2] # pkmn, new_species, method, parameter
      return ret if ret
    end
    nil
  end
end

class PokemonEvolutionScene
  alias pbEvolutionSuccess_random pbEvolutionSuccess
  def pbEvolutionSuccess
    previous_level = @pokemon.level
    pbEvolutionSuccess_random
    @pokemon.form = GameData::Species.get(@pokemon.species).base_form
    @pokemon.level = previous_level if RandomizedChallenge.evolutions_on? && @pokemon.level != previous_level
  end
end

# ********************************************************
# STARTERS RANDOMIZADOS CON DOS ETAPAS EVOLUTIVAS
# ********************************************************

def generate_random_starters
  starter_count = RandomizedChallenge::RANDOM_STARTER_VARIABLES.length || 3
  # Selecciona 3 iniciales unicos de la lista
  starters = RandomizedChallenge::RANDOM_STARTERS_LIST.sample(starter_count)

  # Asigna los iniciales a las variables
  RandomizedChallenge::RANDOM_STARTER_VARIABLES.each_with_index do |var, i|
    $game_variables[var] = starters[i]
  end
end

def get_starter(index = 0, var = nil)
  return pbGet(var) if var

  pbGet(RandomizedChallenge::RANDOM_STARTER_VARIABLES[index])
end

def give_starter_random(index = 0, var = nil, level = 5)
  species = get_starter(index, var)
  RandomizedChallenge.pause
  pbAddPokemon(species, level)
  RandomizedChallenge.resume
  $player.party.first.reset_moves
end


# ********************************************************
# MEGAS RANDOMIZE TO MEGAS
# ********************************************************
alias pbLoadTrainer_random pbLoadTrainer
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  return pbLoadTrainer_random(tr_type, tr_name, tr_version) unless RandomizedChallenge.enabled?

  trainer = pbLoadTrainer_random(tr_type, tr_name, tr_version)
  return trainer if trainer.nil?

  trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)
  return trainer if RandomizedChallenge::UNRANDOMIZABLE_TRAINERS.include?(trainer_data.id)

  unrandomizable_pokes = RandomizedChallenge::UNRANDOMIZABLE_TRAINER_POKEMON.fetch(trainer_data.id, {})

  return trainer if unrandomizable_pokes.empty? && !RandomizedChallenge::MEGAS_RANDOMIZE_TO_MEGAS

  trainer.party.map!.with_index do |pkmn, index|
    if unrandomizable_pokes[index]
      RandomizedChallenge.pause
      pkmn = Pokemon.new(unrandomizable_pokes[index], pkmn.level, pkmn.owner)
      RandomizedChallenge.resume
    elsif pkmn&.item&.is_mega_stone?
      species_data = GameData::Species.get(pkmn.species)
      if species_data.mega_stone
        pkmn.item = species_data.mega_stone
      else
        RandomizedChallenge.pause
        new_species = random_species(true)
        pkmn = Pokemon.new(new_species, pkmn.level, pkmn.owner)
        pkmn.item = GameData::Species.get(new_species).mega_stone
        pkmn.reset_moves
        RandomizedChallenge.resume
      end
    end
    pkmn
  end

  trainer
end

class PokemonEncounters
  alias setup_random setup
  def setup(map_ID)
    setup_random(map_ID)
    badges_max_levels = if defined?(RandomizedChallenge::BADGES_MAX_LEVELS)
                          RandomizedChallenge::BADGES_MAX_LEVELS
                        else
                          {}
                        end
    return unless RandomizedChallenge.consistent_wild_encounters? && !badges_max_levels.empty?

    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    if encounter_data
      encounter_data.types.each do |enc_type|
        next unless @encounter_tables[enc_type]

        @encounter_tables[enc_type].map! do |enc|
          level, = enc
          level_range = (level - 5)..(level + 5)
          badge_count = badges_max_levels.find { |_, max_level| level_range.include?(max_level) }&.first || 0
          new_species = valid_random_species(badge_count)
          [level, new_species.id]
        end
        $PokemonGlobal.random_encounter_table[enc_type] = @encounter_tables[enc_type]
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

    if !$PokemonGlobal.random_encounter_table[enc_type] || $PokemonGlobal.random_encounter_table[enc_type].empty?
      $PokemonGlobal.random_encounter_table[enc_type] = enc_list.map do |enc|
        enc[1] = valid_random_species.id
        enc
      end
    end
    @encounter_tables[enc_type] = $PokemonGlobal.random_encounter_table[enc_type]

    wild = choose_wild_pokemon_random(enc_type, chance_rolls)
    RandomizedChallenge.pause_wild_species
    $PokemonGlobal.dont_randomize << wild[0]
    wild
  end
end

class EncounterList_Scene
  alias initialize_random initialize
  def initialize
    initialize_random
    return unless RandomizedChallenge.enabled?

    if RandomizedChallenge.consistent_wild_encounters?
      @encounter_tables = $PokemonGlobal.random_encounter_table || {}
      @max_enc, @eLength = @encounter_tables.empty? ? [1, 1] : getMaxEncounters(@encounter_tables)
      Kernel.pbMessage(_INTL('En el modo random el busca salvajes estará vacío hasta que entres al menos en 1 combate con salvajes por ruta'))
    else
      Kernel.pbMessage(_INTL('En el modo random donde los Pokémon de las rutas son 100% aleatorios el busca salvajes no mostrará información correcta'))
    end
  end
end
