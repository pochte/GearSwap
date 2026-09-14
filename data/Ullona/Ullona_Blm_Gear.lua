-- =============================================================================
-- Ullona_Blm_Gear.lua
-- =============================================================================

function user_job_setup()
    -- Options: Override default values
    state.CastingMode:options('Normal','Resistant','Fodder','Proc','OccultAcumen','MB','MB Resistant')
    state.OffenseMode:options('Normal')
    state.IdleMode:options('Normal','PDT','DTHippo')
    state.Weapons:options('None','BurstWeapons','Khatvanga','Lathi')

    -- (obi/back swap variables removed 2026-08-10: waist/back are now hardwired
    -- directly into sets.engaged and sets.midcast['Elemental Magic'] below)

    gear.nuke_jse_back = {
        name="Taranus's Cape",
        augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10',}
    }

    -- =========================================================================
    -- Macro Book
    -- =========================================================================
    set_macro_page(1, 2) -- Page 1, Macro Book 2

    -- =========================================================================
    -- Additional local binds — every keybind noted below for quick reference.
    -- Modifier key: ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    -- =========================================================================
    send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen')  -- Ctrl + Q : Equip Khatvanga + set OccultAcumen casting mode
    send_command('bind !q gs c weapons Default;gs c reset CastingMode;gs c reset DeathMode')  -- Alt + Q : Reset weapons + CastingMode/DeathMode
    send_command('bind !r gs c set DeathMode Single;gs c set CastingMode MB')  -- Alt + R : One-shot Death + MB casting mode
    send_command('bind !\\\\ input /ja "Manawell" <me>')          -- Alt + \ : Manawell
    send_command('bind @f9 gs c cycle DeathMode')                 -- Win + F9 : Cycle DeathMode
    send_command('bind @^` input /ja "Parsimony" <me>')           -- Win + Ctrl + ` : Parsimony
    send_command('bind !pause gs c toggle AutoSubMode')           -- Alt + Pause : Toggle AutoSubMode
    send_command('bind ^backspace input /ma "Stun" <t>')          -- Ctrl + Backspace : Stun
    send_command('bind !backspace input /ja "Enmity Douse" <t>')  -- Alt + Backspace : Enmity Douse
    send_command('bind @backspace input /ja "Alacrity" <me>')     -- Win + Backspace : Alacrity
    send_command('bind != input /ja "Light Arts" <me>')           -- Alt + = : Light Arts
    send_command('bind @= input /ja "Addendum: White" <me>')      -- Win + = : Addendum: White
    send_command('bind ^delete input /ja "Dark Arts" <me>')       -- Ctrl + Delete : Dark Arts
    send_command('bind !delete input /ja "Addendum: Black" <me>') -- Alt + Delete : Addendum: Black
    send_command('bind @delete input /ja "Manifestation" <me>')   -- Win + Delete : Manifestation
    send_command('bind @f10 gs c smartna')                        -- Win + F10 : SmartNa
    send_command('bind @f8 gs c toggle AutoNukeMode')             -- Win + F8 : Toggle AutoNukeMode
end

-- Applies the lockstyle after the equipment model has loaded.
function user_job_lockstyle()
    send_command('input /lockstyleset 2')
end

function init_gear_sets()
    -- [FIX] Removed a stray job_precast(spell, spellMap, eventArgs) stub that was pasted here
    -- (just calling check_ecphoria_for_ja(spell)). Same last-definition-wins bug already fixed
    -- in Ullona_Rdm_Gear.lua, Ullona_Thf_Gear.lua, and Ullona_Whm_Gear.lua -- since gear files
    -- load after job files, this stub was silently REPLACING BLM.lua's real job_precast with a
    -- function that did nothing else. BLM.lua's actual job_precast already calls
    -- check_ecphoria_for_ja(spell) itself (line 84), so nothing of value is lost by removing it.
    -- =========================================================================
    -- Weapon swap sets
    -- =========================================================================
    sets.weapons                 = sets.weapons or {}
    sets.weapons.BurstWeapons    = sets.weapons.Default
    sets.weapons.Default         = sets.weapons.Default or {main="Marin Staff +1"}

    -- =========================================================================
    -- Buff overlay sets
    -- =========================================================================
    sets.buff                    = sets.buff or {}
    sets.buff.Sublimation        = {waist="Embla Sash"}
    sets.buff.DTSublimation      = {waist="Embla Sash"}

    -- =========================================================================
    -- Precast: Job Abilities
    -- =========================================================================
sets.TreasureHunter = {ammo="Perfect Lucky Egg", waist="Chaac Belt"}
    -- Mana Wall: equip back+feet for footwear lock benefit
    sets.precast.JA['Mana Wall'] = {back="Taranus's Cape", feet="Wicce Sabots +2"}

    -- Manafont: body gives the most benefit
    sets.precast.JA.Manafont     = {body="Archmage's Coat +2"}

    -- Convert: empty — equip nothing special; keep whatever is on
    sets.precast.JA.Convert      = {}

    -- =========================================================================
    -- Precast: Fast Cast
    -- =========================================================================
    sets.precast.FC = {
        main  = "Mpaca's Staff",
        sub="Willpower Grip",
        head  = "Nahtirah Hat",
        body  = "Agwu's Robe",
        hands = "Mallquis Cuffs +2",
        legs="Querkening Brais",
        feet  = "Regal Pumps",
        neck = "Voltsurge Torque",
        ear2="Malignance Earring",   
        ear1  = "Alabaster Earring",
                ring2 ="Kishar Ring",
		ring1="Naji's Loop",
        waist = "Cornelia's Belt",
    }

    -- Enhancing: swap in Magnetic Earring for Conserve MP
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        ear1="Magnetic Earring",
        waist="Embla Sash"
    })

    -- Stoneskin: Siegel Sash + Shedir legs improve potency
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
        waist = "Siegel Sash",
        legs  = "Querkening Brais",
        head="Umuthi Hat"
    })

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        head  = "Wicce Petasos +2",
        neck  = "Baetyl Pendant",
        body  = "Wicce Coat +2",
        feet  = "Spaekona's Sabots +2",
        ring2  = "Mallquis Ring",
    })

    -- Cure precast: healing-focused FC set
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main  = "Vadose Rod",
        sub=none,
        ammo="Psilomene",
        head  = "Vanya Hood",
        body  ="Vrikodara Jupon",
        hands = "Bokwus Gloves",
        legs="Gyve Trousers",
        feet  = "Vanya Clogs",  -- kept from base FC
        neck = "Voltsurge Torque",
        ear1="Magnetic Earring",
        ear2  = "Mendicant's Earring", ---
        ring2 = "Janniston Ring",
        ring1 = "Lebeche Ring",
        back="Pahtli Cape",
        waist = "Acerbic Sash +1",
    })
    sets.precast.FC.Curaga = sets.precast.FC.Cure

    -- Impact: GearSwap's built-in `empty` keyword clears the head slot
    sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty, body="Twilight Cloak"})

    -- Death: use a dedicated staff for the Grioavolr bonus
    sets.precast.FC.Death = set_combine(sets.precast.FC, {main=gear.grioavolr_nuke_staff})

    -- =========================================================================
    -- Precast: Weapon Skills (default)
    -- =========================================================================
    sets.precast.WS = {
        neck  = "Fotia Gorget",
        ear1  = "Cessance Earring",
        ear2  = "Odnowa Earring +1",
        	ring1="Cornelia's Ring",  
        ring2 = "Mars's Ring",
        waist = "Fotia Belt",
        legs="Perdition slops"
    }

    -- =========================================================================
    -- Midcast: Fast Recast fallback (mirrors precast.FC)
    -- =========================================================================
    sets.midcast.FastRecast = sets.precast.FC

    -- =========================================================================
    -- Midcast: Cure / Curaga / Cursna / Status Removal
    -- =========================================================================
    sets.midcast.Cure = {
        main  = "Bunzi Rod",
        sub="Sors Sheild",
        head  = "Vanya Hood",
        body  ="Vrikodara Jupon",
        hands = "Bokwus Gloves",
        feet  = "Vanya Clogs",
        neck  = "Nodens Gorget",
        ear2="Glorious Earring",
        ear1  = "Mendicant's Earring",
        ring2 ="Janniston Ring",
        ring1 ="Lebeche Ring",
        legs="Gyve Trousers",
    }

    -- Light weather: swap in a weather staff + day obi
    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {
        main="Chatoyant Staff",
        sub="Kaja Grip",

    })
    sets.midcast.LightDayCure  = sets.midcast.LightWeatherCure
    sets.midcast.Curaga        = sets.midcast.Cure
    sets.midcast.Cursna        = set_combine(sets.midcast.Cure, {})
    sets.midcast.StatusRemoval = sets.midcast.FastRecast
    sets.precast.Aquaveil    = set_combine(sets.precast.FC['Enhancing Magic'], {main="Vadose Rod", sub="Culminus",})

    -- =========================================================================
    -- Midcast: Enhancing / Stoneskin / Bar-spells
    -- =========================================================================
    sets.midcast['Enhancing Magic'] = {
        head  = "Mallquis Chapeau +2",
        body  = "Mallquis Saio +2",
        hands = "Bokwus Gloves",
        legs  = "Shedir Seraweels",
        feet  = "Medium's Sabots",
        ear1  = "Magnetic Earring",
        ear2  = "Andoaa Earring",
        ring2 = "Vertigo Ring",
        waist = "Siegel Sash",
    }

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga",
    })

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        waist = "Siegel Sash",
        legs  = "Shedir Seraweels",
        feet  = "Medium's Sabots",
        head="Umuthi Hat"
    })

    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {
        legs="Shedir Seraweels",
    })

    -- =========================================================================
    -- Midcast: Enfeebling Magic
    -- =========================================================================
    sets.midcast['Enfeebling Magic'] = {

        sub="Daduchos Grip",
        head   = "Mallquis Chapeau +2",
        body   = "Vanya Robe",
        hands  = "Wicce Gloves +2",
        legs   = "Wicce Chausses +2",
        feet   = "Uk'uxkaj Boots",
        neck   = "Sorcerer's Stole +1",
        ring1  = "Mallquis Ring",
        ring2 ="Kishar Ring",
        ear2="Malignance Earring",   
        ear1="Gifted Earring",
        back   = "Taranus's Cape",
        waist=" Obstinate Sash",
        ranged = "Aureole",
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        main  = "Mpaca's Staff",
        body  = "Spaekona's Coat +2",
        ear1="Gwati Earring",
        waist="Null Belt"
        
    })

    -- Elemental enfeebles (INT- or MND-based)
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {
        back = "Taranus's Cape",
        body = "Spaekona's Coat +2",
        legs = "Archmage's Tonban +3",
        feet = "Archmage's Sabots +2"
    })
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    -- INT/MND enfeeble aliases point to ElementalEnfeeble
    -- (using set_combine avoids aliasing the same table, preventing .Resistant cross-contamination)
    sets.midcast.IntEnfeebles           = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})
    sets.midcast.MndEnfeebles           = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})

    -- =========================================================================
    -- Midcast: Dark Magic / Drain / Aspir
    -- =========================================================================
    sets.midcast['Dark Magic'] = {

        sub="Daduchos Grip",
        head   = "Mallquis Chapeau +2",
        body  = "Wicce Coat +2",
        hands  = "Archmage's Gloves +2",
        legs   = "Spaekona's Tonban +2",
        feet   = "Wicce Sabots +2",
        neck   = "Erra Pendant",
        ear2   ="Malignance Earring",   
        ear1   = "Wicce Earring",
        ring1  = "Mallquis Ring",
        ring1="Evanescence Ring",
        back   = "Taranus's Cape",
        ranged = "Aureole"
    }

    sets.midcast.Drain      = set_combine(sets.midcast['Dark Magic'], {neck="Erra Pendant", waist="Fucho-no-obi", feet="Agwu's Pigaches"
})
    sets.midcast.Aspir      = set_combine(sets.midcast.Drain, {})
    sets.midcast.Aspir.Death = sets.midcast['Dark Magic']

    -- Impact midcast base (GearSwap `empty` clears head slot)
    sets.midcast.Impact = set_combine(sets.precast.FC.Impact or {}, {})

    -- =========================================================================
    -- Midcast: Elemental Magic (nuke sets)
    -- =========================================================================
    sets.midcast['Elemental Magic'] = {
        main   = "Marin Staff +1",
        sub="Willpower Grip",
        ammo="Ghastly Tathlum",
        head   = "Wicce Petasos +2",
        body  = "Wicce Coat +2",
        hands  = "Wicce Gloves +2",
        legs   = "Wicce Chausses +2",
        feet  = "Wicce Sabots +2",
        neck   = "Baetyl Pendant",
        ear2   = "Wicce Earring",
        ring1  = "Freke Ring",
        ring2  = "Jhakri Ring",
        back   = "Taranus's Cape",
        waist  = "Hachirin-no-Obi",
    }

    -- Resistant: swap in accuracy pieces to land on tough targets
    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
        main   = "Marin Staff +1",
        sub="Daduchos Grip",
        neck   = "Incanter's Torque",
        feet   = "Medium's Sabots",
        ranged = "Aureole",
        hands="Spaekona's Gloves +2"
    })

    -- HighTierNuke: proper set_combine so .Resistant doesn't corrupt base set
    sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})

    -- Proc: lowest accuracy requirement, focus on landing the proc
    sets.midcast['Elemental Magic'].Proc = set_combine(sets.midcast['Elemental Magic'], {
        main   = "Marin Staff +1",
        ranged = "Aureole"
    })

    -- OccultAcumen: converts elemental damage to TP; base nuke set is fine
    sets.midcast['Elemental Magic'].OccultAcumen = set_combine(sets.midcast['Elemental Magic'], {})

    -- Impact OccultAcumen variant: clears head via GearSwap `empty`, uses Twilight Cloak
    sets.midcast.Impact.OccultAcumen = set_combine(
        sets.midcast['Elemental Magic'].OccultAcumen or {},
        {head=empty, body="Twilight Cloak"}
    )

    -- =========================================================================
    -- Recovery / Burst overlay sets
    -- =========================================================================

    -- RecoverMP: Spaekona body converts elemental damage dealt into MP recovered
    sets.RecoverMP = {
        body="Spaekona's Coat +2",
    }

    -- MagicBurst: overlaid on nukes when CastingMode contains 'MB' (was MagicBurstMode ~= 'Off', now retired)
    sets.MagicBurst = set_combine(sets.midcast['Elemental Magic'], {
        head  = "Archmage's Petasos +3",
        neck  = "Sorcerer's Stole +1",
        body="Agwu's Robe",
        hands = "Archmage's Gloves +2",
        legs="Archmage's Tonban +3",
        ring2="Freke Ring",
        ring1="Locus Ring",
        feet="Spaekona's Sabots +2",
        back="Taranus's cape"
    })

    -- ResistantMagicBurst: used when CastingMode contains 'Resistant' and bursting
  sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})

    -- =========================================================================
    -- Idle sets — MUST be defined before sets.resting
    -- =========================================================================
    sets.idle = {
        main  = "Mpaca's Staff",
        sub="Kaja Grip",
        ammo  = "Crepuscular Pebble",
        head  = "Wicce Petasos +2",
        body  = "Jhakri Robe +2",
        hands = "SV Gauntlets +1",
        legs  = "Assiduity Pants +1",
        feet  = "Herald's Gaiters",
        neck  = "Null Loop",  
        ear1  = "Alabaster Earring",
        ear2  = "Moonshade Earring",
        ring1 = "Archon Ring",
        ring2 = "Murky Ring",
        back  = "Archon Cape",
        waist="Fucho-no-Obi"
    }

    -- Idle variants (populate slots as needed)
    sets.idle.PDT     = set_combine(sets.idle, {})
    sets.idle.MDT     = set_combine(sets.idle, {})
    sets.idle.DTHippo = set_combine(sets.idle, {})
    sets.idle.Weak    = set_combine(sets.idle, {})

    sets.idle.Death = set_combine(sets.idle, {main=gear.grioavolr_nuke_staff})

    -- Resting: defined AFTER sets.idle so set_combine has a valid base
    sets.resting = set_combine(sets.idle, {
        main = "Chatoyant Staff",
        body = "Jhakri Robe +2",
        legs = "Assiduity Pants +1",
    })

    -- =========================================================================
    -- Defense sets
    -- =========================================================================
    sets.defense.PDT  = sets.idle.PDT
    sets.defense.MDT  = sets.idle.MDT
    sets.defense.MEVA = sets.idle.MDT

    -- =========================================================================
    -- Utility / situational sets
    -- =========================================================================
    sets.Kiting          = {feet="Herald's Gaiters", main="Malignance Pole", sub="Kaja Grip", waist="Platinum Moogle Belt"}
    sets.latent_refresh  = {waist="Fucho-no-obi"}
    sets.latent_refresh_grip = {sub="Oneiros Grip"}
    sets.TPEat           = {}
    sets.DayIdle         = {}
    sets.NightIdle       = {}

    sets.HPDown          = {}
    sets.HPCure          = {}
	--Situational sets: Gear that is equipped on certain targets
	sets.Self_Healing = {ring1="Kunaji Ring" }
	sets.Cure_Received = {}
	sets.Self_Refresh = {}

    sets.buff.Doom       = set_combine(sets.buff.Doom or {}, {})
    sets.buff['Mana Wall'] = {back=gear.nuke_jse_back, feet="Wicce Sabots +2"}

    -- =========================================================================
    -- Engaged (melee) sets
    -- =========================================================================
    sets.engaged = {
        main  = "Malignance Pole",
        sub="Daduchos Grip",
        head  = "Jhakri Coronal +2",
        body  = "SV Separates +1",
        hands = "SV Gauntlets +1",
        legs="Perdition slops",
        feet  = "SV Gaiters +1",
        neck  = "Peacock Amulet",
        ring1 = "Mars's Ring",
        back  = "Null Shawl",  
        waist = "Eschan Stone",
    }

    sets.engaged.DT = sets.engaged

end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions
-------------------------------------------------------------------------------------------------------------------

