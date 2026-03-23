--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                  AquaUI  •  Beta 1.0                      ║
    ║        Apple / macOS Inspired Roblox UI Library           ║
    ║                                                           ║
    ║  Components:                                              ║
    ║    • Window       • Button      • Toggle                  ║
    ║    • Slider       • TextInput   • Label                   ║
    ║    • Separator    • Dropdown    • Notification            ║
    ║    • Section      • ColorPicker • Keybind                 ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

local AquaUI = {}
AquaUI.__index = AquaUI

-- ─────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────
-- Theme
-- ─────────────────────────────────────────────
AquaUI.Theme = {
    -- Backgrounds
    WindowBG        = Color3.fromRGB(28,  28,  30),   -- macOS dark window
    SidebarBG       = Color3.fromRGB(22,  22,  24),
    ElementBG       = Color3.fromRGB(44,  44,  46),
    ElementHover    = Color3.fromRGB(58,  58,  62),
    ElementActive   = Color3.fromRGB(72,  72,  76),

    -- Glass
    GlassBG         = Color3.fromRGB(38,  38,  42),
    GlassBorder     = Color3.fromRGB(70,  70,  75),

    -- Accent (Apple Blue)
    Accent          = Color3.fromRGB(10,  132, 255),
    AccentHover     = Color3.fromRGB(50,  155, 255),
    AccentDim       = Color3.fromRGB(10,  100, 200),

    -- Text
    TextPrimary     = Color3.fromRGB(255, 255, 255),
    TextSecondary   = Color3.fromRGB(160, 160, 168),
    TextTertiary    = Color3.fromRGB(100, 100, 108),
    TextAccent      = Color3.fromRGB(10,  132, 255),

    -- Semantic
    Success         = Color3.fromRGB(48,  209, 88),
    Warning         = Color3.fromRGB(255, 159, 10),
    Danger          = Color3.fromRGB(255, 69,  58),

    -- Misc
    Separator       = Color3.fromRGB(55,  55,  60),
    Shadow          = Color3.fromRGB(0,   0,   0),
    TrafficRed      = Color3.fromRGB(255, 95,  86),
    TrafficYellow   = Color3.fromRGB(255, 189, 46),
    TrafficGreen    = Color3.fromRGB(39,  201, 63),

    -- Sizing
    CornerRadius    = UDim.new(0, 12),
    CornerRadiusSm  = UDim.new(0, 8),
    CornerRadiusXs  = UDim.new(0, 6),

    -- Fonts
    FontBold        = Enum.Font.GothamBold,
    FontSemiBold    = Enum.Font.GothamSemibold,
    FontRegular     = Enum.Font.Gotham,
    FontMono        = Enum.Font.RobotoMono,

    -- Animation
    TweenInfo       = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoFast   = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenInfoSlow   = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

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
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Shadow(parent, size, transparency)
    local s = Instance.new("ImageLabel")
    s.Name = "_Shadow"
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.BackgroundTransparency = 1
    s.Position = UDim2.new(0.5, 0, 0.5, 4)
    s.Size = UDim2.new(1, size or 30, 1, size or 30)
    s.ZIndex = parent.ZIndex - 1
    s.Image = "rbxassetid://6014261993"
    s.ImageColor3 = AquaUI.Theme.Shadow
    s.ImageTransparency = transparency or 0.55
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(49, 49, 450, 450)
    s.Parent = parent
    return s
end

local function Ripple(parent, x, y)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = Color3.new(1, 1, 1)
    r.BackgroundTransparency = 0.85
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

-- Dragging helper
local function MakeDraggable(topbar, frame)
    local dragging, dragInput, startPos, startFramePos = false, nil, nil, nil

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
                startFramePos.X.Scale,
                startFramePos.X.Offset + delta.X,
                startFramePos.Y.Scale,
                startFramePos.Y.Offset + delta.Y
            )
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
    local size     = config.Size     or UDim2.new(0, 560, 0, 400)
    local position = config.Position or UDim2.new(0.5, -280, 0.5, -200)
    local tabs     = config.Tabs     or {}
    local T        = AquaUI.Theme

    local ScreenGui = GetScreenGui()
    local Window = {}

    -- ── Outer frame (the window itself)
    local WinFrame = Instance.new("Frame")
    WinFrame.Name = "AquaWindow"
    WinFrame.Size = size
    WinFrame.Position = position
    WinFrame.BackgroundColor3 = T.WindowBG
    WinFrame.BorderSizePixel = 0
    WinFrame.ClipsDescendants = true
    Corner(WinFrame, T.CornerRadius)
    Stroke(WinFrame, T.GlassBorder, 1, 0.4)
    Shadow(WinFrame, 40, 0.4)
    WinFrame.Parent = ScreenGui

    -- Scale-in entrance animation
    WinFrame.Size = UDim2.new(0, 0, 0, 0)
    WinFrame.Position = UDim2.new(position.X.Scale, position.X.Offset + 280,
                                   position.Y.Scale, position.Y.Offset + 200)
    Tween(WinFrame, { Size = size, Position = position }, T.TweenInfoSlow)

    -- ── Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = T.SidebarBG
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = WinFrame

    -- Traffic lights
    local lights = {
        { name = "Close",    color = T.TrafficRed,    pos = 18 },
        { name = "Minimize", color = T.TrafficYellow, pos = 38 },
        { name = "Zoom",     color = T.TrafficGreen,  pos = 58 },
    }
    for _, l in ipairs(lights) do
        local btn = Instance.new("TextButton")
        btn.Name = l.name
        btn.Size = UDim2.new(0, 13, 0, 13)
        btn.Position = UDim2.new(0, l.pos, 0.5, -6)
        btn.BackgroundColor3 = l.color
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 3
        Corner(btn, UDim.new(1, 0))
        btn.Parent = TitleBar

        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.35 }, T.TweenInfoFast)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0 }, T.TweenInfoFast)
        end)

        if l.name == "Close" then
            btn.MouseButton1Click:Connect(function()
                Ripple(btn, 6, 6)
                Tween(WinFrame, { Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1 }, T.TweenInfoSlow)
                task.delay(0.45, function() WinFrame:Destroy() end)
            end)
        elseif l.name == "Minimize" then
            btn.MouseButton1Click:Connect(function()
                Ripple(btn, 6, 6)
                local visible = WinFrame.Size == size
                local targetSize = visible and UDim2.new(size.X.Scale, size.X.Offset, 0, 48) or size
                Tween(WinFrame, { Size = targetSize }, T.TweenInfo)
            end)
        end
    end

    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -160, 1, 0)
    TitleLabel.Position = UDim2.new(0, 80, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = T.TextPrimary
    TitleLabel.Font = T.FontSemiBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TitleBar

    if subtitle ~= "" then
        local Sub = Instance.new("TextLabel")
        Sub.Size = UDim2.new(1, -160, 0, 14)
        Sub.Position = UDim2.new(0, 80, 1, -14)
        Sub.BackgroundTransparency = 1
        Sub.Text = subtitle
        Sub.TextColor3 = T.TextSecondary
        Sub.Font = T.FontRegular
        Sub.TextSize = 11
        Sub.TextXAlignment = Enum.TextXAlignment.Center
        Sub.ZIndex = 3
        Sub.Parent = TitleBar

        TitleLabel.Position = UDim2.new(0, 80, 0, 5)
    end

    MakeDraggable(TitleBar, WinFrame)

    -- ── Separator line below titlebar
    local TitleSep = Instance.new("Frame")
    TitleSep.Size = UDim2.new(1, 0, 0, 1)
    TitleSep.Position = UDim2.new(0, 0, 0, 48)
    TitleSep.BackgroundColor3 = T.Separator
    TitleSep.BorderSizePixel = 0
    TitleSep.Parent = WinFrame

    -- ── Sidebar (tabs)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, -49)
    Sidebar.Position = UDim2.new(0, 0, 0, 49)
    Sidebar.BackgroundColor3 = T.SidebarBG
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.Parent = WinFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 4)
    SidebarLayout.Parent = Sidebar

    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingTop = UDim.new(0, 10)
    SidebarPad.PaddingLeft = UDim.new(0, 8)
    SidebarPad.PaddingRight = UDim.new(0, 8)
    SidebarPad.Parent = Sidebar

    -- Sidebar border
    local SidebarStroke = Instance.new("Frame")
    SidebarStroke.Size = UDim2.new(0, 1, 1, -49)
    SidebarStroke.Position = UDim2.new(0, 150, 0, 49)
    SidebarStroke.BackgroundColor3 = T.Separator
    SidebarStroke.BorderSizePixel = 0
    SidebarStroke.Parent = WinFrame

    -- ── Content area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -151, 1, -49)
    Content.Position = UDim2.new(0, 151, 0, 49)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = WinFrame

    -- ── Tab management
    local tabPages   = {}
    local tabButtons = {}
    local activeTab  = nil

    local function SwitchTab(tabName)
        if activeTab == tabName then return end
        activeTab = tabName

        for name, page in pairs(tabPages) do
            local isActive = name == tabName
            page.Visible = isActive
        end

        for name, btn in pairs(tabButtons) do
            local isActive = name == tabName
            Tween(btn, {
                BackgroundColor3 = isActive and T.Accent or Color3.new(0,0,0),
                BackgroundTransparency = isActive and 0 or 1,
            }, T.TweenInfoFast)
            local lbl = btn:FindFirstChildOfClass("TextLabel")
            if lbl then
                Tween(lbl, { TextColor3 = isActive and T.TextPrimary or T.TextSecondary }, T.TweenInfoFast)
            end
        end
    end

    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local name = tabConfig.Name or ("Tab " .. (#tabPages + 1))
        local icon = tabConfig.Icon or ""

        -- Sidebar button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. name
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = T.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.BorderSizePixel = 0
        TabBtn.LayoutOrder = #tabPages + 1
        Corner(TabBtn, T.CornerRadiusSm)
        TabBtn.Parent = Sidebar

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, icon ~= "" and -30 or -10, 1, 0)
        TabLabel.Position = UDim2.new(0, icon ~= "" and 32 or 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.TextColor3 = T.TextSecondary
        TabLabel.Font = T.FontSemiBold
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        if icon ~= "" then
            local IconLbl = Instance.new("TextLabel")
            IconLbl.Size = UDim2.new(0, 20, 1, 0)
            IconLbl.Position = UDim2.new(0, 8, 0, 0)
            IconLbl.BackgroundTransparency = 1
            IconLbl.Text = icon
            IconLbl.TextColor3 = T.TextSecondary
            IconLbl.Font = T.FontRegular
            IconLbl.TextSize = 14
            IconLbl.Parent = TabBtn
        end

        -- Page (scrollable)
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
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 14)
        PagePad.PaddingLeft = UDim.new(0, 14)
        PagePad.PaddingRight = UDim.new(0, 14)
        PagePad.PaddingBottom = UDim.new(0, 14)
        PagePad.Parent = Page

        tabPages[name]   = Page
        tabButtons[name] = TabBtn

        -- Hover
        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tween(TabBtn, { BackgroundTransparency = 0.85 }, T.TweenInfoFast)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tween(TabBtn, { BackgroundTransparency = 1 }, T.TweenInfoFast)
            end
        end)
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn, Mouse.X - TabBtn.AbsolutePosition.X, Mouse.Y - TabBtn.AbsolutePosition.Y)
            SwitchTab(name)
        end)

        -- Auto-activate first tab
        if not activeTab then SwitchTab(name) end

        -- Tab component builder
        local Tab = {}

        -- ── SECTION ──────────────────────────────
        function Tab:AddSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            local sName = sectionConfig.Name or "Section"
            local Section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section_" .. sName
            SectionFrame.Size = UDim2.new(1, 0, 0, 28)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.LayoutOrder = #Page:GetChildren()
            SectionFrame.Parent = Page

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 6)
            SectionLayout.Parent = SectionFrame

            -- Section header
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Size = UDim2.new(1, 0, 0, 22)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.LayoutOrder = 0
            SectionHeader.Parent = SectionFrame

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, 0, 1, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = string.upper(sName)
            SectionLabel.TextColor3 = T.TextTertiary
            SectionLabel.Font = T.FontSemiBold
            SectionLabel.TextSize = 10
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionHeader

            local elementCount = 0

            -- ── BUTTON ──────────────────────────────
            function Section:AddButton(btnConfig)
                btnConfig = btnConfig or {}
                local bLabel   = btnConfig.Name     or "Button"
                local bDesc    = btnConfig.Desc     or ""
                local callback = btnConfig.Callback or function() end

                elementCount += 1
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn_" .. bLabel
                Btn.Size = UDim2.new(1, 0, 0, bDesc ~= "" and 52 or 38)
                Btn.BackgroundColor3 = T.ElementBG
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.BorderSizePixel = 0
                Btn.LayoutOrder = elementCount
                Corner(Btn, T.CornerRadiusSm)
                Stroke(Btn, T.GlassBorder, 1, 0.6)
                Btn.Parent = SectionFrame

                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Size = UDim2.new(1, -46, 0, 18)
                BtnLabel.Position = UDim2.new(0, 14, 0, bDesc ~= "" and 9 or 0)
                BtnLabel.AnchorPoint = bDesc ~= "" and Vector2.new(0,0) or Vector2.new(0, 0.5)
                BtnLabel.Position = bDesc ~= "" and UDim2.new(0,14,0,10) or UDim2.new(0,14,0.5,0)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = bLabel
                BtnLabel.TextColor3 = T.TextPrimary
                BtnLabel.Font = T.FontSemiBold
                BtnLabel.TextSize = 13
                BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
                BtnLabel.Parent = Btn

                if bDesc ~= "" then
                    local DescLabel = Instance.new("TextLabel")
                    DescLabel.Size = UDim2.new(1, -46, 0, 14)
                    DescLabel.Position = UDim2.new(0, 14, 0, 28)
                    DescLabel.BackgroundTransparency = 1
                    DescLabel.Text = bDesc
                    DescLabel.TextColor3 = T.TextSecondary
                    DescLabel.Font = T.FontRegular
                    DescLabel.TextSize = 11
                    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                    DescLabel.Parent = Btn
                end

                -- Chevron icon
                local Chevron = Instance.new("TextLabel")
                Chevron.Size = UDim2.new(0, 24, 0, 24)
                Chevron.Position = UDim2.new(1, -36, 0.5, -12)
                Chevron.BackgroundTransparency = 1
                Chevron.Text = "›"
                Chevron.TextColor3 = T.TextTertiary
                Chevron.Font = T.FontBold
                Chevron.TextSize = 20
                Chevron.Parent = Btn

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.ElementHover }, T.TweenInfoFast)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.ElementBG }, T.TweenInfoFast)
                end)
                Btn.MouseButton1Down:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.ElementActive }, T.TweenInfoFast)
                end)
                Btn.MouseButton1Up:Connect(function()
                    Tween(Btn, { BackgroundColor3 = T.ElementHover }, T.TweenInfoFast)
                end)
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn, Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y)
                    task.spawn(callback)
                end)

                return Btn
            end

            -- ── TOGGLE ──────────────────────────────
            function Section:AddToggle(tConfig)
                tConfig = tConfig or {}
                local tLabel    = tConfig.Name     or "Toggle"
                local tDesc     = tConfig.Desc     or ""
                local default   = tConfig.Default  or false
                local callback  = tConfig.Callback or function() end

                elementCount += 1
                local state = default

                local Row = Instance.new("Frame")
                Row.Name = "Toggle_" .. tLabel
                Row.Size = UDim2.new(1, 0, 0, tDesc ~= "" and 52 or 38)
                Row.BackgroundColor3 = T.ElementBG
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount
                Corner(Row, T.CornerRadiusSm)
                Stroke(Row, T.GlassBorder, 1, 0.6)
                Row.Parent = SectionFrame

                local RowLabel = Instance.new("TextLabel")
                RowLabel.Size = UDim2.new(1, -70, 0, 18)
                RowLabel.Position = tDesc ~= "" and UDim2.new(0,14,0,10) or UDim2.new(0,14,0.5,0)
                RowLabel.AnchorPoint = tDesc ~= "" and Vector2.new(0,0) or Vector2.new(0,0.5)
                RowLabel.BackgroundTransparency = 1
                RowLabel.Text = tLabel
                RowLabel.TextColor3 = T.TextPrimary
                RowLabel.Font = T.FontSemiBold
                RowLabel.TextSize = 13
                RowLabel.TextXAlignment = Enum.TextXAlignment.Left
                RowLabel.Parent = Row

                if tDesc ~= "" then
                    local Desc = Instance.new("TextLabel")
                    Desc.Size = UDim2.new(1,-70,0,14)
                    Desc.Position = UDim2.new(0,14,0,28)
                    Desc.BackgroundTransparency = 1
                    Desc.Text = tDesc
                    Desc.TextColor3 = T.TextSecondary
                    Desc.Font = T.FontRegular
                    Desc.TextSize = 11
                    Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Desc.Parent = Row
                end

                -- Track container
                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(0, 42, 0, 24)
                Track.Position = UDim2.new(1, -54, 0.5, -12)
                Track.BackgroundColor3 = state and T.Accent or T.GlassBorder
                Track.BorderSizePixel = 0
                Corner(Track, UDim.new(1, 0))
                Track.Parent = Row

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 20, 0, 20)
                Knob.Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
                Knob.BackgroundColor3 = Color3.new(1,1,1)
                Knob.BorderSizePixel = 0
                Corner(Knob, UDim.new(1,0))
                Knob.Parent = Track

                -- Click area
                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1,0,1,0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.ZIndex = Row.ZIndex + 5
                ClickArea.Parent = Row

                ClickArea.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(Track, { BackgroundColor3 = state and T.Accent or T.GlassBorder }, T.TweenInfoFast)
                    Tween(Knob,  { Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10) }, T.TweenInfoFast)
                    task.spawn(callback, state)
                end)

                local ToggleAPI = {}
                function ToggleAPI:Set(val)
                    state = val
                    Tween(Track, { BackgroundColor3 = state and T.Accent or T.GlassBorder }, T.TweenInfoFast)
                    Tween(Knob,  { Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10) }, T.TweenInfoFast)
                end
                function ToggleAPI:Get() return state end
                return ToggleAPI
            end

            -- ── SLIDER ──────────────────────────────
            function Section:AddSlider(sConfig)
                sConfig = sConfig or {}
                local sLabel    = sConfig.Name     or "Slider"
                local sMin      = sConfig.Min      or 0
                local sMax      = sConfig.Max      or 100
                local sDefault  = sConfig.Default  or sMin
                local sSuffix   = sConfig.Suffix   or ""
                local callback  = sConfig.Callback or function() end

                elementCount += 1
                local value = math.clamp(sDefault, sMin, sMax)

                local Row = Instance.new("Frame")
                Row.Name = "Slider_" .. sLabel
                Row.Size = UDim2.new(1, 0, 0, 54)
                Row.BackgroundColor3 = T.ElementBG
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount
                Corner(Row, T.CornerRadiusSm)
                Stroke(Row, T.GlassBorder, 1, 0.6)
                Row.Parent = SectionFrame

                local SLabel = Instance.new("TextLabel")
                SLabel.Size = UDim2.new(0.6,0,0,18)
                SLabel.Position = UDim2.new(0,14,0,10)
                SLabel.BackgroundTransparency = 1
                SLabel.Text = sLabel
                SLabel.TextColor3 = T.TextPrimary
                SLabel.Font = T.FontSemiBold
                SLabel.TextSize = 13
                SLabel.TextXAlignment = Enum.TextXAlignment.Left
                SLabel.Parent = Row

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0.4,-14,0,18)
                ValLabel.Position = UDim2.new(0.6,0,0,10)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(value) .. sSuffix
                ValLabel.TextColor3 = T.TextAccent
                ValLabel.Font = T.FontSemiBold
                ValLabel.TextSize = 13
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = Row

                local TrackBG = Instance.new("Frame")
                TrackBG.Size = UDim2.new(1,-28,0,6)
                TrackBG.Position = UDim2.new(0,14,0,36)
                TrackBG.BackgroundColor3 = T.GlassBorder
                TrackBG.BorderSizePixel = 0
                Corner(TrackBG, UDim.new(1,0))
                TrackBG.Parent = Row

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((value - sMin)/(sMax - sMin), 0, 1, 0)
                Fill.BackgroundColor3 = T.Accent
                Fill.BorderSizePixel = 0
                Corner(Fill, UDim.new(1,0))
                Fill.Parent = TrackBG

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0,14,0,14)
                Knob.AnchorPoint = Vector2.new(0.5,0.5)
                Knob.Position = UDim2.new((value - sMin)/(sMax - sMin), 0, 0.5, 0)
                Knob.BackgroundColor3 = Color3.new(1,1,1)
                Knob.BorderSizePixel = 0
                Corner(Knob, UDim.new(1,0))
                Knob.ZIndex = TrackBG.ZIndex + 2
                Knob.Parent = TrackBG

                local draggingSlider = false

                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1,0,0,24)
                ClickArea.Position = UDim2.new(0,0,0,-9)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.ZIndex = TrackBG.ZIndex + 5
                ClickArea.Parent = TrackBG

                local function UpdateSlider(inputX)
                    local rel = math.clamp((inputX - TrackBG.AbsolutePosition.X) / TrackBG.AbsoluteSize.X, 0, 1)
                    value = math.floor(sMin + rel * (sMax - sMin) + 0.5)
                    local p = (value - sMin)/(sMax - sMin)
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
                    local p = (value - sMin)/(sMax - sMin)
                    Tween(Fill,  { Size = UDim2.new(p, 0, 1, 0) }, T.TweenInfoFast)
                    Tween(Knob, { Position = UDim2.new(p, 0, 0.5, 0) }, T.TweenInfoFast)
                    ValLabel.Text = tostring(value) .. sSuffix
                end
                function SliderAPI:Get() return value end
                return SliderAPI
            end

            -- ── TEXT INPUT ──────────────────────────
            function Section:AddTextInput(iConfig)
                iConfig = iConfig or {}
                local iLabel       = iConfig.Name        or "Input"
                local iPlaceholder = iConfig.Placeholder or "Type here..."
                local iDefault     = iConfig.Default     or ""
                local callback     = iConfig.Callback    or function() end

                elementCount += 1

                local Row = Instance.new("Frame")
                Row.Name = "Input_" .. iLabel
                Row.Size = UDim2.new(1, 0, 0, 54)
                Row.BackgroundColor3 = T.ElementBG
                Row.BorderSizePixel = 0
                Row.LayoutOrder = elementCount
                Corner(Row, T.CornerRadiusSm)
                Stroke(Row, T.GlassBorder, 1, 0.6)
                Row.Parent = SectionFrame

                local ILabel = Instance.new("TextLabel")
                ILabel.Size = UDim2.new(1,-14,0,18)
                ILabel.Position = UDim2.new(0,14,0,9)
                ILabel.BackgroundTransparency = 1
                ILabel.Text = iLabel
                ILabel.TextColor3 = T.TextSecondary
                ILabel.Font = T.FontSemiBold
                ILabel.TextSize = 11
                ILabel.TextXAlignment = Enum.TextXAlignment.Left
                ILabel.Parent = Row

                local InputBG = Instance.new("Frame")
                InputBG.Size = UDim2.new(1,-28,0,24)
                InputBG.Position = UDim2.new(0,14,0,27)
                InputBG.BackgroundColor3 = T.GlassBG
                InputBG.BorderSizePixel = 0
                Corner(InputBG, T.CornerRadiusXs)
                Stroke(InputBG, T.GlassBorder, 1, 0.5)
                InputBG.Parent = Row

                local TBox = Instance.new("TextBox")
                TBox.Size = UDim2.new(1,-16,1,0)
                TBox.Position = UDim2.new(0,8,0,0)
                TBox.BackgroundTransparency = 1
                TBox.Text = iDefault
                TBox.PlaceholderText = iPlaceholder
                TBox.PlaceholderColor3 = T.TextTertiary
                TBox.TextColor3 = T.TextPrimary
                TBox.Font = T.FontRegular
                TBox.TextSize = 12
                TBox.TextXAlignment = Enum.TextXAlignment.Left
                TBox.ClearTextOnFocus = false
                TBox.Parent = InputBG

                local FocusStroke = InputBG:FindFirstChildOfClass("UIStroke")
                TBox.Focused:Connect(function()
                    Tween(FocusStroke, { Color = T.Accent, Thickness = 2 }, T.TweenInfoFast)
                end)
                TBox.FocusLost:Connect(function(enter)
                    Tween(FocusStroke, { Color = T.GlassBorder, Thickness = 1 }, T.TweenInfoFast)
                    if enter then task.spawn(callback, TBox.Text) end
                end)

                local InputAPI = {}
                function InputAPI:Set(v) TBox.Text = v end
                function InputAPI:Get() return TBox.Text end
                return InputAPI
            end

            -- ── LABEL ──────────────────────────────
            function Section:AddLabel(lConfig)
                lConfig = lConfig or {}
                local text  = lConfig.Text  or "Label"
                local color = lConfig.Color or T.TextSecondary

                elementCount += 1
                local Lbl = Instance.new("TextLabel")
                Lbl.Name = "Label"
                Lbl.Size = UDim2.new(1, 0, 0, 24)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = text
                Lbl.TextColor3 = color
                Lbl.Font = T.FontRegular
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.LayoutOrder = elementCount
                Lbl.Parent = SectionFrame

                local LblAPI = {}
                function LblAPI:Set(t) Lbl.Text = t end
                return LblAPI
            end

            -- ── SEPARATOR ──────────────────────────
            function Section:AddSeparator()
                elementCount += 1
                local Sep = Instance.new("Frame")
                Sep.Name = "Separator"
                Sep.Size = UDim2.new(1, 0, 0, 1)
                Sep.BackgroundColor3 = T.Separator
                Sep.BorderSizePixel = 0
                Sep.LayoutOrder = elementCount
                Sep.Parent = SectionFrame
            end

            -- ── DROPDOWN ──────────────────────────
            function Section:AddDropdown(dConfig)
                dConfig = dConfig or {}
                local dLabel   = dConfig.Name     or "Dropdown"
                local options  = dConfig.Options  or {}
                local default  = dConfig.Default  or (options[1] or "Select...")
                local callback = dConfig.Callback or function() end

                elementCount += 1
                local selected = default
                local open = false

                local Container = Instance.new("Frame")
                Container.Name = "Dropdown_" .. dLabel
                Container.Size = UDim2.new(1, 0, 0, 38)
                Container.BackgroundTransparency = 1
                Container.LayoutOrder = elementCount
                Container.ClipsDescendants = false
                Container.ZIndex = 10
                Container.Parent = SectionFrame

                local Row = Instance.new("TextButton")
                Row.Size = UDim2.new(1, 0, 0, 38)
                Row.BackgroundColor3 = T.ElementBG
                Row.Text = ""
                Row.AutoButtonColor = false
                Row.BorderSizePixel = 0
                Row.ZIndex = 10
                Corner(Row, T.CornerRadiusSm)
                Stroke(Row, T.GlassBorder, 1, 0.6)
                Row.Parent = Container

                local DLabel = Instance.new("TextLabel")
                DLabel.Size = UDim2.new(1,-50,1,0)
                DLabel.Position = UDim2.new(0,14,0,0)
                DLabel.BackgroundTransparency = 1
                DLabel.Text = dLabel
                DLabel.TextColor3 = T.TextSecondary
                DLabel.Font = T.FontSemiBold
                DLabel.TextSize = 12
                DLabel.TextXAlignment = Enum.TextXAlignment.Left
                DLabel.ZIndex = 11
                DLabel.Parent = Row

                local SelLabel = Instance.new("TextLabel")
                SelLabel.Size = UDim2.new(1,-50,1,0)
                SelLabel.Position = UDim2.new(0,14,0,0)
                SelLabel.BackgroundTransparency = 1
                SelLabel.Text = selected
                SelLabel.TextColor3 = T.TextPrimary
                SelLabel.Font = T.FontSemiBold
                SelLabel.TextSize = 13
                SelLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelLabel.ZIndex = 11
                SelLabel.Parent = Row

                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.new(0,30,1,0)
                Arrow.Position = UDim2.new(1,-36,0,0)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "⌄"
                Arrow.TextColor3 = T.TextTertiary
                Arrow.Font = T.FontBold
                Arrow.TextSize = 14
                Arrow.ZIndex = 11
                Arrow.Parent = Row

                local DropList = Instance.new("Frame")
                DropList.Size = UDim2.new(1, 0, 0, 0)
                DropList.Position = UDim2.new(0, 0, 0, 42)
                DropList.BackgroundColor3 = T.GlassBG
                DropList.BorderSizePixel = 0
                DropList.ClipsDescendants = true
                DropList.ZIndex = 50
                Corner(DropList, T.CornerRadiusSm)
                Stroke(DropList, T.GlassBorder, 1, 0.4)
                DropList.Parent = Container

                local DListLayout = Instance.new("UIListLayout")
                DListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DListLayout.Parent = DropList

                for i, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1,0,0,32)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = ""
                    OptBtn.AutoButtonColor = false
                    OptBtn.LayoutOrder = i
                    OptBtn.ZIndex = 51
                    OptBtn.Parent = DropList

                    local OptLabel = Instance.new("TextLabel")
                    OptLabel.Size = UDim2.new(1,-24,1,0)
                    OptLabel.Position = UDim2.new(0,12,0,0)
                    OptLabel.BackgroundTransparency = 1
                    OptLabel.Text = opt
                    OptLabel.TextColor3 = T.TextPrimary
                    OptLabel.Font = T.FontRegular
                    OptLabel.TextSize = 13
                    OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptLabel.ZIndex = 52
                    OptLabel.Parent = OptBtn

                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, { BackgroundTransparency = 0.85 }, T.TweenInfoFast)
                        OptBtn.BackgroundColor3 = T.Accent
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, { BackgroundTransparency = 1 }, T.TweenInfoFast)
                    end)
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        SelLabel.Text = opt
                        open = false
                        Tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, T.TweenInfoFast)
                        Arrow.Text = "⌄"
                        task.spawn(callback, opt)
                    end)
                end

                Row.MouseButton1Click:Connect(function()
                    open = not open
                    local targetH = open and (math.min(#options, 5) * 32) or 0
                    Tween(DropList, { Size = UDim2.new(1, 0, 0, targetH) }, T.TweenInfo)
                    Arrow.Text = open and "⌃" or "⌄"
                end)

                local DAPI = {}
                function DAPI:Set(v) selected = v; SelLabel.Text = v end
                function DAPI:Get() return selected end
                return DAPI
            end

            return Section
        end

        return Tab
    end

    -- ── Logo / branding in sidebar footer
    local BrandLabel = Instance.new("TextLabel")
    BrandLabel.Size = UDim2.new(1, 0, 0, 24)
    BrandLabel.Position = UDim2.new(0, 0, 1, -28)
    BrandLabel.BackgroundTransparency = 1
    BrandLabel.Text = "AquaUI  β1.0"
    BrandLabel.TextColor3 = T.TextTertiary
    BrandLabel.Font = T.FontRegular
    BrandLabel.TextSize = 10
    BrandLabel.TextXAlignment = Enum.TextXAlignment.Center
    BrandLabel.Parent = Sidebar

    return Window
end

-- ═══════════════════════════════════════════════════════════════
--  NOTIFICATION
-- ═══════════════════════════════════════════════════════════════
function AquaUI:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notification"
    local desc     = config.Desc     or ""
    local duration = config.Duration or 4
    local type_    = config.Type     or "Info"  -- Info | Success | Warning | Danger
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
    Notif.Size = UDim2.new(0, 280, 0, 0)
    Notif.Position = UDim2.new(1, -294, 1, -20)
    Notif.AnchorPoint = Vector2.new(0, 1)
    Notif.BackgroundColor3 = T.GlassBG
    Notif.BorderSizePixel = 0
    Notif.AutomaticSize = Enum.AutomaticSize.Y
    Notif.ClipsDescendants = false
    Corner(Notif, T.CornerRadiusSm)
    Stroke(Notif, accent, 1, 0.6)
    Shadow(Notif, 20, 0.5)
    Notif.Parent = ScreenGui

    -- Accent bar
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 1, -16)
    Bar.Position = UDim2.new(0, 0, 0, 8)
    Bar.BackgroundColor3 = accent
    Bar.BorderSizePixel = 0
    Corner(Bar, UDim.new(1, 0))
    Bar.Parent = Notif

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1,-20,0,18)
    NTitle.Position = UDim2.new(0,14,0,10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = T.TextPrimary
    NTitle.Font = T.FontSemiBold
    NTitle.TextSize = 13
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notif

    if desc ~= "" then
        local NDesc = Instance.new("TextLabel")
        NDesc.Size = UDim2.new(1,-20,0,0)
        NDesc.Position = UDim2.new(0,14,0,30)
        NDesc.BackgroundTransparency = 1
        NDesc.Text = desc
        NDesc.TextColor3 = T.TextSecondary
        NDesc.Font = T.FontRegular
        NDesc.TextSize = 11
        NDesc.TextWrapped = true
        NDesc.AutomaticSize = Enum.AutomaticSize.Y
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.Parent = Notif
    end

    -- Progress bar
    local ProgBG = Instance.new("Frame")
    ProgBG.Size = UDim2.new(1,-20,0,2)
    ProgBG.Position = UDim2.new(0,14,1,-10)
    ProgBG.BackgroundColor3 = T.Separator
    ProgBG.BorderSizePixel = 0
    Corner(ProgBG, UDim.new(1,0))
    ProgBG.Parent = Notif

    local Prog = Instance.new("Frame")
    Prog.Size = UDim2.new(1,0,1,0)
    Prog.BackgroundColor3 = accent
    Prog.BorderSizePixel = 0
    Corner(Prog, UDim.new(1,0))
    Prog.Parent = ProgBG

    -- Slide in
    Notif.Position = UDim2.new(1, 10, 1, -20)
    Tween(Notif, { Position = UDim2.new(1, -294, 1, -20) }, T.TweenInfo)

    -- Progress drain
    Tween(Prog, { Size = UDim2.new(0, 0, 1, 0) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))

    -- Dismiss
    task.delay(duration, function()
        Tween(Notif, { Position = UDim2.new(1, 10, 1, -20), BackgroundTransparency = 1 }, T.TweenInfo)
        task.delay(0.3, function() Notif:Destroy() end)
    end)

    return Notif
end

return AquaUI
