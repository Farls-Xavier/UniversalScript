local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Farls-Xavier/UiLibrary/main/Library.lua"))()

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--[[ ESP SETTINGS ]]--
_G.EspSettings = {
    TeamCheck = false
}

_G.TracerSettings = {
    Visible = false,
    Color = Color3.fromRGB(76, 77, 146)
}

_G.BoxSettings = {
    Visible = false,
    Color = Color3.fromRGB(76, 77, 146)
}

_G.NameSettings = {
    Visible = false,
    Color = Color3.fromRGB(76, 77, 146)
}

--[[ AIMBOT SETTINGS ]] --
_G.AimbotSettings = {
    Enabled = false,
    Aimpart = "Head",
    Smoothness = 0
}

_G.FovSettings = {
    Visible = false,
    Size = 90
}

local Window = Library:Window({Title = "Universal Script"})
local Tabs = {
    ["Aim"] = Window:Tab({
        Text = "Aim",
        Icon = "rbxassetid://14966164502"
    }),

    ["Visuals"] = Window:Tab({
        Text = "Visuals",
        Icon = "rbxassetid://14966779139"
    }),

    ["Player"] = Window:Tab({
        Text = "Player",
        Icon = "rbxassetid://14958157475"
    })
}

local AimTab = {
    ["Aimbot Toggle"] = Tabs.Aim:Toggle({
        Text = "Aimbot",
        Callback = function(v)
            _G.AimbotSettings.Enabled = v
        end
    }),

    ["Smoothness Slider"] = Tabs.Aim:Slider({
        Text = "Smoothness",
        Min = 0,
        Max = 10,
        Default = 0,
        Callback = function(v)
            _G.AimbotSettings.Smoothness = v
        end
    }),

    ["Fov Toggle"] = Tabs.Aim:Toggle({
        Text = "FOV",
        Callback = function(v)
            _G.FovSettings.Visible = v
        end
    }),

    ["Fov Size Slider"] = Tabs.Aim:Slider({
        Text = "FOV Size",
        Min = 10,
        Max = 999,
        Default = 90,
        Callback = function(v)
            _G.FovSettings.Size = v
        end
    })
}

local VisualsTab = {
    ["Boxes Toggle"] = Tabs.Visuals:Toggle({
        Text = "Boxes",
        Callback = function(v)
            _G.BoxSettings.Visible = v
        end
    }),

    ["Names Toggle"] = Tabs.Visuals:Toggle({
        Text = "Names",
        Callback = function(v)
            _G.NameSettings.Visible = v
        end
    }),

    ["Tracers Toggle"] = Tabs.Visuals:Toggle({
        Text = "Tracers",
        Callback = function(v)
            _G.TracerSettings.Visible = v
        end
    })
}

local PlayerTab = {
    ["WalkSpeed Slider"] = Tabs.Player:Slider({
        Text = "WalkSpeed",
        Min = 0,
        Max = 500,
        Default = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed,
        Callback = function(v)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    }),
    
    ["JumpPower Slider"] = Tabs.Player:Slider({
        Text = "JumpPower",
        Min = 0,
        Max = 500,
        Default = game.Players.LocalPlayer.Character.Humanoid.JumpPower or game.Players.LocalPlayer.Character.Humanoid.JumpHeight,
        Callback = function(v)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.JumpHeight = v
            end)
        end
    })
}

local function AddBoxes(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = _G.BoxSettings.Color
    Box.Thickness = 1
    Box.Filled = false

    local HeadOffset = Vector3.new(0, 0.5, 0)
    local LegOffset = Vector3.new(0, 3, 0)

    RunService.RenderStepped:Connect(function()
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            local HeadPos = Camera:WorldToViewportPoint(player.Character.Head.Position + HeadOffset)
            local LegPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position - LegOffset)

            Box.Position = Vector2.new(Vector.X, Vector.Y)
            Box.Size = Vector2.new(1000 / Vector.Z, HeadPos.Y - LegPos.Y)

            if OnScreen == true then
                if _G.EspSettings.TeamCheck == true then
                    if player.Team ~= Player.Team then
                        Box.Visible = _G.BoxSettings.Visible
                    else
                        Box.Visible = false
                    end
                else
                    Box.Visible = _G.BoxSettings.Visible
                end
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            Box:Remove()
        end
    end)
end

for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= Player then
        AddBoxes(v)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        AddBoxes(player)
    end)
end)
