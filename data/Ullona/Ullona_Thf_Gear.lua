-- =============================================================================
-- Ullona_Thf_Gear.lua — Changelog
-- =============================================================================
-- Setup vars that are user-dependent. Can override this function in a sidecar file.
function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal','DT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Match','Normal','DT','SomeAcc','Acc','FullAcc','Fodder','Proc')
    state.IdleMode:options('Normal', 'Sphere')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')

    -- [FUTURE] Uncomment 'Exenterator' and 'AccExenterator' below (and the matching
    -- sets.weapons entries further down) once you actually have that weapon.
    -- state.Weapons:options('Exenterator','AccExenterator', ...)
    state.Weapons:options('Default','Evisceration','Waltz','Savage','AccSavage','Throwing','SwordThrowing','AoE')

    state.ExtraMeleeMode = M{['description']='Extra Melee Mode','None','Suppa','DWMax','Parry'}
    state.AmbushMode = M(false, 'Ambush Mode')

    -- =========================================================================
    -- Macro Book
    -- =========================================================================
    set_macro_page(1, 6) -- Page 1, Macro Book 6

    -- =========================================================================
    -- Additional local binds
    -- =========================================================================
    send_command('bind ^` input /ja "Flee" <me>')                 -- Ctrl + `         : Flee
    send_command('bind !` input /ra <t>')                         -- Alt + `          : Ranged attack
    send_command('bind @` gs c cycle SkillchainMode')             -- Win + `          : Cycle SkillchainMode
    send_command('bind @f10 gs c toggle AmbushMode')              -- Win + F10        : Toggle AmbushMode
    send_command('bind ^backspace input /item "Thief\'s Tools" <t>') -- Ctrl + Backspace : Thief's Tools
    send_command('bind !q gs c weapons SwordThrowing')            -- Alt + Q          : Sword/Throwing weapons
    send_command('bind !backspace input /ja "Hide" <me>')         -- Alt + Backspace  : Hide
    send_command('bind ^a gs c weapons Default;gs c set WeaponSkillMode match') -- Ctrl + A : Default weapons + Match WS
    send_command('bind ^\\\\ input /ja "Despoil" <t>')            -- Ctrl + \         : Despoil
    send_command('bind !\\\\ input /ja "Mug" <t>')                -- Alt + \          : Mug
end

function user_job_lockstyle()
    -- Delay is necessary for game to finish loading equipment model
    send_command('input /lockstyleset 5')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Special sets (required by rules)
    --------------------------------------

	sets.TreasureHunter = {hands="Plunderer's Armlets +1", feet="Skulker's Poulaines +3", waist="Chaac Belt", ammo="Perfect Lucky Egg"}
    sets.Kiting = {feet="Pillager's Poulaines +1"}

	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {}
	
    sets.buff['Sneak Attack'] = {hands="Skulker's Armlets +2", back="Toutatis's Cape"}
    sets.buff['Trick Attack'] = {back="Toutatis's Cape", hands="Pillager's Armlets +1"}

    -- Extra Melee sets.  Apply these on top of melee sets.
    sets.Knockback = {}
	sets.Suppa = {}
	sets.DWEarrings = {}
	sets.DWMax = {}
	sets.Parry = {}
	sets.Ambush = {}
	
	-- Weapons sets
	sets.weapons.Default = {}
	sets.weapons.Evisceration = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.Waltz = {main="Tauret",sub="Gleti's Knife"}
	sets.weapons.Savage = {main="Naegling",sub="Gleti's Knife"}
	sets.weapons.AccSavage = {main="Naegling",sub="Tauret"}
	sets.weapons.Throwing = {main="Tauret",sub="Gleti's Knife",range="Wingcutter",ammo=empty}
	sets.weapons.SwordThrowing = {main="Naegling",sub="Gleti's Knife",range="Wingcutter",ammo=empty}
	-- AoE/farming set -- keeps Sandung on purpose (not swapped to Gleti's Knife like
	-- the sets above) since Sandung carries Treasure Hunter and this is the loot-farming set.
	sets.weapons.AoE = {main="Tauret",sub="Sandung"}

	
    -- Actions we want to use to tag TH.
    sets.precast.Step = {
        head="Mummu Bonnet +2",              
        neck="Null Loop",              
        ear2="Cessance Earring",          
        ear1="Sherida Earring",            
        body="Mummu Jacket +2",             
        hands="Leyline Gloves",         
        ring1="Mars's  Ring",  
        ring2="Meghanada Ring",           
        waist="Sailfi Belt +1",             
        legs="SV loincloth +1",          
        feet="Plunderer's Poulaines",
        ammo="Perfect Lucky Egg"           -- [FIX 2026-08-09] was missing entirely -- this
                                            -- is the TH-tagging set (per the comment above)
                                            -- but never actually equipped the Egg
    }
		
    sets.precast.JA['Violent Flourish'] = {}
	sets.precast.JA['Animated Flourish'] = sets.TreasureHunter
	sets.precast.JA.Provoke = sets.TreasureHunter

    --------------------------------------
    -- Precast sets
    --------------------------------------


    -- Precast sets to enhance JAs
    sets.precast.JA['Collabolua lotor'] = {head="Skulker's Bonnet +2"}
    sets.precast.JA['Accomplice'] = {head="Skulker's Bonnet +2"}
    sets.precast.JA['Flee'] = {feet="Pillager's Poulaines +1",}
    sets.precast.JA['Hide'] = {body="Pillager's Vest +1"}
    sets.precast.JA['Conspirator'] = {head="Skulker's Bonnet +2", body="Skulker's Vest +2", hands="Skulker's Armlets +2", legs="Skulker's Culottes +3", feet="Skulker's Poulaines +3"} 
    sets.precast.JA['Steal'] = {legs="Pillager's Culottes +1", feet="Pillager's Poulaines +1", hands="Pillager's Armlets +1"}
	sets.precast.JA['Mug'] = {head="Plunderer's Bonnet"}
    sets.precast.JA['Despoil'] = {feet="Skulker's Poulaines +3", legs="Skulker's Culottes +3"}
    sets.precast.JA['Perfect Dodge'] = {hands="Plunderer's Armlets +1"}
    sets.precast.JA['Feint'] = {legs="Plunderer's Culottes +1"}
    sets.precast.JA["Assassin's Charge"] = {}

    sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
    sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

    -- Waltz set (chr and vit)
    sets.precast.Waltz = {body= "Gleti's Cuirass", head="Mummu Bonnet +2", hands="Slither Gloves +1", ring1="Asklepian Ring", feet="Rawhide Boots", ammo="Yamarang"}
	sets.Self_Waltz =   sets.precast.Waltz 
    sets.precast.Waltz['Healing Waltz'] =   sets.precast.Waltz 

    -- Fast cast sets for spells
    sets.precast.FC = {    
        head="Ejekamal Mask",           
        ear1="Alabaster Earring",   
        ear2="Malignance Earring",   
        body="Skulker's Vest +2",         
        hands="Leyline Gloves",     
        waist="Cornelia's Belt",
        feet=" Mummu Gamashes +2",
        legs="Malignance Tights",
        ring2="Murky Ring",
        neck = "Voltsurge Torque",
        ring1="Lebeche Ring",
        
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Bead Necklace"})

    -- Ranged snapshot gear
    sets.precast.RA = {}

    --------------------------------------
    -- Weaponskill sets
    --------------------------------------

    -- Default set for any weaponskill that isn't more specifically defined
    sets.precast.WS = {    
        head="Sukeroku Hachimaki",          
        neck="Fotia Gorget",            
        ear2="Ishvara Earring",           
        ear1="Crepuscular Earring",           
        body="Gleti's Cuirass",           
        hands="Meghanada Gloves +2",       
	ring1="Cornelia's Ring",             
        ring2="Rufescent Ring",               
        back="Toutatis's Cape",       
        waist="Fotia Belt",              
        legs="Malignance Tights",          
        feet="Gleti's Boots",
        ammo="Oshasha's Treatise"
    }
    
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {
        hands="Leyline Gloves",         
        ring2="Meghanada Ring",                                   
        waist="Fotia Belt",
        legs="Malignance Tights"
    })
    
    sets.precast.WS.Acc = set_combine(sets.precast.Step, {})
	sets.precast.WS.FullAcc = set_combine(sets.precast.Step, {})



	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {}
	sets.AccMaxTP = {}

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {}

    -- Specific spells
	sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {neck="Magoraga Bead Necklace"})

    -- Ranged gear
    sets.midcast.RA = {}
    sets.midcast.RA.Acc = {}

    --------------------------------------
    -- Melee sets — MUST be defined before sets.idle, which combines onto sets.engaged
    --------------------------------------

    sets.engaged = {            
        head  = "Gleti's Mask",
        feet  ="Malignance Boots",
        neck="Anu Torque",           
        ear2="Skulker's Earring",           
        ear1="Sherida Earring",           
        body="Malignance Tabard",            
        hands="Malignance Gloves",       
        ring1 ="Petrov Ring",
        ring2 ="Rajas Ring",              
        back="Toutatis's Cape",          
        waist="Sailfi Belt +1",            
        legs="Malignance Tights",       
        ammo="Crepuscular Pebble"
    }
		
    sets.engaged.SomeAcc = set_combine(sets.engaged, {waist=gear.default.waist, neck="Sanctity Necklace", ear2="Cessance Earring"})
	sets.engaged.Acc = set_combine(sets.engaged.SomeAcc, {neck="Null Loop", ring1="Mars's Ring"})
    -- [FIX 2 cont.]: was set_combine(sets.Acc, ...) — sets.Acc never existed (typo for
    --          sets.engaged.Acc), so this branch was silently equipping a table missing
    --          everything SomeAcc/Acc had contributed. Now correctly builds on Acc.
    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {ring1="Mars's Ring", ear2="Cessance Earring"})
    sets.engaged.Fodder = set_combine(sets.engaged, {back="Null Shawl"})

    sets.engaged.DT = set_combine(sets.engaged, {})
    sets.engaged.SomeAcc.DT = set_combine(sets.engaged.SomeAcc, {})
    sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})
    sets.engaged.FullAcc.DT = set_combine(sets.engaged.FullAcc, {})
    sets.engaged.Fodder.DT = set_combine(sets.engaged.Fodder, {})

    --------------------------------------
    -- Idle/resting/defense sets
    --------------------------------------

    -- Resting sets
    sets.resting = {}

    -- Idle sets
    sets.idle = set_combine(sets.engaged, {
        head  = "Gleti's Mask",
        body  = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        legs  = "Gleti's Breeches",
        feet  = "Gleti's Boots",
        waist="Null Belt",

    })
		
    sets.idle.Sphere = set_combine(sets.idle, {waist="Null Belt"})
    sets.idle.Weak = set_combine(sets.idle, {})

	sets.DayIdle = set_combine(sets.idle, {})
	sets.NightIdle = set_combine(sets.idle, {})
	sets.ExtraRegen = set_combine(sets.idle, {waist="Null Belt"})


    -- Defense sets
    sets.defense.PDT = {}
    sets.defense.MDT = {}
	sets.defense.MEVA = {}
	sets.engaged.Haste_15 = {}
	sets.engaged.Haste_30 = {}
	sets.engaged.MaxHaste = {}
	-----placeholder----
end
