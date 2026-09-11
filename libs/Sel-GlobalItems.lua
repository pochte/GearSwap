--------------------------------------------------------------------------------------------------------------------------------------------
-- Universal items that are the same for all characters, and logic to determine if some specific items are owned and used.
if not sets.Reive then
	if item_owned("Adoulin's Refuge +1") then
		sets.Reive = {neck="Adoulin's Refuge +1"}
	elseif item_owned("Arciela's Grace +1") then
		sets.Reive = {neck="Arciela's Grace +1"}
	elseif item_owned("Ygnas's Resolve +1") then
		sets.Reive = {neck="Ygnas's Resolve +1"}
	else
		sets.Reive = {}
	end
end

uses_waltz_legs = false
if sets.precast.Waltz and sets.precast.Waltz.legs then
	waltz_legs = standardize_set(sets.precast.Waltz).legs
	if (waltz_legs == "Desultor Tassets" or waltz_legs == "Blitzer Poleyn" or waltz_legs == "Tatsumaki Sitagoromo") then
		uses_waltz_legs	= true
	end
end