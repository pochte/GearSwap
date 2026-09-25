--[[
(Ullona-Globals.lua):
]]

-- Global includes.
include('SoulDevour.lua')
include('Ullona-shortcuts.lua')
include('Smart-Caster.lua')
include('organizer-lib')
latency = .67

-- Shadow conservation.
conserveshadows = false

-- Display settings.
state.DisplayMode = M(true, 'Display Mode')

--displayx = 3
--displayy = 1062
--displayfont = 'Arial'
--displaysize = 12
--displaybold = true
--displaybg = 0
--displaystroke = 2
--displaytransparancy = 192
--state.DisplayColors = {
    -- h='\\cs(255, 0, 0)',
    -- w='\\cs(255,255,255)',
    -- n='\\cs(192,192,192)',
    -- s='\\cs(96,96,96)'
--}
-- Automation settings.
state.ReEquip = M(true, 'ReEquip Mode')
state.AutoArts = M(true, 'AutoArts')

-- Shared ElementalMode order.
state.ElementalMode = M{['description'] = 'Elemental Mode','Lightning','Ice','Fire','Wind','Water','Earth','Dark','Light',}

-- Silence ElementalMode announcements.
function user_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'displayelement' then
        eventArgs.handled = true
        return
    end

    if cmdParams[2] and cmdParams[2]:lower() == 'elementalmode' and (cmdParams[1]:lower() == 'cycle' or cmdParams[1]:lower() == 'cycleback') then
        local oldVal = state.ElementalMode.value
        if cmdParams[1]:lower() == 'cycleback' then
            state.ElementalMode:cycleback()
        else
            state.ElementalMode:cycle()
        end
        local newVal = state.ElementalMode.value

        if state_change then
            state_change(state.ElementalMode.description, newVal, oldVal)
        end

        handle_update({'auto'})
        eventArgs.handled = true
        return
    end

    -- Weapons/MainWeapon compatibility: jobs migrated to the MainWeapon/OffWeapon split
    -- (currently RDM, THF) no longer have a state.Weapons at all, so the Ctrl+F7 bind below
    -- ('gs c cycle Weapons') would silently do nothing on those jobs. Redirect to MainWeapon
    -- when it exists; unmigrated jobs still cycle the old Weapons state exactly as before.
    if cmdParams[2] and cmdParams[2]:lower() == 'weapons' and (cmdParams[1]:lower() == 'cycle' or cmdParams[1]:lower() == 'cycleback') then
        local target = state.MainWeapon or state.Weapons
        if target then
            if cmdParams[1]:lower() == 'cycleback' then
                target:cycleback()
            else
                target:cycle()
            end
        end
        eventArgs.handled = true
        return
    end

    -- Same compatibility fix for Ctrl+R ('gs c weapons Default') -- only intercepts on
    -- migrated jobs (state.MainWeapon present); unmigrated jobs fall through untouched to
    -- the library's own 'weapons <name>' handling, same as always.
    if cmdParams[1]:lower() == 'weapons' and cmdParams[2] and cmdParams[2]:lower() == 'default' and state.MainWeapon then
        send_command('gs c set MainWeapon None')
        if state.OffWeapon then send_command('gs c set OffWeapon None') end
        if state.RangedWeapon then send_command('gs c set RangedWeapon None') end
        eventArgs.handled = true
        return
    end

    -- Cycle defense submode.
    if cmdParams[1]:lower() == 'cycledefensesub' then
        if state.DefenseMode.value == 'None' then
            add_to_chat(123,'No defense mode active -- nothing to cycle.')
        else
            local subState = state[state.DefenseMode.value..'DefenseMode']
            if subState then
                subState:cycle()
                if state.DisplayMode.value then update_job_states() end
            end
        end
        eventArgs.handled = true
        return
    end

    -- Smart Utsusemi.
    if cmdParams[1]:lower() == 'utsusemi' then
        handle_utsusemi(cmdParams)
        eventArgs.handled = true
        return
    end

    -- Smart Waltz.
    if cmdParams[1]:lower() == 'smartwaltz' then
        handle_smartwaltz(cmdParams)
        eventArgs.handled = true
    end

    -- Smart Na.
    if cmdParams[1]:lower() == 'smartna' then
        if handle_smart_curena then
            handle_smart_curena(cmdParams)
        else
            add_to_chat(123, 'Abort: SmartNa requires Smart-Caster.lua to be included on this job.')
        end
        eventArgs.handled = true
        return
    end

    -- Nexus Cape command.
    if cmdParams[1]:lower() == 'nexus' then
        add_to_chat(217,'Equipping Nexus Cape. Activating in 30 seconds.')
        windower.send_command('gs c forceequip back "Nexus Cape"; wait 30; input /item "Nexus Cape" <me>')
        eventArgs.handled = true
        return
    end
end

-- Nexus command alias.
send_command('alias /nexus gs c nexus')

-- Utsusemi tool requirements.
local utsusemi_tool_required = {
    ['Utsusemi: San'] = nil,
    ['Utsusemi: Ni']  = 'Shihei',
    ['Utsusemi: Ichi'] = nil,
}

local last_missing_tool_ping = 0

function handle_utsusemi(cmdParams)
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local tiers = {'Utsusemi: San', 'Utsusemi: Ni', 'Utsusemi: Ichi'}
    local missing_tool = nil

    for k in ipairs(tiers) do
        local spell = get_spell_table_by_name(tiers[k])
        local tool = utsusemi_tool_required[tiers[k]]
        local has_tool = not tool or player.inventory[tool]

        if tool and not has_tool then
            missing_tool = missing_tool or tool
        end

        if spell and silent_can_use(spell.id) and spell_recasts[spell.id] < spell_latency and has_tool then
            windower.chat.input('/ma "'..tiers[k]..'" <me>')
            return
        end
    end

    if missing_tool then
        add_to_chat(123,'Abort: Utsusemi:Ni unusable ('..missing_tool..' not in active inventory), and no lower tier was ready either.')
        if os.clock() - last_missing_tool_ping > 30 then
            last_missing_tool_ping = os.clock()
            windower.chat.input('//findall '..missing_tool)
        end
    else
        add_to_chat(123,'Abort: All Utsusemi tiers on cooldown or unavailable.')
    end
end

function get_ability_recast_id_by_name(name)
	for id, ability in pairs(res.job_abilities) do
		if ability.en == name then
			return ability.recast_id
		end
	end
	return nil
end

-- Haste-tier melee grouping.
function determine_haste_group()
	classes.CustomMeleeGroups:clear()

	if (buffactive['Haste'] and (buffactive['March'] or buffactive['Mighty Guard'])) or
		(buffactive['Haste'] and (buffactive['Geo-Haste'] or buffactive['Embrava'])) or
		(buffactive['March'] == 2 and buffactive['Mighty Guard']) then
		classes.CustomMeleeGroups:append('MaxHaste')
	elseif buffactive['Geo-Haste'] or buffactive['Haste'] or buffactive['March'] == 2 or
		(buffactive['March'] == 1 and buffactive['Mighty Guard']) then
		classes.CustomMeleeGroups:append('Haste_30')
	elseif buffactive['March'] == 1 or buffactive['Mighty Guard'] or buffactive['Haste Samba'] then
		classes.CustomMeleeGroups:append('Haste_15')
	end
end

local haste_related_buffs = S{'haste', 'march', 'mighty guard', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}

-- Amnesia ring swap.
function equip_ecphoria_ring()
	equip({ring2="Ecphoria Ring"})
end

function check_ecphoria_for_ja(spell)
	if spell and spell.type == 'JobAbility' and buffactive['Amnesia'] then
		equip_ecphoria_ring()
	end
end

function user_buff_change(buff, gain, eventArgs)
	if haste_related_buffs:contains(buff:lower()) then
		determine_haste_group()
		if not midaction() then
			handle_equipping_gear(player.status)
		end
	end

	if buff:lower() == 'amnesia' and not gain then
		if not midaction() then
			handle_equipping_gear(player.status)
		end
	end

	soul_devour_buff_change(buff, gain)
end

-- Waltz TP costs.
local waltz_tp_cost = {
	['Curing Waltz'] = 200,
	['Curing Waltz II'] = 350,
	['Curing Waltz III'] = 500,
	['Curing Waltz IV'] = 650,
	['Curing Waltz V'] = 800,
}

local waltz_tiers_asc = {'Curing Waltz', 'Curing Waltz II', 'Curing Waltz III', 'Curing Waltz IV', 'Curing Waltz V'}

local function waltz_ready(tierName)
	local id = get_ability_recast_id_by_name(tierName)
	if not id then return false end
	local abil_recasts = windower.ffxi.get_ability_recasts()
	return abil_recasts[id] and abil_recasts[id] < latency and player.tp >= (waltz_tp_cost[tierName] or 0)
end

local function cast_waltz(tierName, targetId)
	windower.chat.input('/ja "'..tierName..'" '..targetId..'')
end

function handle_smartwaltz(cmdParams)
	if player.sub_job ~= 'DNC' then
		add_to_chat(123,'Abort: Smart Waltz requires /DNC subjob.')
		return
	end

	if not cmdParams[2] and player.hpp >= 75 then
		for i = #waltz_tiers_asc, 1, -1 do
			if waltz_ready(waltz_tiers_asc[i]) then
				cast_waltz(waltz_tiers_asc[i], '<st>')
				return
			end
		end
		add_to_chat(123,'Abort: No Curing Waltz available (recast/TP/unlocked).')
		return
	end

	local cureTarget
	if not cmdParams[2] then
		cureTarget = player
	elseif tonumber(cmdParams[2]) then
		cureTarget = windower.ffxi.get_mob_by_id(tonumber(cmdParams[2]))
	else
		local targetName = table.concat(cmdParams, ' ', 2)
		cureTarget = get_closest_mob_by_name(targetName)
	end

	if not cureTarget or not cureTarget.name then cureTarget = player end

	if cureTarget.type == 'MONSTER' then
		add_to_chat(123,'Abort: Waltzes cannot target monsters.')
		return
	end

	if cureTarget.status == 2 or cureTarget.status == 3 then
		add_to_chat(123,'Abort: Target is down -- Waltzes cannot raise.')
		return
	end

	local missingHP
	if cureTarget.in_alliance then
		cureTarget.hp = find_player_in_alliance(cureTarget.name).hp
		local est_max_hp = cureTarget.hp / (cureTarget.hpp/100)
		missingHP = math.floor(est_max_hp - cureTarget.hp)
	else
		local est_current_hp = 1800 * (cureTarget.hpp/100)
		missingHP = math.floor(1800 - est_current_hp)
	end

	local tid = cureTarget.id

	-- Waltz severity tiers.
	local desiredTier
	if missingHP < 200 then desiredTier = 'Curing Waltz'
	elseif missingHP < 500 then desiredTier = 'Curing Waltz II'
	elseif missingHP < 850 then desiredTier = 'Curing Waltz III'
	elseif missingHP < 1300 then desiredTier = 'Curing Waltz IV'
	else desiredTier = 'Curing Waltz V' end

	-- Reverse Flourish fallback.
	if player.tp < (waltz_tp_cost[desiredTier] or 0) and (state.Buff['Climactic Flourish'] or state.Buff['Building Flourish']) then
		local rf_id = get_ability_recast_id_by_name('Reverse Flourish')
		local abil_recasts = windower.ffxi.get_ability_recasts()
		if rf_id and abil_recasts[rf_id] and abil_recasts[rf_id] < latency then
			windower.chat.input('/ja "Reverse Flourish" <me>')
			local retryArgs = 'smartwaltz'
			if cmdParams[2] then retryArgs = retryArgs..' '..table.concat(cmdParams, ' ', 2) end
			windower.chat.input:schedule(1.5, 'gs c '..retryArgs)
			return
		end
	end

	local startIdx
	for i, t in ipairs(waltz_tiers_asc) do
		if t == desiredTier then startIdx = i break end
	end

	for i = startIdx, 1, -1 do
		if waltz_ready(waltz_tiers_asc[i]) then
			cast_waltz(waltz_tiers_asc[i], tid)
			return
		end
	end

	add_to_chat(123,'Abort: No Curing Waltz available (recast/TP/unlocked).')
end

-- CastingMode/MagicBurstMode.
function is_magic_bursting()
    return state.CastingMode and state.CastingMode.value:contains('MB')
end

function try_magic_burst()
    if not is_magic_bursting() then return end
    if state.CastingMode.value:contains('Resistant') and sets.ResistantMagicBurst then
        equip(sets.ResistantMagicBurst)
    elseif sets.MagicBurst then
        equip(sets.MagicBurst)
    end
end

-- MP recovery threshold.
function should_recover_mp()
    return player.mpp < 75
end

-- Zodiac Ring day swap.
function try_zodiac_ring(spell)
    if not spell.element then return end
    if spell.element ~= world.day_element then return end
    if state.CastingMode.value ~= 'Fodder' and state.CastingMode.value ~= 'Normal' then return end
    if not item_available('Zodiac Ring') then return end

    equip({ring2="Zodiac Ring"})
end

local mage_jobs = S{'WHM','RDM','BLM','GEO','SCH','SMN'}

function try_recover_mp()
    if not mage_jobs:contains(player.main_job) then return end
    if player.main_job == 'SMN' and pet.isvalid then return end
    if not should_recover_mp() then return end
    if state.Buff['Manafont'] or state.Buff['Manawell'] then return end
    if not sets.RecoverMP then return end

    if is_magic_bursting() then
        if state.CastingMode.value:contains('Resistant') and sets.ResistantRecoverBurst then
            equip(sets.ResistantRecoverBurst)
        elseif sets.RecoverBurst then
            equip(sets.RecoverBurst)
        else
            equip(sets.RecoverMP)
        end
    else
        equip(sets.RecoverMP)
    end
end

-- Offense weapon lock.
function try_offense_weapon_lock(stateField, newValue)
    if stateField ~= 'Offense Mode' then return end
    if newValue == 'None' then
        disable('main','sub','range')
    else
        enable('main','sub','range')
    end
end

-- Cure weather helper.
function check_aurorastorm_for_cure(missingHP, cureTarget)
    if not missingHP then return end
    if player.sub_job ~= 'SCH' then return end
    if buffactive['Aurorastorm'] then return end

    -- Self-heal safety.
    if cureTarget == player and player.hpp < 75 then
        add_to_chat(167, 'Aurorastorm is down')
        return
    end

    if missingHP < 400 then
        windower.chat.input('/ma "Aurorastorm" <me>')
    else
        add_to_chat(167, 'Aurorastorm is down')
    end
end

function check_silence(spell, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		if buffactive.mute then
			add_to_chat(123,'Abort: You are muted.')
			eventArgs.cancel = true
			return true
		elseif buffactive.Omerta then
			add_to_chat(123,'Abort: Your magic is restricted.')
			eventArgs.cancel = true
			return true
		elseif buffactive.silence then
			if player.inventory['Echo Drops'] or player.satchel['Echo Drops'] then
				send_command('input /item "Echo Drops" <me>')
			elseif player.inventory["Remedy"] then
				send_command('input /item "Remedy" <me>')
			else
				add_to_chat(123,'Abort: You are silenced.')
			end

			eventArgs.cancel = true
			return true
		else
			return false
		end
	else
		return false
	end
end

-- Global states.
state.AutoLockstyle = M(true, 'AutoLockstyle Mode')
state.CancelStoneskin = M(true, 'Cancel Stone Skin')
state.SkipProcWeapons = M(true, 'Skip Proc Weapons')
state.NotifyBuffs = M(false, 'Notify Buffs')

-- Keyboard bindings.
send_command('bind ^` gs c cycle ElementalMode')
send_command('bind ~^` gs c cycleback ElementalMode')
send_command('bind !@^f7 gs c toggle AutoWSMode')
send_command('bind !^f7 gs c toggle AutoFoodMode')
send_command('bind ^f7 gs c cycle Weapons')
send_command('bind !f7 gs c cycle OffWeapon')
send_command('bind @f8 gs c toggle AutoNukeMode')
send_command('bind ^f8 gs c toggle AutoStunMode')
send_command('bind !f8 gs c toggle AutoDefenseMode')
send_command('bind ^@!f8 gs c toggle AutoTrustMode')
send_command('bind @pause gs c cycle AutoBuffMode')
send_command('bind @scrolllock gs c cycle Passive')
send_command('bind ^!f9 gs c cycle OffenseMode')
send_command('bind ^f9 gs c cycle HybridMode')
send_command('bind @f9 gs c cycle RangedMode')
send_command('bind !f9 gs c cycle WeaponskillMode')
send_command('bind ^!f10 gs c cycle DefenseMode')
send_command('bind ^f10 gs c cycledefensesub')
send_command('bind !f10 gs c toggle Kiting')
send_command('bind !` gs c cycle CastingMode')
send_command('bind !f11 gs c cycle ExtraMeleeMode')
send_command('bind @f12 gs c cycle IdleMode')
send_command('bind ^@!f12 gs reload')
send_command('bind pause gs c update user')
send_command('bind ^@!pause gs org')
send_command('bind ^@!backspace gs c buffup')
send_command('bind ^r gs c weapons Default')
send_command('bind ^z gs c toggle Capacity')
send_command('bind ^y gs c toggle AutoCleanupMode')
send_command('bind ^t gs c cycle treasuremode')
send_command('bind !t input /target <bt>')
send_command('bind ^o fillmode')

NotifyBuffs = S{'doom','petrification'}

-- Bayld items.
bayld_items = {'Tlalpoloani','Macoquetza','Camatlatia','Icoyoca','Tlamini','Suijingiri Kanemitsu',
'Zoquittihuitz','Quauhpilli Helm','Chocaliztli Mask','Xux Hat','Quauhpilli Gloves','Xux Trousers',
'Chocaliztli Boots','Maochinoli','Xiutleato','Hatxiik','Kuakuakait','Azukinagamitsu','Atetepeyorg',
'Kaquljaan','Ajjub Bow','Baqil Staff','Ixtab','Tamaxchi','Otomi Helm','Otomi Gloves','Kaabnax Hat',
'Kaabnax Trousers','Ejekamal Mask','Ejekamal Boots','Quiahuiz Helm','Quiahuiz Trousers','Uk\'uxkaj Cap'}

--[[
List of all Bayld Items.
bayld_items = {'Tlalpoloani','Macoquetza','Camatlatia','Icoyoca','Tlamini','Suijingiri Kanemitsu','Zoquittihuitz',
'Quauhpilli Helm','Chocaliztli Mask','Xux Hat','Quauhpilli Gloves','Xux Trousers','Chocaliztli Boots','Maochinoli',
'Hatxiik','Kuakuakait','Azukinagamitsu','Atetepeyorg','Kaquljaan','Ajjub Bow','Baqil Staff','Ixtab','Otomi Helm',
'Otomi Gloves','Kaabnax Hat','Kaabnax Trousers','Ejekamal Mask','Ejekamal Boots','Quiahuiz Helm','Quiahuiz Trousers',
'Uk\'uxkaj Cap'}
]]