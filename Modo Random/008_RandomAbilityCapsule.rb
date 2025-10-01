# Lista de habilidades baneados
ALLOW_REUSE = true
class PokemonGlobalMetadata
  attr_accessor :last_used_id, :random_abs_pokes

  alias global_init_dp initialize
  def initialize
    global_init_dp
    @last_used_id = 0
  end
end

class Pokemon
  attr_accessor :id

  def randomize_ability_set_with_capsule
    # Initialize the storage if needed
    return unless $PokemonGlobal
    $PokemonGlobal.random_abs_pokes = {} unless $PokemonGlobal.random_abs_pokes
    
    # Get available abilities (excluding blacklisted ones)
    abilities = GameData::Ability.keys.clone
    RandomizedChallenge::ABILITY_EXCLUSIONS.each do |excluded|
      abilities.delete(excluded)
    end
    
    return false if abilities.empty?
    
    # Get the original ability list structure
    original_list = self.original_getAbilityList
    
    # Create a new randomized ability set for this specific Pokémon
    new_ability_list = []
    
    # Replace each ability in the original list with a random one
    original_list.each do |abil_data|
      ability_id, ability_index = abil_data
      random_ability = abilities.sample
      new_ability_list.push([random_ability, ability_index])
    end
    
    # Store this randomized set
    $PokemonGlobal.random_abs_pokes[@id] = new_ability_list
    
    # Force the Pokémon to recalculate its ability with the new randomized set
    old_index = @ability_index
    @ability = nil
    @ability_index = nil
    
    # Set ability index to the first available ability in the new set
    if new_ability_list.length > 0
      @ability_index = new_ability_list[0][1]  # Use the index from first ability
      @ability = new_ability_list[0][0]        # Set the ability ID directly
    end
    
    true
  end
  
  def has_been_randomized_by_capsule?
    return false unless $PokemonGlobal && $PokemonGlobal.random_abs_pokes
    $PokemonGlobal.random_abs_pokes.key?(@id) && $PokemonGlobal.random_abs_pokes[@id].is_a?(Array)
  end
  
  # Override getAbilityList to use capsule randomization if available
  alias original_getAbilityList getAbilityList
  def getAbilityList
    if has_been_randomized_by_capsule?
      return $PokemonGlobal.random_abs_pokes[@id]
    else
      return original_getAbilityList
    end
  end
  
  # Override ability_id to use capsule randomization
  alias original_ability_id ability_id
  def ability_id
    if has_been_randomized_by_capsule?
      # If we have a set ability index, find the corresponding ability from our randomized set
      if @ability_index
        randomized_list = $PokemonGlobal.random_abs_pokes[@id]
        randomized_list.each do |abil_data|
          ability_id, ability_index = abil_data
          return ability_id if ability_index == @ability_index
        end
        # If not found, return the first ability
        return randomized_list[0][0] if randomized_list.length > 0
      else
        # No ability index set, return first randomized ability
        randomized_list = $PokemonGlobal.random_abs_pokes[@id]
        return randomized_list[0][0] if randomized_list.length > 0
      end
    end
    return original_ability_id
  end
end

ItemHandlers::UseOnPokemon.add(:RANDOMABILITYCAPSULE, proc { |item, qty, pokemon, scene|
  unless pokemon.id
    $PokemonGlobal.last_used_id += 1
    pokemon.id = $PokemonGlobal.last_used_id
  end

  if pokemon.has_been_randomized_by_capsule? && !ALLOW_REUSE
    pbMessage(_INTL("Las habilidades de #{pokemon.name} ya fueron randomizadas"))
    next false
  elsif ALLOW_REUSE && pokemon.has_been_randomized_by_capsule?
    unless pbConfirmMessageSerious(_INTL("Las habilidades de #{pokemon.name} ya fueron randomizadas, ¿estás seguro que quieres randomizarlas de nuevo?"))
      next false
    end
  end

  if pokemon.randomize_ability_set_with_capsule
    pbMessage(_INTL("¡El conjunto de habilidades de #{pokemon.name} fue randomizado!"))
    scene.pbRefresh if scene
    next true
  else
    pbMessage(_INTL("No se pudo randomizar las habilidades de #{pokemon.name}"))
    next false
  end
})
