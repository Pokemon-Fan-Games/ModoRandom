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
                :remember_trainer_teams, :random_trainer_teams, :randomize_trainers_items

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
    end
    # @random_gens = []
    @random_types = {}
    @tm_compatibility_random = {}
    @random_encounter_table = {}
    @wild_paused = false
    @dont_randomize = []
    @given_tm_moves = []
    @semi_random_mode = false
    @random_trainer_teams = {}
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
    @given_tm_moves = []
    @randomize_trainers = false
    @randomize_starters = false
    @semi_random_mode = false
    @random_trainer_teams = {}
    @randomize_trainers_items = false
  end
end

module RandomizedChallenge
  def self.enable(without_defaults = false)
    return unless $game_switches

    $PokemonGlobal.initialize_random_params(without_defaults)
    RandomizerConfigurator.ability_mode = RandomizedChallenge::RANDOM_ABILITY_METHOD
    generate_random_starters #if randomize_starters?
    # $game_switches[RandomizedChallenge::SWITCH] = true
    $PokemonGlobal.random_enabled = true
  end

  def self.disable
    # $game_switches[RandomizedChallenge::SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = false
    $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = false
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
    $PokemonGlobal.wild_paused ? true : false
  end

  def self.randomize_pokemon?
    return !self.wild_paused?
  end
  
  class << self
    alias random_species_paused? wild_paused?
  end

  def self.enabled?
    # $game_switches && $game_switches[RandomizedChallenge::SWITCH] ? true : false
    $PokemonGlobal && $PokemonGlobal.random_enabled ? true : false
  end

  def self.random_abilities?
    enabled? && $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] && !RandomizedChallenge.semi_random_mode? ? true : false
  end

  def self.ability_mode
    return :NO if !random_abilities?
    return :MAPABILITIES if random_abilities? && $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH]
    # return :SAMEINEVOLUTION if random_abilities? && $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH]
    return :FULLRANDOM if random_abilities? && $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH]
  end

  def self.moves_on?
    enabled? && $PokemonGlobal.enable_random_moves && !semi_random_mode? ? true : false
  end

  def self.tm_compat_on?
    enabled? && $PokemonGlobal.enable_random_tm_compat && !semi_random_mode? ? true : false
  end

  def self.progressive?
    enabled? && $PokemonGlobal.progressive_random ? true : false
  end

  def self.gens
    $PokemonGlobal.random_gens ||= []
    $PokemonGlobal.random_gens
  end

  def self.types_on?
    enabled? && $PokemonGlobal.enable_random_types && !semi_random_mode? ? true : false
  end

  def self.ohko_banned?
    $PokemonGlobal.banohko ? true : false
  end

  def self.consistent_wild_encounters?
    enabled? && $PokemonGlobal.consistent_wild_encounters ? true : false
  end

  def self.randomize_trainers?
    enabled? && $PokemonGlobal.randomize_trainers && !semi_random_mode? ? true : false
  end

  def self.randomize_starters?
    enabled? && $PokemonGlobal.randomize_starters ? true : false
  end

  def self.semi_random_mode?
    enabled? && $PokemonGlobal.semi_random_mode ? true : false
  end

  def self.remember_trainer_teams?
    enabled? && $PokemonGlobal.remember_trainer_teams ? true : false
  end

  def self.randomize_trainers_items?
    enabled? && $PokemonGlobal.randomize_trainers_items ? true : false
  end

  def self.gen_included?(gen)
    gens.include?(gen) || gens.empty?
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
    return species_list.sample
  end
  species = species_list.sample
  GameData::Species.get(species)
end

def valid_pokemon?(species, ignore_bst = false, badge_count = nil)
  bst = species.base_stats.values.sum
  badge_count ||= $player.badge_count
  previous_species = GameData::Species.get(species.get_previous_species)
  valid_form = species.mega_stone && species.form != species.unmega_form ? false : true
  valid_bst = ignore_bst || valid_bst?(bst, badge_count)
  blacklisted = RandomizedChallenge::BLACKLISTED_POKEMON.include?(species)
  valid_gen = RandomizedChallenge.gens.empty? || RandomizedChallenge.gens.include?(species.generation) || RandomizedChallenge.gens.include?(previous_species.generation)
  species && !blacklisted && valid_bst && valid_gen && valid_form
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
  attr_accessor :traded
  alias randomized_init initialize

  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    if RandomizedChallenge.enabled? && !RandomizedChallenge::UNRANDOMIZABLE_POKEMON.include?(species)
      species = RandomizedChallenge::WHITELISTED_POKEMON.sample || species unless RandomizedChallenge.wild_paused?
      if RandomizedChallenge::WHITELISTED_POKEMON.empty? && !RandomizedChallenge.wild_paused?
        $PokemonGlobal.random_gens = [] unless RandomizedChallenge.gens
        species = valid_random_species
      end
    end
    randomized_init(species, level, owner, withMoves, recheck_form)
  end

  def traded?
    @traded || false
  end

  def traded=(value)
    @traded = value
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

  # Esto de momento se comenta ya que da problemas de performance hay que ver como optimizarlo.
  # alias reset_moves_random reset_moves
  # def reset_moves
  #   reset_moves_random
  #   movelist = improve_moves_with_stab_and_damage

  #   movelist.each_with_index do |m, i|
  #     @moves[i] = Pokemon::Move.new(m.id)
  #   end
  # end

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

  def random_moveset(progresive = RandomizedChallenge.progressive?, num_moves = 4)
    moves = []
    num_moves.times do
      if RandomizedChallenge::PRIORIZE_STAB_IN_LEARNSET && rand(100) < RandomizedChallenge::STAB_IN_LEARNSET
        move = GameData::Move.get(find_valid_move(0, self.types, false, progresive).id)
      else
        move = GameData::Move.get(find_valid_move(0, [], false, progresive).id)
      end
      moves << move
    end
    moves
  end

  alias random_getMoveList getMoveList
  def getMoveList
    moves = random_getMoveList
    return moves unless RandomizedChallenge.enabled? && RandomizedChallenge.moves_on? && !RandomizedChallenge::UNRANDOMIZABLE_POKEMON.include?(self.species_data.id)

    $PokemonGlobal.random_moves = {} unless $PokemonGlobal.random_moves
    
    return $PokemonGlobal.random_moves[@species][self.form] if $PokemonGlobal.random_moves[@species] && $PokemonGlobal.random_moves[@species][self.form]

    $PokemonGlobal.random_moves[@species] ||= {}
    $PokemonGlobal.random_moves[@species][self.form] ||= []

    moves.each do |item|
      level = item[0]
      if RandomizedChallenge::PRIORIZE_STAB_IN_LEARNSET && rand(100) < RandomizedChallenge::STAB_IN_LEARNSET
        move = find_valid_move(0, self.types)
      else
        move = find_valid_move
      end
      $PokemonGlobal.random_moves[@species][self.form] << [level, move]
    end
    $PokemonGlobal.random_moves[@species][self.form]
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
end

# ********************************************************
# STARTERS RANDOMIZADOS CON DOS ETAPAS EVOLUTIVAS
# ********************************************************

def generate_random_starters
  starter_count = RandomizedChallenge::RANDOM_STARTER_VARIABLES.length || 3
  # Selecciona 3 iniciales unicos de la lista
  if RandomizedChallenge::RANDOM_STARTERS_LIST.empty?
    species_list = [] 
    GameData::Species.each_species do |species|
      next if !RandomizedChallenge.gens.empty? && !RandomizedChallenge.gens.include?(species.generation)
      evolutions = species.get_family_evolutions
      species_list << species if evolutions.size >= 2 && evolutions.one? {|e| e[0] == species.id }
    end
    species_list.shuffle!
    starters = species_list.sample(starter_count)
  else
    valid_starters = RandomizedChallenge.gens.empty? ? RandomizedChallenge::RANDOM_STARTERS_LIST : RandomizedChallenge::RANDOM_STARTERS_LIST.select { |s| RandomizedChallenge.gens.include?(GameData::Species.get(s).generation) }
    starters = valid_starters.sample(starter_count)
  end

  # Asigna los iniciales a las variables
  RandomizedChallenge.pause
  RandomizedChallenge::RANDOM_STARTER_VARIABLES.each_with_index do |var, i|
    pokemon = Pokemon.new(starters[i], 5)
    pbSet(var, pokemon)
  end
  RandomizedChallenge.resume
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
    RandomizedChallenge.pause
    pokemon = Pokemon.new(pokemon, level)
    RandomizedChallenge.resume
  end
  # pokemon.reset_moves
  pbAddPokemon(pokemon)
end


# ********************************************************
# MEGAS RANDOMIZE TO MEGAS
# ********************************************************
alias pbLoadTrainer_random pbLoadTrainer
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  return pbLoadTrainer_random(tr_type, tr_name, tr_version) unless RandomizedChallenge.enabled?

  trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)

  if RandomizedChallenge.remember_trainer_teams? && $PokemonGlobal.random_trainer_teams.has_key?(trainer_data.id)
    trainer = $PokemonGlobal.random_trainer_teams[trainer_data.id]
    return trainer
  end

  if !RandomizedChallenge.randomize_trainers? || RandomizedChallenge::UNRANDOMIZABLE_TRAINERS.include?(trainer_data.id)
    RandomizedChallenge.pause
    trainer = pbLoadTrainer_random(tr_type, tr_name, tr_version)
    RandomizedChallenge.resume
    return trainer
  end

  trainer = pbLoadTrainer_random(tr_type, tr_name, tr_version)
  return trainer if trainer.nil?

  unrandomizable_pokes = RandomizedChallenge::UNRANDOMIZABLE_TRAINER_POKEMON.fetch(trainer_data.id, {})

  if unrandomizable_pokes.empty? 
    trainer.party.map! do |pkmn|
      if RandomizedChallenge::RERANDOM_TRAINER_MOVESET
        pkmn.moves = RandomizedChallenge::TRAINERS_MOVESET_RESPECT_PROGRESSIVE ? pkmn.random_moveset : pkmn.random_moveset(false)
      end
      if RandomizedChallenge.randomize_trainers_items? && !pkmn&.item&.is_mega_stone?
        pkmn.item = RandomizedChallenge.random_item(false, true)
      end
      pkmn
    end
  end

  return trainer if unrandomizable_pokes.empty? && !RandomizedChallenge::MEGAS_RANDOMIZE_TO_MEGAS

  trainer.party.map!.with_index do |pkmn, index|
    if unrandomizable_pokes[index]
      RandomizedChallenge.pause
      pkmn = Pokemon.new(unrandomizable_pokes[index], pkmn.level, pkmn.owner)
      RandomizedChallenge.resume
    elsif pkmn&.item&.is_mega_stone?
      species_data = GameData::Species.get_species_form(pkmn.species, pkmn.form)
      if species_data.mega_stone
        pkmn.item = species_data.mega_stone
      else
        RandomizedChallenge.pause
        new_species = random_species(true)
        pkmn = Pokemon.new(new_species, pkmn.level, pkmn.owner)
        pkmn.item = GameData::Species.get_species_form(new_species, pkmn.form).mega_stone
        RandomizedChallenge.resume
        pkmn.reset_moves
      end
    elsif RandomizedChallenge.randomize_trainers_items?
      pkmn.item = RandomizedChallenge.random_item(false, true)
    end
    if RandomizedChallenge::RERANDOM_TRAINER_MOVESET
      pkmn.moves = RandomizedChallenge::TRAINERS_MOVESET_RESPECT_PROGRESSIVE ? pkmn.random_moveset : pkmn.random_moveset(false)
    end
    pkmn
  end

  if RandomizedChallenge.remember_trainer_teams?
    $PokemonGlobal.random_trainer_teams[trainer_data.id] = trainer
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

        highest_level = @encounter_tables[enc_type].max_by { |enc| enc[0] }[0]

        @encounter_tables[enc_type].map! do |enc|
          level, = enc
          # level_range = (level - 5)..(level + 5)

          badge_count = 0
          badges_max_levels.each_pair do |badge, max_level|
            badge_count = badge if highest_level >= max_level
            break if badge_count != 0 || highest_level < max_level
          end

          # badge_count = badges_max_levels.find { |_, max_level| level_range.include?(max_level) }&.first || 0
          new_species = valid_random_species(badge_count)
          [level, new_species.id]
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
    if !$PokemonGlobal.random_encounter_table.dig($game_map.map_id, enc_type) || $PokemonGlobal.random_encounter_table[$game_map.map_id][enc_type].empty?
      $PokemonGlobal.random_encounter_table ||= {}
      $PokemonGlobal.random_encounter_table[$game_map.map_id] ||= {}
      $PokemonGlobal.random_encounter_table[$game_map.map_id][enc_type] ||= []
      $PokemonGlobal.random_encounter_table[$game_map.map_id][enc_type] = enc_list.map do |enc|
        enc[1] = valid_random_species.id
        enc
      end
    end
    @encounter_tables[enc_type] = $PokemonGlobal.random_encounter_table[$game_map.map_id][enc_type]

    wild = choose_wild_pokemon_random(enc_type, chance_rolls)
    RandomizedChallenge.pause_random_species
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
      @encounter_tables = $PokemonGlobal.random_encounter_table[$game_map.map_id] || {}
      @max_enc, @eLength = @encounter_tables.empty? ? [1, 1] : getMaxEncounters(@encounter_tables)
      pbMessage(_INTL('En el modo random el busca salvajes estará vacío hasta que entres al menos en 1 combate con salvajes por ruta')) if @encounter_tables.empty?
    else
      pbMessage(_INTL('En el modo random donde los Pokémon de las rutas son 100% aleatorios el busca salvajes no mostrará información correcta'))
    end
  end
end
