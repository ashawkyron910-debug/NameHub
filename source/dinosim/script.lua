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
	FarmSpeed = 220,
	NoclipEnabled = true,
	MeteorFarmEnabled = false,
	MeteorFarmInterval = 0.85,
	MeteorSearchRadius = 12000,
	MeteorFarmSpeed = 220,
	MeteorNoclipEnabled = true,
	FlyEnabled = false,
	FlyKey = Enum.KeyCode.V,
	FlySpeed = 140,
	AutoEatEnabled = true,
	AutoDrinkEnabled = true,
	AntiAfkEnabled = true,
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
	ThemeName = "Midnight",
}

local THEME = {
	Background = Color3.fromRGB(16, 16, 18),
	Topbar = Color3.fromRGB(12, 12, 14),
	Element = Color3.fromRGB(22, 22, 25),
	Accent = Color3.fromRGB(230, 55, 85),
	Text = Color3.fromRGB(232, 232, 236),
	SubText = Color3.fromRGB(118, 116, 130),
	Stroke = Color3.fromRGB(48, 48, 54),
	Success = Color3.fromRGB(230, 55, 85),
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
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
local uiLoading = true
local farmSessionDiamonds = 0
local farmSessionStarts = 0
local lastDiamondBalance= nil
local farmLoopRunning = false
local meteorLoopRunning = false
local meteorSessionStarts = 0

local screenGui
local menuFrame
local toggleButton
local statusLabel
local meteorStatus
local statsLabel
local togglePainters = {}
local footerLabel
local menuKeyLabel
local flyKeyLabel
local listeningForMenuKey = false
local listeningForFlyKey = false
local menuInputConn
local refreshToggles
local setFlyEnabled

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
	if menuInputConn then
		menuInputConn:Disconnect()
		menuInputConn = nil
	end
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
	if uiLoading then
		visible = false
	end
	menuOpen = visible
	if menuFrame then
		menuFrame.Visible = visible
	end
	if toggleButton then
		toggleButton.Text = if visible then "NH ✕" else "NH ▶"
		toggleButton.BackgroundColor3 = if visible then THEME.Accent else THEME.Topbar
	end
end

local lastMenuToggle = 0
local function toggleMenu()
	local now = os.clock()
	if now - lastMenuToggle < 0.25 then
		return
	end
	lastMenuToggle = now
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

local noclipActive = false
local noclipReasons = {}
local savedCollide = {}

local function applyNoclip()
	local character = getCharacter()
	if not character then
		return
	end
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = true
	end
end

RunService.Stepped:Connect(function()
	if noclipActive then
		applyNoclip()
	end
end)

local function setNoclipReason(reason, on)
	if on then
		if not noclipActive then
			savedCollide = {}
			local character = getCharacter()
			if character then
				for _, part in character:GetDescendants() do
					if part:IsA("BasePart") then
						savedCollide[part] = part.CanCollide
					end
				end
			end
		end
		noclipReasons[reason] = true
		noclipActive = true
		applyNoclip()
		return
	end
	noclipReasons[reason] = nil
	if next(noclipReasons) ~= nil then
		return
	end
	noclipActive = false
	for part, canCollide in savedCollide do
		if typeof(part) == "Instance" and part.Parent and part:IsA("BasePart") then
			part.CanCollide = canCollide
		end
	end
	savedCollide = {}
	local character = getCharacter()
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end
	end
end

local function flyDirection()
	local camera = workspace.CurrentCamera
	if not camera then
		return Vector3.zero
	end
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local direction = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		direction += look
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		direction -= look
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		direction -= right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		direction += right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		direction += Vector3.yAxis
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		direction -= Vector3.yAxis
	end
	if direction.Magnitude < 0.05 then
		return Vector3.zero
	end
	return direction.Unit
end

function setFlyEnabled(on)
	CONFIG.FlyEnabled = on
	local root = getRoot()
	if not on then
		setNoclipReason("fly", false)
		if root then
			local existing = root:FindFirstChild("NameHubDSFly")
			if existing then
				existing:Destroy()
			end
			if not root:FindFirstChild("NameHubDSMove") then
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end
	if refreshToggles then
		refreshToggles()
	end
end

RunService.Heartbeat:Connect(function()
	if not scriptAlive or not CONFIG.FlyEnabled then
		return
	end
	local root = getRoot()
	if not root or root:FindFirstChild("NameHubDSMove") then
		return
	end
	setNoclipReason("fly", true)
	local mover = root:FindFirstChild("NameHubDSFly")
	if not mover then
		mover = Instance.new("BodyVelocity")
		mover.Name = "NameHubDSFly"
		mover.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		mover.P = 12500
		mover.Parent = root
	end
	local speed = math.clamp(tonumber(CONFIG.FlySpeed) or 140, 40, 400)
	local direction = flyDirection()
	local velocity = if direction.Magnitude > 0 then direction * speed else Vector3.zero
	mover.Velocity = velocity
	root.AssemblyLinearVelocity = velocity
end)

local function clearMove(root)
	if not root then
		return
	end
	local existing = root:FindFirstChild("NameHubDSMove")
	if existing then
		existing:Destroy()
	end
	root.AssemblyLinearVelocity = Vector3.zero
end

local function stopMove(mover)
	setNoclipReason("farm", false)
	local root = getRoot()
	clearMove(root)
	if mover and mover.Parent then
		mover:Destroy()
	end
end

local function tpTo(position, move)
	move = move or {
		enabled = function()
			return CONFIG.DiamondFarmEnabled
		end,
		speed = function()
			return CONFIG.FarmSpeed
		end,
		noclip = function()
			return CONFIG.NoclipEnabled
		end,
	}
	local goal = position
	local started = os.clock()
	local root = getRoot()
	if not root then
		return false
	end
	pcall(function()
		sethiddenproperty(localPlayer, "SimulationRadius", 1000)
		sethiddenproperty(localPlayer, "MaxSimulationRadius", 1000)
	end)
	local mover = Instance.new("BodyVelocity")
	mover.Name = "NameHubDSMove"
	mover.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	mover.P = 12500
	mover.Velocity = Vector3.zero
	mover.Parent = root
	while scriptAlive and move.enabled() do
		root = getRoot()
		if not root then
			stopMove(mover)
			return false
		end
		if mover.Parent ~= root then
			mover.Parent = root
		end
		local speed = math.clamp(tonumber(move.speed()) or 220, 40, 400)
		local useNoclip = move.noclip() == true
		if useNoclip then
			setNoclipReason("farm", true)
		elseif noclipReasons.farm then
			setNoclipReason("farm", false)
		end
		local delta = goal - root.Position
		local flat = Vector3.new(delta.X, 0, delta.Z)
		local arriveDist = if move.arrive then move.arrive() else (if useNoclip then 14 else 12)
		if move.arrive and delta.Magnitude < 36 then
			speed = math.min(speed, 48)
		end
		local reached = if useNoclip then delta.Magnitude <= arriveDist else flat.Magnitude <= arriveDist
		if reached then
			mover.Velocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
			if move.onArrive then
				move.onArrive()
			end
			stopMove(mover)
			return true
		end
		if os.clock() - started > 50 then
			stopMove(mover)
			return false
		end
		local velocity
		if useNoclip and delta.Magnitude > 1 then
			velocity = delta.Unit * speed
		elseif flat.Magnitude > 1 then
			local climb = math.clamp(delta.Y, -50, 50)
			velocity = flat.Unit * speed + Vector3.new(0, climb, 0)
		else
			velocity = Vector3.zero
		end
		mover.Velocity = velocity
		root.AssemblyLinearVelocity = velocity
		RunService.Heartbeat:Wait()
	end
	stopMove(mover)
	return false
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
end

local function nameLooksLikeDiamond(name)
	local lower = string.lower(name)
	return string.find(lower, "diamond", 1, true) ~= nil
end

local function nameLooksLikeMeteor(name)
	local lower = string.lower(name)
	return string.find(lower, "meteor", 1, true) ~= nil
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

local function getNearestTarget(filterFn, radius)
	local root = getRoot()
	if not root then
		return nil
	end
	radius = radius or CONFIG.DiamondSearchRadius
	local origin = root.Position
	local bestPart= nil
	local bestDist = radius

	for _, inst in workspace:GetDescendants() do
		if filterFn(inst.Name) then
			local pos = getInstancePosition(inst)
			if pos then
				local dist = (pos - origin).Magnitude
				if dist <= radius then
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
	if statusLabel then
		statusLabel.Text = "Moving to a diamond"
	end
	if not tpTo(diamondPart.Position) then
		return false
	end
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

local ADULT_STAGE_NAMES = {
	baby = true,
	child = true,
	juvenile = true,
	teen = true,
	["young adult"] = true,
	youngadult = true,
	subadult = true,
	["sub-adult"] = true,
}

local function growthValueName(name)
	local lower = string.lower(name)
	return lower == "growth"
		or lower == "currentgrowth"
		or lower == "age"
		or lower == "growthstage"
		or lower == "stage"
		or lower == "growthpercent"
end

local function setGrowthValue(valueObj)
	local lower = string.lower(valueObj.Name)
	if lower == "maxgrowth" or lower == "overallgrowth" or lower == "maxage" then
		return false
	end
	if valueObj:IsA("StringValue") then
		if ADULT_STAGE_NAMES[string.lower(valueObj.Value)] then
			valueObj.Value = "Adult"
			return true
		end
		return false
	end
	if not (valueObj:IsA("NumberValue") or valueObj:IsA("IntValue")) then
		return false
	end
	local parent = valueObj.Parent
	local cap = nil
	if parent then
		for _, capName in { "MaxGrowth", "OverallGrowth", "MaxAge" } do
			local capValue = parent:FindFirstChild(capName)
			if capValue and (capValue:IsA("NumberValue") or capValue:IsA("IntValue")) and capValue.Value > 0 then
				cap = capValue.Value
				break
			end
		end
	end
	if lower == "age" then
		local stage = parent and parent:FindFirstChild("GrowthStage")
		local stageSaysYoung = stage and stage:IsA("StringValue") and ADULT_STAGE_NAMES[string.lower(stage.Value)]
		if stageSaysYoung and valueObj.Value < 3 then
			valueObj.Value = 3
			return true
		end
		if valueObj.Value > 0 and valueObj.Value < 1 then
			valueObj.Value = 1
			return true
		end
		return false
	end
	if cap and valueObj.Value < cap then
		valueObj.Value = cap
		return true
	end
	if valueObj.Value > 0 and valueObj.Value < 1 then
		valueObj.Value = 1
		return true
	end
	if valueObj.Value > 1 and valueObj.Value < 100 then
		valueObj.Value = 100
		return true
	end
	return false
end

local function setGrowthAttributes(inst)
	pcall(function()
		for name, value in inst:GetAttributes() do
			local lower = string.lower(name)
			if typeof(value) == "string" and (lower == "growthstage" or lower == "stage" or lower == "age") then
				if ADULT_STAGE_NAMES[string.lower(value)] then
					inst:SetAttribute(name, "Adult")
				end
			elseif typeof(value) == "number" and (lower == "growth" or lower == "currentgrowth") then
				local cap = inst:GetAttribute("MaxGrowth") or inst:GetAttribute("OverallGrowth")
				if typeof(cap) == "number" and cap > value then
					inst:SetAttribute(name, cap)
				elseif value > 0 and value < 1 then
					inst:SetAttribute(name, 1)
				elseif value > 1 and value < 100 then
					inst:SetAttribute(name, 100)
				end
			end
		end
	end)
end

local function growToAdult()
	local roots = {}
	local character = getCharacter()
	if character then
		table.insert(roots, character)
	end
	table.insert(roots, localPlayer)
	for _, root in roots do
		setGrowthAttributes(root)
		for _, inst in root:GetDescendants() do
			if inst:IsA("ValueBase") and growthValueName(inst.Name) then
				setGrowthValue(inst)
			elseif inst:IsA("Model") or inst:IsA("Folder") or inst:IsA("BasePart") then
				setGrowthAttributes(inst)
			end
		end
	end
	pcall(function()
		if typeof(getgc) ~= "function" then
			return
		end
		local found = 0
		for _, obj in getgc(true) do
			if typeof(obj) ~= "table" then
				continue
			end
			local cap = rawget(obj, "OverallGrowth") or rawget(obj, "MaxGrowth")
			if typeof(cap) == "number" and cap > 0 then
				local currentKey = if rawget(obj, "CurrentGrowth") ~= nil then "CurrentGrowth" else "Growth"
				local current = rawget(obj, currentKey)
				if typeof(current) == "number" and current < cap then
					rawset(obj, currentKey, cap)
					found += 1
				end
			end
			for _, key in { "GrowthStage", "Stage", "AgeName" } do
				local stage = rawget(obj, key)
				if typeof(stage) == "string" and ADULT_STAGE_NAMES[string.lower(stage)] then
					rawset(obj, key, "Adult")
					found += 1
				end
			end
			if found >= 4 then
				break
			end
		end
	end)
end

local function meteorTopPosition(part)
	local lift = 8
	if part:IsA("BasePart") then
		local half = part.Size.Y * 0.5
		if half > 25 then
			half = 10
		end
		lift = half + 5
	end
	return part.Position + Vector3.new(0, lift, 0)
end

local function promptHostPosition(prompt)
	local parent = prompt.Parent
	if parent and parent:IsA("BasePart") then
		return parent.Position
	end
	if parent and parent:IsA("Attachment") and parent.Parent and parent.Parent:IsA("BasePart") then
		return parent.Parent.Position
	end
	if parent and parent:IsA("Model") then
		local host = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
		if host then
			return host.Position
		end
	end
	return nil
end

local function findMeteorPrompt(part)
	local best = nil
	local bestDist = 30
	local function consider(inst)
		if not inst:IsA("ProximityPrompt") then
			return
		end
		local pos = promptHostPosition(inst)
		if not pos then
			return
		end
		local dist = (pos - part.Position).Magnitude
		if dist < bestDist then
			bestDist = dist
			best = inst
		end
	end
	for _, desc in part:GetDescendants() do
		consider(desc)
	end
	local parent = part.Parent
	if parent and parent ~= workspace then
		for _, desc in parent:GetDescendants() do
			consider(desc)
		end
	end
	return best
end

local function triggerPrompt(prompt)
	pcall(function()
		prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 24)
		prompt.RequiresLineOfSight = false
	end)
	pcall(function()
		local fn = getgenv().fireproximityprompt
		if typeof(fn) == "function" then
			fn(prompt)
		end
	end)
	pcall(function()
		prompt:InputHoldBegin()
		task.wait((prompt.HoldDuration or 0) + 0.2)
		prompt:InputHoldEnd()
	end)
end

local meteorMove = {
	enabled = function()
		return CONFIG.MeteorFarmEnabled
	end,
	speed = function()
		return CONFIG.MeteorFarmSpeed
	end,
	noclip = function()
		return CONFIG.MeteorNoclipEnabled
	end,
}

local function farmMeteorOnce()
	local meteorPart = getNearestTarget(nameLooksLikeMeteor, CONFIG.MeteorSearchRadius)
	if not meteorPart then
		if meteorStatus then
			meteorStatus.Text = "No meteorite in range"
		end
		return false
	end
	if meteorStatus then
		meteorStatus.Text = "Growing to adult"
	end
	growToAdult()
	if meteorStatus then
		meteorStatus.Text = "Moving on top of a meteorite"
	end
	local move = {
		enabled = meteorMove.enabled,
		speed = meteorMove.speed,
		noclip = meteorMove.noclip,
		arrive = function()
			return 5
		end,
		onArrive = function()
			if meteorStatus then
				meteorStatus.Text = "Collecting meteorite"
			end
			growToAdult()
			for _ = 1, 4 do
				if not CONFIG.MeteorFarmEnabled then
					return
				end
				local prompt = findMeteorPrompt(meteorPart)
				if prompt then
					triggerPrompt(prompt)
				end
				task.wait(0.15)
			end
		end,
	}
	if not tpTo(meteorTopPosition(meteorPart), move) then
		return false
	end
	meteorSessionStarts += 1
	if meteorStatus then
		meteorStatus.Text = "Meteorites collected: " .. tostring(meteorSessionStarts)
	end
	return true
end

local function startMeteorFarmLoop()
	if meteorLoopRunning then
		return
	end
	meteorLoopRunning = true
	task.spawn(function()
		while scriptAlive and CONFIG.MeteorFarmEnabled do
			farmMeteorOnce()
			task.wait(CONFIG.MeteorFarmInterval)
		end
		meteorLoopRunning = false
	end)
end

local loaderFrame
local loadPercent
local loadFill
local loadStatus

local function createToggle(parent, label, getter, setter)
	local row = Instance.new("TextButton")
	row.AutoButtonColor = false
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Text = ""
	row.Parent = parent

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -28, 1, 0)
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 13
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = THEME.Text
	textLabel.Text = label
	textLabel.Parent = row

	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, 0, 0.5, 0)
	box.Size = UDim2.fromOffset(14, 14)
	box.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	box.BorderSizePixel = 0
	box.Parent = row
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = THEME.Stroke
	boxStroke.Thickness = 1
	boxStroke.Parent = box

	local mark = Instance.new("Frame")
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	mark.Size = UDim2.fromOffset(8, 8)
	mark.BackgroundColor3 = THEME.Accent
	mark.BorderSizePixel = 0
	mark.Parent = box

	local function paint()
		local on = getter()
		mark.Visible = on
		boxStroke.Color = if on then THEME.Accent else THEME.Stroke
	end

	row.MouseButton1Click:Connect(function()
		setter(not getter())
		paint()
	end)
	paint()
	table.insert(togglePainters, paint)
	return row
end

function refreshToggles()
	for _, paint in togglePainters do
		paint()
	end
end

local function createSlider(parent, label, minValue, maxValue, step, getter, setter, formatValue)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1, 0, 0, 36)
	holder.Parent = parent

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -56, 0, 16)
	title.Font = Enum.Font.Gotham
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Text
	title.Text = label
	title.Active = false
	title.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, 0, 0, 0)
	valueLabel.Size = UDim2.fromOffset(56, 16)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.Active = false
	valueLabel.Parent = holder

	local track = Instance.new("TextButton")
	track.AutoButtonColor = false
	track.Text = ""
	track.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(0, 22)
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Parent = holder
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = THEME.Stroke
	trackStroke.Thickness = 1
	trackStroke.Parent = track

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Active = false
	fill.Parent = track

	local dragging = false
	local function paint(value)
		local alpha = (value - minValue) / (maxValue - minValue)
		alpha = math.clamp(alpha, 0, 1)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		if formatValue then
			valueLabel.Text = formatValue(value)
		else
			valueLabel.Text = tostring(math.floor(value + 0.5))
		end
	end
	local function pointerX()
		local inset = game:GetService("GuiService"):GetGuiInset()
		return UserInputService:GetMouseLocation().X - inset.X
	end
	local function setFromX(x)
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return
		end
		local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
		local raw = minValue + (maxValue - minValue) * alpha
		local snapped = minValue + math.floor((raw - minValue) / step + 0.5) * step
		snapped = math.clamp(snapped, minValue, maxValue)
		setter(snapped)
		paint(getter())
	end

	track.MouseButton1Down:Connect(function()
		dragging = true
		setFromX(pointerX())
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(pointerX())
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	paint(getter())
	return holder
end

local function makeColumn(parent, x, title)
	local col = Instance.new("Frame")
	col.BackgroundColor3 = THEME.Element
	col.BorderSizePixel = 0
	col.Position = UDim2.fromOffset(x, 58)
	col.Size = UDim2.new(0, 228, 1, -70)
	col.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Stroke
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = col

	local head = Instance.new("TextLabel")
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, -24, 0, 18)
	head.Position = UDim2.fromOffset(12, 10)
	head.Font = Enum.Font.GothamBold
	head.TextSize = 11
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.TextColor3 = THEME.SubText
	head.Text = string.upper(title)
	head.Parent = col

	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(12, 36)
	body.Size = UDim2.new(1, -24, 1, -46)
	body.Parent = col
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = body
	return body
end

local function buildLoader()
	loaderFrame = Instance.new("Frame")
	loaderFrame.Name = "Loader"
	loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	loaderFrame.Position = UDim2.fromScale(0.5, 0.5)
	loaderFrame.Size = UDim2.fromOffset(460, 124)
	loaderFrame.BackgroundColor3 = THEME.Background
	loaderFrame.BorderSizePixel = 0
	loaderFrame.ZIndex = 50
	loaderFrame.Parent = screenGui
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Stroke
	stroke.Parent = loaderFrame

	local logo = Instance.new("TextLabel")
	logo.BackgroundTransparency = 1
	logo.Position = UDim2.fromOffset(18, 16)
	logo.Size = UDim2.new(1, -120, 0, 24)
	logo.Font = Enum.Font.GothamBold
	logo.TextSize = 18
	logo.TextXAlignment = Enum.TextXAlignment.Left
	logo.TextColor3 = THEME.Accent
	logo.Text = "NAMEHUB"
	logo.ZIndex = 51
	logo.Parent = loaderFrame

	loadPercent = Instance.new("TextLabel")
	loadPercent.BackgroundTransparency = 1
	loadPercent.AnchorPoint = Vector2.new(1, 0)
	loadPercent.Position = UDim2.new(1, -18, 0, 16)
	loadPercent.Size = UDim2.fromOffset(80, 24)
	loadPercent.Font = Enum.Font.GothamBold
	loadPercent.TextSize = 18
	loadPercent.TextXAlignment = Enum.TextXAlignment.Right
	loadPercent.TextColor3 = THEME.Text
	loadPercent.Text = "1%"
	loadPercent.ZIndex = 51
	loadPercent.Parent = loaderFrame

	loadStatus = Instance.new("TextLabel")
	loadStatus.BackgroundTransparency = 1
	loadStatus.Position = UDim2.fromOffset(18, 44)
	loadStatus.Size = UDim2.new(1, -36, 0, 18)
	loadStatus.Font = Enum.Font.Gotham
	loadStatus.TextSize = 13
	loadStatus.TextXAlignment = Enum.TextXAlignment.Left
	loadStatus.TextColor3 = THEME.SubText
	loadStatus.Text = "loading"
	loadStatus.ZIndex = 51
	loadStatus.Parent = loaderFrame

	local track = Instance.new("Frame")
	track.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(18, 78)
	track.Size = UDim2.new(1, -36, 0, 8)
	track.ZIndex = 51
	track.Parent = loaderFrame

	loadFill = Instance.new("Frame")
	loadFill.BackgroundColor3 = THEME.Accent
	loadFill.BorderSizePixel = 0
	loadFill.Size = UDim2.new(0.01, 0, 1, 0)
	loadFill.ZIndex = 52
	loadFill.Parent = track

	local hint = Instance.new("TextLabel")
	hint.BackgroundTransparency = 1
	hint.Position = UDim2.fromOffset(18, 94)
	hint.Size = UDim2.new(1, -36, 0, 16)
	hint.Font = Enum.Font.Gotham
	hint.TextSize = 11
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextColor3 = THEME.SubText
	hint.Text = "dinosaur simulator"
	hint.ZIndex = 51
	hint.Parent = loaderFrame
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
	toggleButton.Size = UDim2.fromOffset(36, 36)
	toggleButton.Position = UDim2.new(0, 12, 0.5, -18)
	toggleButton.BackgroundColor3 = THEME.Background
	toggleButton.TextColor3 = THEME.Accent
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 12
	toggleButton.Text = "NH"
	toggleButton.ZIndex = 1000
	toggleButton.AutoButtonColor = false
	toggleButton.Parent = screenGui
	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = THEME.Stroke
	toggleStroke.Parent = toggleButton
	toggleButton.MouseButton1Click:Connect(toggleMenu)

	menuFrame = Instance.new("Frame")
	menuFrame.Name = "Main"
	menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	menuFrame.BackgroundColor3 = THEME.Background
	menuFrame.BorderSizePixel = 0
	menuFrame.Size = UDim2.fromOffset(732, 340)
	menuFrame.Position = UDim2.fromScale(0.5, 0.5)
	menuFrame.Visible = false
	menuFrame.ZIndex = 10
	menuFrame.Parent = screenGui
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = THEME.Stroke
	menuStroke.Parent = menuFrame

	local topbar = Instance.new("Frame")
	topbar.BackgroundColor3 = THEME.Topbar
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 46)
	topbar.ZIndex = 11
	topbar.Parent = menuFrame

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromOffset(140, 46)
	title.Position = UDim2.fromOffset(16, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = THEME.Accent
	title.Text = "NAMEHUB"
	title.ZIndex = 12
	title.Parent = topbar

	local tag = Instance.new("TextLabel")
	tag.BackgroundTransparency = 1
	tag.AnchorPoint = Vector2.new(1, 0.5)
	tag.Position = UDim2.new(1, -16, 0.5, 0)
	tag.Size = UDim2.fromOffset(120, 20)
	tag.Font = Enum.Font.Gotham
	tag.TextSize = 12
	tag.TextXAlignment = Enum.TextXAlignment.Right
	tag.TextColor3 = THEME.SubText
	tag.Text = "dinosaur sim"
	tag.ZIndex = 12
	tag.Parent = topbar

	local farmPage = Instance.new("Frame")
	farmPage.BackgroundTransparency = 1
	farmPage.Size = UDim2.fromScale(1, 1)
	farmPage.ZIndex = 11
	farmPage.Parent = menuFrame
	local meteorPage = Instance.new("Frame")
	meteorPage.BackgroundTransparency = 1
	meteorPage.Size = UDim2.fromScale(1, 1)
	meteorPage.Visible = false
	meteorPage.ZIndex = 11
	meteorPage.Parent = menuFrame
	local movementPage = Instance.new("Frame")
	movementPage.BackgroundTransparency = 1
	movementPage.Size = UDim2.fromScale(1, 1)
	movementPage.Visible = false
	movementPage.ZIndex = 11
	movementPage.Parent = menuFrame
	local settingsPage = Instance.new("Frame")
	settingsPage.BackgroundTransparency = 1
	settingsPage.Size = UDim2.fromScale(1, 1)
	settingsPage.Visible = false
	settingsPage.ZIndex = 11
	settingsPage.Parent = menuFrame

	local farmTab = Instance.new("TextButton")
	farmTab.BackgroundTransparency = 1
	farmTab.Position = UDim2.fromOffset(148, 8)
	farmTab.Size = UDim2.fromOffset(56, 30)
	farmTab.Font = Enum.Font.GothamBold
	farmTab.TextSize = 12
	farmTab.Text = "FARM"
	farmTab.TextColor3 = THEME.Accent
	farmTab.ZIndex = 12
	farmTab.Parent = topbar
	local meteorTab = Instance.new("TextButton")
	meteorTab.BackgroundTransparency = 1
	meteorTab.Position = UDim2.fromOffset(206, 8)
	meteorTab.Size = UDim2.fromOffset(76, 30)
	meteorTab.Font = Enum.Font.GothamBold
	meteorTab.TextSize = 12
	meteorTab.Text = "METEOR"
	meteorTab.TextColor3 = THEME.SubText
	meteorTab.ZIndex = 12
	meteorTab.Parent = topbar
	local movementTab = Instance.new("TextButton")
	movementTab.BackgroundTransparency = 1
	movementTab.Position = UDim2.fromOffset(284, 8)
	movementTab.Size = UDim2.fromOffset(104, 30)
	movementTab.Font = Enum.Font.GothamBold
	movementTab.TextSize = 12
	movementTab.Text = "MOVEMENT"
	movementTab.TextColor3 = THEME.SubText
	movementTab.ZIndex = 12
	movementTab.Parent = topbar
	local settingsTab = Instance.new("TextButton")
	settingsTab.BackgroundTransparency = 1
	settingsTab.Position = UDim2.fromOffset(390, 8)
	settingsTab.Size = UDim2.fromOffset(90, 30)
	settingsTab.Font = Enum.Font.GothamBold
	settingsTab.TextSize = 12
	settingsTab.Text = "SETTINGS"
	settingsTab.TextColor3 = THEME.SubText
	settingsTab.ZIndex = 12
	settingsTab.Parent = topbar
	local function showPage(page)
		farmPage.Visible = page == "farm"
		meteorPage.Visible = page == "meteor"
		movementPage.Visible = page == "movement"
		settingsPage.Visible = page == "settings"
		farmTab.TextColor3 = if page == "farm" then THEME.Accent else THEME.SubText
		meteorTab.TextColor3 = if page == "meteor" then THEME.Accent else THEME.SubText
		movementTab.TextColor3 = if page == "movement" then THEME.Accent else THEME.SubText
		settingsTab.TextColor3 = if page == "settings" then THEME.Accent else THEME.SubText
	end
	farmTab.MouseButton1Click:Connect(function()
		showPage("farm")
	end)
	meteorTab.MouseButton1Click:Connect(function()
		showPage("meteor")
	end)
	movementTab.MouseButton1Click:Connect(function()
		showPage("movement")
	end)
	settingsTab.MouseButton1Click:Connect(function()
		showPage("settings")
	end)

	local farmCol = makeColumn(farmPage, 12, "Farm")
	local survivalCol = makeColumn(farmPage, 252, "Survival")
	local sessionCol = makeColumn(farmPage, 492, "Session")

	statusLabel = Instance.new("TextLabel")
	statusLabel.BackgroundTransparency = 1
	statusLabel.Size = UDim2.new(1, 0, 0, 32)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextWrapped = true
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Top
	statusLabel.TextColor3 = THEME.SubText
	statusLabel.Text = "Diamond farm paused"
	statusLabel.LayoutOrder = 10
	statusLabel.Parent = farmCol

	createToggle(farmCol, "Auto Diamond Farm", function()
		return CONFIG.DiamondFarmEnabled
	end, function(on)
		CONFIG.DiamondFarmEnabled = on
		if on then
			CONFIG.MeteorFarmEnabled = false
			if meteorStatus then
				meteorStatus.Text = "Meteorite farm paused"
			end
			task.spawn(function()
				while meteorLoopRunning do
					task.wait()
				end
				if CONFIG.DiamondFarmEnabled then
					startDiamondFarmLoop()
					statusLabel.Text = "Diamond farm running"
				end
				refreshToggles()
			end)
		else
			statusLabel.Text = "Diamond farm paused"
		end
		refreshToggles()
	end)

	createSlider(farmCol, "Speed", 40, 400, 10, function()
		return CONFIG.FarmSpeed
	end, function(value)
		CONFIG.FarmSpeed = value
	end, function(value)
		return tostring(math.floor(value + 0.5))
	end)

	createToggle(farmCol, "Noclip", function()
		return CONFIG.NoclipEnabled
	end, function(on)
		CONFIG.NoclipEnabled = on
	end)

	createSlider(farmCol, "Delay", 0.2, 5, 0.1, function()
		return CONFIG.DiamondFarmInterval
	end, function(value)
		CONFIG.DiamondFarmInterval = value
	end, function(value)
		return string.format("%.1fs", value)
	end)

	createSlider(farmCol, "Range", 500, 12000, 500, function()
		return CONFIG.DiamondSearchRadius
	end, function(value)
		CONFIG.DiamondSearchRadius = value
	end, function(value)
		return tostring(math.floor(value + 0.5))
	end)

	createToggle(survivalCol, "Auto Eat", function()
		return CONFIG.AutoEatEnabled
	end, function(on)
		CONFIG.AutoEatEnabled = on
	end)

	createToggle(survivalCol, "Auto Drink", function()
		return CONFIG.AutoDrinkEnabled
	end, function(on)
		CONFIG.AutoDrinkEnabled = on
	end)

	createToggle(survivalCol, "Anti AFK", function()
		return CONFIG.AntiAfkEnabled
	end, function(on)
		CONFIG.AntiAfkEnabled = on
	end)

	statsLabel = Instance.new("TextLabel")
	statsLabel.BackgroundTransparency = 1
	statsLabel.Size = UDim2.new(1, 0, 0, 72)
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextSize = 13
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.TextYAlignment = Enum.TextYAlignment.Top
	statsLabel.TextColor3 = THEME.Text
	statsLabel.Text = "Session farms: 0"
	statsLabel.Parent = sessionCol

	local meteorCol = makeColumn(meteorPage, 12, "Meteorite")
	meteorStatus = Instance.new("TextLabel")
	meteorStatus.BackgroundTransparency = 1
	meteorStatus.Size = UDim2.new(1, 0, 0, 32)
	meteorStatus.Font = Enum.Font.Gotham
	meteorStatus.TextSize = 12
	meteorStatus.TextWrapped = true
	meteorStatus.TextXAlignment = Enum.TextXAlignment.Left
	meteorStatus.TextYAlignment = Enum.TextYAlignment.Top
	meteorStatus.TextColor3 = THEME.SubText
	meteorStatus.Text = "Meteorite farm paused"
	meteorStatus.LayoutOrder = 10
	meteorStatus.Parent = meteorCol

	createToggle(meteorCol, "Auto Meteorite Farm", function()
		return CONFIG.MeteorFarmEnabled
	end, function(on)
		CONFIG.MeteorFarmEnabled = on
		if on then
			CONFIG.DiamondFarmEnabled = false
			statusLabel.Text = "Diamond farm paused"
			task.spawn(function()
				while farmLoopRunning do
					task.wait()
				end
				if CONFIG.MeteorFarmEnabled then
					startMeteorFarmLoop()
					meteorStatus.Text = "Meteorite farm running"
				end
				refreshToggles()
			end)
		else
			meteorStatus.Text = "Meteorite farm paused"
		end
		refreshToggles()
	end)

	createSlider(meteorCol, "Speed", 40, 400, 10, function()
		return CONFIG.MeteorFarmSpeed
	end, function(value)
		CONFIG.MeteorFarmSpeed = value
	end, function(value)
		return tostring(math.floor(value + 0.5))
	end)

	createToggle(meteorCol, "Noclip", function()
		return CONFIG.MeteorNoclipEnabled
	end, function(on)
		CONFIG.MeteorNoclipEnabled = on
	end)

	createSlider(meteorCol, "Delay", 0.2, 5, 0.1, function()
		return CONFIG.MeteorFarmInterval
	end, function(value)
		CONFIG.MeteorFarmInterval = value
	end, function(value)
		return string.format("%.1fs", value)
	end)

	createSlider(meteorCol, "Range", 500, 12000, 500, function()
		return CONFIG.MeteorSearchRadius
	end, function(value)
		CONFIG.MeteorSearchRadius = value
	end, function(value)
		return tostring(math.floor(value + 0.5))
	end)

	local movementCol = makeColumn(movementPage, 12, "Fly")
	createToggle(movementCol, "Fly", function()
		return CONFIG.FlyEnabled
	end, function(on)
		setFlyEnabled(on)
	end)
	createSlider(movementCol, "Speed", 40, 400, 10, function()
		return CONFIG.FlySpeed
	end, function(value)
		CONFIG.FlySpeed = value
	end, function(value)
		return tostring(math.floor(value + 0.5))
	end)
	local flyKeyRow = Instance.new("TextButton")
	flyKeyRow.AutoButtonColor = false
	flyKeyRow.BackgroundTransparency = 1
	flyKeyRow.Size = UDim2.new(1, 0, 0, 28)
	flyKeyRow.Text = ""
	flyKeyRow.Parent = movementCol
	local flyKeyTitle = Instance.new("TextLabel")
	flyKeyTitle.BackgroundTransparency = 1
	flyKeyTitle.Size = UDim2.new(1, -72, 1, 0)
	flyKeyTitle.Font = Enum.Font.Gotham
	flyKeyTitle.TextSize = 13
	flyKeyTitle.TextXAlignment = Enum.TextXAlignment.Left
	flyKeyTitle.TextColor3 = THEME.Text
	flyKeyTitle.Text = "Fly key"
	flyKeyTitle.Active = false
	flyKeyTitle.Parent = flyKeyRow
	flyKeyLabel = Instance.new("TextLabel")
	flyKeyLabel.BackgroundTransparency = 1
	flyKeyLabel.AnchorPoint = Vector2.new(1, 0.5)
	flyKeyLabel.Position = UDim2.new(1, 0, 0.5, 0)
	flyKeyLabel.Size = UDim2.fromOffset(72, 20)
	flyKeyLabel.Font = Enum.Font.GothamBold
	flyKeyLabel.TextSize = 12
	flyKeyLabel.TextXAlignment = Enum.TextXAlignment.Right
	flyKeyLabel.TextColor3 = THEME.Accent
	flyKeyLabel.Text = CONFIG.FlyKey.Name
	flyKeyLabel.Active = false
	flyKeyLabel.Parent = flyKeyRow
	local flyKeyHit = Instance.new("TextButton")
	flyKeyHit.BackgroundTransparency = 1
	flyKeyHit.Text = ""
	flyKeyHit.AutoButtonColor = false
	flyKeyHit.Size = UDim2.fromScale(1, 1)
	flyKeyHit.ZIndex = 5
	flyKeyHit.Parent = flyKeyRow
	local function beginFlyListen()
		listeningForMenuKey = false
		listeningForFlyKey = true
		flyKeyLabel.Text = "Press"
	end
	flyKeyRow.MouseButton1Click:Connect(beginFlyListen)
	flyKeyHit.MouseButton1Click:Connect(beginFlyListen)
	local flyHint = Instance.new("TextLabel")
	flyHint.BackgroundTransparency = 1
	flyHint.Size = UDim2.new(1, 0, 0, 48)
	flyHint.Font = Enum.Font.Gotham
	flyHint.TextSize = 12
	flyHint.TextWrapped = true
	flyHint.TextXAlignment = Enum.TextXAlignment.Left
	flyHint.TextYAlignment = Enum.TextYAlignment.Top
	flyHint.TextColor3 = THEME.SubText
	flyHint.Text = "WASD moves. Space up, Ctrl down. Click Fly key, then press a key."
	flyHint.Parent = movementCol

	local settingsCol = makeColumn(settingsPage, 12, "Menu")
	local keyRow = Instance.new("TextButton")
	keyRow.AutoButtonColor = false
	keyRow.BackgroundTransparency = 1
	keyRow.Size = UDim2.new(1, 0, 0, 28)
	keyRow.Text = ""
	keyRow.Parent = settingsCol
	local keyTitle = Instance.new("TextLabel")
	keyTitle.BackgroundTransparency = 1
	keyTitle.Size = UDim2.new(1, -72, 1, 0)
	keyTitle.Font = Enum.Font.Gotham
	keyTitle.TextSize = 13
	keyTitle.TextXAlignment = Enum.TextXAlignment.Left
	keyTitle.TextColor3 = THEME.Text
	keyTitle.Text = "Menu key"
	keyTitle.Parent = keyRow
	menuKeyLabel = Instance.new("TextLabel")
	menuKeyLabel.BackgroundTransparency = 1
	menuKeyLabel.AnchorPoint = Vector2.new(1, 0.5)
	menuKeyLabel.Position = UDim2.new(1, 0, 0.5, 0)
	menuKeyLabel.Size = UDim2.fromOffset(72, 20)
	menuKeyLabel.Font = Enum.Font.GothamBold
	menuKeyLabel.TextSize = 12
	menuKeyLabel.TextXAlignment = Enum.TextXAlignment.Right
	menuKeyLabel.TextColor3 = THEME.Accent
	menuKeyLabel.Text = CONFIG.MenuKey.Name
	menuKeyLabel.Parent = keyRow
	keyTitle.Active = false
	menuKeyLabel.Active = false
	local keyHit = Instance.new("TextButton")
	keyHit.BackgroundTransparency = 1
	keyHit.Text = ""
	keyHit.AutoButtonColor = false
	keyHit.Size = UDim2.fromScale(1, 1)
	keyHit.ZIndex = 5
	keyHit.Parent = keyRow
	local function beginKeyListen()
		listeningForFlyKey = false
		listeningForMenuKey = true
		menuKeyLabel.Text = "Press"
	end
	keyRow.MouseButton1Click:Connect(beginKeyListen)
	keyHit.MouseButton1Click:Connect(beginKeyListen)
	local keyHint = Instance.new("TextLabel")
	keyHint.BackgroundTransparency = 1
	keyHint.Size = UDim2.new(1, 0, 0, 36)
	keyHint.Font = Enum.Font.Gotham
	keyHint.TextSize = 12
	keyHint.TextWrapped = true
	keyHint.TextXAlignment = Enum.TextXAlignment.Left
	keyHint.TextYAlignment = Enum.TextYAlignment.Top
	keyHint.TextColor3 = THEME.SubText
	keyHint.Text = "Click Menu key, then press the key you want. Escape cancels."
	keyHint.Parent = settingsCol

	footerLabel = Instance.new("TextLabel")
	footerLabel.BackgroundTransparency = 1
	footerLabel.AnchorPoint = Vector2.new(0, 1)
	footerLabel.Position = UDim2.new(0, 16, 1, -8)
	footerLabel.Size = UDim2.new(1, -32, 0, 16)
	footerLabel.Font = Enum.Font.Gotham
	footerLabel.TextSize = 11
	footerLabel.TextXAlignment = Enum.TextXAlignment.Left
	footerLabel.TextColor3 = THEME.SubText
	footerLabel.Text = CONFIG.MenuKey.Name .. " · dinosaur simulator"
	footerLabel.ZIndex = 12
	footerLabel.Parent = menuFrame

	if uiLoading then
		buildLoader()
	end

	refreshStatsText()
end

local function isMenuKey(key)
	return key == CONFIG.MenuKey
		or key == Enum.KeyCode.Home
		or key == Enum.KeyCode.RightControl
		or key == Enum.KeyCode.F4
end

local function applyMenuKey(keyCode)
	CONFIG.MenuKey = keyCode
	listeningForMenuKey = false
	if menuKeyLabel then
		menuKeyLabel.Text = keyCode.Name
	end
	if footerLabel then
		footerLabel.Text = keyCode.Name .. " · dinosaur simulator"
	end
	pcall(function()
		ContextActionService:UnbindAction("NameHubDSMenu")
		ContextActionService:BindActionAtPriority(
			"NameHubDSMenu",
			function(_name, state, input)
				if state ~= Enum.UserInputState.Begin then
					return Enum.ContextActionResult.Pass
				end
				if uiLoading then
					return Enum.ContextActionResult.Sink
				end
				if input.UserInputType ~= Enum.UserInputType.Keyboard then
					return Enum.ContextActionResult.Pass
				end
				if listeningForMenuKey then
					if input.KeyCode ~= Enum.KeyCode.Escape then
						applyMenuKey(input.KeyCode)
					else
						listeningForMenuKey = false
						if menuKeyLabel then
							menuKeyLabel.Text = CONFIG.MenuKey.Name
						end
					end
					return Enum.ContextActionResult.Sink
				end
				if isMenuKey(input.KeyCode) then
					return Enum.ContextActionResult.Sink
				end
				return Enum.ContextActionResult.Pass
			end,
			false,
			3000,
			keyCode,
			Enum.KeyCode.Home,
			Enum.KeyCode.RightControl,
			Enum.KeyCode.F4
		)
	end)
end

local function bindMenuInput()
	if menuInputConn then
		menuInputConn:Disconnect()
		menuInputConn = nil
	end
	menuInputConn = UserInputService.InputBegan:Connect(function(input, _gameProcessed)
		if not scriptAlive or uiLoading then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if listeningForMenuKey then
			if input.KeyCode ~= Enum.KeyCode.Escape then
				applyMenuKey(input.KeyCode)
			else
				listeningForMenuKey = false
				if menuKeyLabel then
					menuKeyLabel.Text = CONFIG.MenuKey.Name
				end
			end
			return
		end
		if listeningForFlyKey then
			if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= CONFIG.MenuKey then
				CONFIG.FlyKey = input.KeyCode
			end
			listeningForFlyKey = false
			if flyKeyLabel then
				flyKeyLabel.Text = CONFIG.FlyKey.Name
			end
			return
		end
		if input.KeyCode == CONFIG.FlyKey and input.KeyCode ~= CONFIG.MenuKey then
			setFlyEnabled(not CONFIG.FlyEnabled)
			return
		end
		if isMenuKey(input.KeyCode) then
			toggleMenu()
		end
	end)
	applyMenuKey(CONFIG.MenuKey)
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
	setMenuVisible(false)
end)

if not bootOk then
	uiLoading = false
	warn("[NameHub DS] UI boot failed:", bootErr)
	notify("NameHub DS Error", tostring(bootErr))
else
	print("[NameHub DS] UI loading")
	task.spawn(function()
		for step = 1, 100 do
			if not scriptAlive then
				return
			end
			if loadPercent then
				loadPercent.Text = tostring(step) .. "%"
			end
			if loadFill then
				loadFill.Size = UDim2.new(step / 100, 0, 1, 0)
			end
			if loadStatus then
				if step < 35 then
					loadStatus.Text = "loading"
				elseif step < 70 then
					loadStatus.Text = "preparing farm"
				elseif step < 100 then
					loadStatus.Text = "starting"
				else
					loadStatus.Text = "ready"
				end
			end
			task.wait(0.018)
		end
		uiLoading = false
		if loaderFrame then
			loaderFrame:Destroy()
			loaderFrame = nil
		end
		setMenuVisible(true)
		notify("NameHub DS", CONFIG.MenuKey.Name .. " opens the menu")
	end)
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
		CONFIG.MeteorFarmEnabled = false
		CONFIG.FlyEnabled = false
		pcall(function()
			setNoclipReason("fly", false)
			setNoclipReason("farm", false)
			local character = localPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				local flyMover = root:FindFirstChild("NameHubDSFly")
				if flyMover then
					flyMover:Destroy()
				end
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end)
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
