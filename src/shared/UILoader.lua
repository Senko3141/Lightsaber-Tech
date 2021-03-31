-- UI Loader
-- Senko
-- 3/31/2021

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = ReplicatedStorage:WaitForChild("UI")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local UI_Components = Modules.Components.UI

local Loader = {};

function Loader.load(plr_ui)
    for _,obj in pairs(UI:GetChildren()) do
        if (obj:IsA("ScreenGui")) then
            obj:Clone().Parent = plr_ui

            if (UI_Components:FindFirstChild(obj.Name)) then
                require(UI_Components[obj.Name])()
            end

            warn("Successfully loaded ui_asset: ".. obj.Name..".")
        end
    end
end


return Loader