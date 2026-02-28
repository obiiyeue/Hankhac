--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           Switch Hub ( Find Fruit ) - Script                 ║
    ║           Made for Blox Fruits                               ║
    ╚══════════════════════════════════════════════════════════════╝

    === CÁCH DÙNG BÊN NGOÀI ===
    repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
    getgenv().Setting = {
        ["Webhook"] = {
            ["url"] = "", -- Dán link Webhook Discord của bạn vào đây
        },
        ["Auto Random Fruit"] = true,
        ["Auto Store Fruit"] = true,
        ["Webhook Store Fruit"] = {
            ["Enabled"] = true,
            ["Rarity"] = {
                ["Mythical"] = true,
                ["Legendary"] = true,
                ["Rare"] = false,
                ["Uncommon"] = false,
                ["Common"] = false,
            },
        },
    }
    loadstring(game:HttpGet("URL_SCRIPT_CỦA_BẠN"))()
]]

-- ================================================================
-- SERVICES & VARIABLES
-- ================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- Đọc Setting từ bên ngoài (nếu có)
getgenv().Setting = getgenv().Setting or {}
local Setting = getgenv().Setting

Setting.Webhook = Setting.Webhook or { url = "" }
Setting["Auto Store Fruit"] = Setting["Auto Store Fruit"] ~= nil and Setting["Auto Store Fruit"] or true
Setting["Webhook Store Fruit"] = Setting["Webhook Store Fruit"] or {
    Enabled = true,
    Rarity = {
        Mythical = true,
        Legendary = true,
        Rare = false,
        Uncommon = false,
        Common = false,
    }
}

-- ================================================================
-- FRUIT RARITY TABLE (Updated - Current Blox Fruits)
-- ================================================================
local FruitRarity = {
    -- ★ Common
    ["Rocket Fruit"]        = "Common",
    ["Spin Fruit"]          = "Common",
    ["Blade Fruit"]         = "Common",
    ["Spring Fruit"]        = "Common",
    ["Bomb Fruit"]          = "Common",
    ["Smoke Fruit"]         = "Common",
    ["Spike Fruit"]         = "Common",
    -- ★★ Uncommon
    ["Flame Fruit"]         = "Uncommon",
    ["Ice Fruit"]           = "Uncommon",
    ["Sand Fruit"]          = "Uncommon",
    ["Dark Fruit"]          = "Uncommon",
    ["Eagle Fruit"]         = "Uncommon",
    ["Diamond Fruit"]       = "Uncommon",
    -- ★★★ Rare
    ["Light Fruit"]         = "Rare",
    ["Rubber Fruit"]        = "Rare",
    ["Ghost Fruit"]         = "Rare",
    ["Magma Fruit"]         = "Rare",
    -- ★★★★ Legendary
    ["Quake Fruit"]         = "Legendary",
    ["Buddha Fruit"]        = "Legendary",
    ["Love Fruit"]          = "Legendary",
    ["Creation Fruit"]      = "Legendary",
    ["Spider Fruit"]        = "Legendary",
    ["Sound Fruit"]         = "Legendary",
    ["Phoenix Fruit"]       = "Legendary",
    ["Portal Fruit"]        = "Legendary",
    ["Lightning Fruit"]     = "Legendary",
    ["Pain Fruit"]          = "Legendary",
    ["Blizzard Fruit"]      = "Legendary",
    -- ★★★★★ Mythical
    ["Gravity Fruit"]       = "Mythical",
    ["Mammoth Fruit"]       = "Mythical",
    ["T-Rex Fruit"]         = "Mythical",
    ["Dough Fruit"]         = "Mythical",
    ["Shadow Fruit"]        = "Mythical",
    ["Venom Fruit"]         = "Mythical",
    ["Gas Fruit"]           = "Mythical",
    ["Spirit Fruit"]        = "Mythical",
    ["Tiger Fruit"]         = "Mythical",
    ["Yeti Fruit"]          = "Mythical",
    ["Kitsune Fruit"]       = "Mythical",
    ["Control Fruit"]            = "Mythical",
    ["Dragon Fruit (West)"]      = "Mythical",  -- Dragon West
    ["Dragon Fruit (East)"]      = "Mythical",  -- Dragon East
    -- Alias phòng trường hợp game dùng tên khác
    ["Dragon Fruit"]             = "Mythical",  -- fallback chung
}

-- Fruit đã lưu trữ trong session này (tránh nhặt lại)
local StoredFruitsThisSession = {}

-- ================================================================
-- STORE FRUIT LIST (Updated - Current Blox Fruits)
-- ================================================================
local FruitStoreList = {
    -- Common
    {"Rocket Fruit",        "Rocket-Rocket"},
    {"Spin Fruit",          "Spin-Spin"},
    {"Blade Fruit",         "Blade-Blade"},
    {"Spring Fruit",        "Spring-Spring"},
    {"Bomb Fruit",          "Bomb-Bomb"},
    {"Smoke Fruit",         "Smoke-Smoke"},
    {"Spike Fruit",         "Spike-Spike"},
    -- Uncommon
    {"Flame Fruit",         "Flame-Flame"},
    {"Ice Fruit",           "Ice-Ice"},
    {"Sand Fruit",          "Sand-Sand"},
    {"Dark Fruit",          "Dark-Dark"},
    {"Eagle Fruit",         "Eagle-Eagle"},
    {"Diamond Fruit",       "Diamond-Diamond"},
    -- Rare
    {"Light Fruit",         "Light-Light"},
    {"Rubber Fruit",        "Rubber-Rubber"},
    {"Ghost Fruit",         "Ghost-Ghost"},
    {"Magma Fruit",         "Magma-Magma"},
    -- Legendary
    {"Quake Fruit",         "Quake-Quake"},
    {"Buddha Fruit",        "Buddha-Buddha"},
    {"Love Fruit",          "Love-Love"},
    {"Creation Fruit",      "Creation-Creation"},
    {"Spider Fruit",        "Spider-Spider"},
    {"Sound Fruit",         "Sound-Sound"},
    {"Phoenix Fruit",       "Phoenix-Phoenix"},
    {"Portal Fruit",        "Portal-Portal"},
    {"Lightning Fruit",     "Lightning-Lightning"},
    {"Pain Fruit",          "Pain-Pain"},
    {"Blizzard Fruit",      "Blizzard-Blizzard"},
    -- Mythical
    {"Gravity Fruit",       "Gravity-Gravity"},
    {"Mammoth Fruit",       "Mammoth-Mammoth"},
    {"T-Rex Fruit",         "T-Rex-T-Rex"},
    {"Dough Fruit",         "Dough-Dough"},
    {"Shadow Fruit",        "Shadow-Shadow"},
    {"Venom Fruit",         "Venom-Venom"},
    {"Gas Fruit",           "Gas-Gas"},
    {"Spirit Fruit",        "Spirit-Spirit"},
    {"Tiger Fruit",         "Tiger-Tiger"},
    {"Yeti Fruit",          "Yeti-Yeti"},
    {"Kitsune Fruit",       "Kitsune-Kitsune"},
    {"Control Fruit",            "Control-Control"},
    -- Dragon West & East tách rõ ràng
    {"Dragon Fruit (West)",      "Dragon-Dragon"},        -- Dragon West
    {"Dragon Fruit (East)",      "DragonEast-DragonEast"}, -- Dragon East (key riêng)
    {"Dragon Fruit",             "Dragon-Dragon"},        -- fallback nếu game không ghi rõ
}

-- ================================================================
-- WEBHOOK
-- ================================================================
local function SendWebhook(fruitName, rarity)
    if not Setting["Webhook Store Fruit"].Enabled then return end
    if not Setting.Webhook.url or Setting.Webhook.url == "" then return end

    local rarityConfig = Setting["Webhook Store Fruit"].Rarity
    if not rarityConfig[rarity] then return end

    local rarityColors = {
        Mythical   = 0xFF0000,
        Legendary  = 0xFFA500,
        Rare       = 0x9B59B6,
        Uncommon   = 0x00AAFF,
        Common     = 0x95A5A6,
    }

    local embedColor = rarityColors[rarity] or 0xFFFFFF
    local char = LocalPlayer.Character
    local pos = char and char.HumanoidRootPart and char.HumanoidRootPart.Position or Vector3.new(0,0,0)

    local payload = HttpService:JSONEncode({
        username = "Switch Hub • Find Fruit",
        avatar_url = "https://tr.rbxcdn.com/16060333448/420/420/Image/Webp/noFilter",
        embeds = {
            {
                title = "🍎 Đã lưu trữ Trái!",
                description = string.format("**Trái:** `%s`\n**Rarity:** `%s`\n**Server:** `%s`\n**PlaceId:** `%s`\n**Player:** `%s`",
                    fruitName, rarity, tostring(JobId), tostring(PlaceId), tostring(LocalPlayer.Name)),
                color = embedColor,
                thumbnail = { url = "https://tr.rbxcdn.com/16060333448/420/420/Image/Webp/noFilter" },
                footer = { text = "Switch Hub ( Find Fruit ) • BloxFruits" },
            }
        }
    })

    pcall(function()
        game:HttpPost(Setting.Webhook.url, payload, false, "application/json")
    end)
end

-- ================================================================
-- STORE FRUIT FUNCTION
-- ================================================================
local function StoreFruitFromBackpack()
    local bp = LocalPlayer:WaitForChild("Backpack")
    local char = LocalPlayer.Character
    for _, entry in ipairs(FruitStoreList) do
        local fruitName = entry[1]
        local fruitKey  = entry[2]
        local fruitObj  = bp:FindFirstChild(fruitName) or (char and char:FindFirstChild(fruitName))
        if fruitObj then
            if not StoredFruitsThisSession[fruitName] then
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitKey, fruitObj)
                end)
                local rarity = FruitRarity[fruitName] or "Common"
                StoredFruitsThisSession[fruitName] = true
                task.wait(0.5)
                SendWebhook(fruitName, rarity)
            end
        end
    end
end

-- ================================================================
-- FIND FRUIT IN SERVER
-- ================================================================
local function FindFruitsInServer()
    local fruits = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
            table.insert(fruits, obj)
        end
    end
    -- Cũng tìm trong workspace folders
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
            local already = false
            for _, f in ipairs(fruits) do if f == obj then already = true break end end
            if not already then table.insert(fruits, obj) end
        end
    end
    return fruits
end

local function GetFruitDistance(fruitObj)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return 999999 end
    if not fruitObj:FindFirstChild("Handle") then return 999999 end
    return (fruitObj.Handle.CFrame.Position - char.HumanoidRootPart.Position).Magnitude
end

-- ================================================================
-- TWEEN TELEPORT (speed 350 = TweenTime)
-- ================================================================
local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (targetCFrame.Position - hrp.Position).Magnitude
    local tweenTime = dist / 350  -- tốc độ 350 studs/giây

    local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ================================================================
-- SERVER HOP SYSTEM (Smart - 80% fruit server, anti-duplicate, 5s timeout)
-- ================================================================

-- Danh sách server đã hop vào (tránh trùng)
local VisitedServers = {}
VisitedServers[JobId] = true  -- đánh dấu server hiện tại

local function GetServers()
    local servers = {}
    local ok, req = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if not ok then return servers end
    local ok2, data = pcall(function() return HttpService:JSONDecode(req) end)
    if not ok2 or not data or not data.data then return servers end
    for _, server in pairs(data.data) do
        -- Lọc: còn chỗ, chưa từng vào, không phải server hiện tại
        if server.playing < server.maxPlayers
        and not VisitedServers[server.id] then
            table.insert(servers, server)
        end
    end
    return servers
end

-- Smart pick: 80% ưu tiên server đông (fruit spawn nhiều hơn)
local function SmartPickServer(servers)
    if #servers == 0 then return nil end
    table.sort(servers, function(a, b)
        return (a.playing or 0) > (b.playing or 0)
    end)
    local roll = math.random(1, 100)
    local topCount = math.max(1, math.floor(#servers * 0.3))
    if roll <= 80 then
        return servers[math.random(1, topCount)]
    else
        return servers[math.random(1, #servers)]
    end
end

local function HopToServer()
    HopStatusLabel.Text = "🌐 Hopping..."
    local servers = GetServers()

    -- Nếu hết server chưa thăm -> reset danh sách (giữ lại server hiện tại)
    if #servers == 0 then
        VisitedServers = {}
        VisitedServers[JobId] = true
        servers = GetServers()
    end

    local picked = SmartPickServer(servers)
    if picked then
        VisitedServers[picked.id] = true  -- đánh dấu đã vào
        HopStatusLabel.Text = "✈️ Hopping... (" .. (picked.playing or 0) .. " players)"

        -- Countdown 5 giây trước khi hop
        for i = 5, 1, -1 do
            HopStatusLabel.Text = "⏳ Chuyển server sau " .. i .. "s... (" .. (picked.playing or 0) .. " players)"
            task.wait(1)
        end

        TeleportService:TeleportToPlaceInstance(PlaceId, picked.id, LocalPlayer)
    else
        HopStatusLabel.Text = "⚠️Not server → Rejoin..."
        task.wait(2)
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end

-- ================================================================
-- CHECK IF FRUIT ALREADY STORED (so sánh với fruit đã có)
-- ================================================================
local function IsFruitAlreadyStored(fruitName)
    -- Kiểm tra trong Data.Fruits nếu có
    local ok, stored = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits", false)
    end)
    if ok and stored then
        for _, f in pairs(stored) do
            if f.Name == fruitName then return true end
        end
    end
    return StoredFruitsThisSession[fruitName] == true
end

-- ================================================================
-- GUI SETUP
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SwitchHubFindFruit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- === Background overlay (tối mờ toàn màn hình) ===
local BgOverlay = Instance.new("Frame")
BgOverlay.Name = "BgOverlay"
BgOverlay.Size = UDim2.new(1, 0, 1, 0)
BgOverlay.Position = UDim2.new(0, 0, 0, 0)
BgOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BgOverlay.BackgroundTransparency = 0.35  -- nền tối 65%
BgOverlay.BorderSizePixel = 0
BgOverlay.ZIndex = 2
BgOverlay.Parent = ScreenGui

-- === Background Image (ID: 16060333448) ===
local BgImage = Instance.new("ImageLabel")
BgImage.Name = "BgImage"
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.Position = UDim2.new(0, 0, 0, 0)
BgImage.BackgroundTransparency = 1
BgImage.BorderSizePixel = 0
BgImage.Image = "rbxassetid://16060333448"
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ImageTransparency = 0.55  -- ảnh mờ hơn
BgImage.ZIndex = 1
BgImage.Parent = ScreenGui

-- === Main Frame (không viền, nền trong suốt hoàn toàn) ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 270)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -135)
MainFrame.BackgroundTransparency = 1  -- không có nền khung
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

-- KHÔNG tạo UICorner, KHÔNG tạo UIStroke → xóa hoàn toàn khung viền xanh

-- === Title (to hơn, không có khung) ===
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 70)
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Switch Hub ( Find Fruit )"
TitleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleLabel.TextSize = 34  -- to hơn
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 6
TitleLabel.Parent = MainFrame

-- Bóng chữ
local TitleShadow = Instance.new("TextLabel")
TitleShadow.Size = TitleLabel.Size
TitleShadow.Position = UDim2.new(0, 3, 0, 8)
TitleShadow.BackgroundTransparency = 1
TitleShadow.Text = TitleLabel.Text
TitleShadow.TextColor3 = Color3.fromRGB(20, 60, 140)
TitleShadow.TextSize = 34
TitleShadow.Font = Enum.Font.GothamBold
TitleShadow.TextXAlignment = Enum.TextXAlignment.Center
TitleShadow.ZIndex = 5
TitleShadow.Parent = MainFrame

-- === Divider mỏng dưới title ===
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.7, 0, 0, 1)
Divider.Position = UDim2.new(0.15, 0, 0, 76)
Divider.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
Divider.BackgroundTransparency = 0.4
Divider.BorderSizePixel = 0
Divider.ZIndex = 6
Divider.Parent = MainFrame

-- === Status / Fruit Label ===
local FruitInfoLabel = Instance.new("TextLabel")
FruitInfoLabel.Name = "FruitInfoLabel"
FruitInfoLabel.Size = UDim2.new(1, -20, 0, 25)
FruitInfoLabel.Position = UDim2.new(0, 10, 0, 82)
FruitInfoLabel.BackgroundTransparency = 1
FruitInfoLabel.Text = "🔍 Đang tìm kiếm trái..."
FruitInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FruitInfoLabel.TextSize = 14
FruitInfoLabel.Font = Enum.Font.Gotham
FruitInfoLabel.TextXAlignment = Enum.TextXAlignment.Center
FruitInfoLabel.ZIndex = 6
FruitInfoLabel.Parent = MainFrame

-- === Fruit List Display ===
local FruitListLabel = Instance.new("TextLabel")
FruitListLabel.Name = "FruitListLabel"
FruitListLabel.Size = UDim2.new(1, -20, 0, 100)
FruitListLabel.Position = UDim2.new(0, 10, 0, 110)
FruitListLabel.BackgroundTransparency = 1
FruitListLabel.Text = ""
FruitListLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FruitListLabel.TextSize = 13
FruitListLabel.Font = Enum.Font.Gotham
FruitListLabel.TextXAlignment = Enum.TextXAlignment.Center
FruitListLabel.TextYAlignment = Enum.TextYAlignment.Top
FruitListLabel.ZIndex = 6
FruitListLabel.TextWrapped = true
FruitListLabel.Parent = MainFrame

-- === Server Hop Status ===
local HopStatusLabel = Instance.new("TextLabel")
HopStatusLabel.Name = "HopStatus"
HopStatusLabel.Size = UDim2.new(1, -20, 0, 22)
HopStatusLabel.Position = UDim2.new(0, 10, 0, 215)
HopStatusLabel.BackgroundTransparency = 1
HopStatusLabel.Text = "🌐 Server: Đang chạy..."
HopStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
HopStatusLabel.TextSize = 13
HopStatusLabel.Font = Enum.Font.Gotham
HopStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
HopStatusLabel.ZIndex = 6
HopStatusLabel.Parent = MainFrame

-- === Minimize Button (thay thế nút BẮT ĐẦU) ===
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 8)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 255)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "Off"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.ZIndex = 7
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Mini bar hiện khi thu nhỏ
local MiniBar = Instance.new("Frame")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 220, 0, 34)
MiniBar.Position = UDim2.new(0.5, -110, 0, 6)
MiniBar.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
MiniBar.BackgroundTransparency = 0.1
MiniBar.BorderSizePixel = 0
MiniBar.Visible = false
MiniBar.ZIndex = 10
MiniBar.Parent = ScreenGui

local MiniBarCorner = Instance.new("UICorner")
MiniBarCorner.CornerRadius = UDim.new(0, 10)
MiniBarCorner.Parent = MiniBar

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(60, 160, 255)
MiniStroke.Thickness = 1.5
MiniStroke.Parent = MiniBar

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Size = UDim2.new(1, -40, 1, 0)
MiniLabel.Position = UDim2.new(0, 8, 0, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "🍎 Switch Hub (Find Fruit) • Đang chạy..."
MiniLabel.TextColor3 = Color3.fromRGB(100, 190, 255)
MiniLabel.TextSize = 11
MiniLabel.Font = Enum.Font.GothamBold
MiniLabel.TextXAlignment = Enum.TextXAlignment.Left
MiniLabel.ZIndex = 11
MiniLabel.Parent = MiniBar

local ExpandBtn = Instance.new("TextButton")
ExpandBtn.Size = UDim2.new(0, 30, 0, 24)
ExpandBtn.Position = UDim2.new(1, -34, 0.5, -12)
ExpandBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 255)
ExpandBtn.BorderSizePixel = 0
ExpandBtn.Text = "⬆"
ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExpandBtn.TextSize = 12
ExpandBtn.Font = Enum.Font.GothamBold
ExpandBtn.ZIndex = 12
ExpandBtn.Parent = MiniBar

local ExpCorner = Instance.new("UICorner")
ExpCorner.CornerRadius = UDim.new(0, 6)
ExpCorner.Parent = ExpandBtn

-- Minimize / Expand logic
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    MainFrame.Visible = false
    MiniBar.Visible = true
end)
ExpandBtn.MouseButton1Click:Connect(function()
    isMinimized = false
    MiniBar.Visible = false
    MainFrame.Visible = true
end)

-- Drag support
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ================================================================
-- MAIN AUTO FIND FRUIT LOGIC (Auto-start, không cần bật tắt)
-- ================================================================
getgenv().FindFruitEnabled = true  -- Bật ngay khi load

-- Update fruit list display
local function UpdateFruitDisplay()
    local fruits = FindFruitsInServer()
    if #fruits == 0 then
        FruitListLabel.Text = "❌ There are no fruits in the server."
        FruitInfoLabel.Text = "🔍No Fruit Hopping... "
        return fruits
    end
    local text = ""
    for i, fruit in ipairs(fruits) do
        if i > 5 then break end
        local dist = math.floor(GetFruitDistance(fruit))
        local rarity = FruitRarity[fruit.Name] or "Common"
        local rarityIcon = ({Common="⚪",Uncommon="🟢",Rare="🔵",Legendary="🟠",Mythical="🔴"})[rarity] or "⚪"
        text = text .. string.format("%s %s | %s | 📍%d studs\n", rarityIcon, fruit.Name, rarity, dist)
    end
    FruitListLabel.Text = text
    FruitInfoLabel.Text = string.format("🔍 Tìm thấy %d trái trong server", #fruits)
    return fruits
end

-- Main loop (chạy thẳng, không cần bấm nút)
local function MainFindFruitLoop()
    while true do
        pcall(function()
            local fruits = UpdateFruitDisplay()

            if #fruits == 0 then
                HopStatusLabel.Text = "🌐No Fruit →Hopping..."
                FruitInfoLabel.Text = "⚡ Hopping Fruit Sever..."
                task.wait(1)
                HopToServer()
                return
            end

            -- Tìm fruit chưa lưu
            local targetFruit = nil
            for _, fruit in ipairs(fruits) do
                if not StoredFruitsThisSession[fruit.Name] then
                    targetFruit = fruit
                    break
                end
            end

            if not targetFruit then
                HopStatusLabel.Text = "✅ Storage → Hoppimg server..."
                task.wait(1)
                HopToServer()
                return
            end

            -- Kiểm tra đã có trong kho
            if IsFruitAlreadyStored(targetFruit.Name) then
                StoredFruitsThisSession[targetFruit.Name] = true
                FruitInfoLabel.Text = "📦 Đã có " .. targetFruit.Name .. " → bỏ qua"
                task.wait(0.5)
                return
            end

            -- Bay Tween đến fruit
            if targetFruit and targetFruit:FindFirstChild("Handle") then
                FruitInfoLabel.Text = "✈️ Tween Fruit: " .. targetFruit.Name
                HopStatusLabel.Text = "🌐 Fruit..."
                TweenTo(targetFruit.Handle.CFrame)
                task.wait(0.4)
            end

            -- Snap đến chính xác
            if targetFruit and targetFruit.Parent and targetFruit:FindFirstChild("Handle") then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = targetFruit.Handle.CFrame
                end
                task.wait(0.6)
            end

            -- Lưu trữ
            FruitInfoLabel.Text = "💾 Fruit Storage..."
            StoreFruitFromBackpack()
            task.wait(0.4)

            UpdateFruitDisplay()
            HopStatusLabel.Text = "✅Storage! Tiếp tục..."
            task.wait(1)
        end)
        task.wait(0.1)
    end
end

-- Auto Store loop song song
if Setting["Auto Store Fruit"] then
    task.spawn(function()
        while task.wait(0.3) do
            pcall(StoreFruitFromBackpack)
        end
    end)
end

-- Cập nhật display liên tục
task.spawn(function()
    while task.wait(2) do
        pcall(UpdateFruitDisplay)
        -- Cập nhật mini bar
        if isMinimized then
            local fruits = FindFruitsInServer()
            MiniLabel.Text = string.format("🍎 Switch Hub • %d trái trong server", #fruits)
        end
    end
end)

-- ================================================================
-- KHỞI ĐỘNG NGAY KHI LOAD (không cần bấm nút)
-- ================================================================
FruitInfoLabel.Text = "✅ Đang chạy tự động..."
HopStatusLabel.Text = "🌐 Server: Đang tìm trái..."
task.spawn(MainFindFruitLoop)

-- ================================================================
-- NOTIFICATION
-- ================================================================
print([[
╔══════════════════════════════════════════════════╗
║   Switch Hub ( Find Fruit ) - Đã tải & chạy!    ║
║   Script tự động chạy ngay, không cần bật tay   ║
╚══════════════════════════════════════════════════╝
]])
