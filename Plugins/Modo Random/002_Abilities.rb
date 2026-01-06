#-------------------------------------------------------------------------------
# Abilities
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Main module to handle randomization of abilities
#-------------------------------------------------------------------------------

module RandomizedChallenge::Ability
  #-----------------------------------------------------------------------------
  # Load randomized ability based on species data
  #-----------------------------------------------------------------------------
  def self.get(key, default, hidden = false)
    # Load default data when switch is off
    return default if !RandomizedChallenge.random_abilities? || !RandomizedChallenge.enabled?
    return default if RandomizedChallenge::SPECIES_WITHOUT_RANDOM_ABS.include?(key)

    # Load randomized data if exists
    all_abilities = self.get_randomized_data
    ret = all_abilities[key]
    return default unless GameData::Species.exists?(key) && ret.is_a?(Hash)
    
    ability_type = hidden ? :hidden : :base
    return default unless ret[ability_type].is_a?(Array)
    
    ret[ability_type]
  end
  #-----------------------------------------------------------------------------
  # Helper: Prepare shuffled ability pool
  #-----------------------------------------------------------------------------
  def self.prepare_shuffled_abilities
    keys = GameData::Ability::DATA.keys.clone
    shuffle_keys = keys.clone.shuffle
    # Delete blacklisted abilities
    RandomizedChallenge::ABILITY_EXCLUSIONS.each do |a|
      shuffle_keys.delete(a)
    end
    shuffle_keys
  end
  #-----------------------------------------------------------------------------
  # Helper: Assign abilities to a species
  #-----------------------------------------------------------------------------
  def self.assign_abilities_to_species(key, sp_data, shuffle_keys)
    $randomized_data[:abilities][key] = { :base => [], :hidden => [] }
    
    # Use shuffle.take to avoid duplicate abilities on the same Pokemon
    base_count = sp_data.real_abilities.length
    hidden_count = sp_data.real_hidden_abilities.length
    total_needed = base_count + hidden_count
    
    selected_abilities = shuffle_keys.shuffle.take(total_needed)
    $randomized_data[:abilities][key][:base] = selected_abilities.take(base_count)
    $randomized_data[:abilities][key][:hidden] = selected_abilities.drop(base_count).take(hidden_count)
  end
  #-----------------------------------------------------------------------------
  # Helper: Assign abilities for semi-randomized mode (evolutionary lines share abilities)
  #-----------------------------------------------------------------------------
  def self.assign_semi_randomized_abilities(shuffle_keys)
    GameData::Species.each do |sp_data|
      key = sp_data.id
      next if $randomized_data[:abilities][key].is_a?(Hash)
      
      # Get abilities from first species in evolutionary line, or create new ones
      first_species = sp_data.get_first_evo
      if $randomized_data[:abilities][first_species].is_a?(Hash)
        ability_hash = $randomized_data[:abilities][first_species]
      else
        assign_abilities_to_species(first_species, GameData::Species.get(first_species), shuffle_keys)
        ability_hash = $randomized_data[:abilities][first_species]
      end
      
      # Apply the same abilities to all Pokemon in the evolutionary line
      sp_data.get_evolutionary_line.each do |pkmn|
        next if $randomized_data[:abilities][pkmn].is_a?(Hash)
        $randomized_data[:abilities][pkmn] = { :base => [], :hidden => [] }
        $randomized_data[:abilities][pkmn][:base] = ability_hash[:base].clone
        $randomized_data[:abilities][pkmn][:hidden] = ability_hash[:hidden].clone
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Helper: Assign abilities for fully randomized mode
  #-----------------------------------------------------------------------------
  def self.assign_fully_randomized_abilities(shuffle_keys)
    GameData::Species.each do |sp_data|
      key = sp_data.id
      assign_abilities_to_species(key, sp_data, shuffle_keys)
    end
  end
  #-----------------------------------------------------------------------------
  # Load all randomized abilities
  #-----------------------------------------------------------------------------
  def self.get_randomized_data
    $randomized_data ||= {}
    return $randomized_data[:abilities] if $randomized_data[:abilities].is_a?(Hash)
    
    $randomized_data[:abilities] = {}
    shuffle_keys = prepare_shuffled_abilities
    
    if $game_switches[RandomizedChallenge::ABILITY_SEMI_RANDOMIZER_SWITCH]
      assign_semi_randomized_abilities(shuffle_keys)
    else
      assign_fully_randomized_abilities(shuffle_keys)
    end
    
    $randomized_data[:abilities]
  end
  #-----------------------------------------------------------------------------
  # Reset randomized data
  #-----------------------------------------------------------------------------
  def self.reset_randomized_data
    # Clear randomized data
    $randomized_data[:abilities] = nil
    get_randomized_data
    # Unrandomize / Rerandomize player Pokemon abilities
    pbEachPokemon do |pkmn, _|
      old_idx = pkmn.ability_index
      pkmn.ability_index = nil
      pkmn.ability_index = old_idx
    end
  end
  #-----------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
# Overriding Species GameData to load new abilities
#-------------------------------------------------------------------------------
module GameData
  class Species
    # Get abilities for species with Randomizer overrides
    def abilities; return RandomizedChallenge::Ability.get(@id, @abilities); end

    # Get hidden abilities for species with Randomizer overrides
    def hidden_abilities; return RandomizedChallenge::Ability.get(@id, @hidden_abilities, true); end

    # Get abilities for species without Randomizer overrides
    def real_abilities; return @abilities; end

    # Get hidden abilities for species without Randomizer overrides
    def real_hidden_abilities; return @hidden_abilities; end

    # utility function to get the first species in the evolutionary line
    def get_first_evo
      prev = GameData::Species.get(@id).get_previous_evo
      return @id if prev == @id

      GameData::Species.get(prev).get_previous_evo
    end

    # utility function to get the previous species in the evolutionary line
    def get_previous_evo
      return @id if @evolutions.empty?

      @evolutions.each { |evo| return GameData::Species.get_species_form(evo[0], @form).id if evo[3] } # Get prevolution
      @id
    end

    # utility function to get every evolution after defined species
    def get_next_evos
      evo = GameData::Species.get(@id).get_evolutions
      all = []
      return [@id] if evo.empty?

      evo.each do |arr|
        all += [GameData::Species.get_species_form(arr[0], @form).id]
        all += GameData::Species.get_species_form(arr[0], @form).get_next_evos
      end
      all.uniq
    end

    # utility function to get all species inside an evolutionary line
    def get_evolutionary_line
      sp = get_first_evo
      ([sp] + GameData::Species.get(sp).get_next_evos).uniq
    end

    # Returns a random mega stone for a given species.
    # If the species has multiple mega forms with different mega stones, one is chosen randomly.
    # Returns nil if the species has no mega forms.
    def get_mega_stone
      mega_stones = []
      species_list = GameData::Species.keys
      # Find all mega forms for this species and collect their mega stones
      species_list.each do |data|
        species_data = GameData::Species.get(data)
        next if species_data.species != @species
        next if species_data.form == 0  # Skip base form
        next unless species_data.mega_stone && species_data.mega_stone != :NONE
        
        mega_stones << species_data.mega_stone
      end
      
      # Return a random mega stone if any were found, otherwise nil
      return mega_stones.empty? ? nil : mega_stones.sample
    end
  end
end

class Pokemon
  attr_accessor :forced_ability

  alias ability_random ability
  def ability
    return GameData::Ability.try_get(@forced_ability) if @forced_ability
    ability_random
  end

  alias ability_id_random ability_id
  def ability_id
    return GameData::Ability.get(@forced_ability).id if @forced_ability
    ability_id_random
  end

  def forced_ability?
    !@forced_ability.nil?
  end

  def forced_ability=(value)
    return if !GameData::Ability.exists?(value) && !value.nil?
    @forced_ability = value
  end

end

#-------------------------------------------------------------------------------
# Save Data for randomized data, so it doesn't change on save reload
#-------------------------------------------------------------------------------
SaveData.register(:randomized_data) do
  save_value { $randomized_data }
  load_value { |value| $randomized_data = value }
  new_game_value { {} }
end
