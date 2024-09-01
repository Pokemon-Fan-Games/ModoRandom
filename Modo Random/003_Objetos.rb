#-------------------------------------------------------------------------------
# Overrides of pbItemBall and pbReceiveItem
#-------------------------------------------------------------------------------
# Picking up an item found on the ground
#-------------------------------------------------------------------------------
alias pbItemBall_random pbItemBall
def pbItemBall(item, quantity = 1)
  return pbItemBall_random(item, quantity) unless random_enabled?

  random_item = RandomizedChallenge.determine_random_item(item)
  pbItemBall_random(random_item, quantity)
end

alias pbReceiveItem_random pbReceiveItem
def pbReceiveItem(item, quantity = 1)
  return pbReceiveItem_random(item, quantity) unless random_enabled?

  random_item = RandomizedChallenge.determine_random_item(item)
  pbReceiveItem_random(random_item, quantity)
end

module RandomizedChallenge
  def self.item
    items = GameData::Item.keys # Get all item IDs
    GameData::Item.get(items.sample) # Return the item object
  end

  def self.random_tm
    loop do
      tm = item # Calling the item method defined above
      return tm if tm.is_machine? && !$bag.has?(tm)
    end
  end

  def self.random_item
    loop do
      item = item() # Calling the item method defined above
      next if excluded_item?(item)

      return item
    end
  end

  def self.determine_random_item(original_item)
    return original_item if unrandomizable_item?(original_item)

    if GameData::Item.get(original_item).is_machine? && RandomizedChallenge::MT_GET_RANDOMIZED_TO_ANOTHER_MT
      return random_tm if RandomizedChallenge::MTLIST_RANDOM.empty?

      random_tms = RandomizedChallenge::MTLIST_RANDOM.shuffle
      random_tms.each do |tm_id|
        tm_item = GameData::Item.get(tm_id)
        return tm_item unless $bag.has?(tm_item)
      end
    else
      random_item = random_item()
      return random_item unless random_item.is_machine? && $bag.has?(random_item)
    end

    random_tms = RandomizedChallenge::MTLIST_RANDOM.shuffle
    random_tms.each do |tm_id|
      tm_item = GameData::Item.get(tm_id)
      return tm_item unless $bag.has?(tm_item)
    end

    random_item
  end

  def self.unrandomizable_item?(item)
    UNRANDOMIZABLE_ITEMS.include?(item) || GameData::Item.get(item).is_key_item?
  end

  def self.excluded_item?(item)
    ITEM_BLACK_LIST.include?(item.id) || GameData::Item.get(item.id).is_key_item?
  end
end
