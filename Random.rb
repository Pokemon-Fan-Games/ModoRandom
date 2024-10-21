################################################################################
# Randomized Pokemon Script
# por DPertierra
########################## You may edit any settings below this freely.#########
module RandomizedChallenge
  SWITCH = 409 # switch ID to randomize a pokemon, if it's on then ALL
  # pokemon will be randomized. No exceptions.

  BLACKLISTEDPOKEMON = []
  # Los Pokémon de la blacklist jamas saldran, ni en entrenadores ni como salvajes.
  # Ejemplo Blacklist
  # BLACKLISTEDPOKEMON = [PBSpecies::ARTICUNO,PBSpecies::MOLTRES, PBSpecies::ZAPDOS]

  WHITELISTEDPOKEMON = []
  # Leave this empty if all pokemon are allowed, otherwise only pokemon listed
  # above will be selected.

  # Lista de movimientos baneados para el random
  MOVEBLACKLIST = []

  # Lista de habilidades baneados para el random
  ABILITYBLACKLIST = []

  # LISTA DE STARTERS PARA EL RANDOM
  # RANDOM_STARTER_LIST = [
  #   PBSpecies::BULBASAUR,
  #   PBSpecies::CHARMANDER,
  #   PBSpecies::SQUIRTLE
  # ]
  RANDOM_STARTER_LIST = [
    PBSpecies::BULBASAUR,
    PBSpecies::CHARMANDER,
    PBSpecies::SQUIRTLE,
    PBSpecies::PIDGEY,
    PBSpecies::NIDORANmA,
    PBSpecies::NIDORANfE,
    PBSpecies::ZUBAT,
    PBSpecies::MANKEY,
    PBSpecies::POLIWAG,
    PBSpecies::ABRA,
    PBSpecies::MACHOP,
    PBSpecies::BELLSPROUT,
    PBSpecies::GEODUDE,
    PBSpecies::MAGNEMITE,
    PBSpecies::GASTLY,
    PBSpecies::RHYHORN,
    PBSpecies::HORSEA,
    PBSpecies::ELEKID,
    PBSpecies::MAGBY,
    PBSpecies::PORYGON,
    PBSpecies::ODDISH,
    PBSpecies::DRATINI,
    PBSpecies::CHIKORITA,
    PBSpecies::CYNDAQUIL,
    PBSpecies::TOTODILE,
    PBSpecies::MAREEP,
    PBSpecies::HOPPIP,
    PBSpecies::SWINUB,
    PBSpecies::TEDDIURSA,
    PBSpecies::LARVITAR,
    PBSpecies::TREECKO,
    PBSpecies::TORCHIC,
    PBSpecies::MUDKIP,
    PBSpecies::LOTAD,
    PBSpecies::SEEDOT,
    PBSpecies::RALTS,
    PBSpecies::ARON,
    PBSpecies::BUDEW,
    PBSpecies::TRAPINCH,
    PBSpecies::DUSKULL,
    PBSpecies::SHUPPET,
    PBSpecies::BAGON,
    PBSpecies::BELDUM,
    PBSpecies::SPHEAL,
    PBSpecies::TURTWIG,
    PBSpecies::CHIMCHAR,
    PBSpecies::PIPLUP,
    PBSpecies::STARLY,
    PBSpecies::SHINX,
    PBSpecies::GIBLE,
    PBSpecies::SNIVY,
    PBSpecies::TEPIG,
    PBSpecies::OSHAWOTT,
    PBSpecies::LILLIPUP,
    PBSpecies::SEWADDLE,
    PBSpecies::VENIPEDE,
    PBSpecies::ROGGENROLA,
    PBSpecies::TIMBURR,
    PBSpecies::SOLOSIS,
    PBSpecies::GOTHITA,
    PBSpecies::SANDILE,
    PBSpecies::VANILLITE,
    PBSpecies::KLINK,
    PBSpecies::TYNAMO,
    PBSpecies::LITWICK,
    PBSpecies::AXEW,
    PBSpecies::DEINO,
    PBSpecies::PAWNIARD,
    PBSpecies::CHESPIN,
    PBSpecies::FENNEKIN,
    PBSpecies::FROAKIE,
    PBSpecies::FLETCHLING,
    PBSpecies::FLABEBE,
    PBSpecies::GOOMY,
    PBSpecies::HONEDGE,
    PBSpecies::ROWLET,
    PBSpecies::LITTEN,
    PBSpecies::POPPLIO,
    PBSpecies::GRUBBIN,
    PBSpecies::JANGMOO,
    PBSpecies::GROOKEY,
    PBSpecies::SCORBUNNY,
    PBSpecies::SOBBLE,
    PBSpecies::ROLYCOLY,
    PBSpecies::BLIPBUG,
    PBSpecies::ROOKIDEE,
    PBSpecies::HATENNA,
    PBSpecies::IMPIDIMP,
    PBSpecies::DREEPY,
    PBSpecies::SPRIGATITO,
    PBSpecies::FUECOCO,
    PBSpecies::QUAXLY,
    PBSpecies::PAWMI,
    PBSpecies::SMOLIV,
    PBSpecies::NACLI,
    PBSpecies::TINKATINK,
    PBSpecies::FRIGIBAX
  ]

  # Ingrese las variables en las que se guardaran lo inciales random, luego deberá utilizar esta variable
  # para el evento de elección de iniciales.
  STATERS_VARIABLES = [803, 804, 805]

  # Es rango de numero de pokedex para cada generación
  MAX_NUM_GEN = { 1 => [1, 151], 2 => [152, 251], 3 => [252, 386], 4 => [387, 494],
                  5 => [495, 649], 6 => [650, 721], 7 => [722, 809], 8 => [810, 905],
                  9 => [906, 1025] }

  # Este flag decide que las habilidades sean random para cada especie
  # Ejemplo Pikachu tendra Intimidacion y Cura Natural
  # Pero Raichu podria tener otras distintas como Absorbe agua y levitacion
  FULL_RANDOM_ABS = true

  # Este flag decide que las habilidades sean un mapeo de una a otra
  # Ejemplo Intimidacion se convierte en Inicio Lento
  # Lo que no significa que Inicio Lento se convierta en Intimidacion
  # Si la variable FULL_RANDOM_ABS esta en true esa sera la opcion determinada
  MAP_RANDOM_ABS = false

  # Si ambas variables estan en false no se randomizaran las habilidades
  # Se puede cambiar el metodo de randomizado de habilidades
  # llamando al metodo choose_random_ability_mode a este metodo hay que pasarle el modo
  # Para el mapeo hay que pasarle :MAP_RANDOM_ABS, asi choose_random_ability_mode(:MAP_RANDOM_ABS)
  # Para el modo full random hay que pasarle :FULL_RANDOM_ABS, asi choose_random_ability_mode(:FULL_RANDOM_ABS)
  # Tengan en cuenta que el llamado a este método volverá a randomizar las habilidades
  # Y las antiguas no podrán ser recuperadas.

  # Si normalmente una forma alterna tiene un set de habilidades
  # distinto al de la forma normal, en el random tambien tendrá un set distinto
  DIFFERENT_FORMS_HAVE_DIFFERENT_ABILITIES = true

  # Este flag decide que el BST de los pokemon sea progresivo, es decir si el flag está en true
  # no podran salir pokemon con un BST mayor al que se define en la funcion max_bst_cap
  # Siempre se podra modificar esto llamando al metodo toggle_progressive_random
  PROGRESSIVE_RANDOM_DEFAULT_VALUE = true

  # Movimientos randomizados
  # Si quieres que los movimientos esten randomizados por defecto pon esta constante en true
  # Siempre se podra modificar esto llamando al metodo toggle_random_moves
  RANDOM_MOVES_DEFAULT_VALUE = true

  # Distintos sets para distintas formas
  # Si una forma alterna tiene un movepool distinto a la original
  # En el random también tendran movesets distintos
  DIFFERENT_FORMS_HAVE_DIFFERENT_MOVEPOOLS = true


  # Randomizar compatibilidad con las MTs
  # Se podrá cambiar llamando al metodo toggle_tm_compat
  # Tengan en cuenta que de esa forma un jugador podria armarse el moveset como quiera
  # Activando y desactivando esta opción
  RANDOM_TM_COMPAT_DEFAULT_VALUE = true

  # Randomizar evoluciones de los pokemones
  # Se podrá cambiar llamando al metodo toggle_random_evos
  RANDOM_EVOS_DEFAULT_VALUE = false

  # Randomizar evoluciones de los pokemones a otro con BST similares
  # Por ejemplo un Pichu no podra evolucionar a un Slaking
  # Se podrá cambiar llamando al metodo toggle_random_evos_similar_bst
  RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE = true

  # Esto es el margen de diferencia de los BST para las evos random, actualmente es un 10%
  # Si quisieran cambiarlo a un 20% hay que cambiarlo a 0.2
  EVO_BST_MARGIN = 0.1

  # Valor por defecto para randomizar los tipos
  # Se puede activar y desactivar el randomizado de tipos llamando al método toggle_random_types
  RANDOM_TYPES_DEFAULT_VALUE = false

  # Lista de tipos invalidos para randomizar
  # El tipo QMARKS es para los pokemones que no tienen tipos
  INVALID_TYPES = [PBTypes::QMARKS]

  # Randomizar forma de los pokémon
  # No podrán salir formas megas ni primigenias, pero si no tienen bien
  # hecha la logica de los MultipleForms se pueden dar cosas raras
  # La unica forma alterna que podra salir es la forma 1
  ENABLE_RANDOM_FORM = true

  ### MEGA STONES for each pokemon
  MEGAS_RANDOMIZE_TO_MEGAS = true
  # Para que esto funciona se debe mantener el hash de abajo con la relacion
  # entre las especies y su mega piedra, si el pokemon tiene mas de 1 forma mega
  # con distintas megapiedras, como el caso de Charizard, se deben mantener los
  # items en un array, dejo un ejemplo del hash.

  # NO OLVIDEN ELIMINAR LOS # que comentan el hash
  # POKEMON_MEGA_STONES = {
  #  PBSpecies::VENUSAUR    => PBItems::VENUSAURITE,
  #  PBSpecies::CHARIZARD   => [PBItems::CHARIZARDITEX, PBItems::CHARIZARDITEY],
  # }

  # Lista de entrenadores que no se randomizarán
  # solo se randomizarán las habilidades
  # El listado debe contener el trainer.id
  UNRANDOMIZABLE_TRAINERS = []

  # Lista de entrenadores y pokemon especificos que no se randomizarán
  # Es un hash que debe ser trainer.id => { partyid => [PBSpecies::ESPECIE1, PBSpecies::ESPECIE2] }
  UNRANDOMIZABLE_TRAINER_POKEMON = {
    # PBTrainers::LIDER1 => { 1 => [PBSpecies::LEDIAN] },
  }

  # Mantener encuentros de rutas
  KEEP_SAME_WILD_IN_ROUTES = true

  # Mostrar los encuentros random en el DexNav
  # Solo funciona cuando el KEEP_SAME_WILD_IN_ROUTES está en true
  SHOW_ENCOUNTERS_IN_DEXNAV = true

  # En este hash hay que mantener el nivel maximo de cada lider.
  # El valor de la izquierda es la medalla y el de la derecha el nivel
  # BADGES_MAX_LEVELS = {
  #   0 => LEVELGYM0,
  #   1 => LEVELGYM1,
  #   2 => LEVELGYM2,
  #   3 => LEVELGYM3,
  #   4 => LEVELGYM4,
  #   5 => LEVELGYM5,
  #   6 => LEVELGYM6,
  #   7 => LEVELGYM7,
  #   8 => LEVELGYM8,
  #   9 => LEVELGYM9
  # }

  # Definir los pokemon que tienen posibles formas alternas
  POKEMON_WITH_FORMS = {
    PBSpecies::RAPIDASH => [0, 1],
    PBSpecies::TYPHLOSION => [0, 1],
    PBSpecies::DEOXYS => [0, 1, 2, 3],
    PBSpecies::MRMIME => [0, 1],
    PBSpecies::SHAYMIN => [0, 1],
    PBSpecies::BASCULIN => [0, 1, 2],
    PBSpecies::AVALUGG => [0, 1],
    PBSpecies::DECIDUEYE => [0, 1],
    PBSpecies::SAMUROTT => [0, 1],
    PBSpecies::GOODRA => [0, 1],
    PBSpecies::STUNFISK => [0, 1],
    PBSpecies::SLOWKING => [0, 1],
    PBSpecies::SLOWBRO => [0, 1],
    PBSpecies::SANDSLASH => [0, 1],
    PBSpecies::NINETALES => [0, 1],
    PBSpecies::ARCANINE => [0, 1],
    PBSpecies::ELECTRODE => [0, 1],
    PBSpecies::LILLIGANT => [0, 1],
    PBSpecies::GOLEM => [0, 1],
    PBSpecies::MUK => [0, 1],
    PBSpecies::EXEGGUTOR => [0, 1],
    PBSpecies::MAROWAK => [0, 1],
    PBSpecies::WEEZING => [0, 1],
    PBSpecies::TORNADUS => [0, 1],
    PBSpecies::THUNDURUS => [0, 1],
    PBSpecies::LANDORUS => [0, 1],
    PBSpecies::KYUREM => [0, 1, 2],
    PBSpecies::MELOETTA => [0, 1],
    PBSpecies::MEOWSTIC => [0, 1, 2],
    PBSpecies::AEGISLASH => [0, 1],
    PBSpecies::DUGTRIO => [0, 1],
    PBSpecies::BRAVIARY => [0, 1],
    PBSpecies::DONPHAN => [0, 1],
    PBSpecies::ZOROARK => [0, 1],
    PBSpecies::TAUROS => [0, 1],
    PBSpecies::DELIBIRD => [0, 1],
    PBSpecies::MAGNEZONE => [0, 1],
    PBSpecies::VOLCARONA => [0, 1],
    PBSpecies::HARIYAMA => [0, 1],
    PBSpecies::TENTACRUEL => [0, 1],
    PBSpecies::PERSIAN => [0, 1],
    PBSpecies::RATICATE => [0, 1],
    PBSpecies::ARTICUNO => [0, 1],
    PBSpecies::ZAPDOS => [0, 1],
    PBSpecies::MOLTRES => [0, 1]
  }
  # Si se revive el mismo fossil mas de 1 vez siempre dará el mismo Pokémon
  KEEP_SAME_FOSSIL_POKEMON = true

  # Salvajes a los que no se les randomizan los objetos
  # SPECIES_UNRAN_HELD_ITEMS = [PBSpecies::PARAS]
  SPECIES_UNRAN_HELD_ITEMS = []
end

class PokemonGlobalMetadata
  attr_accessor :tm_compatibility_random, :random_gens,
                :valid_num_ranges, :random_abs_pokemon, :ability_hash,
                :random_moves, :enable_random_moves, :random_ability_mode,
                :progressive_random, :enable_random_tm_compat, :random_evos, :random_evos_similar_bst,
                :enable_random_types, :random_types, :given_tm_moves,
                :last_used_id, :random_abs_pokes, :random_encounter_table,
                :wild_paused, :dont_randomize, :wild_held_items,
                :reviving_fossil, :fossil_species, :pause_random_species
  alias random_abil_init initialize
  def initialize
    random_abil_init
    @ability_hash = nil
    @given_tm_moves = []
  end
end

def random_moves_on?
  random_enabled? && $PokemonGlobal.enable_random_moves ? true : false
end

def toggle_random_moves
  if $PokemonGlobal.enable_random_moves.nil?
    $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
  end
  $PokemonGlobal.enable_random_moves = !$PokemonGlobal.enable_random_moves
end

def progressive_random_on?
  random_enabled? && $PokemonGlobal.progressive_random ? true : false
end

def toggle_progressive_random
  $PokemonGlobal.progressive_random = !$PokemonGlobal.progressive_random
end

def random_tm_compat_on?
  random_enabled? && $PokemonGlobal.enable_random_tm_compat ? true : false
end

def toggle_random_tm_compat
  $PokemonGlobal.enable_random_tm_compat = !$PokemonGlobal.enable_random_tm_compat
end

def random_evos_on?
  random_enabled? && $PokemonGlobal.random_evos ? true : false
end

def toggle_random_evos
  $PokemonGlobal.random_evos = RandomizedChallenge::RANDOM_EVOS_DEFAULT_VALUE if $PokemonGlobal.random_evos.nil?
  $PokemonGlobal.random_evos = !$PokemonGlobal.random_evos
end

def random_evos_similar_bst_on?
  random_enabled? && $PokemonGlobal.random_evos_similar_bst ? true : false
end

def toggle_random_evos_similar_bst
  if $PokemonGlobal.random_evos_similar_bst.nil?
    $PokemonGlobal.random_evos_similar_bst = RandomizedChallenge::RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE
  end
  $PokemonGlobal.random_evos_similar_bst = !$PokemonGlobal.random_evos_similar_bst
end

def show_ability_mode_options
  return unless random_enabled?

  commands = case $PokemonGlobal.random_ability_mode
             when :FULL_RANDOM_ABS
               [_INTL('[X] Full Random'), _INTL('[ ] Mapeo de habilidades'), _INTL('[ ] Sin randomizar')]
             when :MAP_RANDOM_ABS
               [_INTL('[ ] Full Random'), _INTL('[X] Mapeo de habilidades'), _INTL('[ ] Sin randomizar')]
             when :NO_RANDOM
               [_INTL('[ ] Full Random'), _INTL('[ ] Mapeo de habilidades'), _INTL('[X] Sin randomizar')]
             end

  ret = Kernel.pbMessage(_INTL('Elija el modo para las habilidades random'), commands, -1)

  case ret
  when 0
    choose_random_ability_mode(:FULL_RANDOM_ABS)
  when 1
    choose_random_ability_mode(:MAP_RANDOM_ABS)
  when 2
    choose_random_ability_mode(:NO_RANDOM)
  end
end

def choose_random_ability_mode(mode = :FULL_RANDOM_ABS)
  return if $PokemonGlobal.random_ability_mode == mode

  $PokemonGlobal.random_ability_mode = mode
  reset_abilities
end

def get_random_gens
  $PokemonGlobal.random_gens || []
end

def random_gens_choice_array
  choice_array = []
  random_gens = get_random_gens
  (1..RandomizedChallenge::MAX_NUM_GEN.length).each do |i|
    choice_array.push(random_gens.include?(i) ? "[X] Gen #{i}" : "[  ] Gen #{i}")
  end
  choice_array.push(_INTL('Terminar'))
  choice_array
end

def show_config_options
  text = _INTL('Configurar random')
  ret = Kernel.pbMessage(text, config_options, -1)
  change_config(ret) if ret != -1
  ret
end

def config_options
  return unless random_enabled?

  commands = []

  commands.push(_INTL('Elegir modo de randomizar habilidades'))

  progressive_random_on? ? commands.push(_INTL('[X] Random progresivo')) : commands.push(_INTL('[  ] Random progresivo'))

  random_moves_on? ? commands.push(_INTL('[X] Movimientos random')) : commands.push(_INTL('[  ] Movimientos random'))

  random_evos_on? ? commands.push(_INTL('[X] Evoluciones random')) : commands.push(_INTL('[  ] Evoluciones random'))

  random_evos_similar_bst_on? ? commands.push(_INTL('[X] Evoluciones random con BST similar')) : commands.push(_INTL('[  ] Evoluciones random con BST similar'))

  random_tm_compat_on? ? commands.push(_INTL('[X] Randomizar compatibilidad con MTs')) : commands.push(_INTL('[  ] Randomizar compatibilidad con MTs'))

  random_types_enabled? ? commands.push(_INTL('[X] Randomizar tipos')) : commands.push(_INTL('[  ] Randomizar tipos'))

  random_items_enabled? ? commands.push(_INTL('[X] Randomizar objetos')) : commands.push(_INTL('[  ] Randomizar objetos'))

  random_held_items_enabled? ? commands.push(_INTL('[X] Randomizar objetos de salvajes')) : commands.push(_INTL('[  ] Randomizar objetos de salvajes'))

  commands
end

def change_config(index)
  case index
  when 0
    show_ability_mode_options
  when 1
    toggle_progressive_random
  when 2
    toggle_random_moves
  when 3
    toggle_random_evos
  when 4
    toggle_random_evos_similar_bst
  when 5
    toggle_random_tm_compat
  when 6
    toggle_random_types
  when 7
    toggle_random_items
  when 8
    toggle_random_held_items
  end
end

def show_gens_chooser
  text = _INTL('Elige las generaciones para el random')
  gens = random_gens_choice_array
  gen = Kernel.pbMessage(text, gens, -1)
  add_or_remove_random_gen(gen)
  gen
end

def add_or_remove_random_gen(gen = nil)
  return if !gen || gen < 0 || gen + 1 > RandomizedChallenge::MAX_NUM_GEN.length

  gen += 1

  $PokemonGlobal.random_gens = [] unless $PokemonGlobal.random_gens
  if !$PokemonGlobal.random_gens.include?(gen)
    $PokemonGlobal.random_gens.push(gen)
  else
    $PokemonGlobal.random_gens.delete(gen)
  end
end

def enable_random
  return unless $game_switches

  reset_abilities
  if $PokemonGlobal.enable_random_moves.nil?
    $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
  end
  unless $PokemonGlobal.random_ability_mode
    $PokemonGlobal.random_ability_mode = if RandomizedChallenge::FULL_RANDOM_ABS
                                           :FULL_RANDOM_ABS
                                         elsif RandomizedChallenge::MAP_RANDOM_ABS
                                           :MAP_RANDOM_ABS
                                         else
                                           :NO_RANDOM
                                         end
  end
  if $PokemonGlobal.progressive_random.nil?
    $PokemonGlobal.progressive_random = RandomizedChallenge::PROGRESSIVE_RANDOM_DEFAULT_VALUE
  end
  $PokemonGlobal.enable_random_tm_compat = RandomizedChallenge::RANDOM_TM_COMPAT_DEFAULT_VALUE
  $PokemonGlobal.random_evos = RandomizedChallenge::RANDOM_EVOS_DEFAULT_VALUE
  $PokemonGlobal.random_evos_similar_bst = RandomizedChallenge::RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE
  $PokemonGlobal.enable_random_types = RandomizedChallenge::RANDOM_TYPES_DEFAULT_VALUE
  $PokemonGlobal.random_types = {}
  $PokemonGlobal.given_tm_moves = []
  $PokemonGlobal.wild_paused = false
  $PokemonGlobal.dont_randomize = []
  $PokemonGlobal.wild_held_items = {}
  $PokemonGlobal.pause_random_species = false
  generate_random_starters
  toggle_random_items
  $game_switches[RandomizedChallenge::SWITCH] = true
end

def pokemon_in_gen_range?(species)
  return true unless $PokemonGlobal.random_gens

  $PokemonGlobal.random_gens.each do |gen|
    next unless species.between?(RandomizedChallenge::MAX_NUM_GEN[gen][0], RandomizedChallenge::MAX_NUM_GEN[gen][1])

    return true
  end
  false
end

def toggle_random_types
  $PokemonGlobal.enable_random_types = !$PokemonGlobal.enable_random_types
end

def random_types_enabled?
  $PokemonGlobal.enable_random_types ? true : false
end

# AQUI SE DEFINE EL BST QUE VAN A TENER LOS POKEMON EN EL RANDOMIZADO.
# SEGÚN CADA CANTIDAD DE MEDALLAS, PONER EN LOS RETURN EL BST QUE TENDRÁN
# LOS POKÉMON.
# SI LA CANTIDAD DE MEDALLAS ES MAYOR A LA MAYOR DEL LISTADO DE max_caps, SE DEVUELVE EL BST MAS ALTO
def max_bst_cap(badges = nil)
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

  # Si la cantidad de medallas es menor que la menor clave de max_caps, se devuelve el valor de la clave mas baja.
  # Si la cantidad de medallas es mayor a la clave mas alta de max_caps, se devuelve el valor de la clave mas alta.
  # De esta forma se evitan duplicar claves para medallas con el mismo BST
  badge_count = $Trainer.numbadges
  badge_count = badges if badges
  if badge_count < min_key
    max_caps[min_key]
  else
    max_caps.fetch(badge_count, max_caps[max_key])
  end
end

def min_bst_cap(badges = nil)
  min_caps = {
    7 => 440,
    6 => 425,
    5 => 400,
    4 => 375,
    3 => 350
  }
  max_key = min_caps.keys.max

  # Si la cantidad de medallas es mayor que la mayor clave de min_caps, se devuelve el valor de la clave mas alta.
  # Si la cantidad de medallas es menor a la clave mas baja de min_caps, se devuelve el 0
  badge_count = $Trainer.numbadges
  badge_count = badges if badges
  if badge_count > max_key
    min_caps[max_key]
  else
    min_caps.fetch(badge_count, 0)
  end
end

def not_in_allowed_bst_range?(bst, badges = nil)
  return false unless $PokemonGlobal.progressive_random

  min_cap = min_bst_cap(badges)
  max_cap = max_bst_cap(badges)
  !bst.between?(min_cap, max_cap)
end

def pause_random
  $game_switches[RandomizedChallenge::SWITCH] = false
end

def pause_wild_species
  $PokemonGlobal.wild_paused = true
end

def resume_wild_species
  $PokemonGlobal.wild_paused = false
end

def wild_paused?
  $PokemonGlobal.wild_paused ? true : false
end

def pause_random_species
  $PokemonGlobal.pause_random_species = true
end

def resume_random_species
  $PokemonGlobal.pause_random_species = false
end

def random_species_paused?
  $PokemonGlobal.pause_random_species ? true : false
end

def resume_random
  $game_switches[RandomizedChallenge::SWITCH] = true
end

def invalid_species?(species, bst, evo = false, evo_bst_range = [], previous_species = nil, badges = nil)
  blacklisted = RandomizedChallenge::BLACKLISTEDPOKEMON.include?(species)
  not_in_bst_range = not_in_allowed_bst_range?(bst, badges)
  not_in_gen_range = $PokemonGlobal.random_gens.length > 0 && !pokemon_in_gen_range?(species) && !pokemon_in_gen_range?(previous_species)
  not_in_evo_bst_range = evo && evo_bst_range.length > 0 && !bst.between?(
    evo_bst_range[0], evo_bst_range[1]
  )

  blacklisted || not_in_bst_range || not_in_gen_range || not_in_evo_bst_range
end

def random_species(evo = false, evo_bst_range = [], badges = nil)
  if RandomizedChallenge::WHITELISTEDPOKEMON.empty?
    species = rand(PBSpecies.maxValue - 1) + 1
    bst = bst_sum(species)
    previous_species = pbGetPreviousForm(species)
    $PokemonGlobal.random_gens = [] unless $PokemonGlobal.random_gens
    while invalid_species?(species, bst, evo, evo_bst_range, previous_species, badges)
      species = rand(PBSpecies.maxValue - 1) + 1
      previous_species = pbGetPreviousForm(species)
      bst = bst_sum(species)
    end
  else
    species = RandomizedChallenge::WHITELISTEDPOKEMON.sample
  end
  species
end

def random_enabled?
  $game_switches && $game_switches[RandomizedChallenge::SWITCH] ? true : false
end

def random_evo(_current_pokemon, expected_evo)
  if random_evos_similar_bst_on?
    min_bst = bst_sum(expected_evo) * (1 - RandomizedChallenge::EVO_BST_MARGIN)
    max_bst = bst_sum(expected_evo) * (1 + RandomizedChallenge::EVO_BST_MARGIN)
    evo_bst_range = [min_bst, max_bst]
  else
    evo_bst_range = []
  end
  random_species(true, evo_bst_range)
end

def reset_abilities
  $PokemonGlobal.random_abs_pokemon.clear if $PokemonGlobal.random_abs_pokemon
  $PokemonGlobal.ability_hash.clear if $PokemonGlobal.ability_hash
  create_ability_hash if $PokemonGlobal.random_ability_mode == :MAP_RANDOM_ABS
end

def bst_sum(species)
  dexdata = pbOpenDexData
  pbDexDataOffset(dexdata, species, 10)
  ret = [
    dexdata.fgetb, # PS
    dexdata.fgetb, # Ataque
    dexdata.fgetb, # Defensa
    dexdata.fgetb, # Velocidad
    dexdata.fgetb, # Ataque Especial
    dexdata.fgetb  # Defensa Especial
  ]
  dexdata.close
  bst = 0
  (0..5).each do |i|
    bst += ret[i]
  end
  bst
end

def check_tm_move_in_bag(move)
  $PokemonBag.pockets[4].each do |item|
    next unless pbIsTechnicalMachine?(item[0])

    machine = $ItemData[item[0]][ITEMMACHINE]
    moveid = getID(PBMoves, machine)
    return true if moveid == move
  end
  false
end

def invalid_move?(progressive, move, move_exists = false, power = 0, types = [], for_tm = false)
  movedata = PBMoveData.new(move)
  return true if !movedata || !movedata.totalpp || !PBMoves.getName(move.id) || PBMoves.getName(move.id) == ''

  given_tm = for_tm && RandomizedChallenge::RANDOMIZE_TM_MOVES && $PokemonGlobal.given_tm_moves.include?(move) && check_tm_move_in_bag(move)
  (progressive && power > 0 && movedata.basedamage > power) || (!types.empty? && !types.include?(movedata.type)) || RandomizedChallenge::MOVEBLACKLIST.include?(move) || move_exists || given_tm ? true : false
end

def find_valid_move(progressive = false, power = 0, types = [], for_tm = false, movelist = nil)
  move = rand(PBMoves.maxValue - 1) + 1
  movelist_aux = if for_tm
               nil
             else
               $PokemonGlobal.random_moves ? $PokemonGlobal.random_moves[@species] : nil
             end
  movelist_aux = movelist if movelist
  move_exists = movelist_aux ? movelist_aux.detect { |elem| elem[1] == (move) } : false
  while invalid_move?(progressive, move, move_exists, power, types, for_tm)
    move = rand(PBMoves.maxValue - 1) + 1
    move_exists = movelist_aux ? movelist_aux.detect { |elem| elem[1] == (move) } : false
  end
  move
end

def reviving_fossil(fossil)
  $PokemonGlobal.reviving_fossil = fossil
end

class PokeBattle_Pokemon
  attr_accessor :id

  def setPlayer(player)
    @trainerID = player.id
    @ot = player.name
    @otgender = player.gender
    @language = player.language
  end

  def reset_form?(poke = self)
    return RandomizedChallenge::POKEMON_WITH_FORMS[@species] ? false : true
    has_mega_form = MultipleForms.hasFunction?(poke, 'getMegaForm')
    has_primal_form = MultipleForms.hasFunction?(poke, 'getPrimalForm')
    on_set_form = MultipleForms.hasFunction?(poke, 'onSetForm')
    has_mega_form || has_primal_form || on_set_form ? true : false
  end

  def random_form
    return 0 if reset_form?

    return RandomizedChallenge::POKEMON_WITH_FORMS[@species][rand(RandomizedChallenge::POKEMON_WITH_FORMS[@species].length)] || 0

    form = rand(2)
    return form if form == 0

    evos = get_evos(@species)
    if evos
      pause_random
      evos.each do |evo|
        new_poke = PokeBattle_Pokemon.new(evo, 5)
        if reset_form?(new_poke)
          form = 0
          break
        end
      end
      resume_random
    end
    form
  end

  # Creación de un objeto Pokémon nuevo.
  #    species   - Especie del Pokémon.
  #    level     - Nivel del Pokémon.
  #    player    - Objeto PokeBattle_Trainer para el entrenador original.
  #    withMoves - Si está en false, este Pokémon no tendrá movimientos.
  alias randomized_init initialize
  def initialize(species, level, player = nil, withMoves = true)
    return randomized_init(species, level, player, withMoves) unless random_enabled?

    species = random_species unless wild_paused? || random_species_paused?
    species = getID(PBSpecies, species) if species.is_a?(String) || species.is_a?(Symbol)

    if RandomizedChallenge::KEEP_SAME_FOSSIL_POKEMON && $PokemonGlobal.reviving_fossil
      if $PokemonGlobal.fossil_species && $PokemonGlobal.fossil_species[$PokemonGlobal.reviving_fossil]
        species = $PokemonGlobal.fossil_species[$PokemonGlobal.reviving_fossil]
        species = getID(PBSpecies, species) if species.is_a?(String) || species.is_a?(Symbol)
      else
        $PokemonGlobal.fossil_species ||= {}
        $PokemonGlobal.fossil_species[$PokemonGlobal.reviving_fossil] = species
      end
      $PokemonGlobal.reviving_fossil = nil
    end

    cname = begin
      getConstantName(PBSpecies, species)
    rescue StandardError
      nil
    end
    if !species || species < 1 || species > PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL('El número de especie (núm. {1} de {2}) no es válido.',
                                    species, PBSpecies.maxValue))
      return nil
    end
    time = pbGetTimeNow
    @timeReceived = time.getgm.to_i # Usa GMT
    @species = species
    # IVs (Valores Individuales)
    @personalID = rand(256)
    @personalID |= rand(256) << 8
    @personalID |= rand(256) << 16
    @personalID |= rand(256) << 24
    @hp = 1
    @totalhp = 1
    @ev = [0, 0, 0, 0, 0, 0]
    @iv = []
    @iv[0] = rand(32)
    @iv[1] = rand(32)
    @iv[2] = rand(32)
    @iv[3] = rand(32)
    @iv[4] = rand(32)
    @iv[5] = rand(32)
    expshare = false
    if player
      @trainerID = player.id
      @ot = player.name
      @otgender = player.gender
      @language = player.language
    else
      @trainerID = 0
      @ot = ''
      @otgender = 2
    end
    dexdata = pbOpenDexData
    pbDexDataOffset(dexdata, @species, 19)
    @happiness = dexdata.fgetb
    dexdata.close
    @name = PBSpecies.getName(@species)
    @eggsteps = 0
    @status = 0
    @statusCount = 0
    @item = 0
    @mail = nil
    @fused = nil
    @ribbons = []
    @moves = []
    self.ballused = 0
    self.level = level
    self.form = random_form if RandomizedChallenge::ENABLE_RANDOM_FORM
    calcStats
    @hp = @totalhp
    if $game_map
      @obtainMap = $game_map.map_id
      @obtainText = nil
      @obtainLevel = level
    else
      @obtainMap = 0
      @obtainText = nil
      @obtainLevel = level
    end
    @obtainMode = 0 # Encuentro
    @obtainMode = 4 if $game_switches && $game_switches[FATEFUL_ENCOUNTER_SWITCH]
    @hatchedMap = 0
    if withMoves
      atkdata = pbRgssOpen('Data/attacksRS.dat', 'rb')
      offset = atkdata.getOffset(species - 1)
      length = atkdata.getLength(species - 1) >> 1
      atkdata.pos = offset
      # Genera lista de movimientos
      movelist = []
      if $PokemonGlobal.enable_random_moves
        while movelist.length < 4
          move = rand(PBMoves.maxValue - 1) + 1
          # movedata = PBMoveData.new(move)
          if $Trainer.numbadges < 3 && $PokemonGlobal.progressive_random
            next if invalid_move?(progressive_random_on?, move, false, 70)
            # next if !move || movedata.basedamage > 70 || RandomizedChallenge::MOVEBLACKLIST.include?(move)
          elsif !move || RandomizedChallenge::MOVEBLACKLIST.include?(move)
            next
          end
          movedata = PBMove.new(move)
          movename = PBMoves.getName(move)
          next if !movedata || !movedata.totalpp || !movename || movename == ''

          movelist.push(move)
          movelist |= [] # Elimina duplicados
        end
      # FIN generación de movimientos random
      else
        (0..length - 1).each do
          alevel = atkdata.fgetw
          move = atkdata.fgetw
          movelist[movelist.length] = move if alevel <= level
        end
      end
      atkdata.close
      movelist |= [] # Elimina duplicados

      # Se usan los últimos 4 elementos en la lista de movimientos
      listend = movelist.length - 4
      listend = 0 if listend < 0
      j = 0
      (listend...listend + 4).each do |i|
        moveid = i >= movelist.length ? 0 : movelist[i]
        @moves[j] = PBMove.new(moveid)
        j += 1
      end
    else
      (0...4).each do |i|
        @moves[i] = PBMove.new(0)
      end
    end
  end

  alias wildHoldItems_random wildHoldItems
  def wildHoldItems
    return wildHoldItems_random unless random_held_items_enabled? #|| RandomizedChallenge::SPECIES_UNRAN_HELD_ITEMS.include?(@species)
    if $PokemonGlobal.wild_held_items && $PokemonGlobal.wild_held_items[@species]
      return $PokemonGlobal.wild_held_items[@species]
    end

    held_items = wildHoldItems_random
    held_items.map! do |item|
      item = RandomizedChallenge.held_item if item > 0
      item
    end
    $PokemonGlobal.wild_held_items ||= {}
    $PokemonGlobal.wild_held_items[@species] = held_items
    held_items
  end

  alias type1_random type1
  alias type2_random type2

  def type1
    return type1_random unless random_enabled? && random_types_enabled?

    # Ensure that a random type is generated and stored if it doesn't exist
    unless $PokemonGlobal.random_types[@species]
      random_type1 = rand(PBTypes.maxValue - 1) + 1 while RandomizedChallenge::INVALID_TYPES.include?(random_type1)
      $PokemonGlobal.random_types[@species] = [random_type1]
    end

    $PokemonGlobal.random_types[@species][0]
  end

  def type2
    return type2_random unless random_enabled? && random_types_enabled?

    # Ensure that the second type is set, either the same as type1 or different
    stored_types = $PokemonGlobal.random_types[@species]
    if stored_types.nil? || stored_types.length < 2
      # Fetch or generate type1 to ensure it's in the stored_types
      type1_random = type1

      # If type1 and type2 are originally the same, keep them the same
      if type2_random == type1_random
        $PokemonGlobal.random_types[@species].push(type1_random)
      else
        random_type2 = rand(PBTypes.maxValue - 1) + 1 while RandomizedChallenge::INVALID_TYPES.include?(random_type2)
        $PokemonGlobal.random_types[@species].push(random_type2)
      end
    end

    $PokemonGlobal.random_types[@species][1]
  end

  def isCompatibleWithMove?(move)
    return pbSpeciesCompatible?(species, move) unless random_enabled? && random_tm_compat_on?

    # RAND TM
    $PokemonGlobal.tm_compatibility_random = {} unless $PokemonGlobal.tm_compatibility_random
    $PokemonGlobal.tm_compatibility_random[species] = [] unless $PokemonGlobal.tm_compatibility_random[species]
    species_compatibility = $PokemonGlobal.tm_compatibility_random[species]

    existing_compatibility = species_compatibility.find { |item| item[0] == move }
    return existing_compatibility[1] if existing_compatibility

    is_compatible = rand(2) == 0
    $PokemonGlobal.tm_compatibility_random[species] << [move, is_compatible]
    is_compatible
  end

  def ability_full_random(ret)
    # Initialize global variable if it doesn't exist
    $PokemonGlobal.random_abs_pokemon = {} unless $PokemonGlobal.random_abs_pokemon
    $PokemonGlobal.random_abs_pokemon[@species] = {} unless $PokemonGlobal.random_abs_pokemon[@species]

    different_abs = MultipleForms.hasFunction?(self, 'getAbilityList')
    form_index = different_abs && RandomizedChallenge::DIFFERENT_FORMS_HAVE_DIFFERENT_ABILITIES ? form : 0

    if $PokemonGlobal.random_abs_pokemon[@species][form_index]
      return $PokemonGlobal.random_abs_pokemon[@species][form_index]
    end

    unless $PokemonGlobal.random_abs_pokemon[@species][form_index]
      $PokemonGlobal.random_abs_pokemon[@species][form_index] =
        []
    end
    current_abs = []
    (0...ret.length).each do |i|
      new_ab = generate_random_ability(current_abs)
      current_abs << new_ab
      $PokemonGlobal.random_abs_pokemon[@species][form_index].push([new_ab, i])
      ret[i][0] = new_ab
    end
    $PokemonGlobal.random_abs_pokemon[@species][form_index]
  end

  def generate_random_ability(current_abs = [])
    new_ab = rand(PBAbilities.maxValue - 1) + 1
    new_ab = rand(PBAbilities.maxValue - 1) + 1 while !new_ab || RandomizedChallenge::ABILITYBLACKLIST.include?(new_ab) || current_abs.include?(new_ab)
    new_ab
  end

  def ability_map(ret)
    (0...ret.length).each do |i|
      $PokemonGlobal.ability_hash[ret[i][0]] = generate_random_ability unless $PokemonGlobal.ability_hash[ret[i][0]]
      ret[i][0] = $PokemonGlobal.ability_hash[ret[i][0]]
    end
    ret
  end

  alias random_getAbilityList getAbilityList
  def getAbilityList
    ret = random_getAbilityList
    if $PokemonGlobal.random_abs_pokes && $PokemonGlobal.random_abs_pokes[@id]
      return $PokemonGlobal.random_abs_pokes[@id]
    end

    if random_enabled?
      if $PokemonGlobal.random_ability_mode == :FULL_RANDOM_ABS
        return ability_full_random(ret)
      elsif $PokemonGlobal.random_ability_mode == :MAP_RANDOM_ABS
        return ability_map(ret)
      end
    end
    ret
  end

  alias random_getMoveList getMoveList
  def getMoveList
    return random_getMoveList unless random_enabled? && random_moves_on?

    different_moves = MultipleForms.hasFunction?(self, 'getMoveList')
    form_index = different_moves && RandomizedChallenge::DIFFERENT_FORMS_HAVE_DIFFERENT_MOVEPOOLS ? form : 0

    $PokemonGlobal.random_moves = {} unless $PokemonGlobal.random_moves
    $PokemonGlobal.random_moves[@species] = {} unless $PokemonGlobal.random_moves[@species]
    $PokemonGlobal.random_moves[@species][form_index] = [] unless $PokemonGlobal.random_moves[@species][form_index]
    list = $PokemonGlobal.random_moves[@species][form_index]

    return list unless list.nil? || list.empty?

    atkdata = pbRgssOpen('Data/attacksRS.dat', 'rb')
    offset = atkdata.getOffset(@species - 1)
    length = atkdata.getLength(@species - 1) >> 1
    atkdata.pos = offset

    list = []
    (0..length - 1).each do
      level = atkdata.fgetw
      move = atkdata.fgetw
      next if move.nil?
      move = $Trainer.numbadges < 3 && progressive_random_on? ? find_valid_move(true, 70, [], false, list) : find_valid_move

      list.push([level, move]) unless isConst?(move, PBMoves, :CHATTER) && !isConst?(species, PBSpecies, :CHATOT)
    end
    atkdata.close
    $PokemonGlobal.random_moves[@species][form_index] = list
    list
  end
end

def get_evos(poke)
  species = poke.is_a?(Integer) ? poke : poke.species

  evo = pbGetEvolvedFormData(species)
  evolutions = []
  until evo.empty?
    evolutions << evo.first[2]
    evo = pbGetEvolvedFormData(evo.first[2])
  end
  evolutions
end

def pbCheckEvolutionEx(pokemon)
  return -1 if pokemon.species <= 0 || pokemon.isEgg?
  return -1 if isConst?(pokemon.species, PBSpecies, :PICHU) && pokemon.form == 1
  return -1 if isConst?(pokemon.item, PBItems, :EVERSTONE)

  ret = -1
  pbGetEvolvedFormData(pokemon.species).each do |form|
    ret = if random_enabled? && random_evos_on?
            yield pokemon, form[0], form[1], random_evo(pokemon, form[2]) # form[2]
          else
            yield pokemon, form[0], form[1], form[2]
          end
    break if ret > 0
  end
  ret
end

alias pbLoadTrainer_random pbLoadTrainer
def pbLoadTrainer(trainerid, trainername, partyid = 0)
  return pbLoadTrainer_random(trainerid, trainername, partyid) unless random_enabled?

  pause_random
  original_trainer = pbLoadTrainer_random(trainerid, trainername, partyid)
  resume_random
  trainer = pbLoadTrainer_random(trainerid, trainername, partyid)
  return trainer if trainer.nil?

  megastones_mantained = defined?(RandomizedChallenge::POKEMON_MEGA_STONES) && RandomizedChallenge::POKEMON_MEGA_STONES.length > 0

  return original_trainer if RandomizedChallenge::UNRANDOMIZABLE_TRAINERS.include?(trainerid)

  unrandomizable_trainer_parties = RandomizedChallenge::UNRANDOMIZABLE_TRAINER_POKEMON[trainerid] || {}

  return trainer if unrandomizable_trainer_parties.empty? && !RandomizedChallenge::MEGAS_RANDOMIZE_TO_MEGAS

  unrandomizable_pokes = unrandomizable_trainer_parties[partyid] || []

  unless (RandomizedChallenge::MEGAS_RANDOMIZE_TO_MEGAS && megastones_mantained) || !unrandomizable_pokes.empty?
    return trainer
  end

  trainer[2].map!.with_index do |pkmn, index|
    original_poke = original_trainer[2][index]
    if unrandomizable_pokes.include?(original_poke.species)
      pkmn = original_poke
      pkmn.resetMoves
      pkmn.calcStats
    elsif pbIsMegaStone?(pkmn.item) && pkmn.hasMegaForm?
      megastone = RandomizedChallenge::POKEMON_MEGA_STONES.fetch(pkmn.species)
      pkmn.item megastone.is_a?(Array) ? megastone[rand(megastone.length)] : megastone
    elsif pbIsMegaStone?(pkmn.item)
      new_species = RandomizedChallenge::POKEMON_MEGA_STONES.keys.sample
      pause_random_species
      pkmn = PokeBattle_Pokemon.new(new_species, pkmn.level, trainer[0])
      resume_random_species
      pkmn.setItem(RandomizedChallenge::POKEMON_MEGA_STONES.fetch(new_species, 0))
      # pkmn.resetMoves
      pkmn.calcStats
    end
    pkmn
  end

  trainer
end

################################################################################
# STARTERS RANDOMIZADOS CON DOS ETAPAS EVOLUTIVAS
################################################################################

def generate_random_starters
  starters = RandomizedChallenge::RANDOM_STARTER_LIST#.shuffle
  RandomizedChallenge::STATERS_VARIABLES.each_with_index do |var, i|
    $game_variables[var] = starters[i]
  end
end

def show_random_starter_picture(index = 0, var = nil)
  var ||= RandomizedChallenge::STATERS_VARIABLES[index]
  SpeciesIntro.new(pbGet(var)).set_mark_as_seen(false).show
end

def give_starter_random(index = 0, var = nil, level = 5)
  var ||= RandomizedChallenge::STATERS_VARIABLES[index]
  starter = pbGet(var)
  pause_random
  pbAddPokemon(starter, level)
  resume_random
end

def random_pokemon_set(amount = 3)
  pokemon = []
  amount.times do
    pokemon << random_species
  end
  pokemon
end

def create_ability_hash
  ability_hash = {}
  ability_arr = []
  (1..PBAbilities.maxValue).each do |i|
    next if RandomizedChallenge::ABILITYBLACKLIST.include?(i)

    ability_arr.push(i)
  end
  ability_arr.shuffle!
  (0...ability_arr.length).each do |i|
    ability_hash[i] = ability_arr[i]
  end
  $PokemonGlobal.ability_hash = ability_hash
end

alias pbGenerateWildPokemon_random pbGenerateWildPokemon
def pbGenerateWildPokemon(species, level, isroamer = false)
  wild_poke = pbGenerateWildPokemon_random(species, level, isroamer)
  return wild_poke unless random_enabled? && RandomizedChallenge::KEEP_SAME_WILD_IN_ROUTES

  if $PokemonGlobal.dont_randomize.include?(species)
    $PokemonGlobal.dont_randomize.delete_at($PokemonGlobal.dont_randomize.index(species))
  end
  resume_wild_species if RandomizedChallenge::KEEP_SAME_WILD_IN_ROUTES && $PokemonGlobal.dont_randomize.empty?
  wild_poke
end

class PokemonEncounters
  ENCOUNTER_TYPES = [EncounterTypes::Land, EncounterTypes::Cave, EncounterTypes::Water,
                     EncounterTypes::RockSmash, EncounterTypes::OldRod, EncounterTypes::GoodRod,
                     EncounterTypes::SuperRod, EncounterTypes::HeadbuttLow, EncounterTypes::HeadbuttHigh,
                     EncounterTypes::LandMorning, EncounterTypes::LandDay, EncounterTypes::LandNight,
                     EncounterTypes::BugContest]
  alias setup_random setup
  def setup(mapID)
    setup_random(mapID)
    return unless random_enabled? && RandomizedChallenge::KEEP_SAME_WILD_IN_ROUTES

    return unless @enctypes

    badges_max_levels = if defined?(RandomizedChallenge::BADGES_MAX_LEVELS)
                          RandomizedChallenge::BADGES_MAX_LEVELS
                        else
                          {}
                        end
    ENCOUNTER_TYPES.each do |enctype|
      encounters = @enctypes[enctype]
      next unless encounters

      if $PokemonGlobal.random_encounter_table && $PokemonGlobal.random_encounter_table[mapID] && $PokemonGlobal.random_encounter_table[mapID][enctype]
        @enctypes[enctype] = $PokemonGlobal.random_encounter_table[mapID][enctype]
        next
      end

      conversions = {}

      highest_level = encounters.max_by { |enc| enc[2] }[2] - 2
      encounters.map! do |enc|
        badge_count = 0
        badges_max_levels.each_pair do |badge, max_level|
          badge_count = badge if highest_level >= max_level
          break if badge_count != 0 || highest_level < max_level
        end
        if conversions[enc[0]]
          new_species = conversions[enc[0]]
        else
          new_species = random_species(badge_count)
          conversions[enc[0]] = new_species
        end
        enc[0] = new_species
        enc
      end
      @enctypes[enctype] = encounters
      $PokemonGlobal.random_encounter_table ||= {}
      $PokemonGlobal.random_encounter_table[mapID] ||= {}
      $PokemonGlobal.random_encounter_table[mapID][enctype] = encounters
    end
  end

  alias pbEncounteredPokemon_random pbEncounteredPokemon
  def pbEncounteredPokemon(enctype, tries = 1)
    unless random_enabled? && RandomizedChallenge::KEEP_SAME_WILD_IN_ROUTES
      return pbEncounteredPokemon_random(enctype, tries)
    end

    if enctype < 0 || enctype > EncounterTypes::EnctypeChances.length
      raise ArgumentError.new(_INTL('Tipo de encuentro fuera de rango'))
    end
    return nil if @enctypes[enctype].nil?

    encounters = @enctypes[enctype]
    if !$PokemonGlobal.random_encounter_table || !$PokemonGlobal.random_encounter_table[$game_map.map_id] ||
       !$PokemonGlobal.random_encounter_table[$game_map.map_id][enctype] || $PokemonGlobal.random_encounter_table[$game_map.map_id][enctype].empty?
      conversions = {}
      $PokemonGlobal.random_encounter_table[$game_map.map_id][enctype] = encounters.map do |enc|
        if conversions[enc[0]]
          new_species = conversions[enc[0]]
        else
          new_species = random_species(badge_count)
          conversions[enc[0]] = new_species
        end
        enc[0] = new_species
        enc
      end
    end
    @enctypes[enctype] = $PokemonGlobal.random_encounter_table[$game_map.map_id][enctype]
    pause_wild_species
    wild = pbEncounteredPokemon_random(enctype, tries)
    $PokemonGlobal.dont_randomize ||= []
    $PokemonGlobal.dont_randomize << wild[0] if wild

    wild
  end
end

class EncounterListUI
  alias pbListOfEncounters_random pbListOfEncounters
  def pbListOfEncounters(encounter)
    return pbListOfEncounters_random(encounter) unless random_enabled?

    return [] unless RandomizedChallenge::KEEP_SAME_WILD_IN_ROUTES
    return [] unless RandomizedChallenge::SHOW_ENCOUNTERS_IN_DEXNAV

    encable = []
    if !encounter || !$PokemonGlobal.random_encounter_table || !$PokemonGlobal.random_encounter_table[$game_map.map_id]
      return encable
    end

    encounters = $PokemonGlobal.random_encounter_table[$game_map.map_id]

    for i in 0...encounters.length
      next unless encounters[i]

      for j in 0...encounters[i].length
        next if i >= 13

        next unless encounters[i][j] && encounters[i][j][0].between?(1, PBSpecies.maxValue)

        encable.push(encounters[i][j][0])
      end
    end
    encable |= []
    encable
  end
end
