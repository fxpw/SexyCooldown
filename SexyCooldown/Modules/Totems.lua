if select(2, UnitClass("player")) ~= "SHAMAN" then return end

local mod = SexyCooldown:NewModule("Totems", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SexyCooldown")

function mod:OnInitialize()	
	SexyCooldown.RegisterFilter(self, "TOTEM_COOLDOWN",
		L["Totem durations"],
		L["Show my totem durations on this bar"])
end

function mod:OnEnable()
	self:RegisterEvent("PLAYER_TOTEM_UPDATE", "RefreshSlot")
	self:Refresh()
end

local function getTotemID(name, ...)
	for i = 1, select("#", ...) do
		local spell = select(i, ...)
		local spellName = GetSpellInfo(spell)
		if name:match("^" .. spellName) then
			return spell
		end
	end
	return nil
end

local usedSlots = {}
function mod:RefreshSlot(event, slot)
	local haveTotem, name, start, duration, icon = GetTotemInfo(slot);
	
	local uid = "totem:" .. slot .. ":" .. name
	if usedSlots[slot] and usedSlots[slot] ~= uid then
		SexyCooldown:RemoveItem(usedSlots[slot])
	end
	usedSlots[slot] = uid
	if name and name ~= "" then
		local id = getTotemID(name, GetMultiCastTotemSpells(slot))
		if id then
			SexyCooldown:AddItem(uid, name, icon, start, duration, nil, "TOTEM_COOLDOWN", SexyCooldown.SHOW_HYPERLINK, "spell:" .. id)
		end
	else
		SexyCooldown:RemoveItem(uid)
	end
end

function mod:Refresh()
	for i = 1, 4 do
		self:RefreshSlot(nil, i)
	end
end
