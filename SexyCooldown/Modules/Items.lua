local mod = SexyCooldown:NewModule("Items", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SexyCooldown")
local LibICD = LibStub("LibInternalCooldowns-1.0")

function mod:OnInitialize()	
	SexyCooldown.RegisterFilter(self, "ITEM_COOLDOWN",
		L["Items"],
		L["Show my item cooldowns on this bar"])
	SexyCooldown.RegisterFilter(self, "INTERNAL_ITEM_COOLDOWN", 
		L["Internal cooldowns"], 
		L["Show internal cooldowns for my items and enchants on this bar."])
end

function mod:OnEnable()
	self:RegisterEvent("BAG_UPDATE_COOLDOWN", "Refresh")
	LibICD.RegisterCallback(self, "InternalCooldowns_Proc")
	self:Refresh()
end

function mod:InternalCooldowns_Proc(callback, itemID, spellID, start, duration)
	local texture = select(10, GetItemInfo(itemID))
	local name = GetItemInfo(itemID)
	local uid = ("%s:%d"):format("spell", spellID)
	SexyCooldown:AddItem(uid, name, texture, start, duration, nil, "INTERNAL_ITEM_COOLDOWN", SexyCooldown.SHOW_HYPERLINK, "item:" .. itemID)
end

function mod:Refresh()
	for i = 1, 18 do
		local start, duration, active = GetInventoryItemCooldown("player", i)
		if active == 1 and start > 0 and duration > 3 then
			local link = GetInventoryItemLink("player",i)
			if link then
				local id = link:match("item:(%d+)")
				local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(id)
				local filter = LibICD:IsInternalItemCooldown(id) and "INTERNAL_ITEM_COOLDOWN" or "ITEM_COOLDOWN"				
				local uid = "item:" .. id
				
				SexyCooldown:AddItem(uid, name, texture, start, duration, nil, filter, SexyCooldown.SHOW_HYPERLINK, uid)
			end
		end
	end
	for i = 0, 4 do
		local slots = GetContainerNumSlots(i)
		for j = 1, slots do
			local start, duration, active = GetContainerItemCooldown(i,j)
			if active == 1 and start > 0 and duration > 3 then
				local link = GetContainerItemLink(i,j)
				if link then
					local id = link:match("item:(%d+)")
					local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(id)
					local filter = LibICD:IsInternalItemCooldown(id) and "INTERNAL_ITEM_COOLDOWN" or "ITEM_COOLDOWN"				
					local uid = "item:" .. id
					SexyCooldown:AddItem(uid, name, texture, start, duration, nil, filter, SexyCooldown.SHOW_HYPERLINK, uid)
				end
			end
		end
	end
end