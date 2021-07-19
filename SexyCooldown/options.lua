local mod = SexyCooldown
local L = LibStub("AceLocale-3.0"):GetLocale("SexyCooldown")
local LSM = LibStub("LibSharedMedia-3.0")

local outlines = {
	[""] = L["No outline"], 
	["OUTLINE"] = L["Outline"], 
	["THICKOUTLINE"] = L["Thick Outline"]
}

local orientations = {
	LEFT_TO_RIGHT = L["Left to Right"],
	RIGHT_TO_LEFT = L["Right to Left"],
	TOP_TO_BOTTOM = L["Top to Bottom"],
	BOTTOM_TO_TOP = L["Bottom to top"]
}

local ANCHORS = {
	LEFT = L["Center left"],
	RIGHT = L["Center right"],
	CENTER = L["Center"],
	TOPLEFT = L["Top left"],
	TOPRIGHT = L["Top right"],
	TOP = L["Top center"],
	BOTTOMLEFT = L["Bottom left"],
	BOTTOM = L["Bottom center"],
	BOTTOMRIGHT = L["Bottom right"]
}

local displayFormatHandlers = {
	TRUNCATED = function(val)
		if val >= 3600 then
			if val % 3600 == 0 then
				val = ("%2.0fh"):format(val / 3600)
			else
				val = ("%2.1fh"):format(val / 3600)
			end
		elseif val >= 60 then
			if val % 60 == 0 then
				val = ("%2.0fm"):format(val / 60)
			else
				val = ("%2.1fm"):format(val / 60)
			end
		end
		return val		
	end,
	CLOCK = function(val)
		if val >= 60 then
			val = ("%2.0f:%02.0f"):format(val / 60, val % 60)
		end
		return val		
	end,
	CLOCK_LONG = function(val)
		if val >= 60 then
			val = ("%2.0f:%02.0f"):format(val / 60, val % 60)
		else
			val = ("0:%02.0f"):format(val % 60)
		end
		return val
	end,
	LITERAL = function(val)
		return val
	end
}
mod.displayFormatHandlers = displayFormatHandlers

local TIMING_DISPLAY_FORMATS = {}
local buff = {}
local nums = {1, 30, 60, 90, 3600}

for k, v in pairs(displayFormatHandlers) do
	wipe(buff)
	for _, val in ipairs(nums) do
		tinsert(buff, v(val))
	end
	local s = table.concat(buff, ", ")
	TIMING_DISPLAY_FORMATS[k] = s
end

mod.baseOptions = {
	type = "group",
	args = {}
}

mod.barDefaults = {
	blacklist = {},
	bar = {
		font = "Fritz Quadrata TT",
		fontsize = 12,
		texture = "Glaze",
		border = "Blizzard Tooltip",
		borderInset = 2,
		borderColor = { r = 0.3019607843137255, g = 0.5215686274509804, b = 1, a = 1 },
		backgroundColor = { r = 0.2, g = 0.2705882352941176, b = 0.6784313725490196, a = 1 },
		fontColor = { r = 1, g = 1, b = 1, a = 1 },
		width = 450,
		height = 33,
		minDuration = 3,
		maxDuration = 0,
		inactiveAlpha = 1,
		time_max = 180,
		time_compression = 0.3,
		x = 0,
		y = -300,
		orientation = "LEFT_TO_RIGHT",
		timingDisplayFormat = "TRUNCATED"
	},
	icon = {
		font = "Fritz Quadrata TT",
		fontsize = 10,
		border = "Blizzard Tooltip",
		borderColor = { r = 1, g = 1, b = 1, a = 1 },
		fontColor = { r = 1, g = 1, b = 1, a = 1 },
		sizeOffset = 4,
		borderInset = 4,
		showText = true,
		showStacks = false,
		splashScale = 4,
		splashSpeed = 0.5,
		borderSize = 13,
		stacksAnchor = "TOPLEFT",
		timeAnchor = "BOTTOMRIGHT",
		stacksOffset = 2,
		timeOffset = 2,
		pulseSpeed = 0.4
	},
	events = {
		SPELL_COOLDOWN = true,
		PET_SPELL_COOLDOWN = true,
		ITEM_COOLDOWN = true,
		INTERNAL_SPELL_COOLDOWN = true,
		INTERNAL_ITEM_COOLDOWN = true,
		TOTEM_COOLDOWN = true
	},
	eventColors = {}
}

mod.eventArgs, mod.eventColors = {}, {}

function mod:GetOptionsTable(frame)
	local db = frame.settings
	
	local showAdvanced = function()
		return db.bar.advancedOptions ~= true
	end
	
	local copyVal, copyList = nil, {}
	local options = {
		copy = {
			type = "group",
			name = L["Clone from..."],
			desc = L["Clone from another bar"],
			args = {
				source = {
					type = "select",
					name = L["Clone from..."],
					values = function()
						wipe(copyList)
						for k, v in ipairs(mod.db.profile.bars) do
							if v ~= db then
								copyList[k] = v.bar.name
							end
						end
						return copyList
					end,
					get = function() return copyVal end,
					set = function(info, v)
						copyVal = v
						local source_frame = mod.db.profile.bars[v]
						local oldsettings = frame.settings
						frame.settings = mod:CloneSettings(source_frame)
						frame.settings.bar.x = oldsettings.bar.x
						frame.settings.bar.y = oldsettings.bar.y
						frame.settings.bar.lock = oldsettings.bar.lock
						frame.settings.bar.name = oldsettings.bar.name
						frame.settings.bar.advancedOptions = false
						for k, v in ipairs(mod.db.profile.bars) do
							if v == oldsettings then
								mod.db.profile.bars[k] = frame.settings
								break
							end
						end
						db = frame.settings
						frame:UpdateLook()
					end
				}				
			},
			order = 200
		},
		icon = {
			type = "group",
			name = L["Icons"],
			args = {
				blacklistDesc = {
					type = "description",
					name = L["Right-click an icon on a cooldown bar to blacklist it and prevent it from showing in the future. To remove a cooldown from a blacklist, choose the cooldown to remove from this list."],
					order = 12
				},
				blacklist = {
					name = L["Blacklist"],
					desc = L["Select an item to remove it from the blacklist."],
					type = "select",
					values = db.blacklist,
					get = function() return false end,
					set = function(info, v)
						print((L["Removed %s from the SexyCooldown blacklist"]):format(db.blacklist[v]))
						db.blacklist[v] = nil
					end,
					order = 11,
					width = "full"
				},
				clamp = {
					name = L["Clamp to screen"],
					desc = L["Prevent icons from running off the screen"],
					type = "toggle",
					order = 13
				},
				fontHeader = {
					name = L["Cooldown Text"],
					desc = "Cooldown description",
					type = "header",
					order = 120
				},
				showText = {
					type = "toggle",
					name = L["Show Cooldown Text"],
					desc = L["Show Cooldown Text"],
					order = 120,
					width = "full"
				},
				showStacks = {
					type = "toggle",
					name = L["Show Stacks"],
					desc = L["Show the number of stacks of a buff or debuff"],
					order = 120,
					width = "full"
				},
				timeAnchor = {
					type = "select",
					name = L["Time corner"],
					desc = L["Select the corner to anchor the time text to."],
					values = ANCHORS,
					order = 122,
					disabled = function(info)
						return not db.icon.showText
					end,
				},
				stacksAnchor = {
					type = "select",
					name = L["Stacks corner"],
					desc = L["Select the corner to anchor the stack text to."],
					values = ANCHORS,
					order = 121,
					disabled = function(info)
						return not db.icon.showStacks
					end,
				},
				stacksOffset = {
					type = "range",
					name = L["Stacks offset"],
					desc = L["Offset for stack text"],
					min = -20,
					max = 20,
					step = 1,
					bigStep = 1,
					order = 121,
					disabled = function(info)
						return not db.icon.showStacks
					end,
				},
				timeOffset = {
					type = "range",
					name = L["Time offset"],
					desc = L["Offset for time text"],
					min = -60,
					max = 60,
					step = 1,
					bigStep = 1,
					order = 122,
					disabled = function(info)
						return not db.icon.showText
					end
				},
				font = {
					type = "select",
					name = L["Font"],
					desc = L["Font"],
					dialogControl = 'LSM30_Font',
					values = LSM:HashTable("font"),
					disabled = function(info)
						return not db.icon.showText and not db.icon.showStacks
					end,
					order = 121,
					width = "full"
				},
				fontsize = {
					type = "range",
					name = L["Font size"],
					desc = L["Font size"],
					min = 4,
					max = 30,
					step = 1,
					bigStep = 1,
					disabled = function(info)
						return not db.icon.showText and not db.icon.showStacks
					end,
					order = 123,
					width = "full"
				},
				fontColor = {
					type = "color",
					name = L["Font color"],
					desc = L["Font color"],
					hasAlpha = true,
					disabled = function(info)
						return not db.icon.showText and not db.icon.showStacks
					end,
					order = 123
				},				
				outline = {
					type = "select",
					name = L["Font Outline"],
					desc = L["Font Outline"],
					values = outlines,
					disabled = function(info)
						return not db.icon.showText and not db.icon.showStacks
					end,
					order = 125
				},
				borderheader = {
					type = "header",
					name = L["Borders"],
					order = 50
				},
				border = {
					type = "select",
					name = L["Border"],
					desc = L["Border"],
					dialogControl = 'LSM30_Border',
					values = LSM:HashTable("border"),
					order = 51
				},
				borderColor = {
					type = "color",
					name = L["Border color"],
					desc = L["Border color"],
					hasAlpha = true,
					order = 52
				},				
				borderSize = {
					type = "range",
					name = L["Border size"],
					desc = L["Border size"],
					min = 4,
					max = 24,
					step = 1,
					bigStep = 1
				},
				borderInset = {
					type = "range",
					name = L["Border inset"],
					desc = L["Border inset"],
					min = -5,
					max = 25,
					step = 1,
					bigStep = 1,
				},		
				generalheader = {
					type = "header",
					name = L["General options"],
					order = 1
				},
				sizeOffset = {
					type = "range",
					name = L["Icon size"],
					desc = L["How big to make icons, relative to their parent bar"],
					min = -25,
					max = 25,
					step = 1,
					bigStep = 1,
					order = 10,
					width = "full",
				},
				finish = {
					type = "header",
					name = L["Finish Behavior"],
					order = 14
				},
				splashScale = {
					type = "range",
					name = L["Splash scale"],
					desc = L["How big (or small) icons will 'splash' when their cooldown is done"],
					min = 0,
					max = 50,
					step = 0.25,
					bigStep = 1,
					order = 15
				},
				splashSpeed = {
					type = "range",
					name = L["Splash speed"],
					desc = L["How quickly to play the splash animation once a cooldown is done"],
					min = 0.05,
					max = 3.0,
					step = 0.05,
					bigStep = 0.05,
					order = 16
				},
				disableTooltip = {
					type = "toggle",
					name = L["Disable tooltips"],
					desc = L["Don't show item or spell tooltips when you hover over their icons on the bar."],
					disabled = function()
						return db.icon.disableMouse
					end
				},
				disableMouse = {
					type = "toggle",
					name = L["Disable mouse"],
					desc = L["Don't allow mouse interaction with icons. If you turn this off, you won't be able to blacklist items."]
				},
				pulseSpeed = {
					type = "range",
					name = L["Pulse speed"],
					desc = L["Speed to pulse overlapping icons"],
					min = 0.1,
					max = 2.0,
					step = 0.01,
					bigStep = 0.1,
					order = 17
				}
			}
		},
		bar = {
			type = "group",
			name = L["Bar"],
			args = {
				generalOptions = {
					type = "header",
					name = L["General Options"],
					order = 1
				},
				name = {
					type = "input",
					name = L["Name"],
					desc = L["A descriptive name for this bar"],
					order = 2,
					set = "setName"
				},
				lock = {
					type = "toggle",
					name = L["Lock"],
					desc = L["Lock this bar to prevent resizing or moving"],
					order = 2					
				},
				flexible = {
					type = "toggle",
					name = L["Flexible"],
					desc = L["Collapse the bar to the length of your longest active cooldown."]				,
					order = 3
				},
				advancedOptions = {
					type = "toggle",
					name = L["Advanced Options"],
					desc = L["Enable advanced configuration options"],
					order = 3,
				},
				orientation = {
					name = L["Bar Orientation"],
					desc = L["Bar and icon direction."],
					type = "select",
					values = orientations,
					order = 4
				},							
				timeHeader = {
					type = "header",
					name = L["Time and Duration settings"],
					order = 20
				},
				time_compression = {
					type = "range",
					name = L["Time Compression"],
					desc = L["Time display scaling factor"],
					min = 0.01,
					max = 1.0,
					step = 0.005,
					bigStep = 0.05,
					order = 21
				},
				time_max = {
					type = "range",
					name = L["Max Time"],
					desc = L["Max time to display, in seconds"],
					min = 10,
					max = 1800,
					width = "full",
					step = 1,
					bigStep = 10,
					order = 21
				},				
				minDuration = {
					type = "range",
					name = L["Minimum duration"],
					desc = L["Cooldowns shorter than this will not be shown."],
					min = 3,
					max = 60,
					step = 1,
					bigStep = 1,
					order = 22,
				},
				maxDuration = {
					type = "range",
					name = L["Maximum duration"],
					desc = L["Cooldowns longer than this will not be shown. Set to 0 to show all cooldowns."],
					min = 0,
					max = 3600,
					step = 1,
					bigStep = 5,
					order = 22
				},				
				bnbHeader = {
					type = "header",
					name = L["Border and Background"],
					order = 50
				},
				texture = {
					type = "select",
					name = L["Background"],
					desc = L["Background"],
					dialogControl = 'LSM30_Statusbar',
					values = LSM:HashTable("statusbar")
				},
				backgroundColor = {
					type = "color",
					name = L["Background color"],
					desc = L["Background color"],
					hasAlpha = true
				},
				border = {
					type = "select",
					name = L["Border"],
					desc = L["Border"],
					dialogControl = 'LSM30_Border',
					values = LSM:HashTable("border")
				},
				borderColor = {
					type = "color",
					name = L["Border color"],
					desc = L["Border color"],
					hasAlpha = true		
				},				
				borderSize = {
					type = "range",
					name = L["Border size"],
					desc = L["Border size"],
					min = 4,
					max = 24,
					step = 1,
					bigStep = 1,
					hidden = showAdvanced
				},
				borderInset = {
					type = "range",
					name = L["Border insets"],
					desc = L["Border insets"],
					min = 0,
					max = 16,
					step = 1,
					bigStep = 1,
					hidden = showAdvanced					
				},				
				-- Font
				font = {
					type = "select",
					name = L["Font"],
					desc = L["Font"],
					dialogControl = 'LSM30_Font',
					values = LSM:HashTable("font")
				},				
				fontsize = {
					type = "range",
					name = L["Font size"],
					desc = L["Font size"],
					min = 4,
					max = 30,
					step = 1,
					bigStep = 1
				},
				outline = {
					type = "select",
					name = L["Font Outline"],
					desc = L["Font Outline"],
					values = outlines
				},
				fontColor = {
					type = "color",
					name = L["Font color"],
					desc = L["Font color"],
					hasAlpha = true		
				},
				-- Options
				positioning = {
					type = "header",
					name = L["Position and Size"],
					order = 399,					
					hidden = showAdvanced,
				},
				height = {
					type = "range",
					name = L["Height"],
					desc = L["Height"],
					min = 5,
					max = 100,
					step = 1,
					bigStep = 1,
					hidden = showAdvanced,
					order = 401,
				},
				width = {
					type = "range",
					name = L["Width"],
					desc = L["Width"],
					min = 50,
					max = 2000,
					step = 1,
					bigStep = 25,
					hidden = showAdvanced,
					order = 400,
				},
				x = {
					type = "range",
					name = L["Horizontal Position"],
					desc = L["Horizontal offset from screen center"],
					min = -2000,
					max = 2000,
					step = 1,
					bigStep = 1,
					hidden = showAdvanced,
					order = 500					
				},
				y = {
					type = "range",
					name = L["Vertical Offset"],
					desc = L["Vertical offset from screen center"],
					min = -2000,
					max = 2000,
					step = 1,
					bigStep = 1,
					hidden = showAdvanced,
					order = 501,
				},				
				inactiveAlpha = {
					type = "range",
					name = L["Inactive Opacity"],
					desc = L["Opacity to set the bar to when a cooldown is not active"],
					min = 0,
					max = 1,
					step = 0.01,
					bigStep = 0.05,
					isPercent = true
				},
				showSplash = {
					type = "execute",
					name = L["Show Splash Anchor"],
					desc = L["Show an anchor that you can use to move the splash anchor, which controls where icons 'splash' when they are cooled down."],
					func = function()
						frame.splashAnchor:lock(false)
					end,
					order = 600,
					hidden = showAdvanced
				},
				resetSplash = {
					type = "execute",
					name = L["Reset Splash Anchor"],
					desc = L["Reset splash anchor to its default position."],
					func = function()
						db.bar.splash_x = nil
						db.bar.splash_y = nil
						frame.splashAnchor:ClearAllPoints()
						frame.splashAnchor:SetPoint("CENTER", frame, "LEFT")
					end,
					order = 601,
					hidden = showAdvanced
				},
				deleteBar = {
					type = "execute",
					name = L["/!\\ Delete This Bar /!\\"],
					desc = L["Permanently delete this bar."],
					func = function()
						mod:DestroyBar(frame)
					end,
					confirm = true,
					confirmText = L["Are you sure you want to delete this bar?"],
					order = 602,
					hidden = showAdvanced
				},
				customTimings = {
					type = "input",
					name = L["Custom timings"],
					desc = L["Specify a comma-delimited list of intervals to mark on the bar, in seconds. For example: 1,5,10,30,45,60,180"],
					order = 702,
					hidden = showAdvanced
				},
				timingDisplayFormat = {
					type = "select",
					name = L["Timings format"],
					desc = L["Select the display format for timings"],
					values = TIMING_DISPLAY_FORMATS,
					order = 703,
					hidden = showAdvanced
				}
			}
		},
		events = {
			type = "group",
			name = L["Event Types"],
			get = "getEvents",
			set = "setEvents",
			args = mod.eventArgs
		},
		eventColors = {
			type = "group",
			name = L["Event Colors"],
			get = "getEventColors",
			set = "setEventColors",
			args = mod.eventColors
		}
	}

	local handlers = {}
	handlers.get = function(info)
		local obj = db
		for i = 3, #info do
			obj = obj[info[i]]
		end			
		if type(obj) == "table" then
			return obj.r, obj.g, obj.b, obj.a
		else
			return obj
		end
	end
	
	handlers.set = function(info, ...)
		local obj = db
		for i = 3, #info - 1 do
			obj = obj[info[i]]
		end
		if select("#", ...) == 1 then
			obj[info[#info]] = ...
		else
			local t = obj[info[#info]]
			t.r, t.g, t.b, t.a = ...
		end
		frame:UpdateLook()		
	end
	
	handlers.getEvents = function(self, info)
		return db.events[info[#info]]
	end
	
	handlers.setEvents = function(self, info, value)
		-- handlers.set(info, value)
		db.events[info[#info]] = value
		frame:ExpireInvalidByFilter()
		if value then
			mod:RegisterBarForFilter(frame, info[#info])
		else
			mod:UnregisterBarForFilter(frame, info[#info])
		end
		mod:Refresh(info[#info])
	end
	
	handlers.getEventColors = function(self, info)
		local t = db.eventColors[info[#info]] or db.icon.borderColor
		return t.r, t.g, t.b, t.a
	end	
	
	handlers.setEventColors = function(self, info, r, g, b, a)
		if info.type == "color" then
			local t = db.eventColors[info[#info]] or {}
			db.eventColors[info[#info]] = db.eventColors[info[#info]] or t
			t.r, t.g, t.b, t.a = r, g, b, a
		end
		frame:UpdateLook()
	end
	
	handlers.resetColors = function(self)
		db.eventColors = {}
		frame:UpdateLook()
	end
	
	handlers.setName = function(self, info, value)
		handlers.set(info, value)
		mod:UpdateFrameName(frame)
	end
	
	return {
		type = "group",
		name = frame.settings.bar.name,
		arg = frame,
		handler = handlers,
		get = handlers.get,
		set = handlers.set,
		args = options
	}
end