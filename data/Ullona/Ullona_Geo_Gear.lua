-- =============================================================================
-- Ullona_Geo_Gear.lua
-- =============================================================================

function user_job_setup()

	-- Options
    state.OffenseMode:options('None', 'Normal')
	state.CastingMode:options('Normal', 'Resistant', 'Fodder', 'Proc', 'MB', 'MB Resistant')
    state.IdleMode:options('Normal','PDT')
	state.PhysicalDefenseMode:options('PDT', 'NukeLock', 'GeoLock', 'PetPDT')
	state.MagicalDefenseMode:options('MDT', 'NukeLock')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('None','Idris','DualWeapons')


	
	-- AutoGeo defaults
	autoindi = "Fury"
	autogeo = "Frailty"

	-- AutoGeo profiles
	autoindimelee = "Fury"
	autogeomelee  = "Frailty"
	autoindimage  = "Focus"
	autogeomage   = "Languor"

	-- Auto-Entrust defaults
	autoentrustee = "<st>"
	autoentrust = "Haste"
	
	-- =========================================================================
	-- Additional local binds
	-- ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
	-- =========================================================================
	send_command('bind !f12 gs c toggle PetHPMode')            -- Alt+F12 : Pet HP mode
	send_command('bind @f10 gs c smartna')                     -- Win+F10 : SmartNa
	send_command('bind ^backspace input /ja "Entrust" <me>')   -- Ctrl+Backspace : Entrust
	send_command('bind !backspace input /ja "Life Cycle" <me>') -- Alt+Backspace : Life Cycle
	send_command('bind @backspace input /ma "Sleep II" <t>')   -- Win+Backspace : Sleep II
	send_command('bind ^delete input /ma "Aspir III" <t>')     -- Ctrl+Delete : Aspir III
	send_command('bind @delete input /ma "Sleep" <t>')         -- Win+Delete : Sleep
	
	indi_duration = 290

	-- =========================================================================
	-- Macro Book
	-- =========================================================================
	set_macro_page(1, 4)

end

function user_job_lockstyle()
    send_command('input /lockstyleset 4')
end

function init_gear_sets()
	--------------------------------------
	-- Precast sets
	--------------------------------------

	-- Precast sets to enhance JAs
	sets.precast.JA.Bolster = {body="Bagua Tunic +1"}
	sets.precast.JA['Life Cycle'] = {body="Geo. Tunic +1", back="Nantosuelta's Cape"}
	sets.precast.JA['Radial Arcana'] = {feet="Bagua Sandals +1"}
	sets.precast.JA['Mending Halation'] = {legs="Bagua Pants +1"}
		sets.precast.JA['Cardinal Chant'] = {head="Geomancy Galero +1"}
	sets.precast.JA['Full Circle'] = {head="Azimuth Hood +1",hands="Bagua Mitaines +1"}
	
	-- Indi Duration in slots that would normally have skill here to make entrust more efficient.
	sets.buff.Entrust = {}
	
	-- Relic hat for Blaze of Glory HP increase.
	sets.buff['Blaze of Glory'] = {}
	
	-- Fast cast sets for spells


	sets.precast.FC = {		
		main="Cath Palug Hammer",
		sub="Culminus",
		head="Umuthi Hat",
		body= "Agwu's Robe",
		legs="Lengo Pants",
		hands="Mallquis Cuffs +2",
		feet="Regal Pumps",
		neck = "Voltsurge Torque",
		ear1="Malignance Earring", 
        ring2 ="Kishar Ring",
		ring1="Lebeche Ring",
		back="Alaunus's Cape",
		waist="Cornelia's Belt"}

	sets.precast.FC.Geomancy = set_combine(sets.precast.FC, {range="Dunna",ammo=empty, main="Solstice"})
	
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ear2="Malignance Earring",hands="Bagua Mitaines +1"})
sets.precast.Cure = set_combine(
    sets.precast['Healing Magic'],
    {
        legs="Doyen Pants",
        body="Vanya Robe",
        main="Daybreak",
        sub="Sors Shield",
        back="Pahtli Cape"
    }
)		

	
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {feet="inspirited Boots"}
	
	sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
		main="Daybreak",
        sub="Ammurapi Shield",
		head  ="Umuthi Hat",
        body  ="Bagua Tunic +1",
        legs  ="Bagua Pants +1",
        hands ="Bagua Mitaines +1",
        feet  ="Azimuth Gaiters +1",
        ear1  ="Andoaa Earring",
    	ear2  ="Azimuth Earring +1", -- [NEEDS INPUT] RDM-exclusive, was live -- commented out
        ring1 ="Murky Ring",
        ring2 ="Lebeche Ring",
        back  ="Estoqueur's Cape",
        waist ="Embla Sash"})
	
		sets.precast['Healing Magic'] = set_combine(sets.precast.FC, {
        main  ="Daybreak",
        sub="Sors Sheild",
        legs="Doyen Pants",
        body="Vanya Robe"
    })
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {waist="Siegel Sash", legs="Shedir Seraweels", head="Umuthi Hat", neck  ="Nodens Gorget",})
	
	sets.precast.FC.Impact =  set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})
	
	-- Weaponskill sets
sets.precast.WS = {
    main="Cath Palug Hammer",
    sub="Culminus",
    ammo="Oshasha's Treatise",
    head="Azimuth Hood +1",
    neck="Loricate Torque +1",
    ear1="Hecate's Earring",
    ear2="Malignance Earring",
    body="Bagua Tunic +1",
    hands="Bagua Mitaines +1",
    ring1="Locus Ring",
    ring2="Mujin Band",
    waist="Null Belt",
    legs="Bagua Pants +1",
    feet="Bagua Sandals +1",
}

	sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS, {
		ammo="Ghastly Tathlum",
		neck="Baetyl Pendant",
		ring1="Locus Ring",ring2="Mujin Band",
		back="Izdubar Mantle",
		waist="Hachirin-no-obi",
	})


	--------------------------------------
	-- Midcast sets
	--------------------------------------

    sets.midcast.FastRecast = {}

	sets.midcast.Geomancy = {ear2  ="Azimuth Earring +1",}


	--Extra Indi duration as long as you can keep your 900 skill cap.
	sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {back="Nantosuelta's Cape"})
		
    sets.midcast['Healing Magic'] = { 
        main  = "Bunzi's Rod",
        sub="Sacro Bulwark",
        head  ="Vanya Hood",
        body  ="Vrikodara Jupon", -- was "Bunzi's Robe" -- GEO can't equip WHM body armor, only the Rod itself. Matches the body piece already used in your own LightWeatherCure set a few lines below.
        hands ="Bokwus Gloves",
        neck  ="Nodens Gorget",
        ear2  ="Mendicant's Earring",
        ear1  ="Glorious Earring",
        ring2 ="Janniston Ring",
        ring1="Naji's Loop",
        back  ="Tempered Cape +1",
        legs  ="Vanya Slops",
        feet  ="Vanya Clogs",
    }

	sets.precast.Cure = set_combine(sets.precast.FC.Cure, {legs="Doyen Pants", body="Vanya Robe", main="Daybreak",
        sub="Sors Sheild", back="Pahtli Cape"})
		
sets.midcast.LightWeatherCure = {
    main="Chatoyant Staff",
    sub="Curatio Grip",
    ammo="Psilomene",
    head="Amalric Coif +1",
    neck="Phalaina Locket",
    ear1="Gifted Earring",
    ear2="Malignance Earring",
    body="Vrikodara Jupon",
    hands="Bokwus Gloves",
    ring1="Janniston Ring",
    ring2="Menelaus's Ring",
    back="Twilight Cape",
    waist="Hachirin-no-Obi",
    legs="Geo. Pants +1",
    feet="Vanya Clogs"
}
		
		--Cureset for if it's not light weather but is light day.
    -- main=gear.gada_healing_club, -- [PLACEHOLDER] Gada (Empyrean) -- swap back in once owned
    sets.midcast.LightDayCure = set_combine(sets.midcast['Healing Magic'], {
        main  ="Chatoyant Staff",
        sub   ="Achaq Grip",
    })


    -- [FIX 2026-08-30 -- CRASH] sets.midcast.Cure never actually existed anywhere in this
    -- file, but sets.midcast.Curaga (just below) does set_combine(sets.midcast.Cure, {...}),
    -- passing nil as the target -- exactly the "set_combine(nil, {})" crash the project's own
    -- notes warn about. Defined here, built off Healing Magic, before Curaga touches it.
    sets.midcast.Cure = set_combine(sets.precast.Cure, {})
    sets.midcast.Curaga = sets.midcast.Cure

	sets.midcast.Cursna = set_combine(sets.midcast['Healing Magic'], {
		neck=" Nodens Gorget", hands="Bokwus Gloves",
		back="Tempered Cape +1",    
		waist="Cornelia's Belt", feet="Vanya Clogs"})

	
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main="Cath Palug Hammer",sub="Clemency Grip"}) -- main was gear.grioavolr_fc_staff (Relic) -- see FC set comment above
	

    sets.midcast['Elemental Magic'] = {        
		main  ="Marin Staff +1",
     --   sub="Daduchos Grip",
	 sub="Willpower Grip",
        ammo  ="Ghastly Tathlum",
        head  ="Azimuth Hood +1",
        hands ="Leyline Gloves",
        neck  ="Baetyl Pendant",
        ear1  ="Malignance Earring",
        ear2  ="Azimuth Earring +1",
        ring2 ="Jhakri Ring",
        ring2 ="Freke Ring",
        back="Nantosuelta's Cape",
        waist ="Hachirin-no-obi"}

    sets.midcast['Elemental Magic'].Resistant = {
		main  = "Mpaca's Staff",
		neck = "Incanter's Torque",
        ear1="Gwati Earring",
        waist="Null Belt",
		back = "Null Shawl",
        range="Kaja Bow",

	}
    sets.midcast['Elemental Magic'].Fodder = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].Proc   = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke           = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder    = set_combine(sets.midcast['Elemental Magic'].Fodder, {})

    sets.midcast['Dark Magic'] = {
       head  ="Jhakri Coronal +2",
        body  ="Jhakri Robe +2",
        legs  ="Jhakri Slops +2",
      	hands ="Jhakri Cuffs +2",
        feet  ="Jhakri Pigaches +2",
        neck  ="Erra Pendant",
        ear2  ="Alabaster Earring",
        ear1  ="Malignance Earring",
        ring1 ="Crepuscular Ring",
        ring2="Evanescence Ring",
        back="Nantosuelta's Cape",
        waist ="Eschan Stone",
        ammo="Ghastly Tathlum",
        range=empty,
        main="Marin Staff +1",
		sub="Willpower Grip"
      --  sub="Daduchos Grip"
	  }
		
    sets.midcast.Drain          = set_combine(sets.midcast['Dark Magic'], {neck="Erra Pendant"})
    sets.midcast.Aspir          = set_combine(sets.midcast.Drain, {waist="Fucho-no-obi", feet="Merlinic Crackows"})
    sets.midcast.Stun           = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {})
		
	sets.midcast.Impact = set_combine(sets.precast.FC.Impact, {}) 
		
	sets.midcast['Enfeebling Magic'] = {        
		main  ="Mpaca's Staff",
       --- sub="Daduchos Grip", --currently unable to equip until master
	   sub="Willpower Grip",
     --   head  ="Azimuth Hood +1",
        body  ="Vanya Robe",
       -- legs  ="Bagua Pants +1",
        --hands ="Bagua Mitaines +1",
        feet  ="Skaoi Boots",
		ring1  = "Mallquis Ring",
        ring2 ="Kishar Ring",
        ear2="Malignance Earring",   
        ear1="Gifted Earring",
    	neck="Null Shawl",
        back  ="Lifestream Cape",
        waist ="Null Belt",
		range="Dunna"}
		
	sets.midcast['Enfeebling Magic'].Resistant = {      
		back ="Null Shawl",
        main ="Chatoyant Staff",
        ear1="Snotra Earring",
     --   sub="Daduchos Grip",
	 sub="Willpower Grip",
        ring1="Vertigo Ring",
        neck="Null Loop",
}

	sets.midcast.Dispel = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})
	sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{main="Daybreak", sub="Culminus"})
		
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    -- INT/MND enfeeble aliases point to ElementalEnfeeble
    -- (using set_combine avoids aliasing the same table, preventing .Resistant cross-contamination)
    sets.midcast.IntEnfeebles           = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})
    sets.midcast.MndEnfeebles           = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})
	
	-- [FIX 2026-08-30 -- ORDERING] Moved up from the bottom of the file, where it was defined
	-- AFTER Dia/Bio below already tried to use it -- sets.TreasureHunter was nil at the point
	-- those set_combine calls ran. Whether that silently no-ops or crashes depends on how
	-- set_combine handles a nil second argument, but either way it's the same forward-reference
	-- mistake the project notes already warn about, so fixed regardless.
	sets.TreasureHunter = {ammo="Perfect Lucky Egg", waist="Chaac Belt"}

	sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        feet="Medium's Sabots",
        body="Vanya Robe",
    })
		
	-- main=gear.gada_enhancing_club, -- [PLACEHOLDER] Gada (Empyrean) -- swap back in once owned
	sets.midcast['Enhancing Magic'] = {	    
		head  ="Umuthi Hat",
        body  ="Bagua Tunic +1",
        legs  ="Bagua Pants +1",
        hands ="Bagua Mitaines +1",
        feet  ="Azimuth Gaiters +1",
        ear1  ="Andoaa Earring",
        ear2  ="Lethargy Earring",
        ring1 ="Murky Ring",
        ring2 ="Lebeche Ring",
        waist ="Embla Sash"
    }
		
    sets.midcast.Stoneskin   = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash", legs="Shedir Seraweels", head="Umuthi Hat", neck  ="Nodens Gorget",})
	sets.Self_Refresh  = set_combine(sets.midcast['Enhancing Magic'],{feet="Inspirited Boots"})
    sets.precast.Aquaveil    = set_combine(sets.precast.FC['Enhancing Magic'], {main="Vadose Rod", sub="Culminus",})
	sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {legs="Shedir Seraweels"})
	
	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------

	-- Resting sets
	sets.resting = {main="Chatoyant Staff",sub="Oneiros Grip",}

	-- Idle sets

	sets.idle = {       
		main="Daybreak",
        sub="Sacro Bulwark",
        ammo  =empty,
		ranged="Dunna",
        head  ="Azimuth Hood +1",
        body  ="Bagua Tunic +1",
      --  hands =
       -- feet  =
        neck  ="Null Loop",
        ear1  ="Moonshade Earring",
        ear2  ="Alabaster Earring",
        ring1="Ayanmo Ring",
        ring2 ="Murky Ring",
        back  ="Archon Cape",
        waist ="Null Belt",
	}
		
	sets.idle.PDT = {main="Malignance Pole",
	--sub=Daduchos Grip (to be reenabled once master)
	}

	-- .Pet sets are for when Luopan is present.
sets.idle.Pet = {
    main="Solstice",
    sub="Culminus",
    range="Dunna",
    head="Azimuth Hood +1",
    neck="Loricate Torque +1",
    ear1="Enmerkar Earring",
    ear2="Alabaster Earring",
    body="Jhakri Robe +2",
    hands="Geo. Mitaines +1",
    ring1="Defending Ring",
    ring2="Dark Ring",
    back=gear.idle_jse_back,
    waist="Isa Belt",
    legs="Psycloth Lappas",
    feet="Bagua Sandals +1",
    neck="Bagua Charm +1"
}

sets.idle.PDT.Pet = {
    main="Solstice",
    sub="Umbra Strap",
    range="Dunna",
    head="Azimuth Hood +1",
    neck="Loricate Torque +1",
    ear1="Handler's Earring",
    ear2="Handler's Earring +1",
    body="Jhakri Robe +2",
    hands="Geo. Mitaines +1",
    ring1="Defending Ring",
    ring2="Dark Ring",
    back="Nantosuelta's Cape",
    waist="Isa Belt",
    legs="Hagondes Pants +1",
    feet="Bagua Sandals +1"
}
	-- .Indi sets are for when an Indi-spell is active.
	sets.idle.Indi = set_combine(sets.idle, {})
	sets.idle.Pet.Indi = set_combine(sets.idle.Pet, {}) 
	sets.idle.PDT.Indi = set_combine(sets.idle.PDT, {}) 
	sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, {})

	sets.idle.Weak = set_combine(sets.idle.PDT, {})

	-- Defense sets
	
	sets.defense.PDT = {}

	sets.defense.MDT = {}
		
    sets.defense.MEVA = {}
		
	sets.defense.PetPDT = sets.idle.PDT.Pet
		
	sets.defense.NukeLock = sets.midcast['Elemental Magic']
	
	sets.defense.GeoLock = sets.midcast.Geomancy.Indi

	sets.Kiting = {feet="Geomancy Sandals +1"}

	sets.PetHP = {head="Bagua Galero +1", back="Nantosuelta's Cape"}
	sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {main= "Mpaca's Staff", sub="Oneiros Grip"}
 
	sets.DayIdle = {}
	sets.NightIdle = {}
	
	sets.HPDown = {}
	
	sets.buff.Doom = {}



	-- Normal melee group
	sets.engaged = {}
		
	sets.engaged.DW = {}

	--------------------------------------
	-- Custom buff sets
	--------------------------------------
	
	-- Gear that converts elemental damage done to recover MP.	
	sets.RecoverMP = {}
	
	sets.MagicBurst = set_combine(sets.midcast['Divine Magic'], 
	{
		main="Bunzi's Rod", sub="Culminus",
  head="Agwu's Cap",
body="Agwu's Robe",
hands="Agwu's Gages",
legs="Agwu's Slops",
feet="Agwu's Pigaches",
        neck  ="Mizukage-no-Kubikazari",
        ring2 ="Freke Ring",
        ring1 ="Locus Ring",})

  sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})
	sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
	
	-- Weapons sets
	sets.weapons.Idris = {main="Cath Palug Hammer",sub="Culminus"} -- [RENAMED 2026-08-30] was sets.weapons.Nehushtan -- named for the actual target weapon (Idris, GEO's Ergon/Mythic club) as a running reminder. Swap main to "Idris" once earned.
	sets.weapons.DualWeapons = {main="Cath Palug Hammer",sub="Vadose Rod"}

	-----placeholder----
	-- Referenced in GEO.lua but not yet gear-defined. Built via set_combine off their real
	-- base sets so they inherit sensible gear immediately instead of equipping nothing --
	-- fill in the {} overrides with anything Resistant/Burst-specific whenever ready.
	sets.element.Fire = {}
	sets.element.Ice = {}
	sets.element.Wind = {}
	sets.element.Earth = {}
	sets.element.Water = {}
	sets.element.Thunder = {}
	sets.element.Light = {}
	sets.element.Dark = {}
	sets.RecoverBurst = set_combine(sets.RecoverMP, {})
	sets.ResistantRecoverBurst = set_combine(sets.RecoverBurst, {})
	sets.MaxTP = {}
	-----placeholder----
end

