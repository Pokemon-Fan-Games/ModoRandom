# MenuHandlers.add(:options_menu, :randomizer_configurator, {
#     "name" => _INTL("Modo Random"),
#     "description" => _INTL("Abrir menú del modo Random.\nSi está desactivado te preguntará para activarlo."),
#     "order" => 200,
#     "type" => ButtonOption,
#     "parent" => :options_menu,
#     "get_proc" => proc { next 0 },
#     "set_proc" => proc { |value, _scene|
#       if RandomizedChallenge.enabled?
#         RandomizerConfigurator.pbRandomMenu
#       elsif pbConfirmMessage(_INTL("El modo Random está desactivado, ¿deseas activarlo?"))
#         RandomizedChallenge.enable
#         RandomizerConfigurator.pbRandomMenu
#       else
#         next false
#       end
#       next true
#     }
#   })
  
MenuHandlers.add(:randomizer_configurator, :progressive_random, {
    "name" => _INTL("Randomizado progresivo"),
    "description" => _INTL("Este ajuste hace que vayan saliendo Pokémon y ataques más fuertes a medida que avanzas en el juego y que no pueda salir un legendario al inicio del juego."),
    "order" => 1,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.progressive? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.progressive?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_progressive
      end
      next true
    }
})
  
MenuHandlers.add(:randomizer_configurator, :toggle_semi_random_mode, {
    "name" => _INTL("Modo Semi Random"),
    "description" => _INTL("Randomizar solo salvajes y Pokémon de regalo (incluyendo iniciales)\nNo se randomizarán, movimientos, habilidades, objetos ni entrenadores"),
    "order" => 2,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.semi_random_mode? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.semi_random_mode?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_semi_random_mode
      end
      next true
    }
})
  
MenuHandlers.add(:randomizer_configurator, :randomize_moves, {
    "name" => _INTL("Randomizar Movimientos"),
    "description" => _INTL("Randomizar los movimientos que los Pokémon aprenden por nivel"),
    "order" => 3,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.moves_on? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.moves_on?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_moves
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :ban_ohko, {
    "name" => _INTL("Ban Movs. OHKO"),
    "description" => _INTL("Banear movimientos OHKO, como Perforador, Frío Polar, Guillotina, etc."),
    "order" => 4,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.ohko_banned? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.ohko_banned?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_ban_ohko
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :randomize_tm_compat, {
    "name" => _INTL("Randomizar Aprendizaje de MTs"),
    "description" => _INTL("Randomizar el aprendizaje de las MTs"),
    "order" => 5,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.tm_compat_on? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.tm_compat_on?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_tm_compat
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :ability_mode, {
    "name" => _INTL("Modo Random habilidades"),
    "description" => _INTL("FULL: cada especie tendrá habilidades random\nMAP: Hab A se convierte en Hab B (Intimidación -> Potencia)\nNO: No se randomizarán las habilidades"),
    "order" => 6,
    "type" => EnumOption,
    "parameters" => [_INTL("FULL"), _INTL("MAP"), _INTL("NO")],
    "get_proc" => proc {  
      case RandomizedChallenge.ability_mode?
      when :FULLRANDOM
        0
      when :MAPABILITIES
        1
      when :NO
        2
      end
    },
    "set_proc" => proc { |value, _scene|
      case value
      when 0
        RandomizerConfigurator.ability_mode = :FULLRANDOM
      when 1
        RandomizerConfigurator.ability_mode = :MAPABILITIES
      when 2
        RandomizerConfigurator.ability_mode = :NO
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :random_evolutions, {
    "name" => _INTL("Randomizar evoluciones"),
    "description" => _INTL("Este ajuste hace que los Pokémon no sigan su linea evolutiva, haciendo posible por ejemplo que un Pikachu evolucione en un Charizard."),
    "order" => 7,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.evolutions_on? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.evolutions_on?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_evolutions
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :random_evolutions_similar_bst, {
    "name" => _INTL("Random. evos. con BST similar"),
    "description" => _INTL("Este ajuste hace que si las evoluciones random están activas, la evolución tenga un BST similar al del Pokémon original.\nPor ejemplo un Caterpie no podría evolucionar en un Giratina."),
    "order" => 8,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.evolutions_similar_bst_on? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.evolutions_similar_bst_on?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_evolutions_similar_bst
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :random_evolutions_respect_progressive, {
    "name" => _INTL("Random. evos. progresivo"),
    "description" => _INTL("Este ajuste hace que si las evoluciones random están activas y la opción de Evoluciones Random con BST similar no.\nLas evoluciones random respetarán el limite de BST definido por el Random progresivo, si este estuviera activo."),
    "order" => 9,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.evos_respect_restrictions? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.evos_respect_restrictions?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_evolutions_respect_progressive
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :randomize_types, {
    "name" => _INTL("Randomizar tipos"),
    "description" => _INTL("Este ajuste hace que los tipos de los Pokémon se randomicen, por ejemplo Raichu podría ser tipo Fuego."),
    "order" => 10,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.types_on? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.types_on?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_types
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :randomize_items, {
    "name" => _INTL("Randomizar Objetos"),
    "description" => _INTL("Este ajuste hace que los objetos encontrados sean aleatorios.\nAplican algunas excepciones, como objetos claves u objetos importantes de la historia"),
    "order" => 11,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.randomize_items? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.randomize_items?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_items
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :randomize_held_items, {
    "name" => _INTL("Randomizar Objetos Salvajes"),
    "description" => _INTL("Este ajuste hace que los objetos de los Pokemón que se llevan los salvajes sean aleatorios.\nAplican algunas excepciones, como objetos claves u objetos importantes de la historia"),
    "order" => 12,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.randomize_held_items? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.randomize_held_items?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_held_items
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :consistent_wild_encounters, {
    "name" => _INTL("Set aleatorio encuentros salvajes"),
    "description" => _INTL("Este ajuste hace que los encuentros con salvajes sean aleatorios.\nPero que cada ruta tenga un set específico de Pokemón, este set será distinto en cada partida."),
    "order" => 12,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.consistent_wild_encounters? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      if value == 0
        RandomizerConfigurator.turn_on_consistent_wild_encounters
      else
        RandomizerConfigurator.turn_off_consistent_wild_encounters
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :randomize_trainers, {
    "name" => _INTL("Randomizar entrenadores"),
    "description" => _INTL("Este ajuste hace que los entrenadores sean aleatorios."),
    "order" => 13,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.randomize_trainers? ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      current_value = RandomizedChallenge.randomize_trainers?
      new_value = value == 0 ? true : false
      if current_value != new_value
        RandomizerConfigurator.toggle_randomize_trainers
      end
      next true
    },
})
  
MenuHandlers.add(:randomizer_configurator, :gen_chooser, {
    "name" => _INTL("Seleccionar Generación"),
    "description" => _INTL("Selecciona la generación de Pokémon que quieres que salgan en el modo random.\nPor defecto todas las generaciones están activadas."),
    "order" => 14,
    "type" => ButtonOption,
    "parent" => :randomizer_configurator,
    "condition" => proc { next RandomizedChallenge.enabled? },
    "get_proc" => proc { next 0 },
    "set_proc" => proc { |value, scene|
      RandomizerConfigurator.pbRandomMenu(:gen_chooser)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen1, {
    "name" => _INTL("Generación 1"),
    "description" => _INTL("Permitir Pokémon de la generación 1, incluyendo evoluciones de generaciones posteriores"),
    "order" => 1,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(1) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(1)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen2, {
    "name" => _INTL("Generación 2"),
    "description" => _INTL("Permitir Pokémon de la generación 2, incluyendo evoluciones de generaciones posteriores"),
    "order" => 2,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(2) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(2)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen3, {
    "name" => _INTL("Generación 3"),
    "description" => _INTL("Permitir Pokémon de la generación 3, incluyendo evoluciones de generaciones posteriores"),
    "order" => 3,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(3) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(3)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen4, {
    "name" => _INTL("Generación 4"),
    "description" => _INTL("Permitir Pokémon de la generación 4, incluyendo evoluciones de generaciones posteriores"),
    "order" => 4,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(4) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(4)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen5, {
    "name" => _INTL("Generación 5"),
    "description" => _INTL("Permitir Pokémon de la generación 5, incluyendo evoluciones de generaciones posteriores"),
    "order" => 5,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(5) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(5)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen6, {
    "name" => _INTL("Generación 6"),
    "description" => _INTL("Permitir Pokémon de la generación 6, incluyendo evoluciones de generaciones posteriores"),
    "order" => 6,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(6) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(6)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen7, {
    "name" => _INTL("Generación 7"),
    "description" => _INTL("Permitir Pokémon de la generación 7, incluyendo evoluciones de generaciones posteriores"),
    "order" => 7,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(7) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(7)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen8, {
    "name" => _INTL("Generación 8"),
    "description" => _INTL("Permitir Pokémon de la generación 8, incluyendo evoluciones de generaciones posteriores"),
    "order" => 8,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(8) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(8)
      next true
    },
})
  
MenuHandlers.add(:gen_chooser, :gen9, {
    "name" => _INTL("Generación 9"),
    "description" => _INTL("Permitir Pokémon de la generación 9, incluyendo evoluciones de generaciones posteriores"),
    "order" => 9,
    "type" => EnumOption,
    "parameters" => [_INTL("Sí"), _INTL("No")],
    "get_proc" => proc { next RandomizedChallenge.gen_included?(9) ? 0 : 1 },
    "set_proc" => proc { |value, _scene|
      RandomizerConfigurator.add_or_remove_gen(9)
      next true
    },
})

MenuHandlers.add(:randomizer_configurator, :disable, {
    "name" => _INTL("Desactivar Modo Random"),
    "description" => _INTL("Al interactuar con este botón se desactivará el modo random.\nTe solicitará confirmación"),
    "order" => 20,
    "type" => ButtonOption,
    "parent" => :options_menu,
    "condition" => proc { next RandomizedChallenge.enabled? },
    "get_proc" => proc { next 0 },
    "set_proc" => proc { |value, scene|
        if pbConfirmMessage(_INTL("¿Estás seguro de que quieres desactivar el modo random?\nSi luego lo vuelves a activar todo el randomizado cambiará."))
            RandomizedChallenge.disable
            pbMessage(_INTL("El modo random ha sido desactivado."))
            scene.pbCloseSubMenu
            next true
        else
            next false
        end
    },
})
  