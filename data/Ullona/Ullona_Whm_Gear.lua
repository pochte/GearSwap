-- Setup vars that are user-dependent. Can override this in a sidecar file.
function user_job_setup()
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','SIRD','DT','MB','MB Resistant')
    state.IdleMode:options('Normal','PDT','MDT')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')
    state.Weapons:options('None','DualWeapons','MeleeWeapons')
    state.WeaponskillMode:options('Normal','Fodder')



    -- Force Macro Book 1 / Page 1
    set_macro_page(1, 1)

    -- Additional local binds
    send_command('bind != input /ja "Penury" <me>')              -- Alt + =
    send_command('bind ^@!` gs c toggle AutoCaress')             -- Ctrl + Win + Alt + `
    send_command('bind ^backspace input /ja "Sacrosanctity" <me>') -- Ctrl + Backspace
    send_command('bind @backspace input /ma "Aurorastorm" <me>') -- Win + Backspace
    send_command('bind !pause gs c toggle AutoSubMode')         -- Alt + Pause
    send_command('bind ^a gs c barelement')                     -- Ctrl + A
    send_command('bind !a gs c barstatus')                      -- Alt + A
    send_command('bind @a gs c smartregen')                    -- Win + A
    send_command('bind @f10 gs c smartna')                      -- Win + F10
end

function user_job_lockstyle()
    send_command('input /lockstyleset 1')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------

	-- Weapons sets
	sets.weapons.MeleeWeapons = {main="Kaja Rod", sub="Culminus", range=empty, ammo="Crepuscular Pebble"}
	sets.weapons.DualWeapons = {}
	
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    -- [FIX] Removed two stray job_precast(spell, spellMap, eventArgs) stubs that were pasted
    -- here (each just calling check_ecphoria_for_ja(spell)). Same last-definition-wins bug
    -- already fixed once in Ullona_Rdm_Gear.lua and once in Ullona_Thf_Gear.lua -- since gear
    -- files load after job files, these stubs were silently REPLACING WHM.lua's real,
    -- fully-featured job_precast (Cure/Cursna/Afflatus Solace/Afflatus Misery handling, etc.)
    -- with a function that did nothing else. WHM.lua's actual job_precast already calls
    -- check_ecphoria_for_ja(spell) itself (line 170), so nothing of value is lost by removing
    -- these -- they were pure duplicates, and destructive ones at that.
    -- Precast Sets
    -- Fast cast sets for spells
    sets.precast.FC = {
		main="Cath Palug Hammer",
		sub="Culminus",
		head="Ebers Cap +3",
		body="Inyanga Jubbah +2",
		legs="Ayanmo Cosciales +2",
		hands="Fanatic Gloves",
		feet="Regal Pumps",
		neck = "Voltsurge Torque",
		ear1="Malignance Earring", 
        ring2 ="Kishar Ring",
		ring1="Lebeche Ring",
		back="Alaunus's Cape",
		waist="Cornelia's Belt"}
		
    sets.precast.FC.DT = sets.precast.FC 

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
    main = "Daybreak",
    sub  = "Ammurapi Shield",
     body="Ebers Bliaut +3",
		legs="Gyve Trousers",
		neck="Null Shawl",
		ear1="Magnetic Earring",
		waist="Siegel Sash",
		feet="Ebers Duckbills +3",})
	
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
		legs="Querkening Brais",
		waist="Embla Sash",
		neck  ="Nodens Gorget"
	})

sets.precast.FC['Healing Magic'] = set_combine(
    sets.precast.FC, {
        main="Vadose Rod",
		sub="Sors Shield",
        head = "Piety Cap +4",
        body = "Ebers Bliaut +3",
        legs= "Ebers Pantaloons +3",
		feet= "Hygieia Clogs",
        hands = "Fanatic Gloves",
        neck = "Cleric's Torque",
        ear1="Malignance Earring", 
        ear1  = "Alabaster Earring",
        back = "Alaunus's Cape",
        waist = "Acerbic Sash +1",
		ring2="Janniston Ring",
    }
)
	sets.precast.Cure=set_combine(sets.precast.FC['Healing Magic'],{legs="Doyen Pants", body="Vanya Robe", ear1="Nourishing Earring", ear2="Mendicant's Earring", back="Pahtli Cape"})
    sets.precast.Aquaveil    = set_combine(sets.precast.FC['Enhancing Magic'], {main="Vadose Rod", sub="Culminus",})
    sets.precast.FC.StatusRemoval = set_combine(sets.precast.FC['Healing Magic'],{legs="Piety Pantaloons +3",
	back="Alaunus's Cape", head="Ebers Cap+3", body="Ebers Bliaut +3", main= "Kaja Staff", sub="Clemency Grip"
	---main=
	})
	sets.precast.FC.Impact =  set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
	
    -- Precast sets to enhance JAs
    sets.precast.JA.Benediction = {body="Piety Bliaut +4"}
    sets.precast.JA.Devotion = {head="Piety Cap +4"}
    sets.precast.JA['Afflatus Misery'] = {legs="Piety Pantaloons +3"}

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
	neck="Fotia Gorget",
    ear1="Cessance Earring",    
    ear2="Ebers Earring +1",  
	ring1="Cornelia's Ring",  
    ring2="Mars's Ring",       
    waist="Fotia Belt",
	legs="Lengo Pants",
	feet="Medium's Sabots",
	head="Sukeroku Hachimaki"
	}

    -- Midcast Sets

    sets.Kiting = {feet="Herald's Gaiters", ammo  = "Crepuscular Pebble",  main="Malignance Pole", sub="Daduchos Grip", waist="Platinum Moogle Belt"}
    sets.latent_refresh = {main="Daybreak", sub="Archduke's Shield", waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {}
	sets.TPEat = {}
	sets.DayIdle = {}
	sets.NightIdle = {}
	sets.TreasureHunter = {ammo="Perfect Lucky Egg", waist="Chaac Belt"}
	
	--Situational sets: Gear that is equipped on certain targets
	sets.Self_Healing = {ring1="Kunaji Ring" }
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

	-- Conserve Mp set for spells that don't need anything else, for set_combine.

sets.ConserveMP = set_combine(
    sets.precast.FC,
    { 	
        head="Ebers Cap +3",
		feet="Medium's Sabots",
        ear1 = "Gifted Earring",
		ring2="Murky Ring",
		legs="SV loincloth +1"
    }
)

		
	sets.midcast.Teleport = sets.ConserveMP
	
	sets.midcast.FastRecast = sets.precast.FC
		
    -- Cure sets

    sets.midcast['Full Cure'] = sets.midcast.FastRecast

    sets.midcast.Cure = set_combine(sets.precast.FC['Healing Magic'], {
        main="Bunzi's Rod",
        sub="Sors Shield",
        waist="Hachirin-no-Obi",
        head="Ebers Cap +3",
        hands="Theophany Mitts +4",
        neck="Cleric's Torque",
        feet="Piety Duckbills +4",
        ear1="Nourishing Earring",
        ear2="Glorious Earring",
        ammo="Psilomene",
    })
    sets.midcast.Cure.DT = sets.midcast.Cure

    sets.midcast.CureSolace = set_combine(sets.midcast.Cure, {})

    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {
        waist="Hachirin-no-obi",
        main="Chatoyant Staff",
        sub="Daduchos Grip",
        back="Twilight Cape"
    })
    sets.midcast.LightWeatherCureSolace = set_combine(sets.midcast.LightWeatherCure, {})

    -- [FIX 8]: LightDayCure/LightDayCureSolace were direct aliases to LightWeatherCureSolace
    --          (same table in memory, same bug pattern as FIX 6). set_combine now gives
    --          each its own independent copy.
    sets.midcast.LightDayCure       = set_combine(sets.midcast.LightWeatherCureSolace, {})
    sets.midcast.LightDayCureSolace = set_combine(sets.midcast.LightWeatherCureSolace, {})

    --change ebers for normal cure, then Theophany Bliaut +2 for curaga
    sets.midcast.LightWeatherCuraga = set_combine(sets.midcast.LightWeatherCureSolace, {body = "Theophany Bliaut +4"})
    sets.midcast.LightDayCuraga     = set_combine(sets.midcast.LightWeatherCuraga, {})

    -- [FIX 9]: StatusRemoval moved above Cursna/Erase — both reference it via set_combine,
    --          and it was previously defined AFTER Cursna tried to use it (nil reference,
    --          same bug class as FIX 2 with MagicBurst).
    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        back="Alaunus's Cape",
        head="Ebers Cap+3",
        body="Ebers Bliaut +3",
        main="Kaja Staff",
        sub="Clemency Grip",
        legs="Ebers Pantaloons +3"
    })

    sets.midcast.Cursna = set_combine(sets.midcast.StatusRemoval, {
        back="Alaunus's Cape",
        legs="Theophany Pantaloons +4",
        hands="Fanatic Gloves",
        body="Ebers Bliaut +3",
        ear2="Ebers Earring +1"
    })

    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {neck="Cleric's Torque"})

    -- 110 total Enhancing Magic Skill; caps even without Light Arts
	sets.midcast['Enhancing Magic'] = {	
        head="Umuthi Hat",
		legs="Piety Pantaloons +3",
		hands="Theophany Mitts +4",
		feet="Theophany Duckbills +4",
		neck="Null Shawl",
		ear1="Ebers Earring +1",
		ear2="Andoaa Earring",  
		ring2="Murky Ring",
		ring1="Vertigo Ring",
		back="Izdubar Mantle",
		waist="Siegel Sash",
    main = "Daybreak",
    sub  = "Ammurapi Shield"}

	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash", legs="Shedir Seraweels", feet="Piety Duckbills +4", head="Umuthi Hat", neck  ="Nodens Gorget"})
	sets.midcast.Auspice = set_combine(sets.midcast['Enhancing Magic'], {})
	sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
		main="Bolelabunga",
    sub  = "Ammurapi Shield",
		body="Piety Bliaut +4",
		hands="Ebers Mitts +3",
		legs="Theophany Pantaloons +4",
		head="Inyanga Tiara +2"
	})
	
	sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {
		head="Ebers Cap +3",
		body="Ebers Bliaut +3",
		legs="Piety Pantaloons +3",
		hands="Dynasty Mitts",
		feet="Ebers Duckbills +3"
	})

sets.midcast['Divine Magic'] = {
		main="Marin Staff +1",
		sub="Willpower Grip",
        ammo="Ghastly Tathlum",
		head="Inyanga Tiara +2",
		body="Vanya Robe",
		legs="SV loincloth +1",
		hands="Fanatic Gloves",
		feet="Inyanga Crackows +2",
		neck="Baetyl Pendant",
		ear1="Malignance Earring", 
		ear2="Hecate's Earring",
		ring1="Locus Ring",
		ring2="Freke Ring",
		back="Izdubar Mantle",
		waist="Hachirin-no-obi"
	}

	-- [FIX 2]: MagicBurst moved here from before Divine Magic was defined (crash on load)
	--          Also fixed typo: ing2= → ring2=
	sets.MagicBurst = set_combine(sets.midcast['Divine Magic'], {
		main="Bhunzi's Rod", sub="Culminus",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        feet="Bunzi's Sabots",
        neck  ="Mizukage-no-Kubikazari",
        ring2 ="Freke Ring",
        ring1 ="Locus Ring",
	})

sets.midcast.Impact = set_combine(sets.precast.FC.Impact, {}) -- [FIX 4]: was sets.precast.Impact (wrong path — Impact is in sets.precast.FC.Impact)
	-- [FIX 5]: was sets.midcast['Divine Magic'] (direct alias) — adding .Resistant would mutate
	--          Divine Magic as well. set_combine makes a proper independent copy.
	sets.midcast['Elemental Magic'] = set_combine(sets.midcast['Divine Magic'], {})
	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'],{neck="Erra Pendant"
})
sets.midcast['Dark Magic'] = set_combine(
    sets.midcast['Elemental Magic'],   {
        neck = "Null Shawl",
        ear2 = "Alabaster Earring",
        ring2 = "Archon Ring",
		ring1="Evanescence Ring",
		waist="Null Belt"
    }
)


    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {neck="Erra Pendant", waist="Fucho-no-obi", feet="Merlinic Crackows", ring1="Evanescence Ring"})
    sets.midcast.Drain.Resistant = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Aspir = sets.midcast.Drain
	sets.midcast.Aspir.Resistant = sets.midcast.Drain.Resistant

	sets.midcast.Stun = {}
	sets.midcast.Stun.Resistant = sets.midcast.Stun
		

sets.midcast['Enfeebling Magic'] = {
	main  ="Mpaca's Staff",
    sub="Daduchos Grip",
    head="Piety Cap +4",
    body="Theophany Bliaut +4",
	legs="Theophany Pantaloons +4",
    feet="Theophany Duckbills +4",
    neck="Null Shawl",
	ear1="Malignance Earring", 
	ear2="Ebers Earring +1",
        ring2 ="Kishar Ring",
    ring1="Crepuscular Ring",
    waist=" Obstinate Sash",
	back="Null Shawl",
	ranged="Aureole"
}



 sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
	main="Mpaca's Staff",
    hands="Cleric's Mitts +2",
	waist="Null Belt"
})

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

	-- [FIX 6]: were direct aliases to ElementalEnfeeble — assigning .Resistant to one would
	--          corrupt the others. set_combine creates proper independent copies.
	sets.midcast.IntEnfeebles          = set_combine(sets.midcast.ElementalEnfeeble, {})
	sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})

	sets.midcast.MndEnfeebles           = set_combine(sets.midcast.ElementalEnfeeble, {})
	sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})
    -- Sets to return to when not performing an action.

    -- Idle sets — defined BEFORE sets.resting so set_combine has a valid base  [FIX 7]
	sets.idle = {
main="Daybreak",
sub="Archduke's Shield",
		ammo="Psilomene",
		head="Inyanga Tiara +2",
		body="Ebers Bliaut +3",
		legs="Assiduity Pants +1",
		hands="Inyanga Dastanas +2",
		feet="Inyanga Crackows +2",
		neck="Null Loop",
		ear2="Moonshade Earring",
		ear1="Alabaster Earring",
		ring2="Murky Ring",
		ring1="Inyanga Ring",
		back="Archon Cape",
		waist="Acerbic Sash +1"
	}

	sets.idle.PDT    = set_combine(sets.idle, {legs="SV loincloth +1", main="Malignance Pole", sub="Daduchos Grip"})
	sets.idle.MDT    = set_combine(sets.idle, {})
	sets.idle.DTHippo = set_combine(sets.idle, {})
    sets.idle.Weak   = set_combine(sets.idle, {})

    -- Resting: now safely references sets.idle  [FIX 7]
    sets.resting = set_combine(sets.idle, {
    main="Chatoyant Staff",
    sub="Daduchos Grip",
	body="Inyanga Jubbah +2",
    legs="Assiduity Pants +1",
    ear2="Magnetic Earring"
})

    -- Defense sets

	  sets.defense.PDT = sets.idle.PDT

	sets.defense.MDT = sets.idle.MDT
		
    sets.defense.MEVA = sets.idle.MDT
		
		-- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Basic set for if no TP weapon is defined.
    sets.engaged = {legs="Perdition slops"}

    sets.engaged.Acc = sets.engaged
	sets.engaged.DW = sets.engaged
    sets.engaged.DW.Acc = sets.engaged

    sets.buff['Divine Caress'] = {
		hands="Ebers Mitts +3"
	}
	sets.HPDown = {}

	sets.HPCure = {}

	sets.buff.Doom = set_combine(sets.buff.Doom, {})

end

