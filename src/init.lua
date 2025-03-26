--!strict
--[[
    Modern IDE - A modern IDE GUI library for Roblox
    Version: 1.0.0
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local IDE = {
    Version = "1.0.0";
    OpenWindows = {};
    Options = {};
    Themes = {};
    SelectedTheme = nil;
}

-- Modules
local Elements = script.Elements
local Components = script.Components
local Utils = script.Utils

-- Load dependencies
local Signal = require(script.Utils.Signal)
local Theme = require(script.Utils.Theme)
local Acrylic = require(script.Utils.Acrylic)

-- Import themes
IDE.Themes = Theme.GetThemes()
IDE.SelectedTheme = "Dark" -- Default theme

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernIDE"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true

if RunService:IsStudio() then
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
else
    screenGui.Parent = game:GetService("CoreGui")
end

IDE.ScreenGui = screenGui

-- Internal functions
local function createBaseWindow(config)
    local Window = require(Components.Window)
    return Window.new(IDE, config)
end

-- Public API
function IDE:CreateEditor(config)
    config = config or {}
    config.Title = config.Title or "Modern IDE"
    
    local window = createBaseWindow(config)
    table.insert(self.OpenWindows, window)
    
    return window
end

function IDE:SetTheme(themeName)
    if self.Themes[themeName] then
        self.SelectedTheme = themeName
        self:_updateTheme()
        return true
    end
    return false
end

function IDE:_updateTheme()
    for _, window in ipairs(self.OpenWindows) do
        if window.UpdateTheme then
            window:UpdateTheme()
        end
    end
end

function IDE:Destroy()
    for _, window in ipairs(self.OpenWindows) do
        if window.Destroy then
            window:Destroy()
        end
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    table.clear(self.OpenWindows)
    table.clear(self.Options)
end

function IDE:Notify(options)
    local Notification = require(Components.Notification)
    return Notification.new(self, options)
end

return IDE