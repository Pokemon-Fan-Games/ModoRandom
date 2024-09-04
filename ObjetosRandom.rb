module RandomizedChallenge
  # Lista de objetos que no quieres que aparezcan entre los objetos Random
  ITEM_BLACK_LIST = []

  # Randomizar objetos de salvajes
  RANDOMIZE_WILD_ITEMS = true

  # Lista de objetos que no quieres que aparezcan en los objetos de salvajes
  # es una inclusión adicional sería la ITEM_BLACK_LIST + este listado.
  HELD_ITEM_BLACK_LIST = []

  # Lista de MTs que se pueden generar en el random, si la lista está vacia se randomizará por cualquier MT
  MTLIST_RANDOM = []

  # Objetos que no se randomizarán si son dados en algun evento.
  UNRANDOMIZABLE_ITEMS = []

  ALLOW_DUPLICATE_TMS = false

  # Si en un evento se da una MT se randomizará por otra MT del listado de abajo, a menos que el listado esté vacío
  # Si el listado está vacío se randomizará por cualquier MT
  MT_GET_RANDOMIZED_TO_ANOTHER_MT = true

  def self.item
    item = rand(PBItems.maxValue - 1) + 1
    item_name = PBItems.getName(item)

    # Workaround por si hay huecos en el PBS
    while !item_name || item_name == ''
      item = rand(PBItems.maxValue - 1) + 1
      item_name = PBItems.getName(item)
    end

    item
  end

  def self.random_tm(allow_duplicates = SELF::ALLOW_DUPLICATE_TMS)
    tm = item
    tm = item while !pbIsMachine?(tm) || ($PokemonBag.pbHasItem?(tm) && !allow_duplicates)
    tm
  end

  def self.random_item(ignore_exclusions = false, no_tm = false, is_held_item = false)
    rand_item = item
    if !ignore_exclusions && excluded_item?(rand_item, is_held_item)
      rand_item = item while excluded_item?(rand_item, is_held_item) || (pbIsMachine?(rand_item) && no_tm)
    end
    rand_item
  end

  def self.determine_random_item(original_item)
    return original_item if unrandomizable_item?(original_item)

    if pbIsMachine?(original_item) && self::MT_GET_RANDOMIZED_TO_ANOTHER_MT
      return random_tm if self::MTLIST_RANDOM.empty?

      random_tms = self::MTLIST_RANDOM.shuffle
      random_tms.each do |tm_id|
        return tm_id unless $PokemonBag.pbHasItem?(tm_id)
      end
    else
      rand_item = random_item
      if pbIsMachine?(rand_item) && MTLIST_RANDOM.empty?
        return rand_tm
      elsif pbIsMachine?(rand_item) && !MTLIST_RANDOM.empty?
        random_tms = self::MTLIST_RANDOM.shuffle
        random_tms.each do |tm_id|
          return tm_id unless $PokemonBag.pbHasItem?(tm_id)
        end
      else
        return rand_item
      end

      random_item(false, true)
    end
  end

  def self.unrandomizable_item?(item)
    self::UNRANDOMIZABLE_ITEMS.include?(item) || pbIsKeyItem?(item)
  end

  def self.excluded_item?(item, is_held_item = false)
    self::ITEM_BLACK_LIST.include?(item) || (is_held_item && HELD_ITEM_BLACK_LIST.include?(item)) || pbIsKeyItem?(item)
  end
end

if RandomizedChallenge::RANDOMIZE_WILD_ITEMS
  alias pbGenerateWildPokemon_random pbGenerateWildPokemon
  def pbGenerateWildPokemon(species, level, isroamer = false)
    wild_poke = pbGenerateWildPokemon_random(species, level, isroamer)
    if wild_poke.item && random_enabled?
      item = RandomizedChallenge.determine_random_item(wild_poke.item)
      wild_poke.setItem(item)
    end
    wild_poke
  end
end

module Kernel
  class << self
    alias pbItemBall_random pbItemBall
    def pbItemBall(item, quantity = 1)
      item = getID(PBItems, item) if item.is_a?(String) || item.is_a?(Symbol)
      item = RandomizedChallenge.determine_random_item(item) if random_enabled?
      pbItemBall_random(item, quantity)
    end

    alias pbReceiveItem_random pbReceiveItem
    def pbReceiveItem(item, quantity = 1)
      item = getID(PBItems, item) if item.is_a?(String) || item.is_a?(Symbol)
      item = RandomizedChallenge.determine_random_item(item) if random_enabled?
      pbReceiveItem_random(item, quantity)
    end
  end
end
