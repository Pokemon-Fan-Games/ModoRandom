################################################################################
# Randomized Pokemon Script
# By Umbreon
# Modificado por DPertierra y Skyflyer
################################################################################
# Used for a randomized pokemon challenge mainly.
# 
# By randomized, I mean EVERY pokemon will be random, even interacted pokemon
#   like legendaries. (You may easily disable the randomizer for certain
#    situations like legendary battles and starter selecting.)
#
# To use: simply activate Switch Number X
#  (X = the number listed After "Switch = ", default is switch number 36.)
#
# If you want certain pokemon to NEVER appear, add them inside the black list.
#  (This does not take into effect if the switch stated above is off.)
#
# If you want ONLY certain pokemon to appear, add them to the whitelist. This
#   is only recommended when the amount of random pokemon available is around
#   32 or less.(This does not take into effect if the switch stated above is off.)
#
################################################################################

########################## You may edit any settings below this freely.
module RandomizedChallenge
  Switch = 409 # switch ID to randomize a pokemon, if it's on then ALL
              # pokemon will be randomized. No exceptions.
  
  BlackListedPokemon = []
  # Los Pokémon de la blacklist jamas saldran, ni en entrenadores ni como salvajes.
  # Ejemplo Blacklist
  # BlackListedPokemon = [PBSpecies::ARTICUNO,PBSpecies::MOLTRES, PBSpecies::ZAPDOS]
  
  WhiteListedPokemon = []
  # Leave this empty if all pokemon are allowed, otherwise only pokemon listed
  # above will be selected.
  
  #StarterList = [PBSpecies::BULBASAUR,PBSpecies::CHARMANDER,PBSpecies::SQUIRTLE,PBSpecies::CHIKORITA,PBSpecies::CYNDAQUIL,PBSpecies::TOTODILE,PBSpecies::TREECKO,PBSpecies::TORCHIC,PBSpecies::MUDKIP,PBSpecies::TURTWIG,PBSpecies::CHIMCHAR,PBSpecies::PIPLUP,PBSpecies::SNIVY,PBSpecies::TEPIG,PBSpecies::OSHAWOTT,PBSpecies::CHESPIN,PBSpecies::FENNEKIN,PBSpecies::FROAKIE,PBSpecies::ROWLET,PBSpecies::LITTEN,PBSpecies::POPPLIO]
  
  
  #Lista de movimientos baneados para el random
  MOVEBLACKLIST=[]
  
  #Lista de habilidades baneados para el random
  ABILITYBLACKLIST = []
  
  
  # LISTA DE STARTERS PARA EL RANDOM
  ListaStartersRandomizado = [
  PBSpecies::BULBASAUR,
  PBSpecies::CHARMANDER,
  PBSpecies::SQUIRTLE,
  PBSpecies::PIDGEY,
  PBSpecies::NIDORANmA,
  PBSpecies::NIDORANfE,
  PBSpecies::ZUBAT,
  PBSpecies::MANKEY,
  PBSpecies::POLIWAG,
  PBSpecies::ABRA,
  PBSpecies::MACHOP,
  PBSpecies::BELLSPROUT,
  PBSpecies::GEODUDE,
  PBSpecies::MAGNEMITE,
  PBSpecies::GASTLY,
  PBSpecies::RHYHORN,
  PBSpecies::HORSEA,
  PBSpecies::ELEKID,
  PBSpecies::MAGBY,
  PBSpecies::PORYGON,
  PBSpecies::ODDISH,
  PBSpecies::DRATINI,
  PBSpecies::CHIKORITA,
  PBSpecies::CYNDAQUIL,
  PBSpecies::TOTODILE,
  PBSpecies::MAREEP,
  PBSpecies::HOPPIP,
  PBSpecies::SWINUB,
  PBSpecies::TEDDIURSA,
  PBSpecies::LARVITAR,
  PBSpecies::TREECKO,
  PBSpecies::TORCHIC,
  PBSpecies::MUDKIP,
  PBSpecies::LOTAD,
  PBSpecies::SEEDOT,
  PBSpecies::RALTS,
  PBSpecies::ARON,
  PBSpecies::BUDEW,
  PBSpecies::TRAPINCH,
  PBSpecies::DUSKULL,
  PBSpecies::SHUPPET,
  PBSpecies::BAGON,
  PBSpecies::BELDUM,
  PBSpecies::SPHEAL,
  PBSpecies::TURTWIG,
  PBSpecies::CHIMCHAR,
  PBSpecies::PIPLUP,
  PBSpecies::STARLY,
  PBSpecies::SHINX,
  PBSpecies::GIBLE,
  PBSpecies::SNIVY,
  PBSpecies::TEPIG,
  PBSpecies::OSHAWOTT,
  PBSpecies::LILLIPUP,
  PBSpecies::SEWADDLE,
  PBSpecies::VENIPEDE,
  PBSpecies::ROGGENROLA,
  PBSpecies::TIMBURR,
  PBSpecies::SOLOSIS,
  PBSpecies::GOTHITA,
  PBSpecies::SANDILE,
  PBSpecies::VANILLITE,
  PBSpecies::KLINK,
  PBSpecies::TYNAMO,
  PBSpecies::LITWICK,
  PBSpecies::AXEW,
  PBSpecies::DEINO,
  PBSpecies::PAWNIARD,
  PBSpecies::CHESPIN,
  PBSpecies::FENNEKIN,
  PBSpecies::FROAKIE,
  PBSpecies::FLETCHLING,
  PBSpecies::FLABEBE,
  PBSpecies::GOOMY,
  PBSpecies::HONEDGE,
  PBSpecies::ROWLET,
  PBSpecies::LITTEN,
  PBSpecies::POPPLIO,
  PBSpecies::GRUBBIN,
  PBSpecies::JANGMOO,
  PBSpecies::GROOKEY,
  PBSpecies::SCORBUNNY,
  PBSpecies::SOBBLE,
  PBSpecies::ROLYCOLY,
  PBSpecies::BLIPBUG,
  PBSpecies::ROOKIDEE,
  PBSpecies::HATENNA,
  PBSpecies::IMPIDIMP,
  PBSpecies::DREEPY,
  PBSpecies::SPRIGATITO,
  PBSpecies::FUECOCO,
  PBSpecies::QUAXLY,
  PBSpecies::PAWMI,
  PBSpecies::SMOLIV,
  PBSpecies::NACLI,
  PBSpecies::TINKATINK,
  PBSpecies::FRIGIBAX,
  ]
  MAX_NUM_GEN = { 1 => [1,151], 2 => [152,251], 3 => [252,386], 4 => [387,494], 
                  5 => [495,649], 6 => [650,721], 7 => [722,809], 8 => [810,905],
                  9 => [906,1025] }
  
  # Este flag decide que las habilidades sean random para cada especie
  # Ejemplo Pikachu tendra Intimidacion y Cura Natural
  # Pero Raichu podria tener otras distintas como Absorbe agua y levitacion
  FULL_RANDOM_ABS = true
  
  # Este flag decide que las habilidades sean un mapeo de una a otra
  # Ejemplo Intimidacion se convierte en Inicio Lento
  # Lo que no significa que Inicio Lento se convierta en Intimidacion
  # Si la variable FULL_RANDOM_ABS esta en true esa sera la opcion determinada
  MAP_RANDOM_ABS = false
  # Si ambas variables estan en false no se randomizaran las habilidades
  # Se puede cambiar el metodo de randomizado de habilidades 
  # llamando al metodo choose_random_ability_mode a este metodo hay que pasarle el modo
  # Para el mapeo hay que pasarle :MAP_RANDOM_ABS, asi choose_random_ability_mode(:MAP_RANDOM_ABS)
  # Para el modo full random hay que pasarle :FULL_RANDOM_ABS, asi choose_random_ability_mode(:FULL_RANDOM_ABS)
  # Tengan en cuenta que el llamado a este método volverá a randomizar las habilidades
  # Y las antiguas no podrán ser recuperadas.

  # Este flag decide que el BST de los pokemon sea progresivo, es decir si el flag está en true 
  # no podran salir pokemon con un BST mayor al que se define en la funcion getMaxBSTCap
  # Siempre se podra modificar esto llamando al metodo toggle_progressive_random
  PROGRESSIVE_RANDOM_DEFAULT_VALUE = true

  # Movimientos randomizados
  # Si quieres que los movimientos esten randomizados por defecto pon esta constante en true
  # Siempre se podra modificar esto llamando al metodo toggle_random_moves
  RANDOM_MOVES_DEFAULT_VALUE = true
  
  # Randomizar compatibilidad con las MTs
  # Se podrá cambiar llamando al metodo toggle_tm_compat
  # Tengan en cuenta que de esa forma un jugador podria armarse el moveset como quiera
  # Activando y desactivando esta opción
  RANDOM_TM_COMPAT_DEFAULT_VALUE = false

  # Randomizar evoluciones de los pokemones
  # Se podrá cambiar llamando al metodo toggle_random_evos
  RANDOM_EVOS_DEFAULT_VALUE = true

  # Randomizar evoluciones de los pokemones a otro con BST similares 
  # Por ejemplo un Pichu no podra evolucionar a un Slaking
  # Se podrá cambiar llamando al metodo toggle_random_evos_similar_bst
  RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE = true

  # Esto es el margen de diferencia de los BST para las evos random, actualmente es un 10%
  # Si quisieran cambiarlo a un 20% hay que cambiarlo a 0.2
  EVO_BST_MARGIN = 0.1
end

######################### Do not edit anything below here.

class PokemonGlobalMetadata
  attr_accessor :tmCompatibilityRandom
  attr_accessor :randomGens
  attr_accessor :valid_num_ranges
  attr_accessor :randomAbsPokemon
  attr_accessor :abilityHash
  attr_accessor :randomMoves
  attr_accessor :enable_random_moves
  attr_accessor :random_ability_mode
  attr_accessor :progressive_random
  attr_accessor :enable_random_tm_compat
  attr_accessor :random_evos
  attr_accessor :random_evos_similar_bst
  alias random_abil_init initialize
  def initialize
    random_abil_init
    @abilityHash=nil
  end
end

def are_random_moves_on()
  return false if !$game_switches[RandomizedChallenge::Switch]
  return $PokemonGlobal.enable_random_moves ? true : false
end
def toggle_random_moves()
  $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE if $PokemonGlobal.enable_random_moves == nil
  $PokemonGlobal.enable_random_moves = !$PokemonGlobal.enable_random_moves
end

def is_progressive_random_on()
  return false if !$game_switches[RandomizedChallenge::Switch]
  return $PokemonGlobal.progressive_random ? true : false
end
def toggle_progressive_random()
  $PokemonGlobal.progressive_random = !$PokemonGlobal.progressive_random
end

def is_random_tm_compat_on()
  return $PokemonGlobal.enable_random_tm_compat ? true : false
end
def toggle_random_tm_compat()
  $PokemonGlobal.enable_random_tm_compat = !$PokemonGlobal.enable_random_tm_compat
end

def are_random_evos_on()
  return false if !$game_switches[RandomizedChallenge::Switch]
  return $PokemonGlobal.random_evos ? true : false
end
def toggle_random_evos()
  $PokemonGlobal.random_evos = RandomizedChallenge::RANDOM_EVOS_DEFAULT_VALUE if $PokemonGlobal.random_evos == nil
  $PokemonGlobal.random_evos = !$PokemonGlobal.random_evos
end

def are_random_evos_similar_bst_on()
  return false if !$game_switches[RandomizedChallenge::Switch]
  return $PokemonGlobal.random_evos_similar_bst ? true : false
end
def toggle_random_evos_similar_bst()
  $PokemonGlobal.random_evos_similar_bst = RandomizedChallenge::RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE if $PokemonGlobal.random_evos_similar_bst == nil
  $PokemonGlobal.random_evos_similar_bst = !$PokemonGlobal.random_evos_similar_bst
end

def choose_random_ability_mode(mode=:FULL_RANDOM_ABS)
  return if $PokemonGlobal.random_ability_mode == mode
  $PokemonGlobal.random_ability_mode = mode
  resetAbilities
end


def get_random_gens()
  return $PokemonGlobal.randomGens ? $PokemonGlobal.randomGens : []
end

def get_random_gens_choice_array()
  choice_array = []
  random_gens = get_random_gens()
  for i in 1..RandomizedChallenge::MAX_NUM_GEN.length
    choice_array.push( random_gens.include?(i) ? "[X] Gen " + i.to_s : "[  ] Gen " + i.to_s )
  end
  choice_array.push("Terminar")
  return choice_array
end

def add_or_remove_random_gen(gen = nil)
  return if !gen || gen > RandomizedChallenge::MAX_NUM_GEN.length
  $PokemonGlobal.randomGens = [] if !$PokemonGlobal.randomGens
  if !$PokemonGlobal.randomGens.include?(gen)
    $PokemonGlobal.randomGens.push(gen)
  else
    $PokemonGlobal.randomGens.delete(gen)
  end
end

def enable_random 
  return if !$game_switches
  resetAbilities
  $PokemonGlobal.enable_random_moves = RandomizedChallenge::RANDOM_MOVES_DEFAULT_VALUE if $PokemonGlobal.enable_random_moves == nil
  if !$PokemonGlobal.random_ability_mode
    if RandomizedChallenge::FULL_RANDOM_ABS 
      $PokemonGlobal.random_ability_mode = :FULL_RANDOM_ABS
    elsif RandomizedChallenge::MAP_RANDOM_ABS 
      $PokemonGlobal.random_ability_mode = :MAP_RANDOM_ABS
    end
  end
  $PokemonGlobal.progressive_random = RandomizedChallenge::PROGRESSIVE_RANDOM_DEFAULT_VALUE if $PokemonGlobal.progressive_random == nil
  $PokemonGlobal.enable_random_tm_compat = RandomizedChallenge::RANDOM_TM_COMPAT_DEFAULT_VALUE if $PokemonGlobal.enable_random_tm_compat == nil
  $PokemonGlobal.random_evos = RandomizedChallenge::RANDOM_EVOS_DEFAULT_VALUE
  $PokemonGlobal.random_evos_similar_bst = RandomizedChallenge::RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE
  generarInicialesRandom
  $game_switches[RandomizedChallenge::Switch] = true
end

def is_pokemon_in_gen_range(species)
  return true if !$PokemonGlobal.randomGens
  is_valid = false
  for gen in $PokemonGlobal.randomGens
    if !species.between?(RandomizedChallenge::MAX_NUM_GEN[gen][0],RandomizedChallenge::MAX_NUM_GEN[gen][1])
      next
    else
      return true
    end
  end
  return is_valid
end

# AQUI SE DEFINE EL BST QUE VAN A TENER LOS POKEMON EN EL RANDOMIZADO.
# SEGÚN CADA CANTIDAD DE MEDALLAS, PONER EN LOS RETURN EL BST QUE TENDRÁN
# LOS POKÉMON.
# SI LA CANTIDAD DE MEDALLAS ES MAYOR A LA MAYOR DEL LISTADO DE max_caps, SE DEVUELVE EL BST MAS ALTO
def getMaxBSTCap
  max_caps = {
    1 => 400,
    2 => 440,
    3 => 480,
    4 => 520,
    5 => 560,
    6 => 600,
    7 => 800
  }
  min_key = max_caps.keys.min
  max_key = max_caps.keys.max

  # Si la cantidad de medallas es menor que la menor clave de max_caps, se devuelve el valor de la clave mas baja.
  # Si la cantidad de medallas es mayor a la clave mas alta de max_caps, se devuelve el valor de la clave mas alta.
  # De esta forma se evitan duplicar claves para medallas con el mismo BST
  $Trainer.numbadges < min_key ? max_caps[min_key] :
  max_caps.fetch($Trainer.numbadges, max_caps[max_key])
end

def getMinBSTCap
  min_caps = {
    7 => 440,
    6 => 425,
    5 => 400,
    4 => 375,
    3 => 350
  }
  max_key = min_caps.keys.max

  # Si la cantidad de medallas es mayor que la mayor clave de min_caps, se devuelve el valor de la clave mas alta.
  # Si la cantidad de medallas es menor a la clave mas baja de min_caps, se devuelve el 0
  $Trainer.numbadges > max_key ? min_caps[max_key] :
  min_caps.fetch($Trainer.numbadges, 0)
end



def isNotInAllowedBSTRange(bst)
  return false if !$PokemonGlobal.progressive_random
  !(bst.between?(getMinBSTCap(), getMaxBSTCap()))
end
  
def getRandomSpecies(evo = false, evo_bst_range = [])
  species = RandomizedChallenge::WhiteListedPokemon.shuffle[0]
  if RandomizedChallenge::WhiteListedPokemon.length == 0
    species = rand(PBSpecies.maxValue - 1) + 1
    baseStatsSum = getBaseStatsSum(species)
    previous_species = pbGetPreviousForm(species)
    $PokemonGlobal.randomGens = [] if !$PokemonGlobal.randomGens
    while RandomizedChallenge::BlackListedPokemon.include?(species) || ( isNotInAllowedBSTRange(baseStatsSum) ) || ( $PokemonGlobal.randomGens.length > 0 && !is_pokemon_in_gen_range(species) &&  !is_pokemon_in_gen_range(previous_species) ) || ( evo && evo_bst_range.length > 0 && !baseStatsSum.between?(evo_bst_range[0],evo_bst_range[1]) )  
      species = rand(PBSpecies.maxValue - 1) + 1
      previous_species = pbGetPreviousForm(species)
      baseStatsSum = getBaseStatsSum(species)
    end
  end
  return species
end

def getRandomEvo(current_pokemon, expected_evo)
  if are_random_evos_similar_bst_on() 
    min_bst = getBaseStatsSum(expected_evo) * ( 1 - RandomizedChallenge::EVO_BST_MARGIN)
    max_bst = getBaseStatsSum(expected_evo) * ( 1 + RandomizedChallenge::EVO_BST_MARGIN )
    evo_bst_range = [min_bst,max_bst]
  else
    evo_bst_range = []
  end 
  return getRandomSpecies(true, evo_bst_range)
end


def resetAbilities
  $PokemonGlobal.randomAbsPokemon.clear() if $PokemonGlobal.randomAbsPokemon
  $PokemonGlobal.abilityHash.clear() if $PokemonGlobal.abilityHash
  createAbilityHash if $PokemonGlobal.random_ability_mode == :MAP_RANDOM_ABS
end

def getBaseStatsSum(species)
  dexdata=pbOpenDexData
  pbDexDataOffset(dexdata,species,10)
  ret=[
     dexdata.fgetb, # PS
     dexdata.fgetb, # Ataque
     dexdata.fgetb, # Defensa
     dexdata.fgetb, # Velocidad
     dexdata.fgetb, # Ataque Especial
     dexdata.fgetb  # Defensa Especial
  ]
  dexdata.close
  baseStatsSum = 0
  for i in 0..5
    baseStatsSum += ret[i]
  end
  return baseStatsSum
end

class PokeBattle_Pokemon

  # Creación de un objeto Pokémon nuevo.
  #    species   - Especie del Pokémon.
  #    level     - Nivel del Pokémon.
  #    player    - Objeto PokeBattle_Trainer para el entrenador original.
  #    withMoves - Si está en false, este Pokémon no tendrá movimientos.
  alias randomized_init initialize
  def initialize(species,level,player=nil,withMoves=true)
    return randomized_init(species,level,player,withMoves) if !($game_switches && $game_switches[RandomizedChallenge::Switch])
    species = getRandomSpecies()
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    cname=getConstantName(PBSpecies,species) rescue nil
    if !species || species<1 || species>PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL("El número de especie (núm. {1} de {2}) no es válido.",
        species,PBSpecies.maxValue))
      return nil
    end
    time=pbGetTimeNow
    @timeReceived=time.getgm.to_i # Usa GMT
    @species=species
    # IVs (Valores Individuales)
    @personalID=rand(256)
    @personalID|=rand(256)<<8
    @personalID|=rand(256)<<16
    @personalID|=rand(256)<<24
    @hp=1
    @totalhp=1
    @ev=[0,0,0,0,0,0]
    @iv=[]
    @iv[0]=rand(32)
    @iv[1]=rand(32)
    @iv[2]=rand(32)
    @iv[3]=rand(32)
    @iv[4]=rand(32)
    @iv[5]=rand(32)
    expshare = false
    if player
      @trainerID=player.id
      @ot=player.name
      @otgender=player.gender
      @language=player.language
    else
      @trainerID=0
      @ot=""
      @otgender=2
    end
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,19)
    @happiness=dexdata.fgetb
    dexdata.close
    @name=PBSpecies.getName(@species)
    @eggsteps=0
    @status=0
    @statusCount=0
    @item=0
    @mail=nil
    @fused=nil
    @ribbons=[]
    @moves=[]
    self.ballused=0
    self.level=level
    calcStats
    @hp=@totalhp
    if $game_map
      @obtainMap=$game_map.map_id
      @obtainText=nil
      @obtainLevel=level
    else
      @obtainMap=0
      @obtainText=nil
      @obtainLevel=level
    end
    @obtainMode=0   # Encuentro
    @obtainMode=4 if $game_switches && $game_switches[FATEFUL_ENCOUNTER_SWITCH]
    @hatchedMap=0
    if withMoves
      atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
      offset=atkdata.getOffset(species-1)
      length=atkdata.getLength(species-1)>>1
      atkdata.pos=offset
      # Genera lista de movimientos
      movelist=[]
      if $PokemonGlobal.enable_random_moves 
        while movelist.length<4
          move=rand(PBMoves::PBMoves.maxValue - 1)+1
          movedata=PBMoveData.new(move)
          if $Trainer.numbadges < 3 && $PokemonGlobal.progressive_random
            next if (!move || movedata.basedamage > 70 || RandomizedChallenge::MOVEBLACKLIST.include?(move)) 
          else
            next if (!move || RandomizedChallenge::MOVEBLACKLIST.include?(move)) 
          end
          movelist.push(move)
          movelist|=[] # Elimina duplicados
        end
         # FIN generación de movimientos random
      else
        for i in 0..length-1
          alevel=atkdata.fgetw
          move=atkdata.fgetw
          if alevel<=level
            movelist[movelist.length]=move
          end
        end
      end
      atkdata.close
      movelist|=[] # Elimina duplicados
     
      # Se usan los últimos 4 elementos en la lista de movimientos
      listend=movelist.length-4
      listend=0 if listend<0
      j=0
      for i in listend...listend+4
        moveid=(i>=movelist.length) ? 0 : movelist[i]
        @moves[j]=PBMove.new(moveid)
        j+=1
      end
    else
      for i in 0...4
        @moves[i]=PBMove.new(0)
      end
    end
  end
  
def isCompatibleWithMove?(move)
  if !$PokemonGlobal.enable_random_tm_compat || ($game_switches && !$game_switches[RandomizedChallenge::Switch])
    return pbSpeciesCompatible?(self.species,move)
  end

  #RAND TM
  if !$PokemonGlobal.tmCompatibilityRandom
    $PokemonGlobal.tmCompatibilityRandom = {}
  end
  if ( $PokemonGlobal.tmCompatibilityRandom && $PokemonGlobal.tmCompatibilityRandom[self.species] && $PokemonGlobal.tmCompatibilityRandom[self.species].detect {|item| item[0]==move } )
    return $PokemonGlobal.tmCompatibilityRandom[self.species].any? {|item| item[0]==move && item[1] == true }
  elsif !$PokemonGlobal.tmCompatibilityRandom[self.species]
    $PokemonGlobal.tmCompatibilityRandom[self.species] = []
    if rand(2) == 1
      $PokemonGlobal.tmCompatibilityRandom[self.species].push([move, true])
      return true
    else
      $PokemonGlobal.tmCompatibilityRandom[self.species].push([move, false])
      return false
    end
  else
    if rand(2) == 1
      $PokemonGlobal.tmCompatibilityRandom[self.species].push([move, true])
      return true
    else
      $PokemonGlobal.tmCompatibilityRandom[self.species].push([move, false])
      return false
    end
  end
end

def getAbilityFullRandom(ret)
  $PokemonGlobal.randomAbsPokemon = {} if !$PokemonGlobal.randomAbsPokemon
  if !$PokemonGlobal.randomAbsPokemon[@species]
    $PokemonGlobal.randomAbsPokemon[@species] = []
    for i in 0...ret.length
      newAb = rand(PBAbilities.maxValue - 1) + 1
      while !newAb || RandomizedChallenge::ABILITYBLACKLIST.include?(newAb)
        newAb = rand(PBAbilities.maxValue - 1) + 1
      end
       $PokemonGlobal.randomAbsPokemon[@species].push([newAb,i])
       ret[i][0] = $PokemonGlobal.randomAbsPokemon[@species][ret[i][0]]
    end
  end
  return $PokemonGlobal.randomAbsPokemon[@species]
end

def getAbilityMap(ret)
  for i in 0...ret.length
    if !$PokemonGlobal.abilityHash[ret[i][0]]
      newAb = rand(PBAbilities.maxValue - 1) + 1
      while RandomizedChallenge::ABILITYBLACKLIST.include?(newAb) || !newAb
        newAb = rand(PBAbilities.maxValue - 1) + 1
      end
      $PokemonGlobal.abilityHash[ret[i][0]] = newAb
    end
    ret[i][0]=$PokemonGlobal.abilityHash[ret[i][0]]
  end
  return ret
end

alias random_getAbilityList getAbilityList
def getAbilityList
  ret = random_getAbilityList
  if $game_switches && $game_switches[RandomizedChallenge::Switch]
    if $PokemonGlobal.random_ability_mode == :FULL_RANDOM_ABS
      return getAbilityFullRandom(ret)
    elsif $PokemonGlobal.random_ability_mode == :MAP_RANDOM_ABS
      return getAbilityMap(ret)
    end
  end
  return ret
end

alias random_getMoveList getMoveList
def getMoveList
  if ($game_switches && !$game_switches[RandomizedChallenge::Switch]) || !$PokemonGlobal.enable_random_moves
   return random_getMoveList
  end
  movelist=[]
  atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
  offset=atkdata.getOffset(@species-1)
  length=atkdata.getLength(@species-1)>>1
  atkdata.pos=offset
  
  $PokemonGlobal.randomMoves = [] if !$PokemonGlobal.randomMoves
  if $PokemonGlobal.randomMoves[@species] == nil
    $PokemonGlobal.randomMoves[@species] = []
  else
    return $PokemonGlobal.randomMoves[@species]
  end
  
  for k in 0..length-1
    level=atkdata.fgetw
    move=atkdata.fgetw
    if move != nil
        move=rand(PBMoves::PBMoves.maxValue)+1 
        movedata=PBMoveData.new(move)
        if $Trainer.numbadges < 3 && $PokemonGlobal.progressive_random
          moveExists = $PokemonGlobal.randomMoves[@species].detect{ |elem| elem[1] == (move) }
          while movedata.basedamage > 70 || RandomizedChallenge::MOVEBLACKLIST.include?(move) || moveExists
            move=rand(PBMoves::PBMoves.maxValue)+1
            movedata=PBMoveData.new(move)
            moveExists = $PokemonGlobal.randomMoves[@species].detect{ |elem| elem[1] == (move) }
          end
        else
          #Usar blacklist en el recordador.
          moveExists = $PokemonGlobal.randomMoves[@species].detect{ |elem| elem[1] == (move) }
          while RandomizedChallenge::MOVEBLACKLIST.include?(move) || !move || moveExists 
            move=rand(PBMoves::PBMoves.maxValue)+1 
            moveExists = $PokemonGlobal.randomMoves[@species].detect{ |elem| elem[1] == (move) }
          end
        end
        $PokemonGlobal.randomMoves[@species].push([level,move])
      movelist.push([level,move]) if !(isConst?(move,PBMoves,:CHATTER) && !isConst?(self.species,PBSpecies,:CHATOT))
    end
  end
  atkdata.close
  movelist = $PokemonGlobal.randomMoves[@species] 
  return movelist
end
end

alias pbCheckEvolutionExRandom pbCheckEvolutionEx
def pbCheckEvolutionEx(pokemon)
  return pbCheckEvolutionExRandom(pokemon) if !are_random_evos_on()
  return -1 if pokemon.species<=0 || pokemon.isEgg?
  return -1 if isConst?(pokemon.species,PBSpecies,:PICHU) && pokemon.form==1
  return -1 if isConst?(pokemon.item,PBItems,:EVERSTONE) &&
               !isConst?(pokemon.species,PBSpecies,:KADABRA)
  ret=-1
  for form in pbGetEvolvedFormData(pokemon.species)
    ret=yield pokemon,form[0],form[1], getRandomEvo(pokemon, form[2]) #form[2]
    break if ret>0
  end
  return ret
end


################################################################################
# STARTERS RANDOMIZADOS CON DOS ETAPAS EVOLUTIVAS
################################################################################


def generarInicialesRandom()
  inicial_1 = RandomizedChallenge::ListaStartersRandomizado.shuffle[0]
  
  inicial_2 = inicial_1
  loop do
    inicial_2 = RandomizedChallenge::ListaStartersRandomizado.shuffle[0]
    break if (inicial_1 != inicial_2)
  end
  
  inicial_3 = inicial_1
  loop do
    inicial_3 = RandomizedChallenge::ListaStartersRandomizado.shuffle[0]
    break if (inicial_1 != inicial_3) && (inicial_2 != inicial_3)
  end
  
  $game_variables[803] = inicial_1
  $game_variables[804] = inicial_2
  $game_variables[805] = inicial_3
end

def createAbilityHash
  abilityHash={}
  abilityArr=[]
  for i in 1..PBAbilities.maxValue
    next if RandomizedChallenge::ABILITYBLACKLIST.include?(i)
    abilityArr.push(i)
  end
  abilityArr.shuffle!
  for i in 0...abilityArr.length
    abilityHash[i]=abilityArr[i]
  end
  $PokemonGlobal.abilityHash=abilityHash
end
