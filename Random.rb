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
  
              
  RANDOM_TM_COMPAT = false
  
  BlackListedPokemon = []
  # Los Pokémon de la blacklist jamas saldran, ni en entrenadores ni como salvajes.
  # Ejemplo Blacklist
  # BlackListedPokemon = [PBSpecies::ARTICUNO,PBSpecies::MOLTRES, PBSpecies::ZAPDOS]
  
  WhiteListedPokemon = []
  # Leave this empty if all pokemon are allowed, otherwise only pokemon listed
  # above will be selected.
  
  #StarterList = [PBSpecies::BULBASAUR,PBSpecies::CHARMANDER,PBSpecies::SQUIRTLE,PBSpecies::CHIKORITA,PBSpecies::CYNDAQUIL,PBSpecies::TOTODILE,PBSpecies::TREECKO,PBSpecies::TORCHIC,PBSpecies::MUDKIP,PBSpecies::TURTWIG,PBSpecies::CHIMCHAR,PBSpecies::PIPLUP,PBSpecies::SNIVY,PBSpecies::TEPIG,PBSpecies::OSHAWOTT,PBSpecies::CHESPIN,PBSpecies::FENNEKIN,PBSpecies::FROAKIE,PBSpecies::ROWLET,PBSpecies::LITTEN,PBSpecies::POPPLIO]
  
  
  #Lista de movimientos baneados para el random
  MOVEBLACKLIST=[PBMoves::CHATTERI, PBMoves::DIG, PBMoves::TELEPORT, PBMoves::SONICBOOM,PBMoves::DRAGONRAGE,PBMoves::STRUGGLE]
  
  #Lista de habilidades baneados para el random
  ABILITYBLACKLIST = [PBAbilities::IMPOSTER, PBAbilities::PLUS, PBAbilities::MINUS, PBAbilities::ZENMODE, PBAbilities::WONDERGUARD, PBAbilities::STANCECHANGE, PBAbilities::DISGUISE, PBAbilities::FORECAST, PBAbilities::ILLUSION, PBAbilities::HARVEST, PBAbilities::MULTITYPE, PBAbilities::HONEYGATHER]
  
  
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
  FULL_RANDOM_ABS = false
  
  # Este flag decide que las habilidades sean un mapeo de una a otra
  # Ejemplo Intimidacion se convierte en Inicio Lento
  # Lo que no significa que Inicio Lento se convierta en Intimidacion
  # Si la variable FULL_RANDOM_ABS esta en true esa sera la opcion determinada
  MAP_RANDOM_ABS = false
  # Si ambas variables estan en false no se randomizaran las habilidades

  # Este flag decide que el BST de los pokemon sea progresivo, es decir si el flag está en true 
  # no podran salir pokemon con un BST mayor al que se define en la funcion getMaxBSTCap
  PROGRESSIVE_RANDOM = true
end

######################### Do not edit anything below here.

class PokemonGlobalMetadata
  attr_accessor :tmCompatibilityRandom
  attr_accessor :randomGens
  attr_accessor :valid_num_ranges
  attr_accessor :randomAbsPokemon
  attr_accessor :abilityHash
  alias random_abil_init initialize
  def initialize
    random_abil_init
    @abilityHash=nil
  end
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

def isNotInAllowedBSTRange(bst)
  return false if !RandomizedChallenge::PROGRESSIVE_RANDOM
  bst > getMaxBSTCap() || bst < getMinBSTCap()
end
  
def getRandomSpecies()
  species = RandomizedChallenge::WhiteListedPokemon.shuffle[0]
  if RandomizedChallenge::WhiteListedPokemon.length == 0
    species = rand(PBSpecies.maxValue - 1) + 1
    baseStatsSum = getBaseStatsSum(species)
    previous_species = pbGetPreviousForm(species)
    $PokemonGlobal.randomGens = [] if !$PokemonGlobal.randomGens
    while RandomizedChallenge::BlackListedPokemon.include?(species) || ( isNotInAllowedBSTRange(baseStatsSum) ) || ( $PokemonGlobal.randomGens.length > 0 && !is_pokemon_in_gen_range(species) &&  !is_pokemon_in_gen_range(previous_species) )
      species = rand(PBSpecies.maxValue - 1) + 1
      previous_species = pbGetPreviousForm(species)
      baseStatsSum = getBaseStatsSum(species)
    end
  end
  return species
end

def resetAbilities
  $PokemonGlobal.randomAbsPokemon.clear() if $PokemonGlobal.randomAbsPokemon
  $PokemonGlobal.abilityHash.clear() if $PokemonGlobal.abilityHash
  createAbilityHash if RandomizedChallenge::MAP_RANDOM_ABS
end

class PokeBattle_Pokemon
  
  alias randomized_init initialize
  alias random_getAbilityList getAbilityList
  alias random_getMoveList getMoveList

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

  # AQUI SE DEFINE EL BST QUE VAN A TENER LOS POKEMON EN EL RANDOMIZADO.
  # SEGÚN CADA CANTIDAD DE MEDALLAS, PONER EN LOS RETURN EL BST QUE TENDRÁN
  # LOS POKÉMON.
  def getMaxBSTCap()
    if $Trainer.numbadges <= 1
      return 400
    elsif $Trainer.numbadges <= 2
      return 440
    elsif $Trainer.numbadges <= 3
      return 480
    elsif $Trainer.numbadges <= 4
      return 520
    elsif $Trainer.numbadges <= 5
      return 560
    elsif $Trainer.numbadges <= 6
      return 600
    elsif $Trainer.numbadges <= 7
      return 800
    elsif $Trainer.numbadges <= 8
      return 800
    end
  end
  
  def getMinBSTCap()
    if $Trainer.numbadges > 6
      return 440
    elsif $Trainer.numbadges > 5
      return 425
    elsif $Trainer.numbadges > 4
      return 400
    elsif $Trainer.numbadges > 3
      return 375
    elsif $Trainer.numbadges > 2
      return 350
    else
      return 0
    end
  end

  # Creación de un objeto Pokémon nuevo.
  #    species   - Especie del Pokémon.
  #    level     - Nivel del Pokémon.
  #    player    - Objeto PokeBattle_Trainer para el entrenador original.
  #    withMoves - Si está en false, este Pokémon no tendrá movimientos.
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
      # INCIO generación de movimientos random
      movelist = []
      while movelist.length<4
        move=rand(PBMoves::PBMoves.maxValue - 1)+1
        movedata=PBMoveData.new(move)
        if $Trainer.numbadges < 3 && RandomizedChallenge::PROGRESSIVE_RANDOM
          next if (!move || movedata.basedamage > 70 || RandomizedChallenge::MOVEBLACKLIST.include?(move)) 
        else
          next if (!move || RandomizedChallenge::MOVEBLACKLIST.include?(move)) 
        end
        movelist.push(move)
        movelist|=[] # Elimina duplicados
      end
      # FIN generación de movimientos random
      for i in 0..length-1
        alevel=atkdata.fgetw
        move=atkdata.fgetw
        if alevel<=level
          movelist[movelist.length]=move
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
  if !RandomizedChallenge::RANDOM_TM_COMPAT || ($game_switches && !$game_switches[RandomizedChallenge::Switch])
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

def getAbilityList
  ret = random_getAbilityList
  if $game_switches && $game_switches[RandomizedChallenge::Switch]
    if RandomizedChallenge::FULL_RANDOM_ABS
      return getAbilityFullRandom(ret)
    elsif RandomizedChallenge::MAP_RANDOM_ABS
      return getAbilityMap(ret)
    end
  end
  return ret
end


def getMoveList
  return random_getMoveList() if !($game_switches && $game_switches[RandomizedChallenge::Switch])
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
        if $Trainer.numbadges < 3 && RandomizedChallenge::PROGRESSIVE_RANDOM
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
