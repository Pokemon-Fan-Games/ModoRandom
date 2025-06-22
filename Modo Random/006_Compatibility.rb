class DiegoWTsStarterSelection
    alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
    def initialize(pkmn1, pkmn2, pkmn3)
        original_initialize(pkmn1, pkmn2, pkmn3) unless RandomizedChallenge.enabled?
        starter1 = get_starter(0) || pkmn1
        starter2 = get_starter(1) || pkmn2
        starter3 = get_starter(2) || pkmn3
        RandomizedChallenge.pause
        original_initialize(starter1, starter2, starter3)
        RandomizedChallenge.resume
    end
end