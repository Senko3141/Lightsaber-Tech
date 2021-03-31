-- UI Loader
-- Senko
-- 3/31/2021

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Starter_Gui = script.Parent

local UI_Loader = require(Modules.UILoader)
UI_Loader.load(Starter_Gui)