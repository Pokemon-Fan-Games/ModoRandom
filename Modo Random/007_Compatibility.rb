if PluginManager.installed?("DiegoWTs Starter Selection") && defined?(DiegoWTsStarterSelection)
  class DiegoWTsStarterSelection
    alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
    def initialize(pkmn1, pkmn2, pkmn3)
      return original_initialize(pkmn1, pkmn2, pkmn3) unless RandomizedChallenge.enabled? 
      starter1 = get_starter(0)&.species || pkmn1
      starter2 = get_starter(1)&.species || pkmn2
      starter3 = get_starter(2)&.species || pkmn3
      RandomizedChallenge.pause
      original_initialize(starter1, starter2, starter3)
      RandomizedChallenge.resume
    end
  end
end

if PluginManager.installed?("Script sencillo para la selección de starters.") && defined?(SelectPokemonScene)
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
end

if PluginManager.installed?("Trade Expert") && defined?(TradeExpert)
  class PokemonGlobalMetadata
    attr_accessor :cached_trade
  end
  module TradeExpert
    class << self
      alias_method :tradePokeRandom, :tradePoke
      alias_method :startRandom, :start
    end

    def self.start(margin = 0.1, skip_intro = false)
      # flavour text displaying a little intro for the Trade Expert
      return startRandom(margin, skip_intro) unless RandomizedChallenge.enabled?
      self.displayMsg("intro") if !skip_intro
      # confirmation for the trade
      if self.confirmMsg("asktrade")
        chosen = self.givePokemon
        if chosen.nil?
          self.displayMsg("invalid")
          return false
        end
        give = $PokemonStorage[chosen[0], chosen[1]]
        if give.nil?
          self.displayMsg("invalid")
          return false
        end
        giveBST = self.calcBST(give.species)
        # protects trading from abuse
        $PokemonGlobal.cached_trade ||= {} 
        if $PokemonGlobal.cached_trade[give.species_data.id]
          recv = $PokemonGlobal.cached_trade[give.species_data.id]
        else
          recv = self.fetchEqualSpecies(give.species, margin)
          # cancels the trade if the Trade Expert cannot offer you anything in return
          if recv.length < 1
            self.displayMsg("notrade", give.species_data.real_name)
            return false
          end
          recv = recv[rand(recv.length - 1)]
        end
        self.displayMsg("thinking")
        bst = self.calcBST(recv)
        # flavour text displayed when evaluating the offered Pokemon species
        if bst <= 200
          self.displayMsg("trade0", give.species_data.real_name)
        elsif bst <= 300
          self.displayMsg("trade1", give.species_data.real_name)
        elsif bst <= 400
          self.displayMsg("trade2", give.species_data.real_name)
        elsif bst <= 500
          self.displayMsg("trade3", give.species_data.real_name)
        elsif bst <= 600
          self.displayMsg("trade4", give.species_data.real_name)
        else
          self.displayMsg("trade5", give.species_data.real_name)
        end
        
        # final confirmation for the trade
        recv_data = GameData::Species.get(recv)
        if self.confirmMsg("propose", recv_data.real_name, GameData::Species.get(give.species).real_name)
          # $cachedTrade.delete("#{giveBST}")
          self.tradePoke(chosen, recv)
          self.displayMsg("accepttrade")
          $PokemonGlobal.cached_trade.delete(give.species_data.id)
          # self.saveCache
          return true
        else
          self.displayMsg("rejecttrade")
          # protects trading from abuse
          $PokemonGlobal.cached_trade[give.species_data.id] = recv_data.id
          # self.saveCache
          return true
        end
      else
        # the trade was cancelled at the start
        self.displayMsg("canceltrade")
        return false
      end
    end
  end
end
if defined?(pbStartRadar)
  alias pbStartRadar_randomized pbStartRadar
  def pbStartRadar
    return pbStartRadar_randomized if !RandomizedChallenge.enabled? || !RandomizedChallenge.randomize_pokemon? || RandomizedChallenge.consistent_wild_encounters?
    pbMessage(_INTL('En el modo random donde los Pokémon de las rutas son 100% aleatorios el busca salvajes no mostrará información correcta'))
    return
  end
end

class EncounterList_Scene
  alias initialize_random initialize
  def initialize
    initialize_random
    if RandomizedChallenge.randomize_pokemon? && RandomizedChallenge.consistent_wild_encounters?
      @encounter_tables = $PokemonGlobal.random_encounter_table[$game_map.map_id] || {}
      @max_enc, @eLength = @encounter_tables.empty? ? [1, 1] : getMaxEncounters(@encounter_tables)
      pbMessage(_INTL('En el modo random el busca salvajes estará vacío hasta que entres al menos en 1 combate con salvajes por ruta')) if @encounter_tables.empty?
    end
  end
end

