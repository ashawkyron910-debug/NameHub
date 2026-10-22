-- NameHub · Premium Hub
print("[NameHub Premium] Boot", os.date("!%Y-%m-%dT%H:%M:%SZ"))

--[[
	NameHub Premium — paid tier hub
	Press Insert for menu · enhanced ESP + premium-only UI
]]

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
	ESPMaxDistance = 800,
	ESPBoxes = true,
	ESPFillBoxes = false,
	ESPNames = true,
	ESPDistance = true,
	ESPTracers = false,
	ESPHealthBar = true,
	ESPEnemyColor = Color3.fromRGB(255, 215, 0),
	ESPFillColor = Color3.fromRGB(255, 200, 50),
	ESPTracerColor = Color3.fromRGB(255, 215, 0),
	ESPNameColor = Color3.fromRGB(255, 248, 220),
	ESPWatermark = true,
}

local THEME = {
	Background = Color3.fromRGB(22, 22, 26),
	Topbar = Color3.fromRGB(28, 28, 34),
	Element = Color3.fromRGB(36, 36, 44),
	Accent = Color3.fromRGB(255, 215, 0),
	Text = Color3.fromRGB(250, 250, 252),
	SubText = Color3.fromRGB(180, 180, 190),
	Muted = Color3.fromRGB(130, 130, 140),
	Border = Color3.fromRGB(60, 55, 40),
	ToggleOff = Color3.fromRGB(55, 58, 64),
}

local KNOWN_GAMES = {
	[286090429] = "Arsenal",
	[6035872082] = "Rivals",
	[98839997] = "Dino Sim",
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function gameLabel()
	return KNOWN_GAMES[game.GameId] or KNOWN_GAMES[game.PlaceId] or game.Name
end

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubPremiumUnload) == "function" then
		g.NameHubPremiumUnload()
	end
end)

local scriptAlive = true
local menuOpen = true

local function notify(title, detail)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = detail or title,
			Duration = 8,
		})
	end)
end

notify("NameHub Premium", "Loaded · " .. gameLabel() .. " · Insert for menu")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NameHubPremiumUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2_000_000
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = true

local function resolveHudParent()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
	return playerGui
end

screenGui.Parent = resolveHudParent()

local watermark = Instance.new("TextLabel")
watermark.Name = "PremiumWatermark"
watermark.BackgroundTransparency = 1
watermark.Size = UDim2.new(0, 220, 0, 28)
watermark.Position = UDim2.new(1, -228, 0, 8)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 14
watermark.TextColor3 = THEME.Accent
watermark.TextXAlignment = Enum.TextXAlignment.Right
watermark.Text = "⭐ NameHub Premium"
watermark.Visible = CONFIG.ESPWatermark
watermark.Parent = screenGui

local espFolder = Instance.new("Folder")
espFolder.Name = "NameHubPremiumESP"
espFolder.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 360, 0, 420)
mainFrame.BackgroundColor3 = THEME.Background
mainFrame.BorderSizePixel = 0
mainFrame.Visible = menuOpen
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.Border
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 44)
topbar.BackgroundColor3 = THEME.Topbar
topbar.BorderSizePixel = 0
topbar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topbar

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = THEME.Topbar
topFix.BorderSizePixel = 0
topFix.Parent = topbar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -16, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = THEME.Accent
title.Text = "NameHub Premium · " .. gameLabel()
title.Parent = topbar

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, -20, 1, -56)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = mainFrame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function makeToggle(label, getValue, setValue)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -4, 0, 36)
	row.BackgroundColor3 = THEME.Element
	row.BorderSizePixel = 0
	row.Parent = scroll

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -70, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = THEME.Text
	lbl.Text = label
	lbl.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 46, 0, 24)
	btn.Position = UDim2.new(1, -54, 0.5, -12)
	btn.BackgroundColor3 = THEME.ToggleOff
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = row

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = btn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 20, 0, 20)
	knob.Position = UDim2.new(0, 2, 0.5, -10)
	knob.BackgroundColor3 = THEME.Text
	knob.BorderSizePixel = 0
	knob.Parent = btn

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local function paint()
		local on = getValue()
		btn.BackgroundColor3 = on and THEME.Accent or THEME.ToggleOff
		knob.Position = on and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
	end

	btn.MouseButton1Click:Connect(function()
		setValue(not getValue())
		paint()
	end)
	paint()
end

makeToggle("ESP boxes", function()
	return CONFIG.ESPBoxes
end, function(v)
	CONFIG.ESPBoxes = v
end)

makeToggle("ESP names", function()
	return CONFIG.ESPNames
end, function(v)
	CONFIG.ESPNames = v
end)

makeToggle("ESP distance", function()
	return CONFIG.ESPDistance
end, function(v)
	CONFIG.ESPDistance = v
end)

makeToggle("ESP tracers", function()
	return CONFIG.ESPTracers
end, function(v)
	CONFIG.ESPTracers = v
end)

makeToggle("Premium watermark", function()
	return CONFIG.ESPWatermark
end, function(v)
	CONFIG.ESPWatermark = v
	watermark.Visible = v
end)

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, -4, 0, 48)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.TextWrapped = true
hint.TextColor3 = THEME.SubText
hint.Text = "Premium builds get updates here first. Discord: " .. CONFIG.DiscordInviteUrl
hint.Parent = scroll

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.MenuKey then
		menuOpen = not menuOpen
		mainFrame.Visible = menuOpen
	end
end)

type EspEntry = {
	highlight: Highlight?,
	box: Frame?,
	name: TextLabel?,
	dist: TextLabel?,
	tracer: Frame?,
	health: Frame?,
}

local espCache: { [Model]: EspEntry } = {}

local function cleanupEsp(model: Model)
	local entry = espCache[model]
	if not entry then
		return
	end
	if entry.highlight then
		entry.highlight:Destroy()
	end
	if entry.box then
		entry.box:Destroy()
	end
	if entry.name then
		entry.name:Destroy()
	end
	if entry.dist then
		entry.dist:Destroy()
	end
	if entry.tracer then
		entry.tracer:Destroy()
	end
	if entry.health then
		entry.health:Destroy()
	end
	espCache[model] = nil
end

local function getRoot(model: Model): BasePart?
	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Head")
		or model.PrimaryPart
end

local function worldToScreen(point: Vector3): Vector2?
	local v, onScreen = camera:WorldToViewportPoint(point)
	if not onScreen or v.Z <= 0 then
		return nil
	end
	return Vector2.new(v.X, v.Y)
end

local function updateEsp()
	if not scriptAlive then
		return
	end
	camera = workspace.CurrentCamera
	local seen: { [Model]: boolean } = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player == localPlayer then
			continue
		end
		local char = player.Character
		if not char or not char:IsDescendantOf(workspace) then
			continue
		end
		local root = getRoot(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then
			continue
		end
		local dist = (root.Position - camera.CFrame.Position).Magnitude
		if dist > CONFIG.ESPMaxDistance then
			continue
		end
		seen[char] = true
		local entry = espCache[char]
		if not entry then
			entry = {}
			espCache[char] = entry
		end

		local head = char:FindFirstChild("Head") or root
		local foot = root.Position - Vector3.new(0, 3, 0)
		local top = head.Position + Vector3.new(0, 0.8, 0)
		local sTop = worldToScreen(top)
		local sFoot = worldToScreen(foot)
		if not sTop or not sFoot then
			continue
		end
		local height = math.abs(sFoot.Y - sTop.Y)
		local width = height * 0.55

		if CONFIG.ESPBoxes then
			if not entry.box then
				local box = Instance.new("Frame")
				box.BackgroundTransparency = 1
				box.BorderSizePixel = 0
				box.Parent = espFolder
				local stroke = Instance.new("UIStroke")
				stroke.Color = CONFIG.ESPEnemyColor
				stroke.Thickness = 1.5
				stroke.Parent = box
				entry.box = box
			end
			entry.box.Size = UDim2.fromOffset(width, height)
			entry.box.Position = UDim2.fromOffset(sTop.X - width / 2, sTop.Y)
			entry.box.Visible = true
		elseif entry.box then
			entry.box.Visible = false
		end

		if CONFIG.ESPNames then
			if not entry.name then
				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 13
				lbl.TextColor3 = CONFIG.ESPNameColor
				lbl.Parent = espFolder
				entry.name = lbl
			end
			entry.name.Text = player.DisplayName
			entry.name.Size = UDim2.fromOffset(200, 16)
			entry.name.Position = UDim2.fromOffset(sTop.X - 100, sTop.Y - 18)
			entry.name.Visible = true
		elseif entry.name then
			entry.name.Visible = false
		end

		if CONFIG.ESPDistance then
			if not entry.dist then
				local lbl = Instance.new("TextLabel")
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = THEME.SubText
				lbl.Parent = espFolder
				entry.dist = lbl
			end
			entry.dist.Text = string.format("%dm", math.floor(dist))
			entry.dist.Size = UDim2.fromOffset(80, 14)
			entry.dist.Position = UDim2.fromOffset(sTop.X - 40, sFoot.Y + 2)
			entry.dist.Visible = true
		elseif entry.dist then
			entry.dist.Visible = false
		end
	end

	for model, _ in pairs(espCache) do
		if not seen[model] then
			cleanupEsp(model)
		end
	end
end

RunService:BindToRenderStep("NameHubPremiumESP", Enum.RenderPriority.Camera.Value + 1, updateEsp)

local function unload()
	scriptAlive = false
	pcall(function()
		RunService:UnbindFromRenderStep("NameHubPremiumESP")
	end)
	for model in pairs(espCache) do
		cleanupEsp(model)
	end
	if screenGui then
		screenGui:Destroy()
	end
end

getgenv().NameHubPremiumUnload = unload

Players.PlayerRemoving:Connect(function(player)
	local char = player.Character
	if char then
		cleanupEsp(char)
	end
end)

print("[NameHub Premium] Ready · PlaceId", game.PlaceId, "GameId", game.GameId)
