-- Ullona_Smn_Gear.lua — Changelog
-- Setup vars that are user-dependent. Can override this function in a sidecar.
function user_job_setup()
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','OccultAcumen')
    state.IdleMode:options('Normal','PDT')
    state.Weapons:options('None','Gridarvor','Khatvanga')
    gear.perp_staff = {name="Gridarvor"}
    gear.magic_jse_back = {
        name="Campestres's Cape",
        augments={'Pet: M.Acc.+20 Pet: M.Dmg.+20','Eva.+20 /Mag. Eva.+20','Pet: "Regen"+10',}
    }
    gear.phys_jse_back = {
        name="Campestres's Cape",
        augments={'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20','Eva.+20 /Mag. Eva.+20','Pet: Haste+10',}
    }
    -- Macro Book
    set_macro_page(1, 7) -- Page 1, Macro Book 7
    -- Additional local binds
    send_command('bind !` input /ja "Release" <me>')                         -- Alt + `      : Release current avatar/spirit
    send_command('bind @` gs c cycle MagicBurst')                            -- Win + `      : Cycle MagicBurstMode
    send_command('bind ^\\\\ gs c toggle PactSpamMode')                      -- Ctrl + \     : Toggle PactSpamMode
    send_command('bind !pause gs c toggle AutoSubMode')                      -- Alt + Pause  : Toggle AutoSubMode
    send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen') -- Ctrl + Q : Khatvanga + OccultAcumen
    send_command('bind !q gs c weapons default;gs c reset CastingMode')      -- Alt + Q      : Reset weapons + CastingMode
    send_command('bind ^a gs c wheelavatar')                                 -- Ctrl + A     : Summon avatar from Elemental Wheel
    send_command('bind !1 input /pet "Assault" <t>')                         -- Alt + 1      : Pet Assault (your target)
    send_command('bind !2 input /pet "Retreat" <me>')                        -- Alt + 2      : Pet Retreat
    send_command('bind !3 input /pet "Release" <me>')                        -- Alt + 3      : Pet Release
    -- Note: Ctrl + ` is intentionally left unbound here -- it's the GLOBAL
    -- ElementalMode cycle bind from Ullona-Globals.lua.
end
function user_job_lockstyle()
    -- Delay is necessary for game to finish loading equipment model
    send_command('input /lockstyleset 7')
end
-- Define sets and vars used by this job file.
function init_gear_sets()
    -- Precast Sets
    -- Weapon states: state.Weapons:options('None','Gridarvor','Khatvanga') needs a set per name
    sets.weapons = sets.weapons or {}
    sets.weapons.Gridarvor = {main="Gridarvor"}
    sets.weapons.Khatvanga = {main="Khatvanga"}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {feet=gear.merlinic_treasure_feet})
    -- Precast sets to enhance JAs
    sets.precast.JA['Astral Flow'] = {head="Glyphic Horn"}
    -- Elemental Siphon: equipped on the /ja inside handle_siphoning() (gs c siphon).
    -- (Summoning skill / siphon-effect pieces go here; the spirit summon uses sets.midcast['Summoning Magic'].)
    sets.precast.JA['Elemental Siphon'] = {}
    sets.precast.JA['Mana Cede'] = {hands="Beck. Bracers +1"}
    -- Pact delay reduction gear
    sets.precast.BloodPactWard = {}
    sets.precast.BloodPactRage = sets.precast.BloodPactWard
    -- Fast cast sets for spells
    sets.precast.FC =    {
        main  = "Mpaca's Staff",
        sub="Willpower Grip",
        head  = "Nahtirah Hat",
        body  = "SV Separates +1",
        hands = "SV guantlets +1",
        legs="Querkening Brais",
        feet  = "Regal Pumps",
        neck = "Voltsurge Torque",
        ear2="Malignance Earring",   
        ear1  = "Alabaster Earring",
        ring2 = "Lebeche Ring",
		ring1="Naji's Loop",
        waist = "Embla Sash",}
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {        
        main  = "Vadose Rod",
        sub=none,
        ammo="Psilomene",
        head  = "Vanya Hood",
        body="Inyanga Jubbah +2",
        hands = "Bokwus Gloves",
        legs="Gyve Trousers",
        feet  = "Vanya Clogs",  -- kept from base FC
        neck = "Voltsurge Torque",
        ear2  = "Novia Earring",
        ring2 = "Janniston Ring",
        ring1 = "Lebeche Ring",
        back  = "Tempered Cape +1",
        waist = "Acerbic Sash +1",})
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {     head  = "Mallquis Chapeau +2",
        hands = "Bokwus Gloves",
        legs  = "Shedir Seraweels",
        feet  = "Medium's Sabots",
        ear1  = "Magnetic Earring",
        ear2  = "Andoaa Earring",
        ring2 = "Vertigo Ring",
        waist = "Siegel Sash",})
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {waist="Siegel Sash", legs="Shedir Seraweels", head="Umuthi Hat", neck  ="Nodens Gorget",})
	sets.precast.FC.Impact = set_combine(sets.precast.FC, {head=empty,body="Twilight Cloak"})       
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Culminus"})
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {}
    -- Midcast sets
    sets.midcast.Cure =         
        {main  = "Bunzi Rod",
        head  = "Vanya Hood",
        body  ="Vrikodara Jupon",
        hands = "Bokwus Gloves",
        feet  = "Vanya Clogs",
        neck  = "Nodens Gorget",
        ear2="Glorious Earring",
        ear1  = "Mendicant's Earring",
        ring2 ="Janniston Ring",
        ring1 ="Lebeche Ring",
        legs="Gyve Trousers",}
	sets.Self_Healing = {}
	sets.Cure_Received = {}
	sets.Self_Refresh = {}
sets.midcast.Cursna = set_combine(sets.midcast.Cure, {
		neck="Nodens Gorget", hands="Bokwus Gloves",
		back="Tempered Cape +1",    
		waist="Cornelia's Belt", feet="Vanya Clogs"
	})
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast or {}, {sub="Clemency Grip"})
	sets.midcast['Summoning Magic'] = {main="Malignance Pole",sub="Umbra Strap"}
	sets.midcast['Elemental Magic'] = {        
        main  ="Marin Staff +1",
        sub   ="Willpower Grip",
        ammo  ="Ghastly Tathlum",
        head  ="Bunzi's Hat",
        body  ="Bunzi's Robe",
        legs  ="Bunzi's Pants",
        hands ="Bunzi's Gloves",
        feet  ="Bunzi's Sabots",
        neck  ="Baetyl Pendant",
        ear1  ="Malignance Earring",
        ear2  ="Hecate's Earring",
        ring2 ="Jhakri Ring",
        ring1 ="Resonance Ring",
        back  ="Izdubar Mantle",
        waist ="Hachirin-no-obi"
    }
	sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
		main = "Mpaca's Staff",
		neck = "Incanter's Torque",
		head = "Inyanga Tiara +2",
		waist = "Null Belt",
		back = "Null Shawl",
	})
    sets.midcast['Elemental Magic'].OccultAcumen = {}
    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {head=empty, body="Twilight Cloak"})
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        feet="Medium's Sabots",
        body="Vanya Robe",
    })
	 sets.midcast['Dark Magic'] = set_combine(sets.midcast['Elemental Magic'],{
        neck  ="Erra Pendant",
        ear1  ="Alabaster Earring",
        ear2  ="Malignance Earring",
        ring1 ="Crepuscular Ring",
        ring2="Evanescence Ring",
        back  ="Izdubar Mantle",
        waist ="Eschan Stone",
        ammo="Ghastly Tathlum"
    })
    sets.midcast.Drain      = set_combine(sets.midcast['Dark Magic'], {neck="Erra Pendant", waist="Fucho-no-obi", feet="Merlinic Crackows"})
    sets.midcast.Aspir      = set_combine(sets.midcast.Drain, {})
    sets.midcast.Stun           = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {})
sets.midcast['Enfeebling Magic'] = {
	main  ="Mpaca's Staff",
    sub="Mephitis Grip",
    head="Bunzi's Hat",
    body="Bunzi's Robe",
	legs="Bunzi's Pants",
    feet="Bunzi's Sabots",
    neck="Null Shawl",
	ear1="Malignance Earring", 
	ear2="Ebers Earring +1",
    ring1="Inyanga Ring",
    ring2="Crepuscular Ring",
    waist="Obstinate Sash",
	back="Altruistic Cape",
	ranged="Aureole"
}
 sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
	main="Mpaca's Staff",
	waist="Null Belt"
})
	sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast.Diaga = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Enhancing Magic'] = {main=gear.gada_enhancing_club,sub="Ammurapi Shield",ammo="Psilomene",
		head="Umuthi Hat",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Gifted Earring",
		body="Telchine Chas.",hands="Bokwus Gloves",
		back="Izdubar Mantle",waist="Embla Sash",legs="Telchine Braconi",feet="Telchine Pigaches"}
	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})
	sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {main="Bolelabunga"})
	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {main="Vadose Rod", sub="Culminus", legs="Shedir Seraweels"})
    sets.precast.Stoneskin     = set_combine(sets.precast.FC, {waist="Siegel Sash", legs="Querkening Brais"})
	sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {legs="Shedir Seraweels"})
    -- Avatar pact sets.  All pacts are Ability type.
    sets.midcast.Pet.BloodPactWard = {}
    sets.midcast.Pet.DebuffBloodPactWard = {}
    sets.midcast.Pet.DebuffBloodPactWard.Acc = sets.midcast.Pet.DebuffBloodPactWard
    sets.midcast.Pet.PhysicalBloodPactRage = {legs="Enticer's Pants"}
    sets.midcast.Pet.PhysicalBloodPactRage.AM = {}   -- equipped on top while Aftermath: Lv.3 is up
    sets.midcast.Pet.PhysicalBloodPactRage.Acc = set_combine(sets.midcast.Pet.PhysicalBloodPactRage,{})
    sets.midcast.Pet.MagicalBloodPactRage = {}
    sets.midcast.Pet.MagicalBloodPactRage.Acc = set_combine(sets.midcast.Pet.MagicalBloodPactRage,{})
    -- Spirits cast magic spells, which can be identified in standard ways.
    sets.midcast.Pet.WhiteMagic = {} --legs="Summoner's Spats"
    sets.midcast.Pet['Elemental Magic'] = set_combine(sets.midcast.Pet.MagicalBloodPactRage, {}) --legs="Summoner's Spats"
    sets.midcast.Pet['Elemental Magic'].Resistant = {}
	sets.midcast.Pet['Impact'] = sets.midcast.Pet.DebuffBloodPactWard
	-- No per-pact sets needed: every Rage pact falls through to PhysicalBloodPactRage / MagicalBloodPactRage
	-- (+ their .Acc under CastingMode Resistant). Per-avatar tweaks go in sets.midcast.Pet.<Set>[avatar name].
    -- Idle/resting/defense/etc sets
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
	--	ear2="Moonshade Earring",
		ear1="Alabaster Earring",
		ring2="Murky Ring",
		ring1="Inyanga Ring",
		back="Archon Cape",
		waist="Acerbic Sash +1"
	}
    sets.idle.PDT = {}
    -- Resting sets
    sets.resting = set_combine(sets.idle, {
    main="Chatoyant Staff",
    sub="Achaq Grip",
	body="Inyanga Jubbah +2",
    legs="Assiduity Pants +1",
    ear2="Magnetic Earring"
})
    -- perp costs:
    -- spirits: 7
    -- carby: 11 (5 with mitts)
    -- fenrir: 13
    -- others: 15
    -- avatar's favor: -4/tick
    -- Max useful -perp gear is 1 less than the perp cost (can't be reduced below 1)
    -- Aim for -14 perp, and refresh in other slots.
    -- Can make due without either the head or the body, and use +refresh items in those slots.
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
    feet="Convo. Pigaches +3"
}
sets.idle.PDT.Avatar = {
    main="Malignance Pole",
    sub="Oneiros Grip",
    ammo="Seraphicaller",
    head="Beckoner's Horn +1",
    neck="Adad Amulet",
  --  ear1="C. Palug Earring",
    ear2="Beckoner's Earring +1",
    body="Shomonjijoe",
    hands=gear.merlinic_refresh_hands,
    ring1="Defending Ring",
    ring2="Dark Ring",
    back="Moonlight Cape",
    waist="Regal Belt",
    legs="Assid. Pants +1",
    feet="Convo. Pigaches +3"
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
    feet="Convo. Pigaches +3"
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
    feet="Battlecast Gaiters"
}
--Favor always up and head is best in slot idle so no specific items here at the moment.
    sets.idle.Avatar.Favor = {}
    sets.idle.Avatar.Engaged = {}
	sets.idle.Avatar.Engaged.Carbuncle = {}
	sets.idle.Avatar.Engaged['Cait Sith'] = {}
    sets.perp = {}
    -- Caller's Bracer's halve the perp cost after other costs are accounted for.
    -- Using -10 (Gridavor, ring, Conv.feet), standard avatars would then cost 5, halved to 2.
    -- We can then use Hagondes Coat and end up with the same net MP cost, but significantly better defense.
    -- Weather is the same, but we can also use the latent on the pendant to negate the last point lost.
    sets.perp.Day = {}
    sets.perp.Weather = {}
	sets.perp.Carbuncle = {}
    sets.perp.Diabolos = {waist="Diablos's Rope"}
    sets.perp.Alexander = sets.midcast.Pet.BloodPactWard
	-- Not really used anymore, was for the days of specific staves for specific avatars.
    sets.perp.staff_and_grip = {}
    -- Defense sets
    sets.defense.PDT = {}
    sets.defense.MDT = {}
    sets.defense.MEVA = {}
    sets.Kiting = {feet="Herald's Gaiters"}
    sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.DayIdle = {}
	sets.NightIdle = {}
	sets.HPDown = {}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {}
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    -- Engaged sets
    -- Normal melee group
    sets.engaged = {}
    -----placeholder----
    -- Referenced in SMN.lua but not yet gear-defined -- SMN never had MagicBurst or
    -- MP-recovery gear logic before this pass (see recent RecoverMode/try_recover_mp changes).
    -- RecoverBurst/ResistantRecoverBurst are chained off RecoverMP via set_combine, so once
    -- you fill RecoverMP in with real gear, both of these inherit it automatically. MagicBurst
    -- has no prior "OG" set to pull from here, so it's a genuinely blank slate.
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
    -----placeholder----
end