class PokemonGlobalMetadata
	attr_accessor :enable_random_evolutions, :enable_random_evolutions_similar_bst,
				  :enable_random_evolutions_respect_restrictions
end

module RandomizedChallenge
	def self.evolutions_on?
		$PokemonGlobal.enable_random_evolutions ? true : false
	end

	def self.evolutions_similar_bst_on?
		$PokemonGlobal.enable_random_evolutions_similar_bst ? true : false
	end

	def self.evos_respect_restrictions?
		$PokemonGlobal.enable_random_evolutions_respect_restrictions
	end
end

class Pokemon
	def get_random_evo(_current_species, new_species)
		species_list = GameData::Species.keys
		return species_list.sample unless RandomizedChallenge.evolutions_similar_bst_on? || RandomizedChallenge.evos_respect_restrictions?

		filtered_species = species_list.select do |species|
			species_bst = GameData::Species.get(species).base_stats.values.sum

			if RandomizedChallenge.evolutions_similar_bst_on?
			new_species_bst = GameData::Species.get(new_species).base_stats.values.sum
			species_bst.between?(new_species_bst * 0.9, new_species_bst * 1.1) && valid_pokemon?(species, true)
			elsif RandomizedChallenge.evos_respect_restrictions?
			valid_pokemon?(species)
			end
		end

		filtered_species.sample
	end
	
	def check_evolution_internal
		return nil if egg? || shadowPokemon?
		return nil if hasItem?(:EVERSTONE)
		return nil if hasAbility?(:BATTLEBOND)

		species_data.get_evolutions(true).each do |evo| # [new_species, method, parameter, boolean]
			next if evo[3] # Prevolution
			if RandomizedChallenge.enabled? && RandomizedChallenge::CHANGE_EVO_METHODS.include?(evo[1].to_s)
				ret = yield self, evo[0], "Level", RandomizedChallenge::DIFFICULT_EVO_LEVEL
			elsif RandomizedChallenge.evolutions_on?
				ret = yield self, get_random_evo(self, evo[0]), evo[1], evo[2] # pkmn, new_species, method, parameter
			else
				ret = yield self, evo[0], evo[1], evo[2] # pkmn, new_species, method, parameter
			end
			return ret if ret
		end
		nil
	end
end

class PokemonEvolutionScene
	alias pbEvolutionSuccess_random pbEvolutionSuccess
	def pbEvolutionSuccess
	  previous_level = @pokemon.level
	  pbEvolutionSuccess_random
	  @pokemon.form = GameData::Species.get(@pokemon.species).base_form
	  @pokemon.level = previous_level if RandomizedChallenge.evolutions_on? && @pokemon.level != previous_level
	end
end