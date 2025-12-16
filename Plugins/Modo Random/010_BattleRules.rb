class Game_Temp    
	alias random_add_battle_rule add_battle_rule
	def add_battle_rule(rule, var = nil)
		rules = self.battle_rules
		case rule.to_s.downcase
				when "unrandomized"
						rules["unrandomized"] = true
		else
				random_add_battle_rule(rule, var)
		end
	end
end

class WildBattle
	class << self
		alias_method :start_randomized, :start
		def start(*args, can_override: false)
			rules = $game_temp.battle_rules
			if rules["unrandomized"] && RandomizedChallenge.enabled?
				RandomizedChallenge.pause
				ret = start_randomized(*args, can_override: can_override)
				RandomizedChallenge.resume
				return ret
			end
			start_randomized(*args, can_override: can_override)
		end
	end
end