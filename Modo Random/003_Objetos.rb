#-------------------------------------------------------------------------------
# Overrides of pbItemBall and pbReceiveItem
#-------------------------------------------------------------------------------
# Picking up an item found on the ground
#-------------------------------------------------------------------------------
alias pbItemBall_random pbItemBall
def pbItemBall(item, quantity = 1)
  return pbItemBall_random(item, quantity) unless randomize_items?

  random_item = RandomizedChallenge.determine_random_item(item)
  random_item.move = random_move if (random_item.is_TM? || random_item.is_TR?) && RandomizedChallenge::RANDOMIZE_TM_MOVES
  pbItemBall_random(random_item, quantity)
end

alias pbReceiveItem_random pbReceiveItem
def pbReceiveItem(item, quantity = 1)
  return pbReceiveItem_random(item, quantity) unless randomize_items?

  random_item = RandomizedChallenge.determine_random_item(item)
  random_item.move = random_move if (random_item.is_TM? || random_item.is_TR?) && RandomizedChallenge::RANDOMIZE_TM_MOVES
  pbReceiveItem_random(random_item, quantity)
end

alias pbGenerateWildPokemon_randomized pbGenerateWildPokemon
def pbGenerateWildPokemon(species, level, isRoamer = false)
  return pbGenerateWildPokemon_randomized(species, level, isRoamer) unless randomize_held_items?

  wild_poke = pbGenerateWildPokemon_randomized(species, level, isRoamer)
  wild_poke.item = RandomizedChallenge.determine_random_item(wild_poke.item, true, true) if wild_poke.item
  wild_poke
end

module RandomizedChallenge
  def self.random_item(ignore_exclusions = false, no_tm = false, is_held_item = false)
    items = GameData::Item.keys # Get all item IDs
    item = GameData::Item.get(items.sample) # Return the item object
    if !ignore_exclusions && excluded_item?(item)
      item = GameData::Item.get(items.sample) while excluded_item?(item, is_held_item) || (item.is_machine? && no_tm)
    end
    item
  end

  def self.random_tm(check_allow_list = true, allow_duplicates = RandomizedChallenge::ALLOW_DUPLICATE_TMS)
    if check_allow_list && !RandomizedChallenge::MTLIST_RANDOM.empty?
      random_tms = RandomizedChallenge::MTLIST_RANDOM.shuffle
      return random_tms.find { |tm_id| !$bag.has?(GameData::Item.get(tm_id)) }
    end
    tm = random_item
    tm = random_item until tm.is_machine? && (allow_duplicates || !$bag.has?(tm))
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
