module RandomizerConfigurator
  module_function

  def open_configurator
    unless RandomizedChallenge.enabled?
      # Show warning message before enabling
      warning_text = RandomizedChallenge.const_defined?(:ENABLE_WARNING_TEXT) && !RandomizedChallenge::ENABLE_WARNING_TEXT.empty? ? 
                    RandomizedChallenge::ENABLE_WARNING_TEXT : nil
      if !warning_text || pbConfirmMessageSerious(warning_text)
        RandomizedChallenge.enable
        pbMessage(_INTL("¡Modo Random activado! Ahora puedes configurar las reglas del randomizado."))
      end
    end
    if RandomizedChallenge.enabled?
      pbFadeOutIn { UI::Options.new(false, :randomizer_main_menu).main }
    end
  end
end

#===============================================================================
# Randomizer Rules Menu - Using Improved Menu System
#===============================================================================
if defined?(UI::Options)
  begin
    UI::Options.class_eval do
      unless method_defined?(:random_end_screen)
        alias_method :random_end_screen, :end_screen
        define_method(:end_screen) do
          begin
            if @menu == :randomizer_menu || @menu == :randomizer_main_menu
              RandomizerConfigurator.apply_pending_ability_mode if defined?(RandomizerConfigurator)
            end
          rescue Exception => e
            raise if e.is_a?(Reset) || e.class.to_s == "Reset"
            # Ignore other errors applying pending mode during reloads
          end
          random_end_screen
        end
      end
    end
  rescue Exception => e
    raise if e.is_a?(Reset) || e.class.to_s == "Reset"
    # If anything goes wrong modifying UI::Options (such as during hot-reload), ignore to avoid crashing the interpreter
  end
end

#===============================================================================
# Helper module for randomizer menu
#===============================================================================
module RandomizerMenuHelpers
  module_function

  def randomizer_enabled?
    return RandomizedChallenge.enabled?
  end

  def ability_mode_text
    case RandomizedChallenge.ability_mode
    when :FULLRANDOM
      return _INTL("Full")
    when :MAPABILITIES
      return _INTL("Mapeo")
    when :SAMEINEVOLUTION
      return _INTL("Mant. Evo")
    else
      return _INTL("Desactivado")
    end
  end

  def gens_text
    gens = RandomizedChallenge.gens
    return _INTL("Todas") if gens.length == RandomizerConfigurator::GENS.length
    return gens.join(", ")
  end

  def build_current_rules_text
    return "" if !RandomizedChallenge.enabled?
    
    rules_text = []
    
    # Progressive
    if RandomizedChallenge.progressive?
      rules_text.push(_INTL("- Random Progresivo: Los Pokémon tendrán cada vez mayores estadísticas según avances."))
    end
    
    # Pokémon
    if RandomizedChallenge.randomize_pokemon?
      rules_text.push(_INTL("- Randomizar Pokémon: Los Pokémon salvajes, regalados y de eventos estarán randomizados."))
      
      if RandomizedChallenge.consistent_wild_encounters?
        rules_text.push(_INTL("  - Salvajes Random Fijos: En cada ruta habrá un set fijo de Pokémon random."))
      end
    end
    
    # Types
    if RandomizedChallenge.types_on?
      rules_text.push(_INTL("- Randomizar Tipos: Los tipos de todos los Pokémon estarán randomizados."))
    end
    
    # Evolutions
    if RandomizedChallenge.evolutions_on?
      rules_text.push(_INTL("- Randomizar Evoluciones: Las evoluciones estarán randomizadas."))
      
      if RandomizedChallenge.evolutions_similar_bst_on?
        rules_text.push(_INTL("  - BST Similar: Se eligen especies con sumatoría de estadísticas similares."))
      end
      
      if RandomizedChallenge.evos_respect_restrictions?
        rules_text.push(_INTL("  - Evos Progresivas: Se respeta que sean progresivas."))
      end
    end
    
    # Generations
    gens = RandomizedChallenge.gens
    if gens.length < 9 && gens.length > 0
      rules_text.push(_INTL("- Generaciones permitidas: {1}", gens.sort.join(", ")))
    end
    
    # Moves
    if RandomizedChallenge.moves_on?
      rules_text.push(_INTL("- Randomizar Movimientos: Los movimientos aprendidos por nivel estarán randomizados."))
      
      if RandomizedChallenge.prioritize_stab_in_learnset?
        rules_text.push(_INTL("  - Probabilidad STAB: Los movimientos STAB tienen prioridad (15%)."))
      end
      
      if RandomizedChallenge.different_moveset_per_form?
        rules_text.push(_INTL("  - Moveset por Forma: Cada forma tendrá un moveset distinto."))
      end
      
      if RandomizedChallenge.ohko_banned?
        rules_text.push(_INTL("  - Movimientos OHKO Baneados: No aparecerán en learnsets."))
      end
    end
    
    # TM Compatibility
    if RandomizedChallenge.tm_compat_on?
      rules_text.push(_INTL("- Randomizar Compatibilidad MTs: La compatibilidad con MTs estará randomizada."))
    end
    
    # Abilities
    if RandomizedChallenge.ability_mode != :NO
      case RandomizedChallenge.ability_mode
      when :FULLRANDOM
        rules_text.push(_INTL("- Randomizar Habilidades (Full Random): Cada especie tendrá su propio set de habilidades random."))
      when :MAPABILITIES
        rules_text.push(_INTL("- Randomizar Habilidades (Mapeo): Una habilidad reemplaza a otra (ej: Intimidación => Potencia)."))
      when :SAMEINEVOLUTION
        rules_text.push(_INTL("- Randomizar Habilidades (Mantener Evo): Las habilidades se mantienen en la misma línea evolutiva."))
      end
    end
    
    # Items
    if RandomizedChallenge.randomize_items?
      rules_text.push(_INTL("- Randomizar Objetos: Los objetos encontrados estarán randomizados."))
      
      if RandomizedChallenge.randomize_held_items?
        rules_text.push(_INTL("  - Objetos Equipados Salvajes: Los objetos equipados en Pokémon salvajes estarán randomizados."))
      end
      
      if RandomizedChallenge.randomize_tm_moves?
        rules_text.push(_INTL("  - Movimientos de MTs: El movimiento que contiene cada MT estará randomizado."))
      end
    end
    
    # Trainers
    if RandomizedChallenge.randomize_trainers?
      rules_text.push(_INTL("- Randomizar Entrenadores: Los Pokémon y movimientos de entrenadores estarán randomizados."))
      
      if RandomizedChallenge.remember_trainer_teams?
        rules_text.push(_INTL("  - Recordar Equipos: Si pierdes, el entrenador mantiene el mismo equipo."))
      end
      
      if RandomizedChallenge.randomize_trainers_items?
        rules_text.push(_INTL("  - Objetos Equipados Entrenadores: Los objetos equipados estarán randomizados."))
      end
    end
    
    return rules_text.join("\n")
  end

  def set_gen(gen, enabled)
    current_gens = RandomizedChallenge.gens.clone
    if enabled && !current_gens.include?(gen)
      current_gens.push(gen)
      RandomizerConfigurator.gens = current_gens.sort
    elsif !enabled && current_gens.include?(gen)
      current_gens.delete(gen)
      RandomizerConfigurator.gens = current_gens.sort
    elsif !enabled && current_gens.empty?
      current_gens = RandomizerConfigurator::GENS.clone
      current_gens.delete(gen)
      RandomizerConfigurator.gens = current_gens.sort
    end
  end
end

#===============================================================================
# Randomizer Main Menu (Entry Point)
#===============================================================================
PageHandlers.add(:randomizer_main_menu, :main, {
  :name  => proc { next _INTL("Random") },
  :order => 10,
  :description => proc { next _INTL("Configura el modo random del juego.") }
})

MenuHandlers.add(:randomizer_main_menu, :configure_random, {
  "page"        => :main,
  "name"        => proc { next _INTL("Configurar Random") },
  "order"       => 10,
  "type"        => :use,
  "description" => proc { next _INTL("Abre el menú completo de configuración del modo random.") },
  "condition"   => proc { next RandomizedChallenge.enabled? },
  "use_proc"    => proc { |screen|
    # Use silent end to avoid triggering transitions that can conflict with soft-reset (F12).
    begin
      screen.silent_end_screen
      UI::Options.new(false, :randomizer_menu).main
    rescue Reset
      raise
    rescue Exception => e
      raise if e.is_a?(Reset) || e.class.to_s == "Reset"
      # Ignore other errors when opening the configuration to avoid crashing the interpreter during hot-reload or reset.
    end
  }
})

MenuHandlers.add(:randomizer_main_menu, :semi_random, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Semi Random") },
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Los Pokémon tendrán cada vez mayores estadísticas según avances.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.semi_random_mode? ? 0 : 1 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_semi_random_mode if (value == 1) != RandomizedChallenge.semi_random_mode?
  }
})


MenuHandlers.add(:randomizer_main_menu, :display_rules, {
  "page"        => :main,
  "name"        => proc { next _INTL("Mostrar Reglas") },
  "order"       => 30,
  "type"        => :use,
  "description" => proc { next _INTL("Muestra un resumen de todas las reglas actualmente habilitadas.") },
  "condition"   => proc { next RandomizedChallenge.enabled? },
  "use_proc"    => proc { |screen|
    rules_text = RandomizerMenuHelpers.build_current_rules_text
    echoln "=== Randomizer Current Rules ==="
    echoln rules_text
    if rules_text.empty?
      pbMessage(_INTL("No hay reglas activas actualmente."))
    else
      vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      vp.z = 999999
      infowindow = Window_AdvancedTextPokemon.newWithSize("", 0, 0, Graphics.width, Graphics.height, vp)
      infowindow.setSkin(MessageConfig.pbGetSystemFrame)
      infowindow.letterbyletter = true
      infowindow.lineHeight = 28
      pbSetSmallFont(infowindow.contents)
      infowindow.text = rules_text
      infowindow.resizeHeightToFit(rules_text)
      infowindow.height = Graphics.height if infowindow.height > Graphics.height
      infowindow.y = (Graphics.height - infowindow.height) / 2
      infowindow.z = 999999
      pbPlayDecisionSE
      loop do
        Graphics.update
        Input.update
        infowindow.update
        pbUpdateSceneMap
        if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
          if infowindow.busy?
            pbPlayDecisionSE if infowindow.pausing?
            infowindow.resume
          else
            break
          end
        end
      end
      infowindow.dispose
      vp.dispose
    end
    screen.refresh
  }
})

MenuHandlers.add(:randomizer_main_menu, :disable_random, {
  "page"        => :main,
  "name"        => proc { next _INTL("Desactivar Random") },
  "order"       => 40,
  "type"        => :use,
  "description" => proc { next _INTL("Desactiva el modo random y cierra este menú.") },
  "use_proc"    => proc { |screen|
    pbMessage(_INTL("¡Estás a punto de desactivar el Modo Random! Esto revertirá todos los cambios realizados por el modo random en el juego.\nSi luego decides reactivarlo, todo será randomizado nuevamente, incluyendo las habilidades de los Pokémon que tienes actualmente en el equipo y en la caja."))
    if pbConfirmMessageSerious(_INTL("¿Deseas desactivar el Modo Random de todas formas?"))
      RandomizedChallenge.disable
      screen.end_screen
    end
  }
})


#===============================================================================
# Randomizer Configuration Menu (Sub-Pages)
#===============================================================================
PageHandlers.add(:randomizer_menu, :pokemon, {
  :name  => proc { next _INTL("Pokémon") },
  :order => 10,
  :description => proc { next _INTL("Configura las opciones de randomizado de Pokémon.") }
})

PageHandlers.add(:randomizer_menu, :gens, {
  :name  => proc { next _INTL("Gens.") },
  :order => 20,
  :description => proc { next _INTL("Selecciona qué generaciones de Pokémon pueden aparecer.") }
})

PageHandlers.add(:randomizer_menu, :moves, {
  :name  => proc { next _INTL("Movs.") },
  :order => 30,
  :description => proc { next _INTL("Configura las opciones de randomizado de movimientos.") }
})

PageHandlers.add(:randomizer_menu, :abilities, {
  :name  => proc { next _INTL("Habs.") },
  :order => 40,
  :description => proc { next _INTL("Configura las opciones de randomizado de habilidades.") }
})

PageHandlers.add(:randomizer_menu, :items, {
  :name  => proc { next _INTL("Objetos") },
  :order => 50,
  :description => proc { next _INTL("Configura las opciones de randomizado de objetos.") }
})

PageHandlers.add(:randomizer_menu, :trainers, {
  :name  => proc { next _INTL("Entrenad.") },
  :order => 60,
  :description => proc { next _INTL("Configura las opciones de randomizado de entrenadores.") }
})

#===============================================================================
# Randomizer Menu Options
#===============================================================================

# Progressive random
MenuHandlers.add(:randomizer_menu, :progressive_random, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Random Progresivo") },
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Los Pokémon tendrán cada vez mayores estadísticas según avances.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.progressive? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_progressive if (value == 1) != RandomizedChallenge.progressive?
  }
})

# Randomize Pokémon
MenuHandlers.add(:randomizer_menu, :randomize_pokemon, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Randomizar Pokémon") },
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los Pokémon salvajes, regalados, de intercambios o eventos.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.randomize_pokemon? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_randomize_pokemon if (value == 1) != RandomizedChallenge.randomize_pokemon?
  }
})

# Consistent encounters
MenuHandlers.add(:randomizer_menu, :consistent_encounters, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Salvajes Random Fijos") },
  "order"       => 30,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("En cada ruta habrá un set fijo de Pokémon random.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.consistent_wild_encounters? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_consistent_wild_encounters if (value == 1) != RandomizedChallenge.consistent_wild_encounters?
  }
})

# Randomize types
MenuHandlers.add(:randomizer_menu, :randomize_types, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Randomizar Tipos") },
  "order"       => 40,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los tipos que tengan todos los Pokémon.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.types_on? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_types if (value == 1) != RandomizedChallenge.types_on?
  }
})

# Randomize evolutions
MenuHandlers.add(:randomizer_menu, :randomize_evolutions, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Random. Evoluciones") },
  "order"       => 50,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza las evoluciones, haciendo que evolucionen en especies distintas.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.randomize_pokemon? },
  "get_proc"    => proc { next RandomizedChallenge.evolutions_on? ? 1 : 0 },
  "set_proc"    => proc { |value, screen|
    RandomizerConfigurator.toggle_evolutions if (value == 1) != RandomizedChallenge.evolutions_on?
    screen.refresh
  }
})

# Evolution BST similar
MenuHandlers.add(:randomizer_menu, :evo_bst_similar, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("BST Similar Evos") },
  "order"       => 60,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Al randomizar evos se eligen especies con estadísticas similares.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.evolutions_on? },
  "get_proc"    => proc { next RandomizedChallenge.evolutions_similar_bst_on? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_evolutions_similar_bst if (value == 1) != RandomizedChallenge.evolutions_similar_bst_on?
  }
})

# Evolution respect progressive
MenuHandlers.add(:randomizer_menu, :evo_respect_progressive, {
  "page"        => :pokemon,
  "name"        => proc { next _INTL("Evos Progresivas") },
  "order"       => 70,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Al randomizar evos se respetará que sean progresivas.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.evolutions_on? },
  "get_proc"    => proc { next RandomizedChallenge.evos_respect_restrictions? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_evolutions_respect_progressive if (value == 1) != RandomizedChallenge.evos_respect_restrictions?
  }
})

#===============================================================================
# Moves Page Options
#===============================================================================

# Randomize moves
MenuHandlers.add(:randomizer_menu, :randomize_moves, {
  "page"        => :moves,
  "name"        => proc { next _INTL("Random Movs.") },
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los movimientos que los Pokémon aprenden por nivel.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.moves_on? ? 1 : 0 },
  "set_proc"    => proc { |value, screen|
    RandomizerConfigurator.toggle_moves if (value == 1) != RandomizedChallenge.moves_on?
    screen.refresh
  }
})

# Prioritize STAB
MenuHandlers.add(:randomizer_menu, :priorize_stab, {
  "page"        => :moves,
  "name"        => proc { next _INTL("Prob.STAB") },
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Los movimientos STAB tendrán prioridad en el learnset (15%).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.moves_on? },
  "get_proc"    => proc { next RandomizedChallenge.prioritize_stab_in_learnset? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_prioritize_stab_in_learnset if (value == 1) != RandomizedChallenge.prioritize_stab_in_learnset?
  }
})

# Different movesets per form
MenuHandlers.add(:randomizer_menu, :different_movesets_per_form, {
  "page"        => :moves,
  "name"        => proc { next _INTL("Dif. Movs. Forma") },
  "order"       => 30,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Cada forma de la misma especie tendrá un moveset distinto.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.moves_on? },
  "get_proc"    => proc { next RandomizedChallenge.different_moveset_per_form? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_moves_different_form if (value == 1) != RandomizedChallenge.different_moveset_per_form?
  }
})

# Ban OHKO moves
MenuHandlers.add(:randomizer_menu, :ban_ohko, {
  "page"        => :moves,
  "name"        => proc { next _INTL("Ban Movs. OHKO") },
  "order"       => 40,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Bannea los movimientos OHKO como Frío Polar, Guillotina, etc.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.moves_on? },
  "get_proc"    => proc { next RandomizedChallenge.ohko_banned? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_ban_ohko if (value == 1) != RandomizedChallenge.ohko_banned?
  }
})

# TM compatibility
MenuHandlers.add(:randomizer_menu, :randomize_tm_compat, {
  "page"        => :moves,
  "name"        => proc { next _INTL("Random. Compat. MTs") },
  "order"       => 50,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza la compatibilidad de los Pokémon con las MTs.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.tm_compat_on? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_tm_compat if (value == 1) != RandomizedChallenge.tm_compat_on?
  }
})

#===============================================================================
# Generations Page Options
#===============================================================================

# Generation 1
MenuHandlers.add(:randomizer_menu, :gen1, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 1") },
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 1 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(1) || RandomizedChallenge.gens.empty? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerMenuHelpers.set_gen(1, value == 1)
  }
})

# Generation 2
MenuHandlers.add(:randomizer_menu, :gen2, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 2") },
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 2 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(2) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerMenuHelpers.set_gen(2, value == 1)
  }
})

# Generation 3
MenuHandlers.add(:randomizer_menu, :gen3, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 3") },
  "order"       => 30,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 3 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(3) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(3, value == 1) }
})

# Generation 4
MenuHandlers.add(:randomizer_menu, :gen4, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 4") },
  "order"       => 40,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 4 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(4) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(4, value == 1) }
})

# Generation 5
MenuHandlers.add(:randomizer_menu, :gen5, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 5") },
  "order"       => 50,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 5 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(5) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(5, value == 1) }
})

# Generation 6
MenuHandlers.add(:randomizer_menu, :gen6, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 6") },
  "order"       => 60,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 6 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(6) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(6, value == 1) }
})

# Generation 7
MenuHandlers.add(:randomizer_menu, :gen7, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 7") },
  "order"       => 70,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 7 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(7) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(7, value == 1) }
})

# Generation 8
MenuHandlers.add(:randomizer_menu, :gen8, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 8") },
  "order"       => 80,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 8 (incluyendo evoluciones posteriores).") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(8) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(8, value == 1) }
})

# Generation 9
MenuHandlers.add(:randomizer_menu, :gen9, {
  "page"        => :gens,
  "name"        => proc { next _INTL("Generación 9") },
  "order"       => 90,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Permitir Pokémon de la generación 9.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.gens.include?(9) ? 1 : 0 },
  "set_proc"    => proc { |value, _screen| RandomizerMenuHelpers.set_gen(9, value == 1) }
})

#===============================================================================
# Abilities Page Options
#===============================================================================

# Randomize abilities (with dropdown menu)
MenuHandlers.add(:randomizer_menu, :randomize_abilities, {
  "page"        => :abilities,
  "name"        => proc { next _INTL("Tipo") },
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Full"), _INTL("Map."), _INTL("Mant.")],
  "description" => proc { next _INTL("Selecciona el tipo de randomizado de habilidades para los Pokémon.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc {
    case RandomizedChallenge.ability_mode
    when :FULLRANDOM
      next 1
    when :MAPABILITIES
      next 2
    when :SAMEINEVOLUTION
      next 3
    else
      next 0
    end
  },
  "set_proc"    => proc { |value, screen|
    # Defer applying the ability mode to avoid expensive re-randomization on every change
    mode = case value
    when 0 then :NO
    when 1 then :FULLRANDOM
    when 2 then :MAPABILITIES
    when 3 then :SAMEINEVOLUTION
    else :NO
    end
    case mode
    when :NO
      screen.description = _INTL("No se randomizan las habilidades de los Pokémon.")
    when :FULLRANDOM
      screen.description = _INTL("Cada especie tendrá un set de habilidades randomizadas.")
    when :MAPABILITIES
      screen.description = _INTL("Las habilidades se asignan según un mapeo, por ejemplo Sequía -> Potencia (esto no implica que Potencia -> Sequía).")
    when :SAMEINEVOLUTION
      screen.description = _INTL("Los Pokémon de una misma línea evolutiva compartirán su set de habilidades.")
    end
    # screen.refresh_selected_option
    RandomizerConfigurator.pending_ability_mode = mode
  }
})

#===============================================================================
# Items Page Options
#===============================================================================

# Randomize items
MenuHandlers.add(:randomizer_menu, :randomize_items, {
  "page"        => :items,
  "name"        => proc { next _INTL("Randomizar Objetos") },
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los objetos que encuentres o te regalen.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.randomize_items? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_items if (value == 1) != RandomizedChallenge.randomize_items?
  }
})

# Randomize held items
MenuHandlers.add(:randomizer_menu, :randomize_held_items, {
  "page"        => :items,
  "name"        => proc { next _INTL("Random. Objs. Salvajes") },
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los objetos equipados en los Pokémon salvajes.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.randomize_items? },
  "get_proc"    => proc { next RandomizedChallenge.randomize_held_items? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_held_items if (value == 1) != RandomizedChallenge.randomize_held_items?
  }
})

# Randomize TM moves
MenuHandlers.add(:randomizer_menu, :randomize_tm_moves, {
  "page"        => :items,
  "name"        => proc { next _INTL("Random. Movs. MTs") },
  "order"       => 30,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Al obtener una MT el movimiento que contiene será randomizado.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.randomize_items? },
  "get_proc"    => proc { next RandomizedChallenge.randomize_tm_moves? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_randomize_tm_moves if (value == 1) != RandomizedChallenge.randomize_tm_moves?
  }
})

#===============================================================================
# Trainers Page Options
#===============================================================================

# Randomize trainers
MenuHandlers.add(:randomizer_menu, :randomize_trainers, {
  "page"        => :trainers,
  "name"        => proc { next _INTL("Random. Entrenad.") },
  "order"       => 10,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los Pokémon de los Entrenadores y sus movimientos.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? },
  "get_proc"    => proc { next RandomizedChallenge.randomize_trainers? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_randomize_trainers if (value == 1) != RandomizedChallenge.randomize_trainers?
  }
})

# Remember trainer teams
MenuHandlers.add(:randomizer_menu, :remember_trainer_teams, {
  "page"        => :trainers,
  "name"        => proc { next _INTL("Recordar Entrenad.") },
  "order"       => 20,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Si pierdes, el entrenador mantendrá el mismo equipo al enfrentarle.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.randomize_trainers? },
  "get_proc"    => proc { next RandomizedChallenge.remember_trainer_teams? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_remember_trainer_teams if (value == 1) != RandomizedChallenge.remember_trainer_teams?
  }
})

# Randomize trainer items
MenuHandlers.add(:randomizer_menu, :randomize_trainer_items, {
  "page"        => :trainers,
  "name"        => proc { next _INTL("Random. Objs. Entren.") },
  "order"       => 30,
  "type"        => :array,
  "parameters"  => [_INTL("No"), _INTL("Sí")],
  "description" => proc { next _INTL("Randomiza los objetos equipados de los Pokémon de entrenadores.") },
  "condition"   => proc { RandomizerMenuHelpers.randomizer_enabled? && RandomizedChallenge.randomize_trainers? },
  "get_proc"    => proc { next RandomizedChallenge.randomize_trainers_items? ? 1 : 0 },
  "set_proc"    => proc { |value, _screen|
    RandomizerConfigurator.toggle_trainers_items if (value == 1) != RandomizedChallenge.randomize_trainers_items?
  }
})
