-- This file is script-generated and should not be manually edited. 
-- Localizers may copy this file to edit as necessary. 
local AceLocale = LibStub:GetLibrary("AceLocale-3.0") 
local L = AceLocale:NewLocale("SexyCooldown", "enUS", true) 
if not L then return end 
 
-- ./core.lua
L["Select an options sub-category to get started."] = true
L["Bars"] = true
L["Create new bar"] = true
L["Profiles"] = true
L["Reset to defaults"] = true
L["Reset all colors in this group to the icon defaults"] = true

-- ./loadstub.lua
-- no localization

-- ./Modules/Auras.lua
L["All buffs on me"] = true
L["Show the duration of buffs on me on this bar"] = true
L["All debuffs on me"] = true
L["Show the duration of my debuffs on me on this bar"] = true
L["My buffs on me"] = true
L["Show the duration of my buffs on me on this bar"] = true
L["My debuffs on me"] = true
L["Show the duration of debuffs on me on this bar"] = true
L["My focus buffs"] = true
L["Show the duration of my buffs on my focus on this bar"] = true
L["My focus debuffs"] = true
L["Show the duration of my debuffs on my focus on this bar"] = true
L["My target buffs"] = true
L["Show the duration of my buffs on my target on this bar"] = true
L["My target debuffs"] = true
L["Show the duration of my debuffs on my target on this bar"] = true
L["All target buffs"] = true
L["Show the duration of all buffs on my target on this bar"] = true
L["All target debuffs"] = true
L["Show the duration of all debuffs on my target on this bar"] = true

-- ./Modules/Items.lua
L["Items"] = true
L["Show my item cooldowns on this bar"] = true
L["Internal cooldowns"] = true
L["Show internal cooldowns for my items and enchants on this bar."] = true

-- ./Modules/RaidDebuffs.lua
L["Major Armor Debuff"] = true
L["Attack Speed Debuff"] = true
L["Bleed Damage"] = true
L["Cast Speed Debuff"] = true
L["Healing Debuff"] = true
L["Physical Damage Reduction"] = true
L["Physical Vulnerability"] = true
L["Spell Crit Chance"] = true
L["Spell Damage Taken"] = true
L["Major Armor Debuffs"] = true
L["Show the duration of major armor debuffs on the target"] = true
L["Attack Speed Debuffs"] = true
L["Show the duration of attack speed debuffs on the target"] = true
L["Bleed Damage Debuffs"] = true
L["Show the duration of bleed damage debuffs on the target"] = true
L["Cast Speed Debuffs"] = true
L["Show the duration of cast speed debuffs on the target"] = true
L["Show the duration of -healing debuffs on the target"] = true
L["Physical Damage Reduction Debuffs"] = true
L["Show the duration of physical damage reduction debuffs on the target"] = true
L["Physical Vulnerability Debuffs"] = true
L["Show the duration of physical vulnerability debuffs on the target"] = true
L["Spell Crit Debuffs"] = true
L["Show the duration of spell crit chance debuffs on the target"] = true
L["Spell Damage Debuffs"] = true
L["Show the duration of spell damage debuffs on the target"] = true

-- ./Modules/Spells.lua
L["My spells"] = true
L["Show my spell cooldowns on this bar"] = true
L["Pet spells"] = true
L["Show my pet's cooldowns on this bar"] = true
L["Show internal cooldowns for my spells and talents on this bar."] = true

-- ./Modules/Totems.lua
L["Totem durations"] = true
L["Show my totem durations on this bar"] = true

-- ./options.lua
L["No outline"] = true
L["Outline"] = true
L["Thick Outline"] = true
L["Left to Right"] = true
L["Right to Left"] = true
L["Top to Bottom"] = true
L["Bottom to top"] = true
L["Center left"] = true
L["Center right"] = true
L["Center"] = true
L["Top left"] = true
L["Top right"] = true
L["Top center"] = true
L["Bottom left"] = true
L["Bottom center"] = true
L["Bottom right"] = true
L["Clone from..."] = true
L["Clone from another bar"] = true
L["Icons"] = true
L["Right-click an icon on a cooldown bar to blacklist it and prevent it from showing in the future. To remove a cooldown from a blacklist, choose the cooldown to remove from this list."] = true
L["Blacklist"] = true
L["Select an item to remove it from the blacklist."] = true
L["Removed %s from the SexyCooldown blacklist"] = true
L["Clamp to screen"] = true
L["Prevent icons from running off the screen"] = true
L["Cooldown Text"] = true
L["Show Cooldown Text"] = true
L["Show Stacks"] = true
L["Show the number of stacks of a buff or debuff"] = true
L["Time corner"] = true
L["Select the corner to anchor the time text to."] = true
L["Stacks corner"] = true
L["Select the corner to anchor the stack text to."] = true
L["Stacks offset"] = true
L["Offset for stack text"] = true
L["Time offset"] = true
L["Offset for time text"] = true
L["Font"] = true
L["Font size"] = true
L["Font color"] = true
L["Font Outline"] = true
L["Borders"] = true
L["Border"] = true
L["Border color"] = true
L["Border size"] = true
L["Border inset"] = true
L["General options"] = true
L["Icon size"] = true
L["How big to make icons, relative to their parent bar"] = true
L["Finish Behavior"] = true
L["Splash scale"] = true
L["How big (or small) icons will 'splash' when their cooldown is done"] = true
L["Splash speed"] = true
L["How quickly to play the splash animation once a cooldown is done"] = true
L["Disable tooltips"] = true
L["Don't show item or spell tooltips when you hover over their icons on the bar."] = true
L["Disable mouse"] = true
L["Don't allow mouse interaction with icons. If you turn this off, you won't be able to blacklist items."] = true
L["Pulse speed"] = true
L["Speed to pulse overlapping icons"] = true
L["Bar"] = true
L["General Options"] = true
L["Name"] = true
L["A descriptive name for this bar"] = true
L["Lock"] = true
L["Lock this bar to prevent resizing or moving"] = true
L["Flexible"] = true
L["Collapse the bar to the length of your longest active cooldown."] = true
L["Advanced Options"] = true
L["Enable advanced configuration options"] = true
L["Bar Orientation"] = true
L["Bar and icon direction."] = true
L["Time and Duration settings"] = true
L["Time Compression"] = true
L["Time display scaling factor"] = true
L["Max Time"] = true
L["Max time to display, in seconds"] = true
L["Minimum duration"] = true
L["Cooldowns shorter than this will not be shown."] = true
L["Maximum duration"] = true
L["Cooldowns longer than this will not be shown. Set to 0 to show all cooldowns."] = true
L["Border and Background"] = true
L["Background"] = true
L["Background color"] = true
L["Border insets"] = true
L["Position and Size"] = true
L["Height"] = true
L["Width"] = true
L["Horizontal Position"] = true
L["Horizontal offset from screen center"] = true
L["Vertical Offset"] = true
L["Vertical offset from screen center"] = true
L["Inactive Opacity"] = true
L["Opacity to set the bar to when a cooldown is not active"] = true
L["Show Splash Anchor"] = true
L["Show an anchor that you can use to move the splash anchor, which controls where icons 'splash' when they are cooled down."] = true
L["Reset Splash Anchor"] = true
L["Reset splash anchor to its default position."] = true
L["/!\\ Delete This Bar /!\\"] = true
L["Permanently delete this bar."] = true
L["Are you sure you want to delete this bar?"] = true
L["Custom timings"] = true
L["Specify a comma-delimited list of intervals to mark on the bar, in seconds. For example: 1,5,10,30,45,60,180"] = true
L["Timings format"] = true
L["Select the display format for timings"] = true
L["Event Types"] = true
L["Event Colors"] = true

-- ./prototype.lua
-- no localization

