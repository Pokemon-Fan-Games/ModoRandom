module GameData
  class Move
    def display_real_damage(pkmn, move = nil)
      case @function_code
      when "DoublePowerIfUserHasNoItem"
        return power * 2 unless pkmn&.hasItem?
      when "HitTwoTimes"
        return @power * 2
      when "HitThreeTimes"
        return @power * 3
      when "HitThreeTimesPowersUpWithEachHit"
        dmg = 0
        3.times do
          dmg += @power
        end
        return dmg
      when "TypeDependsOnUserIVs"
        return @power unless pkmn&.iv

        hidden_power = pbHiddenPower(pkmn)
        return hidden_power[1] if hidden_power
      # when "PowerHigherWithUserHP"
      #   return [150 * ((pkmn&.hp.to_f / pkmn&.totalhp) || 0), 1].max
      # when "PowerLowerWithUserHP"
      #   n = 48 * (pkmn&.hp.to_f || 0) / (pkmn&.totalhp || 1)
      #   return 200 if n < 2
      #   return 150 if n < 5
      #   return 100 if n < 10
      #   return 80 if n < 17
      #   return 40 if n < 33

      #   return 20
      # when "PowerHigherWithUserHappiness"
      #   return [(pkmn&.happiness.try(:*, 2) / 5).floor, 1].max
      # when "PowerLowerWithUserHappiness"
      #   return [((255 - (pkmn&.happiness || 0)) * 2 / 5).floor, 1].max
      # when "PowerHigherWithLessPP"
      #   dmgs = [200, 80, 60, 50, 40]
      #   ppLeft = [[(move&.pp || @total_pp) - 1, 0].max, dmgs.length - 1].min
      #   return dmgs[ppLeft]
      end
      @power
    end

    def ohko?
      @flags.each { |flag| return true if flag.downcase.start_with?("ohko") }
      false
    end
  end
end

def invalid_move?(move, move_data, for_tm = false)
  # move_exists = $PokemonGlobal.random_moves && $PokemonGlobal.random_moves[@species] &&  $PokemoGlobal.random_moves[@species][self.form] ? $PokemonGlobal.random_moves[@species][self.form]&.detect { |elem| elem[1] == move } : false
  move_exists = false
  move_exists = $PokemonGlobal.random_moves&.dig(@species, self.form)&.detect { |elem| elem[1] == move } || false if !for_tm
  given_tm = for_tm && RandomizedChallenge::RANDOMIZE_TM_MOVES && $PokemonGlobal.given_tm_moves.include?(move)
  RandomizedChallenge::MOVEBLACKLIST.include?(move) || move_exists || (move_data.ohko? && ohko_banned?) || given_tm ? true : false
end

def find_valid_move(min_damage = 0, types = [], for_tm = false, progressive = RandomizedChallenge.progressive?)
  badge_count = $player.badge_count
  move = random_move(min_damage, types)
  loop do
    move_data = GameData::Move.get(move.id)
    if progressive && badge_count < 3
      break unless move_data.display_real_damage(self) > 70 || invalid_move?(move, move_data, for_tm)
    elsif progressive && badge_count >= 6
      break unless move_data.display_real_damage(self) < 55 || invalid_move?(move, move_data, for_tm)
    else
      break unless invalid_move?(move, move_data, for_tm)
    end

    move = random_move(min_damage, types)
  end

  move
end

def random_move(min_damage = 0, types = [], for_tm = false)
  moves = GameData::Move.keys
  move = moves.sample
  move = GameData::Move.get(move)
  return move unless (min_damage.positive? && move.display_real_damage(self, move) < min_damage) || (!types.empty? && !types.include?(move.type))

  if min_damage.positive? && !types.empty?
    until move.display_real_damage(self, move) >= min_damage && types.include?(move.type)
      move = moves.sample
      move = GameData::Move.get(move)
    end
  elsif min_damage.positive?
    until move.display_real_damage(self, move) >= min_damage
      move = moves.sample
      move = GameData::Move.get(move)
    end
  elsif !types.empty?
    until types.include?(move.type)
      move = moves.sample
      move = GameData::Move.get(move)
    end
  end

  move
end