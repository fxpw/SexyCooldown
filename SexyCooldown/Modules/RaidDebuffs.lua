local mod = SexyCooldown:NewModule("Raid Debuffs", "AceEvent-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SexyCooldown")

-- We only need one ID per skill - it's translated into a name.
local debuffs = {
	RAID_DEBUFF_MAJOR_ARMOR = {
		35387,		-- Corrosive Spit
		50498,		-- Tear Armor
		8647,		-- Expose Armor
		770,		-- Faerie Fire(Feral)
		7386,		-- Sunder Armor
	},
	RAID_DEBUFF_ATTACK_SPEED = {
		50285,		-- Dust Cloud
		90314,		-- Tail Spin
		8042,		-- Earth Shock
		45477,		-- Icy Touch
		48484,		-- Infected Wounds
		53696,		-- Judgements of the Just
		6343,		-- Thunder Clap
		51696,		-- Waylay
	},
	RAID_DEBUFF_BLEED_DAMAGE = {
		29859,		-- Blood Frenzy
		35290,		-- Gore
		57386,		-- Stampede
		50271, 		-- Tendon Rip
		16511,		-- Hemorrhage
		33876,		-- Mangle	
	},
	RAID_DEBUFF_CAST_SPEED = {
		1714,		-- Curse of Tongues
		58604,		-- Lava Breath
		50274,		-- Spore Cloud
		5761,		-- Mind-Numbing Poison
		73975,		-- Necrotic Strike
		31598,		-- Slow	
	},
	RAID_DEBUFF_HEALING = {
		46910,		-- Furious Attacks
		15313,		-- Improved Mind Blast
		30213,		-- Legion Strike
		54680,		-- Monstrous Bite
		82654,		-- Widow Venom
		12294,		-- Mortal Strike
		13219,		-- Wound Poison
	},
	RAID_DEBUFF_PHYSICAL_DAMAGE = {
		702,		-- Curse of Weakness
		99,			-- Demoralizing Roar
		24423,		-- Demoralizing Screech
		1160,		-- Demoralizing Shout
		81132,		-- Scarlet Fever
		26016,		-- Vindication
	},
	RAID_DEBUFF_PHYSICAL_VULNERABILITY = {
		55749,		-- Acid Spit
		50518,		-- Ravage
		29859,		-- Blood Frenzy
		81328,		-- Brittle Bones
		58413,		-- Savage Combat
	},
	RAID_DEBUFF_SPELL_CRIT_CHANCE = {
		12873,		-- Critical Mass
		17801,		-- Shadow and Flame
	},
	RAID_DEBUFF_SPELL_DAMAGE_TAKEN = {
		1490,		-- Curse of the Elements
		48506,		-- Earth and Moon
		65142,		-- Ebon Plague
		34889,		-- Fire Breath
		24844,		-- Lightning Breath
		58410,		-- Master Poisoner
	}
}
local translatedDebuffs = {}
local classes = {
	RAID_DEBUFF_MAJOR_ARMOR 			= ("|cffe2aa68%s|r"):format(L["Major Armor Debuff"]),
	RAID_DEBUFF_ATTACK_SPEED 			= ("|cffff0000%s|r"):format(L["Attack Speed Debuff"]),
	RAID_DEBUFF_BLEED_DAMAGE 			= ("|cff68d2e2%s|r"):format(L["Bleed Damage"]),
	RAID_DEBUFF_CAST_SPEED 				= ("|cff68d2e2%s|r"):format(L["Cast Speed Debuff"]),
	RAID_DEBUFF_HEALING 				= ("|cff68d2e2%s|r"):format(L["Healing Debuff"]),
	RAID_DEBUFF_PHYSICAL_DAMAGE 		= ("|cff68d2e2%s|r"):format(L["Physical Damage Reduction"]),
	RAID_DEBUFF_PHYSICAL_VULNERABILITY 	= ("|cff68d2e2%s|r"):format(L["Physical Vulnerability"]),
	RAID_DEBUFF_SPELL_CRIT_CHANCE 		= ("|cff68d2e2%s|r"):format(L["Spell Crit Chance"]),
	RAID_DEBUFF_SPELL_DAMAGE_TAKEN 		= ("|cff68d2e2%s|r"):format(L["Spell Damage Taken"]),
}

function mod:OnInitialize()	
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_MAJOR_ARMOR",
		L["Major Armor Debuffs"],
		L["Show the duration of major armor debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_ATTACK_SPEED",
		L["Attack Speed Debuffs"],
		L["Show the duration of attack speed debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_BLEED_DAMAGE",
		L["Bleed Damage Debuffs"],
		L["Show the duration of bleed damage debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_CAST_SPEED",
		L["Cast Speed Debuffs"],
		L["Show the duration of cast speed debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_HEALING",
		L["Healing Debuff"],
		L["Show the duration of -healing debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_PHYSICAL_DAMAGE",
		L["Physical Damage Reduction Debuffs"],
		L["Show the duration of physical damage reduction debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_PHYSICAL_VULNERABILITY",
		L["Physical Vulnerability Debuffs"],
		L["Show the duration of physical vulnerability debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_SPELL_CRIT_CHANCE",
		L["Spell Crit Debuffs"],
		L["Show the duration of spell crit chance debuffs on the target"])
	SexyCooldown.RegisterFilter(self, "RAID_DEBUFF_SPELL_DAMAGE_TAKEN",
		L["Spell Damage Debuffs"],
		L["Show the duration of spell damage debuffs on the target"])
		
	for k, v in pairs(debuffs) do
		for _, spellID in ipairs(v) do
			local name, _, icon = GetSpellInfo(spellID)
			if name then
				translatedDebuffs[name] = k
			end
		end
	end
end

function mod:OnEnable()
	self:RegisterBucketEvent("UNIT_AURA", 0.1, "UNIT_AURA")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "Refresh")
	self:Refresh()
end

function mod:Refresh()
	self:UpdateUnit("target")
end

local function showBuffHyperlink(frame, unit, id, filter, class)
	GameTooltip:SetUnitAura(unit, id, filter)
	GameTooltip:AddLine(class)
end

function mod:UNIT_AURA(units)
	for unit in pairs(units) do
		self:UpdateUnit(unit)
	end
end

do
	local removeBuffs = {}
	local existingBuffs = {}
	local slotDebuffs = {}
	local slotDebuffTimes = {}

	function mod:UpdateUnit(unit)
		if unit ~= "target" then return end
		wipe(removeBuffs)
		for k, v in pairs(existingBuffs) do
			removeBuffs[k] = v
		end
		wipe(existingBuffs)
		wipe(slotDebuffs)
		wipe(slotDebuffTimes)
		
		local index = 1
		while true do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, index, "HARMFUL")
			if not name then break end
			local s = name -- .. ":" .. icon
			local debuffSlot = translatedDebuffs[s]
			if debuffSlot then
				local uid = debuffSlot .. ":" .. s
				if expirationTime > (slotDebuffTimes[debuffSlot] or 0) then
					if slotDebuffs[debuffSlot] then
						local oldUID = slotDebuffs[debuffSlot]
						existingBuffs[oldUID] = nil
						removeBuffs[oldUID] = true
					end
					slotDebuffTimes[debuffSlot] = expirationTime
					slotDebuffs[debuffSlot] = uid
					SexyCooldown:AddItem(uid, name, icon, expirationTime - duration, duration, count, debuffSlot, showBuffHyperlink, unit, index, "HARMFUL", classes[debuffSlot])
					existingBuffs[uid] = true
					removeBuffs[uid] = nil
				end
			end
			index = index + 1
		end
		
		for k, v in pairs(removeBuffs) do
			SexyCooldown:RemoveItem(k)
		end
	end
end
