class PokemonGlobalMetadata
  attr_accessor :given_tm_moves
end

#-------------------------------------------------------------------------------
# Overrides of pbItemBall and pbReceiveItem
#-------------------------------------------------------------------------------
# Picking up an item found on the ground
#-------------------------------------------------------------------------------
alias pbItemBall_random pbItemBall
def pbItemBall(item, quantity = 1, outfit_change = nil, randomize = true)
  return pbItemBall_random(item, quantity, outfit_change) unless RandomizedChallenge.randomize_items? && randomize

  random_item = RandomizedChallenge.determine_random_item(item)
  pbItemBall_random(random_item, quantity, outfit_change)
end

alias pbReceiveItem_random pbReceiveItem
def pbReceiveItem(item, quantity = 1, outfit_change = nil, randomize = true)
  return pbReceiveItem_random(item, quantity, outfit_change) unless RandomizedChallenge.randomize_items? && randomize

  random_item = RandomizedChallenge.determine_random_item(item)
  pbReceiveItem_random(random_item, quantity, outfit_change)
end

EventHandlers.add(:on_wild_species_chosen, :randomize_wild_species,
  proc { |encounter|
    $PokemonGlobal.dont_randomize.delete_at($PokemonGlobal.dont_randomize.index(encounter[0])) if $PokemonGlobal.dont_randomize&.include?(encounter[0])
    RandomizedChallenge.resume_random_species if RandomizedChallenge.consistent_wild_encounters? && $PokemonGlobal.dont_randomize&.empty?
  }
)

EventHandlers.add(:on_wild_pokemon_created, :randomize_wild_pokemon_item,
  proc { |pokemon|
    pokemon.item = RandomizedChallenge.random_held_item if pokemon.item && RandomizedChallenge.randomize_held_items?
  }
)

EventHandlers.add(:on_end_battle, :gift_random_item,
  proc { |decision, _canLose, battle|
    next if !RandomizedChallenge::TRAINERS_CAN_GIVE_RANDOM_ITEMS || !RandomizedChallenge.enabled? || decision != 1 || !battle.trainerBattle?
    chance = RandomizedChallenge::PROBABILITY_OF_RANDOM_ITEMS_FROM_TRAINERS || 15
    give_item = rand < (chance / 100)
    pbReceiveItem(:POKEBALL) if give_item
  }
)

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
    if (item.is_TM? || item.is_TR?) && RandomizedChallenge::RANDOMIZE_TM_MOVES
      move = find_valid_move(0, [], true)
      item.move = move
      $PokemonGlobal.given_tm_moves << move
    end
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

