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
local Character = Player.Character or Player.CharacterAppearanceLoaded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")

local Animations = ReplicatedStorage:WaitForChild("Animations")
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
    Default_Class = "Single",
    SlashCooldown = "AnimationBased",
    Animations = {
        Single = {},
        Dual = {},
        Double = {}
    }
}

local function load_anims()
    local anim_tbl = ClientData.Animations

    for _, class in pairs(Animations:GetChildren()) do
        if (anim_tbl[class.Name]) then
            -- valid

            for _, obj in pairs(class:GetChildren()) do
                if (obj:IsA("Animation")) and (not anim_tbl[class.Name][obj.Name]) then
                    anim_tbl[class.Name][obj.Name] = Humanoid:LoadAnimation(obj)
                   -- print(obj.Name)
                end
            end
        end
    end
end
local function unload_anims()
    table.clear(ClientData.Animations)
end

local function toggle_ignite()
    Remotes._SaberEvent:FireServer(
        {
            Action = "Ignite"
        }
    )
end
local function change_color()
    Remotes._SaberEvent:FireServer(
        {
            Action = "ChangeColor"
        }
    )
end

Humanoid.Died:Connect(
    function()
        unload_anims()
        ContextActionService:UnbindAction("Ignite")
        ContextActionService:UnbindAction("ChangeColor")
        ContextActionService:UnbindAction("Slash")
    end
)

Remotes._SaberComm.OnClientInvoke = function(action, dict)
    if (action == "get_state") then
        local states = dict.States
        local to_respond = {}

        for _, name in pairs(states) do
            if (ClientData[name]) then
                to_respond[name] = ClientData[name]
            end
        end
        return to_respond
    end
end

Remotes._SaberEvent.OnClientEvent:Connect(function(action, dict)
    if (action == "PlayAnimation") then
        local name = dict.Name
        local current_class = ClientData.Default_Class

        if (ClientData.Animations[current_class][name]) ~= nil then
            -- works
            ClientData.Animations[current_class][name]:Play()
        end
    end
    if (action == "EndAnimation") then
        local name = dict.Name
        local t = dict.Time

        for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
            if (v.Name == name) then
                v:Stop(t)
            end
        end
    end
end)

ContextActionService:BindAction(
    "Ignite",
    function(name, state, obj)
        if (state == Enum.UserInputState.Begin) then
            if (Humanoid.Health == 0) then
                return -- dead
            end
            if (os.clock() - ClientData.PrevIgnite) >= ClientData.IgniteCooldown then
                ClientData.PrevIgnite = os.clock()
                toggle_ignite()
                --//print("Ignite lightsaber.")
            end
        end
    end,
    false,
    Enum.KeyCode.Q
)

ContextActionService:BindAction(
    "ChangeColor",
    function(name, state, obj)
        if (state == Enum.UserInputState.Begin) then
            if (Humanoid.Health == 0) then
                return -- dead
            end

            if (LightsaberData:FindFirstChild("Active") ~= nil) then
                if (LightsaberData.Active.Value == false) then
                    return -- not activated
                end
            end
            if (os.clock() - ClientData.PrevColorChange) >= ClientData.ColorChangeCooldown then
                ClientData.PrevColorChange = os.clock()
                change_color()
            end
        end
    end,
    false,
    Enum.KeyCode.R
)

ContextActionService:BindAction(
    "Slash",
    function(name, state, obj)
        if (state == Enum.UserInputState.Begin) then
        -- slash here
        end
    end,
    false,
    Enum.UserInputType.MouseButton1
)

local s, e =
    pcall(
    function()
        load_anims()
    end
)
if (s) then
    warn("Successfully loaded saber animations.")
else
    warn(e)
end
