-- =============================================================================
-- Ullona_Rdm_Gear.lua — Changelog
-- 2026-08-30: [FIX -- MAIN WEAPON DROP BUG] Added sets.midcast.Cure, which was never
--             actually defined anywhere in this file -- only sets.midcast['Healing Magic']
--             (the base) and sets.midcast.Curaga (an explicit copy of it) existed. Casting
--             plain Cure with no Light weather/day active resolves to an unmapped
--             spellMap, so GearSwap looked up sets.midcast.Cure directly, found nothing,
--             and midcast gear came up effectively empty -- main weapon never got
--             re-equipped after precast finished. Same missing-definition bug class as the
--             GEO.lua/Ullona_Geo_Gear.lua crash fixed earlier this session (there, Curaga
--             referenced a sets.midcast.Cure that never existed and crashed outright; here
--             nothing referenced it directly so it just silently equipped nothing instead).
--             Fixed the same way Curaga already was: an explicit copy of Healing Magic.
-- =============================================================================


function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal','Acc','FullAcc')
    state.HybridMode:options('Normal','DT')
    state.WeaponskillMode:options('Match','Proc') 
    state.AutoBuffMode:options('Off','Auto','AutoMelee')
    state.CastingMode:options('Normal','Resistant','Fodder','Proc','MB','MB Resistant')
    state.IdleMode:options('Normal','PDT','MDT')
    state.PhysicalDefenseMode:options('PDT','NukeLock')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')
    state.Weapons:options('None','DualWeapons','EnspellMelee')

    -- =========================================================================
    -- Macro Book
    -- =========================================================================
    set_macro_page(1, 3) -- Page 1, Macro Book 3

    -- =========================================================================
    -- Additional local binds — every keybind noted below for quick reference.
    -- Modifier key: ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    -- =========================================================================
    send_command('bind ^@!` input /ja "Accession" <me>')           -- Ctrl+Win+Alt + ` : Accession
    send_command('bind ^backspace input /ja "Saboteur" <me>')      -- Ctrl + Backspace  : Saboteur
    send_command('bind !backspace input /ja "Spontaneity" <t>')    -- Alt + Backspace   : Spontaneity
    send_command('bind @backspace input /ja "Composure" <me>')     -- Win + Backspace   : Composure
    send_command('bind != input /ja "Penury" <me>')                -- Alt + =           : Penury
    send_command('bind @= input /ja "Parsimony" <me>')             -- Win + =           : Parsimony
    send_command('bind ^delete input /ja "Dark Arts" <me>')        -- Ctrl + Delete     : Dark Arts
    send_command('bind !pause input /ja "Light Arts" <me>')        -- Alt + Pause        : Light Arts
    send_command('bind !delete input /ja "Addendum: Black" <me>')  -- Alt + Delete      : Addendum: Black
    send_command('bind @delete input /ja "Manifestation" <me>')    -- Win + Delete       : Manifestation
    send_command('bind @f10 gs c smartna')                         -- Win + F10          : SmartNa
end

function user_job_lockstyle()
    send_command('input /lockstyleset 3')
end


function init_gear_sets()
	--------------------------------------
	-- Start defining the sets
	--------------------------------------
	
	-- Precast Sets
	sets.precast.JA['Chainspell'] = {body="Vitiation Tabard +4"}
	

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
		
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}

	-- Fast cast sets for spells
	
	sets.precast.FC =  {  
		main="Marin Staff +1",
        sub="Daduchos Grip",
        head = "Atrophy Chapeau +4",
        body  ="Vitiation Tabard +4",
        legs  ="Ayanmo Cosciales +2",
        hands ="Leyline Gloves",
        feet  ="Bunzi's Sabots",
        ear1  ="Malignance Earring",
        ear2  ="Lethargy Earring",
        ring1="Naji's Loop",
        ring2 ="Kishar Ring",
        waist ="Cornelia's Belt",
        neck = "Voltsurge Torque"
    }
	
	sets.precast.FC.Enfeebling = set_combine(sets.precast.FC, {head="Lethargy Chappel +3"})
    sets.precast.Stoneskin     = set_combine(sets.precast.FC, {waist="Siegel Sash", legs="Querkening Brais"})
    sets.precast.FC.Impact     = set_combine(sets.precast.FC, {head=empty, body="Twilight Cloak", ring1 ="Archon Ring"})
    sets.precast.FC.Utsusemi   = set_combine(sets.precast.FC, {neck="Magoraga Beads"})
    sets.precast.FC.Dispelga   = set_combine(sets.precast.FC, {main="Daybreak", sub="Culminus"})

	sets.precast['Healing Magic'] = set_combine(sets.precast.FC, {
        main  ="Daybreak",
        sub="Sors Sheild",
        legs="Doyen Pants",
        body="Vanya Robe"
    })
       
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
	    head  ="Vitiation Chapeau +4",
        body  ="Egbesu Frock",
        legs  ="Malignance Tights",
        hands ="Atrophy Gloves +4",
        feet  ="Lethargy Houseaux +3",
        neck  ="Fotia Gorget",
        back  ="Sucellos's Cape",
        waist ="Fotia Belt",
        ear2  ="Ishvara Earring",
        ear1  ="Crepuscular Earring",
        ring2 ="Rufescent Ring",
	ring1="Cornelia's Ring",  
        ammo="Oshasha's Treatise",
        range=empty

    }
		
	sets.precast.WS.Proc = 	sets.precast.WS

	-- Midcast Sets

	
	-- Gear that converts elemental damage done to recover MP.	
	sets.RecoverMP = {}

sets.midcast.FastRecast = sets.precast.FC

    sets.midcast['Healing Magic'] = { 
        main  = "Bunzi Rod",
        sub="Sacro Bulwark",
        head  ="Vanya Hood",
        body  ="Bunzi's Robe",
        hands ="Bokwus Gloves",
        neck  ="Nodens Gorget",
        ear2  ="Mendicant's Earring",
        ear1  ="Glorious Earring",
        ring2 ="Janniston Ring",
        ring1="Naji's Loop",
        back  ="Ghostfyre Cape",
        legs  ="Atrophy Tights +3",
        feet  ="Vanya Clogs",
    }

	sets.precast.Cure = set_combine(sets.precast['Healing Magic'], {legs="Doyen Pants", body="Vanya Robe", main="Daybreak",
        sub="Sors Sheild", back="Pahtli Cape"})
	sets.midcast.Cure = set_combine(sets.midcast['Healing Magic'], {})
    sets.midcast.LightWeatherCure = {		
        main  ="Chatoyant Staff",
        sub   ="Achaq Grip",}
    sets.midcast.LightDayCure = set_combine(sets.midcast['Healing Magic'], {
        main  ="Chatoyant Staff",
        sub   ="Achaq Grip",})

	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {})

	-- [FIX 11]: was set_combine(sets.midcast.Cure, {...}) — sets.midcast.Cure doesn't exist
	--           anywhere in this file (per FIX 2, it's sets.midcast['Healing Magic']).
	--           Was combining against nil.
	sets.midcast.Cursna = set_combine(sets.midcast['Healing Magic'], {
		neck=" Nodens Gorget", hands="Bokwus Gloves",
		back="Tempered Cape +1  ",    
		waist="Cornelia's Belt", feet="Vanya Clogs"
	})

	-- [FIX 12]: was a direct alias to sets.midcast.Cure (undefined) — same nil-reference
	--           bug as Cursna, plus the direct-assignment aliasing risk from FIX 6/8.
	--           Now a proper independent copy of the correct set.
	sets.midcast.Curaga = set_combine(sets.midcast['Healing Magic'], {})

	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {head="Amalric Coif +1"}

	sets.midcast['Enhancing Magic'] = {
	    head  ="Lethargy Chappel +3",
        body  ="Lethargy Sayon +3",
        legs  ="Lethargy Fuseau +3",
        hands ="Lethargy Gantherots +3",
        feet  ="Lethargy Houseaux +3",
        neck  ="Duelist's Torque +1",
        ear1  ="Andoaa Earring",
        ear2  ="Lethargy Earring",
        ring1 ="Murky Ring",
        ring2 ="Lebeche Ring",
        back  ="Sucellos's Cape",
        waist ="Embla Sash"
    }
	sets.buff.ComposureOther = {	    
        head  ="Lethargy Chappel +3",
        body  ="Lethargy Sayon +3",
        legs  ="Lethargy Fuseau +3",
        hands ="Lethargy Gantherots +3",
        feet  ="Lethargy Houseaux +3",}
		
	--Red Mage enhancing sets are handled in a different way from most, layered on due to the way Composure works
	--Don't set combine a full set with these spells, they should layer on Enhancing Set > Composure (If Applicable) > Spell

	sets.midcast.BoostStat = {hands="Vitiation Gloves +3"}
	sets.Self_Refresh  = set_combine(sets.midcast['Enhancing Magic'],{feet="Inspirited Boots"})
    sets.midcast.Regen       = set_combine(sets.midcast['Enhancing Magic'], {main="Bolelabunga"})
    sets.EnhancingSkill      = set_combine(sets.midcast['Enhancing Magic'], {hands="Vitiation Gloves +3"})
    sets.midcast.Refresh     = set_combine(sets.midcast['Enhancing Magic'], {legs="Lethargy Fuseau +3", body="Vitiation Tabard +4"})
    sets.precast.Aquaveil    = set_combine(sets.precast.FC, {hands="Vitiation Gloves +3", main="Vadose Rod", sub="Culminus"})
    sets.midcast.Refresh     = set_combine(sets.midcast['Enhancing Magic'], {legs="Lethargy Fuseau +3", body="Vitiation Tabard +4"})
    sets.midcast.BarElement  = set_combine(sets.midcast['Enhancing Magic'], {hands="Vitiation Gloves +3"})
    sets.midcast.Temper      = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Temper.DW   = set_combine(sets.midcast.Temper, {})
    sets.midcast.Enspell     = set_combine(sets.midcast.Temper, {back="Ghostfyre Cape", legs="Vitiation Tights +4", head="Umuthi Hat", main="Archduke's Sword"})
    sets.midcast.Enspell.DW  = set_combine(sets.midcast.Enspell, {})
    sets.midcast.Stoneskin   = set_combine(sets.midcast['Enhancing Magic'], {waist="Siegel Sash", legs="Shedir Seraweels", head="Umuthi Hat", hands="Vitiation Gloves +3", neck  ="Nodens Gorget",})
    sets.midcast.ShockSpikes = set_combine(sets.midcast['Enhancing Magic'], {legs="Vitiation Tights +4"})
    sets.midcast.BlazeSpikes = set_combine(sets.midcast.ShockSpikes, {})
    sets.midcast.IceSpikes   = set_combine(sets.midcast.ShockSpikes, {})
    sets.midcast.Gain        = set_combine(sets.midcast['Enhancing Magic'], {hands="Vitiation Gloves +3"})
    sets.precast.JA.Chainspell = {body="Vitiation Tabard +4"}

	
	sets.midcast['Enfeebling Magic'] =  
    {
		main  ="Mpaca's Staff",
        sub="Daduchos Grip",
        head  ="Vitiation Chapeau +4",
        body  ="Lethargy Sayon +3",
        legs  ="Lethargy Fuseau +3",
        hands ="Lethargy Gantherots +3",
        feet  ="Vitiation Boots +3",
        neck  ="Duelist's Torque +1",
        ring2 ="Kishar Ring",
        ring1="Crepuscular Ring",
        back  ="Sucellos's Cape",
        waist ="Null Belt",
        ear2  ="Lethargy Earring",
        ear1  ="Malignance Earring",
        range=empty,
        ammo="Regal Gem" -- [FIX] explicit alongside the deliberate Kaja Bow, so nothing combined on top of this set can leave a stray ammo piece fighting the bow
    }
		
	sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        back ="Null Shawl",
        main ="Chatoyant Staff",
        ear1="Snotra Earring",
        sub="Daduchos Grip",
        ring1="Vertigo Ring",
        neck="Null Loop",
    })		
	sets.midcast.DurationOnlyEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {body="Atrophy Tabard +4", ear1="Snotra Earring", waist=" Obstinate Sash"}) -- [FIX] Kaja Bow retired: no range override, so it inherits range=empty/ammo="Regal Gem" from the base Enfeebling Magic set
	sets.midcast.Silence = set_combine(sets.midcast.DurationOnlyEnfeebling, {})
	sets.midcast.Silence.Resistant = sets.midcast['Enfeebling Magic'].Resistant
	sets.midcast.Sleep = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast.Sleep.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{waist=" Null Belt"})
	sets.midcast.Bind = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast.Bind.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{waist=" Null Belt"})
	sets.midcast.Break = set_combine(sets.midcast.DurationOnlyEnfeebling,{})
	sets.midcast.Break.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{waist=" Null Belt"})
	sets.midcast.Dispel = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})
	sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'].Resistant,{main="Daybreak", sub="Culminus"})
	sets.midcast.SkillBasedEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {ear1="Alabaster Earring",hands="Leth. Gantherots +1",legs="Psycloth Lappas"})
	sets.midcast['Frazzle II'] = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})
	sets.midcast['Frazzle III']            = set_combine(sets.midcast.SkillBasedEnfeebling, {})
	sets.midcast['Frazzle III'].Resistant  = sets.midcast['Enfeebling Magic'].Resistant
	sets.midcast['Distract III']           = set_combine(sets.midcast.SkillBasedEnfeebling, {})
	sets.midcast['Distract III'].Resistant = sets.midcast['Enfeebling Magic'].Resistant

    sets.midcast['Elemental Magic'] = {
        main  ="Marin Staff +1",
        sub="Daduchos Grip",
        ammo  ="Ghastly Tathlum",
        head  ="Lethargy Chappel +3",
        body  ="Bunzi's Robe",
        legs  ="Lethargy Fuseau +3",
        hands ="Lethargy Gantherots +3",
        feet  ="Vitiation Boots +3",
        neck  ="Baetyl Pendant",
        ear1  ="Malignance Earring",
        ear2  ="Hecate's Earring",
        ring2 ="Jhakri Ring",
        ring2 ="Freke Ring",
        back  ="Izdubar Mantle",
        waist ="Hachirin-no-obi",
        range=empty -- [FIX] explicit alongside ammo="Ghastly Tathlum" above, so nothing built on this set can inherit a lingering Kaja Bow
    }
		
	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
		main = "Mpaca's Staff",
		neck = "Incanter's Torque",
		head = "Atrophy Chapeau +4",
		waist = "Null Belt",
		back = "Null Shawl",
        ammo="Regal Gem" -- [FIX] Kaja Bow retired: swaps in Regal Gem for the Magic Accuracy boost instead; no range override needed since the base set already carries range=empty
	})
		
    sets.midcast['Elemental Magic'].Fodder = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].Proc   = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke           = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder    = set_combine(sets.midcast['Elemental Magic'].Fodder, {})
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {head=empty, body="Twilight Cloak"})

	-- Gear for Magic Burst mode. (combines against the now fully-defined Elemental Magic set)
    sets.MagicBurst = set_combine(sets.midcast['Elemental Magic'], {
        main="Bunzi's Rod", 
        sub="Culminus",
        head = "Atrophy Chapeau +4",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        legs="Lethargy Fuseau +3",
        feet="Bunzi's Sabots",
        neck  ="Mizukage-no-Kubikazari",
        ring2="Freke Ring",
        ring1 ="Locus Ring",

    })
    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        feet="Medium's Sabots",
        body="Vanya Robe",
    })

	sets.midcast.Dia = sets.midcast['Enfeebling Magic']
	sets.midcast.Diaga = sets.midcast['Enfeebling Magic']
	sets.midcast['Dia II'] = sets.midcast['Enfeebling Magic']
	sets.midcast['Dia III'] = sets.midcast['Enfeebling Magic']
	
	sets.midcast.Bio = sets.midcast['Enfeebling Magic']
	sets.midcast['Bio II'] = sets.midcast['Enfeebling Magic']
	sets.midcast['Bio III'] = set_combine(sets.midcast['Enfeebling Magic'], {head="Vitiation Chapeau +4"})

	 sets.midcast['Dark Magic'] = {
        head  ="Jhakri Coronal +2",
        body  ="Jhakri Robe +2",
        legs  ="Jhakri Slops +2",
        hands ="Malignance Gloves",
        feet  ="Jhakri Pigaches +2",
        neck  ="Erra Pendant",
        ear2  ="Alabaster Earring",
        ear1  ="Malignance Earring",
        ring1 ="Crepuscular Ring",
        ring2="Evanescence Ring",
        back  ="Izdubar Mantle",
        waist ="Eschan Stone",
        ammo="Ghastly Tathlum",
        range=empty,
        main="Marin Staff +1",
        sub="Daduchos Grip"-- [FIX] explicit alongside ammo, so nothing built on this set can inherit a lingering Kaja Bow
    }

    sets.midcast.Drain          = set_combine(sets.midcast['Dark Magic'], {neck="Erra Pendant"})
    sets.midcast.Aspir          = set_combine(sets.midcast.Drain, {waist="Fucho-no-obi", feet="Merlinic Crackows"})
    sets.midcast.Stun           = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {})


	-- Sets for special buff conditions on spells.
		
  sets.buff.Saboteur      = {hands="Lethargy Gantherots +3"}
    sets.buff.Sublimation   = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    sets.HPDown             = {}
    sets.HPCure             = {}
    sets.buff.Doom          = {}
	-- Sets to return to when not performing an action.
	
	-- Resting sets
	sets.resting = {main="Chatoyant Staff",sub="Oneiros Grip",}
	-- Idle sets
	sets.idle = { 
        main="Daybreak",
        sub="Sacro Bulwark",
        ammo  ="Crepuscular Pebble",
        head  ="Vitiation Chapeau +4",
        body  ="Lethargy Sayon +3",
        legs  ="Carmine Cuisses +1",
        hands ="Malignance Gloves",
        feet  ="Malignance Boots",
        neck  ="Null Loop",
        ear1  ="Moonshade Earring",
        ear2  ="Alabaster Earring",
        ring1="Ayanmo Ring",
        ring2 ="Murky Ring",
        back  ="Archon Cape",
        waist ="Null Belt",
        range=empty}
		
	sets.idle.PDT     = set_combine(sets.idle, 
	{        main="Emissary",
        sub="Sacro Bulwark"})
    sets.idle.MDT     = set_combine(sets.idle, {})
    sets.idle.Weak    = set_combine(sets.idle, {})
    sets.idle.DTHippo = set_combine(sets.idle, {})
	
	sets.idle.DTHippo = set_combine(sets.idle.PDT, {
	back="Archon Cape",
	legs="Carmine Cuisses +1",
	--feet="Hippo. Socks +1"
	})
	
	-- Defense sets
	sets.defense.PDT = {}

	sets.defense.NukeLock = sets.midcast['Elemental Magic']
		
	sets.defense.MDT =  set_combine(sets.idle.MDT,{})
		
    sets.defense.MEVA = set_combine(sets.defense.MDT,{})
		
	sets.Kiting = {legs="Carmine Cuisses +1", main="Daybreak", sub="Sacro Bulwark", ammo="Crepuscular Pebble"}
	sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {main= "Mpaca's Staff", sub="Oneiros Grip"}
 
	sets.DayIdle = {}
	sets.NightIdle = {}
	
	-- Weapons sets
	sets.weapons.Naegling = {main="Naegling",sub="Archduke's Shield", range=empty, ammo="Crepuscular Pebble"} -- Default (non-NIN sub) Naegling loadout; range explicitly cleared so a lingering Kaja Bow can't clash with ammo
	sets.weapons.DualWeapons = {main="Naegling", sub="Demersal Degen +1", range=empty, ammo="Crepuscular Pebble"} -- Ctrl+W cycle target for NIN-sub dual wield; ammo/range locked via RDM.lua's job_customize_idle_set/melee_set
	sets.weapons.EnspellMelee = {main="Naegling", sub="Culminus", range=empty, ammo="Crepuscular Pebble"} -- Non-NIN-sub melee: rides enspell procs via Culminus instead of using a shield; Kaja Bow locked same as DualWeapons

	-- Elemental bonus overlay sets. 
	sets.element = {
		Fire = {},
		Ice = {},
		Wind = {},
		Earth = {},
		Lightning = {},
		Water = {},
		Light = {},
		Dark = {},
	}
	sets.element.enspell = {
		Fire = {},
		Ice = {},
		Wind = {},
		Earth = {},
		Lightning = {},
		Water = {},
		Light = {},
		Dark = {},
	}
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

	--Situational sets: Gear that is equipped on certain targets
	sets.Self_Healing = {ring1="Kunaji Ring" }
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

sets.engaged = {  
        neck  ="Lissome Necklace",
        ear1  ="Sherida Earring",
        ear2  ="Cessance Earring",
        body  ="Malignance Tabard",
        hands ="Malignance Gloves",
        ring1 ="Mars's Ring",
        ring2 ="Rajas Ring",
        back="Sucellos's Cape",
        waist ="Sailfi Belt +1",
        legs  ="Malignance Tights",
        feet  ="Malignance Boots",
        ammo="Crepuscular Pebble",
        range=empty} 
        

sets.engaged.EnspellMelee = sets.engaged

sets.engaged.Acc = set_combine(sets.engaged, {ammo="Ginsen", waist="Null Loop"})
sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {back="Null Shawl", neck="Null Loop",})
sets.engaged.DT = set_combine(sets.engaged, {})
sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})
sets.engaged.FullAcc.DT = set_combine(sets.engaged.FullAcc, {})
sets.engaged.DW = set_combine(sets.engaged, {})
sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {})
sets.engaged.DW.FullAcc = set_combine(sets.engaged.FullAcc, {})
sets.engaged.DW.DT = set_combine(sets.engaged, {})
sets.engaged.DW.Acc.DT = set_combine(sets.engaged.Acc, {})
sets.engaged.DW.FullAcc.DT = set_combine(sets.engaged.FullAcc, {})
end