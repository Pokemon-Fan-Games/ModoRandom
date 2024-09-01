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
      when "TypeAndPowerDependOnUserBerry"
        damage_array = {
        60 => [:CHERIBERRY,  :CHESTOBERRY, :PECHABERRY,  :RAWSTBERRY,  :ASPEARBERRY,
                :LEPPABERRY,  :ORANBERRY,   :PERSIMBERRY, :LUMBERRY,    :SITRUSBERRY,
                :FIGYBERRY,   :WIKIBERRY,   :MAGOBERRY,   :AGUAVBERRY,  :IAPAPABERRY,
                :RAZZBERRY,   :OCCABERRY,   :PASSHOBERRY, :WACANBERRY,  :RINDOBERRY,
                :YACHEBERRY,  :CHOPLEBERRY, :KEBIABERRY,  :SHUCABERRY,  :COBABERRY,
                :PAYAPABERRY, :TANGABERRY,  :CHARTIBERRY, :KASIBBERRY,  :HABANBERRY,
                :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :ROSELIBERRY],
        70 => [:BLUKBERRY,   :NANABBERRY,  :WEPEARBERRY, :PINAPBERRY,  :POMEGBERRY,
                :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY,  :TAMATOBERRY,
                :CORNNBERRY,  :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY,  :SPELONBERRY,
                :PAMTREBERRY],
        80 => [:WATMELBERRY, :DURINBERRY,  :BELUEBERRY,  :LIECHIBERRY, :GANLONBERRY,
                :SALACBERRY,  :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY,
                :ENIGMABERRY, :MICLEBERRY,  :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY,
                :KEEBERRY,    :MARANGABERRY]
        }
        if pkmn.hasItem?
          damage_array.each do |dmg, items|
            next unless items.include?(pkmn.item_id)

            ret = dmg
            ret += 20 if Settings::MECHANICS_GENERATION >= 6
            return ret
          end
        end
      when "ThrowUserItemAtTarget"
        fling_powers = {
          130 => [:IRONBALL
                  ],
          100 => [:HARDSTONE,:RAREBONE,
                  # Fossils
                  :ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HELIXFOSSIL,
                  :JAWFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:ROOTFOSSIL,:SAILFOSSIL,
                  :SKULLFOSSIL
                  ],
          90 => [:DEEPSEATOOTH,:GRIPCLAW,:THICKCLUB,
              # Plates
              :DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,:FLAMEPLATE,
              :ICICLEPLATE,:INSECTPLATE,:IRONPLATE,:MEADOWPLATE,:MINDPLATE,
              :PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,:STONEPLATE,
              :TOXICPLATE,:ZAPPLATE
              ],
          80 => [:ASSAULTVEST,:CHIPPEDPOT,:CRACKEDPOT,:DAWNSTONE,:DUSKSTONE,
              :ELECTIRIZER,:HEAVYDUTYBOOTS,:MAGMARIZER,:ODDKEYSTONE,:OVALSTONE,
              :PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SACHET,:SAFETYGOGGLES,
              :SHINYSTONE,:STICKYBARB,:WEAKNESSPOLICY,:WHIPPEDDREAM
              ],
          70 => [:DRAGONFANG,:POISONBARB,
              # EV-training items (Macho Brace is 60)
              :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
              :POWERWEIGHT,
              # Drives
              :BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:SHOCKDRIVE
              ],
          60 => [:ADAMANTORB,:DAMPROCK,:GRISEOUSORB,:HEATROCK,:LEEK,:LUSTROUSORB,
              :MACHOBRACE,:ROCKYHELMET,:STICK,:TERRAINEXTENDER
              ],
          50 => [:DUBIOUSDISC,:SHARPBEAK,
              # Memories
              :BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,
              :FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,
              :GRASSMEMORY,:GROUNDMEMORY,:ICEMEMORY,:POISONMEMORY,
              :PSYCHICMEMORY,:ROCKMEMORY,:STEELMEMORY,:WATERMEMORY
              ],
          40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH
              ],
          30 => [:ABSORBBULB,:ADRENALINEORB,:AMULETCOIN,:BINDINGBAND,:BLACKBELT,
              :BLACKGLASSES,:BLACKSLUDGE,:BOTTLECAP,:CELLBATTERY,:CHARCOAL,
              :CLEANSETAG,:DEEPSEASCALE,:DRAGONSCALE,:EJECTBUTTON,:ESCAPEROPE,
              :EXPSHARE,:FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:GOLDBOTTLECAP,
              :HEARTSCALE,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTBALL,:LIGHTCLAY,
              :LUCKYEGG,:LUMINOUSMOSS,:MAGNET,:METALCOAT,:METRONOME,
              :MIRACLESEED,:MYSTICWATER,:NEVERMELTICE,:PASSORB,:POKEDOLL,
              :POKETOY,:PRISMSCALE,:PROTECTIVEPADS,:RAZORFANG,:SACREDASH,
              :SCOPELENS,:SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SNOWBALL,
              :SOULDEW,:SPELLTAG,:TOXICORB,:TWISTEDSPOON,:UPGRADE,
              # Healing items
              :ANTIDOTE,:AWAKENING,:BERRYJUICE,:BIGMALASADA,:BLUEFLUTE,
              :BURNHEAL,:CASTELIACONE,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,:ETHER,
              :FRESHWATER,:FULLHEAL,:FULLRESTORE,:HEALPOWDER,:HYPERPOTION,
              :ICEHEAL,:LAVACOOKIE,:LEMONADE,:LUMIOSEGALETTE,:MAXELIXIR,
              :MAXETHER,:MAXHONEY,:MAXPOTION,:MAXREVIVE,:MOOMOOMILK,:OLDGATEAU,
              :PARALYZEHEAL,:PARLYZHEAL,:PEWTERCRUNCHIES,:POTION,:RAGECANDYBAR,
              :REDFLUTE,:REVIVALHERB,:REVIVE,:SHALOURSABLE,:SODAPOP,
              :SUPERPOTION,:SWEETHEART,:YELLOWFLUTE,
              # Battle items
              :XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
              :XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,
              :XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6,
              :XDEFENSE,:XDEFENSE2,:XDEFENSE3,:XDEFENSE6,
              :XSPATK,:XSPATK2,:XSPATK3,:XSPATK6,
              :XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6,
              :XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6,
              :XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
              :DIREHIT,:DIREHIT2,:DIREHIT3,
              :ABILITYURGE,:GUARDSPEC,:ITEMDROP,:ITEMURGE,:RESETURGE,
              :MAXMUSHROOMS,
              # Vitamins
              :CALCIUM,:CARBOS,:HPUP,:IRON,:PPUP,:PPMAX,:PROTEIN,:ZINC,
              :RARECANDY,
              # Most evolution stones (see also 80)
              :EVERSTONE,:FIRESTONE,:ICESTONE,:LEAFSTONE,:MOONSTONE,:SUNSTONE,
              :THUNDERSTONE,:WATERSTONE,:SWEETAPPLE,:TARTAPPLE, :GALARICACUFF,
              :GALARICAWREATH,
              # Repels
              :MAXREPEL,:REPEL,:SUPERREPEL,
              # Mulches
              :AMAZEMULCH,:BOOSTMULCH,:DAMPMULCH,:GOOEYMULCH,:GROWTHMULCH,
              :RICHMULCH,:STABLEMULCH,:SURPRISEMULCH,
              # Shards
              :BLUESHARD,:GREENSHARD,:REDSHARD,:YELLOWSHARD,
              # Valuables
              :BALMMUSHROOM,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:COMETSHARD,
              :NUGGET,:PEARL,:PEARLSTRING,:RELICBAND,:RELICCOPPER,:RELICCROWN,
              :RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:STARDUST,
              :STARPIECE,:STRANGESOUVENIR,:TINYMUSHROOM,
              # Exp Candies
              :EXPCANDYXS, :EXPCANDYS, :EXPCANDYM, :EXPCANDYL, :EXPCANDYXL
              ],
          20 => [# Feathers
              :CLEVERFEATHER,:GENIUSFEATHER,:HEALTHFEATHER,:MUSCLEFEATHER,
              :PRETTYFEATHER,:RESISTFEATHER,:SWIFTFEATHER,
              :CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,
              :RESISTWING,:SWIFTWING
              ],
          10 => [:AIRBALLOON,:BIGROOT,:BRIGHTPOWDER,:CHOICEBAND,:CHOICESCARF,
              :CHOICESPECS,:DESTINYKNOT,:DISCOUNTCOUPON,:EXPERTBELT,:FOCUSBAND,
              :FOCUSSASH,:LAGGINGTAIL,:LEFTOVERS,:MENTALHERB,:METALPOWDER,
              :MUSCLEBAND,:POWERHERB,:QUICKPOWDER,:REAPERCLOTH,:REDCARD,
              :RINGTARGET,:SHEDSHELL,:SILKSCARF,:SILVERPOWDER,:SMOOTHROCK,
              :SOFTSAND,:SOOTHEBELL,:WHITEHERB,:WIDELENS,:WISEGLASSES,:ZOOMLENS,
              # Terrain seeds
              :ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED,
              # Nectar
              :PINKNECTAR,:PURPLENECTAR,:REDNECTAR,:YELLOWNECTAR,
              # Incenses
              :FULLINCENSE,:LAXINCENSE,:LUCKINCENSE,:ODDINCENSE,:PUREINCENSE,
              :ROCKINCENSE,:ROSEINCENSE,:SEAINCENSE,:WAVEINCENSE,
              # Scarves
              :BLUESCARF,:GREENSCARF,:PINKSCARF,:REDSCARF,:YELLOWSCARF,
              # Mints
              :LONELYMINT, :ADAMANTMINT, :NAUGHTYMINT, :BRAVEMINT, :BOLDMINT,
              :IMPISHMINT, :LAXMINT, :RELAXEDMINT, :MODESTMINT, :MILDMINT,
              :RASHMINT, :QUIETMINT, :CALMMINT, :GENTLEMINT, :CAREFULMINT,
              :SASSYMINT, :TIMIDMINT, :HASTYMINT, :JOLLYMINT, :NAIVEMINT,
              :SERIOUSMINT,
              # Sweets
              :STRAWBERRYSWEET, :LOVESWEET, :BERRYSWEET, :CLOVERSWEET,
              :FLOWERSWEET, :STARSWEET, :RIBBONSWEET
              ]
        }
        return 0 unless pkmn.item

        return 10 if pkmn.item.is_berry?

        return 80 if pkmn.item.is_mega_stone?

        if pkmn.item.is_TR?
          ret = GameData::Move.get(pkmn.item.move).power
          ret = 10 if ret < 10
          return ret
        end
        fling_powers.each do |power,items|
          return power if items.include?(pkmn.item_id)
        end
        return 10
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
      @flags.each { |flag| return true if flag.start_with?("OHKO") }
      false
    end
  end
end