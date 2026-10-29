-- Ullona_Smn_Gear.lua — Changelog

-- Macro Book
-- Mote-Include calls this on load and when the subjob changes.
function select_default_macro_book()
    set_macro_page(1, 7) -- Page 1, Macro Book 7
end

function user_job_setup()
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','OccultAcumen')
    state.IdleMode:options('Normal','PDT')
    state.Weapons:options('None','Gridarvor','Khatvanga')

    gear.perp_staff = {name="Gridarvor"}

    gear.magic_jse_back = {
        name="Campestres's Cape",
        augments={
            'Pet: M.Acc.+20 Pet: M.Dmg.+20',
            'Eva.+20 /Mag. Eva.+20',
            'Pet: "Regen"+10',
        }
    }

    gear.phys_jse_back = {
        name="Campestres's Cape",
        augments={
            'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20',
            'Eva.+20 /Mag. Eva.+20',
            'Pet: Haste+10',
        }
    }

    -- Additional local binds
    send_command('bind !` input /ja "Release" <me>') -- Alt + `: Release current avatar/spirit
    send_command('bind @` gs c cycle MagicBurst') -- Win + `: Cycle MagicBurstMode
    send_command('bind ^\\\\ gs c toggle PactSpamMode') -- Ctrl + \: Toggle PactSpamMode
    send_command('bind !pause gs c toggle AutoSubMode') -- Alt + Pause: Toggle AutoSubMode
    send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen') -- Ctrl + Q
    send_command('bind !q gs c weapons default;gs c reset CastingMode') -- Alt + Q
    send_command('bind ^a gs c wheelavatar') -- Ctrl + A: Summon avatar from Elemental Wheel
    send_command('bind !1 input /pet "Assault" <t>') -- Alt + 1: Pet Assault
    send_command('bind !2 input /pet "Retreat" <me>') -- Alt + 2: Pet Retreat
    send_command('bind !3 input /pet "Release" <me>') -- Alt + 3: Pet Release

    -- Ctrl + ` is intentionally left unbound here.
    -- It is the GLOBAL ElementalMode cycle bind from Ullona-Globals.lua.
end

-- Clear every bind this file sets so they don't linger after a job change/reload.
function user_job_unload()
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind ^\\\\')
    send_command('unbind !pause')
    send_command('unbind ^q')
    send_command('unbind !q')
    send_command('unbind ^a')
    send_command('unbind !1')
    send_command('unbind !2')
    send_command('unbind !3')
end

function user_job_lockstyle()
    -- Delay is necessary for game to finish loading equipment model.
    send_command('input /lockstyleset 7')
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    -- Weapon states
    sets.weapons = sets.weapons or {}
    sets.weapons.Gridarvor = {main="Gridarvor"}
    sets.weapons.Khatvanga = {main="Khatvanga"}

    sets.TreasureHunter = set_combine(sets.TreasureHunter, {
        feet=gear.merlinic_treasure_feet
    })

    -- Precast sets to enhance JAs
    sets.precast.JA['Astral Flow'] = {head="Glyphic Horn"}

    -- Elemental Siphon: equipped on the /ja inside handle_siphoning() (gs c siphon).
    -- Summoning skill / siphon-effect pieces go here.
    -- Spirit summon uses sets.midcast['Summoning Magic'].
    sets.precast.JA['Elemental Siphon'] = {}
    sets.precast.JA['Mana Cede'] = {hands="Beck. Bracers +1"}

    -- Pact delay reduction gear
    sets.precast.BloodPactWard = {}
    sets.precast.BloodPactRage = sets.precast.BloodPactWard

    -- Fast Cast sets
    sets.precast.FC = {
        main="Mpaca's Staff",
        sub="Willpower Grip",
        head="Nahtirah Hat",
        body="SV Separates +1",
        hands="SV guantlets +1",
        legs="Querkening Brais",
        feet="Regal Pumps",
        neck="Voltsurge Torque",
        ear2="Malignance Earring",
        ear1="Alabaster Earring",
        ring2="Lebeche Ring",
        ring1="Naji's Loop",
        waist="Embla Sash",
    }

    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main="Vadose Rod",
        sub="empty",
        ammo="Psilomene",
        head="Vanya Hood",
        body="Inyanga Jubbah +2",
        hands="Bokwus Gloves",
        legs="Gyve Trousers",
        feet="Vanya Clogs",
        neck="Voltsurge Torque",
        ear2="Novia Earring",
        ring2="Janniston Ring",
        ring1="Lebeche Ring",
        back="Tempered Cape +1",
        waist="Acerbic Sash +1",
    })

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        head="Mallquis Chapeau +2",
        hands="Bokwus Gloves",
        legs="Shedir Seraweels",
        feet="Medium's Sabots",
        ear1="Magnetic Earring",
        ear2="Andoaa Earring",
        ring2="Vertigo Ring",
        waist="Siegel Sash",
    })

    sets.precast.FC.Stoneskin = set_combine(
        sets.precast.FC['Enhancing Magic'],
        {
            waist="Siegel Sash",
            legs="Shedir Seraweels",
            head="Umuthi Hat",
            neck="Nodens Gorget",
        }
    )

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head="empty",
        body="Twilight Cloak",
    })

    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Culminus",
    })

    -- Weaponskill sets
    -- Default set for any weaponskill without a specific definition.
    sets.precast.WS = {}

    -- Midcast sets
    sets.midcast.Cure = {
        main="Bunzi Rod",
        head="Vanya Hood",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        feet="Vanya Clogs",
        neck="Nodens Gorget",
        ear2="Glorious Earring",
        ear1="Mendicant's Earring",
        ring2="Janniston Ring",
        ring1="Lebeche Ring",
        legs="Gyve Trousers",
    }

    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}

    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
        neck="Nodens Gorget",
        hands="Bokwus Gloves",
        back="Tempered Cape +1",
        waist="Cornelia's Belt",
        feet="Vanya Clogs",
    })

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast or {}, {
        sub="Clemency Grip",
    })

    sets.midcast['Summoning Magic'] = {
        main="Malignance Pole",
        sub="Umbra Strap",
    }

    sets.midcast['Elemental Magic'] = {
        main="Marin Staff +1",
        sub="Willpower Grip",
        ammo="Ghastly Tathlum",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        legs="Bunzi's Pants",
        hands="Bunzi's Gloves",
        feet="Bunzi's Sabots",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Hecate's Earring",
        ring2="Jhakri Ring",
        ring1="Resonance Ring",
        back="Izdubar Mantle",
        waist="Hachirin-no-obi",
    }

    sets.midcast['Elemental Magic'].Resistant = set_combine(
        sets.midcast['Elemental Magic'],
        {
            main="Mpaca's Staff",
            neck="Incanter's Torque",
            head="Inyanga Tiara +2",
            waist="Null Belt",
            back="Null Shawl",
        }
    )

    sets.midcast['Elemental Magic'].OccultAcumen = {}

    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {
        head="empty",
        body="Twilight Cloak",
    })

    sets.midcast['Divine Magic'] = set_combine(
        sets.midcast['Elemental Magic'],
        {
            feet="Medium's Sabots",
            body="Vanya Robe",
        }
    )

    sets.midcast['Dark Magic'] = set_combine(
        sets.midcast['Elemental Magic'],
        {
            neck="Erra Pendant",
            ear1="Alabaster Earring",
            ear2="Malignance Earring",
            ring1="Crepuscular Ring",
            ring2="Evanescence Ring",
            back="Izdubar Mantle",
            waist="Eschan Stone",
            ammo="Ghastly Tathlum",
        }
    )

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        neck="Erra Pendant",
        waist="Fucho-no-obi",
        feet="Merlinic Crackows",
    })

    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})
    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {})

    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff",
        sub="Mephitis Grip",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        neck="Null Loop",
        ear1="Malignance Earring",
        ear2="Ebers Earring +1",
        ring1="Inyanga Ring",
        ring2="Crepuscular Ring",
        waist="Obstinate Sash",
        back="Altruistic Cape",
        ranged="Aureole",
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(
        sets.midcast['Enfeebling Magic'],
        {
            main="Mpaca's Staff",
            waist="Null Belt",
        }
    )

    sets.midcast.Dia = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )

    sets.midcast.Diaga = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )

    sets.midcast['Dia II'] = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )

    sets.midcast.Bio = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )

    sets.midcast['Bio II'] = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )

    sets.midcast['Enhancing Magic'] = {
        main=gear.gada_enhancing_club,
        sub="Ammurapi Shield",
        ammo="Psilomene",
        head="Umuthi Hat",
        neck="Incanter's Torque",
        ear1="Andoaa Earring",
        ear2="Gifted Earring",
        body="Telchine Chas.",
        hands="Bokwus Gloves",
        back="Izdubar Mantle",
        waist="Embla Sash",
        legs="Telchine Braconi",
        feet="Telchine Pigaches",
    }

    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        head="Amalric Coif +1",
    })

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga",
        sub="Ammurapi Shield",
        feet="Bunzi's Sabots",
    })

    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Vadose Rod",
        sub="Culminus",
        legs="Shedir Seraweels",
    })

    sets.precast.Stoneskin = set_combine(sets.precast.FC, {
        waist="Siegel Sash",
        legs="Querkening Brais",
    })

    sets.midcast.BarElement = set_combine(
        sets.precast.FC['Enhancing Magic'],
        {
            legs="Shedir Seraweels",
        }
    )

    -- Avatar pact sets. All pacts are Ability type.
    sets.midcast.Pet.BloodPactWard = {}
    sets.midcast.Pet.DebuffBloodPactWard = {}
    sets.midcast.Pet.DebuffBloodPactWard.Acc =
        sets.midcast.Pet.DebuffBloodPactWard

    sets.midcast.Pet.PhysicalBloodPactRage = {
        legs="Enticer's Pants",
    }

    sets.midcast.Pet.PhysicalBloodPactRage.AM = {}
    sets.midcast.Pet.PhysicalBloodPactRage.Acc = set_combine(
        sets.midcast.Pet.PhysicalBloodPactRage,
        {}
    )

    sets.midcast.Pet.MagicalBloodPactRage = {}
    sets.midcast.Pet.MagicalBloodPactRage.Acc = set_combine(
        sets.midcast.Pet.MagicalBloodPactRage,
        {}
    )

    -- Spirits cast magic spells, which can be identified in standard ways.
    sets.midcast.Pet.WhiteMagic = {} -- legs="Summoner's Spats"

    sets.midcast.Pet['Elemental Magic'] = set_combine(
        sets.midcast.Pet.MagicalBloodPactRage,
        {}
    ) -- legs="Summoner's Spats"

    sets.midcast.Pet['Elemental Magic'].Resistant = {}
    sets.midcast.Pet['Impact'] = sets.midcast.Pet.DebuffBloodPactWard

    -- No per-pact sets needed: every Rage pact falls through to
    -- PhysicalBloodPactRage / MagicalBloodPactRage and their .Acc variants.
    -- Per-avatar tweaks go in sets.midcast.Pet.<Set>[avatar name].

    -- Idle/resting/defense sets
    sets.idle = {
        main="Mpaca's Staff",
        sub="Umbra Strap",
        ammo="Seraphicaller",
        head="Inyanga Tiara +2",
        body="Ebers Bliaut +3",
        legs="Assiduity Pants +1",
        hands="Inyanga Dastanas +2",
        feet="Inyanga Crackows +2",
        neck="Null Loop",
        -- ear2="Moonshade Earring",
        ear1="Alabaster Earring",
        ring2="Murky Ring",
        ring1="Inyanga Ring",
        back="Archon Cape",
        waist="Acerbic Sash +1",
    }

    sets.idle.PDT = {}

    -- Resting sets
    sets.resting = set_combine(sets.idle, {
        main="Chatoyant Staff",
        sub="Achaq Grip",
        body="Inyanga Jubbah +2",
        legs="Assiduity Pants +1",
        ear2="Magnetic Earring",
    })

    -- Perpetuation costs:
    -- Spirits: 7
    -- Carbuncle: 11 (5 with mitts)
    -- Fenrir: 13
    -- Others: 15
    -- Avatar's Favor: -4/tick
    -- Maximum useful -perp gear is one less than the perp cost.
    -- Aim for -14 perp, and refresh in other slots.

    sets.idle.Avatar = {
        main="Gridarvor",
        sub="Oneiros Grip",
        ammo="Seraphicaller",
        head="Beckoner's Horn +1",
        neck="Caller's Pendant",
        ear1="C. Palug Earring",
        ear2="Evans Earring",
        body="Shomonjijoe",
        hands=gear.merlinic_refresh_hands,
        ring1="Evoker's Ring",
        ring2="Stikini Ring +1",
        back="Moonlight Cape",
        waist="Lucidity Sash",
        legs="Assid. Pants +1",
        feet="Convo. Pigaches +3",
    }

    sets.idle.PDT.Avatar = {
        main="Malignance Pole",
        sub="Oneiros Grip",
        ammo="Seraphicaller",
        head="Beckoner's Horn +1",
        neck="Adad Amulet",
        -- ear1="C. Palug Earring",
        ear2="Beckoner's Earring +1",
        body="Shomonjijoe",
        hands=gear.merlinic_refresh_hands,
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Moonlight Cape",
        waist="Regal Belt",
        legs="Assid. Pants +1",
        feet="Convo. Pigaches +3",
    }

    sets.idle.Spirit = {
        main="Mpaca's Staff",
        sub="Oneiros Grip",
        ammo="Seraphicaller",
        head="Convoker's Horn +3",
        neck="Caller's Pendant",
        ear1="C. Palug Earring",
        ear2="Ethereal Earring",
        body="Shomonjijoe",
        hands=gear.merlinic_refresh_hands,
        ring1="Evoker's Ring",
        ring2="Stikini Ring +1",
        back="Conveyance Cape",
        waist="Lucidity Sash",
        legs="Assid. Pants +1",
        feet="Convo. Pigaches +3",
    }

    sets.idle.PDT.Spirit = {
        main="Malignance Pole",
        sub="Oneiros Grip",
        ammo="Seraphicaller",
        head="Convoker's Horn +3",
        neck="Loricate Torque +1",
        ear1="C. Palug Earring",
        ear2="Evans Earring",
        body="Shomonjijoe +1",
        hands=gear.merlinic_refresh_hands,
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Umbra Cape",
        waist="Lucidity Sash",
        legs="Assid. Pants +1",
        feet="Battlecast Gaiters",
    }

    -- Favor always up; no separate gear defined here yet.
    sets.idle.Avatar.Favor = {}
    sets.idle.Avatar.Engaged = {}
    sets.idle.Avatar.Engaged.Carbuncle = {}
    sets.idle.Avatar.Engaged['Cait Sith'] = {}

    sets.perp = {}

    -- Caller's Bracers halve perp cost after other costs are accounted for.
    -- Using -10 (Gridarvor, ring, Convoker's feet), standard avatars
    -- would then cost 5, halved to 2.
    -- Perp day/weather sets are currently placeholders.
    sets.perp.Day = {}
    sets.perp.Weather = {}
    sets.perp.Carbuncle = {}
    sets.perp.Diabolos = {
        waist="Diablos's Rope",
    }
    sets.perp.Alexander = sets.midcast.Pet.BloodPactWard

    -- Not really used anymore; previously for specific avatar staves.
    sets.perp.staff_and_grip = {}

    -- Defense sets
    sets.defense.PDT = {}
    sets.defense.MDT = {}
    sets.defense.MEVA = {}

    sets.Kiting = {
        feet="Herald's Gaiters",
    }

    sets.latent_refresh = {
        waist="Fucho-no-obi",
    }

    sets.latent_refresh_grip = {
        sub="Oneiros Grip",
    }

    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.HPDown = {}

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {}
    sets.buff.Sublimation = {
        waist="Embla Sash",
    }
    sets.buff.DTSublimation = {
        waist="Embla Sash",
    }

    -- Engaged sets
    sets.engaged = {}

    -- Placeholder sets referenced by SMN.lua.
    -- RecoverBurst and ResistantRecoverBurst inherit from RecoverMP.
    -- MagicBurst has no prior set to inherit from yet.
    sets.element = sets.element or {}
    sets.element.Fire = {}
    sets.element.Ice = {}
    sets.element.Wind = {}
    sets.element.Earth = {}
    sets.element.Water = {}
    sets.element.Thunder = {}
    sets.element.Light = {}
    sets.element.Dark = {}

    sets.MagicBurst = {}
    sets.RecoverMP = {}
    sets.RecoverBurst = set_combine(sets.RecoverMP, {})
    sets.ResistantRecoverBurst = set_combine(sets.RecoverBurst, {})
    sets.MaxTP = {}

end