class DiegoWTsStarterSelection
	alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
	def initialize(pkmn1, pkmn2, pkmn3)
		original_initialize(pkmn1, pkmn2, pkmn3) unless RandomizedChallenge.enabled?
		starter1 = get_starter(0) || pkmn1
		starter2 = get_starter(1) || pkmn2
		starter3 = get_starter(2) || pkmn3
		RandomizedChallenge.pause
		original_initialize(starter1, starter2, starter3)
		RandomizedChallenge.resume
	end
end

class SelectPokemonScene
	alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
	def initialize(switchNum,varNum)
		original_initialize(switchNum,varNum)
		return unless RandomizedChallenge.enabled?
		starter1 = get_starter(0)
		starter2 = get_starter(1)
		starter3 = get_starter(2)
		if starter1 && starter2 && starter3
			@pkmnList = [starter1, starter2, starter3]
		end
	end

	alias original_change_pokemon changePkmn
	def changePkmn
		if RandomizedChallenge.enabled?
			RandomizedChallenge.pause
			original_change_pokemon
			RandomizedChallenge.resume
		end
	end
end

class PokemonGlobalMetadata
  attr_accessor :cached_trade
end
module TradeExpert
	class << self
		alias_method :fetchEqualSpecies, :fetchEqualSpeciesRandom
		alias_method :tradePoke, :tradePokeRandom
		alias_method :start, :startRandom
	end

  def self.start(margin = 0.1)
    # flavour text displaying a little intro for the Trade Expert
		return startRandom(margin) unless RandomizedChallenge.enabled?
    self.displayMsg("intro")
    # confirmation for the trade
    if self.confirmMsg("asktrade")
      giveID = self.givePokemon
      return self.displayMsg("invalid") if giveID.nil?
      give = $player.party[giveID]
      giveBST = self.calcBST(give.species)
      # protects trading from abuse
			$PokemonGlobal.cached_trade ||= {} 
      if $PokemonGlobal.cached_trade[give.species.id]
        recv = $PokemonGlobal.cached_trade[give.species.id]
      else
        recv = self.fetchEqualSpecies(give.species, margin)
        # cancels the trade if the Trade Expert cannot offer you anything in return
        if recv.length < 1
          self.displayMsg("notrade", GameData::Species.get(give.species).real_name)
          return false
        end
        recv = recv[rand(recv.length - 1)]
      end
      self.displayMsg("thinking")
      bst = self.calcBST(recv)
      # flavour text displayed when evaluating the offered Pokemon species
      if bst <= 200
        self.displayMsg("trade0", GameData::Species.get(give.species).real_name)
      elsif bst <= 300
        self.displayMsg("trade1", GameData::Species.get(give.species).real_name)
      elsif bst <= 400
        self.displayMsg("trade2", GameData::Species.get(give.species).real_name)
      elsif bst <= 500
        self.displayMsg("trade3", GameData::Species.get(give.species).real_name)
      elsif bst <= 600
        self.displayMsg("trade4", GameData::Species.get(give.species).real_name)
      else
        self.displayMsg("trade5", GameData::Species.get(give.species).real_name)
      end
      
      
      # final confirmation for the trade
      if self.confirmMsg("propose", GameData::Species.get(recv).real_name, GameData::Species.get(give.species).real_name)
        $cachedTrade.delete("#{giveBST}")
        self.tradePoke(giveID, recv)
        self.displayMsg("accepttrade")
        # self.saveCache
        return true
      else
        self.displayMsg("rejecttrade")
				# protects trading from abuse
				$PokemonGlobal.cached_trade[give.species.id] = recv
        # self.saveCache
        return false
      end
    else
      # the trade was cancelled at the start
      return self.displayMsg("canceltrade")
    end
  end

	def self.fetchEqualSpecies(poke, margin = 0.1)
		return fetchEqualSpeciesRandom(poke, margin) unless RandomizedChallenge.enabled?
		species = random_species
		species = random_species while TradeExpert::TRADING_BLACKLIST.include?(species)
		return [species]
	end

	def self.tradePoke(give, recv)
		return tradePokeRandom(give, recv) unless RandomizedChallenge.enabled?
		RandomizedChallenge.pause
		tradePokeRandom(give, recv)
		RandomizedChallenge.resume
	end
end