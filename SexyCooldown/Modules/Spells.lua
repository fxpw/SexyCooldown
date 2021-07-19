local mod = SexyCooldown:NewModule("Spells", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SexyCooldown")
local LibICD = LibStub("LibInternalCooldowns-1.0")

local aniFrame = CreateFrame("Frame")
local spells = { PLAYER = {}, PET = {} }
local lastPlayerSpell, lastPetSpell = {}, {}

local function cacheSpellsForBook(t, book)
	wipe(t)
	for i = 1, 500 do
		local name = GetSpellName(i, book)
		if name then
			local link = GetSpellLink(i, book)
			if link then
				local id = tonumber(link:match("spell:(%d+)"))
				if id and id > 0 then
					t[name] = id
				end
			end
		end
	end
end

function mod:OnInitialize()	
	SexyCooldown.RegisterFilter(self, "SPELL_COOLDOWN",
		L["My spells"],
		L["Show my spell cooldowns on this bar"])
	SexyCooldown.RegisterFilter(self, "PET_SPELL_COOLDOWN", 
		L["Pet spells"], 
		L["Show my pet's cooldowns on this bar"])
	SexyCooldown.RegisterFilter(self, "INTERNAL_SPELL_COOLDOWN", 
		L["Internal cooldowns"], 
		L["Show internal cooldowns for my spells and talents on this bar."])
		
	
	-- This is a hack, but use the Blizzard animation system as a delay timer, so that we don't have to handle Yet Another OnUpdate!
	-- This works like a tri-state system - off, start, finish - so that we can test cooldowns both immediately and on a delay, so that
	-- we get fast visual feedback, but still handle cooldown resets like Readiness and the Guardian Spirit glyph.
	aniFrame.timer = aniFrame:CreateAnimationGroup()
	
	-- This first animation introduces a slight delay, effectively causing us to bucket events on a 0.1 sec granularity.
	aniFrame[1] = aniFrame.timer:CreateAnimation()
	aniFrame[1]:SetDuration(0.1)
	
	-- The second animation functions as our throttled OnUpdate/delayed OnUpdate.
	aniFrame[2] = aniFrame.timer:CreateAnimation()
	aniFrame[2]:SetDuration(0)
	aniFrame[2]:SetOrder(2)
	aniFrame[2]:SetStartDelay(0.75)
	aniFrame[2]:SetScript("OnPlay", function()
		mod:Refresh()
	end)
	aniFrame[2]:SetScript("OnFinished", function()
		mod:CleanupCooldowns()
	end)
end

function mod:OnEnable()
	self:CacheSpells()
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("SPELLS_CHANGED", "CacheSpells")	
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")	
	LibICD.RegisterCallback(self, "InternalCooldowns_TalentProc")	
	self:Refresh()
end

function mod:InternalCooldowns_TalentProc(callback, spellID, start, duration)
	local name, _, icon = GetSpellInfo(spellID)
	local uid = ("%s:%d"):format("spell", spellID)
	SexyCooldown:AddItem(uid, name, icon, start, duration, nil, "INTERNAL_SPELL_COOLDOWN", SexyCooldown.SHOW_HYPERLINK, "spell:" .. spellID)	
end

function mod:UNIT_SPELLCAST_FAILED(event, unit, spell, rank)
	if unit == "player" and spells.PLAYER[spell] then
		SexyCooldown:CastFailure("spell:" .. spells.PLAYER[spell])
	elseif unit == "pet" and spells.PET[spell] then
		SexyCooldown:CastFailure("spell:" .. spells.PET[spell])
	end
end

function mod:SPELL_UPDATE_COOLDOWN()
	-- This causes the animation to effectively work like a bucket; granularity is the animation's start delay.
	if aniFrame.timer:IsPlaying() then aniFrame.timer:Stop() end
	aniFrame.timer:Play()
end

function mod:UNIT_SPELLCAST_SUCCEEDED(event, unit, spell)
	if unit == "player" then
		tinsert(lastPlayerSpell, 1, spell)
		if #lastPlayerSpell > 3 then tremove(lastPlayerSpell) end
	elseif unit == "pet" then
		tinsert(lastPetSpell, 1, spell)
		if #lastPetSpell > 3 then tremove(lastPetSpell) end
	end
end

function mod:Refresh()
	mod:UpdateSpellCooldowns(lastPlayerSpell, spells.PLAYER, "SPELL_COOLDOWN")
	if HasPetUI() then
		mod:UpdateSpellCooldowns(lastPetSpell, spells.PET, "PET_SPELL_COOLDOWN")
	end		
end

function mod:CleanupCooldowns()
	mod:CleanupSpellCooldowns(lastPlayerSpell, spells.PLAYER, "SPELL_COOLDOWN")
	if HasPetUI() then
		mod:CleanupSpellCooldowns(lastPetSpell, spells.PET, "PET_SPELL_COOLDOWN")
	end		
end

local function getID(name)
	local link = GetSpellLink(name)
	if link then
		return link:match("spell:(%d+)")
	end
	return nil
end

function mod:UpdateSpellCooldowns(spellQueue, spellSet, filter)
	local start, duration, active, id
	local added = false
	
	for _, name in ipairs(spellQueue) do
		start, duration, active = GetSpellCooldown(name)
		if active == 1 and start > 0 and duration > 3 then
			local name, _, icon = GetSpellInfo(name)
			local id = spellSet[name] or getID(name)
			local uid = "spell:" .. id
			SexyCooldown:AddItem(uid, name, icon, start, duration, nil, filter, SexyCooldown.SHOW_HYPERLINK, uid)
			added = true
		end
	end

	if not added then
		for name, id in pairs(spellSet) do
			start, duration, active = GetSpellCooldown(name)
			if active == 1 and start > 0 and duration > 3 then
				local name, _, icon = GetSpellInfo(name)
				local id = spellSet[name] or getID(name)
				local uid = "spell:" .. id
				SexyCooldown:AddItem(uid, name, icon, start, duration, nil, filter, SexyCooldown.SHOW_HYPERLINK, uid)
			end
		end
	end
end

function mod:CleanupSpellCooldowns(spellQueue, spellSet, filter)
	for name, id in pairs(spellSet) do
		local start, duration, active = GetSpellCooldown(name)
		if start == 0 then
			SexyCooldown:RemoveItem("spell:" .. id)
		end
	end
end

function mod:CacheSpells()
	cacheSpellsForBook(spells.PLAYER, BOOKTYPE_SPELL)
	cacheSpellsForBook(spells.PET, BOOKTYPE_PET)
end
