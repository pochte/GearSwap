-- Ullona_Smn_Gear.lua
-- Rebuilt SMN GearSwap file.
-- Assumptions: Glyphic Horn +1 (other Glyphic pieces NQ), Convoker's body/legs/feet +1,
-- Bunzi's gear at R15, Nyame Path B at R15, and Shomonjijoe +1 are treated as available.
-- Existing equipment from the supplied file is retained where relevant.
--
-- Notes:
--   * Glyphic pieces are used for Blood Pact delay / summoning utility.
--   * Convoker's pieces are used where their avatar accuracy or BP damage wins.
--   * Shomonjijoe is centralised in gear.shomonjijoe to avoid spelling it repeatedly.
--   * Beckoner's Earring +2 is always assigned to ear2 in pet sets.
--   * Nyame is not forced into SMN damage sets; it is primarily a defensive option.
--   * Alt+W = Assault, Alt+E = Retreat, Alt+R = Release.
--   * Asteria Mitts +1: Carbuncle half-perp + Lv+1, Avatar MAB, idle Refresh.
--   * Lamassu Mitts +1: Summoning skill, Cait Sith Lv+1, Avatar Mag Acc.

function select_default_macro_book()
    set_macro_page(1, 7)
end

function user_job_setup()
    state.OffenseMode:options('Normal', 'Acc')
    state.CastingMode:options('Normal', 'Resistant', 'OccultAcumen')
    state.IdleMode:options('Normal', 'PDT')
    state.Weapons:options('None', 'Tumafyrig', 'Marquetry', 'Frazil')

    set_macro_page(1, 7)

    gear.perp_staff = {name = "Mpaca's Staff"}
    gear.shomonjijoe = {name = "Shomonjijoe"} --+1 is a wip. 
    -- Magical Blood Pact / Debuff cape.
    -- Current augments: Pet Magic Accuracy +3, Pet Magic Attack Bonus +3.
    gear.magic_jse_back = {
        name="Campestres's Cape", augments={'Pet: Mag. Acc.+3', 'Pet: "Mag.Atk.Bns."+3'}}
    -- Physical Blood Pact cape placeholder.
    -- Replace the item and augments once the physical cape is completed.
    gear.phys_jse_back = "Campestres's Cape"

    -- Local binds. Ctrl+` remains reserved for Ullona-Globals.lua.
    send_command('bind !` input /ja "Release" <me>')
    send_command('bind @` gs c cycle MagicBurst')
    send_command('bind ^\\ gs c toggle PactSpamMode')
    send_command('bind !pause gs c toggle AutoSubMode')
    send_command('bind ^q gs c set CastingMode OccultAcumen')
    send_command('bind !q gs c weapons default;gs c reset CastingMode')
    send_command('bind ^a gs c wheelavatar')

    -- Pet command cluster; deliberately avoids the macro number row.
    send_command('bind !w input /pet "Assault" <t>')
    send_command('bind !e input /pet "Retreat" <me>')
    send_command('bind !r input /pet "Release" <me>')
end

function user_job_unload()
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind ^\\')
    send_command('unbind !pause')
    send_command('unbind ^q')
    send_command('unbind !q')
    send_command('unbind ^a')
    send_command('unbind !w')
    send_command('unbind !e')
    send_command('unbind !r')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 7')
end

function init_gear_sets()
  
    -- Weapon modes
  
    sets.weapons = sets.weapons or {}
    sets.weapons.Tumafyrig = {main="Tumafyrig"}
    sets.weapons.Marquetry = {main="Marquetry Staff"}
    sets.weapons.Frazil = {main="Frazil Staff"}

    sets.TreasureHunter = set_combine(sets.TreasureHunter or {}, {
        feet = gear.merlinic_treasure_feet
    })

  
    -- Job abilities
  
    sets.precast.JA['Astral Flow'] = {head="Glyphic Horn +1"}
    sets.precast.JA['Elemental Siphon'] = {
        main="Tumafyrig",
        head="Beckoner's Horn +2",
        body="Beck. Doublet +2",
        hands="Lamassu Mitts +1",
        legs="Beck. Spats +2",
        feet="Beck. Pigaches +2",
        neck="Incanter's Torque",
        ear1="Andoaa Earring",
        ring1="Evoker's Ring",
        ring2="Inyanga Ring",
        back="Conveyance Cape",
        waist="Lucidity Sash",
    }
    sets.precast.JA['Mana Cede'] = {hands="Beck. Bracers +2"}
    -- Convoker's Horn +1 is an optional +2 Summoning skill over Beckoner's Horn +2;
    -- not worth farming solely for that small gain. Convoker's Bracers +1 are skipped.

  
    -- Blood Pact precast / delay reduction
    -- Full Blood Pact recast set. Use every timer-reduction piece available,
    -- especially for Cait Sith's Mewing Lullaby when repeatedly applying it to a
    -- raid boss. Mewing Lullaby has a dedicated named override below.
    -- Damage / accuracy gear belongs in the pet midcast set.
  
sets.precast.BloodPactWard = {
    ammo="Seraphicaller",
    head="Glyphic Horn",
    body="Glyphic Doublet +1",
    hands="Glyphic Bracers +1",
    legs="Glyphic Spats +1",
    feet="Glyph. Pigaches +1",
    neck="Caller's Pendant",
    ear1="Caller's Earring",
    back="Conveyance Cape",
}
    -- Cait Sith's Mewing Lullaby gets its own named override. Use the strongest
    -- BP-delay head/body pieces here; the remaining slots inherit the Ward delay set.
    -- (The ability is officially named "Mewing Lullaby" in FFXI.)
    sets.precast.BloodPactWard['Mewing Lullaby'] = set_combine(
        sets.precast.BloodPactWard, {
            head="Beckoner's Horn +2",
            body = gear.shomonjijoe,
        }
    )
    sets.precast.BloodPactRage = sets.precast.BloodPactWard

  
    -- Fast Cast
  
    sets.precast.FC = {
        main="Mpaca's Staff",
        sub="Willpower Grip",
        head="Nahtirah Hat",
        body="Inyanga Jubbah +2",
        hands="SV Gauntlets +1",
        legs="Querkening Brais",
        feet="Regal Pumps",
        neck="Voltsurge Torque",
        ear1="Loquacious Earring",
        ear2="Malignance Earring",
        ring1="Naji's Loop",
        ring2="Kishar Ring",
        waist="Embla Sash",
    }
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main="Vadose Rod", sub="empty", ammo="Psilomene",
        head="Vanya Hood", hands="Bokwus Gloves",
        legs="Gyve Trousers", feet="Vanya Clogs",
        ear1="Loquacious Earring", ear2="Novia Earring",
        ring1="Lebeche Ring", ring2="Janniston Ring",
        back="Tempered Cape +1", waist="Acerbic Sash +1",
    })
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        hands="Bokwus Gloves", legs="Shedir Seraweels",
        feet="Medium's Sabots", ear1="Magnetic Earring",
        ear2="Andoaa Earring", ring2="Vertigo Ring",
        waist="Siegel Sash",
    })
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
        head="Umuthi Hat", neck="Nodens Gorget",
        legs="Shedir Seraweels", waist="Siegel Sash",
    })
    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head="empty", body="Twilight Cloak",
    })
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {
        main="Daybreak", sub="Culminus",
    })
    sets.precast.Stoneskin = set_combine(sets.precast.FC, {
        waist="Siegel Sash", legs="Querkening Brais",
    })

  
    -- Weaponskills
  
    sets.precast.WS = {}

  
    -- Player midcast: healing / status removal
  
    sets.midcast.Cure = {
        main="Bunzi's Rod",
        head="Vanya Hood",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        legs="Gyve Trousers",
        feet="Vanya Clogs",
        neck="Nodens Gorget",
        ear1="Mendicant's Earring",
        ear2="Gifted Earring",
        ring1="Lebeche Ring",
        ring2="Janniston Ring",
    }
    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}
    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        hands="Bokwus Gloves", feet="Vanya Clogs",
        neck="Nodens Gorget", back="Tempered Cape +1",
        waist="Cornelia's Belt",
    })
    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast or {}, {
        sub="Clemency Grip",
    })

  
    -- Player midcast: summoning and nuking
  
    sets.midcast['Summoning Magic'] = {
        main="Malignance Pole", sub="Willpower Grip",
    }
    sets.midcast['Elemental Magic'] = {
        main="Marin Staff +1", sub="Willpower Grip",
        ammo="Ghastly Tathlum",
        head="Bunzi's Hat", body="Bunzi's Robe",
        hands="Bunzi's Gloves", legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Baetyl Pendant",
        ear1="Malignance Earring", ear2="Hecate's Earring",
        ring1="Resonance Ring", ring2="Freke Ring",
        back="Izdubar Mantle", waist="Hachirin-no-Obi",
    }
    sets.midcast['Elemental Magic'].Resistant = set_combine(
        sets.midcast['Elemental Magic'], {
            main="Mpaca's Staff", head="Inyanga Tiara +2",
            neck="Incanter's Torque", waist="Null Belt",
            back="Null Shawl",
        }
    )
    sets.midcast['Elemental Magic'].OccultAcumen = set_combine(
        sets.midcast['Elemental Magic'], {
            main="Mpaca's Staff", neck="Incanter's Torque",
            waist="Acerbic Sash +1",
        }
    )
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {
        head="empty", body="Twilight Cloak",
    })
    sets.midcast['Divine Magic'] = set_combine(
        sets.midcast['Elemental Magic'], {
            feet="Medium's Sabots", body="Vanya Robe",
        }
    )
    sets.midcast['Dark Magic'] = set_combine(
        sets.midcast['Elemental Magic'], {
            neck="Erra Pendant",
            ear1="Alabaster Earring", ear2="Malignance Earring",
            ring1="Crepuscular Ring", ring2="Evanescence Ring",
            back="Izdubar Mantle", waist="Eschan Stone",
        }
    )
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        neck="Erra Pendant", waist="Fucho-no-Obi",
        feet="Merlinic Crackows",
    })
    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Stun = sets.midcast['Dark Magic']
    sets.midcast.Stun.Resistant = set_combine(sets.midcast.Stun, {
        main="Mpaca's Staff", neck="Incanter's Torque",
    })

    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff", sub="Willpower Grip",
        head="Bunzi's Hat", body="Bunzi's Robe",
        legs="Bunzi's Pants", feet="Bunzi's Sabots",
        hands="Bunzi's Gloves",
        neck="Null Loop",
        ear1="Malignance Earring", ear2="Crepuscular Earring",
        ring1="Inyanga Ring", ring2="Crepuscular Ring",
        waist="Null Belt", back="Null Shawl",
    }
    sets.midcast['Enfeebling Magic'].Resistant = set_combine(
        sets.midcast['Enfeebling Magic'], {
            main="Mpaca's Staff", neck="Incanter's Torque",
            waist="Null Belt",
        }
    )
    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Diaga = sets.midcast.Dia
    sets.midcast['Dia II'] = sets.midcast.Dia
    sets.midcast.Bio = sets.midcast.Dia
    sets.midcast['Bio II'] = sets.midcast.Dia

  
    -- Enhancing magic
  
    sets.midcast['Enhancing Magic'] = {
        main="Daybreak", sub="Ammurapi Shield", ammo="Psilomene",
        head="Umuthi Hat", body="Bunzi's Robe",
        hands="Bokwus Gloves", legs="Shedir Seraweels",
        feet="Regal Pumps",
        neck="Incanter's Torque",
        ear1="Andoaa Earring", ear2="Gifted Earring",
        back="Izdubar Mantle", waist="Embla Sash",
    }
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        head="Umuthi Hat",
    })
    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga", feet="Bunzi's Sabots",
    })
    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Vadose Rod", sub="Culminus", legs="Shedir Seraweels",
    })
    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {
        legs="Shedir Seraweels",
    })

  
    -- Pet Blood Pact wards
  
    sets.midcast.Pet = sets.midcast.Pet or {}
    sets.midcast.Pet.BloodPactWard = {
        main="Tumafyrig",
        ammo="Seraphicaller",
        head="Beckoner's Horn +1",
        body="Beck. Doublet +1",
        hands="Glyphic Bracers +3",
        legs="Beck. Spats +1",
        feet="Beck. Pigaches +1",
        neck="Incanter's Torque",
        ear1="Andoaa Earring",
        ear2="Beck. Earring +1",
        ring1="Evoker's Ring",
        ring2="Fervor Ring",
        back="Conveyance Cape",
        waist="Lucidity Sash",
    }

    sets.midcast.Pet.DebuffBloodPactWard = {
        main="Marquetry Staff", 
        ammo="Seraphicaller",
        head="Bunzi's Hat", 
        body="Bunzi's Robe",
        hands="Lamassu Mitts +1", 
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Adad Amulet",
        ear1="Enmerkar Earring", 
        ear2="Beck. Earring +2",
        ring1="C. Palug Ring", 
        ring2="Murky Ring",
        back=gear.magic_jse_back,
        waist="Regal Belt",
    }
    sets.midcast.Pet.DebuffBloodPactWard.Acc =
        sets.midcast.Pet.DebuffBloodPactWard

  
    -- Pet Blood Pact rage: physical and magical
  
       sets.midcast.Pet.PhysicalBloodPactRage = {
        main="Tumafyrig",
        ammo="Seraphicaller",
        head="Bunzi's Hat",
        body="Convoker's Doublet +1",
        hands="Beck. Bracers +1",
        legs="Enticer's Pants",
        feet="Inyan. Crackows +2",
        neck="Shulmanu Collar",
        ear1="Enmerkar Earring",
        ear2="Beck. Earring +1",
        ring1="C. Palug Ring",
        ring2="Murky Ring",
        back=gear.phys_jse_back,
        waist="Regal Belt",
    }

    sets.midcast.Pet.PhysicalBloodPactRage.AM = set_combine(
        sets.midcast.Pet.PhysicalBloodPactRage, {
            body="Bunzi's Robe",
            feet="Bunzi's Sabots",
        }
    )

    sets.midcast.Pet.PhysicalBloodPactRage.Acc = set_combine(
        sets.midcast.Pet.PhysicalBloodPactRage, {
            body="Bunzi's Robe",
            hands="Bunzi's Gloves",
            legs="Convoker's Spats +1",
            feet="Bunzi's Sabots",
            neck="Adad Amulet",
        }
    )

    -- Shomonjijoe supplies Avatar MAB for magical pacts. Convoker's Doublet +1
    -- is used for physical BP damage; compare in-game if your pact/target favors
    -- the alternative body for a particular Rage ability.
    sets.midcast.Pet.MagicalBloodPactRage = {
        main="Frazil Staff", 
        ammo="Seraphicaller",
        head="Bunzi's Hat", 
        body = gear.shomonjijoe,
        hands="Asteria Mitts +1", 
        legs="Avatara Slops",
        feet="Inyan. Crackows +2",
        neck="Adad Amulet",
        ear1="Enmerkar Earring", 
        ear2="Beck. Earring +2",
        ring1="C. Palug Ring", 
        ring2="Murky Ring",
        back=gear.magic_jse_back,
        waist="Regal Belt",
    }
    sets.midcast.Pet.MagicalBloodPactRage.Acc = set_combine(
        sets.midcast.Pet.MagicalBloodPactRage, {
            main="Marquetry Staff", body="Bunzi's Robe",
            hands="Bunzi's Gloves", legs="Bunzi's Pants", feet="Bunzi's Sabots",
        }
    )

    -- Fervor Ring's Avatar MAB bonus is Ifrit-only; never use it in generic sets.
    sets.midcast.Pet.MagicalBloodPactRage.Ifrit = set_combine(
        sets.midcast.Pet.MagicalBloodPactRage, {ring2="Fervor Ring"}
    )

    -- Spirit spells are ordinary pet spell midcasts, not Blood Pacts.
    sets.midcast.Pet.WhiteMagic = {
        legs="Glyphic Spats +1",
    }

    sets.midcast.Pet['Elemental Magic'] = set_combine(
        sets.midcast.Pet.MagicalBloodPactRage, {
            legs="Glyphic Spats +1",
        }
    )

    sets.midcast.Pet['Elemental Magic'].Resistant = set_combine(
        sets.midcast.Pet['Elemental Magic'], {
            main="Marquetry Staff",
            body="Bunzi's Robe",
            head="Bunzi's Hat",
            hands="Bunzi's Gloves",
            legs="Bunzi's Pants",
            feet="Bunzi's Sabots",
        }
    )

    sets.midcast.Pet.Impact = sets.midcast.Pet.DebuffBloodPactWard

  
    -- Idle / perpetuation
  
    sets.idle = {
        main="Mpaca's Staff", sub="Willpower Grip",
        ammo="Crepuscular Pebble",
        head="Beckoner's Horn +2", body = gear.shomonjijoe,
        hands="Asteria Mitts +1", legs="Assid. Pants +1",
        feet="Beck. Pigaches +2",
        neck="Elite Royal Collar",
        ear1="Alabaster Earring", ear2="Beck. Earring +2",
        ring1="Evoker's Ring", ring2="Inyanga Ring",
        back="Conveyance Cape", waist="Regal Belt",
    }
    sets.idle.PDT = {
        main="Malignance Pole", sub="Willpower Grip",
        ammo="Crepuscular Pebble",
        head="Nyame Helm", body="Nyame Mail",
        hands="Nyame Gauntlets", legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Elite Royal Collar",
        ear1="Alabaster Earring", ear2="Odnowa Earring +1",
        ring1="Murky Ring", ring2="Inyanga Ring",
        back="Archon Cape", waist="Null Belt",
    }

    -- Handler's pair is deliberate: pet PDT on both; +1 adds pet Acc/MAcc when augmented R15.
    sets.idle.Avatar = {
        main="Mpaca's Staff", sub="Oneiros Grip",
        ammo="Seraphicaller",
        head="Beckoner's Horn +2", 
        body="Beck. Doublet +2",
        hands="Beck. Bracers +2", 
        legs="Assid. Pants +1",
        feet="Beck. Pigaches +2",
        neck="Null Loop",
        ear1="Handler's Earring +1", ear2="Handler's Earring",
        ring1="Evoker's Ring", ring2="Inyanga Ring",
        back="Conveyance Cape", waist="Regal Belt",
    }
    sets.idle.PDT.Avatar = set_combine(sets.idle.Avatar, {
        main="Malignance Pole", body = gear.shomonjijoe,
        head="Nyame Helm", hands="Beck. Bracers +2",
        legs="Nyame Flanchard", feet="Nyame Sollerets",
        neck="Adad Amulet", ear1="Odnowa Earring +1",
        ear2="Beck. Earring +2", ring1="Murky Ring",
        back="Archon Cape", waist="Regal Belt",
    })
    sets.idle.Spirit = set_combine(sets.idle.Avatar, {
        body = gear.shomonjijoe, ear1="Alabaster Earring",
        ear2="Odnowa Earring +1", waist="Fucho-no-Obi",
    })
    sets.idle.PDT.Spirit = set_combine(sets.idle.PDT.Avatar, {
        feet="Battlecast Gaiters",
    })

    -- Favor and engaged variants are intentionally explicit placeholders.
    sets.idle.Avatar.Favor = {}
    sets.idle.Avatar.Engaged = {}
    sets.idle.Avatar.Engaged.Carbuncle = {
        hands="Asteria Mitts +1",
    }
    sets.idle.Avatar.Engaged['Cait Sith'] = {
        hands="Lamassu Mitts +1",
    }

  
    -- Avatar perpetuation / refresh
  
    -- Dedicated avatar-out set. Prioritises Refresh while retaining enough
    -- perpetuation reduction to keep upkeep low: Assid. Pants +1 (-3),
    -- Beck. Pigaches +2 (-8), Evoker's Ring (-1), and Lucidity Sash (-2).
    -- Beck. Bracers +2 additionally halve the remaining cost on matching day
    -- or weather. Shomonjijoe +1 (+3 Refresh), Beckoner's Horn +2 (+3 Refresh),
    -- and Mpaca's Staff (+2 Refresh) are retained rather than overstacking
    -- -perpetuation beyond what is useful.
    -- Convoker's Pigaches +1 are not selected here: their -4 is weaker than
    -- Beck. Pigaches +2's -8, which this character already owns.
    sets.perp = set_combine(sets.idle.Avatar, {
        main="Mpaca's Staff",
        head="Beckoner's Horn +2",
        body = gear.shomonjijoe,
        hands="Beck. Bracers +2",
        legs="Assid. Pants +1",
        feet="Beck. Pigaches +2",
        ring1="Evoker's Ring",
        waist="Lucidity Sash",
    })
    -- Beckoner's Bracers +2's half-cost effect is conditional on matching
    -- avatar element day/weather; the base set already equips them.
    sets.perp.Day = {}
    sets.perp.Weather = {}
    sets.perp.Carbuncle = set_combine(sets.perp, {
        hands="Asteria Mitts +1",
    })
    sets.perp.Diabolos = set_combine(sets.perp, {waist="Diabolos's Rope"})
    sets.perp.Alexander = sets.midcast.Pet.BloodPactWard
    sets.perp.staff_and_grip = {}

  
    -- Defense / movement / latent
  
    sets.defense.PDT = sets.idle.PDT
    sets.defense.MDT = {
        main="Malignance Pole", sub="Willpower Grip",
        ammo="Crepuscular Pebble",
        head="Nyame Helm", body="Nyame Mail",
        hands="Nyame Gauntlets", legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Null Loop",
        ear1="Alabaster Earring", 
        ear2="Odnowa Earring +1",
        ring1="Murky Ring", 
        ring2="Inyanga Ring",
        back="Archon Cape", 
        waist="Platinum Moogle Belt",
    }
    sets.defense.MEVA = {
        main="Daybreak", sub="Genmei Shield",
        ammo="Crepuscular Pebble",
        head="Bunzi's Hat", body="Bunzi's Robe",
        hands="Bunzi's Gloves", legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Null Loop",
        ear1="Alabaster Earring", ear2="Odnowa Earring +1",
        ring1="Murky Ring", ring2="Inyanga Ring",
        back="Null Shawl", waist="Null Belt",
    }
    -- Kiting while an avatar is summoned.
    -- Retains the avatar-out idle equipment, with movement speed footwear.
    sets.Kiting = set_combine(sets.idle.Avatar, {feet="Herald's Gaiters", waist="Platinum Moogle Belt", })
    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.latent_refresh_grip = {sub="Oneiros Grip"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.HPDown = {}

  
    -- Buff / utility sets
  
    sets.buff.Doom = set_combine(sets.buff.Doom or {}, {})
    sets.buff.Sleep = {}
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

  
    -- Custom mode placeholders expected by SMN.lua
  
    sets.engaged = {}
    sets.element = sets.element or {}
    sets.element.Fire = {}
    sets.element.Ice = {}
    sets.element.Wind = {}
    sets.element.Earth = {}
    sets.element.Water = {}
    sets.element.Thunder = {}
    sets.element.Light = {}
    sets.element.Dark = {}

    sets.MagicBurst = set_combine(sets.midcast['Elemental Magic'], {
        neck="Mizukage-no-Kubikazari",
        ring1="Locus Ring", ring2="Freke Ring",
    })
    sets.RecoverMP = {}
    sets.RecoverBurst = set_combine(sets.RecoverMP, {})
    sets.ResistantRecoverBurst = set_combine(sets.RecoverBurst, {})
    sets.MaxTP = {}
end