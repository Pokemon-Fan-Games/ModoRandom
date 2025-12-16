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
  SWITCH = 47

  # VARIABLES POKEMON INICIALES
  # La posicion 1 es la de la primera variable, la 2 la de la segunda, etc.
  RANDOM_STARTER_VARIABLES = [803, 804, 805]

  RANDOMIZE_POKEMON = true

  # Estos Pokemon tienen muchas formas por lo que habrá un 50% de probabilidad de que se rerandomicen para que no salgan tan a menudo.
  MULTIPLE_FORM_POOL = { :FURFROU => 2, :UNOWN => 20, :ARCEUS => 2, :SILVALLY => 2, 
                         :VIVILLON => 10, :PIKACHU => 10, :ALCREMIE => 20, :MINIOR => 2 }

  # Si se revive el mismo fossil mas de 1 vez siempre dará el mismo Pokémon
  KEEP_SAME_FOSSIL_POKEMON = true

  # BST PROGRESIVO DE POKÉMON RANDOMIZADOS
  # Los BST de cada medalla se definen en getMaxBSTCap.
  # Desactiva esto en cualquier momento con toggle_progressive_random.
  PROGRESSIVE_RANDOM_DEFAULT_VALUE = true

  # MOVIMIENTOS RANDOMIZADOS
  # Si quieres que los movimientos esten randomizados pon esta constante en true.
  # Puedes modificar esto en cualquier momento llamando al método toggle_random_moves.
  RANDOM_MOVES_DEFAULT_VALUE = true


  # RANDOMIZAR LOS EQUIPOS DE ENTRENADORES
  RANDOM_TRAINER_TEAM_DEFAULT_VALUE = true

  # RANDOMIZAR OBJETOS ENTRENADORES
  RANDOM_TRAINER_ITEMS_DEFAULT_VALUE = true

  # Re Randomizar ataques de los Pokémon de los trainers
  # La idea de esto es que los Pokemon que saquen los trainers, no tengan el mismo moveset
  # De un mismo pokemon que salga como salvaje. 
  # Es decir si tu tienes a un Pikachu y un trainer saca a un Pikachu no tiene porqué tener los mismos moves.
  RERANDOM_TRAINER_MOVESET = true

  # Define si el moveset de los entrenadores respeta el random progresivo o no
  TRAINERS_MOVESET_RESPECT_PROGRESSIVE = true

  # Priorizar stab en el learnset de los Pokemon
  PRIORIZE_STAB_IN_LEARNSET = true

  # Probabilidad de movimientos con stab en el learnset por nivel
  # Porcentaje de probabilidad de que un movimiento sea del stab del pokemon
  # Solo se tendra en cuenta si la constante PRIORIZE_STAB_IN_LEARNSET está en true
  STAB_IN_LEARNSET = 15

  # Formas diferentes de la misma especie tienen movesets distintos
  # Si está en true, cada forma tendrá su propio set de movimientos aleatorios
  # Si está en false, todas las formas de la misma especie compartirán el mismo moveset
  DIFFERENT_MOVESETS_PER_FORM = false

  # BANNEAR MOVIMIENTOS OHKO
  BAN_OHKO_MOVES = true

  # ASEGURAR AL MENOS UN MOVIMIENTO DE DAÑO
  # Si está en true, garantiza que todos los Pokémon tengan al menos un movimiento que cause daño
  # Esto previene que los Pokémon se generen con solo movimientos de estado/soporte
  ENSURE_DAMAGING_MOVES = true

  # RANDOMIZAR COMPATIBILIDAD DE LAS MTs
  # Si quieres que el aprendizaje de MTs sea aleatorio.
  # Puedes modificar esto en cualquier momento llamando al método toggle_tm_compat.
  RANDOM_TM_COMPAT_DEFAULT_VALUE = true

  # RANDOMIZAR EVOLUCIONES
  # Si quieres que las evoluciones estén randomizadas.
  RANDOM_EVOLUTIONS_DEFAULT_VALUE = false

  # EVOLUCIONES RANDOM CON BST SIMILAR
  RANDOM_EVOLUTIONS_SIMILAR_BST_DEFAULT_VALUE = false

  # EVOLUCIONES FULL RANDOM RESPETAN EL RESTO DE RESTRICCIONES
  # Si tanto este flag como el de arriba estan en false, las evoluciones random podrán ser cualquier pokémon
  # Esto puede beneficiarlos o perjudicarlos, ya que tu pichu podria evolucionar en un Palkia, pero tu Charmander podria evolucionar en un Weedle
  RANDOM_EVOLUTIONS_RESPECT_RESTRICTIONS = false

  # Sinplificar evoluciones
  # Metodos que serán reemplazados por evoluciones por nivel
  # Esto es para evitar las evoluciones que implican aprender un movimiento que es posible que en random no se aprenda
  CHANGE_EVO_METHODS = []
  
  # Nivel en el que evolucionaran los Pokémon con metodos cambiados
  DIFFICULT_EVO_LEVEL = 40

  # Las megas de los entrenadores se randomizan por otra mega.
  MEGAS_RANDOMIZE_TO_MEGAS = true

  # ********************************************************
  # RESTRICCIONES DEL RANDOMIZADO                          *
  # ********************************************************

  # Pokémon que no pueden salir en el modo Random. Añade aquí los que no quieres que salgan
  # con el mismo formato de los que ya aparecen.
  BLACKLISTED_POKEMON = [:ARCEUS_9, :MEWTWO_5, :GRENINJA_1, :GRENINJA_2,
                         :CRAMORANT_1, :CRAMORANT_2, :SILVALLY_9]

  # Pokemon que no se randomizarán
  UNRANDOMIZABLE_POKEMON = [:MEWTWO_5]

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

  # Desactiva esto si no deseas que los iniciales sean random.
  RANDOMIZE_STARTERS = true

  # Lista de posibles Pokémon que aparecerán como Pokémon Iniciales.
  # La lista debe ser la especie del Pokemon empezando con :, ejemplo :BULBASAUR
  # Si el listado está vacío se utilizarán 3 Pokemon aleatorios que tengan 2 evoluciones.
  RANDOM_STARTERS_LIST = []
  # RANDOM_STARTERS_LIST = [
  #   :BULBASAUR, :CHARMANDER, :SQUIRTLE, :PIDGEY, :NIDORANmA, :NIDORANfE, :ZUBAT, :MANKEY, :POLIWAG, :ABRA, :MACHOP, :BELLSPROUT, :GEODUDE,
  #   :MAGNEMITE, :GASTLY, :RHYHORN, :HORSEA, :ELEKID, :MAGBY, :PORYGON, :ODDISH, :DRATINI, :CHIKORITA, :CYNDAQUIL, :TOTODILE, :MAREEP,
  #   :HOPPIP, :SWINUB, :TEDDIURSA, :LARVITAR, :TREECKO, :TORCHIC, :MUDKIP, :LOTAD, :SEEDOT, :RALTS, :ARON, :BUDEW, :TRAPINCH, :DUSKULL,
  #   :SHUPPET, :BAGON, :BELDUM, :SPHEAL, :TURTWIG, :CHIMCHAR, :PIPLUP, :STARLY, :SHINX, :GIBLE, :SNIVY, :TEPIG, :OSHAWOTT, :LILLIPUP, :SEWADDLE,
  #   :VENIPEDE, :ROGGENROLA, :TIMBURR, :SOLOSIS, :GOTHITA, :SANDILE, :VANILLITE, :KLINK, :TYNAMO, :LITWICK, :AXEW, :DEINO, :PAWNIARD, :CHESPIN,
  #   :FENNEKIN, :FROAKIE, :FLETCHLING, :FLABEBE, :GOOMY, :HONEDGE, :ROWLET, :LITTEN, :POPPLIO, :GRUBBIN, :JANGMOO, :GROOKEY, :SCORBUNNY,
  #   :SOBBLE, :ROLYCOLY, :BLIPBUG, :ROOKIDEE, :HATENNA, :IMPIDIMP, :DREEPY, :SPRIGATITO, :FUECOCO, :QUAXLY, :PAWMI, :SMOLIV, :NACLI, :TINKATINK,
  #   :FRIGIBAX
  # ]

  # Mantener los salvajes de las rutas, se randomizan solo 1 vez y siempre saldran los mismos Pokémon en ese mapa
  # El PokéRadar funciona con este tipo de randomizado
  CONSISTENT_WILD_ENCOUNTERS = false

  # Esta configuracion se usará si se elige el randomizado de salvajes que es constante en la ruta.
  # De esta forma se podrán generar los pokemon de las rutas al activar el modo random y que se mantengan
  # Si esta constante no está mantenida se tendrá que entrar al menos 1 vez a un combate de salvaje y en ese momento
  # Se generaran los salvajes de esa ruta y en futuras ocasiones saldrán los mismos
  BADGES_MAX_LEVELS = { 
    0 => 14,
    1 => 23,
    2 => 30,
  }


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
    :PLUS, :MINUS, :WONDERGUARD, :FORECAST, :HARVEST, :HONEYGATHER,
    :BATTLEBOND, :HUNGERSWITCH, :SHIELDSDOWN, :SCHOOLING, :RKSSYSTEM, :POWERCONSTRUCT,
    :STANCECHANGE, :ZENMODE, :COMMANDER, :MULTITYPE, :GULPMISSILE, :ICEFACE, :ZEROTOHERO, :DISGUISE,
    :COMATOSE, :SHIELDSDOWN, :TERASHIFT, :EMBODYASPECT, :EMBODYASPECT_1, :EMBODYASPECT_2, :EMBODYASPECT_3
  ]

  # Especies a los que no se les randomizará nunca la habilidad
  # El caso más común es el de Shedinja que sin Superguarda es basura.
  SPECIES_WITHOUT_RANDOM_ABS = [:SHEDINJA, :MEWTWO_5]

  # Interruptores que se usan para el modo Random.
  # Ten en cuenta que los NPCs de ejemplo usan estos switches, si cambias el número deberás modificarlos también a ellos.
  ABILITY_RANDOMIZER_SWITCH      = 48
  ABILITY_SEMI_RANDOMIZER_SWITCH = 49
  ABILITY_SWAP_RANDOMIZER_SWITCH = 50

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
  ITEM_BLACK_LIST = [:CENIZASSAGRADAS, :GROWTHMULCH, :BLACKFLUTE, :WHITEFLUTE, :BLUEFLUTE, :YELLOWFLUTE, :REDFLUTE,
                     :DAMPMULCH, :REDNECTAR, :YELLOWNECTAR, :PINKNECTAR, :PURPLENECTAR, :SQUIRTBOTTLE, :SPRAYDUCK, :WAILMERPAIL, :SPRINKLOTAD,
                     :REDAPRICORN, :YELLOWAPRICORN, :BLUEAPRICORN, :GREENAPRICORN, :PINKAPRICORN, :WHITEAPRICORN, :BLACKAPRICORN,
                     :HEARTSCALE, :SLOWPOKETAIL, :STABLEMULCH, :GOOEYMULCH, :SHOALSALT, :SHOALSHELL, :GRACIDEA, 
                     :RAZZBERRY, :BLUKBERRY, :NANABBERRY, :WEPEARBERRY, :CORNNBERRY, :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY, :SPELONBERRY,
                     :PAMTREBERRY, :WATMELBERRY, :DURINBERRY, :BELUEBERRY, :ABILITYURGE, :GIMMIGHOULCOIN,
                     :SACREDASH, :METALALLOY, :MASTERPIECETEACUP, :UNREMARKABLETEACUP, :SYRUPYAPPLE, :LEADERSCREST, :MALICIOUSARMOR, :AUSPICIOUSARMOR,
                     :GALARICACUFF, :SWEETAPPLE, :TARTAPPLE, :CHIPPEDPOT, :CRACKEDPOT, :EXPSHARE,
                     :EXPCANDYXS, :EXPCANDYS, :EXPCANDYM, :EXPCANDYL, :EXPCANDYXL, :UNRARECANDY,
                     :TINYBAMBOOSHOOT, :BIGBAMBOOSHOOT]

  # Lista de objetos que no podrán salir como objetos equipados en salvajes
  HELD_ITEM_BLACK_LIST = []

  # Objetos que no se randomizarán si son dados en algun evento.
  UNRANDOMIZABLE_ITEMS = [:CENIZASSAGRADAS, :TINYMUSHROOM]

  # Si en un evento se da una MT se randomizará por otra MT del listado de abajo, a menos que el listado esté vacío
  # Si el listado está vacío se randomizará por cualquier MT
  MT_GET_RANDOMIZED_TO_ANOTHER_MT = true

  # Si el movimiento que enseña la MT se debe randomizar, es decir la MT24 ya no enseñara rayo
  # si no cualquier otro movimiento.
  RANDOMIZE_TM_MOVES = true

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
                :consistent_wild_encounters, :randomize_trainers, :randomize_starters,
                :semi_random_mode, :remember_trainer_teams, :random_trainer_teams,
                :random_trainer_items, :randomize_pokemon, :different_movesets_per_form
end
module RandomizerConfigurator
  RULES = {
    :PROGRESSIVE_RANDOM => {
      :name  => _INTL("Randomizar progresivo"),
      :desc  => _INTL("Según avances en tu aventura irán apareciendo Pokémon con cada vez mayores estadísticas."),
      :order => 1,
      :check => lambda { RandomizedChallenge.progressive? },
      :toggle => lambda { RandomizerConfigurator.toggle_progressive }
    },
    :RANDOMIZE_POKEMON => { # EDITAR QUE SE ACTIVE CON CUALQUIER CLÁUSULA DEBAJO DE ESTA
      :name  => _INTL("Randomizar Pokémon"),
      :desc  => _INTL("Se randomizarán los Pokémon salvajes, regalados, de intercambios o de eventos."),
      :order => 2,
      :check => lambda { RandomizedChallenge.randomize_pokemon? },
      :toggle => lambda { RandomizerConfigurator.toggle_randomize_pokemon }
    },
    :CONSISTENT_ENCOUNTERS =>{
      :name  => _INTL("Salvajes random fijos"),
      :desc  => _INTL("En cada ruta habrá un set fijo de Pokémon random. En cada partida el set será diferente."),
      :order => 3,
      :check => lambda { RandomizedChallenge.consistent_wild_encounters? },
      :toggle => lambda { RandomizerConfigurator.toggle_consistent_wild_encounters }
    },
    :RANDOMIZE_MOVES => {
      :name  => _INTL("Randomizar movimientos"),
      :desc  => _INTL("Se randomizarán los movimientos que los Pokémon aprenden por nivel."),
      :order => 4,
      :check => lambda { RandomizedChallenge.moves_on? },
      :toggle => lambda { RandomizerConfigurator.toggle_moves }
      # :parent => :RANDOMIZE_POKEMON
    },
    :PRIORIZE_STAB_IN_LEARNSET => {
      :name  => _INTL("Probabilidad de STAB"),
      :desc  => _INTL("Los movimientos de tipo STAB tendrán prioridad al ser elegidos en el learnset. (es un 15%)"),
      :order => 5,
      :check => lambda { RandomizedChallenge.prioritize_stab_in_learnset? },
      :toggle => lambda { RandomizerConfigurator.toggle_prioritize_stab_in_learnset },
      :parent => :RANDOMIZE_MOVES
    },
    :DIFFERENT_MOVESETS_PER_FORM => {
      :name  => _INTL("Dif. Moveset. forma"),
      :desc  => _INTL("Cada forma de la misma especie tendrá un moveset distinto."),
      :order => 6,
      :check => lambda { RandomizedChallenge.different_moveset_per_form? },
      :toggle => lambda { RandomizerConfigurator.toggle_moves_different_form },
      :parent => :RANDOMIZE_MOVES
    },
    :BAN_OHKO => {
      :name  => _INTL("Bannear Mov. OHKO"),
      :desc  => _INTL("Se banearán los movimientos OHKO como Frío Polar, Guillotina, etc. para que no puedan salir."),
      :order => 7,
      :check => lambda { RandomizedChallenge.ohko_banned? },
      :toggle => lambda { RandomizerConfigurator.toggle_ban_ohko },
      :parent => :RANDOMIZE_MOVES
    },
    :RANDOMIZE_TM_COMPATIBILITY => {
      :name  => _INTL("Randomiz. compat. de MTs"),
      :desc  => _INTL("Se randomizará la compatibilidad de los Pokémon con las MTs que consigas."),
      :order => 8,
      :check => lambda { RandomizedChallenge.tm_compat_on? },
      :toggle => lambda { RandomizerConfigurator.toggle_tm_compat }
      # :parent => :RANDOMIZE_POKEMON
    },
    :RANDOMIZE_ABILITIES => {
      :name  => _INTL("Randomizar habilidades"),
      :desc  => _INTL("Se randomizarán las habilidades que puedan tener los Pokémon."),
      :order => 9,
      # :check => lambda { RandomizedChallenge.random_abilities? },
      # :toggle => lambda { RandomizedChallenge.toggle_random_abilities }
      # :parent => :RANDOMIZE_POKEMON
    },
    :RANDOMIZE_TYPES => {
      :name  => _INTL("Randomizar tipos"),
      :desc  => _INTL("Se randomizarán los tipos que tengan todos los Pokémon."),
      :order => 10,
      :check => lambda { RandomizedChallenge.types_on? },
      :toggle => lambda { RandomizerConfigurator.toggle_types }
      # :parent => :RANDOMIZE_POKEMON
    },
    :RANDOMIZE_EVOLUTIONS => {
      :name  => _INTL("Randomizar evoluciones"),
      :desc  => _INTL("Se randomizarán las evoluciones, haciendo que evolucionen en especies distintas a las que deberían."),
      :order => 11,
      :parent => :RANDOMIZE_POKEMON,
      :check => lambda { RandomizedChallenge.evolutions_on? },
      :toggle => lambda { RandomizerConfigurator.toggle_evolutions }
    },
    :RANDOMIZE_EVOLUTIONS_SIMILAR_BST => {
      :name  => _INTL("BST similar en evos"),
      :desc  => _INTL("Al randomizar las evoluciones se elegirán especies con estadísticas similares a la evo. original."),
      :order => 12,
      :parent => :RANDOMIZE_EVOLUTIONS,
      :check => lambda { RandomizedChallenge.evolutions_similar_bst_on? },
      :toggle => lambda { RandomizerConfigurator.toggle_evolutions_similar_bst }
    },
    :RANDOMIZE_EVOLUTIONS_RESPECT_PROGRESSIVE => {
      :name  => _INTL("Randomizar evos. progre."),
      :desc  => _INTL("Al randomizar las evoluciones de los Pokémon se respetará que sean progresivas."),
      :order => 13,
      :parent => :RANDOMIZE_EVOLUTIONS,
      :check => lambda { RandomizedChallenge.evos_respect_restrictions? },
      :toggle => lambda { RandomizerConfigurator.toggle_evolutions_respect_progressive }
    },
    :GENS => {
      :name  => _INTL("Generaciones permitidas"),
      :desc  => _INTL("Limita de qué generaciones serán los Pokémon que aparezcan en el juego al ser randomizados."),
      :order => 14,
      :parent => :RANDOMIZE_POKEMON
    },
    :RANDOMIZE_TRAINERS => {
      :name  => _INTL("Randomizar Entrenadores"),
      :desc  => _INTL("Se randomizarán los Pokémon de los Entrenadores, sus ataques, habilidades y movimientos."),
      :order => 15,
      :check => lambda { RandomizedChallenge.randomize_trainers? },
      :toggle => lambda { RandomizerConfigurator.toggle_randomize_trainers }
    },
    :REMEMBER_TRAINER_TEAMS => {
      :name  => _INTL("Recordar Entrenadores"),
      :desc  => _INTL("Si se pierde un combate contra un Entrenador, mantendrá el mismo equipo al enfrentarle de nuevo."),
      :order => 16,
      :parent => :RANDOMIZE_TRAINERS,
      :check => lambda { RandomizedChallenge.remember_trainer_teams? },
      :toggle => lambda { RandomizerConfigurator.toggle_remember_trainer_teams }
    },
    :RANDOMIZE_TRAINER_ITEMS => {
      :name  => _INTL("Randomiz. objs. Entren."),
      :desc  => _INTL("Se randomizarán los objetos equipados de los Pokémon de los Entrenadores."),
      :order => 17,
      :parent => :RANDOMIZE_TRAINERS,
      :check => lambda { RandomizedChallenge.randomize_trainers_items? },
      :toggle => lambda { RandomizerConfigurator.toggle_trainers_items }
    },
    :RANDOMIZE_ITEMS => {
      :name  => _INTL("Randomizar objetos"),
      :desc  => _INTL("Se randomizarán los objetos que te encuentres o te regalen, pero se aplicarán algunas excepciones."),
      :order => 18,
      :check => lambda { RandomizedChallenge.randomize_items? },
      :toggle => lambda { RandomizerConfigurator.toggle_items }
      # :parent => :RANDOMIZE_TRAINERS
    },
    :RANDOMIZE_HELD_ITEMS => {
      :name  => _INTL("Random. objs. de salvajes"),
      :desc  => _INTL("Se randomizarán los objetos equipados en los Pokémon salvajes."),
      :order => 19,
      :parent => :RANDOMIZE_ITEMS,
      :check => lambda { RandomizedChallenge.randomize_held_items? },
      :toggle => lambda { RandomizerConfigurator.toggle_held_items }
    },
    # :TRAINERS_CAN_GIVE_RANDOM_ITEMS => {
    #   :name  => _INTL("Entrenadores derrotados pueden dar objetos random"),
    #   :desc  => _INTL("Los entrenadores derrotados tienen una probabilidad de dar objetos random."),
    #   :order => 16,
    #   :parent => :RANDOMIZE_ITEMS
    # },
    # :RANDOMIZE_TM_MOVES => {
    #   :name  => _INTL("Randomizar movimientos de MTs"),
    #   :desc  => _INTL("Al obtener una MT el movimiento que contiene será randomizado."),
    #   :order => 17,
    #   :parent => :RANDOMIZE_ITEMS
    # },
  }

  GENS = {
    :GEN1 => {
      :name  => _INTL("Generación 1"),
      :desc  => _INTL("Permitir Pokémon de la generación 1, incluyendo evoluciones de generaciones posteriores."),
      :order => 1,
      :parent => :GENS,
      :key => :GEN1,
      :value => 1,
    },
    :GEN2 => {
      :name  => _INTL("Generación 2"),
      :desc  => _INTL("Permitir Pokémon de la generación 2, incluyendo evoluciones de generaciones posteriores."),
      :order => 2,
      :parent => :GENS,
      :key => :GEN2,
      :value => 2,
    },
    :GEN3 => {
      :name  => _INTL("Generación 3"),
      :desc  => _INTL("Permitir Pokémon de la generación 3, incluyendo evoluciones de generaciones posteriores."),
      :order => 3,
      :parent => :GENS,
      :key => :GEN3,
      :value => 3,
    },
    :GEN4 => {
      :name  => _INTL("Generación 4"),
      :desc  => _INTL("Permitir Pokémon de la generación 4, incluyendo evoluciones de generaciones posteriores."),
      :order => 4,
      :parent => :GENS,
      :key => :GEN4,
      :value => 4,
    },
    :GEN5 => {
      :name  => _INTL("Generación 5"),
      :desc  => _INTL("Permitir Pokémon de la generación 5, incluyendo evoluciones de generaciones posteriores."),
      :order => 5,
      :parent => :GENS,
      :key => :GEN5,
      :value => 5,
    },
    :GEN6 => {
      :name  => _INTL("Generación 6"),
      :desc  => _INTL("Permitir Pokémon de la generación 6, incluyendo evoluciones de generaciones posteriores."),
      :order => 6,
      :parent => :GENS,
      :key => :GEN6,
      :value => 6,
    },
    :GEN7 => {
      :name  => _INTL("Generación 7"),
      :desc  => _INTL("Permitir Pokémon de la generación 7, incluyendo evoluciones de generaciones posteriores."),
      :order => 7,
      :parent => :GENS,
      :key => :GEN7,
      :value => 7,
    },
    :GEN8 => {
      :name  => _INTL("Generación 8"),
      :desc  => _INTL("Permitir Pokémon de la generación 8, incluyendo evoluciones de generaciones posteriores."),
      :order => 8,
      :parent => :GENS,
      :key => :GEN8,
      :value => 8,
    },
    :GEN9 => {
      :name  => _INTL("Generación 9"),
      :desc  => _INTL("Permitir Pokémon de la generación 9."),
      :order => 9,
      :parent => :GENS,
      :key => :GEN9,
      :value => 9,
    },
  }

  module_function

  def toggle_randomize_pokemon
    if $PokemonGlobal.randomize_pokemon.nil?
      $PokemonGlobal.randomize_pokemon = RandomizedChallenge::RANDOMIZE_POKEMON
    end
    $PokemonGlobal.randomize_pokemon = !$PokemonGlobal.randomize_pokemon
  end

  def toggle_moves
    if $PokemonGlobal.enable_random_moves.nil?
      $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE
    end
    $PokemonGlobal.enable_random_moves = !$PokemonGlobal.enable_random_moves
  end

  def toggle_tm_compat
    $PokemonGlobal.enable_random_tm_compat = !$PokemonGlobal.enable_random_tm_compat
  end

  def toggle_progressive
    $PokemonGlobal.progressive_random = !$PokemonGlobal.progressive_random
  end

  def toggle_evolutions
    $PokemonGlobal.enable_random_evolutions = !$PokemonGlobal.enable_random_evolutions
  end

  def toggle_evolutions_similar_bst
    $PokemonGlobal.enable_random_evolutions_similar_bst = !$PokemonGlobal.enable_random_evolutions_similar_bst
  end

  def toggle_evolutions_respect_progressive
    $PokemonGlobal.enable_random_evolutions_respect_restrictions = !$PokemonGlobal.enable_random_evolutions_respect_restrictions
  end

  def gens=(gens = [])
    $PokemonGlobal.random_gens = Array(gens)
  end

  def add_or_remove_gen(gen = nil)
    return unless gen

    $PokemonGlobal.random_gens ||= []
    if !$PokemonGlobal.random_gens.include?(gen)
      $PokemonGlobal.random_gens.push(gen)
    else
      $PokemonGlobal.random_gens.delete(gen)
    end
  end

  def toggle_types
    $PokemonGlobal.enable_random_types = !$PokemonGlobal.enable_random_types
  end

  def toggle_ban_ohko
    $PokemonGlobal.banohko = !$PokemonGlobal.banohko
  end

  def toggle_items
    $PokemonGlobal.randomize_items = !$PokemonGlobal.randomize_items
  end

  def toggle_held_items
    $PokemonGlobal.randomize_held_items = !$PokemonGlobal.randomize_held_items
  end

  def toggle_trainers_items
    $PokemonGlobal.randomize_trainers_items = !$PokemonGlobal.randomize_trainers_items
  end

  def toggle_consistent_wild_encounters
    if $PokemonGlobal.consistent_wild_encounters.nil?
      $PokemonGlobal.consistent_wild_encounters = RandomizedChallenge::CONSISTENT_WILD_ENCOUNTERS_DEFAULT_VALUE
    end
    $PokemonGlobal.consistent_wild_encounters = !$PokemonGlobal.consistent_wild_encounters
  end

  # def turn_off_consistent_wild_encounters
  #   $PokemonGlobal.consistent_wild_encounters = false
  # end

  def toggle_randomize_trainers
    if $PokemonGlobal.randomize_trainers.nil?
      $PokemonGlobal.randomize_trainers = RandomizedChallenge::RANDOM_TRAINER_TEAM_DEFAULT_VALUE
    end
    $PokemonGlobal.randomize_trainers = !$PokemonGlobal.randomize_trainers
  end

  def toggle_randomize_starters
    if $PokemonGlobal.randomize_starters.nil?
      $PokemonGlobal.randomize_starters = RandomizedChallenge::RANDOMIZE_STARTERS
    end
    $PokemonGlobal.randomize_starters =  !$PokemonGlobal.randomize_starters
  end

  def toggle_semi_random_mode
    $PokemonGlobal.semi_random_mode ||= false
    $PokemonGlobal.semi_random_mode = !$PokemonGlobal.semi_random_mode
    if $PokemonGlobal.semi_random_mode
      $PokemonGlobal.enable_random_tm_compat = false
      $PokemonGlobal.enable_random_moves = false
      self.ability_mode = :NO
      $PokemonGlobal.randomize_trainers = false
      $PokemonGlobal.randomize_trainers_items = false
      $PokemonGlobal.randomize_items = false
      $PokemonGlobal.randomize_held_items = false
      $PokemonGlobal.enable_random_types = false
      $PokemonGlobal.enable_random_evolutions = false
      $PokemonGlobal.enable_random_evolutions_similar_bst = false
      $PokemonGlobal.enable_random_evolutions_respect_restrictions = false
      $PokemonGlobal.banohko = false
      # $PokemonGlobal.random_gens = []
    end 
  end

  def ability_mode=(mode = RandomizedChallenge::RANDOM_ABILITY_METHOD)
    current_mode = RandomizedChallenge.ability_mode
    return if current_mode == mode
    case mode
    when :FULLRANDOM
      $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
      $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = false
    when :MAPABILITIES
      $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
      $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = true
    when :SAMEINEVOLUTION
      $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = true
      $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = true
    when :NO
      $game_switches[RandomizedChallenge::ABILITY_RANDOMIZER_SWITCH] = false
      $game_switches[RandomizedChallenge::ABILITY_SWAP_RANDOMIZER_SWITCH] = false
      $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH] = false
    end
    RandomizedChallenge::Ability.reset_randomized_data
  end

  def toggle_remember_trainer_teams
    $PokemonGlobal.remember_trainer_teams ||= false
    $PokemonGlobal.remember_trainer_teams = !$PokemonGlobal.remember_trainer_teams 
    $PokemonGlobal.random_trainer_teams = {} if !$PokemonGlobal.remember_trainer_teams
  end

  def toggle_moves_different_form
    if $PokemonGlobal.different_movesets_per_form.nil?
      $PokemonGlobal.different_movesets_per_form = RandomizedChallenge::DIFFERENT_MOVESETS_PER_FORM
    end
    $PokemonGlobal.different_movesets_per_form = !$PokemonGlobal.different_movesets_per_form
  end

  def show_gen_chooser(gens)
    chosen_gens = []
    cmds = []
    (1..9).each do |gen|
      chosen_gens.push(gen) if gens.empty? || gens.include?(gen)
      cmds.push(_INTL("[#{gens.include?(gen) || gens.empty? ? 'X' : ''}] Generación #{gen}"))
    end
    cmds.push(_INTL("Confirmar"))
    cmds.push(_INTL("Cancelar"))
    loop do
      cmd = pbMessageWithHelp(_INTL("Selecciona las generaciones permitidas"), cmds, [_INTL("Permitir Pokémon de la generación 1, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 2, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 3, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 4, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 5, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 6, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 7, incluyendo evoluciones de generaciones posteriores."), _INTL("Permitir Pokémon de la generación 8, incluyendo evoluciones de generaciones posteriores."), _INTL("Confirmar"), _INTL("Cancelar")], -1)
      
      if cmd == cmds.length - 2
        break
      elsif cmd == -1 || cmd == cmds.length - 1
        return gens
      else
        gen = cmd + 1
        if chosen_gens.include?(gen)
          chosen_gens.delete(gen)
          cmds[cmd] = _INTL("[ ] Generación #{gen}")
        else
          chosen_gens.push(gen)
          cmds[cmd] = _INTL("[X] Generación #{gen}")
        end
      end
    end
    return chosen_gens
  end

  def toggle_prioritize_stab_in_learnset
    return if !$PokemonGlobal.enable_random_moves
    if $PokemonGlobal.prioritize_stab_in_learnset.nil?
      $PokemonGlobal.prioritize_stab_in_learnset = RandomizedChallenge::PRIORIZE_STAB_IN_LEARNSET
    end
    $PokemonGlobal.prioritize_stab_in_learnset = !$PokemonGlobal.prioritize_stab_in_learnset
  end
end
