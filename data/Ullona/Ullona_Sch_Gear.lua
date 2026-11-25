-- CHANGELOG
-- 2026-11-19: Replaced Altruistic Cape (now in storage) with Null Shawl in the Enfeebling set.
-- 2026-11-19: Note: SCH is a WIP job. Argute +2 is the WIP Pedagogy gear; Arbatel pieces are in a Storage Slip.
-- 2026-11-19: Elite Royal Collar (San d'Oria citizen: Regen+3, DT-5%) now the neck in sets.idle / sets.idle.PDT (2 set(s)); replaces Null Loop there (Null Loop kept in all other sets).
-- 2026-11-19: Replaced Platinum Moogle Belt with Null Belt (Regen+3, Eva/MEva/Acc/MAcc+30) in 2 idle set(s); the belt caused too much blood aggro. Defense/FC/other sets unchanged.
-- 2026-11-19: Added Platinum Moogle Belt to sets.Kiting (moved out of idle).
-- 2026-11-19: Pedagogy pieces set to the base reforged item (Pedagogy Gown/Pants, Peda. Loafers); +1 deferred as too expensive.
-- 2026-11-19: Academic's: Gown is owned (base); Pants and Mortarboard commented out as "get:" until owned.
-- 2026-11-19: Arbatel +1 set confirmed owned (was in a Storage Slip); no code change.
-- 2026-11-19: Uncommented the Nyame body/hands/legs/feet (all owned) in sets.idle and sets.defense.PDT; swapped SV Separates/Gauntlets/Loincloth/Gaiters for Nyame in idle.PDT and defense PDT/MDT (12 replacements). Old lines kept as "-- previous" where a commented Nyame line existed.

-- Ullona_Sch_Gear.lua
-- SCH gear setup. One item per line.
-- i109 set for now: Pedagogy (relic) reforged base, Academic's (AF) reforged base (only the Gown is owned), Arbatel (Empy) +1 (owned, in Storage Slip).
-- The +1 upgrades for Pedagogy/Academic's are deferred (too expensive for a rarely played job). Each line notes the +3 BIS target.
-- Argute +2 is the unupgraded relic; once reforged it becomes Pedagogy.
-- Relic (Pedagogy) = +2, still needs Dynamis for +3.
-- Items marked "-- get:" are not owned yet.

function user_job_setup()
    state.OffenseMode:options('Normal')
    state.CastingMode:options('Normal', 'Resistant', 'Proc', 'OccultAcumen', '9k')
    state.IdleMode:options('Normal', 'PDT')
    state.HybridMode:options('Normal', 'PDT')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')
    state.Weapons:options('None', 'Default', 'Mpaca', 'Daybreak')

    -- Nuke cape. Izdubar Mantle until the JSE cape exists.
    gear.nuke_jse_back = "Izdubar Mantle"
    -- get: Lugh's Cape {'INT+20','Mag. Acc+20 /Mag. Dmg.+20','"Mag.Atk.Bns."+10'}

    gear.obi_cure_back = "Tempered Cape +1"
    gear.obi_cure_waist = "Hachirin-no-Obi"

    gear.obi_low_nuke_waist = "Hachirin-no-Obi"
    gear.obi_high_nuke_waist = "Hachirin-no-Obi"

    -- Macro Book 8 (page 1)
    set_macro_page(1, 8)

    -- Additional local binds
    -- ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    send_command('bind ^` gs c cycle ElementalMode')
    send_command('bind !` gs c scholar power')
    send_command('bind @` gs c cycle MagicBurstMode')
    send_command('bind ^q gs c set CastingMode OccultAcumen')
    send_command('bind !q gs c weapons default;gs c reset CastingMode')
    send_command('bind @f10 gs c cycle RecoverMode')
    send_command('bind @f8 gs c toggle AutoNukeMode')
    send_command('bind !pause gs c toggle AutoSubMode') -- Automatically uses sublimation and Myrkr.
    send_command('bind @^` input /ja "Parsimony" <me>')
    send_command('bind ^backspace input /ma "Stun" <t>')
    send_command('bind !backspace gs c scholar speed')
    send_command('bind @backspace gs c scholar aoe')
    send_command('bind ^= input /ja "Dark Arts" <me>')
    send_command('bind != input /ja "Light Arts" <me>')
    send_command('bind ^\\\\ input /ma "Protect V" <t>')
    send_command('bind @\\\\ input /ma "Shell V" <t>')
    send_command('bind !\\\\ input /ma "Reraise III" <me>')
end

-- Clear every bind this file sets so they don't linger after a job change/reload.
function user_job_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind ^q')
    send_command('unbind !q')
    send_command('unbind @f10')
    send_command('unbind @f8')
    send_command('unbind !pause')
    send_command('unbind @^`')
    send_command('unbind ^backspace')
    send_command('unbind !backspace')
    send_command('unbind @backspace')
    send_command('unbind ^=')
    send_command('unbind !=')
    send_command('unbind ^\\\\')
    send_command('unbind @\\\\')
    send_command('unbind !\\\\')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 8')
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    -- Precast sets to enhance JAs
    sets.precast.JA['Tabula Rasa'] = {
        legs="Pedagogy Pants", -- Relic reforged (BIS: Peda. Pants +3)
    }
    sets.precast.JA['Enlightenment'] = {
        body="Pedagogy Gown", -- Relic reforged (BIS: Peda. Gown +3)
    }

    -- Fast cast: full Agwu's is +30% FC on its own.
    sets.precast.FC = {
        main="Mpaca's Staff",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        ammo="Crepuscular Pebble",
        head="Agwu's Cap",
        neck="Voltsurge Torque",
        ear1="Malignance Earring",
        ear2="Loquacious Earring",
        body="Agwu's Robe",
        hands="Agwu's Gages",
        ring1="Kishar Ring",
        ring2="Naji's Loop",
        back="Izdubar Mantle",
        waist="Embla Sash",
        legs="Agwu's Slops",
        feet="Peda. Loafers", -- Relic reforged (FC+6% at +1) (BIS: Peda. Loafers +3)
    }

    sets.precast.FC.Arts = {}

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        waist="Siegel Sash",
    })

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        neck="Baetyl Pendant",
    })

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main="Vadose Rod",
        sub="Sors Shield",
        head="Vanya Hood",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        legs="Gyve Trousers",
        feet="Vanya Clogs",
        ear2="Mendicant's Earring",
        ring2="Janniston Ring",
        back="Pahtli Cape",
        waist="Acerbic Sash +1",
    })

    sets.precast.FC.Curaga = sets.precast.FC.Cure

    sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], {
        head=empty,
        body="Twilight Cloak",
    })

    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Culminus",
    })

    -- Weaponskill: Myrkr (MP)
    sets.precast.WS['Myrkr'] = {
        ammo="Ghastly Tathlum",
        head="Nahtirah Hat",
        neck="Sanctity Necklace",
        ear1="Gifted Earring",
        ear2="Malignance Earring",
        body="Agwu's Robe",
        hands="Arbatel Bracers +1", -- Empy +1 (BIS: Arbatel Bracers +3)
        ring1="Janniston Ring",
        ring2="Lebeche Ring",
        back="Izdubar Mantle",
        waist="Jaq'ij Sash",
        legs="Agwu's Slops",
        feet="Agwu's Pigaches",
    }

    -- Midcast Sets
    sets.TreasureHunter = {
        ammo="Perfect Lucky Egg",
        waist="Chaac Belt",
    }

    -- Gear that converts elemental damage done to recover MP.
    sets.RecoverMP = {
        -- body="Seidr Cotehardie", -- get: not owned
    }

    -- Gear for Magic Burst mode.
    sets.MagicBurst = {
        main="Bunzi's Rod",
        sub="Culminus",
        neck="Mizukage-no-Kubikazari",
        ring1="Locus Ring",
        ring2="Freke Ring",
    }

    -- Gear for specific elemental nukes.
    sets.element.Dark = {
        ring2="Archon Ring",
    }

    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})

    sets.midcast.Cure = {
        main="Bunzi's Rod", -- Cure potency +30%
        sub="Sors Shield",
        head="Vanya Hood",
        neck="Nodens Gorget",
        ear1="Mendicant's Earring",
        ear2="Gifted Earring",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        ring1="Janniston Ring",
        ring2="Lebeche Ring",
        back="Tempered Cape +1",
        waist="Acerbic Sash +1",
        legs="Gyve Trousers",
        feet="Vanya Clogs",
    }

    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {
        main="Chatoyant Staff",
        sub="Clemency Grip",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
    })

    sets.midcast.LightDayCure = set_combine(sets.midcast.Cure, {
        main="Daybreak",
        sub="Sors Shield",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
    })

    sets.midcast.Curaga = sets.midcast.Cure

    sets.Self_Healing = {
        ring1="Kunaji Ring",
        ring2="Asklepian Ring",
    }
    sets.Cure_Received = {
        ring1="Kunaji Ring",
        ring2="Asklepian Ring",
    }
    sets.Self_Refresh = {
        feet="Inspirited Boots",
    }

    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        neck="Nodens Gorget",
        hands="Bokwus Gloves",
        feet="Vanya Clogs",
    })

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        main="Mpaca's Staff",
        sub="Clemency Grip",
    })

    sets.midcast['Enhancing Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Umuthi Hat",
        neck="Incanter's Torque",
        ear1="Andoaa Earring",
        ear2="Gifted Earring",
        body="Pedagogy Gown", -- Relic reforged (Enhancing skill +15 at +1) (BIS: Peda. Gown +3)
        hands="Bokwus Gloves",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Izdubar Mantle",
        waist="Embla Sash",
        legs="Shedir Seraweels",
        feet="Regal Pumps",
    }
 
-- PROTECT / SHELL
 

sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {
    ring1="Sheltered Ring",
})

sets.midcast.Shell = sets.midcast.Protect

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga",
        sub="Ammurapi Shield",
        head="Arbatel Bonnet +1", -- Empy +1: Regen potency +15% (BIS: Arbatel Bonnet +3)
    })

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        neck="Nodens Gorget",
        waist="Siegel Sash",
        legs="Shedir Seraweels",
    })

    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Vadose Rod",
        sub="Culminus",
        legs="Shedir Seraweels",
    })

    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {
        legs="Shedir Seraweels",
    })

    sets.midcast.Storm = set_combine(sets.midcast['Enhancing Magic'], {
        feet="Peda. Loafers", -- Relic reforged (BIS: Peda. Loafers +3)
    })

    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Protectra = sets.midcast.Protect

    sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast.Shellra = sets.midcast.Shell

    -- Custom spell classes
    sets.midcast['Enfeebling Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Ghastly Tathlum",
        head="Agwu's Cap",
        neck="Erra Pendant",
        ear1="Crepuscular Earring",
        ear2="Malignance Earring",
        body="Vanya Robe",
        hands="Agwu's Gages",
        ring1="Kishar Ring",
        ring2="Vertigo Ring",
        back="Null Shawl",
        waist="Obstinate Sash",
        legs="Arbatel Pants +1", -- Empy +1: Enfeebling skill +18, Grimoire MAcc+26 (BIS: Arbatel Pants +3)
        feet="Skaoi Boots",
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Mpaca's Staff",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        back="Null Shawl",
        waist="Null Belt",
        feet="Medium's Sabots",
    })

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Diaga = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)

    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {
        feet="Medium's Sabots",
    })

    sets.midcast['Dark Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Ghastly Tathlum",
        head="Agwu's Cap",
        neck="Erra Pendant",
        ear1="Crepuscular Earring",
        ear2="Malignance Earring",
        body="Agwu's Robe",
        hands="Arbatel Bracers +1", -- Empy +1 (BIS: Arbatel Bracers +3)
        ring1="Evanescence Ring",
        ring2="Archon Ring",
        back="Izdubar Mantle",
        waist="Fucho-no-Obi",
        legs="Pedagogy Pants", -- Relic reforged (Dark skill +15 at +1) (BIS: Peda. Pants +3)
        feet="Agwu's Pigaches",
    }

    sets.midcast.Kaustra = set_combine(sets.midcast['Dark Magic'], {
        head="Agwu's Cap",
        neck="Baetyl Pendant",
        ear2="Arbatel Earring +1",
        ring1="Freke Ring",
        waist="Hachirin-no-Obi",
        legs="Agwu's Slops",
    })

    sets.midcast.Kaustra.Resistant = set_combine(sets.midcast.Kaustra, {
        main="Mpaca's Staff",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        neck="Erra Pendant",
        waist="Null Belt",
    })

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Drain.Resistant = set_combine(sets.midcast['Dark Magic'], {
        waist="Null Belt",
    })

    sets.midcast.Aspir = sets.midcast.Drain
    sets.midcast.Aspir.Resistant = sets.midcast.Drain.Resistant

    sets.midcast.Stun = set_combine(sets.precast.FC, {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    -- Elemental Magic sets are default for handling low-tier nukes.
    sets.midcast['Elemental Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        ammo="Ghastly Tathlum",
        head="Agwu's Cap",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Arbatel Earring +1", -- Empy right-ear piece
        body="Agwu's Robe",
        hands="Agwu's Gages",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        back="Izdubar Mantle", -- get: Lugh's Cape (JSE)
        waist="Hachirin-no-Obi",
        legs="Agwu's Slops",
        feet="Agwu's Pigaches",
    }

    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
        main="Mpaca's Staff",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        neck="Sanctity Necklace",
        ring1="Vertigo Ring",
        back="Null Shawl",
        waist="Null Belt",
    })

    sets.midcast['Elemental Magic'].Fodder = set_combine(sets.midcast['Elemental Magic'], {})

    sets.midcast['Elemental Magic']['9k'] = set_combine(sets.midcast['Elemental Magic'], {})

    sets.midcast['Elemental Magic'].Proc = set_combine(sets.precast.FC, {
        main=empty,
        sub=empty,
    })

    sets.midcast['Elemental Magic'].OccultAcumen = {
        main="Mpaca's Staff",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        ammo="Crepuscular Pebble",
        head="Mallquis Chapeau +2",
        neck="Null Loop",
        ear1="Cessance Earring",
        ear2="Crepuscular Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Rajas Ring",
        ring2="Petrov Ring",
        back="Izdubar Mantle",
        waist="Eschan Stone",
        legs="Perdition Slops",
        feet="Jhakri Pigaches +2",
    }

    -- Custom refinements for certain nuke tiers
    sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {
        ear1="Malignance Earring",
        ring1="Freke Ring",
        ring2="Jhakri Ring",
    })
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = set_combine(sets.midcast['Elemental Magic'].Fodder, {})

    sets.midcast.Helix = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast.Helix.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})
    sets.midcast.Helix.Proc = set_combine(sets.precast.FC, {
        main=empty,
        sub=empty,
    })

    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {
        head=empty,
        body="Twilight Cloak",
    })
    sets.midcast.Impact.OccultAcumen = set_combine(sets.midcast['Elemental Magic'].OccultAcumen, {
        head=empty,
        body="Twilight Cloak",
    })

    -- Sets to return to when not performing an action.

    -- Resting sets
    sets.resting = {
        main="Chatoyant Staff",
        sub="Oneiros Grip",
        body="Jhakri Robe +2",
        legs="Assiduity Pants +1",
    }

    -- Idle sets
    sets.idle = {
        main="Mpaca's Staff",
        sub="Kaja Grip",
        ammo="Crepuscular Pebble",
        head="Nyame Helm", -- Path B
        neck="Elite Royal Collar",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Nyame Mail", -- Path B
        -- body="Jhakri Robe +2", -- previous
        hands="Nyame Gauntlets", -- Path B
        -- hands="SV Gauntlets +1", -- previous
        ring1="Archon Ring",
        ring2="Murky Ring",
        back="Archon Cape",
        waist="Fucho-no-Obi",
        legs="Nyame Flanchard", -- Path B
        -- legs="Assiduity Pants +1", -- previous
        feet="Nyame Sollerets", -- Path B
        -- feet="Herald's Gaiters", -- previous
    }

    sets.idle.PDT = {
        main="Malignance Pole",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        ammo="Crepuscular Pebble",
        head="Nyame Helm", -- Path B
        neck="Elite Royal Collar",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        waist="Null Belt",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
    }

    sets.idle.Hippo = set_combine(sets.idle.PDT, {}) -- get: Hippo. Socks +1 (feet)

    sets.idle.Weak = set_combine(sets.idle, {})

    -- Defense sets
    sets.defense.PDT = {
        main="Malignance Pole",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        ammo="Crepuscular Pebble",
        head="Nyame Helm", -- Path B
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Nyame Mail", -- Path B
        -- body="SV Separates +1", -- previous
        hands="Nyame Gauntlets", -- Path B
        -- hands="SV Gauntlets +1", -- previous
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        waist="Null Belt",
        legs="Nyame Flanchard", -- Path B
        -- legs="SV Loincloth +1", -- previous
        feet="Nyame Sollerets", -- Path B
        -- feet="SV Gaiters +1", -- previous
    }

    sets.defense.MDT = {
        main="Malignance Pole",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
        ammo="Crepuscular Pebble",
        head="Nyame Helm", -- Path B
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        ring1="Murky Ring",
        ring2="Archon Ring",
        back="Null Shawl",
        waist="Platinum Moogle Belt",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
    }

    sets.defense.MEVA = {
        main="Daybreak",
        sub="Culminus",
        ammo="Crepuscular Pebble",
        head="Agwu's Cap",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Agwu's Robe",
        hands="Agwu's Gages",
        ring1="Archon Ring",
        ring2="Shadow Ring",
        back="Null Shawl",
        waist="Null Belt",
        legs="Agwu's Slops",
        feet="Agwu's Pigaches",
    }

    sets.Kiting = {
        feet="Herald's Gaiters",
        waist="Platinum Moogle Belt",
    }
    sets.latent_refresh = {
        waist="Fucho-no-Obi",
    }
    sets.latent_refresh_grip = {
        sub="Oneiros Grip",
    }

    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.TPEat = {}
    sets.ZodiacRing = {} -- get: Zodiac Ring (ring2) if wanted for day-element nukes
    sets.TwilightCape = {
        back="Twilight Cape",
    }

    -- Engaged sets (SCH rarely melees; follows idle)
    sets.engaged = set_combine(sets.idle, {})
    sets.engaged.PDT = set_combine(sets.idle.PDT, {})

    -- Buff sets: gear that needs to be worn to actively enhance a current player buff.
    -- Empyrean (Arbatel) +1 for now. BIS = Arbatel +3 for each slot.
    sets.buff['Ebullience'] = {
        head="Arbatel Bonnet +1", -- Empy +1 (BIS: Arbatel Bonnet +3)
    }
    sets.buff['Rapture'] = {
        head="Arbatel Bonnet +1", -- Empy +1 (BIS: Arbatel Bonnet +3)
    }
    sets.buff['Perpetuance'] = {
        hands="Arbatel Bracers +1", -- Empy +1 (BIS: Arbatel Bracers +3)
    }
    sets.buff['Immanence'] = {
        hands="Arbatel Bracers +1", -- Empy +1 (BIS: Arbatel Bracers +3)
    }
    sets.buff['Penury'] = {
        legs="Arbatel Pants +1", -- Empy +1 (BIS: Arbatel Pants +3)
    }
    sets.buff['Parsimony'] = {
        legs="Arbatel Pants +1", -- Empy +1 (BIS: Arbatel Pants +3)
    }
    sets.buff['Celerity'] = {
        feet="Peda. Loafers", -- Relic reforged (BIS: Peda. Loafers +3)
    }
    sets.buff['Alacrity'] = {
        feet="Peda. Loafers", -- Relic reforged (BIS: Peda. Loafers +3)
    }
    sets.buff['Klimaform'] = {
        feet="Arbatel Loafers +1", -- Empy +1 (BIS: Arbatel Loafers +3)
    }

    sets.HPDown = {}
    sets.HPCure = {}

    sets.buff.Doom = set_combine(sets.buff.Doom, {})

    -- AF (Academic's) reforged base for now (only the Gown is owned). Upgrade to +3 for BIS.
    sets.buff['Light Arts'] = {
        -- legs="Academic's Pants", -- get: not owned (AF reforged; +1 deferred; BIS: Acad. Pants +3)
    }
    sets.buff['Dark Arts'] = {
        body="Academic's Gown", -- AF reforged (owned): Dark Arts +20 at +1 (BIS: Acad. Gown +3)
    }
    -- Other AF upgrade targets: Acad. Mortar. +3 (Sublimation head), Acad. Bracers +3 (FC+9%, Conserve MP+8),
    -- Acad. Loafers +3 (casting time -12%, Magic Acc+20)

    sets.buff.Sublimation = {
        -- head="Acad. Mortarboard", -- get: not owned (AF reforged; +1 deferred; BIS: Acad. Mortar. +3)
        body="Pedagogy Gown", -- Relic reforged (Sublimation+3 at +1) (BIS: Peda. Gown +3)
        waist="Embla Sash",
    }
    sets.buff.DTSublimation = {
        waist="Embla Sash",
    }

    -- Weapons sets
    -- get: Akademos (main) + Enki Strap (sub), Khatvanga + Bloodrain Strap (Occult Acumen)
    sets.weapons.Default = {
        main="Daybreak",
        sub="Ammurapi Shield",
    }
    sets.weapons.Mpaca = {
        main="Mpaca's Staff",
        sub="Willpower Grip", -- placeholder until mastered: replace with proper grip
    }
    sets.weapons.Daybreak = {
        main="Daybreak",
        sub="Ammurapi Shield",
    }

      placeholder----
    -- Referenced in SCH.lua but not yet gear-defined. Built via set_combine off their real
    -- base sets so they inherit sensible gear immediately instead of equipping nothing --
    -- fill in the {} overrides with anything Resistant/Burst-specific whenever ready.
    sets.element.Fire = {}
    sets.element.Ice = {}
    sets.element.Wind = {}
    sets.element.Earth = {}
    sets.element.Water = {}
    sets.element.Thunder = {}
    sets.element.Light = {}
    -- (sets.element.Dark already defined above)
    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})
    sets.RecoverBurst = set_combine(sets.RecoverMP, {})
    sets.ResistantRecoverBurst = set_combine(sets.RecoverBurst, {})
    sets.MaxTP = {}
      placeholder----
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    set_macro_page(1, 8)
end
