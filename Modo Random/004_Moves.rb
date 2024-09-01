module GameData
  class Move
    def display_real_damage(pkmn, move = nil)
      case @function_code
      when "DoublePowerIfUserHasNoItem"
        return power * 2 unless pkmn.hasItem?
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
        return pbHiddenPower(pkmn)[1]
      when "PowerHigherWithUserHP"
        return [150 * pkmn.hp / pkmn.totalhp, 1].max
      when "PowerLowerWithUserHP"
        n = 48 * pkmn.hp / pkmn.totalhp
        return 200 if n < 2
        return 150 if n < 5
        return 100 if n < 10
        return 80 if n < 17
        return 40 if n < 33

        return 20
      when "PowerHigherWithUserHappiness"
        return [(pkmn.happiness * 2 / 5).floor, 1].max
      when "PowerLowerWithUserHappiness"
        return [((255 - pkmn.happiness) * 2 / 5).floor, 1].max
      when "PowerHigherWithLessPP"
        dmgs = [200, 80, 60, 50, 40]
        ppLeft = [[(move&.pp || @total_pp) - 1, 0].max, dmgs.length - 1].min
        return dmgs[ppLeft]
      end
      @power
    end

    def ohko?
      @flags.each { |flag| return true if flag.downcase.start_with?("ohko") }
      false
    end
  end
end
