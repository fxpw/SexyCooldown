local mod = SexyCooldown
local LSM = LibStub("LibSharedMedia-3.0")

local math_min, math_abs, math_pow, math_floor, math_fmod = _G.math.min, _G.math.abs, _G.math.pow, _G.math.floor, _G.math.fmod
local string_format = _G.string.format
local GetTime = _G.GetTime
local dummyFrame = CreateFrame("Frame")
local cooldownPrototype = setmetatable({}, {__index = dummyFrame})
local cooldownMeta = {__index = cooldownPrototype}
local barPrototype = setmetatable({}, {__index = dummyFrame})
local pairs, ipairs, next = _G.pairs, _G.ipairs, _G.next
local tremove, tinsert = _G.tremove, _G.tinsert

mod.barMeta = {__index = barPrototype}

local framePool = {}
local stringPool = {}
local updateFrames = {}

local function getPos(val, valMax, base)
	local r = math_pow(val, base) / math_pow(valMax, base)
	return r > 1 and 1 or r	
end

local function getAnchorOffset(anchor, x, y)
	if anchor:match("TOP") then
		y = -y
	elseif anchor:match("BOTTOM") then
		y = y
	else
		y = 0
	end
	
	if anchor:match("LEFT") then
		x = x
	elseif anchor:match("RIGHT") then
		x = -x
	else
		x = 0
	end
	return x, y
end

local delta = 0
local throttle = 1 / 30
local runOnUpdates = function(self, t)
	delta = delta + t
	if delta < throttle then return end
	delta = delta - throttle
	for k, v in pairs(updateFrames) do
		for _, frame in ipairs(k.usedFrames) do		
			frame:UpdateTime()
		end
	end
end

local function activateFrame(frame)
	updateFrames[frame] = true
	dummyFrame:SetScript("OnUpdate", runOnUpdates)
end

local function deactivateFrame(frame)
	updateFrames[frame] = nil
	if not next(updateFrames) then
		dummyFrame:SetScript("OnUpdate", nil)
	end
end

local function getAnchorSide(self)
	local o = self.settings.bar.orientation
	return 	o == "LEFT_TO_RIGHT" and "LEFT" or
			o == "RIGHT_TO_LEFT" and "RIGHT" or
			o == "BOTTOM_TO_TOP" and "TOP" or
			o == "TOP_TO_BOTTOM" and "BOTTOM"
end

------------------------------------------------------
-- Bar prototype
------------------------------------------------------

function barPrototype:Init()
	self:SetFrameStrata("LOW")
	self.usedFrames = {}
	self.cooldowns = {}
	self.durations = {}
	
	-- self.animationTimer = self:CreateAnimationGroup()
	-- self.animationTimerScript = self:CreateAnimation()
	
	for k, v in pairs(mod.barDefaults.events) do
		if self.settings.events[k] == nil and v then
			mod:RegisterBarForFilter(self, k)
		end
	end
	
	for k, v in pairs(self.settings.events) do
		if v then
			mod:RegisterBarForFilter(self, k)
		end
	end
	
	self:SetBackdrop(mod.backdrop)
	if not self.settings.bar.x then
		self.settings.bar.x, self.settings.bar.y = self.settings.x, self.settings.y
	end
	
	self:SetScript("OnMouseDown", function(self)
		if not self.settings.bar.lock or mod.overrideLocks then
			self:StartMoving()
		end
	end)
	self:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing()
		local x, y = self:GetCenter()
		local ox, oy = UIParent:GetCenter()
		local nx, ny = x - ox, y - oy
		local xdiff, ydiff = math_abs(nx - self.settings.bar.x), math_abs(ny - self.settings.bar.y)
		if xdiff > 1 or ydiff > 1 then
			self.settings.bar.x = nx
			self.settings.bar.y = ny
		elseif button == "RightButton" then
			self:OpenConfig()
		end
	end)
	self:SetScript("OnSizeChanged", function()
		self.settings.bar.width = self:GetLength()
		self.settings.bar.height = self:GetDepth()
		self:UpdateLook()
	end)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:SetResizable(true)
	self:SetMinResize(20, 10)
	
	local grip = CreateFrame("Frame", nil, self)
	grip:EnableMouse(true)
	local tex = grip.tex or grip:CreateTexture()
	grip.tex = tex
	tex:SetTexture([[Interface\BUTTONS\UI-AutoCastableOverlay]])
	tex:SetTexCoord(0.619, 0.760, 0.612, 0.762)
	tex:SetDesaturated(true)
	tex:ClearAllPoints()
	tex:SetAllPoints()

	grip:SetWidth(6)
	grip:SetHeight(6)
	grip:SetScript("OnMouseDown", function(self)
		self:GetParent():StartSizing()
	end)
	grip:SetScript("OnMouseUp", function(self)
		self:GetParent():StopMovingOrSizing()
		self:GetParent().settings.bar.width = self:GetParent():GetLength()
		self:GetParent().settings.bar.height = self:GetParent():GetDepth()
	end)

	grip:ClearAllPoints()
	grip:SetPoint("BOTTOMRIGHT")
	grip:SetScript("OnEnter", function(self)
		self.tex:SetDesaturated(false)
	end)
	grip:SetScript("OnLeave", function(self)
		self.tex:SetDesaturated(true)
	end)
	self.grip = grip
	
	self.fade = self:CreateAnimationGroup()
	self.fadeAlpha = self.fade:CreateAnimation()

	self.fadeAlpha.parent = self
	self.fadeAlpha:SetScript("OnPlay", function(self)
		self.startAlpha = self.parent:GetAlpha()
		if self.parent.active then
			self.endAlpha = 1
		else
			self.endAlpha = self.parent.settings.bar.inactiveAlpha
		end
	end)
	self.fadeAlpha:SetScript("OnUpdate", function(self)		
		local new = self.startAlpha + ((self.endAlpha - self.startAlpha) * self:GetProgress())
		self.parent:SetAlpha(new)
	end)	
	
	
	local backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		insets = {left = 2, top = 2, right = 2, bottom = 2},
		edgeSize = 8,
		tile = false		
	}		
	
	-- Anchor to control where icon ready splashes appear
	self.splashAnchor = CreateFrame("Frame", nil, UIParent)
	
	self.splashAnchor:SetBackdrop(backdrop)
	self.splashAnchor:SetBackdropColor(0, 1, 0, 1)
	self.splashAnchor:SetWidth(35)
	self.splashAnchor:SetHeight(35)
	self.splashAnchor:EnableMouse(true)	
	self.splashAnchor:SetMovable(true)	
	self.splashAnchor:SetScript("OnMouseDown", function(self)
		self:StartMoving()
	end)
	self.splashAnchor:SetScript("OnMouseUp", function(mover)
		mover:StopMovingOrSizing()
		self.settings.bar.splash_x, self.settings.bar.splash_y = mover:GetCenter()
	end)
	local close = CreateFrame("Button", nil, self.splashAnchor, "UIPanelCloseButton")
	close:SetWidth(14)
	close:SetHeight(14)
	close:SetPoint("TOPRIGHT", self.splashAnchor, "TOPRIGHT", -1, -1)
	close:SetScript("OnClick", function(self)
		self:GetParent():lock(true)
	end)
	self.splashAnchor.close = close;
	
	self.splashAnchor.lock = function(self, lock, override)
		if lock ~= nil then
			self.locked = lock
		end
		if lock and not override then
			self.close:Hide()
			self:EnableMouse(false)
			self:SetBackdropColor(0,0,0,0)
		else
			self.close:Show()
			self:EnableMouse(true)
			self:SetBackdropColor(0,1,0,1)
		end
	end
	self.splashAnchor:lock(true)
	
	self:UpdateBarLook()
end

function barPrototype:OpenConfig()
	mod:Config(self)
end

function barPrototype:Vertical()
	local vert = (self.settings.bar.orientation == "BOTTOM_TO_TOP" or self.settings.bar.orientation == "TOP_TO_BOTTOM")
	return vert
end

function barPrototype:Reversed()
	return self.settings.bar.orientation == "RIGHT_TO_LEFT" or self.settings.bar.orientation == "BOTTOM_TO_TOP"
end

function barPrototype:GetLength()
	return self:Vertical() and self:GetHeight() or self:GetWidth()
end

function barPrototype:GetDepth()
	return self:Vertical() and self:GetWidth() or self:GetHeight()
end

do
	local framelevelSerial = 10
	
	local backdrop = {
		edgeFile = [[Interface\GLUES\COMMON\TextPanel-Border.blp]],
		insets = {left = 2, top = 2, right = 2, bottom = 2},
		edgeSize = 8,
		tile = false		
	}	
	function barPrototype:UpdateSingleIconLook(icon)
		backdrop.edgeFile = LSM:Fetch("border", self.settings.icon.border) or backdrop.edgeFile
		backdrop.edgeSize = self.settings.icon.borderSize or backdrop.edgeSize
		
		icon:SetClampedToScreen(self.settings.icon.clamp)
		icon.tex:SetPoint("TOPLEFT", icon, "TOPLEFT", self.settings.icon.borderInset, -self.settings.icon.borderInset)
		icon.tex:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -self.settings.icon.borderInset, self.settings.icon.borderInset)
		icon.overlay.tex:SetPoint("TOPLEFT", icon.overlay, "TOPLEFT", self.settings.icon.borderInset, -self.settings.icon.borderInset)
		icon.overlay.tex:SetPoint("BOTTOMRIGHT", icon.overlay, "BOTTOMRIGHT", -self.settings.icon.borderInset, self.settings.icon.borderInset)
		
		icon:SetBackdrop(backdrop)
		icon.overlay:SetBackdrop(backdrop)
		
		local c = icon.filter and self.settings.eventColors[icon.filter] or self.settings.icon.borderColor
		icon:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		icon.overlay:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		
		self:UpdateLabel(icon.fs, self.settings.icon)
		self:UpdateLabel(icon.overlay.fs, self.settings.icon)
		self:UpdateLabel(icon.stacks, self.settings.icon)
		self:UpdateLabel(icon.overlay.stacks, self.settings.icon)
		
		icon:SetWidth(self:GetDepth() + self.settings.icon.sizeOffset)
		icon:SetHeight(self:GetDepth() + self.settings.icon.sizeOffset)		
		
		icon.overlay:SetWidth(icon:GetWidth())
		icon.overlay:SetHeight(icon:GetHeight())
		
		local xoff, yoff
		xoff, yoff = getAnchorOffset(self.settings.icon.stacksAnchor, self.settings.icon.stacksOffset, self.settings.icon.stacksOffset)
		icon.stacks:ClearAllPoints()
		icon.overlay.stacks:ClearAllPoints()
		icon.stacks:SetPoint(self.settings.icon.stacksAnchor, icon, self.settings.icon.stacksAnchor, xoff, yoff)
		icon.overlay.stacks:SetPoint(self.settings.icon.stacksAnchor, icon.overlay, self.settings.icon.stacksAnchor, xoff, yoff)

		xoff, yoff = getAnchorOffset(self.settings.icon.timeAnchor, self.settings.icon.timeOffset, self.settings.icon.timeOffset)
		icon.fs:ClearAllPoints()
		icon.overlay.fs:ClearAllPoints()
		icon.fs:SetPoint(self.settings.icon.timeAnchor, icon, self.settings.icon.timeAnchor, xoff, yoff)
		icon.overlay.fs:SetPoint(self.settings.icon.timeAnchor, icon.overlay, self.settings.icon.timeAnchor, xoff, yoff)
		
		icon.pulseAlpha:SetDuration(self.settings.icon.pulseSpeed)
		icon.pulseAlpha:SetEndDelay(self.settings.icon.pulseSpeed)
		icon.pulseAlpha:SetStartDelay(self.settings.icon.pulseSpeed)		
		
		if self.settings.icon.showText then
			icon.fs:Show()
			icon.overlay.fs:Show()
		else
			icon.fs:Hide()
			icon.overlay.fs:Hide()
		end
		
		if self.settings.icon.showStacks then
			icon.stacks:Show()
			icon.overlay.stacks:Show()
		else
			icon.stacks:Hide()
			icon.overlay.stacks:Hide()
		end
		
		-- icon.finishScale.maxScale = self.settings.icon.splashScale
		-- icon.finishScale:SetScale(self.settings.icon.splashScale, self.settings.icon.splashScale)
		-- icon.finishScale:SetDuration(self.settings.icon.splashSpeed)
		icon.finishAlpha:SetDuration(self.settings.icon.splashSpeed * 1.2)
		
		if self.settings.icon.disableMouse then
			icon.overlay:EnableMouse(false)
		else
			icon.overlay:EnableMouse(true)
		end
	end
	
	local function onClick(self, button)
		if button == "RightButton" then
			if IsModifierKeyDown() then
				self.icon:Blacklist()
			else
				self.icon:Cancel()
			end
		end
	end
	
	function barPrototype:Activate()
		if self.active then return end
		self.active = true		
		local alpha = self:GetAlpha()
		if alpha ~= 1 then
			self.fade:Stop()
			self.fadeAlpha:SetDuration(0.3)
			self.fade:Play()
		end
	end
	
	function barPrototype:Deactivate()
		if not self.active then return end
		self.active = false
		local alpha = self:GetAlpha()
		if alpha ~= self.settings.bar.inactiveAlpha then
			self.fade:Stop()
			self.fadeAlpha:SetDuration(0.33)
			self.fade:Play()
		end
		deactivateFrame(self)
	end
	
	function barPrototype:CreateNewCooldownFrame()
		local f = setmetatable(CreateFrame("Frame"), cooldownMeta)
		
		f.tex = f:CreateTexture(nil, "ARTWORK")

		f.overlay = CreateFrame("Frame", nil, f)
		f.overlay:SetPoint("CENTER")
		-- f.overlay:SetPoint("TOPLEFT")		
		-- f.overlay:SetPoint("BOTTOMRIGHT")
		
		f.overlay.icon = f
		f.overlay.tex = f.overlay:CreateTexture(nil, "ARTWORK")
		
		f.stacks = f:CreateFontString(nil, nil, "SystemFont_Outline_Small")
		
		f.fs = f:CreateFontString(nil, nil, "SystemFont_Outline_Small")
		
		f.overlay.stacks = f.overlay:CreateFontString(nil, nil, "SystemFont_Outline_Small")
		f.overlay.fs = f.overlay:CreateFontString(nil, nil, "SystemFont_Outline_Small")
		
		f.overlay:SetScript("OnEnter", f.ShowTooltip)
		f.overlay:SetScript("OnLeave", f.HideTooltip)
		f.overlay:SetScript("OnMouseUp", onClick)
		
		f.finish = f:CreateAnimationGroup()
		f.finishAlpha = f.finish:CreateAnimation("Alpha")
		f.finishAlpha:SetChange(-1)
		
		-- f.finishScale = f.finish:CreateAnimation("Scale")		
		f.finish:SetScript("OnPlay", function()
			f:SetParent(self.splashAnchor)
			f:ClearAllPoints()
			f:SetPoint("CENTER", f.parent.splashAnchor, "CENTER", 0, 0)
			f.overlay:EnableMouse(false)
			
			f.overlay:Hide()
			f.fs:Hide()
		end)
		f.finish:SetScript("OnUpdate", function(animation)
			local p = animation:GetProgress()
			f:SetScale(1 + (self.settings.icon.splashScale - 1) * p)
		end)
		f.finish:SetScript("OnFinished", function()
			if not self.settings.icon.disableTooltip then
				f:EnableMouse(true)
			end
			f:Hide()
			f:SetScale(1)
			f:SetParent(self)
			f.fs:Show()
			f.overlay:Show()
		end)
		f.finish:SetScript("OnStop", f.finish:GetScript("OnFinished"))
		
		f.pulse = f.overlay:CreateAnimationGroup()
		f.pulse:SetLooping("BOUNCE")
		f.pulseAlpha = f.pulse:CreateAnimation("Alpha")
		f.pulseAlpha:SetChange(-1)
		f.pulse:SetScript("OnUpdate", function(self)
			local s, p = f.pulse:GetLoopState(), self:GetProgress()
			if s == "FORWARD" and p >= 0.5 then
				f.overlay:EnableMouse(false)
			elseif s == "REVERSE" and p >= 0.5 then
				f.overlay:EnableMouse(not f.parent.settings.disableMouse)
			end
		end)
		f.pulse:SetScript("OnStop", function(self)
			f.overlay:EnableMouse(not f.parent.settings.disableMouse)
		end)
		
		local throbScale = 0.5
		f.throb = f.overlay:CreateAnimationGroup()
		f.throb[1] = f.throb:CreateAnimation()
		f.throb[1]:SetDuration(0.05)
		f.throb[1]:SetEndDelay(0.1)
		f.throb[1]:SetOrder(1)
		f.throb[1]:SetScript("OnUpdate", function(self)
			local p = self:GetRegionParent()
			p:SetFrameLevel(128)
			p:SetAlpha(1)
			self:GetRegionParent():SetScale(1 + (throbScale * self:GetProgress()))
		end)

		f.throb[2] = f.throb:CreateAnimation()
		f.throb[2]:SetDuration(0.35)
		f.throb[2]:SetOrder(2)
		f.throb[2]:SetScript("OnUpdate", function(self)
			local p = self:GetRegionParent()
			p:SetFrameLevel(128)
			p:SetAlpha(1)
			p:SetScale(1 + (throbScale * (1 - self:GetProgress())))
		end)
		
		f.throb:SetScript("OnPlay", function()
			f.overlayFrameLevel = f.overlayFrameLevel or f.overlay:GetFrameLevel()
			f.overlay:SetFrameLevel(128)
		end)
		f.throb:SetScript("OnStop", function()
			f.overlay:SetScale(1)
			if f.overlayFrameLevel then
				f.overlay:SetFrameLevel(f.overlayFrameLevel)
				f.overlayFrameLevel = nil
			end
		end)
		f.throb:SetScript("OnFinished", f.throb:GetScript("OnStop"))
		
		f.parent = self
		
		tinsert(framePool, f)
		return f
	end
	
	local function filterValid(self, filter)		
		if filter then
			return self.settings.events[filter]
		else
			return true
		end
	end
	
	function barPrototype:CreateCooldown(uid, name, icon, startTime, duration, stacks, filter, callback, ...)
		if not filterValid(self, filter) then return end		
		
		if duration < self.settings.bar.minDuration or duration - (GetTime() - startTime) + 0.5 < self.settings.bar.minDuration then return end
		if duration > self.settings.bar.maxDuration and self.settings.bar.maxDuration ~= 0 then return end
		
		if self.settings.blacklist[uid] then return end
		
		local f = self.cooldowns[uid]
		if not f then
			f = tremove(framePool)
			if not f then
				self:CreateNewCooldownFrame()
				f = tremove(framePool)
			end
			
			f.finish:Stop()
			f.throb:Stop()
			f.pulse:Stop()

			f.overlay:Show()
			f:SetAlpha(1)	
			f.overlay:SetAlpha(1)			
			
			f:SetParent(self)
			
			f:SetFrameLevel(framelevelSerial)
			f.nativeFrameLevel = framelevelSerial
			f.overlay:SetFrameLevel(framelevelSerial + 60)
			framelevelSerial = framelevelSerial + 5
			if framelevelSerial > 60 then
				framelevelSerial = 10
			end
			f.uid = uid
			self.cooldowns[f.uid] = f
			self.durations[f.uid] = duration
			
			f.parent = self			
			tinsert(self.usedFrames, f)
			f:Show()
			self:Activate()
			
			-- Only set this on button acquire. Otherwise, filters that are a superset of another filter set (all buffs, my buffs) might
			-- get "popping" between border colors. Once an icon has been created by a filter, we'll assume that UID is owned by that filter
			-- type until the icon expires.
			f.filter = filter
		end
		f.name = name
		f.icon = icon
		
		if stacks and stacks > 0 then
			f.stacks:SetText(stacks)
			f.overlay.stacks:SetText(stacks)
		else
			f.stacks:SetText(nil)
			f.overlay.stacks:SetText(nil)
		end		
		f.tooltipCallback = callback
		f.arg1, f.arg2, f.arg3, f.arg4 = ...
		f.endTime = startTime + duration
		f.startTime = startTime
		f.duration = duration
		self:SetMaxDuration()
		f.lastOverlapCheck = 0

		f:SetCooldownTexture(icon)			
		self:UpdateSingleIconLook(f)
		
		f:ClearAllPoints()
		f:UpdateTime()
		activateFrame(self)
	end
	
	function barPrototype:ExpireInvalidByFilter()
		for _, frame in ipairs(self.usedFrames) do
			if not filterValid(self, frame.filter) then
				frame:Expire(true)
			end
		end
	end
	
	function barPrototype:ExpireCooldown(uid)
		if self.cooldowns[uid] then
			self.cooldowns[uid]:Expire(true)
		end
	end
	
	function barPrototype:CastFailure(uid)
		local f = self.cooldowns[uid]
		if f and f.endTime - GetTime() > 0.3 and not f.throb:IsPlaying() then
			f.throb:Play()
		end
	end
end

function barPrototype:SetMaxDuration()
	if not self.settings.bar.flexible then return end
	local max = 0
	for k, v in pairs(self.durations) do
		max = v > max and v or max
	end
	if max < 30 then max = 30 end
	if max ~= self:GetTimeMax() then
		self.max_duration = max
		self:SetLabels()
	end
end

function barPrototype:GetTimeMax()
	local t = self.settings.bar.flexible and self.max_duration or self.settings.bar.time_max
	return t
end

function barPrototype:CreateLabel()
	local s = tremove(stringPool) or self:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
	tinsert(self.usedStrings, s)
	s:SetParent(self)
	s:Show()
	return s
end

function barPrototype:SetLabel(val)
	local l = self:CreateLabel(self)
	local depth = self:GetDepth() / 2
	local pos = getPos(val, self:GetTimeMax(), self.settings.bar.time_compression) * (self:GetLength() - depth)
	local lw = self:Vertical() and l:GetHeight() or l:GetWidth()
	if pos + lw > self:GetLength() then
		pos = self:GetLength() - lw
	end
	if self:Vertical() then
		l:SetPoint("CENTER", self, getAnchorSide(self), 0, pos * (self:Reversed() and -1 or 1))
	else
		l:SetPoint("CENTER", self, getAnchorSide(self), pos * (self:Reversed() and -1 or 1), 0)
	end
	local f = mod.displayFormatHandlers[self.settings.bar.timingDisplayFormat] or mod.displayFormatHandlers.TRUNCATED
	val = f(val)	
	l:SetText(val)
end

local stock = {1, 10, 30}
function barPrototype:SetLabels()
	self.usedStrings = self.usedStrings or {}
	
	while #self.usedStrings > 0 do
		local l = tremove(self.usedStrings)
		l:Hide()
		tinsert(stringPool, l)
	end
	
	if self.settings.bar.customTimings then
		local labels = 0
		for num in tostring(self.settings.bar.customTimings):gmatch("%d+") do
			num = tonumber(num)
			if num and num > 0 then
				self:SetLabel(num)
				labels = labels + 1
			end
		end
		if labels > 0 then return end
	end
	
	local minutes = math_floor(self:GetTimeMax() / 60)
	for i = 5, minutes, 5 do
		self:SetLabel(i * 60)
	end
	
	if minutes > 5 and math_fmod(minutes, 5) ~= 0 then
		self:SetLabel(minutes * 60)
	elseif minutes < 1 and self:GetTimeMax() ~= 30 then
		self:SetLabel(self:GetTimeMax())
	end
	
	for i = 1, math_min(minutes, 5) do
		self:SetLabel(i * 60)
	end

	for _, val in ipairs(stock) do
		if val <= self:GetTimeMax() then
			self:SetLabel(val)
		end
	end
end

function barPrototype:UpdateLabel(label, store)
	local f, s, m = label:GetFont() 
	local font = LSM:Fetch("font", store.font or f)
	local size = store.fontsize or s
	local outline = store.outline or m
	label:SetFont(font, size, outline)	
	local c = store.fontColor
	label:SetTextColor(c.r, c.g, c.b, c.a)
end

function barPrototype:SetBarFont()
	for k, v in ipairs(stringPool) do
		self:UpdateLabel(v, self.settings.bar)
	end
	
	for k, v in ipairs(self.usedStrings) do
		self:UpdateLabel(v, self.settings.bar)
	end
end

do
	local backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		insets = {left = 2, top = 2, right = 2, bottom = 2},
		edgeSize = 8,
		tile = false
	}
	function barPrototype:UpdateBarBackdrop()
		backdrop.bgFile = LSM:Fetch("statusbar", self.settings.bar.texture) or backdrop.bgFile
		backdrop.edgeFile = LSM:Fetch("border", self.settings.bar.border) or backdrop.border
		backdrop.edgeSize = self.settings.bar.borderSize or backdrop.edgeSize
		backdrop.insets.left = self.settings.bar.borderInset or backdrop.insets.left
		backdrop.insets.top = self.settings.bar.borderInset or backdrop.insets.top
		backdrop.insets.right = self.settings.bar.borderInset or backdrop.insets.right
		backdrop.insets.bottom = self.settings.bar.borderInset or backdrop.insets.bottom
		self:SetBackdrop(backdrop)
		local c = self.settings.bar.backgroundColor
		self:SetBackdropColor(c.r, c.g, c.b, c.a)
		c = self.settings.bar.borderColor
		self:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
	end
end

function barPrototype:UpdateBarLook()
	self:SetPoint("CENTER", UIParent, "CENTER", self.settings.bar.x, self.settings.bar.y)
	self:SetWidth(self:Vertical() and self.settings.bar.height or self.settings.bar.width)
	self:SetHeight(self:Vertical() and self.settings.bar.width or self.settings.bar.height)
	
	if self.settings.bar.splash_x then
		self.splashAnchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", self.settings.bar.splash_x, self.settings.bar.splash_y)
	else
		self.splashAnchor:SetPoint("CENTER", self, getAnchorSide(self))
	end
	
	self:SetLabels()
	self:SetBarFont()
	self:UpdateBarBackdrop()
	if self.settings.bar.lock and not mod.overrideLocks then
		self.grip:Hide()
		self:EnableMouse(false)
	else
		self.grip:Show()
		self:EnableMouse(true)
	end
	
	self.splashAnchor:lock(self.splashAnchor.locked, mod.overrideLocks)
	
	if mod.overrideLocks then
		self:SetAlpha(1)
	elseif not self.active then
		self:SetAlpha(self.settings.bar.inactiveAlpha)
	end
end

function barPrototype:UpdateIconLook()
	for _, icon in ipairs(self.usedFrames) do
		self:UpdateSingleIconLook(icon)
	end
end

function barPrototype:UpdateLook()
	self:UpdateBarLook()
	self:UpdateIconLook()	
end

function barPrototype:Expire()
	deactivateFrame(self)
	
	while #self.usedStrings > 0 do
		local l = tremove(self.usedStrings)
		l:Hide()
		tinsert(stringPool, l)
	end
	
	for _, frame in ipairs(self.usedFrames) do
		frame.finish:Stop()
		frame.throb:Stop()
		frame.pulse:Stop()
		frame:Expire(true)
	end
	
	for k, v in pairs(self.settings.events) do
		mod:UnregisterBarForFilter(self, k)
	end
	
	wipe(self.cooldowns)
	self:Hide()
	self.splashAnchor:SetParent(self)
	self.splashAnchor:Hide()
end

function barPrototype:CheckOverlap(current)
	local getLeft = self:Vertical() and "GetBottom" or "GetLeft"
	local getRight = self:Vertical() and "GetTop" or "GetRight"
	
	local l, r = current[getLeft](current), current[getRight](current)
	if not l or not r then return end
	
	current.lastOverlapCheck = current.lastOverlapCheck or 0
	if GetTime() - current.lastOverlapCheck < 3 then return end
	current.lastOverlapCheck = GetTime()
	
	current.pulsing = false
	for _, icon in ipairs(self.usedFrames) do
		if icon ~= current then
			local ir, il = icon[getLeft](icon), icon[getRight](icon)
			if (ir >= l and ir <= r) or (il >= l and il <= r) then
				local overlap = math_min(math_abs(ir - l), math_abs(il - r))
				if overlap >= 0 then				
					local frame = icon.nativeFrameLevel > current.nativeFrameLevel and icon or current
					if not frame.pulse:IsPlaying() then
						frame.pulse:Play()
					end
					frame.pulsing = true
				end
			end
		end
	end
	if not current.pulsing and current.pulse:IsPlaying() then
		current.pulse:Stop()
	end	
end

------------------------------------------------------
-- Button prototype
------------------------------------------------------
function cooldownPrototype:SetCooldownTexture(icon)
	self.tex:SetTexture(icon)
	self.tex:SetTexCoord(0.09, 0.91, 0.09, 0.91)
	
	self.overlay.tex:SetTexture(icon)
	self.overlay.tex:SetTexCoord(0.09, 0.91, 0.09, 0.91)
end

function cooldownPrototype:ShowTooltip()
	local icon = self.icon
	if not icon.tooltipCallback or icon.parent.settings.icon.disableTooltip then 
		return
	end
	GameTooltip:SetOwner(icon, "ANCHOR_CURSOR")
	icon.tooltipCallback(icon, icon.arg1, icon.arg2, icon.arg3, icon.arg4)
	GameTooltip:Show()
end

function cooldownPrototype:HideTooltip()
	GameTooltip:Hide()
end
	
function cooldownPrototype:Expire(noanimate)
	local parent = self.parent
	for k, v in ipairs(parent.usedFrames) do
		if v == self then
			tinsert(framePool, tremove(parent.usedFrames, k))
			break
		end
	end
	if #parent.usedFrames == 0 then
		parent:Deactivate()
	end
	
	if self.pulse:IsPlaying() then self.pulse:Stop() end
	if noanimate and self.endTime - GetTime() > 1 then
		self:Hide()
	else
		self.finish:Play()
	end
	parent.cooldowns[self.uid] = nil
	parent.durations[self.uid] = nil
end
	
function cooldownPrototype:UpdateTime()
	local parent = self.parent
	local timeMax = parent:GetTimeMax()
	local remaining = self.endTime - GetTime()
	local iRemaining = math_floor(remaining)
	local text
	if iRemaining ~= self.lastRemaining or iRemaining < 10 then
		parent:CheckOverlap(self)
		if iRemaining >= 60 then
			local minutes = math_floor(iRemaining / 60)
			local seconds = math_fmod(iRemaining, 60)
			text = string_format("%2.0f:%02.0f", minutes, seconds)
		elseif remaining <= 10 then
			text = string_format("%2.1f", remaining)
		else
			text = string_format("%2.0f", remaining)
		end
		if self.fs.lastText ~= text then
			self.fs:SetText(text)
			self.fs.lastText = text
			self.overlay.fs:SetText(text)
			self.overlay.fs.lastText = text
		end
		self.lastRemaining = iRemaining
	end
	
	if remaining > timeMax then
		remaining = timeMax
	end

	local expire = false
	if remaining <= 0 then
		remaining = 0.00001
		expire = true
	end
	
	local w, h = parent:GetLength(), parent:GetDepth()
	local barWidth = (w - (h / 2))
	local base = parent.settings.bar.time_compression
	local pos = getPos(remaining, timeMax, base) * barWidth
	-- self:SetPoint("CENTER", parent, "LEFT", pos, 0)
	if parent:Vertical() then
		self:SetPoint("CENTER", parent, getAnchorSide(parent), 0, pos * (parent:Reversed() and -1 or 1))
	else
		self:SetPoint("CENTER", parent, getAnchorSide(parent), pos * (parent:Reversed() and -1 or 1), 0)
	end	
	
	if expire then
		self:Expire()		
	end
end

function cooldownPrototype:Blacklist()
	print(("|cff7777eeSexyCooldown|r добавлен |cffff0000%s|r в черный список из панели |cffff0000%s|r"):format(self.name, self.parent.settings.bar.name))
	self.parent.settings.blacklist[self.uid] = self.name
	self:Expire(true)
end

-- Sometimes this may not do anything if it's not a valid aura, but hey, we can try.
function cooldownPrototype:Cancel()
	if self.name then
		-- CancelUnitBuff("player", self.name)
	end
end