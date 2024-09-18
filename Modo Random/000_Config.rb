################################################################################
#
#                            Script de Pokémon Random
#                           por DPertierra y Skyflyer
#
################################################################################
# Utilizado principalmente para un desafío de Pokémon aleatorizado.
#
# Por aleatorizado, me refiero a que TODOS los Pokémon serán aleatorios, incluso
# los Pokémon con los que interactúas como los legendarios (puedes desactivar
# fácilmente el aleatorizador para ciertas situaciones como batallas legendarias
# y selección de Pokémon inicial apagando el interruptor correspondiente.)
#
# Para usarlo: simplemente activa el Interruptor del modo Random (este interruptor
# es el que viene definido más abajo en la línea 28, donde pone "Switch = 60").
#
# Si no quieres que ciertos Pokémon aparezcan nunca, agrégalos dentro de la lista
# negra en BLACKLISTED_POKEMON (Esto no tiene efecto si el interruptor mencionado
# arriba está apagado.)
#
# Si quieres que SOLO ciertos Pokémon aparezcan, agrégalos a la lista blanca llamada
# WHITELISTED_POKEMON. Esto solo se recomienda cuando la cantidad de Pokémon aleatorios
# disponibles es alrededor de 32 o menos. (Esto no tiene efecto si el interruptor
# mencionado arriba está apagado.)
#
# Tienes más opciones de customización como ataques o habilidades baneadas. Puedes
# encontrar todo esto en las siguientes líneas.
#
################################################################################
module RandomizedChallenge
  # ********************************************************
  # CONFIGURACIÓN GENERAL                                  *
  # ********************************************************

  # ID del Interruptor/Switch para randomizar a los Pokémon. En caso
  # de estar en ON, todos los Pokémon del juego sin excepción serán
  # randomizados, con las restricciones de las opciones siguientes.
  SWITCH = 60

  # VARIABLES POKEMON INICIALES
  # La posicion 1 es la de la primera variable, la 2 la de la segunda, etc.
  RANDOM_STARTER_VARIABLES = [803, 804, 805]

  # BST PROGRESIVO DE POKÉMON RANDOMIZADOS
  # Los BST de cada medalla se definen en getMaxBSTCap.
  # Desactiva esto en cualquier momento con toggle_progressive_random.
  PROGRESSIVE_RANDOM_DEFAULT_VALUE = true

  # MOVIMIENTOS RANDOMIZADOS
  # Si quieres que los movimientos esten randomizados pon esta constante en true.
  # Puedes modificar esto en cualquier momento llamando al método toggle_random_moves.
  RANDOM_MOVES_DEFAULT_VALUE = true

  # BANNEAR MOVIMIENTOS OHKO
  BAN_OHKO_MOVES = true

  # RANDOMIZAR COMPATIBILIDAD DE LAS MTs
  # Si quieres que el aprendizaje de MTs sea aleatorio.
  # Puedes modificar esto en cualquier momento llamando al método toggle_tm_compat.
  RANDOM_TM_COMPAT_DEFAULT_VALUE = true

  # BANNEAR MOVIMIENTOS OHKO
  BAN_OHKO_MOVES = true

  # RANDOMIZAR EVOLUCIONES
  # Si quieres que las evoluciones estén randomizadas.
  RANDOM_EVOLUTIONS_DEFAULT_VALUE = false

  # EVOLUCIONES RANDOM CON BST SIMILAR
  RANDOM_EVOLUTIONS_SIMILAR_BST_DEFAULT_VALUE = false

  # EVOLUCIONES FULL RANDOM RESPETAN EL RESTO DE RESTRICCIONES
  # Si tanto este flag como el de arriba estan en false, las evoluciones random podrán ser cualquier pokémon
  # Esto puede beneficiarlos o perjudicarlos, ya que tu pichu podria evolucionar en un Palkia, pero tu Charmander podria evolucionar en un Weedle
  RANDOM_EVOLUTIONS_RESPECT_RESTRICTIONS = false

  # Las megas de los entrenadores se randomizan por otra mega.
  MEGAS_RANDOMIZE_TO_MEGAS = true

  # ********************************************************
  # RESTRICCIONES DEL RANDOMIZADO                          *
  # ********************************************************

  # Pokémon que no pueden salir en el modo Random. Añade aquí los que no quieres que salgan
  # con el mismo formato de los que ya aparecen.
  BLACKLISTED_POKEMON = [:MEW, :ARCEUS]

  # Lista de los únicos Pokémon que pueden aparecer en el modo Random. Si la dejas VACÍA,
  # aparecerán todos los Pokémon del juego SALVO los que añadas a la lista que hay
  # encima de esta, BLACKLISTED_POKEMON.
  WHITELISTED_POKEMON = []

  # Lista de movimientos que no pueden aparecer en el modo Random.
  # Debes añadirlos con el nombre interno que aparece en el PBS moves.txt.
  MOVEBLACKLIST = [:CHATTER, :DIG, :TELEPORT, :SONICBOOM, :DRAGONRAGE, :STRUGGLE]

  # Si el pokemon no tiene un movimiento con stab en su moveset base, hay una probabilidad de que se le añada uno
  # Este valor puede ir entre 1 y 100 o cualquier valor menor 1 para desactivarlo
  PROBABILITY_OF_STAB = 25

  # Lista de posibles Pokémon que aparecerán como Pokémon Iniciales.
  RANDOM_STARTERS_LIST = [
    :BULBASAUR, :CHARMANDER, :SQUIRTLE, :PIDGEY, :NIDORANmA, :NIDORANfE, :ZUBAT, :MANKEY, :POLIWAG, :ABRA, :MACHOP, :BELLSPROUT, :GEODUDE,
    :MAGNEMITE, :GASTLY, :RHYHORN, :HORSEA, :ELEKID, :MAGBY, :PORYGON, :ODDISH, :DRATINI, :CHIKORITA, :CYNDAQUIL, :TOTODILE, :MAREEP,
    :HOPPIP, :SWINUB, :TEDDIURSA, :LARVITAR, :TREECKO, :TORCHIC, :MUDKIP, :LOTAD, :SEEDOT, :RALTS, :ARON, :BUDEW, :TRAPINCH, :DUSKULL,
    :SHUPPET, :BAGON, :BELDUM, :SPHEAL, :TURTWIG, :CHIMCHAR, :PIPLUP, :STARLY, :SHINX, :GIBLE, :SNIVY, :TEPIG, :OSHAWOTT, :LILLIPUP, :SEWADDLE,
    :VENIPEDE, :ROGGENROLA, :TIMBURR, :SOLOSIS, :GOTHITA, :SANDILE, :VANILLITE, :KLINK, :TYNAMO, :LITWICK, :AXEW, :DEINO, :PAWNIARD, :CHESPIN,
    :FENNEKIN, :FROAKIE, :FLETCHLING, :FLABEBE, :GOOMY, :HONEDGE, :ROWLET, :LITTEN, :POPPLIO, :GRUBBIN, :JANGMOO, :GROOKEY, :SCORBUNNY,
    :SOBBLE, :ROLYCOLY, :BLIPBUG, :ROOKIDEE, :HATENNA, :IMPIDIMP, :DREEPY, :SPRIGATITO, :FUECOCO, :QUAXLY, :PAWMI, :SMOLIV, :NACLI, :TINKATINK,
    :FRIGIBAX
  ]

  # Mantener los salvajes de las rutas, se randomizan solo 1 vez y siempre saldran los mismos Pokémon en ese mapa
  CONSISTENT_WILD_ENCOUNTERS = true

  # ********************************************************
  # HABILIDADES RANDOMIZADAS                               *
  # ********************************************************

  # TIPO DE RANDOMIZADO DE HABILIDADES
  # Definir el tipo de randomizado de habilidades. Hay tres opciones:
  #   :FULLRANDOM      - Todas las habilidades serán aleatorias.
  #   :MAPABILITIES    - Cada habilidad se intercambia por otra siempre.
  #                      Por ejemplo, si Presión se cambia por Llovizna, todos los Pokémon con Presión ahora van a tener Llovizna.
  #                      Sin embargo, los Pokémon que tenían Llovizna no tienen por qué tener Presión, puede haberle tocado otra habilidad.
  #   :SAMEINEVOLUTION - Se mantiene la habilidad al evolucionar.
  #
  # Si no quieres ningún tipo de randomizado pon "RANDOM_ABILITY_METHOD = nil"
  RANDOM_ABILITY_METHOD = :FULLRANDOM

  # Lista de habilidades que no pueden aparecer en el modo Random.
  # Debes añadirlas con el nombre interno que aparece en el PBS abilities.txt.
  ABILITY_EXCLUSIONS = [
    :IMPOSTER, :PLUS, :MINUS, :WONDERGUARD, :FORECAST, :HARVEST, :HONEYGATHER,
    :BATTLEBOND, :HUNGERSWITCH, :SHIELDSDOWN, :SCHOOLING, :RKSSYSTEM, :POWERCONSTRUCT,
    :STANCECHANGE, :ZENMODE, :COMMANDER, :MULTITYPE, :GULPMISSILE, :ICEFACE, :ZEROTOHERO, :DISGUISE
  ]

  # Interruptores que se usan para el modo Random.
  # Ten en cuenta que los NPCs de ejemplo usan estos switches, si cambias el número deberás modificarlos también a ellos.
  ABILITY_RANDOMIZER_SWITCH      = 61
  ABILITY_SEMI_RANDOMIZER_SWITCH = 62
  ABILITY_SWAP_RANDOMIZER_SWITCH = 63

  # ********************************************************
  # OBJETOS RANDOMIZADOS                                   *
  # ********************************************************

  # Randomize Items Gift and Ball
  RANDOMIZE_ITEMS = true

  # Randomizar objetos equipados en salvajes
  RANDOMIZE_HELD_ITEMS = false

  # Los salvajes pueden tener MTs como objetos random
  WILD_CAN_HAVE_TMS = false


  GIFTED_POKEMON_CAN_HAVE_ITEMS = true
  # Probabilidad de objetos en pokemon regalados o de trade
  # (entre 0 y 100)
  GIFTED_POKEMON_ITEM_PROBABILITY = 15

  # Lista de objetos que no quieres que aparezcan entre los objetos Random.
  ITEM_BLACK_LIST = []

  # Lista de objetos que no podrán salir como objetos equipados en salvajes
  HELD_ITEM_BLACK_LIST = []

  # Objetos que no se randomizarán si son dados en algun evento.
  UNRANDOMIZABLE_ITEMS = []

  # Si en un evento se da una MT se randomizará por otra MT del listado de abajo, a menos que el listado esté vacío
  # Si el listado está vacío se randomizará por cualquier MT
  MT_GET_RANDOMIZED_TO_ANOTHER_MT = true

  # Si el movimiento que enseña la MT se debe randomizar, es decir la MT24 ya no enseñara rayo
  # si no cualquier otro movimiento.
  RANDOMIZE_TM_MOVES = false

  # Lista de las MTs que pueden salir en el modo Random.
  # Elimina las que prefieras que se entreguen por NPCs y por tanto no
  # se puedan encontrar en objetos del suelo.
  # Si está vacía cualquier MT podrá salir.
  MTLIST_RANDOM = []

  # Permitir que salgan MTs que el jugador ya tiene en los objetos random.
  ALLOW_DUPLICATE_TMS = false

  # Hay una probabilidad de que al vencer a un entranador te den un objeto random
  TRAINERS_CAN_GIVE_RANDOM_ITEMS = true

  # Porcentaje de probabilidad de que un objeto random sea dado por un entrenador
  # (entre 0 y 100)
  PROBABILITY_OF_RANDOM_ITEMS_FROM_TRAINERS = 15

  # ********************************************************
  # TIPOS RANDOMIZADOS                                     *
  # ********************************************************

  RANDOM_TYPES_DEFAULT_VALUE = false
  INVALID_TYPES = [:QMARKS]

  # Lista de entrenadores que no se randomizarán
  # El listado debe contener el trainer.id
  UNRANDOMIZABLE_TRAINERS = []

  # Lista de entrenadores y pokemon especificos que no se randomizarán
  # Es un hash que debe ser trainer.id => [:ESPECIE1, :ESPECIE2]
  UNRANDOMIZABLE_TRAINER_POKEMON = {}
end

class PokemonGlobalMetadata
  attr_accessor :progressive_random, :random_moves,
                :enable_random_moves, :banohko, :random_gens,
                :enable_random_tm_compat, :tm_compatibility_random, :enable_random_evolutions,
                :enable_random_evolutions_similar_bst,
                :enable_random_evolutions_respect_restrictions, :enable_random_types,
                :random_types, :randomize_items, :randomize_held_items,
                :consistent_wild_encounters
end
class RandomizerConfigurator
  def self.toggle_moves
    if $PokemonGlobal.enable_random_moves.nil?
      $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
    end
    $PokemonGlobal.enable_random_moves = !$PokemonGlobal.enable_random_moves
  end

  def self.toggle_tm_compat
    $PokemonGlobal.enable_random_tm_compat = !$PokemonGlobal.enable_random_tm_compat
  end

  def self.toggle_progressive
    $PokemonGlobal.progressive_random = !$PokemonGlobal.progressive_random
  end

  def self.toggle_evolutions
    $PokemonGlobal.enable_random_evolutions = !$PokemonGlobal.enable_random_evolutions
  end

  def self.toggle_evolutions_similar_bst
    $PokemonGlobal.enable_random_evolutions_similar_bst = !$PokemonGlobal.enable_random_evolutions_similar_bst
  end

  def self.toggle_evolutions_respect_progressive
    $PokemonGlobal.enable_random_evolutions_respect_restrictions = !$PokemonGlobal.enable_random_evolutions_respect_restrictions
  end

  def self.set_gens(gens = [])
    $PokemonGlobal.random_gens = Array(gens)
  end

  def self.add_or_remove_gen(gen = nil)
    return unless gen

    $PokemonGlobal.random_gens = $PokemonGlobal.random_gens || []
    if !$PokemonGlobal.random_gens.include?(gen)
      $PokemonGlobal.random_gens.push(gen)
    else
      $PokemonGlobal.random_gens.delete(gen)
    end
  end

  def self.toggle_types
    $PokemonGlobal.enable_random_types = !$PokemonGlobal.enable_random_types
  end

  def self.toggle_ban_ohko
    $PokemonGlobal.banohko = !$PokemonGlobal.banohko
  end

  def self.toggle_items
    $PokemonGlobal.randomize_items = !$PokemonGlobal.randomize_items
  end

  def self.toggle_held_items
    $PokemonGlobal.randomize_held_items = !$PokemonGlobal.randomize_held_items
  end

  def self.turn_on_consistent_wild_encounters
    $PokemonGlobal.keep_wild_encounters = true
  end

  def self.turn_off_consistent_wild_encounters
    $PokemonGlobal.keep_wild_encounters = false
  end
end
