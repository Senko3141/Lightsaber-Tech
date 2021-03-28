-- Lightsaber Server
-- Senko
-- 3/28/2021

--[[
    Idea:

    > Server:
        - Handles player_joining, initiates saber.
        - Removes saber on death, and when player leaves. 
        - Saber gets WELDED to player. 
        
        - Handles checks to prevent exploiting.
    
    > Client
        - Handles input. 
]]


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local SFX = Workspace:WaitForChild("SFX")
local Sounds = ServerStorage:WaitForChild("Sounds")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Models = {
    Saber = ReplicatedStorage:WaitForChild("Saber")
};

local function play_sound(sound)
    -- only for one-time sounds, sustained differ

    local clone = Sounds:FindFirstChild(sound):Clone()
    clone.Parent = SFX
    clone:Play()
    Debris:AddItem(clone, clone.TimeLength)
end

Remotes._SaberEvent.OnServerEvent:Connect(function(plr, data)
    if (data == nil) or (data.Action == nil) then
        plr:Kick("No exploiting. | Tagged: Data argument passed is nil.")
        return;
    end

    local Action = data.Action
    local PlayerFolder = plr:FindFirstChild("LightsaberData")

    if (PlayerFolder) then
        if (Action == "Ignite") then
            -- ignite
            local is_active = PlayerFolder.Active
            local returned = Remotes._SaberComm:InvokeClient(
                plr,
                "get_state",
                {
                   States = {"PrevIgnite", "IgniteCooldown"}
                }
            )
            local prev_ignite = returned.PrevIgnite
            local ignite_cooldown = returned.IgniteCooldown

            if (os.clock() - prev_ignite) < ignite_cooldown then
                if (is_active.Value == false) then
                    -- ignite
                    play_sound("Ignite")
                    is_active.Value = (not is_active.Value)

                    coroutine.resume(coroutine.create(function()
                        local saber_model = plr.Character:FindFirstChild("Saber")
                        if (saber_model) then
                            local blade = saber_model.Blade
                            for _,obj in pairs(blade:GetDescendants()) do
                                if (obj:IsA("ParticleEmitter")) then
                                    obj.Enabled = true
                                end
                            end
                        end
                    end))
                    return;
                end
                if (is_active.Value == true) then
                    -- de-ignite
                    play_sound("Extinguish")
                    is_active.Value = (not is_active.Value)

                    coroutine.resume(coroutine.create(function()
                        local saber_model = plr.Character:FindFirstChild("Saber")
                        if (saber_model) then
                            local blade = saber_model.Blade
                            for _,obj in pairs(blade:GetDescendants()) do
                                if (obj:IsA("ParticleEmitter")) then
                                    obj.Enabled = false
                                end
                            end
                        end
                    end))
                    return;
                end
            end
            
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    local folder = Instance.new("Folder")
    folder.Name = "LightsaberData"

    folder.Parent = plr

    local ignited = Instance.new("BoolValue")
    ignited.Name = "Active"
    ignited.Value = false
    ignited.Parent = folder

    local color = Instance.new("Color3Value")
    color.Name = "Color"
    color.Value = Color3.fromRGB(255,0,0)
    color.Parent = folder

    plr.CharacterAppearanceLoaded:Connect(function(char)
        warn(plr.Name.." needs to get his lightsaber initiated.")

        local _clone = Models.Saber:Clone()
        _clone.Weld.Part1 = char:WaitForChild("Right Arm")
        _clone.Parent = char
    end)
end)