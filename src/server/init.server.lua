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
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Models = {
    Saber = ReplicatedStorage:WaitForChild("Saber")
}

require(Modules.Credits)()

local ServerData = {
    --[[
        Order: 
        Red,
        Blue,
        Light Blue,
        Green,
        Yellow-Green,
        Purple,
        Yellow,
        White,
        Black
    ]]
    LightsaberColors = {
        [1] = Color3.fromRGB(0, 25, 199),
        [2] = Color3.fromRGB(255, 0, 0),
        [3] = Color3.fromRGB(51, 80, 107),
        [4] = Color3.fromRGB(26, 80, 35),
        [5] = Color3.fromRGB(66, 85, 30),
        [6] = Color3.fromRGB(116, 48, 194),
        [7] = Color3.fromRGB(127, 121, 43),
        [8] = Color3.fromRGB(83, 83, 83)
    }
}

local function play_sound(sound)
    -- only for one-time sounds, sustained differ

    local clone = Sounds:FindFirstChild(sound):Clone()
    clone.Parent = SFX
    clone:Play()
    Debris:AddItem(clone, clone.TimeLength)
end
local function update_color(saber, currentColor)
    coroutine.resume(
        coroutine.create(
            function()
                local clr_value = table.find(ServerData.LightsaberColors, currentColor)
                if (clr_value ~= nil) then
                    for _, emitter in pairs(saber:GetDescendants()) do
                        if (emitter:IsA("ParticleEmitter")) and (emitter.Name == "Outer") then
                            -- change color here
                            emitter.Color = ColorSequence.new(ServerData.LightsaberColors[clr_value])
                        end
                    end
                end
            end
        )
    )
end

Remotes._SaberEvent.OnServerEvent:Connect(
    function(plr, data)
        if (data == nil) or (data.Action == nil) then
            plr:Kick("No exploiting. | Tagged: Data argument passed is nil.")
            return
        end

        local Action = data.Action
        local PlayerFolder = plr:FindFirstChild("LightsaberData")

        if (PlayerFolder) then
            if (Action == "Ignite") then
                -- ignite
                local is_active = PlayerFolder.Active
                local returned =
                    Remotes._SaberComm:InvokeClient(
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

                        coroutine.resume(
                            coroutine.create(
                                function()
                                    local saber_model = plr.Character:FindFirstChild("Saber")
                                    if (saber_model) then
                                        local blade = saber_model.Blade
                                        for _, obj in pairs(blade:GetDescendants()) do
                                            if (obj:IsA("ParticleEmitter")) then
                                                obj.Enabled = true
                                            end
                                        end
                                    end
                                end
                            )
                        )
                        return
                    end
                    if (is_active.Value == true) then
                        -- de-ignite
                        play_sound("Extinguish")
                        is_active.Value = (not is_active.Value)

                        coroutine.resume(
                            coroutine.create(
                                function()
                                    local saber_model = plr.Character:FindFirstChild("Saber")
                                    if (saber_model) then
                                        local blade = saber_model.Blade
                                        for _, obj in pairs(blade:GetDescendants()) do
                                            if (obj:IsA("ParticleEmitter")) then
                                                obj.Enabled = false
                                            end
                                        end
                                    end
                                end
                            )
                        )
                        return
                    end
                end
            end

            if (Action == "ChangeColor") then
                local chosen_color = data.New
                -- good
                local current_color = PlayerFolder.Color

                if (ServerData.LightsaberColors[table.find(ServerData.LightsaberColors, chosen_color)]) ~= nil then
                    current_color.Value = chosen_color
                    update_color(plr.Character.Saber, current_color.Value)
                end
            end
        end
    end
)

Players.PlayerAdded:Connect(
    function(plr)
        local folder = Instance.new("Folder")
        folder.Name = "LightsaberData"

        folder.Parent = plr

        local ignited = Instance.new("BoolValue")
        ignited.Name = "Active"
        ignited.Value = false
        ignited.Parent = folder

        local color = Instance.new("Color3Value")
        color.Name = "Color"
        color.Value = ServerData.LightsaberColors[1]
        color.Parent = folder

        ignited:GetPropertyChangedSignal("Value"):Connect(
            function()
                local _val = ignited.Value
                if (_val == true) then
                    Remotes._SaberEvent:FireClient(
                        plr,
                        "PlayAnimation",
                        {
                            Name = "Saber_Idle"
                        }
                    )
                end
                if (_val == false) then
                    Remotes._SaberEvent:FireClient(
                        plr,
                        "EndAnimation",
                        {
                            Name = "Saber_Idle",
                            Time = 0.09
                        }
                    )
                end
            end
        )

        plr.CharacterAppearanceLoaded:Connect(
            function(char)
                local humanoid = char:WaitForChild("Humanoid")

                warn(plr.Name .. " needs to get his lightsaber initiated.")

                local _clone = Models.Saber:Clone()
                _clone.Weld.Part1 = char:WaitForChild("Right Arm")
                _clone.Parent = char

                humanoid.Died:Connect(
                    function()
                        if (char:FindFirstChild("Saber")) then
                            char.Saber:Destroy()
                        end
                    end
                )
            end
        )
    end
)
