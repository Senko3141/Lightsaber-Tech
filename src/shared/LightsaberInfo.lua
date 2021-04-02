-- Lightsaber Info
-- Senko
-- 4/2/2021

local Info = {}

Info.LightsaberColors = {
    Server = {
        [1] = Color3.fromRGB(0, 25, 199),
        [2] = Color3.fromRGB(255, 0, 0),
        [3] = Color3.fromRGB(51, 80, 107),
        [4] = Color3.fromRGB(26, 80, 35),
        [5] = Color3.fromRGB(66, 85, 30),
        [6] = Color3.fromRGB(116, 48, 194),
        [7] = Color3.fromRGB(127, 121, 43),
        [8] = Color3.fromRGB(83, 83, 83)
    },
    Client = {
        ["Blue"] = Color3.fromRGB(0, 25, 199),
        ["Red"] = Color3.fromRGB(255, 0, 0),
        ["Light Blue"] = Color3.fromRGB(51, 80, 107),
        ["Green"] = Color3.fromRGB(26, 80, 35),
        ["Yellow-Green"] = Color3.fromRGB(66, 85, 30),
        ["Purple"] = Color3.fromRGB(116, 48, 194),
        ["Yellow"] = Color3.fromRGB(127, 121, 43),
        ["White"] = Color3.fromRGB(83, 83, 83)
    }
}

Info.Hilts = {
    Server = {
        ["DefaultSaber"] = true,
        ["Test1"] = true,
        ["Test2"] = true,
        ["Vader Hilt"] = true
    },
    Client = {
        ["DefaultSaber"] = true,
        ["Test1"] = true,
        ["Test2"] = true,
        ["Vader Hilt"] = true
    }
}

return Info
