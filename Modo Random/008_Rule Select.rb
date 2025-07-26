class PokemonGlobalMetadata
  attr_accessor :randomizer_rules
end
module RandomizerConfigurator
  module_function

  def open_configurator(display = false, preselected_rules = get_current_rules)
    rules = select_mode(preselected_rules)
    if rules.empty?
      if pbConfirmMessage(_INTL("Has desactivado todas las reglas del modo random.\n¿Quieres desactivarlo?"))
        RandomizedChallenge.disable
      else
        pbMessage(_INTL("El random seguirá activo con las reglas predefinidas"))
        if pbConfirmMessage(_INTL("¿Quieres verlas?"))
          display_current_rules
        end
      end
      return
    end
    configure_options(rules) if !display
  end

  def get_current_rules
    current_rules = {}
    RULES.each do |rule, rule_data|
      case rule
      when :RANDOMIZE_ABILITIES
        case RandomizedChallenge.ability_mode
        when :FULLRANDOM
          current_rules[rule] = :FULL
        when :MAPABILITIES
          current_rules[rule] = :MAP
        end
      when :GENS
        gens = RandomizedChallenge.gens
        current_rules[rule] = gens
      else
        if rule_data && rule_data.has_key?(:check) && rule_data[:check] && rule_data[:check].call
          current_rules[rule] = true
        end
      end
    end
    return current_rules
  end

  def display_current_rules
    display_rules(get_current_rules)
  end
  
  def configure_options(rules)
    return if rules.empty?
    # RandomizedChallenge.disable
    # RandomizedChallenge.enable(true)
    RULES.each do |rule, rule_data|
      value = rules.fetch(rule, false)
      case rule
      when :RANDOMIZE_ABILITIES
        case value
        when :FULL
          RandomizerConfigurator.ability_mode = :FULLRANDOM
        when :MAP
          RandomizerConfigurator.ability_mode = :MAPABILITIES
        else
          RandomizerConfigurator.ability_mode = :NO
        end
        if !rules.has_key?(rule)
          RandomizerConfigurator.ability_mode = :NO
        end
      when :GENS
        gens = value.keys.map { |gen_key| GENS[gen_key][:value] } if value.is_a?(Hash) && !value.empty?
        RandomizerConfigurator.gens = gens if gens
      else
        if ((!value && rule_data[:check].call) || (value && !rule_data[:check].call)) && rule_data && rule_data.has_key?(:check) && rule_data.has_key?(:toggle)
          rule_data[:toggle].call
        end
      end
      # when :PROGRESSIVE_RANDOM
      #   if !RandomizedChallenge.progressive?
      #     RandomizerConfigurator.toggle_progressive
      #   end
      # when :RANDOMIZE_MOVES
      #   if !RandomizedChallenge.moves_on?
      #     RandomizerConfigurator.toggle_moves
      #   end
      # when :BAN_OHKO
      #   if !RandomizedChallenge.ohko_banned?
      #     RandomizerConfigurator.toggle_ban_ohko
      #   end
      # when :RANDOMIZE_TM_COMPATIBILITY
      #   if !RandomizedChallenge.tm_compat_on?
      #     RandomizerConfigurator.toggle_tm_compat
      #   end
      # when :RANDOMIZE_TYPES
      #   if !RandomizedChallenge.types_on?
      #     RandomizerConfigurator.toggle_types
      #   end
      # when :RANDOMIZE_EVOLUTIONS
      #   if !RandomizedChallenge.evolutions_on?
      #     RandomizerConfigurator.toggle_evolutions
      #   end
      # when :RANDOMIZE_EVOLUTIONS_SIMILAR_BST
      #   if !RandomizedChallenge.evolutions_similar_bst_on?
      #     RandomizerConfigurator.toggle_evolutions_similar_bst
      #   end
      # when :RANDOMIZE_EVOLUTIONS_RESPECT_PROGRESSIVE
      #   if !RandomizedChallenge.evolutions_respect_progressive?
      #     RandomizerConfigurator.toggle_evolutions_respect_progressive
      #   end
      # when :RANDOMIZE_ITEMS
      #   if !RandomizedChallenge.randomize_items?
      #     RandomizerConfigurator.toggle_items
      #   end
      # when :RANDOMIZE_HELD_ITEMS
      #   if !RandomizedChallenge.randomize_held_items?
      #     RandomizerConfigurator.toggle_held_items
      #   end
      # when :CONSISTENT_WILD_ENCOUNTERS
      #   if !RandomizedChallenge.consistent_wild_encounters?
      #     RandomizerConfigurator.toggle_consistent_wild_encounters
      #   end
      # when :RANDOMIZE_TM_MOVES
      #   if !RandomizedChallenge.tm_moves_on?
      #     RandomizerConfigurator.toggle_tm_moves
      #   end
      # when :RANDOMIZE_TRAINERS
      #   if !RandomizedChallenge.randomize_trainers?
      #     RandomizerConfigurator.toggle_trainers
      #   end
      # when :RANDOMIZE_TRAINER_ITEMS
      #   if !RandomizedChallenge.randomize_trainers_items?
      #     RandomizerConfigurator.toggle_trainers_items
      #   end
      # when :REMEMBER_TRAINER_TEAMS
      #   if !RandomizedChallenge.remember_trainer_teams?
      #     RandomizerConfigurator.toggle_remember_trainer_teams
      #   end
      # end
    end
  end

  def select_mode(preselected_rules = {})
    selected_rules = preselected_rules
    loop do
      selected_rules = select_custom_rules(preselected_rules)
      if selected_rules.empty?
        break if pbMessage(_INTL("¿Te gustaría jugar al juego sin Modo Random?"), [_INTL("Sí"), _INTL("No")]) == 0
      else
        display_rules(selected_rules)
        if pbConfirmMessage(_INTL("¿Te gustaría jugar al juego con el modo random seleccionado?"))
          $PokemonGlobal.randomizer_rules = selected_rules
          configure_options(selected_rules)
          break
        end
      end
    end
    return selected_rules
  end

  def select_gens(preselected_rules = {})
    selected_rules = preselected_rules
    vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    infowindow = Window_AdvancedTextPokemon.newWithSize("", 0, Graphics.height - 96, Graphics.width, 96, vp)
    infowindow.setSkin(MessageConfig.pbGetSystemFrame)
    cmdwindow = Window_CommandPokemon_Challenge.new([])
    cmdwindow.viewport = vp
    cmdwindow.y = 64
    text = _INTL("Elegir Generaciones")
    titlewindow = Window_UnformattedTextPokemon.newWithSize(
      text, 0, 0, Graphics.width, 64, vp)
    need_refresh = true
    rules = GENS.keys.clone
    rules.sort! { |a, b| GENS[a][:order] <=> GENS[b][:order] }
    pbSetNarrowFont(infowindow.contents)
    infowindow.text = _INTL(GENS[rules.first][:desc])
    defaultskin = MessageConfig.pbGetSystemFrame.gsub("Graphics/Windowskins/", "")
    loop do
      if need_refresh
        commands = []
        rules.each do |rule|
          toggle = selected_rules.key?(rule) ? 1 : 0
          commands.push([GENS[rule][:name], toggle])
        end
        commands.push(_INTL("Confirmar"))
        cmdwindow.commands = commands
        cmdwindow.width = Graphics.width
        cmdwindow.height = Graphics.height - 160
        need_refresh = false
      end
      Graphics.update
      Input.update
      old_index = cmdwindow.index
      cmdwindow.update
      infowindow.update
      pbUpdateSceneMap
      if old_index != cmdwindow.index
        text = ""
        if cmdwindow.index == cmdwindow.commands.length - 1
          text = _INTL("Confirme la siguiente selección de modificadores.") 
        else
          text = GENS[rules[cmdwindow.index]][:desc]
        end
        infowindow.text = _INTL(text) 
        old_index = cmdwindow.index
      end
      if Input.trigger?(Input::BACK)
        infowindow.visible = false
        break if selected_rules.empty?
        selected_rules.clear if pbConfirmMessage(_INTL("\\w[{1}]¿Borrar la selección actual de modificadores?", defaultskin))
        infowindow.visible = true
        need_refresh = true
      elsif Input.trigger?(Input::USE)
        command = cmdwindow.index
        break if command == GENS.values.length
        rule = rules[command]
        updated = false
        if !updated
          if selected_rules.key?(rule)
            selected_rules.delete(rule)
            updated = true
          else
            selected_rules[rule] = true
            updated = true
          end
        end
        if updated
          pbPlayCursorSE
          # selected_rules.sort! { |a, b| rules_hash[a][:order] <=> rules_hash[b][:order] }
          need_refresh = true
        else 
          pbPlayBuzzerSE
        end
      end
    end
    cmdwindow.dispose
    infowindow.dispose
    titlewindow.dispose
    vp.dispose
    return selected_rules
  end

  def select_custom_rules(preselected_rules = {}, rules_hash = RULES)
    selected_rules = preselected_rules
    vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    infowindow = Window_AdvancedTextPokemon.newWithSize("", 0, Graphics.height - 96, Graphics.width, 96, vp)
    infowindow.setSkin(MessageConfig.pbGetSystemFrame)
    cmdwindow = Window_CommandPokemon_Challenge.new([])
    cmdwindow.viewport = vp
    cmdwindow.y = 64
    text = _INTL("Opciones del Modo Random")
    titlewindow = Window_UnformattedTextPokemon.newWithSize(
      text, 0, 0, Graphics.width, 64, vp)
    need_refresh = true
    rules = rules_hash.keys.clone
    rules.sort! { |a, b| rules_hash[a][:order] <=> rules_hash[b][:order] }
    pbSetNarrowFont(infowindow.contents)
    infowindow.text = _INTL(rules_hash[rules.first][:desc])
    defaultskin = MessageConfig.pbGetSystemFrame.gsub("Graphics/Windowskins/", "")
    loop do
      if need_refresh
        commands = []
        rules.each do |rule|
          toggle = selected_rules.key?(rule) ? 1 : 0
          commands.push([rules_hash[rule][:name], toggle])
        end
        commands.push(_INTL("Confirmar"))
        cmdwindow.commands = commands
        cmdwindow.width = Graphics.width
        cmdwindow.height = Graphics.height - 160
        need_refresh = false
      end
      Graphics.update
      Input.update
      old_index = cmdwindow.index
      cmdwindow.update
      infowindow.update
      pbUpdateSceneMap
      if old_index != cmdwindow.index
        text = ""
        if cmdwindow.index == cmdwindow.commands.length - 1
          text = _INTL("Confirme la siguiente selección de modificadores.") 
        else
          text = rules_hash[rules[cmdwindow.index]][:desc]
        end
        infowindow.text = _INTL(text) 
        old_index = cmdwindow.index
      end
      if Input.trigger?(Input::BACK)
        infowindow.visible = false
        break if selected_rules.empty?
        selected_rules.clear if pbConfirmMessage(_INTL("\\w[{1}]¿Borrar la selección actual de modificadores?", defaultskin))
        infowindow.visible = true
        need_refresh = true
      elsif Input.trigger?(Input::USE)
        command = cmdwindow.index
        break if command == rules_hash.values.length
        rule = rules[command]
        updated = false
        if rule == :RANDOMIZE_ABILITIES && !selected_rules.key?(:RANDOMIZE_ABILITIES)
          cmd = pbMessageWithHelp(_INTL("Elige el modo de randomizado de las habilidades"), [_INTL("FULL"), _INTL("MAP"), _INTL("Cancelar")], [_INTL("Genera un set de habilidades random para cada especie"), _INTL("Una habilidad reemplaza a otra por ejemplo Intimidación => Potencia"), _INTL("No se randomizarán las habilidades")], -1)
          if cmd == 0
            selected_rules[:RANDOMIZE_ABILITIES] = :FULL
            updated = true
          elsif cmd == 1
            selected_rules[:RANDOMIZE_ABILITIES] = :MAP
            updated = true
          elsif cmd == -1 || cmd == 2
            next 
          end
        end
        if rule == :GENS 
          preselected_gens = {}
          RandomizedChallenge.gens.each do |gen|
            selected_gen = GENS.find { |k, v| v[:value] == gen }.first
            preselected_gens[selected_gen] = true
          end
          gens = select_gens(preselected_gens)
          if gens.empty?
            next
          end
          selected_rules[:GENS] = gens
          updated = true
          need_refresh = true
        end
        if !updated
          if selected_rules.key?(rule)
            selected_rules.delete(rule)
            updated = true
          else
            selected_rules[rule] = true
            updated = true
          end
        end
        if updated
          pbPlayCursorSE
          # selected_rules.sort! { |a, b| rules_hash[a][:order] <=> rules_hash[b][:order] }
          need_refresh = true
        else 
          pbPlayBuzzerSE
        end
      end
    end
    cmdwindow.dispose
    infowindow.dispose
    titlewindow.dispose
    vp.dispose
    return selected_rules
  end

  def display_rules(rules)
    vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    infowindow = Window_AdvancedTextPokemon.newWithSize("", 0, 0, Graphics.width, Graphics.height, vp)
    infowindow.setSkin(MessageConfig.pbGetSystemFrame)
    infowindow.letterbyletter = true
    infowindow.lineHeight = 28
    rule_text  = ""
    rules.each_with_index do |(rule, value), i|
      next if rule == :GAME_OVER_WHITEOUT
      rule_text += "- " + _INTL(RULES[rule][:desc]) if rule != :GENS
      if rule == :RANDOMIZE_ABILITIES && value == :FULL
        rule_text += "\n- " + _INTL("Cada especie tendrá su propio set de habilidades random.")
      elsif rule == :RANDOMIZE_ABILITIES && value == :MAP
        rule_text += "\n- " + _INTL("Se convertirá una habilidad en otra por ejemplo Intimidación => Potencia.")
      end
      if rule == :GENS && (value.length == GENS.length || value.empty?)
        rule_text += "\n- " + _INTL("Se permitirán Pokémon de todas las generaciones en el randomizado")
      elsif rule == :GENS && value.length < GENS.length
        gens = value if value.is_a?(Array)
        if value.is_a?(Hash)
          gens = []
          value.each do |key, value|
            gens.push(GENS[key][:value])
          end
        end
        rule_text += "\n- " + _INTL("Se permitirán Pokémon de las siguientes generaciones {1} (incluyendo evoluciones posteriores)", gens.join(", "))
      end
      rule_text += "\n" if i != rules.length - 1
    end
    pbSetSmallFont(infowindow.contents)
    infowindow.text = rule_text
    infowindow.resizeHeightToFit(rule_text)
    infowindow.height = Graphics.height if infowindow.height > Graphics.height
    infowindow.y = (Graphics.height - infowindow.height) / 2
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
    # rule_text  = ""
    # pbSetSmallFont(infowindow.contents)
    # infowindow.text = rule_text
    # infowindow.resizeHeightToFit(rule_text)
    # infowindow.height = Graphics.height if infowindow.height > Graphics.height
    # infowindow.y = (Graphics.height - infowindow.height) / 2
    # pbPlayDecisionSE
    # loop do
    #   Graphics.update
    #   Input.update
    #   infowindow.update
    #   pbUpdateSceneMap
    #   if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
    #     if infowindow.busy?
    #       pbPlayDecisionSE if infowindow.pausing?
    #       infowindow.resume
    #     else
    #       break
    #     end
    #   end
    # end
    infowindow.dispose
    vp.dispose
  end
end

class Window_CommandPokemon_Challenge < Window_CommandPokemon
  def initialize(commands, width = nil)
    @text_key = []
    commands.each_with_index do |command, i|
      next if !command.is_a?(Array)
      commands[i]  = command[0]
      @text_key[i] = command[1]
    end
    super(commands, width)
  end

  def drawItem(index, count, rect)
    pbSetSystemFont(self.contents)
    rect = drawCursor(index, rect)
    base   = self.baseColor
    shadow = self.shadowColor
    x_pos = rect.x 
    y_pos = rect.y 
    pbDrawShadowText(self.contents, x_pos + 4, y_pos + (self.contents.text_offset_y || 0), 
      rect.width, rect.height, @commands[index], base, shadow)
    return if !@text_key[index]
    text = _INTL("DESACTIVADO")
    shadow   = Color.new(232, 32, 16)
    base = Color.new(248, 168, 184)
    if @text_key[index] == 1
      text = _INTL("ACTIVADO")
      shadow   = Color.new(0, 112, 248)
      base = Color.new(120, 184, 232)
    end
    text = "[#{text}]"
    option_width = rect.width / 2
    x_pos += rect.width - option_width
    pbSetSystemFont(self.contents)
    pbDrawShadowText(self.contents, x_pos, rect.y + (self.contents.text_offset_y || 0),
      option_width, rect.height, text, base, shadow, 1)
  end

  def commands=(commands)
    @text_key = []
    commands.each_with_index do |command, i|
      next if !command.is_a?(Array)
      commands[i]  = command[0]
      @text_key[i] = command[1]
    end
    @commands = commands
  end
end