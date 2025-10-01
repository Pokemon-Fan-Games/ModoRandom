# ********************************************************
# HELPER METHODS FOR TRAINER RANDOMIZATION
# ********************************************************
# ********************************************************
# MEGAS RANDOMIZE TO MEGAS
# ********************************************************
alias pbLoadTrainer_random pbLoadTrainer
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  return pbLoadTrainer_random(tr_type, tr_name, tr_version) unless RandomizedChallenge.enabled?
  trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)

  if !RandomizedChallenge.randomize_trainers? || RandomizedChallenge::UNRANDOMIZABLE_TRAINERS.include?(trainer_data.id)
    RandomizedChallenge.pause
    trainer = pbLoadTrainer_random(tr_type, tr_name, tr_version)
    trainer.party.map! { |pkmn| 
                          pkmn = force_normal_ability(pkmn)
                          pkmn.randomized = false
                          pkmn
                        }
    RandomizedChallenge.resume
    return trainer
  end

  
  $PokemonGlobal.random_trainer_teams ||= {}

  if RandomizedChallenge.randomize_trainers? &&
     RandomizedChallenge.remember_trainer_teams? &&
     $PokemonGlobal.random_trainer_teams.has_key?(trainer_data.id)
    return $PokemonGlobal.random_trainer_teams[trainer_data.id]
  end

  # Estado previo del mapeo global
  wild_paused = RandomizedChallenge.wild_paused?

  RandomizedChallenge.resume_random_species if wild_paused

  # Cargar entrenador base
  trainer = pbLoadTrainer_random(tr_type, tr_name, tr_version)
  return trainer if trainer.nil?

  RandomizedChallenge.pause_random_species if wild_paused

  # Especies específicas no randomizables por slot
  unrandomizable_pokes = RandomizedChallenge::UNRANDOMIZABLE_TRAINER_POKEMON.fetch(trainer_data.id, {})

  trainer.party.map!.with_index do |pkmn, index|
    process_trainer_pokemon(pkmn, unrandomizable_pokes, index)
  end

  if RandomizedChallenge.remember_trainer_teams?
    $PokemonGlobal.random_trainer_teams[trainer_data.id] = Marshal.load(Marshal.dump(trainer))
  end

  trainer
end



# Processes a trainer Pokemon based on randomization settings
def process_trainer_pokemon(pkmn, unrandomizable_species = nil, index = nil)
  # Handle unrandomizable Pokemon
  if unrandomizable_species && unrandomizable_species[index]
    RandomizedChallenge.pause
    pkmn = Pokemon.new(unrandomizable_species[index], pkmn.level, pkmn.owner)
    RandomizedChallenge.resume
  else
    # Megas: solo si la 14 está ON
    pkmn = handle_mega_stone_pokemon(pkmn) if RandomizedChallenge.randomize_trainers? && RandomizedChallenge::MEGAS_RANDOMIZE_TO_MEGAS  # <-- CHANGED

    # Objetos: solo si la 14 y la 16 están ON
    randomize_trainer_pokemon_item(pkmn)
  end

  # Movimientos: solo si la 14 está ON y la opción de movimientos está ON
  randomize_trainer_pokemon_moveset(pkmn)
  pkmn
end

# Handles mega stone Pokemon randomization
def handle_mega_stone_pokemon(pkmn)
  return pkmn unless pkmn&.item&.is_mega_stone?

  species_data = GameData::Species.get(pkmn.species)
  mega_stone = species_data.get_mega_stone
  if mega_stone
    pkmn.item = mega_stone
  else
    new_species = random_species(true)
    mega_stone = new_species.get_mega_stone
    RandomizedChallenge.pause
    pkmn = Pokemon.new(new_species, pkmn.level, pkmn.owner)
    pkmn.item = mega_stone
    RandomizedChallenge.resume
    pkmn.reset_moves
  end
  pkmn
end

# Handles item randomization for trainer Pokemon
def randomize_trainer_pokemon_item(pkmn)
  return unless RandomizedChallenge.randomize_trainers?           
  return unless RandomizedChallenge.randomize_trainers_items?     
  return if !pkmn&.item
  return if pkmn&.item&.is_mega_stone?
  pkmn.item = RandomizedChallenge.random_item(false, true)
end

# Applies moveset randomization to a Pokemon
def randomize_trainer_pokemon_moveset(pkmn)
  # Debe depender de la 14 y de la opción de movimientos del menú
  return unless RandomizedChallenge.randomize_trainers?
  if !RandomizedChallenge.moves_on?      
    pkmn.reset_moves
    return
  end
  return unless RandomizedChallenge::RERANDOM_TRAINER_MOVESET

  pkmn.moves = RandomizedChallenge::TRAINERS_MOVESET_RESPECT_PROGRESSIVE ? pkmn.random_moveset(RandomizedChallenge.progressive?, 4, pkmn.moves) : pkmn.random_moveset(false, 4, pkmn.moves)
end

# Forces a Pokemon to use its normal (non-randomized) ability
def force_normal_ability(pkmn)
  species_data = GameData::Species.get(pkmn.species)
  abil_index = pkmn.ability_index
  
  # Get the actual ability from the species data (not randomized)
  if abil_index >= 2   # Hidden ability
    normal_ability = species_data.real_hidden_abilities[abil_index - 2]
    abil_index = (pkmn.personalID & 1) if !normal_ability
  end
  
  if !normal_ability   # Natural ability or no hidden ability defined
    normal_ability = species_data.real_abilities[abil_index] || species_data.real_abilities[0]
  end
  
  # Force the Pokemon to use the normal ability
  pkmn.forced_ability = normal_ability if normal_ability
  pkmn
end
