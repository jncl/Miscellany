local aName, aObj = ...
local _G = _G

local function printD(...)
	if not aObj.debug then return end
	print(("%s [%s.%03d]"):format(aName, _G.date("%H:%M:%S"), (_G.GetTime() % 1) * 1000), ...)
end

local IsQuestFlaggedCompleted, SlashCmdList = _G.IsQuestFlaggedCompleted, _G.SlashCmdList

-- Timeless Isle Chests
function aObj:timelessIsleChests()

	-- Treasure, Treasure Everywhere Achievement (http://www.wowhead.com/achievement=8729#comments)

	local function checkTable(tab)

		local todo = false
		for k, info in pairs(tab) do
			if not IsQuestFlaggedCompleted(info["questID"]) then
				printD(stringf("%s %s %s", "Timeless Isle", info["coords"], k))
				SlashCmdList.TOMTOM_WAY(stringf("%s %s %s", "Timeless Isle", info["coords"], k))
				todo = true
			end
		end
		if not todo then print("All Weekly Timeless Isle Chests have been found") end

	end

	-- Weekly Reset Chests
	local wrChests = {
		["Blackguard's Jetsam, enter cave here"] = { ["questID"] = 32956, ["coords"] = "17.2 57.3" }, -- "22.5 58.9"
		["Sunken Treasure, kill mobs for key"]  = { ["questID"] = 32957, ["coords"] = "40.4 92.3" },
		["Rope-Bound Treasure Chest, start here and rope walk"] = { ["questID"] = 32968, ["coords"] = "60.2 45.9" }, -- "53.9 47.1" },
		["Gleaming Treasure Chest, start here and jump the pillars"] = { ["questID"] = 32969, ["coords"] =  "51.4 73.3" }, -- "49.7 69.5"
		["Gleaming Treasure Satchel"] = { ["questID"] = 32970, ["coords"] = "70.7 80.9" },
		["Access Mist-Covered Treasure Chests via the Gleaming Crane Statue"] = { ["questID"] = 32971, ["coords"] = "58.5 60.0" },
	}
	checkTable(wrChests)

	-- One Time Chests
	local otChests = {
		["Moss-Covered Chest 01"]  = { ["questID"] = 33170, ["coords"] = "36.7 34.1" },
		["Moss-Covered Chest 02"]  = { ["questID"] = 33171, ["coords"] = "25.5 27.2" },
		["Moss-Covered Chest 03"]  = { ["questID"] = 33172, ["coords"] = "27.4 39.1" },
		["Moss-Covered Chest 04"]  = { ["questID"] = 33173, ["coords"] = "30.7 36.5" },
		["Moss-Covered Chest 05"]  = { ["questID"] = 33174, ["coords"] = "22.4 35.4" },
		["Moss-Covered Chest 06"]  = { ["questID"] = 33175, ["coords"] = "22.1 49.3" },
		["Moss-Covered Chest 07"]  = { ["questID"] = 33176, ["coords"] = "24.8 53.0" },
		["Moss-Covered Chest 08"]  = { ["questID"] = 33177, ["coords"] = "25.7 45.8" },
		["Moss-Covered Chest 09"]  = { ["questID"] = 33178, ["coords"] = "22.3 68.1" },
		["Moss-Covered Chest 10"]  = { ["questID"] = 33179, ["coords"] = "26.8 68.7" },
		["Moss-Covered Chest 11"]  = { ["questID"] = 33180, ["coords"] = "31.0 76.3" },
		["Moss-Covered Chest 12, in house"]  = { ["questID"] = 33181, ["coords"] = "35.3 76.4" },
		["Moss-Covered Chest 13, in house"]  = { ["questID"] = 33182, ["coords"] = "38.7 71.6" },
		["Moss-Covered Chest 14, in house"]  = { ["questID"] = 33183, ["coords"] = "39.8 79.5" },
		["Moss-Covered Chest 15, below jetty"]  = { ["questID"] = 33184, ["coords"] = "34.8 84.2" },
		["Moss-Covered Chest 16"]  = { ["questID"] = 33185, ["coords"] = "43.6 84.1" },
		["Moss-Covered Chest 17"]  = { ["questID"] = 33186, ["coords"] = "47.0 53.7" },
		["Moss-Covered Chest 18"]  = { ["questID"] = 33187, ["coords"] = "46.7 46.7" },
		["Moss-Covered Chest 19"]  = { ["questID"] = 33188, ["coords"] = "51.2 45.7" },
		["Moss-Covered Chest 20"]  = { ["questID"] = 33189, ["coords"] = "55.5 44.3" },
		["Moss-Covered Chest 21"]  = { ["questID"] = 33190, ["coords"] = "58.0 50.7" },
		["Moss-Covered Chest 22"]  = { ["questID"] = 33191, ["coords"] = "65.7 47.8" },
		["Moss-Covered Chest 23"]  = { ["questID"] = 33192, ["coords"] = "63.8 59.2" },
		["Moss-Covered Chest 24"]  = { ["questID"] = 33193, ["coords"] = "64.9 75.6" },
		["Moss-Covered Chest 25"]  = { ["questID"] = 33194, ["coords"] = "60.2 66.0" },
		["Moss-Covered Chest 26"]  = { ["questID"] = 33195, ["coords"] = "49.7 65.7" },
		["Moss-Covered Chest 27"]  = { ["questID"] = 33196, ["coords"] = "53.1 70.8" },
		["Moss-Covered Chest 28"]  = { ["questID"] = 33197, ["coords"] = "52.7 62.7" },
		["Moss-Covered Chest 29"]  = { ["questID"] = 33227, ["coords"] = "61.7 88.5" },
		["Moss-Covered Chest in Stump 30"]  = { ["questID"] = 33198, ["coords"] = "44.2 65.3" },
		["Moss-Covered Chest in Stump 31"]  = { ["questID"] = 33199, ["coords"] = "26.0 61.4" },
		["Moss-Covered Chest in Stump 32"]  = { ["questID"] = 33200, ["coords"] = "24.6 38.5" },
		["Take bird to Lake for Moss-Covered Chest 33"]  = { ["questID"] = 33201, ["coords"] = "59.9 31.3" },
		["Moss-Covered Chest 34"]  = { ["questID"] = 33202, ["coords"] = "29.7 31.8" },
		["Skull-Covered Chest, inside Cavern of Lost Spirits entrance here"]  = { ["questID"] = 33203, ["coords"] = "43.1 41.5" }, -- "46.7 32.3"
		["Take bird for Sturdy Chest 01"]  = { ["questID"] = 33204, ["coords"] = "28.2 35.2" },
		["Take bird for Sturdy Chest 02"]  = { ["questID"] = 33205, ["coords"] = "26.8 64.9" },
		["Sturdy Chest 01"] = { ["questID"] = 33206, ["coords"] = "64.6 70.4" },
		["Sturdy Chest 02"] = { ["questID"] = 33207, ["coords"] = "59.2 49.5" },
		["Smoldering Chest 01"] = { ["questID"] = 33208, ["coords"] = "69.5 32.9" },
		["Smoldering Chest 02"] = { ["questID"] = 33209, ["coords"] = "54.0 78.2" },
		["Take bird for Blazing Chest and enter here"]  = { ["questID"] = 33210, ["coords"] = "40.75 25.35" }, -- "47.6 27.6"
	}
	checkTable(otChests)

end

-- Isle of Thunder Chests
function aObj:isleOfThunderChests()

	local function checkTable(tab)

		for k, info in pairs(tab) do
			if not IsQuestFlaggedCompleted(info["questID"]) then
				printD(stringf("%s %s %s", "Timeless Isle", info["coords"], k))
				SlashCmdList.TOMTOM_WAY(stringf("%s %s %s", "Isle of Thunder", info["coords"], k))
			else
				print("All Weekly Isle of Thunder Chests have been found")
			end
		end

	end

	-- check this page for other weekly items: http://www.wowhead.com/object=218593#comments

	-- Weekly Reset Chests
	local wrChests = {
		["Trove of the Thunder King"] = { ["questID"] = 32609, ["coords"] = { "28.8 80.8", "33.2 60.5", "33.3 76.3", "33.4 57.5", "33.8 60.3", "34.8 47.6", "35.6 63.8", "36.1 58.4", "36.9 60.7", "37.0 60.0", "37.0 68.1", "37.9 61.0", "38.9 54.6", "38.9 59.9", "39.1 76.8", "39.6 64.9", "40.8 74.8", "43.5 78.6", "43.8 82.8", "44.1 56.2", "44.3 67.4", "45.2 50.7", "46.3 57.4", "46.6 61.6", "47.4 72.4", "47.7 25.8", "47.9 82.1", "48.0 29.2", "48.8 42.9", "49.0 27.2", "50.2 44.2", "50.3 27.2", "51.3 74.9", "51.5 89.6", "51.6 73.8", "52.7 45.4", "52.9 77.2", "53.2 24.5", "53.8 82.8", "54.2 53.7", "55.1 49.2", "55.4 53.7", "56.8 45.6", "57.5 48.5", "58.0 39.6", "59.2 56.9", "59.3 56.8", "59.8 47.0", "63.5 39.3", "63.8 48.2", "66.1 40.9" }, },
	}
	checkTable(wrChests)

end

function aObj:pandariaTreasures()

	local function checkTable(z, tab)

		for a, info in pairs(tab) do
			if not IsQuestFlaggedCompleted(info["questID"]) then
				for _, v in pairs(info["coords"]) do
					SlashCmdList.TOMTOM_WAY(stringf("%s %s %s", z, v, a))
				end
			end
		end

	end

	-- Is Another Man's Treasure Achievement (http://www.wowhead.com/achievement=7284#comments)
	local iamt = {
		["The Jade Forest"] = {
			["Ancient Jinyu Staff (BoA), in the river"] = { ["questID"] = 31402, ["coords"] = { "47.1 67.4", "46.2 71.2", "44.9 64.6" }, },
			["Ancient Pandaren Mining Pick (BoA), in the Greenstone Quarry, entrance at SE waypoint"] = { ["questID"] = 31399, ["coords"] = { "40.0 40.7", "46.1 29.3", "44.1 27.0", "43.8 30.7" }, },
			["Hammer of Ten Thunders (BoA)"] = { ["questID"] = 31403, ["coords"] = { "43.0 11.6", "41.7 17.6", "41.2 13.8", "40.2 13.7" }, },
			["Talk to Jade Warrior Statue for Jade Infused Blade (BoA)"] = { ["questID"] = 31307, ["coords"] = { "39.26 46.65" }, },
			["Wodin's Mantid Shanker (BoA)"] = { ["questID"] = 31397, ["coords"] = { "39.4 7.3" }, },
		},
		["Valley of the Four Winds"] = {
			["Talk to Ghostly Pandaren Fisherman for Ancient Pandaren Fishing Charm (BoP)"] = { ["questID"] = 31284, ["coords"] = { "46.8 24.3" }, },
			["Talk to Ghostly Pandaren Craftsman for Ancient Pandaren Woodcutter (grey)"] = { ["questID"] = 31292, ["coords"] = { "45.4 38.4" }, },
			["Cache of Pilfered Goods, in Springtail Warren, entrance here (BoP)"] = { ["questID"] = 31406, ["coords"] = { "43.5 35.0" }, },
			["Staff of the Hidden Master (BoA)"] = { ["questID"] = 31407, ["coords"] = { "15.4 29.1", "19.1 37.9", "17.5 35.7", "15.0 33.7", "19.0 42.5" }, },
		},
		["Krasarang Wilds"] = {
			["Equipment Locker, at bottom of Ship (BoP)"] = { ["questID"] = 31410, ["coords"] = { "42.3 92.0" }, },
			["Pandaren Fishing Spear, behind Uncle Deming"] = { ["questID"] = 31409, ["coords"] = { "50.8 49.3" }, },
			["Barrel of Banana Infused Rum, be careful of Spriggin (Rare)"] = { ["questID"] = 31411, ["coords"] = { "52.3 88.7" }, },
		},
		["Townlong Steppes"] = {
			["Yaungol Fire Carrier (BoA)"] = { ["questID"] = 31425, ["coords"] = { "66.2 44.7", "66.8 48.0" }, },
		},
		["Kun-Lai Summit"] = {
			["Hozen Warrior Spear (BoA), in The Deeper, entrance here"] = { ["questID"] = 31413, ["coords"] = { "52.9 71.0" }, },
			["Talk to Frozen Trail Packer for Kafa Press (BoP), in Yeti Cave, entrance here"] = { ["questID"] = 31304, ["coords"] = { "37.5 78.0" }, },
			["Sprite's Cloth Chest, in Pranksters' Hollow, entrance here"] = { ["questID"] = 31412, ["coords"] = { "72.9 73.4" }, },
			["Stash of Yaungol Weapons"] = { ["questID"] = 31421, ["coords"] = { "71.2 62.6", "70.0 63.8" }, },
			["Tablet of Ren Yun (cooking recipe)"] = { ["questID"] = 31417, ["coords"] = { "44.7 52.4" }, },
		},
		["Dread Wastes"] = {
			["Blade of the Poisoned Mind (BoA)"] = { ["questID"] = 31438, ["coords"] = { "28.9 41.9" }, },
			["Blade of the Prime (BoA), inside Mistblade Den, entrance here"] = { ["questID"] = 31433, ["coords"] = { "66.7 63.7" }, },
			["Bloodsoaked Chitin Fragment (BoP), in Muckscale Grotto, entrance here"] = { ["questID"] = 31436, ["coords"] = { "25.8 54.4" }, },
			["Dissector's Staff of Mutation (BoA)"] = { ["questID"] = 31435, ["coords"] = { "30.2 90.7" }, },
			["Amber Encased Necklace (BoA)"] = { ["questID"] = 31431, ["coords"] = { "33.0 30.1" }, },
			["Malik's Stalwart Spear (BoA)"] = { ["questID"] = 31430, ["coords"] = { "48.7 30.0" }, },
			["Talk to Glinting Rapana Whelk for Manipulator's Talisman (BoA), slides around island"] = { ["questID"] = 31432, ["coords"] = { "42.0 62.2", "42.2 63.6", "41.6 64.6" }, },
			["Swarming Cleaver of Ka'roz"] = { ["questID"] = 31434, ["coords"] = { "56.7 77.7" }, },
			["Swarmkeeper's Medallion (BoP)"] = { ["questID"] = 31437, ["coords"] = { "54.2 56.3" }, },
			["Wind-Reaver's Dagger of Quick Strikes (BoA)"] = {
				["questID"] = 31666,
				["coords"] = { "71.7 36.1" },
			},
		},
		["The Veiled Stair"] = {
		},
		["Vale of Eternal Blossoms"] = {
		},
		["Isle of Thunder"] = {
		},
		["Dawnseeker Promontory"] = {
		},
	}
	-- other artifacts that grant XP and can be sold, may count towards the achievement(s) [Treasure/Fortune/Bounty/Riches of Pandaria]
	local others = {
		["The Jade Forest"] = {
			["Ancient Pandaren Tea Pot (grey)"] = { ["questID"] = 31400, ["coords"] = { "26.2, 32.3", }, },
			["Lucky Pandaren Coin (grey)"] = { ["questID"] = 31401, ["coords"] = { "31.9 27.7", }, },
			["Pandaren Ritual Stone (grey)"] = { ["questID"] = 31404, ["coords"] = { "23.5 35.0", }, },
			["Ship's Locker (cash)"] = { ["questID"] = 31396, ["coords"] = { "70.13 74.50" }, }, -- "51.2 100.00 +22 yards South"
			["Chest of Supplies (cash)"] = { ["questID"] = 31864, ["coords"] = { "24.6, 53.2", }, },
			["Offering of Remembrance (cash)"] = { ["questID"] = 31865, ["coords"] = { "46.3, 80.7", }, },
			["Stash of Gems (cash + gem), in cave, entrance here"] = { ["questID"] = 31866, ["coords"] = { "62.7 26.6", }, },
		},
		["Valley of the Four Winds"] = {
			["Virmen Treasure Cache (cash), in Lair of Skiggit, entrance here"] = { ["questID"] = 31405, ["coords"] = { "23.1 30.7", }, },
			["Boat-Building Instructions (grey)"] = { ["questID"] = 31869, ["coords"] = { "92.1 39.0", }, },
			["Saurok Stone Tablet, in cave, entrance here (grey)"] = { ["questID"] = 31408, ["coords"] = { "77.2 57.4", }, },
		},
		["Krasarang Wilds"] = {
			["Stack of Papers (grey)"] = { ["questID"] = 31863, ["coords"] = { "52.1 73.4", }, },
		},
		["Townlong Steppes"] = {
			["Abandoned Crate of Goods (cash), in a tent"] = { ["questID"] = 31427, ["coords"] = { "62.7 34.1", }, },
			["Amber Encased Moth (grey)"] = { ["questID"] = 31426, ["coords"] = { "65.8 86.1", }, },
			["Fragment of Dread (grey), in Niuzao Catacombs, entrance here"] = { ["questID"] = 31423, ["coords"] = { " 32.7, 61.0", }, },
			["Hardened Sap of Kri'vess (grey)"] = { ["questID"] = 31424, ["coords"] = { "52.2 57.5", "55.5 61.0", "53.7 61.2", "56.0, 55.5", "58.0 59.0", "52.8 59.9" }, },
		},
		["Kun-Lai Summit"] = {
			["Ancient Mogu Tablet (grey), in Path of Conquerors, entrance here"] = { ["questID"] = 31420, ["coords"] = { "63.9 49.8", }, },
			["Hozen Treasure Cache (cash), in Knucklethump Hole"] = { ["questID"] = 31414, ["coords"] = { "50.3 61.7", }, },
			["Stolen Sprite Treasure (cash), in Howlingwind Cavern, entrance here"] = { ["questID"] = 31415, ["coords"] = { "59.5, 52.9", }, },
			["Statue of Xuen (grey)"] = { ["questID"] = 31416, ["coords"] = { "72.0 34.0", }, },
			["Lost Adventurer's Belongings (cash)"] = { ["questID"] = 31418, ["coords"] = { "36.7, 79.8", }, },
			["Rikktik's Tiny Chest (grey), in Emperor Rikktik's Rest"] = { ["questID"] = 31419, ["coords"] = { "52.0 51.0", }, },
			["Terracotta Head (cash)"] = { ["questID"] = 31422, ["coords"] = { "59.2 73.0", "57.0 75.5", "57.8 76.3", "59.2 74.5", "58.4 73.5" }, },
			["Mo-Mo's Treasure Chest (cash)"] = { ["questID"] = 31868, ["coords"] = { "47.8 73.5", }, },
		},
		["Dread Wastes"] = {
		},
		["The Veiled Stair"] = {
			["The Hammer of Folly (grey), at Mason's Folly, stairs start here"] = { ["questID"] = 31428, ["coords"] = { "68.1 79.0", }, },
			["Forgotten Lockbox (cash)"] = { ["questID"] = 31867, ["coords"] = { "54.6 71.2", }, },
		},
		["Vale of Eternal Blossoms"] = {
		},
		["Isle of Thunder"] = {
		},
		["Dawnseeker Promontory"] = {
		},
	}

	local z = _G.GetRealZoneText()
	checkTable(z, iamt[z])
	checkTable(z, others[z])

end

function aObj:loreObjects()

	local function checkTable(z, tab)

		for a, info in pairs(tab) do
			-- local numCriteria = GetAchievementNumCriteria(info["achID"])
			-- for i = 1, numCriteria do
			-- 	printD(GetAchievementCriteriaInfo(info["achID"], i), i)
			-- end
 			local _, _, completed, _, _, _, _, _, _, _ = _G.GetAchievementCriteriaInfo(info["achID"], info["criIdx"])
			if not completed then
				SlashCmdList.TOMTOM_WAY(stringf("%s %s %s", z, info["coords"], a))
			end
		end

	end

	local lore = {
		["The Jade Forest"] = {
			["Watersmithing"] = { ["achID"] = 6846, ["criIdx"] = 1, ["coords"] = "66.0 87.5" },
			["Hozen Speech"] = { ["achID"] = 6850, ["criIdx"] = 1, ["coords"] = "26.4 28.3" },
			["Xin Wo Yin the Broken Hearted"] = { ["achID"] = 7230, ["criIdx"] = 2, ["coords"] = "37.2 30.1" },
			["Spirit Binders"] = { ["achID"] = 6754, ["criIdx"] = 3, ["coords"] = "42.2 17.4" },
			["The Emperor's Burden - Part 1"] = { ["achID"] = 6855, ["criIdx"] = 1, ["coords"] = "47.0 45.1" },
			["The Emperor's Burden - Part 3"] = { ["achID"] = 6855, ["criIdx"] = 3, ["coords"] = "55.0 56.0" },
			["The Saurok"] = { ["achID"] = 6716, ["criIdx"] = 1, ["coords"] = "67.7 29.4" },
			["The First Monks"] = { ["achID"] = 6858, ["criIdx"] = 3, ["coords"] = "35.7 30.4" },
			["Restore Balance at the Broken Incense Burner"] = { ["achID"] = 7381, ["criIdx"] = 1, ["coords"] = "34.0 33.5" },
		},
		["Krasarang Wilds"] = {
			["Hozen Maturity, in cave, entrance here"] = { ["achID"] = 6850, ["criIdx"] = 2, ["coords"] = "52.2 86.0" },
			["Waiting for the Turtle"] = { ["achID"] = 6856, ["criIdx"] = 4, ["coords"] = "72.2 31.1" },
			["The Last Stand"] = { ["achID"] = 6716, ["criIdx"] = 4, ["coords"] = "32.7 29.4" },
			["Origins"] = { ["achID"] = 6846, ["criIdx"] = 3, ["coords"] = "30.5 38.5" },
			["Quan Tou Kuo the Two Fisted"] = { ["achID"] = 7230, ["criIdx"] = 1, ["coords"] = "81.5 11.6" },
			["The Lost Dynasty"] = { ["achID"] = 6754, ["criIdx"] = 2, ["coords"] = "50.9 31.7" },
			["The Emperor's Burden - Part 4, in the Temple of the Red Crane"] = { ["achID"] = 6855, ["criIdx"] = 4, ["coords"] = "40.5 56.5" },
		},
		["Valley of the Four Winds"] = {
			["The Wondering Widow"] = { ["achID"] = 6856, ["criIdx"] = 3, ["coords"] = "34.6 63.9" },
			["A Most Famous Bill of Sale"] = { ["achID"] = 6856, ["criIdx"] = 2, ["coords"] = "55.0 47.2" },
			["The Birthplace of Liu Lang"] = { ["achID"] = 6856, ["criIdx"] = 1, ["coords"] = "20.0 55.0" },
			["Waterspeakers"] = { ["achID"] = 6846, ["criIdx"] = 2, ["coords"] = "61.2 34.6" },
			["Pandaren Fighting Tactics"] = { ["achID"] = 6858, ["criIdx"] = 1, ["coords"] = "18.8 31.7" },
			["Embracing the Passions"] = { ["achID"] = 6850, ["criIdx"] = 3, ["coords"] = "83.1 21.1" },
		},
		["Kun-Lai Summit"] = {
			["Role Call"] = { ["achID"] = 6846, ["criIdx"] = 4, ["coords"] = "74.0 83.0" },
			["The Hozen Ravage"] = { ["achID"] = 6850, ["criIdx"] = 4, ["coords"] = "45.7 61.9" },
			["Ren Yun the Blind"] = { ["achID"] = 7230, ["criIdx"] = 3, ["coords"] = "44.7 52.4" },
			["Valley of Emperors, in temple, entrance here"] = { ["achID"] = 6754, ["criIdx"] = 1, ["coords"] = "53.0 46.0" },
			["The Emperor's Burden - Part 2"] = { ["achID"] = 6855, ["criIdx"] = 2, ["coords"] = "43.0 51.0" },
			["The Emperor's Burden - Part 6"] = { ["achID"] = 6855, ["criIdx"] = 6, ["coords"] = "67.8 48.3" },
			["The Emperor's Burden - Part 7"] = { ["achID"] = 6855, ["criIdx"] = 7, ["coords"] = "41.0 42.4" },
			["Yaungoil"] = { ["achID"] = 6847, ["criIdx"] = 3, ["coords"] = "71.7 63.0" },
			["Yaungol Tactics"] = { ["achID"] = 6847, ["criIdx"] = 1, ["coords"] = "50.0 79.0" },
			["Victory in Kun-Lai"] = { ["achID"] = 6858, ["criIdx"] = 5, ["coords"] = "63.0 40.8" },
		},
		["Townlong Steppes"] = {
			["The Emperor's Burden - Part 5, in Niuzao Temple"] = { ["achID"] = 6855, ["criIdx"] = 5, ["coords"] = "37.7 62.9" },
			["Dominance"] = { ["achID"] = 6847, ["criIdx"] = 2, ["coords"] = "65.4 50.0" },
			["Trapped in a Strange Land"] = { ["achID"] = 6847, ["criIdx"] = 4, ["coords"] = "84.0 72.8" },
		},
		["Dread Wastes"] = {
			["Amber, in the Amber Vault, entrance here"] = { ["achID"] = 6857, ["criIdx"] = 3, ["coords"] = "53.6 15.8" },
			["The Empress"] = { ["achID"] = 6857, ["criIdx"] = 4, ["coords"] = "35.5 32.6" },
			["Mantid Society"] = { ["achID"] = 6857, ["criIdx"] = 2, ["coords"] = "59.8 55.0" },
			["The Deserters"] = { ["achID"] = 6716, ["criIdx"] = 3, ["coords"] = "67.5 60.8" },
			["Cycle of the Mantid"] = { ["achID"] = 6857, ["criIdx"] = 1, ["coords"] = "48.3 32.8" },
		},
		["Vale of Eternal Blossoms"] = {
			["Always Remember"] = { ["achID"] = 6858, ["criIdx"] = 2, ["coords"] = "52.8 68.5" },
			["The Emperor's Burden - Part 8"] = { ["achID"] = 6855, ["criIdx"] = 8, ["coords"] = "67.7 44.1" },
			["The Thunder King"] = { ["achID"] = 6754, ["criIdx"] = 4, ["coords"] = "40.1 77.6" },
			["Together, We Are Strong"] = { ["achID"] = 6858, ["criIdx"] = 4, ["coords"] = "26.6 21.5" },
		},
		["The Veiled Stair"] = {
			["The Defiant, in the Rookery, part of the Ancient Passage, entrance at S waypoint"] = { ["achID"] = 6716, ["criIdx"] = 2, ["coords"] = "49.9.0 41.2", "55.0 16.2" },
		},
		["Isle of Thunder"] = {
			-- Rumbles of Thunder
			["Lei Shen"] = { ["achID"] = 8050, ["criIdx"] = 1, ["coords"] = "40.2 40.6" },
			["The Sacred Mount"] = { ["achID"] = 8050, ["criIdx"] = 2, ["coords"] = "47.0 59.9" },
			["Unity at a Price"] = { ["achID"] = 8050, ["criIdx"] = 3, ["coords"] = "34.9 65.5" },
			["The Pandaren Problem"] = { ["achID"] = 8050, ["criIdx"] = 4, ["coords"] = "60.7 68.8" },
			-- Gods and Monsters
			["Agents of Order"] = { ["achID"] = 8051, ["criIdx"] = 1, ["coords"] = "35.8 54.7", },
			["Shadow, Storm, and Stone"] = { ["achID"] = 8051, ["criIdx"] = 2, ["coords"] = "59.1 26.2", },
			["The Curse and The Silence"] = { ["achID"] = 8051, ["criIdx"] = 3, ["coords"] = "49.9 20.4", },
			["Age of a Hundred Kings"] = { ["achID"] = 8051, ["criIdx"] = 4, ["coords"] = "62.5 37.7", },
			-- The Zandalari Prophecy
			["Coming of Age"] = { ["achID"] = 8049, ["criIdx"] = 1, ["coords"] = "35.2 70.1", },
			["For Council and King"] = { ["achID"] = 8049, ["criIdx"] = 2, ["coords"] = "66.0 44.7", },
			["Shadows of the Loa"] = { ["achID"] = 8049, ["criIdx"] = 3, ["coords"] = "36.4 70.3", },
			["The Dark Prophet Zul"] = { ["achID"] = 8049, ["criIdx"] = 4, ["coords"] = "52.6 41.4", },
		},
		["Dawnseeker Promontory"] = {
		},
	}

	local z = _G.GetRealZoneText()
	checkTable(z, lore[z])

end
