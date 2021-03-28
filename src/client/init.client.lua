-- Saber Client
-- Senko
-- 3/28/2021

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local LightsaberData = Player:WaitForChild("LightsaberData")
local ClientData = {
    PrevIgnite = os.clock(),
    PrevColorChange = os.clock(),

    PrevSlash = os.clock(),
    PrevBlock = os.clock(),

    IgniteCooldown = 1,
    ColorChangeCooldown = 0.5,
    BlockCooldown = 1,

    SlashCooldown = "AnimationBased",
};


local function toggle_ignite()
    Remotes._SaberEvent:FireServer(
        {
            Action = "Ignite",
        }
    )
end

Remotes._SaberComm.OnClientInvoke = function(action, dict)
    if (action == "get_state") then
        local states = dict.States
        local to_respond = {};

        for _,name in pairs(states) do
            if (ClientData[name]) then
                to_respond[name] = ClientData[name]
            end
        end
        return to_respond
    end
end

ContextActionService:BindAction(
    "Ignite",
    function(name, state, obj)
        if (state == Enum.UserInputState.Begin) then
            if (os.clock() - ClientData.PrevIgnite) >= ClientData.IgniteCooldown then
                ClientData.PrevIgnite = os.clock()
                toggle_ignite()
                print("Ignite lightsaber.")
            end
        end
    end,
    false,
    Enum.KeyCode.Q
)