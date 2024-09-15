#-------------------------------------------------------------------------------
# Overrides of pbItemBall and pbReceiveItem
#-------------------------------------------------------------------------------
# Picking up an item found on the ground
#-------------------------------------------------------------------------------
alias pbItemBall_random pbItemBall
def pbItemBall(item, quantity = 1)
  return pbItemBall_random(item, quantity) unless RandomizedChallenge.randomize_items?

  random_item = RandomizedChallenge.determine_random_item(item)
  pbItemBall_random(random_item, quantity)
end

alias pbReceiveItem_random pbReceiveItem
def pbReceiveItem(item, quantity = 1)
  return pbReceiveItem_random(item, quantity) unless RandomizedChallenge.randomize_items?

  random_item = RandomizedChallenge.determine_random_item(item)
  pbReceiveItem_random(random_item, quantity)
end

alias pbGenerateWildPokemon_randomized pbGenerateWildPokemon
def pbGenerateWildPokemon(species, level, isRoamer = false)
  return pbGenerateWildPokemon_randomized(species, level, isRoamer) unless RandomizedChallenge.randomize_held_items?

  wild_poke = pbGenerateWildPokemon_randomized(species, level, isRoamer)
  wild_poke.item = RandomizedChallenge.random_held_item if wild_poke.item
  wild_poke
end

class TrainerBattle
  class << self
    alias start_random start
    def start(*args)
      outcome = start_random(*args)
      return outcome == 1 unless RandomizedChallenge.enabled? && RandomizedChallenge::TRAINERS_CAN_GIVE_RANDOM_ITEMS

      if outcome ==  1 && RandomizedChallenge.enabled? && RandomizedChallenge::TRAINERS_CAN_GIVE_RANDOM_ITEMS
        chance = RandomizedChallenge::PROBABILITY_OF_RANDOM_ITEMS_FROM_TRAINERS || 15
        give_item = rand < (chance / 100)
        Kernel.pbReceiveItem(:POKEBALL) if give_item
      end
      outcome == 1
    end
  end
end

module RandomizedChallenge
  def self.randomize_items?
    $PokemonGlobal.randomize_items ? true : false
  end

  def self.randomize_held_items?
    $PokemonGlobal.randomize_held_items ? true : false
  end

  def self.random_item(ignore_exclusions = false, no_tm = false, is_held_item = false)
    items = GameData::Item.keys # Get all item IDs
    item = GameData::Item.get(items.sample) # Return the item object
    if !ignore_exclusions && excluded_item?(item)
      item = GameData::Item.get(items.sample) while excluded_item?(item, is_held_item) || (item.is_machine? && no_tm)
    end
    item.move = random_move if (item.is_TM? || item.is_TR?) && RandomizedChallenge::RANDOMIZE_TM_MOVES
    item
  end

  def self.random_held_item(item = :POKEBALL)
    no_tm = !RandomizedChallenge::WILD_CAN_HAVE_TMS
    RandomizedChallenge.determine_random_item(item, no_tm, true)
  end

  def self.random_tm(check_allow_list = true, allow_duplicates = RandomizedChallenge::ALLOW_DUPLICATE_TMS)
    if check_allow_list && !RandomizedChallenge::MTLIST_RANDOM.empty?
      random_tms = RandomizedChallenge::MTLIST_RANDOM.shuffle
      return random_tms.find { |tm_id| !$bag.has?(GameData::Item.get(tm_id)) }
    end
    tm = random_item
    tm = random_item until tm.is_machine? && (allow_duplicates || !$bag.has?(tm))
    tm.move = random_move if (tm.is_TM? || tm.is_TR?) && RandomizedChallenge::RANDOMIZE_TM_MOVES
    tm
  end

  def self.determine_random_item(original_item)
    return original_item if unrandomizable_item?(original_item)

    item = if GameData::Item.get(original_item).is_machine? && RandomizedChallenge::MT_GET_RANDOMIZED_TO_ANOTHER_MT
             random_tm(!RandomizedChallenge::MTLIST_RANDOM.empty?)
           else
             random_item
           end

    return random_item(false, true) if !item && GameData::Item.get(original_item).is_machine?
    return item unless item.is_machine? && $bag.has?(item)

    if RandomizedChallenge::MTLIST_RANDOM.empty? && item.is_machine?
      item = random_tm(false)
    elsif !RandomizedChallenge::MTLIST_RANDOM.empty? && item.is_machine?
      item = random_tm(true)
      item ||= random_item(false, true)
    end

    item
  end

  def self.unrandomizable_item?(item)
    UNRANDOMIZABLE_ITEMS.include?(item) || GameData::Item.get(item).is_key_item? || GameData::Item.get(item).is_HM? ? true : false
  end

  def self.excluded_item?(item, is_held_item = false)
    ITEM_BLACK_LIST.include?(item.id) || (is_held_item && HELD_ITEM_BLACK_LIST.include?(item.id)) || GameData::Item.get(item.id).is_key_item? ? true : false
  end
end

alias pbAddPokemon_random pbAddPokemon
def pbAddPokemon(pkmn, level = 1, see_form = true)
  return pbAddPokemon_random(pkmn, level, see_form) unless RandomizedChallenge::GIFTED_POKEMON_CAN_HAVE_ITEMS && RandomizedChallenge.enabled? && RandomizedChallenge.randomize_held_items?

  poke = Pokemon.new(pkmn, level) unless pkmn.is_a?(Pokemon)
  chance = RandomizedChallenge::GIFTED_POKEMON_ITEM_PROBABILITY.between?(0, 100) ? RandomizedChallenge::GIFTED_POKEMON_ITEM_PROBABILITY : 15
  give_item = rand < (chance / 100)
  poke.item = RandomizedChallenge.random_held_item if give_item
  pbAddPokemon_random(poke, level, see_form)
end

alias pbAddPokemonSilent_random pbAddPokemonSilent
def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return pbAddPokemonSilent_random(pkmn, level, see_form) unless RandomizedChallenge::GIFTED_POKEMON_CAN_HAVE_ITEMS && RandomizedChallenge.enabled? && RandomizedChallenge.randomize_held_items?

  poke = Pokemon.new(pkmn, level) unless pkmn.is_a?(Pokemon)
  chance = RandomizedChallenge::GIFTED_POKEMON_ITEM_PROBABILITY.between?(0, 100) ? RandomizedChallenge::GIFTED_POKEMON_ITEM_PROBABILITY : 15
  give_item = rand < (chance / 100)
  poke.item = RandomizedChallenge.random_held_item if give_item
  pbAddPokemonSilent_random(poke, level, see_form)
end

