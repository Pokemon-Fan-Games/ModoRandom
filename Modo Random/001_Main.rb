# ***********************************************************
# - MAIN -
# ***********************************************************

class PokemonGlobalMetadata
  attr_accessor :tm_compatibility_random, :random_moves,
                :random_gens, :enable_random_moves, :progressive_random,
                :enable_random_tm_compat, :enable_random_evolutions,
                :enable_random_evolutions_similar_bst,
                :enable_random_evolutions_respect_restrictions, :enable_random_types,
                :random_types
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
  end

  def disable_random_params
    $PokemonGlobal.enable_random_moves = false
    $PokemonGlobal.progressive_random = false
    $PokemonGlobal.enable_random_tm_compat = false
    $PokemonGlobal.enable_random_evolutions = false
    $PokemonGlobal.enable_random_evolutions_similar_bst = false
    $PokemonGlobal.enable_random_evolutions_respect_restrictions = false
    $PokemonGlobal.enable_random_types = false
  end
end

def random_moves_on?
  $PokemonGlobal.enable_random_moves ? true : false
end

def toggle_random_moves
  if $PokemonGlobal.enable_random_moves.nil?
    $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
  end
  $PokemonGlobal.enable_random_moves = !$PokemonGlobal.enable_random_moves
end

def random_tm_compat_on?
  $PokemonGlobal.enable_random_tm_compat ? true : false
end

def toggle_random_tm_compat
  $PokemonGlobal.enable_random_tm_compat = !$PokemonGlobal.enable_random_tm_compat
end

def progressive_random_on?
  $PokemonGlobal.progressive_random ? true : false
end

def toggle_progressive_random
  $PokemonGlobal.progressive_random = !$PokemonGlobal.progressive_random
end

def random_evolutions_on?
  $PokemonGlobal.enable_random_evolutions ? true : false
end

def toggle_random_evolutions
  $PokemonGlobal.enable_random_evolutions = !$PokemonGlobal.enable_random_evolutions
end

def random_evolutions_similar_bst_on?
  $PokemonGlobal.enable_random_evolutions_similar_bst ? true : false
end

def toggle_random_evolutions_similar_bst
  $PokemonGlobal.enable_random_evolutions_similar_bst = !$PokemonGlobal.enable_random_evolutions_similar_bst
end

def do_random_evos_respect_restrictions?
  $PokemonGlobal.enable_random_evolutions_respect_restrictions
end

def toggle_random_evolutions_respect_progressive
  $PokemonGlobal.enable_random_evolutions_respect_restrictions = !$PokemonGlobal.enable_random_evolutions_respect_restrictions
end

def set_random_gens(gens = [])
  $PokemonGlobal.random_gens = Array(gens)
end

def add_or_remove_random_gen(gen = nil)
  return unless gen

  $PokemonGlobal.random_gens = $PokemonGlobal.random_gens || []
  if !$PokemonGlobal.random_gens.include?(gen)
    $PokemonGlobal.random_gens.push(gen)
  else
    $PokemonGlobal.random_gens.delete(gen)
  end
end

def get_random_gens
  $PokemonGlobal.random_gens || []
end

def toggle_random_types
  $PokemonGlobal.enable_random_types = !$PokemonGlobal.enable_random_types
end

def random_types_on?
  $PokemonGlobal.enable_random_types ? true : false
end

def enable_random
  return unless $game_switches
  $PokemonGlobal.initialize_random_params
  case RandomizedChallenge::RANDOM_ABILITY_METHOD
  when :FULLRANDOM
    $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
  when :MAPABILITIES
    $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
    $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = true
  when :SAMEINEVOLUTION
    $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
    $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = true
  end
  generate_random_starters
  $game_switches[RandomizedChallenge::Switch] = true
end

def disable_random
  $game_switches[RandomizedChallenge::Switch] = false
  $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = false
  $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = false
  $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = false
  $PokemonGlobal.disable_random_params
end

def random_enabled?
  $game_switches[RandomizedChallenge::Switch]
end

# BST máximo y mínimo de los Pokémon del Randomizado en base a cada medalla
# del jugador.
# Si necesitas más medallas o usar otro BST, puedes editarlo aquí.
def max_bst_cap
  max_caps = {
    1 => 400,
    2 => 440,
    3 => 480,
    4 => 520,
    5 => 560,
    6 => 600,
    7 => 800,
    8 => 800
  }
  min_key = max_caps.keys.min
  max_key = max_caps.keys.max
  # Si el jugador tiene menos medallas que las definidas en max_caps se devuelve el valor de la mas baja
  # Si el jugador tiene mas medallas que las definidas en max_caps se devuelve el valor de la mas alta
  $player.badge_count < min_key ? max_caps[min_key] : max_caps.fetch($player.badge_count, max_caps[max_key])
end

def min_bst_cap
  min_caps = {
    7 => 440,
    6 => 425,
    5 => 400,
    4 => 375,
    3 => 350
  }
  max_key = min_caps.keys.max
  # Si el jugador tiene mas medallas que las definidas en min_caps se devuelve el valor de la mas alta
  if $player.badge_count > max_key
    min_caps[max_key]
  else
    # 0 por defecto si hay menos de 3 medallas
    min_caps.fetch($player.badge_count, 0)
  end
end

def random_species
  species_num = rand(GameData::Species.species_count - 1) + 1
  count = 1
  GameData::Species.each_species do |species|
    return species if count == species_num

    count += 1
  end
end

def valid_pokemon?(species, ignore_bst = false)
  bst = species.base_stats.values.sum
  previous_species = GameData::Species.get(species.get_previous_species)
  species && !RandomizedChallenge::BLACKLISTED_POKEMON.include?(species.species) &&
    (ignore_bst || valid_bst?(bst)) && ($PokemonGlobal.random_gens.empty? || (!$PokemonGlobal.random_gens.empty? &&
                                                                                $PokemonGlobal.random_gens.include?(species.generation) &&
                                                                                 $PokemonGlobal.random_gens.include?(previous_species.generation)))
end

def valid_bst?(bst)
  return true unless $PokemonGlobal.progressive_random

  bst.between?(min_bst_cap, max_bst_cap)
end

class Pokemon
  alias randomized_init initialize

  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    if $game_switches && $game_switches[RandomizedChallenge::Switch]
      species = RandomizedChallenge::WHITELISTED_POKEMON.sample
      if RandomizedChallenge::WHITELISTED_POKEMON.empty?
        species = random_species
        $PokemonGlobal.random_gens = [] unless $PokemonGlobal.random_gens
        species = random_species until valid_pokemon?(species)
      end
    end
    randomized_init(species, level, owner, withMoves, recheck_form)
  end

  def random_types
    types = []
    current_types = GameData::Species.get(@species).types

    (0...current_types.length).each do |_|
      type = GameData::Type.keys[rand(GameData::Type.count - 1) + 1]
      next if RandomizedChallenge::INVALID_TYPES.include?(type) || types.include?(type)

      types << type
    end
    types
  end

  alias randomized_types types
  def types
    return randomized_types unless random_enabled? && random_types_on?

    unless $PokemonGlobal.random_types[@species]
      types = random_types
      $PokemonGlobal.random_types[@species] = types
    end

    $PokemonGlobal.random_types[@species]
  end

  def random_move
    move_num = rand(GameData::Move.count - 1) + 1
    count = 1
    GameData::Move.each do |move|
      return move if count == move_num

      count += 1
    end
  end

  alias random_getMoveList getMoveList
  def getMoveList
    moves = random_getMoveList
    if $game_switches && $game_switches[RandomizedChallenge::Switch]
      $PokemonGlobal.random_moves = {} unless $PokemonGlobal.random_moves
      return $PokemonGlobal.random_moves[@species] if $PokemonGlobal.random_moves[@species]

      $PokemonGlobal.random_moves[@species] = []

      moves.each do |item|
        level = item[0]
        move = random_move
        if $player.badge_count < 3
          movedata = GameData::Move.get(move.id)
          move_exists = $PokemonGlobal.random_moves[@species].detect { |elem| elem[1] == (move) }
          while movedata.power > 70 || RandomizedChallenge::MOVEBLACKLIST.include?(move) || move_exists
            move = random_move
            movedata = GameData::Move.get(move.id)
            move_exists = $PokemonGlobal.random_moves[@species].detect { |elem| elem[1] == (move) }
          end
        else
          # Usar blacklist en el recordador.
          move_exists = $PokemonGlobal.random_moves[@species].detect { |elem| elem[1] == (move) }
          while RandomizedChallenge::MOVEBLACKLIST.include?(move) || !move || move_exists
            move = random_move
            move_exists = $PokemonGlobal.random_moves[@species].detect { |elem| elem[1] == (move) }
          end
        end
        $PokemonGlobal.random_moves[@species].push([level, move])
      end
      
      moves = $PokemonGlobal.random_moves[@species]
    end
    moves
  end

  alias compatible_with_move_random? compatible_with_move?
  def compatible_with_move?(move_id)
    if ($game_switches && !$game_switches[RandomizedChallenge::Switch]) || !random_tm_compat_on?
      return compatible_with_move_random?(move_id)
    end

    # RAND Compatibility #TM
    $PokemonGlobal.tm_compatibility_random = {} unless $PokemonGlobal.tm_compatibility_random
    if $PokemonGlobal.tm_compatibility_random && $PokemonGlobal.tm_compatibility_random[species] && $PokemonGlobal.tm_compatibility_random[species].detect do |item|
         item[0] == move_id
       end
      $PokemonGlobal.tm_compatibility_random[species].any? { |item| item[0] == move_id && item[1] == true }
    elsif !$PokemonGlobal.tm_compatibility_random[species]
      $PokemonGlobal.tm_compatibility_random[species] = []
      if rand(2) == 1
        $PokemonGlobal.tm_compatibility_random[species].push([move_id, true])
        true
      else
        $PokemonGlobal.tm_compatibility_random[species].push([move_id, false])
        false
      end
    elsif rand(2) == 1
      $PokemonGlobal.tm_compatibility_random[species].push([move_id, true])
      true
    else
      $PokemonGlobal.tm_compatibility_random[species].push([move_id, false])
      false
    end
  end

  def get_random_evo(_current_species, new_species)
    species_list = []
    GameData::Species.each_species do |species|
      species_list.push(species)
    end
    # species_list.shuffle!
    return species_list.sample if !random_evolutions_similar_bst_on? && !do_random_evos_respect_restrictions?

    if random_evolutions_similar_bst_on?
      new_species_bst_min = GameData::Species.get(new_species).base_stats.values.sum * 0.9
      new_species_bst_max = GameData::Species.get(new_species).base_stats.values.sum * 1.1
      species_list.each do |species|
        species_bst = GameData::Species.get(species).base_stats.values.sum
        return species if valid_pokemon?(species, ignore_bst = true) && species_bst >= new_species_bst_min &&
                          species_bst <= new_species_bst_max
      end
    elsif do_random_evos_respect_restrictions?
      species_list.each do |species|
        return species if valid_pokemon?(species)
      end
    end
  end

  def check_evolution_internal
    return nil if egg? || shadowPokemon?
    return nil if hasItem?(:EVERSTONE)
    return nil if hasAbility?(:BATTLEBOND)

    species_data.get_evolutions(true).each do |evo| # [new_species, method, parameter, boolean]
      next if evo[3] # Prevolution

      random_evo = random_evolutions_on? ? get_random_evo(self, evo[0]) : evo[0]
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
    @pokemon.level = previous_level if random_evolutions_on? && @pokemon.level != previous_level
  end
end

# ********************************************************
# STARTERS RANDOMIZADOS CON DOS ETAPAS EVOLUTIVAS
# ********************************************************

def generate_random_starters
  starter_count = RandomizedChallenge::RANDOM_STARTER_VARIABLES.length || 3
  # Selecciona 3 iniciales unicos de la lista
  iniciales = RandomizedChallenge::RANDOM_STARTERS_LIST.sample(starter_count)

  # Asigna los iniciales a las variables
  RandomizedChallenge::RANDOM_STARTER_VARIABLES.each_with_index do |var, i|
    $game_variables[var] = iniciales[i]
  end
end
