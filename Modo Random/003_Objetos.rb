#***********************************************************
# OBJETOS RANDOM
#
# Por Skyflyer
#***********************************************************

def random_item
    item_num = rand(GameData::Item.count - 1) + 1
    count = 1
    GameData::Item.each do |item| 
      if count == item_num
          return item
      end
      count += 1
    end
end

# Al llamar a esta función, si el interruptor ITEMS_RANDOM está activo, el objeto
# que encontramos es uno al azar.
def random_item_from_pokeball()
  objeto_elegido = 0
  loop do
    objeto_elegido = random_item
    # Comprobamos si está en la Blacklist.
    for blacklist_item in RandomizedChallenge::ITEM_BLACK_LIST
      item = GameData::Item.get(blacklist_item)
      enBlackList = true if objeto_elegido==item
      break if enBlackList
    end
    # Revisión de MTs.
    for mt in RandomizedChallenge::MTLIST_RANDOM
      item = GameData::Item.get(mt)
      mtRepetida = true if (objeto_elegido==item && $bag.has?(objeto_elegido))
      break if mtRepetida
    end
    break if !enBlackList && !mtRepetida
  end
  Kernel.pbItemBall(objeto_elegido)
end