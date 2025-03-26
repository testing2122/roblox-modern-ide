--!strict
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utils = script.Parent.Parent.Utils
local Elements = script.Parent.Parent.Elements

local Theme = require(Utils.Theme)
local Acrylic = require(Utils.Acrylic)
local Signal = require(Utils.Signal)
local TabSystem = require(Elements.TabSystem)
local MenuBar = require(Elements.MenuBar)
local ProjectExplorer = require(Elements.ProjectExplorer)
local CodeEditor = require(Elements.CodeEditor)
local PropertyPanel = require(Elements.PropertyPanel)
local Console = require(Elements.Console)

local Window = {}
Window.__index = Window

local WINDOW_PADDING = 5
local TITLE_BAR_HEIGHT = 30
local MIN_WINDOW_SIZE = Vector2.new(600, 400)

function Window.new(ide, config)
    local self = setmetatable({}, Window)
    
    self.IDE = ide
    self.Config = config or {}
    self.Signals = {
        WindowClosed = Signal.new(),
        WindowResized = Signal.new(),
        WindowMoved = Signal.new()
    }
    
    self.Title = config.Title or "Modern IDE"
    self.Size = config.Size or UDim2.fromOffset(800, 600)
    self.MinSize = config.MinSize or MIN_WINDOW_SIZE
    self.Position = config.Position or UDim2.fromScale(0.5, 0.5)
    self.Draggable = (config.Draggable ~= nil) and config.Draggable or true
    self.Resizable = (config.Resizable ~= nil) and config.Resizable or true
    self.UseAcrylic = (config.UseAcrylic ~= nil) and config.UseAcrylic or true
    
    -- Create UI
    self:_createUI()
    
    return self
end

function Window:_createUI()
    local theme = Theme.GetTheme(self.IDE.SelectedTheme)
    
    -- Main frame
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "IDEWindow"
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Frame.BackgroundColor3 = theme.Background
    self.Frame.BorderSizePixel = 0
    self.Frame.ClipsDescendants = true
    self.Frame.Parent = self.IDE.ScreenGui
    
    -- Apply acrylic effect if enabled
    if self.UseAcrylic then
        Acrylic.ApplyAcrylic(self.Frame, theme.Background, 0.85)
    end
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.SliceScale = 0.04
    shadow.Parent = self.Frame
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, TITLE_BAR_HEIGHT)
    self.TitleBar.BackgroundColor3 = theme.TitleBar
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Frame
    
    -- Title text
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "Title"
    self.TitleText.Size = UDim2.new(1, -100, 1, 0)
    self.TitleText.Position = UDim2.fromOffset(10, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Font = Enum.Font.SourceSansBold
    self.TitleText.Text = self.Title
    self.TitleText.TextColor3 = theme.TextColor
    self.TitleText.TextSize = 16
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.Parent = self.TitleBar
    
    -- Window controls
    self:_createWindowControls()
    
    -- Content area
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, 0, 1, -TITLE_BAR_HEIGHT)
    self.Content.Position = UDim2.fromOffset(0, TITLE_BAR_HEIGHT)
    self.Content.BackgroundTransparency = 1
    self.Content.BorderSizePixel = 0
    self.Content.Parent = self.Frame
    
    -- Create layout
    self:_createLayout()
    
    -- Set up dragging
    if self.Draggable then
        self:_setupDragging()
    end
    
    -- Set up resizing
    if self.Resizable then
        self:_setupResizing()
    end
end

function Window:UpdateTheme()
    local theme = Theme.GetTheme(self.IDE.SelectedTheme)
    
    -- Update main elements
    self.Frame.BackgroundColor3 = theme.Background
    self.TitleBar.BackgroundColor3 = theme.TitleBar
    self.TitleText.TextColor3 = theme.TextColor
    
    -- Update child components
    if self.TabSystem and self.TabSystem.UpdateTheme then
        self.TabSystem:UpdateTheme()
    end
    
    if self.MenuBar and self.MenuBar.UpdateTheme then
        self.MenuBar:UpdateTheme()
    end
    
    if self.ProjectExplorer and self.ProjectExplorer.UpdateTheme then
        self.ProjectExplorer:UpdateTheme()
    end
    
    if self.CodeEditor and self.CodeEditor.UpdateTheme then
        self.CodeEditor:UpdateTheme()
    end
    
    if self.Console and self.Console.UpdateTheme then
        self.Console:UpdateTheme()
    end
    
    if self.PropertyPanel and self.PropertyPanel.UpdateTheme then
        self.PropertyPanel:UpdateTheme()
    end
end

function Window:Destroy()
    -- Disconnect all signals
    for _, signal in pairs(self.Signals) do
        signal:DisconnectAll()
    end
    
    -- Destroy UI
    if self.Frame then
        self.Frame:Destroy()
    end
end

return Window