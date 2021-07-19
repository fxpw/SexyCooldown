local lib, oldminor = LibStub:GetLibrary("LibInternalCooldowns-1.0")

-- Format is spellID = itemID | {itemID, itemID, ... itemID}
local spellToItem = {
	-- Darkmoon Cards
	[89091] = 62047,			-- Darkmoon Card: Volcano

	-- Tol Barad factions
	[91192] = {62467, 62472},	-- Mandala of Stirring Patterns
	[91047] = {62465, 62470},	-- Stump of Time

	-- Valour Vendor 4.0
	[92233] = 58182,			-- Bedrock Talisman

	-- Cataclysm Raid 372
	[92320] = 65105,			-- Theralion's Mirror
	[92355] = 65048,			-- Symbiotic Worm
	[92349] = 65026,			-- Prestor's Talisman of Machination
	[92345] = 65072,			-- Heart of Rage
	[92345] = 65072,			-- Heart of Rage
	[92332] = 65124,			-- Fall of Mortality
	[92351] = 65140,			-- Essence of the Cyclone
	[92342] = 65118,			-- Crushing Weight
	[92318] = 65053,			-- Bell of Enraging Resonance
	--[92331] = 65029,			-- Jar of Ancient Remedies. DO NOT USE, overwrites the actual use cooldown with the internal one

	-- Cataclysm Raid 359
	[92108] = 59520,			-- Unheeded Warning
	[91024] = 59519,			-- Theralion's Mirror
	[92235] = 59332,			-- Symbiotic Worm
	[92124] = 59441,			-- Prestor's Talisman of Machination
	[91816] = 59224,			-- Heart of Rage
	[91184] = 59500,			-- Fall of Mortality
	[92126] = 59473,			-- Essence of the Cyclone
	[91821] = 59506,			-- Crushing Weight
	[91007] = 59326,			-- Bell of Enraging Resonance
	--[91322] = 59354,			-- Jar of Ancient Remedies. DO NOT USE, overwrites the actual use cooldown with the internal one

	-- Cataclysm Dungeon 346
	[90992] = 56407,			-- Anhuur's Hymnal
	[91149] = 56414,			-- Blood of Isiset
	[92087] = 56295,			-- Grace of the Herald
	[91364] = 56393,			-- Heart of Solace
	[92091] = 56328,			-- Key to the Endless Chamber
	[92184] = 56347,			-- Leaden Despair
	[92094] = 56427,			-- Left Eye of Rajh
	[92174] = 56280,			-- Porcelain Crab
	[91143] = 56377,			-- Rainsong
	[91368] = 56431,			-- Right Eye of Rajh
	[91002] = 56400,			-- Sorrowsong
	[91139] = 56351,			-- Tear of Blood
	[90898] = 56339,			-- Tendrils of Burrowing Dark
	[92205] = 56449,			-- Throngus's Finger
	[90887] = 56320,			-- Witching Hourglass

	-- Cataclysm Dungeon and World drops 308-333
	[90989] = 55889,			-- Anhuur's Hymnal
	[91147] = 55995,			-- Blood of Isiset
	[91363] = 55868,			-- Heart of Solace
	[92096] = 56102,			-- Left Eye of Rajh
	[91370] = 56100,			-- Right Eye of Rajh
	[90996] = 55879,			-- Sorrowsong
	[92208] = 56121,			-- Throngus's Finger
	[92052] = 66969,			-- Heart of the Vile
	[92069] = 55795,			-- Key to the Endless Chamber
	[92179] = 55816,			-- Leaden Despair
	[91141] = 55854,			-- Rainsong
	[91138] = 55819,			-- Tear of Blood
	[90896] = 55810,			-- Tendrils of Burrowing Dark
	[92052] = 55266,			-- Grace of the Herald
	[90885] = 55787,			-- Witching Hourglass

	-- Cataclysm Quest rewards (and a 5man trinket, sneaky Blizzard!)
	[92166] = {65803, 65805, 65804, 55237}, -- Harrison's Insignia of Panache, Schnotzz's Medallion of Command, Talisman of Sinister Order, Porcelain Crab 

	-- PvP Lvl 85
	[85027] = 61045,			-- Vicious Gladiator's Insignia of Dominance
	[85032] = 61046,			-- Vicious Gladiator's Insignia of Victory
	[85022] = 61047,			-- Vicious Gladiator's Insignia of Conquest
	[92218] = 64762,			-- Bloodthirsty Gladiator's Insignia of Dominance
	[92216] = 64763,			-- Bloodthirsty Gladiator's Insignia of Victory
	[92220] = 64761,			-- Bloodthirsty Gladiator's Insignia of Conquest


	-- Random WotLK stuff
	[64411] = 46017,			-- Val'anyr, Hammer of Ancient Kings

	[60065] = {44914, 40684, 49074},	-- Anvil of the Titans, Mirror of Truth, Coren's Chromium Coaster
	[60488] = 40373,					-- Extract of Necromatic Power
	[64713] = 45518,					-- Flare of the Heavens
	[60064] = {44912, 40682, 49706},	-- Flow of Knowledge, Sundial of the Exiled, Mithril Pocketwatch

	[67703] = {47303, 47115},	-- Death's Choice, Death's Verdict (AGI)
	[67708] = {47303, 47115},	-- Death's Choice, Death's Verdict (STR)
	[67772] = {47464, 47131},	-- Death's Choice, Death's Verdict (Heroic) (AGI)
	[67773] = {47464, 47131},	-- Death's Choice, Death's Verdict (Heroic) (STR)

	-- ICC epix
	-- Rep rings
	[72416] = {50398, 50397},
	[72412] = {50402, 50401},
	[72418] = {50399, 50400},
	[72414] = {50404, 50403},

	-- Deathbringer's Will (Non-heroic)
	[71485] = 50362,
	[71492] = 50362,
	[71486] = 50362,
	[71484] = 50362,
	[71491] = 50362,
	[71487] = 50362,

	-- Deathbringer's Will (Heroic)
	[71556] = 50363,
	[71560] = 50363,
	[71558] = 50363,
	[71561] = 50363,
	[71559] = 50363,
	[71557] = 50363,

	[71403] = 50198,			-- Needle-Encrusted Scorpion
	[71610] = 50359,			-- Althor's Abacus
	[71633] = 50352,			-- Corpse-tongue coin

	-- ICC trinkets
	[71601] = 50353,			-- Dislodged Foreign Object
	[71584] = 50358,			-- Purified Lunar Dust
	[71401] = 50342,			-- Whispering Fanged Skull
	[71605] = 50360,			-- Phylactery of the Nameless Lich
	
	-- Heroic ICC trinkets
	[71541] = 50343,			-- Whispering Fanged Skull
	[71641] = 50366,			-- Althor's Abacus
	[71639] = 50349,			-- Corpse-tongue coin
	[71644] = 50348,			-- Dislodged Foreign Object
	[71636] = 50365,			-- Phylactery of the Nameless Lich

	-- RS trinkets
	[75458] = 54569,			-- Sharpened Twilight Scale
	[75466] = 54572,			-- Charred Twilight Scale
	-- [75490] = 54573,			-- Glowing Twilight Scale
	[75477] = 54571,			-- Petrified Twilight Scale

	-- Heroic RS trinkets
	[75456] = 54590,			-- Sharpened Twilight Scale
	[75473]	= 54588,			-- Charred Twilight Scale
	-- [75495] = 54589,			-- Glowing Twilight Scale
	[75480]	= 54591,			-- Petrified Twilight Scale

	-- DK T9 2pc. WTF.
	[67117] = {48501, 48502, 48503, 48504, 48505, 48472, 48474, 48476, 48478, 48480, 48491, 48492, 48493, 48494, 48495, 48496, 48497, 48498, 48499, 48500, 48486, 48487, 48488, 48489, 48490, 48481, 48482, 48483, 48484, 48485},


	-- pvp sirus
	
	[305696] = 100109,


	-- WotLK Epix
	[67671] = 47214,			-- Banner of Victory
	[67669] = 47213, 			-- Abyssal Rune 
	[64772] = 45609, 			-- Comet's Trail
	[65024] = 46038, 			-- Dark Matter
	[60443] = 40371,			-- Bandit's Insignia
	[64790] = 45522,			-- Blood of the Old God
	[60203] = 42990,			-- Darkmoon Card: Death
	[60494] = 40255,			-- Dying Curse
	[65004] = 65005,			-- Elemental Focus Stone
	[60492] = 39229,			-- Embrace of the Spider
	[60530] = 40258,			-- Forethought Talisman
	[60437] = 40256,			-- Grim Toll
	[49623] = 37835, 			-- Je'Tze's Bell
	[65019] = 45931, 			-- Mjolnir Runestone
	[64741] = 45490,			-- Pandora's Plea
	[65014] = 45286,			-- Pyrite Infuser
	[65003] = 45929, 			-- Sif's Remembrance
	[60538] = 40382,			-- Soul of the Dead
	[58904] = 43573,			-- Tears of Bitter Anguish
	[60062] = {40685, 49078},	-- The Egg of Mortal Essence, Ancient Pickled Egg
	[64765] = 45507, 			-- The General's Heart

	-- WotLK Blues
	[51353]	= 38358,			-- Arcane Revitalizer
	[60218] = 37220,			-- Essence of Gossamer
	[60479] = 37660,			-- Forge Ember
	[51348] = 38359,			-- Goblin Repetition Reducer
	[63250] = 45131,			-- Jouster's Fury
	[63250] = 45219,			-- Jouster's Fury
	[60302] = 37390,			-- Meteorite Whetstone
	[54808] = 40865, 			-- Noise Machine
	[60483] = 37264, 			-- Pendulum of Telluric Currents
	[52424] = 38675, 			-- Signet of the Dark Brotherhood
	[55018] = 40767,			-- Sonic Booster
	[52419] = 38674,			-- Soul Harvester's Charm
	-- [18350] = 37111,			-- Soul Preserver, no internal cooldown
	[60520] = 37657,			-- Spark of Life
	[60307] = 37064,			-- Vestige of Haldor

	-- Greatness cards
	[60233] = {44253, 44254, 44255, 42987},		-- Greatness, AGI
	[60235] = {44253, 44254, 44255, 42987},		-- Greatness, SPI
	[60229] = {44253, 44254, 44255, 42987},		-- Greatness, INT
	[60234] = {44253, 44254, 44255, 42987},		-- Greatness, STR

	-- Vanilla Epix
	[23684] = 19288,			-- Darkmoon Card: Blue Dragon
	-- sirus all?
	[307754] = 103184,      -- pvp
	[308886] = 103382,
	[308883] = 103384,
	[305695] = 103383,	[308881] = 103381,
	[307752] = 103181,
	[305695] = 103183,
	[307757] = 103182,
	[307754] = 103184,
	--pve
	[307880] = 33829,
	[71640] = 33830,
	[307878] = 33831,
	[300967] = 34029,
	[313543] = 151380,
	[313523] = 151299,
	[300144] = 65140,
	[300134] = 65118,
	[300136] = 58183,
	[310194] = 77999,

	[305503] = 61411,
	[305496] = 61462,
	[305500] = 80773,
	[305685] = 100103,
	[305706] = 100119,
	[305695] = 100111,
	[305693] = 100107,

	[300131] = 60233,

	[305100] = 28823,
	[305695] = 100110,
	[304670] = 28727,
	[305102] = 28830,
	[304658] = 28528,
	[304661] = 28590,
	[304667] = 28785,
	[305703] = 100118,


	-- tolgorod
		--plamya
		
	[314758] = 153720,
	[314760] = 153725,
	[314762] = 153730,
	[314764] = 153735,
	[314766] = 153740,

	[314758] = 153974,
	[314760] = 153979,
	[314762] = 153984,
	[314764] = 153989,
	[314766] = 153994,

	[314758] = 154126,
	[314760] = 154131,
	[314762] = 154136,
	[314764] = 154141,
	[314766] = 154146,

	-- Obyaz obesh

	[314776] = 153721,
	[314778] = 153726,
	[314780] = 153731,
	[314782] = 153735,
	[314784] = 153741,

	[314776] = 153975,
	[314778] = 153980,
	[314780] = 153985,
	[314782] = 153990,
	[314784] = 153995,

	[314776] = 154127,
	[314778] = 154132,
	[314780] = 154137,
	[314782] = 154142,
	[314784] = 154147,




	-- rog zverya

	[314786] = 153722,
	[314788] = 153727,
	[314790] = 153732,
	[314792] = 153737,
	[314794] = 153742,

	[314786] = 153976,
	[314788] = 153981,
	[314790] = 153986,
	[314792] = 153991,
	[314794] = 153996,

	[314786] = 154128,
	[314788] = 154133,
	[314790] = 154138,
	[314792] = 154143,
	[314794] = 154148,

	------ serdze groma 

	[314796] = 153723,
	[314798] = 153728,
	[314800] = 153733,
	[314702] = 153738,
	[314704] = 153743,

	[314796] = 153977,
	[314798] = 153982,
	[314800] = 153987,
	[314702] = 153992,
	[314704] = 153997,

	[314796] = 154129,
	[314798] = 154134,
	[314800] = 154139,
	[314702] = 154144,
	[314704] = 154149,

	--- afk shield
	[315520] = 154408,
	[314522] = 154409,
	[314524] = 154410,
	[314526] = 154411,
	[314528] = 154412,

	[315520] = 154413,
	[314522] = 154414,
	[314524] = 154415,
	[314526] = 154416,
	[314528] = 154417,

	[315520] = 154418,
	[314522] = 154419,
	[314524] = 154420,
	[314526] = 154421,
	[314528] = 154422,



	-- воля 284
	[300138] = 58184,	[300139] = 58184,
	[300140] = 58184,	[300141] = 58184,
	[300142] = 58184,
	

	--
	[305691] = 100106,
	[305683] = 100102,
	[305681] = 100100,
	[305700] = 100116,
	
	[305695] = 100108,
	[305689] = 100104,
	[60487] = 40373,--Экстракт некромантского могущества
	[60493] = 40255,-- Исчезающее проклятие
	[60537] = 40382, --Душа умершего
	[60436] = 40256, --мрачный перезвон
	[305697] = 100117,
	[305687] = 100105,
	[305695] = 100109,
	[305679] = 100101,


	---- Символ  защитника
	[314726] = 153670,
	[314734] = 153675,
	[314742] = 153680,
	[314750] = 153685,
	[314768] = 153690,
	[314726] = 153924,
	[314734] = 153929,
	[314742] = 153934,
	[314750] = 153939,
	[314768] = 153944,
	[314726] = 154076,
	[314734] = 154081,
	[314742] = 154086,
	[314750]= 154091,
	[314768]= 154096,

	--Символ воителя 45
	[314728] = 153672,
	[314736] = 153677,
	[314744] = 153682,
	[314752] = 153687,
	[314770] = 153692,
	[314728] = 153926,
	[314736] = 153931,
	[314744] = 153936,
	[314752] = 153941,
	[314770] = 153946,
	[314728] = 154078,
	[314736] = 154083,
	[314744] = 154088,
	[314752] = 154093,
	[314770] = 154098,

--	Символ лекаря 45
	[314729] = 153674,
	[314737] = 153679,
	[314745] = 153684,
	[314753] = 153689,
	[314771] = 153694,
	[314729] = 153928,
	[314737] = 153933,
	[314745] = 153938,
	[314753] = 153943,
	[314771] = 153948,
	[314729] = 154080,
	[314737] = 154085,
	[314745] = 154090,
	[314753] = 154095,
	[314771] = 154100,


--	Символ мудреца 45
	[314727] = 153671,
	[314735] = 153676,
	[314743] = 153681,
	[314751] = 153686,
	[314769] = 153691,
	[314727] = 153925,
	[314735] = 153930,
	[314743] = 153935,
	[314751] = 153940,
	[314769] = 153945,
	[314727] = 154077,
	[314735] = 154082,
	[314743] = 154087,
	[314751] = 154092,
	[314769] = 154097,


--	Символ хитреца 45
	[314728] = 153673,
	[314736] = 153678,
	[314744] = 153683,
	[314752] = 153688,
	[314770] = 153693,
	[314728] = 153927,
	[314736] = 153932,
	[314744] = 153937,
	[314752] = 153942,
	[314770] = 153947,
	[314728] = 154079,
	[314736] = 154084,
	[314744] = 154089,
	[314752] = 154094,
	[314770] = 154099,


	--valanir
	[313104] = 151821,

	--mirodrob
	[36111] = 30090,


	}

-- spell ID = {enchant ID, slot1[, slot2]}
local enchants = {
	-- Cataclysm
	[74245] = {4099, 16, 17},		-- Landslide
	[74241] = {4097, 16},			-- Power Torrent
	[74221] = {4083, 16, 17},		-- Hurricane
	[74224] = {4084, 16},			-- Heartsong
	[75170] = {4115, 15},			-- Lightweave Embroidery (Rank 2)
	[75176] = {4118, 15},			-- Swordguard Embroidery (Rank 2)
	[75173] = {4116, 15},			-- Darkglow Embroidery (Rank 2)
	[95712] = {4175, 18},			-- Gnomish X-Ray Scope

	-- WotLK
	[55637] = {3722, 15},			-- Lightweave Embroidery (Rank 1)
	[55775] = {3730, 15},			-- Swordguard Embroidery (Rank 1)
	[55767] = {3728, 15},			-- Darkglow Embroidery (Rank 1)
	[59626] = {3790, 16},			-- Black Magic
}

-- ICDs on metas assumed to be 45 sec. Needs testing.
local metas = {
	-- I've commented these two out, because there aren't really any tactical decisions you could make based on them
	-- [55382] = 41401,				-- Insightful Earthsiege Diamond
	-- [32848] = 25901,				-- Insightful Earthstorm Diamond

	[23454] = 25899,				-- Brutal Earthstorm Diamond
	[55341] = 41385, 				-- Invigorating Earthsiege Diamond
	[18803] = 25893,				-- Mystical Skyfire Diamond
	[32845]	= 25898,				-- Tenacious Earthstorm Diamond
	[39959] = 32410,				-- Thundering Skyfire Diamond
	[55379] = 41400					-- Thundering Skyflare Diamond
}

-- Spell ID => cooldown, in seconds
-- If an item isn't in here, 45 sec is assumed.
local cooldowns = {
	-- Tol Barad factions
	[91192] = 50,			-- Mandala of Stirring Patterns, confirm!
	[91047] = 75,			-- Stump of Time

	-- Valour Vendor 4.0
	[92233] = 30,			-- Bedrock Talisman

	-- Cataclysm Raid 372
	[92320] = 50,			-- Theralion's Mirror, confirm!
	[92355] = 30,			-- Symbiotic Worm
	[92349] = 75,			-- Prestor's Talisman of Machination
	[92345] = 100,			-- Heart of Rage, confirm!
	[92332] = 75,			-- Fall of Mortality, confirm!
	[92351] = 50,			-- Essence of the Cyclone
	[92342] = 75,			-- Crushing Weight, confirm!
	[92318] = 100,			-- Bell of Enraging Resonance
	--[92331] = 30,			-- Jar of Ancient Remedies

	-- Cataclysm Raid 359
	[91024] = 50,			-- Theralion's Mirror, confirm!
	[92235] = 30,			-- Symbiotic Worm
	[92124] = 75,			-- Prestor's Talisman of Machination
	[91816] = 100,			-- Heart of Rage, confirm!
	[91184] = 75,			-- Fall of Mortality, confirm!
	[92126] = 50,			-- Essence of the Cyclone
	[91821] = 75,			-- Crushing Weight, confirm!
	[91007] = 100,			-- Bell of Enraging Resonance
	--[91322] = 30,			-- Jar of Ancient Remedies
	[92108] = 50,			-- Unheeded Warning, confirm!

	-- Cataclysm Dungeon 346
	[90992] = 50,			-- Anhuur's Hymnal
	[91149] = 100,			-- Blood of Isiset
	[92087] = 50,			-- Grace of the Herald
	[91364] = 100,			-- Heart of Solace
	[92091] = 75,			-- Key to the Endless Chamber
	[92184] = 30,			-- Leaden Despair
	[92094] = 50,			-- Left Eye of Rajh
	[92174] = 80,			-- Porcelain Crab, confirm!
	[91143] = 75,			-- Rainsong
	[91368] = 50,			-- Right Eye of Rajh
	[91002] = 10,			-- Sorrowsong, very spammy
	[91139] = 75,			-- Tear of Blood
	[90898] = 75,			-- Tendrils of Burrowing Dark
	[92205] = 60,			-- Throngus's Finger
	[90887] = 75,			-- Witching Hourglass

	-- Cataclysm Dungeon and World drops 308-333
	[90989] = 50,			-- Anhuur's Hymnal
	[91147] = 100,			-- Blood of Isiset
	[91363] = 100,			-- Heart of Solace
	[92096] = 50,			-- Left Eye of Rajh
	[91370] = 50,			-- Right Eye of Rajh
	[90996] = 10,			-- Sorrowsong, very spammy
	[92208] = 60,			-- Throngus's Finger
	[92052] = 50,			-- Heart of the Vile
	[92069] = 75,			-- Key to the Endless Chamber
	[92179] = 30,			-- Leaden Despair
	[91141] = 75,			-- Rainsong
	[91138] = 75,			-- Tear of Blood
	[90896] = 75,			-- Tendrils of Burrowing Dark
	[92052] = 50,			-- Grace of the Herald
	[90885] = 75,			-- Witching Hourglass

	-- Cataclysm Quest rewards (and a 5man trinket, sneaky Blizzard!)
	[92166] = 80,			-- Harrison's Insignia of Panache, Schnotzz's Medallion of Command, Talisman of Sinister Order, Porcelain Crab, confirm!

	-- PvP Lvl 85
	[85027] = 50,			-- Vicious Gladiator's Insignia of Dominance
	[85032] = 50,			-- Vicious Gladiator's Insignia of Victory
	[85022] = 50,			-- Vicious Gladiator's Insignia of Conquest
	[92218] = 50,			-- Bloodthirsty Gladiator's Insignia of Dominance
	[92216] = 50,			-- Bloodthirsty Gladiator's Insignia of Victory
	[92220] = 50,			-- Bloodthirsty Gladiator's Insignia of Conquest

	-- Cataclysm enchants
	[74224] = 20,			-- Heartsong

	-- ICC rep rings
	[72416] = 60,
	[72412] = 60,
	[72418] = 60,
	[72414] = 60,

	[60488] = 15,
	[51348] = 10,
	[51353] = 10,
	[54808] = 60,
	[55018] = 60,
	[52419] = 30,
	[59620] = 90,
	[55382] = 15,
	[32848] = 15,
	[55341] = 90,
	[48517] = 30,
	[48518] = 30,
	[47755] = 12,

	-- Deathbringer's Will, XI from #elitistjerks says it's 105 sec so if it's wrong yell at him.
	[71485] = 105,
	[71492] = 105,
	[71486] = 105,
	[71484] = 105,
	[71491] = 105,
	[71487] = 105,

	-- Deathbringer's Will (Heroic)
	[71556] = 105,
	[71560] = 105,
	[71558] = 105,
	[71561] = 105,
	[71559] = 105,
	[71557] = 105,

	-- Phylactery of the Nameless Lich
	[71605] = 90,
	-- Phylactery of the Nameless Lich (Heroic)
	[71636] = 90,

	-- RS trinkets
	[75458] = 45,				-- Sharpened Twilight Scale
	[75466] = 45,				-- Charred Twilight Scale
	-- [75490] = 54573,			-- Glowing Twilight Scale
	[75477] = 45,				-- Petrified Twilight Scale

	-- Heroic RS trinkets
	[75456] = 45,				-- Sharpened Twilight Scale
	[75473] = 45,				-- Charred Twilight Scale
	-- [75495] = 54589,			-- Glowing Twilight Scale
	[75480] = 45,				-- Petrified Twilight Scale

	-- Black Magic
	[59626] = 35,
	-- pvp sirus
	[305696] = 90,
	[307754] = 45,
	[308886] = 45,
	[308883] = 45,
	[305695] = 45,
	[308881] = 45,
	[307752] = 45,
	[305695] = 45,
	[307757] = 45,
	[307754] = 45,
	[307757] = 45,
	
	-- pve сирус
	[307880] = 45, -- усохшая Голова ЗА
	[71640] = 30,
	[307878] = 45,
	[300967]= 45,
	[313543] = 20,
	[313523] = 45,
	[300144] = 45,
	[300134] = 45,
	[300136] = 45,
	[310194] = 45,

	[300131] = 45,


	[305503] = 6,
	[305496] = 60,
	[305500] = 90,
	[305685] = 45,
	[305706] = 45,
	[305695] = 90,
	[305693] = 45,

	[305100] = 45,
	[305695] = 90,
	[304670] = 45,
	[305102] = 45,
	[304658] = 45,
	[304661] = 45,
	[304667] = 45,
	[305703] = 45,

	-- tolgorod
		--plamya
		
	[314758] = 15,
	[314760] = 15,
	[314762] = 15,
	[314764] = 15,
	[314766] = 15,

	[314758] = 15,
	[314760] = 15,
	[314762] = 15,
	[314764] = 15,
	[314766] = 15,

	[314758] = 15,
	[314760] = 15,
	[314762] = 15,
	[314764] = 15,
	[314766] = 15,


	-- ob obesh
	[314776] = 45,
	[314778] = 45,
	[314780] = 45,
	[314782] = 45,
	[314784] = 45,

	[314776] = 45,
	[314778] = 45,
	[314780] = 45,
	[314782] = 45,
	[314784] = 45,

	[314776] = 45,
	[314778] = 45,
	[314780] = 45,
	[314782] = 45,
	[314784] = 45

	-- rog zverya
	[314786] = 45,
	[314788] = 45,
	[314790] = 45,
	[314792] = 45,
	[314794] = 45,

	[314786] = 45,
	[314788] = 45,
	[314790] = 45,
	[314792] = 45,
	[314794] = 45,

	[314786] = 45,
	[314788] = 45,
	[314790] = 45,
	[314792] = 45,
	[314794] = 45,

	----  serdze groma
		
	[314796] = 45,
	[314798] = 45,
	[314800] = 45,
	[314702] = 45,
	[314704] = 45,

	[314796] = 45,
	[314798] = 45,
	[314800] = 45,
	[314702] = 45,
	[314704] = 45,

	[314796] = 45,
	[314798] = 45,
	[314800] = 45,
	[314702] = 45,
	[314704] = 45,
	
	--- afk shield
	[315520] = 15,
	[314522] = 15,
	[314524] = 15,
	[314526] = 15,
	[314528] = 15,

	[315520] = 15,
	[314522] = 15,
	[314524] = 15,
	[314526] = 15,
	[314528] = 15,

	[315520] = 15,
	[314522] = 15,
	[314524] = 15,
	[314526] = 15,
	[314528] = 15,



	--воля 284
	[300138] = 105,	[300139] = 105,
	[300140] = 105,	[300141] = 105,
	[300142] = 105,

	---
	[305691] = 45,
	[305683] = 45,
	[305681] = 45,
	[305700] = 45,
	
	[305695] = 90,
	[305689] = 45,
	[60487] = 45,--Экстракт некромантского могущества
	[60493] = 45,-- Исчезающее проклятие
	[60537] = 45, --Душа умершего
	[60436] = 45, --мрачный перезвон
	[305697] = 45,
	[305687] = 45,
	[305695] = 90,
	[305679] = 45,

---- Символ  защитника
	[314726] = 45,
	[314734] = 45,
	[314742] = 45,
	[314750] = 45,
	[314768] = 45,
	[314726] = 45,
	[314734] = 45,
	[314742] = 45,
	[314750] = 45,
	[314768] = 45,
	[314726] = 45,
	[314734] = 45,
	[314742] = 45,
	[314750]= 45,
	[314768]= 45,


	--Символ воителя 45
	[314728] = 45,
	[314736] = 45,
	[314744] = 45,
	[314752] = 45,
	[314770] = 45,
	[314728] = 45,
	[314736] = 45,
	[314744] = 45,
	[314752] = 45,
	[314770] = 45,
	[314728] = 45,
	[314736] = 45,
	[314744] = 45,
	[314752] = 45,
	[314770] = 45,

	--		Символ лекаря 45
	[314729] = 45,
	[314737] = 45,
	[314745] = 45,
	[314753] = 45,
	[314771] = 45,
	[314729] = 45,
	[314737] = 45,
	[314745] = 45,
	[314753] = 45,
	[314771] = 45,
	[314729] = 45,
	[314737] = 45,
	[314745] = 45,
	[314753] = 45,
	[314771] = 45,
	--	Символ мудреца 45
	[314727] = 45,
	[314735] = 45,
	[314743] = 45,
	[314751] = 45,
	[314769] = 45,
	[314727] = 45,
	[314735] = 45,
	[314743] = 45,
	[314751] = 45,
	[314769] = 45,
	[314727] = 45,
	[314735] = 45,
	[314743] = 45,
	[314751] = 45,
	[314769] = 45,

--		Символ хитреца 45
	[314728] = 45,
	[314736] = 45,
	[314744] = 45,
	[314752] = 45,
	[314770] = 45,
	[314728] = 45,
	[314736] = 45,
	[314744] = 45,
	[314752] = 45,
	[314770] = 45,
	[314728] = 45,
	[314736] = 45,
	[314744] = 45,
	[314752] = 45,
	[314770] = 45,

	-- val anir ger
	[313104] = 60,
	-- mirodrob
	[36111] = 60,

	}
	--[[Ангел Божий, что днесь да присно за моей спиной стоишь! Ты всякое деяние мое видишь, слово каждое слышишь, думу всякую читаешь. К тебе моя грешная душа обращается да помощи просит. Помолись со мной Господу за грехи мои, прошлые да грядущие. Наставь меня на путь истинный, к Отцу нашему ведущий. Подсоби в делах праведных, защити от лиха худого. Привнеси процветание в житие мое во имя Отца, и Сына, и Святого Духа. Аминь!»



]]--

-- Procced spell effect ID = unique name
-- The name doesn't matter, as long as it's non-numeric and unique to the ICD.
local talents = {
	-- Druid
	[48517] = "Eclipse",
	[48518] = "Eclipse",
	--[16886] = "Nature's Grace", -- resets after 60s or with Eclipses

	-- Hunter
	[56453] = "Lock and Load",

	-- Death Knight
	[52286] = "Will of the Necropolis",

	-- Priest
	[47755] = "Rapture",
}
-----------------------------------------------------------------------
-- Don't edit past this line									--
-----------------------------------------------------------------------

------------------------------------
-- Upgrade this data into the lib
------------------------------------

lib.spellToItem = lib.spellToItem or {}
lib.cooldowns = lib.cooldowns or {}
lib.enchants = lib.enchants or {}
lib.metas = lib.metas or {}
lib.talents = lib.talents or {}

local tt, tts = {}, {}
local function merge(t1, t2)
	wipe(tts)
	for _, v in ipairs(t1) do
		tts[v] = true
	end
	for _, v in ipairs(t2) do
		if not tts[v] then
			tinsert(t1, v)
		end
	end
end

for k, v in pairs(spellToItem) do
	local e = lib.spellToItem[k]
	if e and e ~= v then
		if type(e) == "table" then
			if type(v) ~= "table" then
				wipe(tt)
				tinsert(tt, v)
			end
			merge(e, tt)
		else
			lib.spellToItem[k] = {e, v}
		end
	else
		lib.spellToItem[k] = v
	end
end

for k, v in pairs(cooldowns) do
	lib.cooldowns[k] = v
end

for k, v in pairs(enchants) do
	lib.enchants[k] = v
end

for k, v in pairs(metas) do
	lib.metas[k] = v
end

for k, v in pairs(talents) do
	lib.talents[k] = v
end
