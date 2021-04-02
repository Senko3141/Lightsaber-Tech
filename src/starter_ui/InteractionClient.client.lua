-- Interaction Client
-- Senko
-- 3/31/2021

--[[
    TODO: Make it to whenever you interact with the table, your lightsaber is de-ignited, and you can't ignite until you're done.
]]

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Sounds = ReplicatedStorage:WaitForChild("Sounds")
local Table = Workspace:WaitForChild("Table")
local Camera = Workspace.CurrentCamera
local Player_Gui = script.Parent
local SFX = Workspace:WaitForChild("SFX")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local LightsaberInfo = require(Modules.LightsaberInfo)
local PlayerData = Player:WaitForChild("LightsaberData")

local Prompt = Table:FindFirstChild("Prompt")
if (Prompt == nil) then
    error("FATAL ERROR: COULD NOT FIND PRMOPT IN TABLE OBJECT.")
end

local ClientData = {
    OriginOffset = CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 0, 5.4),
    SaberMovementScale = Vector2.new(-50, -50),
    SaberRotationScale = 2,
    PreviousMove = os.clock(),
    MoveCooldown = 1,
    Moving = false,
}

ClientData.LightsaberColors = LightsaberInfo.LightsaberColors.Client
ClientData.Hilts = LightsaberInfo.Hilts.Client

local function play_sound(sound)
    -- only for one-time sounds, sustained differ

    local clone = Sounds:FindFirstChild(sound):Clone()
    clone.Parent = SFX
    clone:Play()
    Debris:AddItem(clone, clone.TimeLength)
end

ContextActionService:UnbindAction("Inspect_Saber")
RunService:UnbindFromRenderStep("Inspect_Saber_Movement")

Prompt.Triggered:Connect(
    function(plr)
        print(plr.Name)

        local _view = Workspace:FindFirstChild("Saber_View").Hilt_Part
        if (_view ~= nil) then
            Prompt.Enabled = false
            local original_cf = CFrame.new(_view.Origin.WorldPosition) * ClientData.OriginOffset
            local object_cf = _view.CFrame

            -- valid, keep on going boi
            Camera.CameraType = Enum.CameraType.Scriptable
            local tween =
                TweenService:Create(
                Camera,
                TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {
                    CFrame = original_cf
                }
            )
            tween:Play()
            tween.Completed:Wait()

            coroutine.resume(
                coroutine.create(
                    function()
                        play_sound("Ignite")
                        for _, emitter in pairs(_view:GetDescendants()) do
                            if (emitter:IsA("ParticleEmitter")) then
                                emitter.Enabled = true
                            end
                        end
                    end
                )
            )

            local t =
                TweenService:Create(
                Camera,
                TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {
                    CFrame = original_cf * CFrame.new(0, 0, 2)
                }
            )
            t:Play()
            t.Completed:Wait()

            local customization_ui = Player_Gui:FindFirstChild("Customization")
            if (customization_ui ~= nil) then
                customization_ui.Enabled = true

                --{0.5, 0},{0.122, 0}
                --{0.404, 0},{0.896, 0} finish button final

                local ClickConnections = {}

                local hilt_frame = customization_ui.HiltsFrame
                local color_frame = customization_ui.ColorFrame

                local hiltsf_open = false
                local colorsf_open = false

                local selection_frame = customization_ui.Selection
                local finish_button = customization_ui.Finish

                local ColorButton = selection_frame.Buttons.Color
                local HiltsButton = selection_frame.Buttons.Hilt

                local function tween_assets(type)
                    if (type == "In") then
                        selection_frame:TweenPosition(
                            UDim2.new(0.5, 0, 0.122, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quint,
                            0.5,
                            true
                        )
                        finish_button:TweenPosition(
                            UDim2.new(0.404, 0, 0.896, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quint,
                            0.5,
                            true
                        )
                    end
                    if (type == "Out") then
                        hiltsf_open = false
                        colorsf_open = false
                        hilt_frame:TweenPosition(
                            UDim2.new(1.2, 0, 0.159, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quint,
                            0.5,
                            true
                        )
                        color_frame:TweenPosition(
                            UDim2.new(-0.2, 0, 0.159, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quint,
                            0.5,
                            true
                        )

                        selection_frame:TweenPosition(
                            UDim2.new(0.5, 0, -0.2, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quint,
                            0.5,
                            true
                        )

                        finish_button:TweenPosition(
                            UDim2.new(0.404, 0, 1.2, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quint,
                            0.5,
                            true
                        )
                    end
                end

                ClickConnections[ColorButton.Name] =
                    ColorButton.MouseButton1Click:Connect(
                    function()
                        colorsf_open = (not colorsf_open)

                        if (colorsf_open == true) then
                            -- open
                            color_frame:TweenPosition(
                                UDim2.new(0.051, 0, 0.159, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quint,
                                0.5,
                                true
                            )
                        end
                        if (colorsf_open == false) then
                            -- close
                            color_frame:TweenPosition(
                                UDim2.new(-0.2, 0, 0.159, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quint,
                                0.5,
                                true
                            )
                        end
                    end
                )

                ClickConnections[HiltsButton.Name] =
                    HiltsButton.MouseButton1Click:Connect(
                    function()
                        hiltsf_open = (not hiltsf_open)

                        if (hiltsf_open == true) then
                            -- open
                            hilt_frame:TweenPosition(
                                UDim2.new(0.816, 0, 0.159, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quint,
                                0.5,
                                true
                            )
                        end
                        if (hiltsf_open == false) then
                            -- close
                            hilt_frame:TweenPosition(
                                UDim2.new(1.2, 0, 0.159, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quint,
                                0.5,
                                true
                            )
                        end
                    end
                )

                ClickConnections[finish_button.Name] =
                    finish_button.MouseButton1Click:Connect(
                    function()
                        ContextActionService:UnbindAction("Inspect_Saber")

                        local disconnected_list = {}
                        for _name, v in pairs(ClickConnections) do
                            if (v ~= nil) then
                                table.insert(disconnected_list, #disconnected_list + 1, _name)
                                v:Disconnect()
                            end
                        end

                        if (#disconnected_list > 0) then
                            warn("Disconnected events: " .. table.concat(disconnected_list, " ") .. "\nAmount DC'ed: " .. tostring(#disconnected_list))
                        end

                        if (ClientData.Moving == true) then
                            TweenService:Create(
                                Camera,
                                TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                {
                                    CFrame = original_cf * CFrame.new(0, 0, 2)
                                }
                            ):Play()

                            -- tween all assets later
                            tween_assets("In")

                            ClientData.PreviousMove = os.clock()
                            ClientData.Moving = false
                            RunService:UnbindFromRenderStep("Inspect_Saber_Movement")
                            TweenService:Create(
                                _view,
                                TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                {
                                    CFrame = object_cf
                                }
                            ):Play()
                        end

                        tween_assets("Out")
                        TweenService:Create(
                            Camera,
                            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                            {
                                CFrame = original_cf
                            }
                        ):Play()
                        wait(1)
                        play_sound("Extinguish")
                        for _, emitter in pairs(_view:GetDescendants()) do
                            if (emitter:IsA("ParticleEmitter")) then
                                emitter.Enabled = false
                            end
                        end

                        wait(.6)

                        Camera.CameraType = Enum.CameraType.Custom
                        wait(1)
                        Prompt.Enabled = true
                    end
                )

                -- changing colors
                for _, obj in pairs(color_frame.Buttons:GetChildren()) do
                    if (obj:IsA("TextButton")) then
                        ClickConnections[obj.Name .. "Button/Color"] =
                            obj.MouseButton1Click:Connect(
                            function()
                                if (ClientData.LightsaberColors[obj.Name]) ~= nil then
                                    -- change color

                                    -- update saber color
                                    local _blade = _view.Blade
                                    for _, emitter in pairs(_blade:GetDescendants()) do
                                        if (emitter:IsA("ParticleEmitter")) and (emitter.Name == "Outer") then
                                            emitter.Color = ColorSequence.new(ClientData.LightsaberColors[obj.Name])
                                        end
                                    end
                                    Remotes._SaberEvent:FireServer(
                                        {
                                            Action = "ChangeColor",
                                            ["New"] = ClientData.LightsaberColors[obj.Name]
                                        }
                                    )
                                end

                                print("Update lightsaber color " .. obj.Name .. ".")
                            end
                        )
                    end
                end

                -- changing hilts
                for _, obj in pairs(hilt_frame.Buttons:GetChildren()) do
                    if (obj:IsA("TextButton")) then
                        ClickConnections[obj.Name .. "Button/Hilt"] =
                            obj.MouseButton1Click:Connect(
                            function()
                                -- update hilt
                                print("Update hilt to " .. obj.Name .. ".")

                                -- checking if valid

                                if (ClientData.Hilts[obj.Name] ~= nil) then
                                    -- works
                                    if (_view:FindFirstChild(obj.Name)) ~= nil then
                                        -- change hilt
                                        Remotes._SaberEvent:FireServer(
                                            {
                                                Action = "ChangeHilt",
                                                ["New"] = obj.Name
                                            }
                                        )
                                        wait(.1)

                                        -- update view via client, oh well exploiters lol

                                        
                                        for _,h in pairs(_view:GetChildren()) do
                                            if (h:GetAttribute("IsSaber")) ~= nil and (h:GetAttribute("IsSaber")) == true then
                                                -- is a saber\
                                                if (h.Transparency == 0) then
                                                    h.Transparency = 1
                                                end
                                            end
                                        end

                                        -- changing transparency of NEW saber
                                        if (_view:FindFirstChild(PlayerData.CurrentHilt.Value)) ~= nil then
                                            _view[PlayerData.CurrentHilt.Value].Transparency = 0
                                        end

                                    end
                                end
                                    
                            end
                        )
                    end
                end

                tween_assets("In")
                -- binding actions
                ContextActionService:BindAction(
                    "Inspect_Saber",
                    function(name, state, obj)
                        if (state == Enum.UserInputState.Begin) then
                            if
                                (ClientData.Moving == true) or
                                    ((os.clock() - ClientData.PreviousMove) < ClientData.MoveCooldown)
                             then
                                return -- on cooldown
                            end
                            ClientData.Moving = true
                            -- bind move action
                            TweenService:Create(
                                Camera,
                                TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                {
                                    CFrame = original_cf
                                }
                            ):Play()

                            -- tween all assets out later

                            tween_assets("Out")

                            RunService:BindToRenderStep(
                                "Inspect_Saber_Movement",
                                Enum.RenderPriority.Camera.Value - 1,
                                function()
                                    local screen_size = Camera.ViewportSize
                                    local mousePos =
                                        (UserInputService:GetMouseLocation() - screen_size / 2) * (2 / screen_size)

                                    local rotation =
                                        CFrame.Angles(
                                        math.rad(mousePos.Y * ClientData.SaberMovementScale.Y),
                                        math.rad(mousePos.X * ClientData.SaberMovementScale.X),
                                        0
                                    )

                                    _view.CFrame = object_cf * rotation
                                end
                            )
                        end
                        if (state == Enum.UserInputState.End) then
                            -- stopped holding
                            if (ClientData.Moving == true) then
                                TweenService:Create(
                                    Camera,
                                    TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                    {
                                        CFrame = original_cf * CFrame.new(0, 0, 2)
                                    }
                                ):Play()

                                -- tween all assets later
                                tween_assets("In")

                                ClientData.PreviousMove = os.clock()
                                ClientData.Moving = false
                                RunService:UnbindFromRenderStep("Inspect_Saber_Movement")
                                TweenService:Create(
                                    _view,
                                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                    {
                                        CFrame = object_cf
                                    }
                                ):Play()
                            end
                        end
                    end,
                    false,
                    Enum.UserInputType.MouseButton2
                )
            end
        end
    end
)
