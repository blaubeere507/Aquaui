--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                  AquaUI  •  Beta 2.0                      ║
    ║        Apple / macOS Inspired Roblox UI Library           ║
    ║         Pure Light Mode  •  SF Pro Design System          ║
    ║                                                           ║
    ║  Components:                                              ║
    ║    • Window       • Button      • Toggle                  ║
    ║    • Slider       • TextInput   • Label                   ║
    ║    • Separator    • Dropdown    • Notification            ║
    ║    • Section      • Keybind     • Hide/Show Toggle        ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

local AquaUI = {}
AquaUI.__index = AquaUI

-- ─────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────
-- Theme  (Pure Apple Light Mode)
-- ─────────────────────────────────────────────
AquaUI.Theme = {
    -- Backgrounds  (macOS Ventura / iOS 17 light)
    WindowBG        = Color3.fromRGB(242, 242, 247),   -- systemGroupedBackground
    SidebarBG       = Color3.fromRGB(255, 255, 255),   -- pure white sidebar
    ElementBG       = Color3.fromRGB(255, 255, 255),   -- white cards
    ElementHover    = Color3.fromRGB(246, 246, 248),
    ElementActive   = Color3.fromRGB(235, 235, 240),

    -- Glass / blur illusion
    GlassBG         = Color3.fromRGB(255, 255, 255),
    GlassBorder     = Color3.fromRGB(209, 209, 214),   -- separator grey

    -- Accent  (Apple Blue)
    Accent          = Color3.fromRGB(0,   122, 255),
    AccentHover     = Color3.fromRGB(40,  145, 255),
    AccentDim       = Color3.fromRGB(0,   90,  200),
    AccentSoft      = Color3.fromRGB(232, 243, 255),   -- tinted fill bg

    -- Text  (Apple semantic text colours)
    TextPrimary     = Color3.fromRGB(0,   0,   0),     -- label
    TextSecondary   = Color3.fromRGB(60,  60,  67),    -- secondaryLabel  ~0.6 alpha
    TextTertiary    = Color3.fromRGB(60,  60,  67),    -- tertiaryLabel   ~0.3 alpha
    TextAccent      = Color3.fromRGB(0,   122, 255),
    TextOnAccent    = Color3.fromRGB(255, 255, 255),

    -- Semantic
    Success         = Color3.fromRGB(52,  199, 89),
    Warning         = Color3.fromRGB(255, 149, 0),
    Danger          = Color3.fromRGB(255, 59,  48),

    -- Misc
    Separator       = Color3.fromRGB(198, 198, 200),
    Shadow          = Color3.fromRGB(0,   0,   0),
    TrafficRed      = Color3.fromRGB(255, 95,  86),
    TrafficYellow   = Color3.fromRGB(255, 189, 46),
    TrafficGreen    = Color3.fromRGB(40,  205, 65),

    -- Sizing
    CornerRadius    = UDim.new(0, 14),
    CornerRadiusSm  = UDim.new(0, 10),
    CornerRadiusXs  = UDim.new(0, 7),

    -- Fonts  (Gotham approximates SF Pro in Roblox)
    FontBold        = Enum.Font.GothamBold,
    FontSemiBold    = Enum.Font.GothamSemibold,
    FontRegular     = Enum.Font.Gotham,
    FontMono        = Enum.Font.RobotoMono,

    -- Animation  (Apple spring-like curves)
    TweenInfo       = TweenInfo.new(0.2,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoFast   = TweenInfo.new(0.1,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoSlow   = TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoSpring = TweenInfo.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

-- ─────────────────────────────────────────────
-- Default toggle keybind
-- ─────────────────────────────────────────────
AquaUI.ToggleKey = Enum.KeyCode.RightShift

-- ─────────────────────────────────────────────
-- Utility Helpers
-- ─────────────────────────────────────────────
local function Tween(obj, props, info)
    local ti = info or AquaUI.Theme.TweenInfo
    return TweenService:Create(obj, ti, props):Play()
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or AquaUI.Theme.CornerRadius
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or AquaUI.Theme.GlassBorder
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Shadow(parent, size, transparency)
    local s = Instance.new("ImageLabel")
    s.Name = "_Shadow"
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.BackgroundTransparency = 1
    s.Position = UDim2.new(0.5, 0, 0.5, 6)
    s.Size = UDim2.new(1, size or 40, 1, size or 40)
    s.ZIndex = parent.ZIndex - 1
    s.Image = "rbxassetid://6014261993"
    s.ImageColor3 = AquaUI.Theme.Shadow
    s.ImageTransparency = transparency or 0.72
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(49, 49, 450, 450)
    s.Parent = parent
    return s
end

local function Ripple(parent, x, y)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    r.BackgroundTransparency = 0.88
    r.AnchorPoint = Vector2.new(0.5, 0.5)
    r.Size = UDim2.new(0, 0, 0, 0)
    r.Position = UDim2.new(0, x, 0, y)
    r.ZIndex = parent.ZIndex + 10
    Corner(r, UDim.new(1, 0))
    r.Parent = parent

    local target = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    Tween(r, { Size = UDim2.new(0, target, 0, target), BackgroundTransparency = 1 },
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
    game:GetService("Debris"):AddItem(r, 0.55)
end

local function MakeDraggable(topbar, frame)
    local dragging, startPos, startFramePos = false, nil, nil
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            startFramePos = frame.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(
                startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
                startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
end

-- ─────────────────────────────────────────────
-- ROOT GUI
-- ─────────────────────────────────────────────
local function GetScreenGui()
    local existing = CoreGui:FindFirstChild("AquaUI_Root")
    if existing then return existing end
    local sg = Instance.new("ScreenGui")
    sg.Name = "AquaUI_Root"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui
    return sg
end

-- ═══════════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════════
function AquaUI:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "AquaUI Window"
    local subtitle = config.Subtitle or ""
    local size     = config.Size     or UDim2.new(0, 580, 0, 430)
    local position = config.Position or UDim2.new(0.5, -290, 0.5, -215)
    local toggleKey = config.ToggleKey or AquaUI.ToggleKey
    local T        = AquaUI.Theme

    local ScreenGui = GetScreenGui()
    local Window = {}

    -- ── Outer frame
    local WinFrame = Instance.new("Frame")
    WinFrame.Name = "AquaWindow"
    WinFrame.Size = size
    WinFrame.Position = position
    WinFrame.BackgroundColor3 = T.WindowBG
    WinFrame.BorderSizePixel = 0
    WinFrame.ClipsDescendants = false
    Corner(WinFrame, T.CornerRadius)
    Stroke(WinFrame, T.GlassBorder, 1, 0.3)
    Shadow(WinFrame, 50, 0.60)
    WinFrame.Parent = ScreenGui

    -- Clip inner content (separate inner frame)
    local InnerClip = Instance.new("Frame")
    InnerClip.Name = "InnerClip"
    InnerClip.Size = UDim2.new(1, 0, 1, 0)
    InnerClip.BackgroundTransparency = 1
    InnerClip.ClipsDescendants = true
    InnerClip.Parent = WinFrame
    Corner(InnerClip, T.CornerRadius)

    -- Scale-in entrance
    WinFrame.Size = UDim2.new(0, size.X.Offset * 0.85, 0, size.Y.Offset * 0.85)
    WinFrame.Position = UDim2.new(position.X.Scale, position.X.Offset + size.X.Offset * 0.075,
                                   position.Y.Scale, position.Y.Offset + size.Y.Offset * 0.075)
    WinFrame.BackgroundTransparency = 1
    Tween(WinFrame, { Size = size, Position = position, BackgroundTransparency = 0 }, T.TweenInfoSpring)

    -- ── Title bar  (pure white, macOS-style)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 52)
    TitleBar.BackgroundColor3 = T.SidebarBG
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = InnerClip

    -- Hairline separator under title bar
    local TitleSep = Instance.new("Frame")
    TitleSep.Size = UDim2.new(1, 0, 0, 1)
    TitleSep.Position = UDim2.new(0, 0, 0, 52)
    TitleSep.BackgroundColor3 = T.Separator
    TitleSep.BorderSizePixel = 0
    TitleSep.Parent = InnerClip

    -- Traffic lights
    local lights = {
        { name = "Close",    color = T.TrafficRed,    pos = 20 },
        { name = "Minimize", color = T.TrafficYellow, pos = 40 },
        { name = "Zoom",     color = T.TrafficGreen,  pos = 60 },
    }
    for _, l in ipairs(lights) do
        local dot = Instance.new("TextButton")
        dot.Name = l.name
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(0, l.pos, 0.5, -7)
        dot.BackgroundColor3 = l.color
        dot.Text = ""
        dot.BorderSizePixel = 0
        dot.AutoButtonColor = false
        dot.ZIndex = 4
        Corner(dot, UDim.new(1, 0))
        dot.Parent = TitleBar

        -- Subtle inner shadow ring
        Stroke(dot, Color3.new(0,0,0), 1, 0.88)

        dot.MouseEnter:Connect(function()
            Tween(dot, { BackgroundTransparency = 0.25 }, T.TweenInfoFast)
        end)
        dot.MouseLeave:Connect(function()
            Tween(dot, { BackgroundTransparency = 0 }, T.TweenInfoFast)
        end)

        if l.name == "Close" then
            dot.MouseButton1Click:Connect(function()
                Tween(WinFrame, { Size = UDim2.new(0, size.X.Offset * 0.85, 0, size.Y.Offset * 0.85),
                                  BackgroundTransparency = 1 }, T.TweenInfoSlow)
                task.delay(0.42, function() WinFrame:Destroy() end)
            end)
        elseif l.name == "Minimize" then
            local minimized = false
            dot.MouseButton1Click:Connect(function()
                minimized = not minimized
                Tween(WinFrame, { Size = minimized and UDim2.new(0, size.X.Offset, 0, 52) or size }, T.TweenInfo)
            end)
        end
    end

    -- Title text — centred, SF Pro style
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -160, 0, 18)
    TitleLabel.Position = UDim2.new(0, 80, 0, subtitle ~= "" and 8 or 0)
    TitleLabel.AnchorPoint = subtitle ~= "" and Vector2.new(0, 0) or Vector2.new(0, 0.5)
    TitleLabel.Position = subtitle ~= "" and UDim2.new(0.5, -80, 0, 8) or UDim2.new(0.5, -80, 0.5, 0)
    TitleLabel.Size = UDim2.new(0, 160, 0, 20)
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
    TitleLabel.Position = subtitle ~= "" and UDim2.new(0.5, 0, 0, 8) or UDim2.new(0.5, 0, 0.5, -9)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = T.TextPrimary
    TitleLabel.Font = T.FontSemiBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TitleBar

    if subtitle ~= "" then
        local SubLabel = Instance.new("TextLabel")
        SubLabel.Size = UDim2.new(0, 220, 0, 14)
        SubLabel.AnchorPoint = Vector2.new(0.5, 0)
        SubLabel.Position = UDim2.new(0.5, 0, 0, 30)
        SubLabel.BackgroundTransparency = 1
        SubLabel.Text = subtitle
        SubLabel.TextColor3 = T.TextSecondary
        SubLabel.Font = T.FontRegular
        SubLabel.TextSize = 11
        SubLabel.TextXAlignment = Enum.TextXAlignment.Center
        SubLabel.ZIndex = 3
        SubLabel.Parent = TitleBar
    end

    -- Keybind hint label (right-aligned in titlebar)
    local KeyHint = Instance.new("TextLabel")
    KeyHint.Size = UDim2.new(0, 120, 0, 14)
    KeyHint.AnchorPoint = Vector2.new(1, 0.5)
    KeyHint.Position = UDim2.new(1, -14, 0.5, 0)
    KeyHint.BackgroundTransparency = 1
    KeyHint.Text = tostring(toggleKey.Name) .. " to hide"
    KeyHint.TextColor3 = T.TextTertiary
    KeyHint.Font = T.FontRegular
    KeyHint.TextSize = 10
    KeyHint.TextXAlignment = Enum.TextXAlignment.Right
    KeyHint.ZIndex = 3
    KeyHint.Parent = TitleBar

    MakeDraggable(TitleBar, WinFrame)

    -- ── Sidebar
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 156, 1, -53)
    Sidebar.Position = UDim2.new(0, 0, 0, 53)
    Sidebar.BackgroundColor3 = T.SidebarBG
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.Parent = InnerClip

    -- Sidebar right hairline
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, -53)
    SidebarLine.Position = UDim2.new(0, 156, 0, 53)
    SidebarLine.BackgroundColor3 = T.Separator
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = InnerClip

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 2)
    SidebarLayout.Parent = Sidebar

    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingTop = UDim.new(0, 12)
    SidebarPad.PaddingLeft = UDim.new(0, 8)
    SidebarPad.PaddingRight = UDim.new(0, 8)
    SidebarPad.Parent = Sidebar

    -- ── Content area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -157, 1, -53)
    Content.Position = UDim2.new(0, 157, 0, 53)
    Content.BackgroundColor3 = T.WindowBG
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = InnerClip

    -- ── Tab management
    local tabPages   = {}
    local tabButtons = {}
    local activeTab  = nil

    local function SwitchTab(tabName)
        if activeTab == tabName then return end
        activeTab = tabName
        for name, page in pairs(tabPages) do
            page.Visible = name == tabName
        end
        for name, data in pairs(tabButtons) do
            local isActive = name == tabName
            Tween(data.bg, {
                BackgroundColor3 = isActive and T.AccentSoft or Color3.new(1,1,1),
                BackgroundTransparency = isActive and 0 or 1,
            }, T.TweenInfoFast)
            Tween(data.lbl, { TextColor3 = isActive and T.Accent or T.TextSecondary }, T.TweenInfoFast)
            if data.icon then
                Tween(data.icon, { TextColor3 = isActive and T.Accent or T.TextTertiary }, T.TweenInfoFast)
            end
        end
    end

    -- ── AddTab
    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local name = tabConfig.Name or ("Tab " .. (tabCount + 1))
        local icon = tabConfig.Icon or ""

        -- Sidebar button
        local TabBtn = Instance.new("Frame")
        TabBtn.Name = "Tab_" .. name
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.LayoutOrder = #tabPages + 1
        TabBtn.Parent = Sidebar

        local BtnBG = Instance.new("Frame")
        BtnBG.Size = UDim2.new(1, 0, 1, 0)
        BtnBG.BackgroundColor3 = Color3.new(1,1,1)
        BtnBG.BackgroundTransparency = 1
        BtnBG.BorderSizePixel = 0
        Corner(BtnBG, T.CornerRadiusSm)
        BtnBG.Parent = TabBtn

        local IconLbl
        if icon ~= "" then
            IconLbl = Instance.new("TextLabel")
            IconLbl.Size = UDim2.new(0, 22, 1, 0)
            IconLbl.Position = UDim2.new(0, 8, 0, 0)
            IconLbl.BackgroundTransparency = 1
            IconLbl.Text = icon
            IconLbl.TextColor3 = T.TextTertiary
            IconLbl.Font = T.FontRegular
            IconLbl.TextSize = 15
            IconLbl.ZIndex = 2
            IconLbl.Parent = BtnBG
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, icon ~= "" and -32 or -12, 1, 0)
        TabLabel.Position = UDim2.new(0, icon ~= "" and 32 or 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.TextColor3 = T.TextSecondary
        TabLabel.Font = T.FontSemiBold
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 2
        TabLabel.Parent = BtnBG

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 5
        ClickBtn.Parent = TabBtn

        tabButtons[name] = { bg = BtnBG, lbl = TabLabel, icon = IconLbl }

        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page_" .. name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = T.GlassBorder
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = Content

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop    = UDim.new(0, 16)
        PagePad.PaddingLeft   = UDim.new(0, 16)
        PagePad.PaddingRight  = UDim.new(0, 16)
        PagePad.PaddingBottom = UDim.new(0, 16)
        PagePad.Parent = Page

        tabPages[name] = Page

        ClickBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tween(BtnBG, { BackgroundTransparency = 0.6 }, T.TweenInfoFast)
                BtnBG.BackgroundColor3 = T.AccentSoft
            end
        end)
        ClickBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tween(BtnBG, { BackgroundTransparency = 1 }, T.TweenInfoFast)
            end
        end)
        ClickBtn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)

        if not activeTab then SwitchTab(name) end

        -- ── Tab API
        local Tab = {}

        function Tab:AddSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            local sName = sectionConfig.Name or "Section"
            local Section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section_" .. sName
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.LayoutOrder = #Page:GetChildren()
            SectionFrame.Parent = Page

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 1)   -- hairline gap between items (grouped style)
            SectionLayout.Parent = SectionFrame

            -- Section header label
            local HeaderPad = Instance.new("Frame")
            HeaderPad.Size = UDim2.new(1, 0, 0, 26)
            HeaderPad.BackgroundTransparency = 1
            HeaderPad.LayoutOrder = 0
            HeaderPad.Parent = SectionFrame

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Size = UDim2.new(1, -16, 1, 0)
            HeaderLabel.Position = UDim2.new(0, 16, 0, 0)
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Text = string.upper(sName)
            HeaderLabel.TextColor3 = T.TextTertiary
            HeaderLabel.Font = T.FontSemiBold
            HeaderLabel.TextSize = 11
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.Parent = HeaderPad

            -- Grouped container (rounded rect wrapping all children)
            local GroupBG = Instance.new("Frame")
            GroupBG.Name = "GroupBG"
            GroupBG.Size = UDim2.new(1, 0, 0, 0)
            GroupBG.AutomaticSize = Enum.AutomaticSize.Y
            GroupBG.BackgroundColor3 = T.ElementBG
            GroupBG.BorderSizePixel = 0
            GroupBG.LayoutOrder = 1
            GroupBG.ClipsDescendants = true
            Corner(GroupBG, T.CornerRadiusSm)
            Stroke(GroupBG, T.GlassBorder, 1, 0.4)
            GroupBG.Parent = SectionFrame

            local GroupLayout = Instance.new("UIListLayout")
            GroupLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupLayout.Padding = UDim.new(0, 0)
            GroupLayout.Parent = GroupBG

            local elementCount = 0

            -- Internal helper: hairline divider between items
            local function AddDivider(parentFrame, order)
                local d = Instance.new("Frame")
                d.Name = "_Divider"
                d.Size = UDim2.new(1, -16, 0, 1)
                d.Position = UDim2.new(0, 16, 0, 0)
                d.BackgroundColor3 = T.Separator
                d.BorderSizePixel = 0
                d.LayoutOrder = order
                d.Parent = parentFrame
            end

            -- ── BUTTON
            function Section:AddButton(btnConfig)
                btnConfig = btnConfig or {}
                local bLabel   = btnConfig.Name     or "Button"
                local bDesc    = btnConfig.Desc     or ""
                local callback = btnConfig.Callback or function() end

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn_" .. bLabel
                Btn.Size = UDim2.new(1, 0, 0, bDesc ~= "" and 56 or 44)
                Btn.BackgroundColor3 = T.ElementBG
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.BorderSizePixel = 0
                Btn.LayoutOrder = elementCount * 10
                Btn.Parent = GroupBG

                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Size = UDim2.new(1, -52, 0, 18)
                BtnLabel.Position = bDesc ~= "" and UDim2.new(0, 16, 0, 11) or UDim2.new(0, 16, 0.5, -9)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = bLabel
                BtnLabel.TextColor3 = T.TextPrimary
                BtnLabel.Font = T.FontRegular
                BtnLabel.TextSize = 14
                BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
                BtnLabel.Parent = Btn

                if bDesc ~= "" then
                    local Desc = Instance.new("TextLabel")
                    Desc.Size = UDim2.new(1, -52, 0, 14)
                    Desc.Position = UDim2.new(0, 16, 0, 30)
                    Desc.BackgroundTransparency = 1
                    Desc.Text = bDesc
                    Desc.TextColor3 = T.TextSecondary
                    Desc.Font = T.FontRegular
                    Desc.TextSize = 12
                    Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Desc.Parent = Btn
                end

                -- SF-style chevron
                local Chevron = Instance.new("TextLabel")
                Chevron.Size = UDim2.new(0, 20, 0, 20)
                Chevron.Position = UDim2.new(1, -32, 0.5, -10)
                Chevron.BackgroundTransparency = 1
                Chevron.Text = "›"
                Chevron.TextColor3 = T.GlassBorder
                Chevron.Font = T.FontBold
                Chevron.TextSize = 22
                Chevron.Parent = Btn

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, { BackgroundTransparency = 0, BackgroundColor3 = T.ElementHover }, T.TweenInfoFast)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, { BackgroundTransparency = 1 }, T.TweenInfoFast)
                end)
                Btn.MouseButton1Down:Connect(function()
                    Tween(Btn, { BackgroundTransparency = 0, BackgroundColor3 = T.ElementActive }, T.TweenInfoFast)
                end)
                Btn.MouseButton1Up:Connect(function()
                    Tween(Btn, { BackgroundTransparency = 0, BackgroundColor3 = T.ElementHover }, T.TweenInfoFast)
                end)
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn, Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y)
                    task.spawn(callback)
                end)

                return Btn
            end

            -- ── TOGGLE
            function Section:AddToggle(tConfig)
                tConfig = tConfig or {}
                local tLabel   = tConfig.Name     or "Toggle"
                local tDesc    = tConfig.Desc     or ""
                local default  = tConfig.Default  or false
                local callback = tConfig.Callback or function() end

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local state = default

                local Row = Instance.new("Frame")
                Row.Name = "Toggle_" .. tLabel
                Row.Size = UDim2.new(1, 0, 0, tDesc ~= "" and 56 or 44)
                Row.BackgroundColor3 = T.ElementBG
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount * 10
                Row.Parent = GroupBG

                local RowLabel = Instance.new("TextLabel")
                RowLabel.Size = UDim2.new(1, -72, 0, 18)
                RowLabel.Position = tDesc ~= "" and UDim2.new(0, 16, 0, 11) or UDim2.new(0, 16, 0.5, -9)
                RowLabel.BackgroundTransparency = 1
                RowLabel.Text = tLabel
                RowLabel.TextColor3 = T.TextPrimary
                RowLabel.Font = T.FontRegular
                RowLabel.TextSize = 14
                RowLabel.TextXAlignment = Enum.TextXAlignment.Left
                RowLabel.Parent = Row

                if tDesc ~= "" then
                    local Desc = Instance.new("TextLabel")
                    Desc.Size = UDim2.new(1, -72, 0, 14)
                    Desc.Position = UDim2.new(0, 16, 0, 30)
                    Desc.BackgroundTransparency = 1
                    Desc.Text = tDesc
                    Desc.TextColor3 = T.TextSecondary
                    Desc.Font = T.FontRegular
                    Desc.TextSize = 12
                    Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Desc.Parent = Row
                end

                -- Track (iOS toggle pill)
                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(0, 50, 0, 28)
                Track.Position = UDim2.new(1, -62, 0.5, -14)
                Track.BackgroundColor3 = state and T.Accent or Color3.fromRGB(225, 225, 230)
                Track.BorderSizePixel = 0
                Corner(Track, UDim.new(1, 0))
                Track.Parent = Row

                -- Knob shadow container
                local KnobShadowHolder = Instance.new("Frame")
                KnobShadowHolder.Size = UDim2.new(0, 24, 0, 24)
                KnobShadowHolder.Position = state and UDim2.new(1,-26,0.5,-12) or UDim2.new(0,2,0.5,-12)
                KnobShadowHolder.BackgroundColor3 = Color3.new(1,1,1)
                KnobShadowHolder.BorderSizePixel = 0
                Corner(KnobShadowHolder, UDim.new(1,0))
                Stroke(KnobShadowHolder, Color3.new(0,0,0), 1, 0.88)
                KnobShadowHolder.Parent = Track

                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.ZIndex = Row.ZIndex + 5
                ClickArea.Parent = Row

                ClickArea.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(Track, { BackgroundColor3 = state and T.Accent or Color3.fromRGB(225, 225, 230) }, T.TweenInfoFast)
                    Tween(KnobShadowHolder, {
                        Position = state and UDim2.new(1,-26,0.5,-12) or UDim2.new(0,2,0.5,-12)
                    }, T.TweenInfo)
                    task.spawn(callback, state)
                end)

                local ToggleAPI = {}
                function ToggleAPI:Set(val)
                    state = val
                    Tween(Track, { BackgroundColor3 = state and T.Accent or Color3.fromRGB(225, 225, 230) }, T.TweenInfoFast)
                    Tween(KnobShadowHolder, {
                        Position = state and UDim2.new(1,-26,0.5,-12) or UDim2.new(0,2,0.5,-12)
                    }, T.TweenInfo)
                end
                function ToggleAPI:Get() return state end
                return ToggleAPI
            end

            -- ── SLIDER
            function Section:AddSlider(sConfig)
                sConfig = sConfig or {}
                local sLabel   = sConfig.Name     or "Slider"
                local sMin     = sConfig.Min      or 0
                local sMax     = sConfig.Max      or 100
                local sDefault = sConfig.Default  or sMin
                local sSuffix  = sConfig.Suffix   or ""
                local callback = sConfig.Callback or function() end

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local value = math.clamp(sDefault, sMin, sMax)

                local Row = Instance.new("Frame")
                Row.Name = "Slider_" .. sLabel
                Row.Size = UDim2.new(1, 0, 0, 60)
                Row.BackgroundColor3 = T.ElementBG
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount * 10
                Row.Parent = GroupBG

                local SLabel = Instance.new("TextLabel")
                SLabel.Size = UDim2.new(0.55, 0, 0, 18)
                SLabel.Position = UDim2.new(0, 16, 0, 12)
                SLabel.BackgroundTransparency = 1
                SLabel.Text = sLabel
                SLabel.TextColor3 = T.TextPrimary
                SLabel.Font = T.FontRegular
                SLabel.TextSize = 14
                SLabel.TextXAlignment = Enum.TextXAlignment.Left
                SLabel.Parent = Row

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0.4, -16, 0, 18)
                ValLabel.Position = UDim2.new(0.6, 0, 0, 12)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(value) .. sSuffix
                ValLabel.TextColor3 = T.TextAccent
                ValLabel.Font = T.FontSemiBold
                ValLabel.TextSize = 14
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = Row

                -- Track background
                local TrackBG = Instance.new("Frame")
                TrackBG.Size = UDim2.new(1, -32, 0, 5)
                TrackBG.Position = UDim2.new(0, 16, 0, 40)
                TrackBG.BackgroundColor3 = Color3.fromRGB(209, 209, 214)
                TrackBG.BorderSizePixel = 0
                Corner(TrackBG, UDim.new(1, 0))
                TrackBG.Parent = Row

                -- Filled portion
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((value - sMin) / (sMax - sMin), 0, 1, 0)
                Fill.BackgroundColor3 = T.Accent
                Fill.BorderSizePixel = 0
                Corner(Fill, UDim.new(1, 0))
                Fill.Parent = TrackBG

                -- Knob
                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 20, 0, 20)
                Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob.Position = UDim2.new((value - sMin) / (sMax - sMin), 0, 0.5, 0)
                Knob.BackgroundColor3 = Color3.new(1, 1, 1)
                Knob.BorderSizePixel = 0
                Corner(Knob, UDim.new(1, 0))
                Stroke(Knob, Color3.new(0,0,0), 1, 0.88)
                Knob.ZIndex = TrackBG.ZIndex + 2
                Knob.Parent = TrackBG

                local draggingSlider = false

                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1, 0, 0, 28)
                ClickArea.Position = UDim2.new(0, 0, 0, -12)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.ZIndex = TrackBG.ZIndex + 5
                ClickArea.Parent = TrackBG

                local function UpdateSlider(inputX)
                    local rel = math.clamp((inputX - TrackBG.AbsolutePosition.X) / TrackBG.AbsoluteSize.X, 0, 1)
                    value = math.floor(sMin + rel * (sMax - sMin) + 0.5)
                    local p = (value - sMin) / (sMax - sMin)
                    Tween(Fill,  { Size = UDim2.new(p, 0, 1, 0) }, T.TweenInfoFast)
                    Tween(Knob, { Position = UDim2.new(p, 0, 0.5, 0) }, T.TweenInfoFast)
                    ValLabel.Text = tostring(value) .. sSuffix
                    task.spawn(callback, value)
                end

                ClickArea.MouseButton1Down:Connect(function()
                    draggingSlider = true
                    UpdateSlider(Mouse.X)
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                RunService.RenderStepped:Connect(function()
                    if draggingSlider then UpdateSlider(Mouse.X) end
                end)

                local SliderAPI = {}
                function SliderAPI:Set(v)
                    value = math.clamp(v, sMin, sMax)
                    local p = (value - sMin) / (sMax - sMin)
                    Tween(Fill,  { Size = UDim2.new(p, 0, 1, 0) }, T.TweenInfoFast)
                    Tween(Knob, { Position = UDim2.new(p, 0, 0.5, 0) }, T.TweenInfoFast)
                    ValLabel.Text = tostring(value) .. sSuffix
                end
                function SliderAPI:Get() return value end
                return SliderAPI
            end

            -- ── TEXT INPUT
            function Section:AddTextInput(iConfig)
                iConfig = iConfig or {}
                local iLabel       = iConfig.Name        or "Input"
                local iPlaceholder = iConfig.Placeholder or "Type here..."
                local iDefault     = iConfig.Default     or ""
                local callback     = iConfig.Callback    or function() end

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local Row = Instance.new("Frame")
                Row.Name = "Input_" .. iLabel
                Row.Size = UDim2.new(1, 0, 0, 60)
                Row.BackgroundColor3 = T.ElementBG
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount * 10
                Row.Parent = GroupBG

                local ILabel = Instance.new("TextLabel")
                ILabel.Size = UDim2.new(1, -16, 0, 16)
                ILabel.Position = UDim2.new(0, 16, 0, 11)
                ILabel.BackgroundTransparency = 1
                ILabel.Text = iLabel
                ILabel.TextColor3 = T.TextSecondary
                ILabel.Font = T.FontSemiBold
                ILabel.TextSize = 11
                ILabel.TextXAlignment = Enum.TextXAlignment.Left
                ILabel.Parent = Row

                local InputBG = Instance.new("Frame")
                InputBG.Size = UDim2.new(1, -32, 0, 26)
                InputBG.Position = UDim2.new(0, 16, 0, 29)
                InputBG.BackgroundColor3 = Color3.fromRGB(242, 242, 247)
                InputBG.BorderSizePixel = 0
                Corner(InputBG, T.CornerRadiusXs)
                local inputStroke = Stroke(InputBG, T.GlassBorder, 1, 0.3)
                InputBG.Parent = Row

                local TBox = Instance.new("TextBox")
                TBox.Size = UDim2.new(1, -16, 1, 0)
                TBox.Position = UDim2.new(0, 8, 0, 0)
                TBox.BackgroundTransparency = 1
                TBox.Text = iDefault
                TBox.PlaceholderText = iPlaceholder
                TBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 190)
                TBox.TextColor3 = T.TextPrimary
                TBox.Font = T.FontRegular
                TBox.TextSize = 13
                TBox.TextXAlignment = Enum.TextXAlignment.Left
                TBox.ClearTextOnFocus = false
                TBox.Parent = InputBG

                TBox.Focused:Connect(function()
                    Tween(inputStroke, { Color = T.Accent, Thickness = 2 }, T.TweenInfoFast)
                end)
                TBox.FocusLost:Connect(function(enter)
                    Tween(inputStroke, { Color = T.GlassBorder, Thickness = 1 }, T.TweenInfoFast)
                    if enter then task.spawn(callback, TBox.Text) end
                end)

                local InputAPI = {}
                function InputAPI:Set(v) TBox.Text = v end
                function InputAPI:Get() return TBox.Text end
                return InputAPI
            end

            -- ── DROPDOWN
            function Section:AddDropdown(dConfig)
                dConfig = dConfig or {}
                local dLabel   = dConfig.Name     or "Dropdown"
                local options  = dConfig.Options  or {}
                local default  = dConfig.Default  or (options[1] or "Select...")
                local callback = dConfig.Callback or function() end

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local selected = default
                local open = false

                -- Row wrapper (needs overflow so list floats above)
                local RowWrapper = Instance.new("Frame")
                RowWrapper.Name = "DD_" .. dLabel
                RowWrapper.Size = UDim2.new(1, 0, 0, 44)
                RowWrapper.BackgroundTransparency = 1
                RowWrapper.ClipsDescendants = false
                RowWrapper.ZIndex = 20
                RowWrapper.LayoutOrder = elementCount * 10
                RowWrapper.Parent = GroupBG

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1, 0, 1, 0)
                Row.BackgroundColor3 = T.ElementBG
                Row.BackgroundTransparency = 1
                Row.Text = ""
                Row.AutoButtonColor = false
                Row.BorderSizePixel = 0
                Row.ZIndex = 20
                Row.Parent = RowWrapper

                local DLabel = Instance.new("TextLabel")
                DLabel.Size = UDim2.new(0.55, 0, 1, 0)
                DLabel.Position = UDim2.new(0, 16, 0, 0)
                DLabel.BackgroundTransparency = 1
                DLabel.Text = dLabel
                DLabel.TextColor3 = T.TextPrimary
                DLabel.Font = T.FontRegular
                DLabel.TextSize = 14
                DLabel.TextXAlignment = Enum.TextXAlignment.Left
                DLabel.ZIndex = 21
                DLabel.Parent = Row

                local SelLabel = Instance.new("TextLabel")
                SelLabel.Size = UDim2.new(0.4, -32, 1, 0)
                SelLabel.Position = UDim2.new(0.55, 0, 0, 0)
                SelLabel.BackgroundTransparency = 1
                SelLabel.Text = selected
                SelLabel.TextColor3 = T.TextSecondary
                SelLabel.Font = T.FontRegular
                SelLabel.TextSize = 14
                SelLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelLabel.ZIndex = 21
                SelLabel.Parent = Row

                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.new(0, 24, 1, 0)
                Arrow.Position = UDim2.new(1, -28, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "›"
                Arrow.TextColor3 = T.GlassBorder
                Arrow.Font = T.FontBold
                Arrow.TextSize = 18
                Arrow.Rotation = 90
                Arrow.ZIndex = 21
                Arrow.Parent = Row

                -- Floating dropdown panel
                local DropList = Instance.new("Frame")
                DropList.Size = UDim2.new(1, 0, 0, 0)
                DropList.Position = UDim2.new(0, 0, 0, 46)
                DropList.BackgroundColor3 = T.GlassBG
                DropList.BorderSizePixel = 0
                DropList.ClipsDescendants = true
                DropList.ZIndex = 100
                Corner(DropList, T.CornerRadiusSm)
                Stroke(DropList, T.GlassBorder, 1, 0.3)
                Shadow(DropList, 20, 0.65)
                DropList.Parent = RowWrapper

                local DListLayout = Instance.new("UIListLayout")
                DListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DListLayout.Parent = DropList

                for i, opt in ipairs(options) do
                    if i > 1 then
                        local d = Instance.new("Frame")
                        d.Size = UDim2.new(1, -16, 0, 1)
                        d.Position = UDim2.new(0, 8, 0, 0)
                        d.BackgroundColor3 = T.Separator
                        d.BorderSizePixel = 0
                        d.LayoutOrder = i * 2 - 1
                        d.ZIndex = 101
                        d.Parent = DropList
                    end

                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 36)
                    OptBtn.BackgroundColor3 = T.ElementBG
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    OptBtn.LayoutOrder = i * 2
                    OptBtn.ZIndex = 101
                    OptBtn.Parent = DropList

                    local OptLabel = Instance.new("TextLabel")
                    OptLabel.Size = UDim2.new(1, -40, 1, 0)
                    OptLabel.Position = UDim2.new(0, 16, 0, 0)
                    OptLabel.BackgroundTransparency = 1
                    OptLabel.Text = opt
                    OptLabel.TextColor3 = T.TextPrimary
                    OptLabel.Font = T.FontRegular
                    OptLabel.TextSize = 14
                    OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptLabel.ZIndex = 102
                    OptLabel.Parent = OptBtn

                    -- Checkmark for selected
                    local Check = Instance.new("TextLabel")
                    Check.Size = UDim2.new(0, 20, 1, 0)
                    Check.Position = UDim2.new(1, -28, 0, 0)
                    Check.BackgroundTransparency = 1
                    Check.Text = opt == selected and "✓" or ""
                    Check.TextColor3 = T.Accent
                    Check.Font = T.FontBold
                    Check.TextSize = 14
                    Check.ZIndex = 102
                    Check.Parent = OptBtn

                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, { BackgroundTransparency = 0, BackgroundColor3 = T.ElementHover }, T.TweenInfoFast)
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, { BackgroundTransparency = 1 }, T.TweenInfoFast)
                    end)
                    OptBtn.MouseButton1Click:Connect(function()
                        -- Clear old check
                        for _, child in pairs(DropList:GetChildren()) do
                            local lbl = child:FindFirstChildOfClass("TextLabel")
                            if lbl and lbl.Name == "" then
                                local chk = child:FindFirstChild("Check") or child:GetChildren()[2]
                            end
                            -- iterate all optbtns
                            if child:IsA("TextButton") then
                                local ck = child:FindFirstChildOfClass("TextLabel")
                                -- find last textlabel (check)
                                for _, c in pairs(child:GetChildren()) do
                                    if c:IsA("TextLabel") and c.Text == "✓" then
                                        c.Text = ""
                                    end
                                end
                            end
                        end
                        Check.Text = "✓"
                        selected = opt
                        SelLabel.Text = opt
                        open = false
                        Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, T.TweenInfoFast)
                        Arrow.Rotation = 90
                        task.spawn(callback, opt)
                    end)
                end

                Row.MouseButton1Click:Connect(function()
                    open = not open
                    local targetH = open and (math.min(#options, 6) * 36 + math.max(0, math.min(#options, 6)-1)) or 0
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, targetH) }, T.TweenInfo)
                    Tween(Arrow, { Rotation = open and 270 or 90 }, T.TweenInfoFast)
                end)

                local DAPI = {}
                function DAPI:Set(v) selected = v; SelLabel.Text = v end
                function DAPI:Get() return selected end
                return DAPI
            end

            -- ── LABEL
            function Section:AddLabel(lConfig)
                lConfig = lConfig or {}
                local text  = lConfig.Text  or "Label"
                local color = lConfig.Color or T.TextSecondary

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local Lbl = Instance.new("TextLabel")
                Lbl.Name = "Label"
                Lbl.Size = UDim2.new(1, 0, 0, 40)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = text
                Lbl.TextColor3 = color
                Lbl.Font = T.FontRegular
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.LayoutOrder = elementCount * 10
                local LblPad = Instance.new("UIPadding")
                LblPad.PaddingLeft = UDim.new(0, 16)
                LblPad.Parent = Lbl
                Lbl.Parent = GroupBG

                local LblAPI = {}
                function LblAPI:Set(t) Lbl.Text = t end
                return LblAPI
            end

            -- ── SEPARATOR  (outside of grouped box — section-level gap)
            function Section:AddSeparator()
                -- Simply ends current group visually by returning; groups already separate
                -- but we can add a small spacer
                local Spacer = Instance.new("Frame")
                Spacer.Size = UDim2.new(1, 0, 0, 8)
                Spacer.BackgroundTransparency = 1
                Spacer.LayoutOrder = (elementCount + 1) * 10
                Spacer.Parent = SectionFrame
            end

            -- ── KEYBIND
            function Section:AddKeybind(kConfig)
                kConfig = kConfig or {}
                local kLabel    = kConfig.Name     or "Keybind"
                local kDefault  = kConfig.Default  or Enum.KeyCode.Unknown
                local callback  = kConfig.Callback or function() end

                elementCount += 1
                if elementCount > 1 then AddDivider(GroupBG, elementCount * 10 - 1) end

                local boundKey = kDefault
                local listening = false

                local Row = Instance.new("Frame")
                Row.Name = "Keybind_" .. kLabel
                Row.Size = UDim2.new(1, 0, 0, 44)
                Row.BackgroundTransparency = 1
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount * 10
                Row.Parent = GroupBG

                local KLabel = Instance.new("TextLabel")
                KLabel.Size = UDim2.new(1, -120, 1, 0)
                KLabel.Position = UDim2.new(0, 16, 0, 0)
                KLabel.BackgroundTransparency = 1
                KLabel.Text = kLabel
                KLabel.TextColor3 = T.TextPrimary
                KLabel.Font = T.FontRegular
                KLabel.TextSize = 14
                KLabel.TextXAlignment = Enum.TextXAlignment.Left
                KLabel.Parent = Row

                -- Key pill badge
                local KeyPill = Instance.new("TextButton")
                KeyPill.Size = UDim2.new(0, 90, 0, 26)
                KeyPill.Position = UDim2.new(1, -104, 0.5, -13)
                KeyPill.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
                KeyPill.Text = boundKey == Enum.KeyCode.Unknown and "Click to set" or boundKey.Name
                KeyPill.TextColor3 = T.TextAccent
                KeyPill.Font = T.FontSemiBold
                KeyPill.TextSize = 11
                KeyPill.AutoButtonColor = false
                KeyPill.BorderSizePixel = 0
                Corner(KeyPill, T.CornerRadiusXs)
                Stroke(KeyPill, T.GlassBorder, 1, 0.4)
                KeyPill.Parent = Row

                KeyPill.MouseButton1Click:Connect(function()
                    listening = true
                    KeyPill.Text = "…"
                    KeyPill.TextColor3 = T.Warning
                    Tween(KeyPill, { BackgroundColor3 = Color3.fromRGB(255, 245, 220) }, T.TweenInfoFast)
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and not processed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            boundKey = input.KeyCode
                            listening = false
                            KeyPill.Text = boundKey.Name
                            KeyPill.TextColor3 = T.TextAccent
                            Tween(KeyPill, { BackgroundColor3 = Color3.fromRGB(235, 235, 240) }, T.TweenInfoFast)
                            task.spawn(callback, boundKey)
                        end
                    end
                end)

                local KAPI = {}
                function KAPI:Get() return boundKey end
                function KAPI:Set(k)
                    boundKey = k
                    KeyPill.Text = k.Name
                end
                return KAPI
            end

            return Section
        end

        return Tab
    end

    -- ── Sidebar footer
    local FooterLabel = Instance.new("TextLabel")
    FooterLabel.Size = UDim2.new(1, 0, 0, 20)
    FooterLabel.Position = UDim2.new(0, 0, 1, -24)
    FooterLabel.BackgroundTransparency = 1
    FooterLabel.Text = "AquaUI  β2.0"
    FooterLabel.TextColor3 = T.TextTertiary
    FooterLabel.Font = T.FontRegular
    FooterLabel.TextSize = 10
    FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
    FooterLabel.Parent = Sidebar

    -- ══════════════════════════════════════════
    --  KEYBIND — HIDE / SHOW WINDOW
    -- ══════════════════════════════════════════
    local windowVisible = true

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            windowVisible = not windowVisible
            if windowVisible then
                WinFrame.Visible = true
                WinFrame.BackgroundTransparency = 1
                WinFrame.Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9)
                WinFrame.Position = UDim2.new(
                    position.X.Scale, position.X.Offset + size.X.Offset * 0.05,
                    position.Y.Scale, position.Y.Offset + size.Y.Offset * 0.05)
                Tween(WinFrame, { BackgroundTransparency = 0, Size = size, Position = position }, T.TweenInfoSpring)
                -- Notify
                AquaUI:Notify({ Title = "UI Shown", Desc = "Press " .. toggleKey.Name .. " to hide.", Type = "Info", Duration = 2 })
            else
                Tween(WinFrame, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9),
                    Position = UDim2.new(position.X.Scale, position.X.Offset + size.X.Offset * 0.05,
                                         position.Y.Scale, position.Y.Offset + size.Y.Offset * 0.05),
                }, T.TweenInfoSlow)
                task.delay(0.4, function()
                    if not windowVisible then WinFrame.Visible = false end
                end)
            end
        end
    end)

    -- Expose toggle API
    function Window:SetToggleKey(key)
        toggleKey = key
        KeyHint.Text = tostring(key.Name) .. " to hide"
    end

    function Window:Toggle()
        windowVisible = not windowVisible
        WinFrame.Visible = windowVisible
    end

    return Window
end

-- ═══════════════════════════════════════════════════════════════
--  NOTIFICATION  (light mode, frosted card style)
-- ═══════════════════════════════════════════════════════════════
function AquaUI:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notification"
    local desc     = config.Desc     or ""
    local duration = config.Duration or 4
    local type_    = config.Type     or "Info"
    local T        = AquaUI.Theme

    local accentColors = {
        Info    = T.Accent,
        Success = T.Success,
        Warning = T.Warning,
        Danger  = T.Danger,
    }
    local accent = accentColors[type_] or T.Accent

    local ScreenGui = GetScreenGui()

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 0)
    Notif.AnchorPoint = Vector2.new(0, 1)
    Notif.Position = UDim2.new(1, 10, 1, -24)
    Notif.BackgroundColor3 = Color3.new(1, 1, 1)
    Notif.BorderSizePixel = 0
    Notif.AutomaticSize = Enum.AutomaticSize.Y
    Notif.ClipsDescendants = false
    Corner(Notif, T.CornerRadiusSm)
    Stroke(Notif, T.GlassBorder, 1, 0.3)
    Shadow(Notif, 24, 0.72)
    Notif.Parent = ScreenGui

    -- Accent dot
    local AccentDot = Instance.new("Frame")
    AccentDot.Size = UDim2.new(0, 8, 0, 8)
    AccentDot.Position = UDim2.new(0, 14, 0, 0)
    AccentDot.AnchorPoint = Vector2.new(0, 0.5)
    AccentDot.BackgroundColor3 = accent
    AccentDot.BorderSizePixel = 0
    -- Will be repositioned after layout
    Corner(AccentDot, UDim.new(1, 0))
    AccentDot.Parent = Notif

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -36, 0, 20)
    NTitle.Position = UDim2.new(0, 30, 0, 12)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = T.TextPrimary
    NTitle.Font = T.FontSemiBold
    NTitle.TextSize = 14
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notif

    -- Reposition dot vertically centred with title
    AccentDot.Position = UDim2.new(0, 14, 0, 20)

    if desc ~= "" then
        local NDesc = Instance.new("TextLabel")
        NDesc.Size = UDim2.new(1, -28, 0, 0)
        NDesc.Position = UDim2.new(0, 14, 0, 34)
        NDesc.BackgroundTransparency = 1
        NDesc.Text = desc
        NDesc.TextColor3 = T.TextSecondary
        NDesc.Font = T.FontRegular
        NDesc.TextSize = 12
        NDesc.TextWrapped = true
        NDesc.AutomaticSize = Enum.AutomaticSize.Y
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.Parent = Notif
    end

    -- Progress bar
    local ProgBG = Instance.new("Frame")
    ProgBG.Size = UDim2.new(1, -28, 0, 2)
    ProgBG.Position = UDim2.new(0, 14, 1, -10)
    ProgBG.BackgroundColor3 = Color3.fromRGB(209, 209, 214)
    ProgBG.BorderSizePixel = 0
    Corner(ProgBG, UDim.new(1, 0))
    ProgBG.Parent = Notif

    local Prog = Instance.new("Frame")
    Prog.Size = UDim2.new(1, 0, 1, 0)
    Prog.BackgroundColor3 = accent
    Prog.BorderSizePixel = 0
    Corner(Prog, UDim.new(1, 0))
    Prog.Parent = ProgBG

    -- Slide in
    Tween(Notif, { Position = UDim2.new(1, -314, 1, -24) }, T.TweenInfoSpring)

    -- Drain
    Tween(Prog, { Size = UDim2.new(0, 0, 1, 0) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))

    task.delay(duration, function()
        Tween(Notif, { Position = UDim2.new(1, 10, 1, -24), BackgroundTransparency = 1 }, T.TweenInfo)
        task.delay(0.28, function() Notif:Destroy() end)
    end)

    return Notif
end

return AquaUI
