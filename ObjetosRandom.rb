class PokemonGlobalMetadata
  attr_accessor :tm_list, :given_tm_moves, :random_items_enabled,
                :random_held_items, :tm_moves, :random_tm_item_used,
                :wild_paused, :dont_randomize, :tm_mart,
                :random_items_from_trainers
  alias initialize_item_random initialize
  def initialize
    initialize_item_random
    @tm_moves = {}
    @tm_mart = {}
    @random_items_from_trainers = false
  end
end

# Configuracion Objetos Random
module RandomizedChallenge
  RANDOM_ITEMS_DEFAULT_VALUE = true
  RANDOM_HELD_ITEMS_DEFAULT_VALUE = true

  HELD_ITEM_CAN_BE_A_TM = false

  # Lista de objetos que no quieres que aparezcan entre los objetos Random
  # Ningun objeto clave podrá salir en el random a pesar de que no se incluya en este listado.
  ITEM_BLACK_LIST = []

  HELD_ITEM_BLACK_LIST = []

  
  # Objetos que no se randomizarán si son dados en algun evento.
  # Cualquier objeto clave que den en un evento, jamás será randomizado
  UNRANDOMIZABLE_ITEMS = []

  # Si en un evento se da una MT se randomizará por otra MT del listado de abajo, a menos que el listado esté vacío
  # Si el listado está vacío se randomizará por cualquier MT
  MT_GET_RANDOMIZED_TO_ANOTHER_MT = true

  # Lista de MTs que se pueden generar en el random, si la lista está vacia se randomizará por cualquier MT
  MTLIST_RANDOM = []


  # Randomizar el movimiento que enseña la MT
  RANDOMIZE_TM_MOVES = true

  # Ataques de MTs que no se pueden randomizar aunque el RANDOMIZE_TM_MOVES esté activo
  UNRANDOMIZABLE_TMS = [PBItems::TM94]

  # Randomizar objetos de salvajes
  RANDOMIZE_WILD_ITEMS = true

  # Los Pokemon de regalo o intercambio pueden tener equipado un objeto random
  GIFTED_POKEMON_CAN_HAVE_ITEMS = true

  # Porcentaje de probabilidad de que un pokemon pokemon regalado o de intercambio tenga un objeto random
  # Valor entre 1 y 100
  # Si la constante está en true y la siguiente contante tiene un valor que no este entre 1 y 100
  # se pondra por defecto en 15
  PROBABILITY_OF_ITEMS_IN_GIFTED_POKEMON = 30

  # Al vencer entrenadores te pueden dar un objeto random
  BEATEN_TRAINERS_CAN_GIVE_ITEMS = true

  # Porcentaje de probabilidad de que entrenador de un objeto random al vencerlo
  # Valor entre 1 y 100
  # Si la constante está en true y la siguiente contante tiene un valor que no este entre 1 y 100
  # se pondra por defecto en 10
  PROBABILITY_OF_ITEMS_FROM_BEATEN_TRAINERS = 10

  MT_MOVES_RESPECT_PROGRESSIVE_RANDOM = true
end


def enable_random_items
  $PokemonGlobal.random_items_enabled = RandomizedChallenge::RANDOM_ITEMS_DEFAULT_VALUE
  $PokemonGlobal.random_held_items = RandomizedChallenge::RANDOM_HELD_ITEMS_DEFAULT_VALUE
  $PokemonGlobal.random_items_from_trainers = RandomizedChallenge::BEATEN_TRAINERS_CAN_GIVE_ITEMS
end


def random_items_enabled?
  random_enabled? && $PokemonGlobal.random_items_enabled && !semi_random_mode? ? true : false
end

def toggle_random_items
  if $PokemonGlobal.random_items_enabled.nil?
    $PokemonGlobal.random_items_enabled = RandomizedChallenge::RANDOM_ITEMS_DEFAULT_VALUE
  else
    $PokemonGlobal.random_items_enabled = !$PokemonGlobal.random_items_enabled
  end

  if $PokemonGlobal.random_held_items.nil?
    $PokemonGlobal.random_held_items = RandomizedChallenge::RANDOM_HELD_ITEMS_DEFAULT_VALUE
  else
    $PokemonGlobal.random_held_items = !$PokemonGlobal.random_held_items
  end

  if $PokemonGlobal.random_items_from_trainers.nil?
    $PokemonGlobal.random_items_from_trainers = RandomizedChallenge::BEATEN_TRAINERS_CAN_GIVE_ITEMS
  else
    $PokemonGlobal.random_items_from_trainers = !$PokemonGlobal.random_items_from_trainers
  end
end

def pause_random_items
  $PokemonGlobal.random_items_enabled = false if random_items_enabled?
end

def resume_random_items
  $PokemonGlobal.random_items_enabled = true unless random_items_enabled?
end

def random_held_items_enabled?
  random_enabled? && $PokemonGlobal.random_held_items ? true : false
end

def toggle_random_held_items
  if $PokemonGlobal.random_held_items.nil?
    $PokemonGlobal.random_held_items = RandomizedChallenge::RANDOM_HELD_ITEMS_DEFAULT_VALUE
  else
    $PokemonGlobal.random_held_items = !$PokemonGlobal.random_held_items
  end
end

def random_items_from_trainers?
  $PokemonGlobal.random_items_from_trainers ? true : false
end

def pause_random_items_from_trainers
  $PokemonGlobal.random_items_from_trainers = false
end 

def resume_random_items_from_trainers
  $PokemonGlobal.random_items_from_trainers = true
end

module RandomizedChallenge
  def self.initialize_tm_list
    return if $PokemonGlobal.tm_list && $PokemonGlobal.tm_list.length > 0

    $PokemonGlobal.tm_list = [] if !$PokemonGlobal.tm_list

    (0..PBItems.maxValue).each do |item|
      item_name = PBItems.getName(item)
      next if !item_name || item_name == '' || !pbIsTechnicalMachine?(item)

      $PokemonGlobal.tm_list << item
    end
  end

  def self.get_item
    item = rand(PBItems.maxValue - 1) + 1
    item_name = PBItems.getName(item)
    while !item_name || item_name == ''
      item = rand(PBItems.maxValue - 1) + 1
      item_name = PBItems.getName(item)
    end

    item
  end

  def self.random_tm
    initialize_tm_list
    tm_index = rand($PokemonGlobal.tm_list.length)
    tm = $PokemonGlobal.tm_list[tm_index]
    count = 0
    while $PokemonBag.pbHasItem?(tm) && count < $PokemonGlobal.tm_list.length
      tm_index = rand($PokemonGlobal.tm_list.length)
      tm = $PokemonGlobal.tm_list[tm_index]
      count += 1
    end
    !$PokemonBag.pbHasItem?(tm) ? tm : random_item(false, true)
  end

  def self.random_item(ignore_exclusions = false, no_tm = false, is_held_item = false)
    rand_item = get_item
    if !ignore_exclusions && (excluded_item?(rand_item, is_held_item) || (pbIsTechnicalMachine?(rand_item) && no_tm))
      rand_item = get_item while excluded_item?(rand_item, is_held_item) || (pbIsTechnicalMachine?(rand_item) && no_tm)
    end

    rand_item
  end

  def self.held_item
    no_tm = !self::HELD_ITEM_CAN_BE_A_TM
    random_item(false, no_tm, true)
  end

  def self.determine_random_item(original_item = PBItems::POKEBALL)
    return original_item if unrandomizable_item?(original_item)

    item_id = original_item.is_a?(String) || original_item.is_a?(Symbol) ? getID(PBItems, original_item) : original_item
    if pbIsTechnicalMachine?(item_id) && self::MT_GET_RANDOMIZED_TO_ANOTHER_MT
      return random_tm if self::MTLIST_RANDOM.empty?

      random_tms = self::MTLIST_RANDOM.shuffle
      random_tms.each do |tm_id|
        return tm_id unless $PokemonBag.pbHasItem?(tm_id)
      end
    else
      rand_item = random_item
      if pbIsTechnicalMachine?(rand_item) && MTLIST_RANDOM.empty? && $PokemonBag.pbHasItem?(rand_item)
        return random_tm
      elsif pbIsTechnicalMachine?(rand_item) && !MTLIST_RANDOM.empty? && $PokemonBag.pbHasItem?(rand_item)
        random_tms = self::MTLIST_RANDOM.shuffle
        random_tms.each do |tm_id|
          return tm_id unless $PokemonBag.pbHasItem?(tm_id)
        end
      end

      return rand_item unless pbIsTechnicalMachine?(rand_item) && $PokemonBag.pbHasItem?(rand_item)

      random_item(false, true)
    end
  end

  def self.unrandomizable_item?(item)
    item_id = item.is_a?(String) || item.is_a?(Symbol) ? getID(PBItems, item) : item

    return true if self::UNRANDOMIZABLE_ITEMS.include?(item_id) || pbIsKeyItem?(item_id) || pbIsHiddenMachine?(item_id) || pbIsMegaStone?(item_id)

    false
  end

  def self.excluded_item?(item, is_held_item = false)
    item_id = item.is_a?(String) || item.is_a?(Symbol) ? getID(PBItems, item) : item

    return true if self::ITEM_BLACK_LIST.include?(item_id) || (is_held_item && HELD_ITEM_BLACK_LIST.include?(item_id)) || pbIsKeyItem?(item_id) || pbIsMegaStone?(item_id)

    false
  end


  def self.get_random_tms(amount = 5)
    tms = []
    tms_hash = {}
    timeout = 10
    try_count = 0
    amount.times do |i|
      tm = RandomizedChallenge.random_tm
      try_count = 0
      while tms_hash[tm] && try_count < timeout
        tm = RandomizedChallenge.random_tm
        try_count += 1
      end
      tms << tm
      tms_hash[tm] = true
    end
    return tms.uniq
  end
  
  def self.tm_mart(id, amount = 5, types=[])
    $PokemonGlobal.tm_mart ||= {}
    tms = $PokemonGlobal.tm_mart[id]
    return tms if tms
    tms = get_random_tms(amount)
    randomize_tm_moves(tms, types) if RandomizedChallenge::RANDOMIZE_TM_MOVES
    $PokemonGlobal.tm_mart[id] = tms
    return tms
  end
  
  def self.randomize_tm_moves(tms, types = [])
    $PokemonGlobal.tm_moves ||= {}
    tms.each do |tm|
      tm = getID(PBItems, tm) if tm.is_a?(String) || tm.is_a?(Symbol)
      next if UNRANDOMIZABLE_TMS.include?(tm)
      if $PokemonGlobal.tm_moves && !$PokemonGlobal.tm_moves[tm]
        progresive = progressive_random_on? && $Trainer.numbadges < 3 && RandomizedChallenge::MT_MOVES_RESPECT_PROGRESSIVE_RANDOM ? true : false
        move = progresive ? find_valid_move(true, 70, true, nil, types) : find_valid_move(false, 0, true, nil, types)
        $PokemonGlobal.given_tm_moves << move
        $ItemData[tm][ITEMMACHINE] = move
        $PokemonGlobal.tm_moves[tm] = move
      end
    end
  end

end

alias pbAddPokemon_random pbAddPokemon
def pbAddPokemon(pkmn, level = nil, seeform = true)
  return pbAddPokemon_random(pkmn, level, seeform) unless random_enabled? && RandomizedChallenge::GIFTED_POKEMON_CAN_HAVE_ITEMS
  return if !pkmn || !$Trainer

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("¡No hay espacio para el Pokémon!\1"))
    Kernel.pbMessage(_INTL('¡Las Cajas del PC están llenas y no aceptan ni un Pokémon más!'))
    return false
  end

  pkmn = getID(PBSpecies, pkmn) if pkmn.is_a?(String) || pkmn.is_a?(Symbol)
  resume_wild_species
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $Trainer) if pkmn.is_a?(Integer) && level.is_a?(Integer)

  return false unless pkmn.is_a?(PokeBattle_Pokemon)

  probability = RandomizedChallenge::PROBABILITY_OF_ITEMS_IN_GIFTED_POKEMON
  probability = (probability.to_f / 100) if probability.between?(1, 100)
  probability ||= 30 / 100.0

  item = 0
  item = RandomizedChallenge.held_item if rand < probability
  pkmn.setItem(item) if item > 0 && !semi_random_mode?
  pbAddPokemon_random(pkmn, level, seeform)
end

alias pbAddPokemonSilent_random pbAddPokemonSilent
def pbAddPokemonSilent(pkmn, level = nil, seeform = true)
  return pbAddPokemonSilent_random(pkmn, level, seeform) unless random_enabled? && RandomizedChallenge::GIFTED_POKEMON_CAN_HAVE_ITEMS

  return if !pkmn || !$Trainer

  pkmn = getID(PBSpecies, pkmn) if pkmn.is_a?(String) || pkmn.is_a?(Symbol)
  pkmn = PokeBattle_Pokemon.new(pkmn, level, $Trainer) if pkmn.is_a?(Integer) && level.is_a?(Integer)

  return false unless pkmn.is_a?(PokeBattle_Pokemon)

  probability = RandomizedChallenge::PROBABILITY_OF_ITEMS_IN_GIFTED_POKEMON
  probability = (probability.to_f / 100) if probability.between?(1, 100)
  probability ||= 30 / 100.0

  item = 0
  item = RandomizedChallenge.held_item if rand < probability
  pkmn.setItem(item) if item > 0 && !semi_random_mode?
  pbAddPokemonSilent_random(pkmn, level, seeform)
end



alias pbTrainerBattle_random pbTrainerBattle
def pbTrainerBattle(trainerid, trainername, endspeech,
                    doublebattle = false, trainerparty = 0, canlose = false, variable = nil)
  won = pbTrainerBattle_random(trainerid, trainername, endspeech, doublebattle,
                               trainerparty, canlose, variable)

  return won unless won
  return won unless random_enabled? && random_items_enabled? && random_items_from_trainers? && !semi_random_mode?

  probability = RandomizedChallenge::PROBABILITY_OF_ITEMS_FROM_BEATEN_TRAINERS
  probability = (probability.to_f / 100) if probability.between?(1, 100)
  probability ||= 10 / 100.0

  if rand < probability
    item = RandomizedChallenge.random_item(false,true)
    pause_random_items
    Kernel.pbReceiveItem(item)
    resume_random_items
  end
  won
end

module Kernel
  class << self
    alias pbItemBall_random pbItemBall
    def pbItemBall(item, quantity = 1)
      original_item = item
      if random_items_enabled? && !semi_random_mode?
        new_item = RandomizedChallenge.determine_random_item(original_item)
        item = new_item
        item = getID(PBItems, item) if item.is_a?(String) || item.is_a?(Symbol)

        if pbIsTechnicalMachine?(item) && RandomizedChallenge::RANDOMIZE_TM_MOVES && !RandomizedChallenge::UNRANDOMIZABLE_TMS.include?(item)
          progresive = progressive_random_on? && $Trainer.numbadges < 3 && RandomizedChallenge::MT_MOVES_RESPECT_PROGRESSIVE_RANDOM ? true : false
          move = progresive ? find_valid_move(true, 70, true) : find_valid_move(false, 0, true)
          $PokemonGlobal.given_tm_moves << move
          $PokemonGlobal.tm_moves ||= {}
          $ItemData[item][ITEMMACHINE] = move
          $PokemonGlobal.tm_moves[item] = move
        end
      end
      pbItemBall_random(item, quantity)
    end

    alias pbReceiveItem_random pbReceiveItem
    def pbReceiveItem(item, quantity = 1)
      original_item = item
      if random_items_enabled? && semi_random_mode?
        new_item = RandomizedChallenge.determine_random_item(original_item)
        item = new_item
        item = getID(PBItems, item) if item.is_a?(String) || item.is_a?(Symbol)

        if pbIsTechnicalMachine?(item) && RandomizedChallenge::RANDOMIZE_TM_MOVES && !RandomizedChallenge::UNRANDOMIZABLE_TMS.include?(new_item)
          progresive = progressive_random_on? && $Trainer.numbadges < 3 && RandomizedChallenge::MT_MOVES_RESPECT_PROGRESSIVE_RANDOM ? true : false
          move = progresive ? find_valid_move(true, 70, true) : find_valid_move(false, 0, true)
          $PokemonGlobal.given_tm_moves << move
          $PokemonGlobal.tm_moves ||= {}
          $ItemData[item][ITEMMACHINE] = move
          $PokemonGlobal.tm_moves[item] = move
        end
      elsif !random_items_enabled? && $PokemonGlobal.random_tm_item_used
        item = getID(PBItems, item) if item.is_a?(String) || item.is_a?(Symbol)

        if pbIsTechnicalMachine?(item) && RandomizedChallenge::RANDOMIZE_TM_MOVES && !RandomizedChallenge::UNRANDOMIZABLE_TMS.include?(item)
          progresive = progressive_random_on? && $Trainer.numbadges < 3 && RandomizedChallenge::MT_MOVES_RESPECT_PROGRESSIVE_RANDOM ? true : false
          move = progresive ? find_valid_move(true, 70, true) : find_valid_move(false, 0, true)
          $PokemonGlobal.given_tm_moves << move
          $PokemonGlobal.tm_moves ||= {}
          $ItemData[item][ITEMMACHINE] = move
          $PokemonGlobal.tm_moves[item] = move
        end
      end
      pbReceiveItem_random(item, quantity)
    end
  end
end

# Requerido para randomizar los ataques de las MTs de lo contrario se borran
# Los movimientos random de las MTs al cerrar y abrir el juego
class PokemonLoad
  alias pbStartLoadScreen_random pbStartLoadScreen
  def pbStartLoadScreen(savenum = 0, auto = nil, savename = 'Partida 1')
    pbStartLoadScreen_random(savenum, auto, savename)
    if random_enabled? && !semi_random_mode? && RandomizedChallenge::RANDOMIZE_TM_MOVES && $PokemonGlobal.tm_moves && !$PokemonGlobal.tm_moves.empty?
      $PokemonGlobal.tm_moves.each_pair do |item, move|
        $ItemData[item][ITEMMACHINE] = move
      end
    end
  end
end



