local L = LibStub("AceLocale-3.0"):GetLocale("SexyCooldown")
local ACD3 = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local mod = SexyCooldown
local _G = getfenv(0)

CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}

local GetInventoryItemCooldown = _G.GetInventoryItemCooldown
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetContainerItemCooldown = _G.GetContainerItemCooldown
local GetContainerItemLink = _G.GetContainerItemLink
local GetSpellCooldown = _G.GetSpellCooldown

local pairs, ipairs, next = _G.pairs, _G.ipairs, _G.next
local tremove, tinsert = _G.tremove, _G.tinsert
local type, rawset, rawget = _G.type, _G.rawset, _G.rawget

local defaults = {
	profile = {
		bars = {}
	}
}
local frames = {}

local options = {
	type = "group",
	inline = true,
	childGroups = "tab",
	args = {
		defaultArgs = {
			type = "group",
			name = "Default Args",
			guiHidden = true,
			args = {
				instructions = {
					type = "description",
					name = L["Select an options sub-category to get started."]
				}
			}
		},
		bars = {
			type = "group",
			childGroups = "select",
			name = L["Bars"],
			args = {
				createBar = {
					type = "execute",
					name = L["Create new bar"],
					func = function()
						local bar = mod:CreateBar()
						mod:ShowBarOptions(bar)
					end,
					order = 101
				},
			}
		},
	}
}

local function deepcopy(from)
	local to = {}
	for k,v in pairs(from) do
		if type(v) == "table" then
			to[k] = deepcopy(v)
		else
			to[k] = v
		end
	end
	return to
end
mod.deepcopy = deepcopy

local configFrame

local function isSlashCommandRegistered(command)
	for k, v in pairs(SlashCmdList) do
		for i = 1, 3 do
			if _G["SLASH_" .. k .. i] == command then
				return true
			end
		end
	end
	return false
end

function mod:OnInitialize()
	-- self:UpdateBarDB()
	
	self.db = LibStub("AceDB-3.0"):New("SexyCooldownDB", defaults)
	self.db.global.dbVersion = 3
	
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SexyCooldown", options)
	
	ACD3:AddToBlizOptions("SexyCooldown", nil, nil, "defaultArgs")
	configFrame = ACD3:AddToBlizOptions("SexyCooldown", L["Bars"], "SexyCooldown", "bars")
	ACD3:AddToBlizOptions("SexyCooldown", L["Profiles"], "SexyCooldown", "profiles")
	self:Setup()
	self.bars = frames
	
	if not isSlashCommandRegistered("/scd") then
		self:RegisterChatCommand("scd", "Config")
	end
	self:RegisterChatCommand("sexycd", "Config")
	self:RegisterChatCommand("sexycooldown", "Config")
	self:RegisterChatCommand("sexycooldowns", "Config")
end

function mod:Config(bar)
	InterfaceOptionsFrame:Hide()
	ACD3:SetDefaultSize("SexyCooldown", 680, 550)
	ACD3:Open("SexyCooldown")
	if bar then
		self:ShowBarOptions(bar)
	end
end

function mod:ShowBarOptions(bar)
	ACD3:SelectGroup("SexyCooldown", "bars", bar.optionsKey)
end

function mod:OnEnable()	
	self.db.RegisterCallback(self, "OnProfileChanged", "ReloadAddon")
	self.db.RegisterCallback(self, "OnProfileCopied", "ReloadAddon")
	self.db.RegisterCallback(self, "OnProfileReset", "ReloadAddon")
end

local oldframes = {}
function mod:ReloadAddon()
	for _, v in ipairs(frames) do
		local frame = tremove(frames)
		frame:Expire()
		tinsert(oldframes, frame)
	end
	
	self:Setup()
	self:Refresh()
end

local filterToMod = {}
local filterOrders = {}
function mod.RegisterFilter(module, filter, name, description)
	filterToMod[filter] = module
	local modname = module:GetName():gsub(" ", "_")
	filterOrders[modname] = (filterOrders[modname] or 0) + 1
	
	mod.eventArgs[modname] = mod.eventArgs[modname] or {
		type = "group",
		inline = true,
		name = module:GetName(),
		args = {}
	}
	mod.eventArgs[modname].args[filter] = {
		type = "toggle",
		name = name,
		desc = description,
		order = filterOrders[modname]
	}
	
	mod.eventColors[modname] = mod.eventColors[modname] or {
		type = "group",
		inline = true,
		name = module:GetName(),
		args = {
			reset = {
				type = "execute",
				name = L["Reset to defaults"],
				desc = L["Reset all colors in this group to the icon defaults"],
				width = "full",
				func = "resetColors",
				order = 999
			}
		}
	}
	
	mod.eventColors[modname].args[filter] = {
		type = "color",
		name = name,
		desc = description,
		order = filterOrders[modname] * 2,
	}
end

do
	local filterRegistrations = {}
	local activeFilters = {}
	local function updateFilterActive(filter)
		activeFilters[filter] = next(filterRegistrations[filter]) and 1 or 0
	end

	function mod:RegisterBarForFilter(bar, filter)
		filterRegistrations[filter] = filterRegistrations[filter] or {}
		filterRegistrations[filter][bar] = true
		updateFilterActive(filter)
	end

	function mod:UnregisterBarForFilter(bar, filter)
		if filterRegistrations[filter] then
			filterRegistrations[filter][bar] = nil
			updateFilterActive(filter)
		end
	end

	function mod:IsFilterRegistered(filter)
		return activeFilters[filter] and activeFilters[filter] > 0
	end
end

-- For 0.6.2 to 0.6.3
function mod:UpdateBarDB()
	if not SexyCooldownDB then return end
	if not SexyCooldownDB.global or not SexyCooldownDB.global.dbVersion or SexyCooldownDB.global.dbVersion < 2 then
		if SexyCooldownDB.namespaces then
			for namespace, settings in pairs(SexyCooldownDB.namespaces) do
				for profile, key in pairs(settings.profileKeys) do
					local barSettings = settings.profiles[key]
					if #SexyCooldownDB.profiles[key].bars == 0 then
						SexyCooldownDB.profiles[key].bars = {}
					end
					tinsert(SexyCooldownDB.profiles[key].bars, barSettings)
				end
			end
		end
		for profile, settings in pairs(SexyCooldownDB.profiles) do
			settings.barSerial = nil
		end
		SexyCooldownDB.namespaces = nil
		SexyCooldownDB.global = SexyCooldownDB.global or {}
		SexyCooldownDB.global.dbVersion = 2
	end	
end

local function bindToMetaTable(toBind, bindTo)
	for k, v in pairs(toBind) do
		if type(v) == "table" and bindTo[k] then
			bindToMetaTable(v, bindTo[k])
		end
	end
	
	return setmetatable(toBind, {__index = function(t, k)
		if type(bindTo[k]) == "table" then
			rawset(t, k, bindToMetaTable({}, bindTo[k]))
			return rawget(t, k)
		else
			return bindTo[k]
		end
	end})
end

function mod:CloneSettings(settings)
	return bindToMetaTable(deepcopy(settings), self.barDefaults)
end

local usedNames = {}
local barOptionsCount = 0
function mod:CreateBar(settings, defaultName)
	settings = settings or {}
	bindToMetaTable(settings, self.barDefaults)
	
	local name = settings.bar.name or defaultName
	if not name then
		name = "Bar " .. (#self.db.profile.bars)
	end
	
	local frameName = "SexyCooldown" .. name
	while usedNames[frameName] do
		frameName = frameName .. ".1"
	end
	usedNames[frameName] = true
	local frame = setmetatable(CreateFrame("Frame", frameName, UIParent), self.barMeta)
	
	local existing = false
	for k, v in ipairs(self.db.profile.bars) do
		if v == settings then
			existing = true
			break
		end
	end
	if not existing then
		tinsert(self.db.profile.bars, settings)
		-- self.db:RegisterDefaults(defaults)
	end	
	
	settings.bar.name = name
	
	frame.settings = settings
	frame.optionsTable = self:GetOptionsTable(frame)
	frame.optionsKey = "baroptions" .. barOptionsCount
	options.args.bars.args[frame.optionsKey] = frame.optionsTable
	barOptionsCount = barOptionsCount + 1
	frame:Init()
	tinsert(frames, frame)
	return frame
end

function mod:UpdateFrameName(frame)
	frame.optionsTable.name = frame.settings.bar.name
	self:ShowBarOptions(frame)
	ACD3:ConfigTableChanged(nil, "SexyCooldown")
end

-- FIXME
function mod:DestroyBar(frame)
	for k, v in ipairs(self.db.profile.bars) do
		if frame.settings == v then
			tremove(self.db.profile.bars, k)
		end
	end
	options.args.bars.args[frame.optionsKey] = nil
	
	for k, v in ipairs(frames) do
		self:ShowBarOptions(v)
		break
	end
	ACD3:ConfigTableChanged(nil, "SexyCooldown")
	frame:Expire()
end

function mod:Setup()
	for k, v in ipairs(self.db.profile.bars) do
		self:CreateBar(v, "Bar " .. k)
	end
	if #self.db.profile.bars == 0 then
		self:CreateBar()
	end
end

function mod:Refresh(filter)
	if filter then
		if filterToMod[filter].Refresh then
			filterToMod[filter]:Refresh()
		end
	else
		for k, v in self:IterateModules() do
			if v.Refresh then v:Refresh() end
		end
	end
end

function mod:AddItem(uid, name, icon, start, duration, stacks, filter, callback, ...)
	for _, frame in ipairs(frames) do
		frame:CreateCooldown(uid, name, icon, start, duration, stacks, filter, callback, ...)
	end
end

function mod:RemoveItem(uid)
	for _, frame in ipairs(frames) do
		frame:ExpireCooldown(uid)
	end
end

function mod:CastFailure(uid)
	for _, frame in ipairs(frames) do
		frame:CastFailure(uid)
	end
end

function mod.SHOW_HYPERLINK(frame, link)
	if link then
		GameTooltip:SetHyperlink(link)
	end
end

CONFIGMODE_CALLBACKS.SexyCooldown = function(action)
	if action == "ON" then
		mod.overrideLocks = true
	elseif action == "OFF" then
		mod.overrideLocks = false
	end
	for k, v in ipairs(frames) do
		v:UpdateLook()
	end
end
