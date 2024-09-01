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

  #********************************************************
  # CONFIGURACIÓN GENERAL
  #********************************************************

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

  #********************************************************
  # RESTRICCIONES DEL RANDOMIZADO
  #********************************************************

  # Pokémon que no pueden salir en el modo Random. Añade aquí los que no quieres que salgan
  # con el mismo formato de los que ya aparecen.
  BLACKLISTED_POKEMON = [:MEW, :ARCEUS]

  # Lista de los únicos Pokémon que pueden aparecer en el modo Random. Si la dejas VACÍA,
  # aparecerán todos los Pokémon del juego SALVO los que añadas a la lista que hay
  # encima de esta, BLACKLISTED_POKEMON.
  WHITELISTED_POKEMON = []

  # Lista de movimientos que no pueden aparecer en el modo Random.
  # Debes añadirlos con el nombre interno que aparece en el PBS moves.txt.
  MOVEBLACKLIST=[:CHATTER, :DIG, :TELEPORT, :SONICBOOM, :DRAGONRAGE, :STRUGGLE]

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

  #********************************************************
  # HABILIDADES RANDOMIZADAS
  #********************************************************

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
    :BATTLEBOND,:HUNGERSWITCH,:SHIELDSDOWN,:SCHOOLING,:RKSSYSTEM,:POWERCONSTRUCT, 
    :STANCECHANGE, :ZENMODE,:COMMANDER, :MULTITYPE, :GULPMISSILE, :ICEFACE, :ZEROTOHERO, :DISGUISE
  ]

  # Interruptores que se usan para el modo Random.
  # Ten en cuenta que los NPCs de ejemplo usan estos switches, si cambias el número deberás modificarlos también a ellos.
  ABILITY_RANDOMIZER_SWITCH      = 61
  ABILITY_SEMI_RANDOMIZER_SWITCH = 62
  ABILITY_SWAP_RANDOMIZER_SWITCH = 63

  #********************************************************
  # OBJETOS RANDOMIZADAS
  #********************************************************

  # Lista de objetos que no quieres que aparezcan entre los objetos Random.
  ITEM_BLACK_LIST = []

  # Objetos que no se randomizarán si son dados en algun evento.
  UNRANDOMIZABLE_ITEMS = []

  # Si en un evento se da una MT se randomizará por otra MT del listado de abajo, a menos que el listado esté vacío
  # Si el listado está vacío se randomizará por cualquier MT
  MT_GET_RANDOMIZED_TO_ANOTHER_MT = true

  # Lista de las MTs que pueden salir en el modo Random.
  # Elimina las que prefieras que se entreguen por NPCs y por tanto no
  # se puedan encontrar en objetos del suelo.
  MTLIST_RANDOM = [
    :TM01, :TM02, :TM03, :TM04, :TM05, :TM06, :TM07, :TM08, :TM09, :TM10,
    :TM11, :TM12, :TM13, :TM14, :TM15, :TM16, :TM17, :TM18, :TM19, :TM20,
    :TM21, :TM22, :TM23, :TM24, :TM25, :TM26, :TM27, :TM28, :TM29, :TM30,
    :TM31, :TM32, :TM33, :TM34, :TM35, :TM36, :TM37, :TM38, :TM39, :TM40,
    :TM41, :TM42, :TM43, :TM44, :TM45, :TM46, :TM47, :TM48, :TM49, :TM50,
    :TM51, :TM52, :TM53, :TM54, :TM55, :TM56, :TM57, :TM58, :TM59, :TM60,
    :TM61, :TM62, :TM63, :TM64, :TM65, :TM66, :TM67, :TM68, :TM69, :TM70,
    :TM71, :TM72, :TM73, :TM74, :TM75, :TM76, :TM77, :TM78, :TM79, :TM80, 
    :TM81, :TM82, :TM83, :TM84, :TM85, :TM86, :TM87, :TM88, :TM89, :TM90,
    :TM91, :TM92, :TM93, :TM94, :TM95, :TM96, :TM97, :TM98, :TM99, :TM100
  ]

  #********************************************************
  # TIPOS RANDOMIZADAS
  #********************************************************

  RANDOM_TYPES_DEFAULT_VALUE = true
  INVALID_TYPES = [:QMARKS]
end
