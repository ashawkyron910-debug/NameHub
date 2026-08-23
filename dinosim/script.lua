-- NameHub · Dinosaur Simulator build 2026-08-23T17:46:27.343Z
print("[NameHub] Boot dinosim 2026-08-23T17:46:27.343Z")
--[[
	NameHub · Dinosaur Simulator (Beta)
	Diamond farming only
]]

local DS_GAME_ID = 98839997
local DS_PLACE_IDS= {
	[228181322] = true,
}

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	DiamondFarmEnabled = false,
	DiamondFarmInterval = 0.85,
	DiamondSearchRadius = 12000,
	AutoEatEnabled = true,
	AutoDrinkEnabled = true,
	AntiAfkEnabled = true,
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
	ThemeName = "Midnight",
}

local THEME = {
	Background = Color3.fromRGB(25, 27, 29),
	Topbar = Color3.fromRGB(32, 34, 37),
	Element = Color3.fromRGB(35, 37, 40),
	Accent = Color3.fromRGB(16, 185, 129),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(160, 160, 165),
	Stroke = Color3.fromRGB(55, 55, 60),
	Success = Color3.fromRGB(60, 180, 100),
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

print("[NameHub DS] Booting… PlaceId", game.PlaceId, "GameId", game.GameId)

local function isSupportedGame()
	if game.GameId == DS_GAME_ID then
		return true
	end
	return DS_PLACE_IDS[game.PlaceId] == true
end

if not isSupportedGame() then
	warn(
		string.format(
			"[NameHub DS] Expected Dinosaur Simulator (GameId %s) — got PlaceId %s GameId %s (%s). Menu will still try to load.",
			tostring(DS_GAME_ID),
			tostring(game.PlaceId),
			tostring(game.GameId),
			game.Name
		)
	)
end

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

pcall(function()
	local g = getgenv()
	if typeof(g.NameHubDSUnload) == "function" then
		g.NameHubDSUnload()
	end
end)

local scriptAlive = true
local menuOpen = false
local farmSessionDiamonds = 0
local farmSessionStarts = 0
local lastDiamondBalance= nil
local farmLoopRunning = false

local screenGui
local menuFrame
local toggleButton
local statusLabel
local statsLabel

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5,
		})
	end)
	if screenGui and screenGui.Parent then
		pcall(function()
			local card = Instance.new("TextLabel")
			card.BackgroundColor3 = THEME.Topbar
			card.BorderSizePixel = 0
			card.Size = UDim2.fromOffset(260, 42)
			card.Position = UDim2.new(1, -276, 0, 12)
			card.Font = Enum.Font.GothamMedium
			card.TextSize = 13
			card.TextColor3 = THEME.Text
			card.Text = title .. " — " .. text
			card.ZIndex = 500
			card.Parent = screenGui
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = card
			task.delay(3, function()
				pcall(function()
					card:Destroy()
				end)
			end)
		end)
	end
end

local function wipeNameHubUi()
	for _, parent in { playerGui, game:GetService("CoreGui") } do
		pcall(function()
			local hui = gethui()
			if typeof(hui) == "Instance" then
				local old = hui:FindFirstChild("NameHubDSUI")
				if old then
					old:Destroy()
				end
			end
		end)
		local existing = parent:FindFirstChild("NameHubDSUI")
		if existing then
			existing:Destroy()
		end
	end
	pcall(function()
		ContextActionService:UnbindAction("NameHubDSMenu")
	end)
	menuInputBound = false
end

local function resolveHudParent(gui)
	local parents= {}
	pcall(function()
		local hui = gethui()
		if typeof(hui) == "Instance" then
			table.insert(parents, hui)
		end
	end)
	pcall(function()
		table.insert(parents, game:GetService("CoreGui"))
	end)
	table.insert(parents, playerGui)
	for _, parent in parents do
		local ok = pcall(function()
			gui.Parent = parent
		end)
		if ok and gui.Parent == parent then
			return parent
		end
	end
	gui.Parent = playerGui
	return playerGui
end

local function protectGui(gui)
	pcall(function()
		local g = getgenv()
		local fns = {
			g.protect_gui,
			typeof(g.syn) == "table" and g.syn.protect_gui or nil,
			g.protectgui,
			g.secure_gui,
			typeof(g.syn) == "table" and g.syn.secure_gui or nil,
		}
		for _, fn in fns do
			if typeof(fn) == "function" then
				fn(gui)
			end
		end
	end)
	pcall(function()
		(gui ).OnTopOfCoreBlur = true
	end)
end

local function setMenuVisible(visible)
	menuOpen = visible
	if menuFrame then
		menuFrame.Visible = visible
	end
	if toggleButton then
		toggleButton.Text = if visible then "NH ✕" else "NH ▶"
		toggleButton.BackgroundColor3 = if visible then THEME.Accent else THEME.Topbar
	end
end

local function toggleMenu()
	setMenuVisible(not menuOpen)
end

local function getCharacter()
	return localPlayer.Character
end

local function getRoot()
	local character = getCharacter()
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart") 
end

local function tpTo(position)
	local root = getRoot()
	if not root then
		return false
	end
	root.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
	return true
end

local function fireTouch(part)
	local root = getRoot()
	if not root then
		return
	end
	pcall(function()
		local g = getgenv()
		if typeof(g.firetouchinterest) == "function" then
			g.firetouchinterest(root, part, 0)
			task.wait()
			g.firetouchinterest(root, part, 1)
		end
	end)
	pcall(function()
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end)
end

local function nameLooksLikeDiamond(name)
	local lower = string.lower(name)
	return string.find(lower, "diamond", 1, true) ~= nil
end

local function nameLooksLikeFood(name)
	local lower = string.lower(name)
	return string.find(lower, "plant", 1, true)
		or string.find(lower, "food", 1, true)
		or string.find(lower, "meat", 1, true)
		or string.find(lower, "berry", 1, true)
		or string.find(lower, "leaf", 1, true)
end

local function nameLooksLikeWater(name)
	local lower = string.lower(name)
	return string.find(lower, "water", 1, true) or string.find(lower, "pond", 1, true)
end

local function getInstancePosition(inst)
	if inst:IsA("BasePart") then
		return inst.Position
	end
	if inst:IsA("Model") then
		local primary = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
		if primary then
			return primary.Position
		end
	end
	return nil
end

local function getNearestTarget(filterFn)
	local root = getRoot()
	if not root then
		return nil
	end
	local origin = root.Position
	local bestPart= nil
	local bestDist = CONFIG.DiamondSearchRadius

	for _, inst in workspace:GetDescendants() do
		if filterFn(inst.Name) then
			local pos = getInstancePosition(inst)
			if pos then
				local dist = (pos - origin).Magnitude
				if dist <= CONFIG.DiamondSearchRadius then
					local part= nil
					if inst:IsA("BasePart") then
						part = inst
					elseif inst:IsA("Model") then
						part = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
					end
					if part and dist < bestDist then
						bestDist = dist
						bestPart = part
					end
				end
			end
		end
	end

	return bestPart
end

local function readDiamondBalance()
	local leaderstats = localPlayer:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end
	for _, child in leaderstats:GetChildren() do
		if string.find(string.lower(child.Name), "diamond", 1, true) and child:IsA("IntValue") then
			return child.Value
		end
	end
	return nil
end

local function refreshStatsText()
	if not statsLabel then
		return
	end
	local balance = readDiamondBalance()
	local balanceText = if balance then tostring(balance) else "—"
	statsLabel.Text = string.format(
		"Session farms: %d\nSession diamond gain: %d\nCurrent diamonds: %s",
		farmSessionStarts,
		farmSessionDiamonds,
		balanceText
	)
end

local function trackDiamondGain()
	local balance = readDiamondBalance()
	if balance and lastDiamondBalance and balance > lastDiamondBalance then
		farmSessionDiamonds += balance - lastDiamondBalance
	end
	if balance then
		lastDiamondBalance = balance
	end
	refreshStatsText()
end

local function tryAutoSurvival()
	if CONFIG.AutoEatEnabled then
		local food = getNearestTarget(nameLooksLikeFood)
		if food then
			tpTo(food.Position)
			fireTouch(food)
		end
	end
	if CONFIG.AutoDrinkEnabled then
		local water = getNearestTarget(nameLooksLikeWater)
		if water then
			tpTo(water.Position)
			fireTouch(water)
		end
	end
end

local function farmDiamondOnce()
	local diamondPart = getNearestTarget(nameLooksLikeDiamond)
	if not diamondPart then
		return false
	end
	tpTo(diamondPart.Position)
	fireTouch(diamondPart)
	farmSessionStarts += 1
	trackDiamondGain()
	return true
end

local function startDiamondFarmLoop()
	if farmLoopRunning then
		return
	end
	farmLoopRunning = true
	lastDiamondBalance = readDiamondBalance()
	task.spawn(function()
		while scriptAlive and CONFIG.DiamondFarmEnabled do
			if not farmDiamondOnce() then
				tryAutoSurvival()
			end
			refreshStatsText()
			task.wait(CONFIG.DiamondFarmInterval)
		end
		farmLoopRunning = false
	end)
end

local function createToggle(parent, label, getter, setter)
	local row = Instance.new("TextButton")
	row.AutoButtonColor = false
	row.BackgroundColor3 = THEME.Element
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, -2, 0, 34)
	row.Text = ""
	row.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = row

	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.new(1, -84, 1, 0)
	text.Position = UDim2.fromOffset(12, 0)
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 14
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextColor3 = THEME.Text
	text.Text = label
	text.Parent = row

	local badge = Instance.new("TextLabel")
	badge.BackgroundColor3 = THEME.Stroke
	badge.BorderSizePixel = 0
	badge.Size = UDim2.fromOffset(56, 22)
	badge.Position = UDim2.new(1, -68, 0.5, -11)
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 12
	badge.TextColor3 = THEME.Text
	badge.Parent = row
	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(1, 0)
	badgeCorner.Parent = badge

	local function paint()
		local on = getter()
		badge.Text = if on then "ON" else "OFF"
		badge.BackgroundColor3 = if on then THEME.Success else THEME.Stroke
	end

	row.MouseButton1Click:Connect(function()
		setter(not getter())
		paint()
	end)
	paint()
end

local function buildMenu()
	wipeNameHubUi()

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NameHubDSUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1_000_000
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = true
	resolveHudParent(screenGui)
	protectGui(screenGui)

	toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Toggle"
	toggleButton.Size = UDim2.fromOffset(52, 52)
	toggleButton.Position = UDim2.new(0, 12, 0.5, -26)
	toggleButton.BackgroundColor3 = THEME.Accent
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 14
	toggleButton.Text = "NH ▶"
	toggleButton.ZIndex = 1000
	toggleButton.AutoButtonColor = true
	toggleButton.Parent = screenGui
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleButton
	toggleButton.MouseButton1Click:Connect(toggleMenu)

	menuFrame = Instance.new("Frame")
	menuFrame.Name = "Main"
	menuFrame.BackgroundColor3 = THEME.Background
	menuFrame.BorderSizePixel = 0
	menuFrame.Size = UDim2.fromOffset(420, 360)
	menuFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
	menuFrame.Visible = false
	menuFrame.ZIndex = 10
	menuFrame.Parent = screenGui

	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 10)
	menuCorner.Parent = menuFrame

	local topbar = Instance.new("Frame")
	topbar.BackgroundColor3 = THEME.Topbar
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 42)
	topbar.Parent = menuFrame
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topbar

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -20, 1, 0)
	title.Position = UDim2.fromOffset(14, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Text
	title.Text = "NameHub · Dinosaur Simulator"
	title.Parent = topbar

	statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Size = UDim2.new(1, -24, 0, 18)
	statusLabel.Position = UDim2.fromOffset(12, 50)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 13
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextColor3 = THEME.SubText
	statusLabel.Text = "🧪 Beta · Diamond farming only"
	statusLabel.Parent = menuFrame

	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Size = UDim2.new(1, -24, 1, -130)
	body.Position = UDim2.fromOffset(12, 74)
	body.Parent = menuFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = body

	createToggle(body, "Auto Diamond Farm", function()
		return CONFIG.DiamondFarmEnabled
	end, function(on)
		CONFIG.DiamondFarmEnabled = on
		if on then
			startDiamondFarmLoop()
			statusLabel.Text = "💎 Diamond farm running…"
		else
			statusLabel.Text = "Diamond farm paused"
		end
	end)

	createToggle(body, "Auto Eat", function()
		return CONFIG.AutoEatEnabled
	end, function(on)
		CONFIG.AutoEatEnabled = on
	end)

	createToggle(body, "Auto Drink", function()
		return CONFIG.AutoDrinkEnabled
	end, function(on)
		CONFIG.AutoDrinkEnabled = on
	end)

	createToggle(body, "Anti AFK", function()
		return CONFIG.AntiAfkEnabled
	end, function(on)
		CONFIG.AntiAfkEnabled = on
	end)

	statsLabel = Instance.new("TextLabel")
	statsLabel.BackgroundColor3 = THEME.Element
	statsLabel.BorderSizePixel = 0
	statsLabel.Size = UDim2.new(1, -24, 0, 72)
	statsLabel.Position = UDim2.new(0, 12, 1, -84)
	statsLabel.Font = Enum.Font.Code
	statsLabel.TextSize = 13
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.TextYAlignment = Enum.TextYAlignment.Top
	statsLabel.TextColor3 = THEME.SubText
	statsLabel.Text = "Session farms: 0"
	statsLabel.Parent = menuFrame
	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 6)
	statsCorner.Parent = statsLabel

	refreshStatsText()
end

local MENU_KEYS = {
	CONFIG.MenuKey,
	Enum.KeyCode.Home,
	Enum.KeyCode.RightControl,
	Enum.KeyCode.F4,
}

local function isMenuKey(key)
	for _, menuKey in MENU_KEYS do
		if key == menuKey then
			return true
		end
	end
	return false
end

local menuInputBound = false

local function bindMenuInput()
	if menuInputBound then
		return
	end
	menuInputBound = true
	UserInputService.InputBegan:Connect(function(input, _gameProcessed)
		if not scriptAlive then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and isMenuKey(input.KeyCode) then
			toggleMenu()
		end
	end)

	pcall(function()
		ContextActionService:BindActionAtPriority(
			"NameHubDSMenu",
			function(_name, state, input)
				if state ~= Enum.UserInputState.Begin then
					return Enum.ContextActionResult.Pass
				end
				if input.UserInputType == Enum.UserInputType.Keyboard and isMenuKey(input.KeyCode) then
					toggleMenu()
					return Enum.ContextActionResult.Sink
				end
				return Enum.ContextActionResult.Pass
			end,
			false,
			3000,
			CONFIG.MenuKey,
			Enum.KeyCode.Home,
			Enum.KeyCode.RightControl,
			Enum.KeyCode.F4
		)
	end)
end

if CONFIG.AntiAfkEnabled then
	pcall(function()
		localPlayer.Idled:Connect(function()
			if CONFIG.AntiAfkEnabled then
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end
		end)
	end)
end

local bootOk, bootErr = pcall(function()
	buildMenu()
	bindMenuInput()
	setMenuVisible(true)
end)

if not bootOk then
	warn("[NameHub DS] UI boot failed:", bootErr)
	notify("NameHub DS Error", tostring(bootErr))
else
	print("[NameHub DS] UI ready — click green NH button or press Insert / Home / F4")
	notify("NameHub DS", "Click green NH button (left) or Insert")
end

task.spawn(function()
	while scriptAlive do
		task.wait(2)
		if not screenGui or not screenGui.Parent then
			warn("[NameHub DS] UI missing — rebuilding")
			pcall(buildMenu)
			pcall(bindMenuInput)
			setMenuVisible(true)
		end
	end
end)

pcall(function()
	getgenv().NameHubDSUnload = function()
		scriptAlive = false
		CONFIG.DiamondFarmEnabled = false
		wipeNameHubUi()
	end
end)

local function reportLoadToDiscord(gameLabel)
	task.defer(function()
		pcall(function()
			local g = getgenv()
			local url = g.NameHubLoadReportUrl
			if typeof(url) ~= "string" or url == "" then
				return
			end
			local licenseKey = g.NameHubKey
			if typeof(licenseKey) ~= "string" or licenseKey == "" then
				return
			end
			local executorName = "Unknown"
			pcall(function()
				if typeof(identifyexecutor) == "function" then
					executorName = identifyexecutor() or executorName
				elseif typeof(getexecutorname) == "function" then
					executorName = getexecutorname() or executorName
				end
			end)
			local payload = HttpService:JSONEncode({
				key = licenseKey,
				executor = executorName,
				robloxUser = localPlayer.Name,
				robloxUserId = localPlayer.UserId,
				placeId = game.PlaceId,
				gameName = game.Name,
				gameLabel = gameLabel,
			})
			local headers= { ["Content-Type"] = "application/json" }
			local secret = g.NameHubLoadReportSecret
			if typeof(secret) == "string" and secret ~= "" then
				headers["Authorization"] = "Bearer " .. secret
			end
			local req = g.request or g.http_request
			if typeof(g.syn) == "table" and typeof(g.syn.request) == "function" then
				req = g.syn.request
			end
			if typeof(req) == "function" then
				req({
					Url = url,
					Method = "POST",
					Headers = headers,
					Body = payload,
				})
			end
		end)
	end)
end

print("[NameHub DS] Loaded PlaceId", game.PlaceId, "GameId", game.GameId)
reportLoadToDiscord("Dinosaur Simulator")
