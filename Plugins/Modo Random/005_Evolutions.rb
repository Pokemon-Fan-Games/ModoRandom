# Evolution randomization constants
module EvolutionRandomizer
  # BST (Base Stat Total) tolerance for similar strength evolutions
  BST_LOWER_BOUND = 0.9  # 90% of original BST
  BST_UPPER_BOUND = 1.1  # 110% of original BST
  
  # Maximum attempts to find a valid evolution to prevent infinite loops
  MAX_EVOLUTION_ATTEMPTS = 1000
end

# Extends PokemonGlobalMetadata to store evolution randomization settings
class PokemonGlobalMetadata
  attr_accessor :enable_random_evolutions, :enable_random_evolutions_similar_bst,
                :enable_random_evolutions_respect_restrictions
end

# Module containing evolution randomization logic
module RandomizedChallenge
  # Checks if evolution randomization is enabled
  # @return [Boolean] true if random evolutions are enabled
  def self.evolutions_on?
    !!$PokemonGlobal&.enable_random_evolutions
  end

  # Checks if evolution should maintain similar base stat totals
  # @return [Boolean] true if BST similarity is required
  def self.evolutions_similar_bst_on?
    !!$PokemonGlobal&.enable_random_evolutions_similar_bst
  end

  # Checks if evolutions should respect game restrictions
  # @return [Boolean] true if restrictions should be respected
  def self.evos_respect_restrictions?
    !!$PokemonGlobal&.enable_random_evolutions_respect_restrictions
  end
end

# Extends Pokemon class with evolution randomization functionality
class Pokemon
  # Finds a random evolution target based on configured constraints
  # @param _current_species [Symbol] the current species (unused but kept for compatibility)
  # @param new_species [Symbol] the intended evolution target
  # @return [Symbol, nil] random species that meets criteria, or nil if none found
  def get_random_evo(_current_species, new_species)
    species_list = GameData::Species.keys
    
    return nil if species_list.empty?  # Safety check
    
    # If no special constraints are enabled, return any random species
    if !RandomizedChallenge.evolutions_similar_bst_on? && !RandomizedChallenge.evos_respect_restrictions?
      return species_list.sample
    end
    
    # Get target species data once to avoid repeated lookups
    target_species_data = GameData::Species.get(new_species)
    return species_list.sample unless target_species_data  # Fallback if target invalid
    
    target_bst = target_species_data.base_stats.values.sum if RandomizedChallenge.evolutions_similar_bst_on?
    
    # Filter species based on enabled constraints
    filtered_species = species_list.filter_map do |species|
      species_data = GameData::Species.get(species)
      next unless species_data  # Skip invalid species
      
      # Check BST similarity constraint
      if RandomizedChallenge.evolutions_similar_bst_on?
        species_bst = species_data.base_stats.values.sum
        bst_valid = species_bst.between?(
          target_bst * EvolutionRandomizer::BST_LOWER_BOUND,
          target_bst * EvolutionRandomizer::BST_UPPER_BOUND
        )
        next unless bst_valid
        
        # Also check validity if both constraints are enabled
        next unless valid_pokemon?(species, true) if RandomizedChallenge.evos_respect_restrictions?
      elsif RandomizedChallenge.evos_respect_restrictions?
        # Only respect restrictions constraint
        next unless valid_pokemon?(species)
      end
      
      species  # Include this species in the filtered list
    end
    
    # Return random species from filtered list, or fallback to any species
    filtered_species.empty? ? species_list.sample : filtered_species.sample
  end
  
  # Internal method to check and process evolution logic
  # @return [Object, nil] evolution result or nil if no evolution occurs
  def check_evolution_internal
    # Early returns for conditions that prevent evolution
    return nil if egg? || shadowPokemon?
    return nil if hasItem?(:EVERSTONE)
    return nil if hasAbility?(:BATTLEBOND)
    return nil if hasItem?(:SUPEREVIOLITE)
    
    evolutions = species_data&.get_evolutions(true)
    return nil unless evolutions  # Safety check
    
    evolutions.each do |evo| # [new_species, method, parameter, boolean]
      next if evo[3]  # Skip prevolutions
      if RandomizedChallenge.evolutions_on? #&& RandomizedChallenge.evolutions_similar_bst_on?
        random_species = get_random_evo(self, evo[0])
      else
        random_species = evo[0]
      end
      # Determine evolution parameters based on randomization settings
      if RandomizedChallenge.enabled? && RandomizedChallenge::CHANGE_EVO_METHODS.include?(evo[1].to_s) 
        # Use simplified evolution method for randomized challenge
        ret = yield self, random_species, "Level", RandomizedChallenge::DIFFICULT_EVO_LEVEL
      else
        # Use standard evolution
        ret = yield self, random_species, evo[1], evo[2]
      end
      
      return ret if ret  # Return first successful evolution
    end
    
    nil  # No evolution occurred
  end
end

# Extends PokemonEvolutionScene to handle random evolution display
class PokemonEvolutionScene
  alias pbEvolutionSuccess_random pbEvolutionSuccess
  
  # Handles successful evolution with random evolution considerations
  # Preserves the Pokemon's level and sets proper form when random evolutions are enabled
  def pbEvolutionSuccess
    return pbEvolutionSuccess_random unless @pokemon  # Safety check
    if RandomizedChallenge.enabled? && @pokemon.forced_ability? && @pokemon.traded?
      @pokemon.forced_ability = nil
    end
    return pbEvolutionSuccess_random unless RandomizedChallenge.evolutions_on?
    
    # Store original level to preserve it through random evolution
    previous_level = @pokemon.level
    
    # Execute the original evolution success logic
    pbEvolutionSuccess_random
    
    # Apply post-evolution adjustments for random evolutions
    if @pokemon
      # Reset to base form for the new species
      # base_form = @pokemon.species_data&.base_form
      # @pokemon.form = base_form if base_form
      form = @pokemon.form
      
      # Restore original level if it was modified during evolution
      if @pokemon.level != previous_level
        @pokemon.level = previous_level
      end
    end
  end
end