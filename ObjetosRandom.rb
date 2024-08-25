module RandomizedChallenge

  # Lista de objetos que no quieres que aparezcan entre los objetos Random
  ITEM_BLACK_LIST = []

  # Lista de MTs que se pueden generar en el random, si la lista está vacia se randomizará por cualquier MT
  MTLIST_RANDOM = []

  # Objetos que no se randomizarán si son dados en algun evento.
  UNRANDOMIZABLE_ITEMS = []

  # Si en un evento se da una MT se randomizará por otra MT del listado de abajo, a menos que el listado esté vacío
  # Si el listado está vacío se randomizará por cualquier MT
  MT_GET_RANDOMIZED_TO_ANOTHER_MT = true

  def self.item
    rand(PBItems.maxValue)
  end

  def self.random_tm
    loop do
      tm = item
      return tm if pbIsMachine?(tm) && !$PokemonBag.pbHasItem?(tm)
    end
  end

  def self.random_item
    loop do
      rand_item = item
      next if excluded_item?(rand_item)

      return rand_item
    end
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
      return rand_item unless pbIsMachine?(rand_item) && $PokemonBag.pbHasItem?(rand_item)
    end

    random_tms = self::MTLIST_RANDOM.shuffle
    random_tms.each do |tm_id|
      return tm_id unless $PokemonBag.pbHasItem?(tm_id)
    end

    random_item
  end

  def self.unrandomizable_item?(item)
    self::UNRANDOMIZABLE_ITEMS.include?(item) || pbIsKeyItem?(item)
  end

  def self.excluded_item?(item)
    self::ITEM_BLACK_LIST.include?(item.id) || pbIsKeyItem?(item)
  end
end
