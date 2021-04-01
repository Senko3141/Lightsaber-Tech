-- Kill Death Ratio Handler
-- Senko
-- 4/1/2021

local Players = game:GetService("Players")

local function get_kdr(k,d)
    return (k/d)
end

Players.PlayerAdded:Connect(function(plr)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = plr

    local kills = Instance.new("IntValue", leaderstats)
    kills.Name = "Kills"
    kills.Value = 0

    local deaths = Instance.new("IntValue", leaderstats)
    deaths.Name = "Deaths"
    deaths.Value = 0

    plr.CharacterAppearanceLoaded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        if (humanoid) then
            humanoid.Died:Connect(function()
                deaths.Value = deaths.Value - 1
            end)
        end
    end)
end)