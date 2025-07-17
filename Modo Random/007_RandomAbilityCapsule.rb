# Lista de habilidades baneados
ALLOW_REUSE = true
class PokemonGlobalMetadata
  attr_accessor :last_used_id, :random_abs_pokes

  alias global_init_dp initialize
  def initialize
    global_init_dp
    @last_used_id = 0
  end
end

class Pokemon
  attr_accessor :id

  def generate_random_ability_list(ret)
    $PokemonGlobal.random_abs_pokes = {} unless $PokemonGlobal.random_abs_pokes
    if !$PokemonGlobal.random_abs_pokes[@id] || ALLOW_REUSE
      $PokemonGlobal.random_abs_pokes[@id] = []
      abilities = GameData::Ability.keys
      (0...ret.length).each do |i|
        new_ab = abilities.sample
        new_ab = abilities.sample while !new_ab || RandomizedChallenge::ABILITY_EXCLUSIONS.include?(new_ab)
        $PokemonGlobal.random_abs_pokes[@id].push([new_ab, i])
        ret[i][0] = $PokemonGlobal.random_abs_pokes[@id][ret[i][0]]
      end
    end
    $PokemonGlobal.random_abs_pokes[@id]
  end
end

ItemHandlers::UseOnPokemon.add(:RANDOMABILITYCAPSULE, proc { |_, pokemon, _|
  unless pokemon.id
    $PokemonGlobal.last_used_id += 1
    pokemon.id = $PokemonGlobal.last_used_id
  end

  if $PokemonGlobal.random_abs_pokes && $PokemonGlobal.random_abs_pokes.key?(pokemon.id) && !ALLOW_REUSE
    pbMessage(_INTL("Las habilidades de #{pokemon.name} ya fueron randomizadas"))
    next false
  elsif ALLOW_REUSE && $PokemonGlobal.random_abs_pokes && $PokemonGlobal.random_abs_pokes.key?(pokemon.id)
    unless pbConfirmMessageSerious(_INTL("Las habilidades de #{pokemon.name} ya fueron randomizadas, ¿estás seguro que deseas randomizarlas de nuevo?"))
      next false
    end
  end

  pokemon.generate_random_ability_list(pokemon.getAbilityList)

  pbMessage(_INTL("Las habilidades de #{pokemon.name} fueron randomizadas"))

  next true
})
