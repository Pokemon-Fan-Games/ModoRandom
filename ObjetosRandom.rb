################################################################################
# ITEMS RANDOM BY SKYFLYER
################################################################################

BLACK_LIST = []


MTLIST_RANDOM = []

################################################################################
################################################################################ 


# Al llamar a esta función, si el interruptor ITEMS_RANDOM está activo, el objeto
# que encontramos es uno al azar.
def getItemRandomFromPokeball()
  objeto_elegido = 0
  loop do
    objeto_elegido = rand(PBItems.maxValue)
    for i in BLACK_LIST
      item=getID(PBItems,i)
      enBlackList = true if objeto_elegido==item
      break if enBlackList
    end
    for i in MTLIST_RANDOM
      item=getID(PBItems,i)
      mtRepetida = true if (objeto_elegido==item && $PokemonBag.pbHasItem?(objeto_elegido))
      break if mtRepetida
    end
    break if !enBlackList && !mtRepetida
  end
  Kernel.pbItemBall(objeto_elegido)
end
