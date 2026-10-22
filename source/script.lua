-- NameHub · Arsenal build 2026-08-23T19:33:19.436Z
print("[NameHub] Boot arsenal 2026-08-23T19:33:19.436Z")
--[[
	NameHub — Arsenal only (Aim Assist / ESP / Movement)
]]

warn("[NameHub] Script file running — PlaceId " .. tostring(game.PlaceId))
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "NameHub",
		Text = "Loading — press Insert or click NH (left)",
		Duration = 10,
	})
end)

local ARSENAL_PLACE_ID = 286090429

local CONFIG = {
	ToggleKey = Enum.KeyCode.RightShift,
	ToggleMouse = nil ,
	MenuKey = Enum.KeyCode.Insert,
	LoadingImageId = "rbxassetid://0",
	LoadingDuration = 2.8,
	FOVRadius = 320,
	ShowFOVCircle = true,
	FOVCircleColor = Color3.fromRGB(255, 255, 255),
	FOVCircleThickness = 2,
	FOVCircleTransparency = 0.35,
	TargetPartName = "Head",
	MaxWorldDistance = 1200,
	RequireLineOfSight = false,
	TeamCheckEnabled = false,
	IgnoreNeutralTeams = true,
	Smoothness = 0.95,
	AimStickyLock = true,
	AimSnapLock = true,
	AimPrediction = true,
	AimStickiness = 2.2,
	ShowTargetMarker = true,
	TargetMarkerColor = Color3.fromRGB(255, 80, 80),
	RaycastOriginPart = "Head",
	ESPEnabled = true,
	ESPBoxes = true,
	ESPSkeleton = false,
	ESPNames = true,
	ESPDistance = true,
	ESPHealthBar = true,
	ESPHighlights = true,
	ESPTracers = false,
	ESPTeamCheck = false,
	ESPMaxDistance = 500,
	ESPEnemyColor = Color3.fromRGB(255, 75, 75),
	ESPTeamColor = Color3.fromRGB(80, 170, 255),
	ESPBoxColor = Color3.fromRGB(255, 75, 75),
	ESPBoxRainbow = false,
	ESPSkeletonColor = Color3.fromRGB(255, 180, 80),
	ESPSkeletonRainbow = false,
	ESPNameColor = Color3.fromRGB(255, 255, 255),
	ESPNameRainbow = false,
	ESPDistanceColor = Color3.fromRGB(200, 200, 210),
	ESPDistanceRainbow = false,
	ESPHighlightColor = Color3.fromRGB(255, 75, 75),
	ESPHighlightRainbow = false,
	ESPTracerColor = Color3.fromRGB(255, 120, 120),
	ESPTracerRainbow = false,
	ESPHealthColor = Color3.fromRGB(80, 220, 100),
	ESPHealthRainbow = false,
	ESPUseTeamColors = false,
	ESPRainbowSpeed = 1,
	RainbowWeaponsEnabled = false,
	ESPGlow = false,
	ESPGlowSpeed = 2,
	ESPTextSize = 12,
	FlyKey = Enum.KeyCode.F,
	FlySpeed = 50,
	FlyBoostMultiplier = 2.5,
	FlyVerticalMultiplier = 1,
	SpeedEnabled = false,
	WalkSpeed = 24,
	JumpEnabled = false,
	JumpHeight = 50,
	RapidFireEnabled = false,
	RapidFireRate = 18,
	NoclipKey = Enum.KeyCode.N,
	ThirdPersonEnabled = false,
	ThirdPersonKey = Enum.KeyCode.V,
	ThirdPersonDistance = 32,
	ThirdPersonScrollStep = 3,
	SpinBotEnabled = false,
	SpinBotSpeed = 540,
	SpinBotJitter = true,
	SpinBotJitterAmount = 120,
	SpinBotAntiAim = true,
	SpinBotPitchAmount = 35,
	SpinBotPitchSpeed = 5,
	AimActivationMode = "Toggle",
	SilentAimKey = Enum.KeyCode.T,
	SilentAimShowMarker = true,
	SilentAimMarkerColor = Color3.fromRGB(170, 110, 255),
	SilentAimUseClosest = true,
	SilentAimStickyLock = false,
	SilentAimSnapOnFire = true,
	SilentAimClickFire = true,
	AimClickFire = true,
	SilentAimShowTracer = true,
	SilentAimFireCooldown = 0.05,
	SilentAimTracerTime = 0.08,
	ThemeName = "Midnight",
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
	ConfigAutoLoad = true,
}

local CONFIG_SKIP_SAVE = {
	DiscordInviteUrl = true,
	ConfigAutoLoad = true,
}

local TARGET_PART_OPTIONS = { "Head", "HumanoidRootPart", "UpperTorso" }
local AIM_MODE_OPTIONS = { "Toggle", "Hold" }

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

if game.PlaceId ~= ARSENAL_PLACE_ID then
	warn(
		string.format(
			"[NameHub] Expected Arsenal PlaceId %s — got %s (%s). Continuing anyway.",
			tostring(ARSENAL_PLACE_ID),
			tostring(game.PlaceId),
			game.Name
		)
	)
end

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Replace any previous NameHub instance (stops “old build still running”)
do
	pcall(function()
		local g = getgenv()
		if typeof(g.NameHubUnload) == "function" then
			g.NameHubUnload()
		end
	end)
	local function wipe(parent)
		if not parent then
			return
		end
		local ui = parent:FindFirstChild("NameHubUI")
		if ui then
			ui:Destroy()
		end
		local api = parent:FindFirstChild("NameHubAPI")
		if api then
			api:Destroy()
		end
	end
	pcall(function()
		wipe(gethui())
	end)
	pcall(function()
		wipe(game:GetService("CoreGui"))
	end)
	wipe(playerGui)
end

local LOG_PREFIX = "[NameHub]"
local logLastAt= {}
local logRecent= {}
local LOG_RECENT_MAX = 40

local function pushRecent(line)
	table.insert(logRecent, line)
	if #logRecent > LOG_RECENT_MAX then
		table.remove(logRecent, 1)
	end
end

local function logInfo(tag, message)
	local line = LOG_PREFIX .. " [" .. tag .. "] " .. message
	pushRecent(line)
	print(line)
end

local function logWarn(tag, message)
	local line = LOG_PREFIX .. " [WARN:" .. tag .. "] " .. message
	pushRecent(line)
	warn(line)
end

local function logError(tag, err, context)
	local detail = if context then context .. " — " .. tostring(err) else tostring(err)
	local line = LOG_PREFIX .. " [ERR:" .. tag .. "] " .. detail
	pushRecent(line)
	warn(line)
	print(line)
end

local function logNote(tag, key, message, cooldown)
	local now = os.clock()
	local bucket = tag .. ":" .. key
	local gap = cooldown or 4
	if now - (logLastAt[bucket] or 0) < gap then
		return
	end
	logLastAt[bucket] = now
	logInfo(tag, message)
end

local function safeCall(tag, fn, context)
	local ok, result = xpcall(fn, function(err)
		return debug.traceback(tostring(err), 2)
	end)
	if not ok then
		logError(tag, result, context)
	end
	return ok, result
end

local function logBootDiagnostics()
	local g = getgenv()
	local syn = if typeof(g.syn) == "table" then g.syn else nil
	local function has(name)
		if typeof(g[name]) == "function" then
			return true
		end
		if syn and typeof(syn[name]) == "function" then
			return true
		end
		return false
	end
	local caps = {
		"hookfunction=" .. tostring(has("hookfunction") or has("hook_function")),
		"hookmetamethod=" .. tostring(has("hookmetamethod") or has("hook_metamethod")),
		"getconnections=" .. tostring(has("getconnections") or has("get_connections")),
		"getsenv=" .. tostring(has("getsenv") or has("get_script_env")),
	}
	logInfo("Boot", "Build ready — NameHub for Arsenal · open F9 for logs")
	logInfo("Boot", "Game PlaceId=" .. tostring(game.PlaceId) .. " · Name=" .. game.Name .. " · Players=" .. tostring(#Players:GetPlayers()))
	logInfo("Boot", "Executor APIs: " .. table.concat(caps, " · "))
	pcall(function()
		getgenv().NameHubLogs = logRecent
		getgenv().NameHubLog = logInfo
		getgenv().NameHubLogWarn = logWarn
		getgenv().NameHubLogError = logError
	end)
end

local enabled = false
local aimKeyHeld = false
local mouse1Held = false
local menuOpen = false
local flyEnabled = false
local noclipEnabled = false
local silentAimEnabled = false
local scriptAlive = true
local scriptConnections= {}
local unloadNameHub = nil
local currentTarget= nil
local lockedTarget= nil
local aimLookAt= nil
local aimCameraActive = false
local aimLockPausedUntil = 0
local aimRenderBound = false
local perfTicks = { esp = 0, noclip = 0, movement = 0, knife = 0, weaponRainbow = 0 }
local silentAimTarget= nil
local silentAimPart= nil
local silentAimPosition= nil
local trackedPlayers= {}
local setNoclipEnabled = nil
local notify

local flyState= { wasPlatformStand = false }
local toggleUI= {}
local setFlyEnabled
local setThirdPersonEnabled
local setSpinBotEnabled
local setSilentAimEnabled
local clearAllEsp
local getPredictedAimPosition
local setAimCameraActive
local findClosestTarget
local acquireAimTarget
local acquireSilentAimTarget
local resolveSilentAimShot
local clearSilentAimSticky
local redirectSilentAimForShot
local smoothLookAt
local updateEsp
local updateNoclip
local updateFly
local updateThirdPerson
local updateSpinBot
local adjustThirdPersonZoom
local updateMovement
local applyMovementMods
local startRapidFire
local stopRapidFire
local refreshRapidFireStats
local updateRapidFire
local activateHeldTool
local trySilentAimFire
local updateAutoKnife
local updateRainbowWeapons
local restoreRainbowWeapons
local isMouseOverMenu
local clearSilentAimLock
local updateSilentAimLock
local installCombatRayHook
local beginCombatShotWindow
local endCombatShotWindow

-- Safe stubs until real implementations load (prevents toggle callbacks hitting nil)
setAimCameraActive = function(active)
	aimCameraActive = active
	if not active then
		aimLookAt = nil
	end
end
findClosestTarget = function()
	return nil
end
acquireAimTarget = function(_precomputedClosest)
	return nil
end
acquireSilentAimTarget = function(_precomputedClosest)
	return nil
end
resolveSilentAimShot = function()
	return nil, nil, nil
end
clearSilentAimSticky = function() end
redirectSilentAimForShot = function() end
smoothLookAt = function(_lookAtPosition, _alpha) end
getPredictedAimPosition = function(part, _character)
	return part.Position
end
updateEsp = function() end
updateNoclip = function() end
updateFly = function() end
updateThirdPerson = function() end
updateSpinBot = function() end
adjustThirdPersonZoom = function(_delta) end
setSpinBotEnabled = function(_value) end
updateMovement = function() end
applyMovementMods = function() end
clearAllEsp = function() end
startRapidFire = function() end
stopRapidFire = function() end
refreshRapidFireStats = function() end
updateRapidFire = function() end
activateHeldTool = function() end
trySilentAimFire = function()
	return false
end
updateAutoKnife = function() end
updateRainbowWeapons = function() end
restoreRainbowWeapons = function() end
clearSilentAimLock = function() end
updateSilentAimLock = function(_targetPlayer) end
installCombatRayHook = function()
	return false
end
beginCombatShotWindow = function() end
endCombatShotWindow = function() end
isMouseOverMenu = function()
	return false
end

local espVisuals= {}

local function resolveLoadingImage()
	local fromConfig = CONFIG.LoadingImageId
	if typeof(fromConfig) == "string" and fromConfig ~= "" and fromConfig ~= "rbxassetid://0" then
		return fromConfig
	end
	local embedded = script:FindFirstChild("NameHubLogo")
	if embedded then
		if embedded:IsA("Decal") or embedded:IsA("Texture") then
			return embedded.Texture
		elseif embedded:IsA("ImageLabel") or embedded:IsA("ImageButton") then
			return embedded.Image
		end
	end
	return ""
end

local function playNameHubLoadingScreen()
	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "NameHubLoadingScreen"
	loadingGui.IgnoreGuiInset = true
	loadingGui.ResetOnSpawn = false
	loadingGui.DisplayOrder = 1000
	loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loadingGui.Parent = playerGui

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
	backdrop.BorderSizePixel = 0
	backdrop.Parent = loadingGui

	local glow = Instance.new("Frame")
	glow.Name = "Glow"
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.new(0.5, 0, 0.42, 0)
	glow.Size = UDim2.fromOffset(280, 280)
	glow.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
	glow.BackgroundTransparency = 0.82
	glow.BorderSizePixel = 0
	glow.Parent = backdrop

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(1, 0)
	glowCorner.Parent = glow

	local logo = Instance.new("ImageLabel")
	logo.Name = "Logo"
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.new(0.5, 0, 0.38, 0)
	logo.Size = UDim2.fromOffset(160, 160)
	logo.BackgroundTransparency = 1
	logo.ScaleType = Enum.ScaleType.Fit
	logo.Image = resolveLoadingImage()
	logo.Parent = backdrop

	if logo.Image ~= "" then
		pcall(function()
			ContentProvider:PreloadAsync({ logo })
		end)
	end

	local brand = Instance.new("TextLabel")
	brand.Name = "Brand"
	brand.AnchorPoint = Vector2.new(0.5, 0)
	brand.Position = UDim2.new(0.5, 0, 0.38, 95)
	brand.Size = UDim2.fromOffset(320, 40)
	brand.BackgroundTransparency = 1
	brand.Font = Enum.Font.GothamBold
	brand.Text = "NameHub"
	brand.TextColor3 = Color3.fromRGB(230, 235, 245)
	brand.TextSize = 34
	brand.TextStrokeColor3 = Color3.fromRGB(40, 120, 255)
	brand.TextStrokeTransparency = 0.65
	brand.Parent = backdrop

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Position = UDim2.new(0.5, 0, 0.38, 135)
	status.Size = UDim2.fromOffset(280, 20)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.Gotham
	status.Text = "Loading..."
	status.TextColor3 = Color3.fromRGB(140, 160, 200)
	status.TextSize = 14
	status.Parent = backdrop

	local percentLabel = Instance.new("TextLabel")
	percentLabel.Name = "Percent"
	percentLabel.AnchorPoint = Vector2.new(0.5, 0)
	percentLabel.Position = UDim2.new(0.5, 0, 0.72, 0)
	percentLabel.Size = UDim2.fromOffset(200, 36)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Font = Enum.Font.GothamBold
	percentLabel.Text = "100%"
	percentLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
	percentLabel.TextSize = 28
	percentLabel.Parent = backdrop

	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.AnchorPoint = Vector2.new(0.5, 0)
	barBg.Position = UDim2.new(0.5, 0, 0.72, 44)
	barBg.Size = UDim2.fromOffset(220, 6)
	barBg.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
	barBg.BorderSizePixel = 0
	barBg.Parent = backdrop

	local barBgCorner = Instance.new("UICorner")
	barBgCorner.CornerRadius = UDim.new(1, 0)
	barBgCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.fromScale(1, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg

	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(1, 0)
	barFillCorner.Parent = barFill

	local duration = math.max(CONFIG.LoadingDuration, 0.5)
	local startTime = os.clock()
	local currentPct = 100

	while true do
		local alpha = math.clamp((os.clock() - startTime) / duration, 0, 1)
		local eased = 1 - (1 - alpha) ^ 2
		currentPct = math.clamp(math.floor(100 - eased * 99 + 0.5), 1, 100)
		percentLabel.Text = string.format("%d%%", currentPct)
		barFill.Size = UDim2.fromScale(currentPct / 100, 1)
		if alpha >= 1 then
			break
		end
		RunService.RenderStepped:Wait()
	end

	percentLabel.Text = "1%"
	barFill.Size = UDim2.fromScale(0.01, 1)
	status.Text = "Ready"
	task.wait(0.2)

	local fadeInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(backdrop, fadeInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(glow, fadeInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
	TweenService:Create(brand, fadeInfo, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	TweenService:Create(status, fadeInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(percentLabel, fadeInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(barBg, fadeInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(barFill, fadeInfo, { BackgroundTransparency = 1 }):Play()
	task.wait(0.5)
	loadingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NameHubUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1_000_000
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = true
pcall(function()
	(screenGui ).ClipToDeviceSafeArea = false
end)

local function resolveHudParent()
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
			screenGui.Parent = parent
		end)
		if ok and screenGui.Parent == parent then
			return parent
		end
	end
	screenGui.Parent = playerGui
	return playerGui
end

resolveHudParent()

-- Stop games/executors from eating or deleting the hub UI
pcall(function()
	local g = getgenv()
	local protect = g.protect_gui or (typeof(g.syn) == "table" and g.syn.protect_gui) or g.protectgui
	if typeof(protect) == "function" then
		protect(screenGui)
	end
end)
pcall(function()
	(screenGui ).OnTopOfCoreBlur = true
end)

local toastHost = Instance.new("Frame")
toastHost.Name = "Toasts"
toastHost.AnchorPoint = Vector2.new(1, 1)
toastHost.Position = UDim2.new(1, -16, 1, -16)
toastHost.Size = UDim2.fromOffset(280, 320)
toastHost.BackgroundTransparency = 1
toastHost.ZIndex = 200
toastHost.Active = false
pcall(function()
	(toastHost ).Interactable = false
end)
toastHost.Parent = screenGui
local toastLayout = Instance.new("UIListLayout")
toastLayout.FillDirection = Enum.FillDirection.Vertical
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.Padding = UDim.new(0, 8)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastHost
local toastOrder = 0

notify = function(title, detail)
	pcall(function()
		if not scriptAlive or not screenGui.Parent then
			return
		end
		toastOrder = toastOrder + 1
		local order = toastOrder
		local accentColor = (THEME and THEME.Accent) or Color3.fromRGB(100, 120, 255)
		local textColor = (THEME and THEME.Text) or Color3.fromRGB(240, 240, 240)
		local subColor = (THEME and THEME.SubText) or Color3.fromRGB(160, 160, 165)
		local card = Instance.new("Frame")
		card.Name = "Toast"
		card.Size = UDim2.fromOffset(260, if detail and detail ~= "" then 52 else 36)
		card.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
		card.BackgroundTransparency = 0.08
		card.BorderSizePixel = 0
		card.LayoutOrder = order
		card.ZIndex = 201
		card.Active = false
		card.Parent = toastHost
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card
		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 1, 0)
		accent.BackgroundColor3 = accentColor
		accent.BorderSizePixel = 0
		accent.ZIndex = 202
		accent.Parent = card
		local titleLabel = Instance.new("TextLabel")
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.fromOffset(12, if detail and detail ~= "" then 6 else 8)
		titleLabel.Size = UDim2.new(1, -20, 0, 18)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Text = title
		titleLabel.TextColor3 = textColor
		titleLabel.TextSize = 13
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.ZIndex = 202
		titleLabel.Parent = card
		if detail and detail ~= "" then
			local detailLabel = Instance.new("TextLabel")
			detailLabel.BackgroundTransparency = 1
			detailLabel.Position = UDim2.fromOffset(12, 26)
			detailLabel.Size = UDim2.new(1, -20, 0, 16)
			detailLabel.Font = Enum.Font.Gotham
			detailLabel.Text = detail
			detailLabel.TextColor3 = subColor
			detailLabel.TextSize = 11
			detailLabel.TextXAlignment = Enum.TextXAlignment.Left
			detailLabel.ZIndex = 202
			detailLabel.Parent = card
		end
		card.BackgroundTransparency = 1
		titleLabel.TextTransparency = 1
		TweenService:Create(card, TweenInfo.new(0.18), { BackgroundTransparency = 0.08 }):Play()
		TweenService:Create(titleLabel, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
		task.delay(2.2, function()
			if not card.Parent then
				return
			end
			pcall(function()
				local fade = TweenService:Create(card, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
				fade:Play()
				for _, child in card:GetDescendants() do
					if child:IsA("TextLabel") then
						TweenService:Create(child, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
					elseif child:IsA("GuiObject") then
						TweenService:Create(child, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
					end
				end
				fade.Completed:Wait()
				card:Destroy()
			end)
		end)
	end)
end

local savedMouseBehavior= nil
local savedMouseIconEnabled = true
local menuCursorForced = false

local function forceMenuCursor(wantCursor)
	menuCursorForced = wantCursor
	if wantCursor then
		if not savedMouseBehavior then
			savedMouseBehavior = UserInputService.MouseBehavior
			savedMouseIconEnabled = UserInputService.MouseIconEnabled
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	else
		if savedMouseBehavior then
			UserInputService.MouseBehavior = savedMouseBehavior
		end
		UserInputService.MouseIconEnabled = savedMouseIconEnabled
		savedMouseBehavior = nil
	end
end
local function createCircleFrame(name, color, thickness, transparency)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromOffset(CONFIG.FOVRadius * 2, CONFIG.FOVRadius * 2)
	frame.Visible = false
	frame.ZIndex = 1
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.Parent = frame
	frame.Parent = screenGui
	return frame, stroke
end

local fovCircle, fovStroke = createCircleFrame("FOVCircle", CONFIG.FOVCircleColor, CONFIG.FOVCircleThickness, CONFIG.FOVCircleTransparency)
local targetMarker = createCircleFrame("TargetMarker", CONFIG.TargetMarkerColor, 2, 0.2)
targetMarker.Size = UDim2.fromOffset(16, 16)
local silentMarker = createCircleFrame("SilentAimMarker", CONFIG.SilentAimMarkerColor, 2, 0.15)
silentMarker.Size = UDim2.fromOffset(14, 14)

local espOverlay = Instance.new("Folder")
espOverlay.Name = "ESPOverlay"
espOverlay.Parent = screenGui

local nameHubApi = Instance.new("Folder")
nameHubApi.Name = "NameHubAPI"
nameHubApi.Parent = playerGui

local getSilentAimTargetFn = Instance.new("BindableFunction")
getSilentAimTargetFn.Name = "GetSilentAimTarget"
getSilentAimTargetFn.Parent = nameHubApi

local getSilentAimDirectionFn = Instance.new("BindableFunction")
getSilentAimDirectionFn.Name = "GetSilentAimDirection"
getSilentAimDirectionFn.Parent = nameHubApi

local silentAimChangedEvent = Instance.new("BindableEvent")
silentAimChangedEvent.Name = "SilentAimChanged"
silentAimChangedEvent.Parent = nameHubApi

local silentAimShotEvent = Instance.new("BindableEvent")
silentAimShotEvent.Name = "SilentAimShot"
silentAimShotEvent.Parent = nameHubApi

getSilentAimTargetFn.OnInvoke = function()
	if not silentAimEnabled then
		return nil
	end
	local _pos, part, player = resolveSilentAimShot()
	if not part then
		return nil
	end
	return part, _pos, player
end

getSilentAimDirectionFn.OnInvoke = function(origin)
	if not silentAimEnabled then
		return nil
	end
	local aimPos, _part, player = resolveSilentAimShot()
	if not aimPos then
		return nil
	end
	local from = origin
	if typeof(from) ~= "Vector3" then
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		from = if hrp and hrp:IsA("BasePart") then hrp.Position else (camera and camera.CFrame.Position or Vector3.zero)
	end
	local delta = aimPos - from
	if delta.Magnitude < 0.001 then
		return Vector3.zero
	end
	return delta.Unit, aimPos, _part, player
end

local isSilentAimReadyFn = Instance.new("BindableFunction")
isSilentAimReadyFn.Name = "IsSilentAimReady"
isSilentAimReadyFn.Parent = nameHubApi
isSilentAimReadyFn.OnInvoke = function()
	if not silentAimEnabled then
		return false
	end
	local _pos, part = resolveSilentAimShot()
	return part ~= nil
end

local function refreshOverlayFromConfig()
	fovCircle.Size = UDim2.fromOffset(CONFIG.FOVRadius * 2, CONFIG.FOVRadius * 2)
	fovStroke.Color = CONFIG.FOVCircleColor
	fovStroke.Thickness = CONFIG.FOVCircleThickness
	fovStroke.Transparency = CONFIG.FOVCircleTransparency
end

local THEME_PRESETS = {
	Midnight = {
		Background = Color3.fromRGB(25, 27, 29),
		Topbar = Color3.fromRGB(32, 34, 37),
		Element = Color3.fromRGB(35, 37, 40),
		ElementHover = Color3.fromRGB(42, 44, 48),
		Accent = Color3.fromRGB(100, 120, 255),
		Text = Color3.fromRGB(240, 240, 240),
		SubText = Color3.fromRGB(160, 160, 165),
		Stroke = Color3.fromRGB(55, 55, 60),
		Success = Color3.fromRGB(60, 180, 100),
	},
	Ocean = {
		Background = Color3.fromRGB(12, 24, 36),
		Topbar = Color3.fromRGB(18, 36, 52),
		Element = Color3.fromRGB(22, 42, 60),
		ElementHover = Color3.fromRGB(28, 54, 76),
		Accent = Color3.fromRGB(56, 189, 248),
		Text = Color3.fromRGB(226, 242, 255),
		SubText = Color3.fromRGB(148, 180, 204),
		Stroke = Color3.fromRGB(40, 72, 96),
		Success = Color3.fromRGB(45, 212, 191),
	},
	Crimson = {
		Background = Color3.fromRGB(28, 16, 18),
		Topbar = Color3.fromRGB(40, 20, 24),
		Element = Color3.fromRGB(48, 24, 28),
		ElementHover = Color3.fromRGB(62, 30, 36),
		Accent = Color3.fromRGB(239, 68, 68),
		Text = Color3.fromRGB(255, 240, 240),
		SubText = Color3.fromRGB(190, 150, 150),
		Stroke = Color3.fromRGB(80, 40, 45),
		Success = Color3.fromRGB(74, 222, 128),
	},
	Emerald = {
		Background = Color3.fromRGB(14, 28, 22),
		Topbar = Color3.fromRGB(20, 40, 30),
		Element = Color3.fromRGB(24, 46, 34),
		ElementHover = Color3.fromRGB(32, 58, 44),
		Accent = Color3.fromRGB(52, 211, 153),
		Text = Color3.fromRGB(236, 253, 245),
		SubText = Color3.fromRGB(156, 190, 170),
		Stroke = Color3.fromRGB(40, 70, 55),
		Success = Color3.fromRGB(34, 197, 94),
	},
	Amethyst = {
		Background = Color3.fromRGB(24, 18, 36),
		Topbar = Color3.fromRGB(34, 26, 52),
		Element = Color3.fromRGB(40, 30, 60),
		ElementHover = Color3.fromRGB(52, 40, 76),
		Accent = Color3.fromRGB(168, 85, 247),
		Text = Color3.fromRGB(245, 240, 255),
		SubText = Color3.fromRGB(180, 160, 210),
		Stroke = Color3.fromRGB(70, 50, 100),
		Success = Color3.fromRGB(52, 211, 153),
	},
	Sunset = {
		Background = Color3.fromRGB(32, 20, 16),
		Topbar = Color3.fromRGB(46, 28, 20),
		Element = Color3.fromRGB(54, 34, 24),
		ElementHover = Color3.fromRGB(68, 42, 30),
		Accent = Color3.fromRGB(251, 146, 60),
		Text = Color3.fromRGB(255, 247, 237),
		SubText = Color3.fromRGB(214, 180, 150),
		Stroke = Color3.fromRGB(90, 55, 40),
		Success = Color3.fromRGB(132, 204, 22),
	},
	Snow = {
		Background = Color3.fromRGB(236, 238, 242),
		Topbar = Color3.fromRGB(248, 250, 252),
		Element = Color3.fromRGB(255, 255, 255),
		ElementHover = Color3.fromRGB(226, 232, 240),
		Accent = Color3.fromRGB(37, 99, 235),
		Text = Color3.fromRGB(15, 23, 42),
		SubText = Color3.fromRGB(100, 116, 139),
		Stroke = Color3.fromRGB(203, 213, 225),
		Success = Color3.fromRGB(22, 163, 74),
	},
	Cyber = {
		Background = Color3.fromRGB(8, 12, 10),
		Topbar = Color3.fromRGB(12, 20, 16),
		Element = Color3.fromRGB(16, 28, 22),
		ElementHover = Color3.fromRGB(22, 40, 30),
		Accent = Color3.fromRGB(57, 255, 20),
		Text = Color3.fromRGB(220, 255, 230),
		SubText = Color3.fromRGB(120, 180, 140),
		Stroke = Color3.fromRGB(30, 60, 40),
		Success = Color3.fromRGB(34, 197, 94),
	},
	Rose = {
		Background = Color3.fromRGB(30, 16, 24),
		Topbar = Color3.fromRGB(42, 22, 34),
		Element = Color3.fromRGB(50, 26, 40),
		ElementHover = Color3.fromRGB(64, 34, 52),
		Accent = Color3.fromRGB(244, 114, 182),
		Text = Color3.fromRGB(255, 241, 250),
		SubText = Color3.fromRGB(200, 160, 180),
		Stroke = Color3.fromRGB(80, 45, 65),
		Success = Color3.fromRGB(52, 211, 153),
	},
	Gold = {
		Background = Color3.fromRGB(24, 20, 12),
		Topbar = Color3.fromRGB(36, 30, 16),
		Element = Color3.fromRGB(44, 36, 20),
		ElementHover = Color3.fromRGB(58, 48, 28),
		Accent = Color3.fromRGB(234, 179, 8),
		Text = Color3.fromRGB(254, 249, 195),
		SubText = Color3.fromRGB(190, 170, 120),
		Stroke = Color3.fromRGB(80, 65, 30),
		Success = Color3.fromRGB(132, 204, 22),
	},
}

local THEME_OPTIONS = {
	"Midnight",
	"Ocean",
	"Crimson",
	"Emerald",
	"Amethyst",
	"Sunset",
	"Snow",
	"Cyber",
	"Rose",
	"Gold",
}

local THEME = {}
do
	local preset = THEME_PRESETS[CONFIG.ThemeName] or THEME_PRESETS.Midnight
	for key, value in preset do
		THEME[key] = value
	end
end

local menuFrame = Instance.new("Frame")
menuFrame.Name = "RayfieldStyleMenu"
menuFrame.AnchorPoint = Vector2.new(0, 0.5)
menuFrame.Position = UDim2.new(0, 24, 0.5, 0)
menuFrame.Size = UDim2.fromOffset(420, 520)
menuFrame.BackgroundColor3 = THEME.Background
menuFrame.BorderSizePixel = 0
menuFrame.ZIndex = 50
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Selectable = false
menuFrame:SetAttribute("ThemeRole", "Background")
menuFrame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "NameHubToggle"
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

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = THEME.Stroke
menuStroke.Thickness = 1
menuStroke:SetAttribute("ThemeRole", "Stroke")
menuStroke.Parent = menuFrame

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 44)
topbar.BackgroundColor3 = THEME.Topbar
topbar.BorderSizePixel = 0
topbar.ZIndex = 51
topbar:SetAttribute("ThemeRole", "Topbar")
topbar.Parent = menuFrame

local topbarCorner = Instance.new("UICorner")
topbarCorner.CornerRadius = UDim.new(0, 10)
topbarCorner.Parent = topbar

local topbarFix = Instance.new("Frame")
topbarFix.Size = UDim2.new(1, 0, 0, 14)
topbarFix.Position = UDim2.new(0, 0, 1, -14)
topbarFix.BackgroundColor3 = THEME.Topbar
topbarFix.BorderSizePixel = 0
topbarFix.ZIndex = 51
topbarFix:SetAttribute("ThemeRole", "Topbar")
topbarFix.Parent = topbar

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(14, 0)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "NameHub · Arsenal"
titleLabel.TextColor3 = THEME.Text
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 52
titleLabel:SetAttribute("ThemeRole", "Text")
titleLabel.Parent = topbar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Position = UDim2.fromOffset(14, 22)
subtitleLabel.Size = UDim2.new(1, -60, 0, 16)
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "Studio test · RightShift = toggle · Insert = menu"
subtitleLabel.TextColor3 = THEME.SubText
subtitleLabel.TextSize = 11
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 52
subtitleLabel:SetAttribute("ThemeRole", "SubText")
subtitleLabel.Parent = topbar

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.Size = UDim2.fromOffset(28, 28)
closeButton.BackgroundColor3 = THEME.Element
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = THEME.Text
closeButton.TextSize = 12
closeButton.ZIndex = 52
closeButton:SetAttribute("ThemeRole", "Element")
closeButton:SetAttribute("ThemeTextRole", "Text")
closeButton.Parent = topbar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Position = UDim2.fromOffset(10, 48)
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 51
tabBar.Parent = menuFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local pagesHost = Instance.new("Frame")
pagesHost.Name = "PagesHost"
pagesHost.Position = UDim2.fromOffset(0, 84)
pagesHost.Size = UDim2.new(1, 0, 1, -92)
pagesHost.BackgroundTransparency = 1
pagesHost.ZIndex = 50
pagesHost.Parent = menuFrame

local pages= {}
local tabButtons= {}
local tabCount = 0
local controlsParent= nil
local layoutOrder = 0

local function nextOrder()
	layoutOrder += 1
	return layoutOrder
end

local function createPage(id)
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. id
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = THEME.Accent
	page:SetAttribute("ThemeRole", "AccentScroll")
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 50
	page.Active = true
	page.ScrollingEnabled = true
	page.Parent = pagesHost
	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page
	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingTop = UDim.new(0, 8)
	pagePad.PaddingBottom = UDim.new(0, 12)
	pagePad.PaddingLeft = UDim.new(0, 12)
	pagePad.PaddingRight = UDim.new(0, 12)
	pagePad.Parent = page
	pages[id] = page
	return page
end

local selectedTabId = "Main"

local function selectTab(id)
	selectedTabId = id
	for name, page in pages do
		page.Visible = name == id
	end
	for name, btn in tabButtons do
		local active = name == id
		btn.BackgroundColor3 = if active then THEME.Accent else THEME.Element
		btn.TextColor3 = if active then Color3.fromRGB(255, 255, 255) else THEME.Text
		btn:SetAttribute("ThemeRole", if active then "Accent" else "Element")
		btn:SetAttribute("ThemeTextRole", if active then "White" else "Text")
	end
	controlsParent = pages[id]
end

local function createTab(id, label, order)
	tabCount += 1
	createPage(id)
	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. id
	btn.BackgroundColor3 = THEME.Element
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.Text = label
	btn.TextColor3 = THEME.Text
	btn.TextSize = 10
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	btn.ZIndex = 52
	btn:SetAttribute("ThemeRole", "Element")
	btn:SetAttribute("ThemeTextRole", "Text")
	btn.Parent = tabBar
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
	btn.Size = UDim2.new(1 / math.max(tabCount, 1), -4, 1, 0)
	tabButtons[id] = btn
	btn.MouseButton1Click:Connect(function()
		selectTab(id)
	end)
end

createTab("Main", "Main", 1)
createTab("Aim", "Aim", 2)
createTab("Filters", "Filter", 3)
createTab("ESP", "ESP", 4)
createTab("Movement", "Move", 5)
createTab("Settings", "Settings", 6)
createTab("Configs", "Configs", 7)

local function refreshTabBarLayout()
	local n = math.max(tabCount, 1)
	for _, btn in tabButtons do
		btn.Size = UDim2.new(1 / n, -4, 1, 0)
	end
end
refreshTabBarLayout()

local tryAutoLoadActiveConfig
local saveNameHubProfile
local loadNameHubProfile
local deleteNameHubProfile
local duplicateNameHubProfile
local refreshConfigProfileUI
tryAutoLoadActiveConfig = function() end
saveNameHubProfile = function(_name)
	return false
end
loadNameHubProfile = function(_name)
	return false
end
deleteNameHubProfile = function(_name)
	return false
end
duplicateNameHubProfile = function(_from, _to)
	return false
end
refreshConfigProfileUI = function() end

local configNameBox= nil
local configActiveLabel= nil
local configProfileListHost= nil
local configSelectedProfile = ""

local function createSection(title)
	local section = Instance.new("Frame")
	section.Name = "Section_" .. title
	section.BackgroundTransparency = 1
	section.Size = UDim2.new(1, 0, 0, 22)
	section.LayoutOrder = nextOrder()
	section.ZIndex = 51
	section.Parent = controlsParent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = title
	label.TextColor3 = THEME.Accent
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 51
	label:SetAttribute("ThemeRole", "Accent")
	label.Parent = section
	return section
end

local function createElementShell(height)
	local shell = Instance.new("Frame")
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.Size = UDim2.new(1, 0, 0, height)
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 51
	shell.Active = true
	shell:SetAttribute("ThemeRole", "Element")
	shell.Parent = controlsParent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	return shell
end

local function bindConnection(connection)
	table.insert(scriptConnections, connection)
	return connection
end

local function createActionButton(
	name,
	description,
	buttonText,
	accent,
	callback
)
	local shell = createElementShell(54)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -120, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -120, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel:SetAttribute("ThemeRole", "SubText")
	descLabel.Parent = shell
	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -12, 0.5, 0)
	button.Size = UDim2.fromOffset(100, 28)
	button.BackgroundColor3 = accent
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamBold
	button.Text = buttonText
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 12
	button.ZIndex = 52
	button.Parent = shell
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	button.MouseButton1Click:Connect(function()
		callback()
		notify(name, buttonText)
	end)
	return button
end

local function createToggle(name, description, initial, callback)
	local shell = createElementShell(54)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -70, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -70, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel:SetAttribute("ThemeRole", "SubText")
	descLabel.Parent = shell
	local switch = Instance.new("Frame")
	switch.Name = "Switch"
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -12, 0.5, 0)
	switch.Size = UDim2.fromOffset(42, 22)
	switch.BackgroundColor3 = if initial then THEME.Success else Color3.fromRGB(60, 60, 65)
	switch.BorderSizePixel = 0
	switch.ZIndex = 54
	switch:SetAttribute("ThemeRole", if initial then "Success" else "ToggleOff")
	switch.Parent = shell
	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switch
	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = if initial then UDim2.new(1, -20, 0.5, 0) else UDim2.fromOffset(2, 11)
	knob.Size = UDim2.fromOffset(18, 18)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 55
	knob.Parent = switch
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	-- Invisible full-row hit target (Arsenal often eats small switch clicks)
	local hit = Instance.new("TextButton")
	hit.Name = "Hit"
	hit.BackgroundTransparency = 1
	hit.Size = UDim2.fromScale(1, 1)
	hit.Text = ""
	hit.ZIndex = 60
	hit.AutoButtonColor = false
	hit.Active = true
	hit.Parent = shell
	local state = initial
	local lastFire = 0
	local function applyVisual()
		switch.BackgroundColor3 = if state then THEME.Success else Color3.fromRGB(60, 60, 65)
		switch:SetAttribute("ThemeRole", if state then "Success" else "ToggleOff")
		knob.Position = if state then UDim2.new(1, -20, 0.5, 0) else UDim2.fromOffset(2, 11)
	end
	local function fireToggle()
		local now = os.clock()
		if now - lastFire < 0.12 then
			return
		end
		lastFire = now
		state = not state
		applyVisual()
		local ok, err = pcall(callback, state)
		if not ok then
			logError("Toggle", err, name)
			state = not state
			applyVisual()
			notify(name, "Error — see F9 console")
			return
		end
		logInfo("Toggle", name .. " = " .. tostring(state))
		notify(name, if state then "Enabled" else "Disabled")
	end
	hit.MouseButton1Click:Connect(fireToggle)
	return {
		Set = function(value)
			state = value
			applyVisual()
		end,
	}
end

local function createSlider(name, description, min, max, initial, decimals, callback)
	local shell = createElementShell(72)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -70, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell
	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -12, 0, 8)
	valueLabel.Size = UDim2.fromOffset(56, 18)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.ZIndex = 52
	valueLabel:SetAttribute("ThemeRole", "Accent")
	valueLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -24, 0, 14)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel:SetAttribute("ThemeRole", "SubText")
	descLabel.Parent = shell
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(12, 52)
	track.Size = UDim2.new(1, -24, 0, 8)
	track.BackgroundColor3 = Color3.fromRGB(50, 52, 56)
	track.BorderSizePixel = 0
	track.ZIndex = 52
	track.Parent = shell
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 53
	fill:SetAttribute("ThemeRole", "Accent")
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	local function formatValue(v)
		if decimals <= 0 then
			return tostring(math.floor(v + 0.5))
		end
		local mult = 10 ^ decimals
		return string.format("%." .. decimals .. "f", math.floor(v * mult + 0.5) / mult)
	end
	local function setFromAlpha(alpha)
		alpha = math.clamp(alpha, 0, 1)
		local value = min + (max - min) * alpha
		if decimals <= 0 then
			value = math.floor(value + 0.5)
		else
			local mult = 10 ^ decimals
			value = math.floor(value * mult + 0.5) / mult
		end
		fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
		valueLabel.Text = formatValue(value)
		callback(value)
	end
	setFromAlpha((initial - min) / (max - min))
	local dragging = false
	local lastNotified= nil
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setFromAlpha(rel)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
			setFromAlpha(rel)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				local shown = valueLabel.Text
				if shown ~= lastNotified then
					lastNotified = shown
					notify(name, shown)
				end
			end
		end
	end)
	return {
		Set = function(value)
			setFromAlpha((value - min) / (max - min))
		end,
	}
end

local openDropdownCloser = nil

local function createDropdown(name, description, options, initial, callback)
	local ROW = 28
	local listMax = math.min(#options * ROW + 6, 154)
	local shell = createElementShell(54)
	local index = table.find(options, initial) or 1
	local isOpen = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -132, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -132, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel:SetAttribute("ThemeRole", "SubText")
	descLabel.Parent = shell

	local trigger = Instance.new("TextButton")
	trigger.Name = "DropdownTrigger"
	trigger.AnchorPoint = Vector2.new(1, 0)
	trigger.Position = UDim2.new(1, -12, 0, 12)
	trigger.Size = UDim2.fromOffset(118, 30)
	trigger.BackgroundColor3 = THEME.Topbar
	trigger.BorderSizePixel = 0
	trigger.AutoButtonColor = false
	trigger.Font = Enum.Font.GothamMedium
	trigger.Text = ""
	trigger.TextColor3 = THEME.Text
	trigger.TextSize = 12
	trigger.ZIndex = 53
	trigger:SetAttribute("ThemeRole", "Topbar")
	trigger:SetAttribute("ThemeTextRole", "Text")
	trigger.Parent = shell
	local triggerCorner = Instance.new("UICorner")
	triggerCorner.CornerRadius = UDim.new(0, 6)
	triggerCorner.Parent = trigger

	local triggerLabel = Instance.new("TextLabel")
	triggerLabel.BackgroundTransparency = 1
	triggerLabel.Position = UDim2.fromOffset(8, 0)
	triggerLabel.Size = UDim2.new(1, -28, 1, 0)
	triggerLabel.Font = Enum.Font.GothamMedium
	triggerLabel.Text = options[index]
	triggerLabel.TextColor3 = THEME.Text
	triggerLabel.TextSize = 12
	triggerLabel.TextXAlignment = Enum.TextXAlignment.Left
	triggerLabel.ZIndex = 54
	triggerLabel:SetAttribute("ThemeRole", "Text")
	triggerLabel.Parent = trigger

	local chevron = Instance.new("TextLabel")
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -6, 0.5, 0)
	chevron.Size = UDim2.fromOffset(16, 16)
	chevron.Font = Enum.Font.GothamBold
	chevron.Text = "▾"
	chevron.TextColor3 = THEME.SubText
	chevron.TextSize = 12
	chevron.ZIndex = 54
	chevron:SetAttribute("ThemeRole", "SubText")
	chevron.Parent = trigger

	local list = Instance.new("ScrollingFrame")
	list.Name = "DropdownList"
	list.Visible = false
	list.Position = UDim2.fromOffset(12, 50)
	list.Size = UDim2.new(1, -24, 0, listMax)
	list.BackgroundColor3 = THEME.Topbar
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = THEME.Accent
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ZIndex = 60
	list:SetAttribute("ThemeRole", "Topbar")
	list.Parent = shell
	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 6)
	listCorner.Parent = list
	local listStroke = Instance.new("UIStroke")
	listStroke.Color = THEME.Stroke
	listStroke.Thickness = 1
	listStroke:SetAttribute("ThemeRole", "Stroke")
	listStroke.Parent = list
	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop = UDim.new(0, 4)
	listPad.PaddingBottom = UDim.new(0, 4)
	listPad.PaddingLeft = UDim.new(0, 4)
	listPad.PaddingRight = UDim.new(0, 4)
	listPad.Parent = list
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 2)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = list

	local optionButtons= {}

	local function refreshOptionStyles()
		for i, btn in optionButtons do
			local selected = i == index
			btn.BackgroundColor3 = if selected then THEME.Accent else THEME.Element
			btn.TextColor3 = if selected then Color3.fromRGB(255, 255, 255) else THEME.Text
			btn:SetAttribute("ThemeRole", if selected then "Accent" else "Element")
			btn:SetAttribute("ThemeTextRole", if selected then "White" else "Text")
		end
	end

	local function setOpen(state)
		if state and openDropdownCloser then
			openDropdownCloser()
		end
		isOpen = state
		list.Visible = state
		shell.Size = UDim2.new(1, 0, 0, if state then 54 + listMax + 10 else 54)
		chevron.Text = if state then "▴" else "▾"
		if state then
			openDropdownCloser = function()
				isOpen = false
				list.Visible = false
				shell.Size = UDim2.new(1, 0, 0, 54)
				chevron.Text = "▾"
				openDropdownCloser = nil
			end
		else
			openDropdownCloser = nil
		end
	end

	local function choose(i)
		index = i
		triggerLabel.Text = options[index]
		refreshOptionStyles()
		setOpen(false)
		callback(options[index])
		notify(name, options[index])
	end

	for i, option in options do
		local btn = Instance.new("TextButton")
		btn.Name = "Option_" .. option
		btn.Size = UDim2.new(1, 0, 0, ROW - 2)
		btn.BackgroundColor3 = THEME.Element
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.Gotham
		btn.Text = option
		btn.TextColor3 = THEME.Text
		btn.TextSize = 12
		btn.LayoutOrder = i
		btn.ZIndex = 61
		btn:SetAttribute("ThemeRole", "Element")
		btn:SetAttribute("ThemeTextRole", "Text")
		btn.Parent = list
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = btn
		btn.MouseButton1Click:Connect(function()
			choose(i)
		end)
		table.insert(optionButtons, btn)
	end
	refreshOptionStyles()

	trigger.MouseButton1Click:Connect(function()
		setOpen(not isOpen)
	end)
end

local COLOR_PRESET_ORDER = {
	"Red",
	"Orange",
	"Yellow",
	"Lime",
	"Green",
	"Cyan",
	"Sky",
	"Blue",
	"Purple",
	"Pink",
	"Magenta",
	"White",
	"Gray",
	"Black",
	"Gold",
}

local COLOR_PRESETS= {
	Red = Color3.fromRGB(255, 70, 70),
	Orange = Color3.fromRGB(255, 140, 50),
	Yellow = Color3.fromRGB(255, 220, 60),
	Lime = Color3.fromRGB(170, 255, 50),
	Green = Color3.fromRGB(60, 220, 100),
	Cyan = Color3.fromRGB(50, 230, 230),
	Sky = Color3.fromRGB(80, 170, 255),
	Blue = Color3.fromRGB(70, 110, 255),
	Purple = Color3.fromRGB(170, 90, 255),
	Pink = Color3.fromRGB(255, 120, 200),
	Magenta = Color3.fromRGB(255, 60, 180),
	White = Color3.fromRGB(245, 245, 250),
	Gray = Color3.fromRGB(160, 160, 170),
	Black = Color3.fromRGB(30, 30, 35),
	Gold = Color3.fromRGB(255, 200, 60),
}

local function nearestColorPreset(color)
	local bestName = "Red"
	local bestDist = math.huge
	for name, preset in COLOR_PRESETS do
		local dr = preset.R - color.R
		local dg = preset.G - color.G
		local db = preset.B - color.B
		local dist = dr * dr + dg * dg + db * db
		if dist < bestDist then
			bestDist = dist
			bestName = name
		end
	end
	return bestName
end

local function createColorOption(name, description, initial, onChanged)
	local current = initial
	createDropdown(name, description, COLOR_PRESET_ORDER, nearestColorPreset(initial), function(presetName)
		local color = COLOR_PRESETS[presetName] or current
		current = color
		onChanged(color)
	end)
end

--[[ One ESP visual: enable toggle + color dropdown + rainbow toggle ]]
local function enableEspMaster()
	if CONFIG.ESPEnabled then
		return
	end
	CONFIG.ESPEnabled = true
	if toggleUI.espMaster then
		toggleUI.espMaster.Set(true)
	end
	notify("ESP", "Master enabled")
end

local function createEspFeature(
	name,
	description,
	enabled,
	onEnabled,
	color,
	onColor,
	rainbow,
	onRainbow
)
	createToggle(name, description, enabled, function(value)
		onEnabled(value)
		if value then
			enableEspMaster()
		end
	end)
	createColorOption(name .. " Color", "Color when rainbow is off", color, onColor)
	createToggle(name .. " Rainbow", "Rainbow cycle for " .. string.lower(name) .. " only", rainbow, onRainbow)
end

local listeningForKeybind = nil

local function isMouseBindInput(inputType)
	return inputType == Enum.UserInputType.MouseButton1
		or inputType == Enum.UserInputType.MouseButton2
		or inputType == Enum.UserInputType.MouseButton3
end

local function formatInputBindLabel(key, mouse)
	if mouse then
		if mouse == Enum.UserInputType.MouseButton1 then
			return "LMB"
		elseif mouse == Enum.UserInputType.MouseButton2 then
			return "RMB"
		elseif mouse == Enum.UserInputType.MouseButton3 then
			return "MMB"
		end
		return mouse.Name
	end
	return key.Name
end

local function inputMatchesAimBind(input)
	if CONFIG.ToggleMouse then
		return input.UserInputType == CONFIG.ToggleMouse
	end
	if CONFIG.ToggleKey == Enum.KeyCode.Unknown then
		return false
	end
	return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.ToggleKey
end

local function createKeybind(name, description, initial, onChanged)
	local shell = createElementShell(54)
	local currentKey = initial
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -120, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -120, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel:SetAttribute("ThemeRole", "SubText")
	descLabel.Parent = shell
	local bindButton = Instance.new("TextButton")
	bindButton.AnchorPoint = Vector2.new(1, 0.5)
	bindButton.Position = UDim2.new(1, -12, 0.5, 0)
	bindButton.Size = UDim2.fromOffset(110, 28)
	bindButton.BackgroundColor3 = THEME.Topbar
	bindButton.BorderSizePixel = 0
	bindButton.Font = Enum.Font.GothamBold
	bindButton.Text = currentKey.Name
	bindButton.TextColor3 = THEME.Text
	bindButton.TextSize = 12
	bindButton.ZIndex = 52
	bindButton:SetAttribute("ThemeRole", "Topbar")
	bindButton:SetAttribute("ThemeTextRole", "Text")
	bindButton.Parent = shell
	local bindCorner = Instance.new("UICorner")
	bindCorner.CornerRadius = UDim.new(0, 6)
	bindCorner.Parent = bindButton
	local function showCurrent()
		bindButton.Text = currentKey.Name
		bindButton.TextColor3 = THEME.Text
	end
	bindButton.MouseButton1Click:Connect(function()
		bindButton.Text = "..."
		bindButton.TextColor3 = THEME.Accent
		listeningForKeybind = {
			applyKey = function(keyCode)
				currentKey = keyCode
				showCurrent()
				listeningForKeybind = nil
				onChanged(keyCode)
				notify(name, "Bound to " .. keyCode.Name)
			end,
			cancel = function()
				showCurrent()
				listeningForKeybind = nil
			end,
		}
	end)
end

local function createInputBind(
	name,
	description,
	initialKey,
	initialMouse,
	onChanged
)
	local shell = createElementShell(54)
	local currentKey = initialKey
	local currentMouse = initialMouse
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -120, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -120, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 52
	descLabel:SetAttribute("ThemeRole", "SubText")
	descLabel.Parent = shell
	local bindButton = Instance.new("TextButton")
	bindButton.AnchorPoint = Vector2.new(1, 0.5)
	bindButton.Position = UDim2.new(1, -12, 0.5, 0)
	bindButton.Size = UDim2.fromOffset(110, 28)
	bindButton.BackgroundColor3 = THEME.Topbar
	bindButton.BorderSizePixel = 0
	bindButton.Font = Enum.Font.GothamBold
	bindButton.Text = formatInputBindLabel(currentKey, currentMouse)
	bindButton.TextColor3 = THEME.Text
	bindButton.TextSize = 12
	bindButton.ZIndex = 52
	bindButton:SetAttribute("ThemeRole", "Topbar")
	bindButton:SetAttribute("ThemeTextRole", "Text")
	bindButton.Parent = shell
	local bindCorner = Instance.new("UICorner")
	bindCorner.CornerRadius = UDim.new(0, 6)
	bindCorner.Parent = bindButton
	local function showCurrent()
		bindButton.Text = formatInputBindLabel(currentKey, currentMouse)
		bindButton.TextColor3 = THEME.Text
	end
	bindButton.MouseButton1Click:Connect(function()
		bindButton.Text = "..."
		bindButton.TextColor3 = THEME.Accent
		listeningForKeybind = {
			applyKey = function(keyCode)
				currentKey = keyCode
				currentMouse = nil
				showCurrent()
				listeningForKeybind = nil
				onChanged(currentKey, currentMouse)
				notify(name, "Bound to " .. keyCode.Name)
			end,
			applyMouse = function(mouseType)
				currentMouse = mouseType
				currentKey = Enum.KeyCode.Unknown
				showCurrent()
				listeningForKeybind = nil
				onChanged(currentKey, currentMouse)
				notify(name, "Bound to " .. formatInputBindLabel(currentKey, currentMouse))
			end,
			cancel = function()
				showCurrent()
				listeningForKeybind = nil
			end,
		}
	end)
end

local function setMenuVisible(visible)
	menuOpen = visible
	menuFrame.Visible = visible
	if toggleButton then
		toggleButton.Text = if visible then "NH ✕" else "NH ▶"
		toggleButton.BackgroundColor3 = if visible then THEME.Accent else THEME.Topbar
	end
	forceMenuCursor(visible)
	if visible then
		-- Re-parent in case the game wiped PlayerGui / CoreGui children
		if not screenGui.Parent then
			resolveHudParent()
		end
		screenGui.Enabled = true
		menuFrame.Active = true
	end
end

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

toggleButton.MouseButton1Click:Connect(function()
	setMenuVisible(not menuOpen)
	notify("Menu", if menuOpen then "Opened" else "Closed")
end)

do
	local dragging = false
	local dragStart= nil
	local startPos= nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = menuFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not dragStart or not startPos then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			menuFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function beginPage(id)
	controlsParent = pages[id]
	layoutOrder = 0
end

local function applyTheme(themeName)
	local preset = THEME_PRESETS[themeName]
	if not preset then
		return
	end
	CONFIG.ThemeName = themeName
	for key, value in preset do
		THEME[key] = value
	end

	local function colorForRole(role)
		if role == "Background" then
			return THEME.Background
		elseif role == "Topbar" then
			return THEME.Topbar
		elseif role == "Element" then
			return THEME.Element
		elseif role == "Accent" then
			return THEME.Accent
		elseif role == "Text" then
			return THEME.Text
		elseif role == "SubText" then
			return THEME.SubText
		elseif role == "Stroke" then
			return THEME.Stroke
		elseif role == "Success" then
			return THEME.Success
		elseif role == "ToggleOff" then
			return Color3.fromRGB(60, 60, 65)
		elseif role == "White" then
			return Color3.fromRGB(255, 255, 255)
		end
		return nil
	end

	local function paint(inst)
		local role = inst:GetAttribute("ThemeRole")
		if typeof(role) == "string" then
			if role == "AccentScroll" and inst:IsA("ScrollingFrame") then
				inst.ScrollBarImageColor3 = THEME.Accent
			elseif inst:IsA("UIStroke") then
				local c = colorForRole(role)
				if c then
					inst.Color = c
				end
			elseif inst:IsA("GuiObject") then
				local c = colorForRole(role)
				if c and inst.BackgroundTransparency < 1 then
					inst.BackgroundColor3 = c
				end
				if (inst:IsA("TextLabel") or inst:IsA("TextButton")) and inst.BackgroundTransparency >= 1 then
					if role == "Text" or role == "SubText" or role == "White" or role == "Accent" then
						local tc = colorForRole(role)
						if tc then
							inst.TextColor3 = tc
						end
					end
				end
			end
		end

		local textRole = inst:GetAttribute("ThemeTextRole")
		if typeof(textRole) == "string" and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
			local tc = colorForRole(textRole)
			if tc then
				inst.TextColor3 = tc
			end
		end
	end

	paint(menuFrame)
	for _, d in menuFrame:GetDescendants() do
		paint(d)
	end
	-- Keep active tab styling correct
	selectTab(selectedTabId)
end

beginPage("Main")
createSection("MAIN")
local enableToggle = createToggle("Aim Assist", "Master enable / disable", enabled, function(value)
	enabled = value
	currentTarget = nil
	lockedTarget = nil
	aimLookAt = nil
	setAimCameraActive(false)
	if not enabled then
		fovCircle.Visible = false
		targetMarker.Visible = false
	elseif menuOpen then
		notify("Aim Assist", "Enabled — close menu or look at enemies")
	end
end)
toggleUI.aimAssist = enableToggle
toggleUI.noclip = createToggle("Noclip", "Walk through walls while enabled", noclipEnabled, function(value)
	if setNoclipEnabled then
		setNoclipEnabled(value)
	else
		noclipEnabled = value
	end
end)
toggleUI.thirdPerson = createToggle("Third Person", "Zoom-out camera behind your character", CONFIG.ThirdPersonEnabled, function(value)
	if setThirdPersonEnabled then
		setThirdPersonEnabled(value)
	else
		CONFIG.ThirdPersonEnabled = value
	end
end)
createKeybind("Third Person Key", "Key to toggle third person on/off", CONFIG.ThirdPersonKey, function(keyCode)
	CONFIG.ThirdPersonKey = keyCode
end)
createSlider("Third Person Distance", "Default zoom · scroll wheel in 3rd person", 12, 80, CONFIG.ThirdPersonDistance, 0, function(value)
	CONFIG.ThirdPersonDistance = value
	if CONFIG.ThirdPersonEnabled then
		updateThirdPerson()
	end
end)
createSection("SPIN BOT")
toggleUI.spinBot = createToggle("Spin Bot", "Anti-aim spin — Third Person only", CONFIG.SpinBotEnabled, function(value)
	if setSpinBotEnabled then
		setSpinBotEnabled(value)
	else
		CONFIG.SpinBotEnabled = value
	end
end)
createSlider("Spin Speed", "Spin rate in degrees per second", 120, 1440, CONFIG.SpinBotSpeed, 0, function(value)
	CONFIG.SpinBotSpeed = value
end)
createToggle("Spin Jitter", "Random speed wobble so aim is harder to track", CONFIG.SpinBotJitter, function(value)
	CONFIG.SpinBotJitter = value
end)
createToggle("Anti-Aim Pitch", "Tilt up/down while spinning", CONFIG.SpinBotAntiAim, function(value)
	CONFIG.SpinBotAntiAim = value
end)
toggleUI.rapidFire = createToggle("Rapid Fire", "Hold LMB to spray faster while ON", CONFIG.RapidFireEnabled, function(value)
	CONFIG.RapidFireEnabled = value
	refreshRapidFireStats()
end)
createSlider(
	"Fire Rate",
	"Higher = faster · Hold LMB while Rapid Fire is ON",
	1,
	30,
	CONFIG.RapidFireRate,
	0,
	function(value)
		CONFIG.RapidFireRate = value
		if CONFIG.RapidFireEnabled then
			refreshRapidFireStats()
		end
	end
)
beginPage("Aim")
createSection("AIM")
createInputBind(
	"Aimbot Keybind",
	"Keyboard · LMB · RMB — Hold mode locks while pressed",
	CONFIG.ToggleKey,
	CONFIG.ToggleMouse,
	function(keyCode, mouseType)
		CONFIG.ToggleKey = keyCode
		CONFIG.ToggleMouse = mouseType
	end
)
createDropdown(
	"Aim Mode",
	"Hold = lock while key held · Toggle = press to switch",
	AIM_MODE_OPTIONS,
	CONFIG.AimActivationMode,
	function(value)
		CONFIG.AimActivationMode = value
		if value == "Hold" and enabled then
			enabled = false
			enableToggle.Set(false)
			currentTarget = nil
			lockedTarget = nil
			aimLookAt = nil
			setAimCameraActive(false)
			fovCircle.Visible = false
			targetMarker.Visible = false
		end
	end
)
createToggle("Click Fire", "LMB fires your gun while locked on (Arsenal)", CONFIG.AimClickFire, function(value)
	CONFIG.AimClickFire = value
end)
createSlider("FOV Radius", "Pixel radius around the cursor", 20, 400, CONFIG.FOVRadius, 0, function(value)
	CONFIG.FOVRadius = value
	refreshOverlayFromConfig()
end)
createSlider("Smoothness", "Higher = harder lock (0.95+ = snap)", 0.05, 1, CONFIG.Smoothness, 2, function(value)
	CONFIG.Smoothness = value
end)
createSlider("Max Distance", "Ignore targets beyond this (studs)", 50, 1000, CONFIG.MaxWorldDistance, 0, function(value)
	CONFIG.MaxWorldDistance = value
end)
createDropdown("Target Part", "Aim point on the character", TARGET_PART_OPTIONS, CONFIG.TargetPartName, function(value)
	CONFIG.TargetPartName = value
end)
createDropdown("Ray Origin", "Where LOS ray starts from", TARGET_PART_OPTIONS, CONFIG.RaycastOriginPart, function(value)
	CONFIG.RaycastOriginPart = value
end)

createSection("SILENT AIM")
toggleUI.silentAim = createToggle("Silent Aim", "Per-shot FOV redirect — no lock, each shot picks closest in FOV", silentAimEnabled, function(value)
	if setSilentAimEnabled then
		setSilentAimEnabled(value)
	else
		silentAimEnabled = value
	end
end)
createKeybind("Silent Aim Key", "Toggle silent aim on/off", CONFIG.SilentAimKey, function(keyCode)
	CONFIG.SilentAimKey = keyCode
end)
createToggle("Click Fire", "Left click fires hitscan at silent target", CONFIG.SilentAimClickFire, function(value)
	CONFIG.SilentAimClickFire = value
end)
createToggle("Silent Marker", "Show purple marker on silent target", CONFIG.SilentAimShowMarker, function(value)
	CONFIG.SilentAimShowMarker = value
	if not value then
		silentMarker.Visible = false
	end
end)
createToggle("Show Tracer", "Brief line when you silent-fire", CONFIG.SilentAimShowTracer, function(value)
	CONFIG.SilentAimShowTracer = value
end)
createSlider("Fire Cooldown", "Seconds between silent shots", 0.05, 0.5, CONFIG.SilentAimFireCooldown, 2, function(value)
	CONFIG.SilentAimFireCooldown = value
end)

beginPage("Filters")
createSection("FILTERS")
createToggle("Team Check", "Skip teammates (uses Team + TeamColor for Arsenal)", CONFIG.TeamCheckEnabled, function(value)
	CONFIG.TeamCheckEnabled = value
	if value then
		currentTarget = nil
		lockedTarget = nil
	end
end)
createToggle("Ignore Neutral Teams", "Allow targets with no team", CONFIG.IgnoreNeutralTeams, function(value)
	CONFIG.IgnoreNeutralTeams = value
end)
createToggle("Line of Sight", "Require clear Raycast to target", CONFIG.RequireLineOfSight, function(value)
	CONFIG.RequireLineOfSight = value
end)
createSection("WEAPONS")
toggleUI.rainbowWeapons = createToggle(
	"Rainbow Weapons",
	"Rainbow guns, knives & held weapons — uses Rainbow Speed (ESP tab)",
	CONFIG.RainbowWeaponsEnabled,
	function(value)
		CONFIG.RainbowWeaponsEnabled = value
		if not value then
			pcall(restoreRainbowWeapons)
		end
	end
)

beginPage("ESP")
createSection("ESP")
toggleUI.espMaster = createToggle("ESP Enabled", "Master ESP on/off (deploy into a match to see players)", CONFIG.ESPEnabled, function(value)
	CONFIG.ESPEnabled = value
	if not value then
		clearAllEsp()
	end
end)
createToggle("ESP Team Check", "Hide ESP on teammates (turn off in Arsenal lobby)", CONFIG.ESPTeamCheck, function(value)
	CONFIG.ESPTeamCheck = value
end)
createSlider("ESP Max Distance", "Hide ESP beyond this range", 50, 1500, CONFIG.ESPMaxDistance, 0, function(value)
	CONFIG.ESPMaxDistance = value
end)
createToggle("Use Team Colors", "Enemy/team colors override feature colors (if rainbow off)", CONFIG.ESPUseTeamColors, function(value)
	CONFIG.ESPUseTeamColors = value
end)
createColorOption("Enemy Color", "Used when Use Team Colors is on", CONFIG.ESPEnemyColor, function(color)
	CONFIG.ESPEnemyColor = color
end)
createColorOption("Team Color", "Used when Use Team Colors is on", CONFIG.ESPTeamColor, function(color)
	CONFIG.ESPTeamColor = color
end)
createSlider("Rainbow Speed", "Speed for any feature rainbow", 0.2, 5, CONFIG.ESPRainbowSpeed, 1, function(value)
	CONFIG.ESPRainbowSpeed = value
end)
createToggle("Glow", "Pulse brightness on all ESP colors", CONFIG.ESPGlow, function(value)
	CONFIG.ESPGlow = value
end)
createSlider("Glow Speed", "How fast the glow pulses", 0.5, 6, CONFIG.ESPGlowSpeed, 1, function(value)
	CONFIG.ESPGlowSpeed = value
end)

createSection("Visuals")
createEspFeature(
	"Boxes",
	"2D box around players",
	CONFIG.ESPBoxes,
	function(value)
		CONFIG.ESPBoxes = value
	end,
	CONFIG.ESPBoxColor,
	function(color)
		CONFIG.ESPBoxColor = color
	end,
	CONFIG.ESPBoxRainbow,
	function(value)
		CONFIG.ESPBoxRainbow = value
	end
)
createEspFeature(
	"Skeleton",
	"Bone / stick-figure ESP",
	CONFIG.ESPSkeleton,
	function(value)
		CONFIG.ESPSkeleton = value
	end,
	CONFIG.ESPSkeletonColor,
	function(color)
		CONFIG.ESPSkeletonColor = color
	end,
	CONFIG.ESPSkeletonRainbow,
	function(value)
		CONFIG.ESPSkeletonRainbow = value
	end
)
createEspFeature(
	"Names",
	"Show player names",
	CONFIG.ESPNames,
	function(value)
		CONFIG.ESPNames = value
	end,
	CONFIG.ESPNameColor,
	function(color)
		CONFIG.ESPNameColor = color
	end,
	CONFIG.ESPNameRainbow,
	function(value)
		CONFIG.ESPNameRainbow = value
	end
)
createEspFeature(
	"Distance",
	"Show distance in studs",
	CONFIG.ESPDistance,
	function(value)
		CONFIG.ESPDistance = value
	end,
	CONFIG.ESPDistanceColor,
	function(color)
		CONFIG.ESPDistanceColor = color
	end,
	CONFIG.ESPDistanceRainbow,
	function(value)
		CONFIG.ESPDistanceRainbow = value
	end
)
createEspFeature(
	"Health Bar",
	"Health bar above players",
	CONFIG.ESPHealthBar,
	function(value)
		CONFIG.ESPHealthBar = value
	end,
	CONFIG.ESPHealthColor,
	function(color)
		CONFIG.ESPHealthColor = color
	end,
	CONFIG.ESPHealthRainbow,
	function(value)
		CONFIG.ESPHealthRainbow = value
	end
)
createEspFeature(
	"Highlights",
	"Colored outline through walls",
	CONFIG.ESPHighlights,
	function(value)
		CONFIG.ESPHighlights = value
	end,
	CONFIG.ESPHighlightColor,
	function(color)
		CONFIG.ESPHighlightColor = color
	end,
	CONFIG.ESPHighlightRainbow,
	function(value)
		CONFIG.ESPHighlightRainbow = value
	end
)
createEspFeature(
	"Tracers",
	"Line from screen bottom to player",
	CONFIG.ESPTracers,
	function(value)
		CONFIG.ESPTracers = value
	end,
	CONFIG.ESPTracerColor,
	function(color)
		CONFIG.ESPTracerColor = color
	end,
	CONFIG.ESPTracerRainbow,
	function(value)
		CONFIG.ESPTracerRainbow = value
	end
)

createSection("Aim Overlay")
createToggle("Show FOV Circle", "Draw circle around the mouse", CONFIG.ShowFOVCircle, function(value)
	CONFIG.ShowFOVCircle = value
	if not value then
		fovCircle.Visible = false
	end
end)
createToggle("Show Target Marker", "Highlight the locked target", CONFIG.ShowTargetMarker, function(value)
	CONFIG.ShowTargetMarker = value
	if not value then
		targetMarker.Visible = false
	end
end)
createSlider("FOV Thickness", "Circle outline thickness", 1, 6, CONFIG.FOVCircleThickness, 0, function(value)
	CONFIG.FOVCircleThickness = value
	refreshOverlayFromConfig()
end)
createSlider("FOV Transparency", "Circle outline transparency", 0, 0.9, CONFIG.FOVCircleTransparency, 2, function(value)
	CONFIG.FOVCircleTransparency = value
	refreshOverlayFromConfig()
end)

beginPage("Movement")
createSection("MOVEMENT")
toggleUI.speed = createToggle("Speed", "Faster walk and run", CONFIG.SpeedEnabled, function(value)
	CONFIG.SpeedEnabled = value
	applyMovementMods()
end)
createSlider("Walk Speed", "Studs per second while speed is ON", 16, 100, CONFIG.WalkSpeed, 0, function(value)
	CONFIG.WalkSpeed = value
	if CONFIG.SpeedEnabled then
		applyMovementMods()
	end
end)
toggleUI.jump = createToggle("Jump Height", "Higher jumps while enabled", CONFIG.JumpEnabled, function(value)
	CONFIG.JumpEnabled = value
	applyMovementMods()
end)
createSlider("Jump Height", "Jump power in studs (default ~7)", 7, 150, CONFIG.JumpHeight, 0, function(value)
	CONFIG.JumpHeight = value
	if CONFIG.JumpEnabled then
		applyMovementMods()
	end
end)

createSection("FLY")
toggleUI.fly = createToggle("Fly Enabled", "Toggle flight (also works mid-game)", flyEnabled, function(value)
	if setFlyEnabled then
		setFlyEnabled(value)
	else
		flyEnabled = value
	end
end)
createKeybind("Fly Keybind", "Key to toggle fly on/off", CONFIG.FlyKey, function(keyCode)
	CONFIG.FlyKey = keyCode
end)
createSlider("Fly Speed", "Studs per second while flying", 10, 250, CONFIG.FlySpeed, 0, function(value)
	CONFIG.FlySpeed = value
end)
createSlider("Fly Boost", "Speed multiplier while holding Shift", 1, 5, CONFIG.FlyBoostMultiplier, 1, function(value)
	CONFIG.FlyBoostMultiplier = value
end)
createSlider("Vertical Mult", "Up/down speed multiplier (Space / LeftCtrl)", 0.25, 3, CONFIG.FlyVerticalMultiplier, 2, function(value)
	CONFIG.FlyVerticalMultiplier = value
end)

beginPage("Settings")
createSection("DIAGNOSTICS")
do
	local shell = createElementShell(56)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(12, 8)
	title.Size = UDim2.new(1, -24, 0, 18)
	title.Font = Enum.Font.GothamMedium
	title.Text = "F9 Console Logs"
	title.TextColor3 = THEME.Text
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 52
	title:SetAttribute("ThemeRole", "Text")
	title.Parent = shell
	local desc = Instance.new("TextLabel")
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.fromOffset(12, 28)
	desc.Size = UDim2.new(1, -24, 0, 22)
	desc.Font = Enum.Font.Gotham
	desc.Text = "Always on — boot info, errors, and why features skip (no extra toggle)."
	desc.TextColor3 = THEME.SubText
	desc.TextSize = 11
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.ZIndex = 52
	desc:SetAttribute("ThemeRole", "SubText")
	desc.Parent = shell
end
createSection("KEYBINDS")
createKeybind("Menu Keybind", "Key to open/close this menu", CONFIG.MenuKey, function(keyCode)
	CONFIG.MenuKey = keyCode
end)
createKeybind("Noclip Keybind", "Key to toggle noclip on/off", CONFIG.NoclipKey, function(keyCode)
	CONFIG.NoclipKey = keyCode
end)
createSection("APPEARANCE")
createDropdown(
	"Theme",
	"Open the list and scroll — click a theme to apply",
	THEME_OPTIONS,
	CONFIG.ThemeName,
	function(value)
		applyTheme(value)
	end
)
createSection("COMMUNITY")
createActionButton(
	"Discord",
	"Copy invite link to join the community",
	"Open",
	Color3.fromRGB(88, 101, 242),
	function()
		local url = CONFIG.DiscordInviteUrl
		local copied = false
		pcall(function()
			local g = getgenv()
			if typeof(g.setclipboard) == "function" then
				g.setclipboard(url)
				copied = true
			elseif typeof(g.toclipboard) == "function" then
				g.toclipboard(url)
				copied = true
			end
			local opener = g.open_browser or g.open_webpage
			if typeof(opener) == "function" then
				opener(url)
			elseif typeof(g.syn) == "table" and typeof(g.syn.open_webpage) == "function" then
				g.syn.open_webpage(url)
			end
		end)
		print("[NameHub] Discord invite:", url, if copied then "(copied)" else "(copy from console)")
	end
)
createSection("SCRIPT")
createActionButton(
	"Unload",
	"Fully remove NameHub UI, ESP, fly, and hooks",
	"Unload",
	Color3.fromRGB(220, 70, 70),
	function()
		if unloadNameHub then
			unloadNameHub()
		end
	end
)

beginPage("Configs")
createSection("PROFILE")
do
	local shell = createElementShell(72)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -24, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = "Profile Name"
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 52
	nameLabel:SetAttribute("ThemeRole", "Text")
	nameLabel.Parent = shell
	local box = Instance.new("TextBox")
	box.Name = "ProfileName"
	box.Position = UDim2.fromOffset(12, 32)
	box.Size = UDim2.new(1, -24, 0, 28)
	box.BackgroundColor3 = THEME.Element
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.PlaceholderText = "e.g. Arsenal, Automatics, Legit"
	box.Text = "Default"
	box.TextColor3 = THEME.Text
	box.TextSize = 13
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.ZIndex = 52
	box:SetAttribute("ThemeRole", "Element")
	box:SetAttribute("ThemeTextRole", "Text")
	box.Parent = shell
	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 6)
	boxCorner.Parent = box
	local boxPad = Instance.new("UIPadding")
	boxPad.PaddingLeft = UDim.new(0, 8)
	boxPad.PaddingRight = UDim.new(0, 8)
	boxPad.Parent = box
	box.FocusLost:Connect(function()
		configSelectedProfile = box.Text
	end)
	configNameBox = box
end
do
	local shell = createElementShell(40)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 10)
	label.Size = UDim2.new(1, -24, 0, 20)
	label.Font = Enum.Font.Gotham
	label.Text = "Active profile: Default (not saved yet)"
	label.TextColor3 = THEME.SubText
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.ZIndex = 52
	label:SetAttribute("ThemeRole", "SubText")
	label.Parent = shell
	configActiveLabel = label
end

createSection("ACTIONS")
createActionButton(
	"Save Profile",
	"Save all toggles, sliders, colors, and keybinds under this name",
	"Save",
	Color3.fromRGB(60, 180, 100),
	function()
		local name = if configNameBox then string.gsub(configNameBox.Text, "^%s*(.-)%s*$", "%1") else "Default"
		if name == "" then
			notify("Configs", "Enter a profile name first")
			return
		end
		if saveNameHubProfile(name) then
			configSelectedProfile = name
			refreshConfigProfileUI()
		else
			notify("Configs", "Save failed — need executor file support")
		end
	end
)
createActionButton(
	"Load Profile",
	"Apply the named profile to NameHub",
	"Load",
	Color3.fromRGB(100, 120, 255),
	function()
		local name = if configNameBox then string.gsub(configNameBox.Text, "^%s*(.-)%s*$", "%1") else ""
		if name == "" then
			notify("Configs", "Enter or select a profile name")
			return
		end
		if loadNameHubProfile(name) then
			configSelectedProfile = name
			refreshConfigProfileUI()
		else
			notify("Configs", "Profile not found or invalid")
		end
	end
)
createActionButton(
	"Delete Profile",
	"Remove a saved profile from disk",
	"Delete",
	Color3.fromRGB(220, 70, 70),
	function()
		local name = if configNameBox then string.gsub(configNameBox.Text, "^%s*(.-)%s*$", "%1") else ""
		if name == "" then
			notify("Configs", "Enter or select a profile to delete")
			return
		end
		if deleteNameHubProfile(name) then
			if configSelectedProfile == name then
				configSelectedProfile = ""
			end
			refreshConfigProfileUI()
		else
			notify("Configs", "Could not delete profile")
		end
	end
)
createActionButton(
	"Duplicate Profile",
	"Copy the selected profile to a new name",
	"Copy",
	Color3.fromRGB(170, 110, 255),
	function()
		local fromName = if configNameBox then string.gsub(configNameBox.Text, "^%s*(.-)%s*$", "%1") else ""
		if fromName == "" then
			notify("Configs", "Select a profile to duplicate")
			return
		end
		local toName = fromName .. " Copy"
		local attempt = 1
		while not duplicateNameHubProfile(fromName, toName) and attempt < 8 do
			attempt += 1
			toName = fromName .. " Copy " .. tostring(attempt)
		end
		if attempt >= 8 then
			notify("Configs", "Duplicate failed")
			return
		end
		if configNameBox then
			configNameBox.Text = toName
		end
		configSelectedProfile = toName
		refreshConfigProfileUI()
	end
)

createSection("AUTO LOAD")
createToggle(
	"Auto Load On Join",
	"Automatically apply your active profile when NameHub starts",
	CONFIG.ConfigAutoLoad,
	function(value)
		CONFIG.ConfigAutoLoad = value
	end
)
createActionButton(
	"Set Active Profile",
	"Mark the named profile as auto-load target (also saves it)",
	"Set Active",
	Color3.fromRGB(56, 189, 248),
	function()
		local name = if configNameBox then string.gsub(configNameBox.Text, "^%s*(.-)%s*$", "%1") else ""
		if name == "" then
			notify("Configs", "Enter a profile name")
			return
		end
		if saveNameHubProfile(name) then
			configSelectedProfile = name
			refreshConfigProfileUI()
		else
			notify("Configs", "Could not set active profile")
		end
	end
)

createSection("SAVED PROFILES")
do
	local shell = createElementShell(160)
	local host = Instance.new("Frame")
	host.Name = "ProfileList"
	host.BackgroundTransparency = 1
	host.Position = UDim2.fromOffset(12, 8)
	host.Size = UDim2.new(1, -24, 1, -16)
	host.ZIndex = 52
	host.Parent = shell
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = host
	configProfileListHost = host
end

selectTab("Main")
setMenuVisible(true)
print("[NameHub] Menu ready — click green NH (left) or press Insert")

local function bootstrapGameplay()
local function aimShouldLock()
	if CONFIG.AimActivationMode == "Hold" then
		return enabled or aimKeyHeld
	end
	return enabled
end

local function getMouseViewportPosition()
	local mouse = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	return Vector2.new(mouse.X, mouse.Y - inset.Y)
end

local function viewportToOverlay(viewportPos)
	local inset = GuiService:GetGuiInset()
	return Vector2.new(viewportPos.X + inset.X, viewportPos.Y + inset.Y)
end

local function getAimScanPosition()
	camera = workspace.CurrentCamera
	-- Aim lock snaps the camera, so FOV is measured from screen center.
	if camera and aimShouldLock() and not menuOpen then
		return camera.ViewportSize * 0.5
	end
	return getMouseViewportPosition()
end

local function getSilentAimScanPosition()
	return getMouseViewportPosition()
end

local function getMouseScreenPosition()
	return viewportToOverlay(getAimScanPosition())
end

local function getCharacterPart(character, partName)
	local part = character:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

local function getTargetPart(character)
	return getCharacterPart(character, CONFIG.TargetPartName)
		or character:FindFirstChild("HumanoidRootPart") 
		or character:FindFirstChild("UpperTorso") 
end

local function getRaycastOrigin(character)
	local part = getCharacterPart(character, CONFIG.RaycastOriginPart)
		or character:FindFirstChild("Head") 
		or character:FindFirstChild("HumanoidRootPart") 
	return if part then part.Position else nil
end

local function isAlive(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return character:FindFirstChild("HumanoidRootPart") ~= nil
	end
	if humanoid.Health <= 0 then
		return false
	end
	local state = humanoid:GetState()
	return state ~= Enum.HumanoidStateType.Dead
end

local function isSameTeam(otherPlayer)
	if otherPlayer == localPlayer then
		return true
	end
	local myTeam = localPlayer.Team
	local theirTeam = otherPlayer.Team
	if myTeam and theirTeam then
		return myTeam == theirTeam
	end
	local neutralColor = BrickColor.new("Medium stone grey")
	local myColor = localPlayer.TeamColor
	local theirColor = otherPlayer.TeamColor
	if myColor ~= neutralColor and theirColor ~= neutralColor and myColor == theirColor then
		return true
	end
	local myChar = localPlayer.Character
	local theirChar = otherPlayer.Character
	if myChar and theirChar then
		local myAttr = myChar:GetAttribute("Team") or myChar:GetAttribute("TeamName")
		local theirAttr = theirChar:GetAttribute("Team") or theirChar:GetAttribute("TeamName")
		if typeof(myAttr) == "string" and typeof(theirAttr) == "string" and myAttr ~= "" and myAttr == theirAttr then
			return true
		end
	end
	return false
end

local function passesTeamCheck(otherPlayer)
	if not CONFIG.TeamCheckEnabled then
		return true
	end
	if isSameTeam(otherPlayer) then
		return false
	end
	if CONFIG.IgnoreNeutralTeams then
		local myTeam = localPlayer.Team
		local theirTeam = otherPlayer.Team
		if not myTeam or not theirTeam then
			return true
		end
	end
	return true
end

local function passesEspTeamCheck(otherPlayer)
	if not CONFIG.ESPTeamCheck then
		return true
	end
	if isSameTeam(otherPlayer) then
		return false
	end
	if CONFIG.IgnoreNeutralTeams then
		local myTeam = localPlayer.Team
		local theirTeam = otherPlayer.Team
		if not myTeam or not theirTeam then
			return true
		end
	end
	return true
end

local function getEspColor(otherPlayer)
	local myTeam = localPlayer.Team
	local theirTeam = otherPlayer.Team
	if myTeam and theirTeam and myTeam == theirTeam then
		return CONFIG.ESPTeamColor
	end
	return CONFIG.ESPEnemyColor
end

local function rainbowColor(offset)
	local hue = (os.clock() * CONFIG.ESPRainbowSpeed * 0.2 + offset) % 1
	return Color3.fromHSV(hue, 1, 1)
end

local function applyEspGlow(color)
	if not CONFIG.ESPGlow then
		return color
	end
	local pulse = 0.82 + 0.18 * (math.sin(os.clock() * CONFIG.ESPGlowSpeed * 4) * 0.5 + 0.5)
	return Color3.new(
		math.clamp(color.R * pulse, 0, 1),
		math.clamp(color.G * pulse, 0, 1),
		math.clamp(color.B * pulse, 0, 1)
	)
end

local function resolveEspFeatureColor(
	otherPlayer,
	featureColor,
	featureRainbow,
	rainbowOffset
)
	local base
	if featureRainbow then
		local playerShift = (otherPlayer.UserId % 97) * 0.01
		base = rainbowColor(rainbowOffset + playerShift)
	elseif CONFIG.ESPUseTeamColors then
		base = getEspColor(otherPlayer)
	else
		base = featureColor
	end
	return applyEspGlow(base)
end

local function clearEspForPlayer(player)
	local visuals = espVisuals[player]
	if not visuals then
		return
	end
	visuals.highlight:Destroy()
	visuals.billboard:Destroy()
	visuals.boxFolder:Destroy()
	visuals.tracer:Destroy()
	visuals.skeletonFolder:Destroy()
	espVisuals[player] = nil
end

do
-- Bone pairs for R15 + R6. Missing parts are skipped per character.
local SKELETON_BONES= {
	-- R15
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
	-- R6
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local function createEspArm(parent, name)
	local arm = Instance.new("Frame")
	arm.Name = name
	arm.BorderSizePixel = 0
	arm.BackgroundTransparency = 0
	arm.Visible = false
	arm.ZIndex = 20
	arm.Parent = parent
	return arm
end

local function createSkeletonLine(parent, name)
	local line = Instance.new("Frame")
	line.Name = name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
	line.BorderSizePixel = 0
	line.BackgroundTransparency = 0.05
	line.Visible = false
	line.ZIndex = 21
	line.Parent = parent
	return line
end

local function placeEspLine(frame, from, to, color, thickness)
	local delta = to - from
	local length = delta.Magnitude
	if length < 1 then
		frame.Visible = false
		return
	end
	frame.Visible = true
	frame.BackgroundColor3 = color
	frame.Size = UDim2.fromOffset(length, thickness)
	frame.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
	frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

local function layoutCornerBox(arms, x, y, w, h, color, thick)
	local len = math.clamp(math.min(w, h) * 0.22, 5, 11)
	local t = math.max(thick, 1)
	-- TL H, TL V, TR H, TR V, BL H, BL V, BR H, BR V
	local specs = {
		{ x, y, len, t },
		{ x, y, t, len },
		{ x + w - len, y, len, t },
		{ x + w - t, y, t, len },
		{ x, y + h - t, len, t },
		{ x, y + h - len, t, len },
		{ x + w - len, y + h - t, len, t },
		{ x + w - t, y + h - len, t, len },
	}
	for i, arm in arms do
		local s = specs[i]
		arm.Visible = true
		arm.BackgroundColor3 = color
		arm.Position = UDim2.fromOffset(s[1], s[2])
		arm.Size = UDim2.fromOffset(s[3], s[4])
	end
end

local function hideCornerBox(arms)
	for _, arm in arms do
		arm.Visible = false
	end
end

local function updateSkeletonEsp(visuals, character, color)
	if not CONFIG.ESPSkeleton then
		for _, line in visuals.skeletonLines do
			line.Visible = false
		end
		return
	end
	local lineIndex = 0
	for _, bone in SKELETON_BONES do
		local a = getCharacterPart(character, bone[1])
		local b = getCharacterPart(character, bone[2])
		if a and b then
			local sa, onA = camera:WorldToViewportPoint(a.Position)
			local sb, onB = camera:WorldToViewportPoint(b.Position)
			if onA and onB and sa.Z > 0 and sb.Z > 0 then
				lineIndex += 1
				local line = visuals.skeletonLines[lineIndex]
				if line then
					placeEspLine(line, Vector2.new(sa.X, sa.Y), Vector2.new(sb.X, sb.Y), color, 1)
				end
			end
		end
	end
	for i = lineIndex + 1, #visuals.skeletonLines do
		visuals.skeletonLines[i].Visible = false
	end
end

local function ensureEspVisuals(player, character)
	local existing = espVisuals[player]
	if existing and existing.highlight.Parent and existing.billboard.Parent and existing.boxFolder.Parent then
		if existing.highlight.Adornee ~= character then
			existing.highlight.Adornee = character
			existing.highlight.Parent = character
			local adorn = getCharacterPart(character, "Head") or getCharacterPart(character, "HumanoidRootPart")
			if adorn then
				existing.billboard.Adornee = adorn
				existing.billboard.Parent = adorn
			end
		end
		return existing
	end
	if existing then
		clearEspForPlayer(player)
	end

	local color = getEspColor(player)

	local highlight = Instance.new("Highlight")
	highlight.Name = "NameHubESPHighlight"
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.9
	highlight.OutlineTransparency = 0.25
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = character
	highlight.Parent = character

	local adornPart = getCharacterPart(character, "Head")
		or getCharacterPart(character, "HumanoidRootPart")
		or character:FindFirstChildWhichIsA("BasePart")

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameHubESPBillboard"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(120, 34)
	billboard.StudsOffset = Vector3.new(0, 2.15, 0)
	billboard.MaxDistance = CONFIG.ESPMaxDistance
	billboard.LightInfluence = 0
	if adornPart then
		billboard.Adornee = adornPart
		billboard.Parent = adornPart
	else
		billboard.Parent = character
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 14)
	nameLabel.Position = UDim2.fromOffset(0, 0)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextSize = CONFIG.ESPTextSize
	nameLabel.TextColor3 = color
	nameLabel.TextStrokeTransparency = 0.55
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Text = player.DisplayName
	nameLabel.Parent = billboard

	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size = UDim2.new(1, 0, 0, 12)
	distLabel.Position = UDim2.fromOffset(0, 13)
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextSize = math.max(CONFIG.ESPTextSize - 2, 10)
	distLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	distLabel.TextStrokeTransparency = 0.6
	distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	distLabel.Text = ""
	distLabel.Parent = billboard

	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBg"
	healthBg.AnchorPoint = Vector2.new(0.5, 0)
	healthBg.Position = UDim2.new(0.5, 0, 0, 26)
	healthBg.Size = UDim2.fromOffset(46, 2)
	healthBg.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	healthBg.BackgroundTransparency = 0.15
	healthBg.BorderSizePixel = 0
	healthBg.Parent = billboard

	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.fromScale(1, 1)
	healthFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBg

	local boxFolder = Instance.new("Folder")
	boxFolder.Name = "ESPBox_" .. player.Name
	boxFolder.Parent = espOverlay
	local boxArms= {}
	for i = 1, 8 do
		table.insert(boxArms, createEspArm(boxFolder, "Arm_" .. i))
	end

	local tracer = Instance.new("Frame")
	tracer.Name = "ESPTracer_" .. player.Name
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = color
	tracer.BackgroundTransparency = 0.2
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.ZIndex = 19
	tracer.Parent = espOverlay

	local skeletonFolder = Instance.new("Folder")
	skeletonFolder.Name = "ESPSkeleton_" .. player.Name
	skeletonFolder.Parent = espOverlay
	local skeletonLines= {}
	for i = 1, #SKELETON_BONES do
		table.insert(skeletonLines, createSkeletonLine(skeletonFolder, "Bone_" .. i))
	end

	local visuals= {
		highlight = highlight,
		billboard = billboard,
		nameLabel = nameLabel,
		distLabel = distLabel,
		healthBg = healthBg,
		healthFill = healthFill,
		boxFolder = boxFolder,
		boxArms = boxArms,
		tracer = tracer,
		skeletonFolder = skeletonFolder,
		skeletonLines = skeletonLines,
	}
	espVisuals[player] = visuals
	return visuals
end

local function getScreenBox(character)
	local ok, payload = pcall(function()
		local cf, size = character:GetBoundingBox()
		return { cf = cf, size = size }
	end)
	if not ok or typeof(payload) ~= "table" then
		return nil, nil
	end
	local cf = payload.cf
	local size = payload.size
	if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
		return nil, nil
	end
	local half = size / 2
	local corners = {
		cf * Vector3.new(half.X, half.Y, half.Z),
		cf * Vector3.new(half.X, half.Y, -half.Z),
		cf * Vector3.new(half.X, -half.Y, half.Z),
		cf * Vector3.new(half.X, -half.Y, -half.Z),
		cf * Vector3.new(-half.X, half.Y, half.Z),
		cf * Vector3.new(-half.X, half.Y, -half.Z),
		cf * Vector3.new(-half.X, -half.Y, half.Z),
		cf * Vector3.new(-half.X, -half.Y, -half.Z),
	}
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyOnScreen = false
	for _, worldPos in corners do
		local screenPos = camera:WorldToViewportPoint(worldPos)
		if screenPos.Z > 0 then
			anyOnScreen = true
			minX = math.min(minX, screenPos.X)
			minY = math.min(minY, screenPos.Y)
			maxX = math.max(maxX, screenPos.X)
			maxY = math.max(maxY, screenPos.Y)
		end
	end
	if not anyOnScreen or minX == math.huge then
		return nil, nil
	end
	return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

clearAllEsp = function()
	for player in pairs(espVisuals) do
		clearEspForPlayer(player)
	end
end

updateEsp = function()
	if not CONFIG.ESPEnabled then
		clearAllEsp()
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local camPos = camera.CFrame.Position
	local seen= {}
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer ~= localPlayer then
			local character = otherPlayer.Character
			if not character or not isAlive(character) or not passesEspTeamCheck(otherPlayer) then
				clearEspForPlayer(otherPlayer)
			else
				local root = getCharacterPart(character, "HumanoidRootPart") or getCharacterPart(character, "Head")
				if not root then
					clearEspForPlayer(otherPlayer)
				else
					local distance = (root.Position - camPos).Magnitude
					if distance > CONFIG.ESPMaxDistance then
						clearEspForPlayer(otherPlayer)
					else
						local anyFeature = CONFIG.ESPBoxes
							or CONFIG.ESPSkeleton
							or CONFIG.ESPNames
							or CONFIG.ESPDistance
							or CONFIG.ESPHealthBar
							or CONFIG.ESPHighlights
							or CONFIG.ESPTracers
						if not anyFeature then
							clearEspForPlayer(otherPlayer)
						else
							seen[otherPlayer] = true
							local visuals = ensureEspVisuals(otherPlayer, character)
							local boxColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPBoxColor, CONFIG.ESPBoxRainbow, 0)
							local skeletonColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPSkeletonColor, CONFIG.ESPSkeletonRainbow, 0.14)
							local nameColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPNameColor, CONFIG.ESPNameRainbow, 0.28)
							local distColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPDistanceColor, CONFIG.ESPDistanceRainbow, 0.38)
							local highlightColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPHighlightColor, CONFIG.ESPHighlightRainbow, 0.5)
							local tracerColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPTracerColor, CONFIG.ESPTracerRainbow, 0.64)
							local healthColor = resolveEspFeatureColor(otherPlayer, CONFIG.ESPHealthColor, CONFIG.ESPHealthRainbow, 0.76)

							local glowBoost = if CONFIG.ESPGlow then (0.08 + 0.1 * (math.sin(os.clock() * CONFIG.ESPGlowSpeed * 4) * 0.5 + 0.5)) else 0

							visuals.highlight.Enabled = CONFIG.ESPHighlights
							visuals.highlight.FillColor = highlightColor
							visuals.highlight.OutlineColor = highlightColor
							visuals.highlight.FillTransparency = math.clamp(0.9 - glowBoost * 0.15, 0.78, 0.94)
							visuals.highlight.OutlineTransparency = math.clamp(0.28 - glowBoost * 0.1, 0.12, 0.35)

							local showBillboard = CONFIG.ESPNames or CONFIG.ESPDistance or CONFIG.ESPHealthBar
							visuals.billboard.Enabled = showBillboard
							visuals.billboard.MaxDistance = CONFIG.ESPMaxDistance
							visuals.nameLabel.Visible = CONFIG.ESPNames
							visuals.nameLabel.Text = otherPlayer.DisplayName
							visuals.nameLabel.TextColor3 = nameColor
							visuals.nameLabel.TextSize = CONFIG.ESPTextSize
							visuals.distLabel.Visible = CONFIG.ESPDistance
							visuals.distLabel.Text = string.format("%dm", math.floor(distance + 0.5))
							visuals.distLabel.TextColor3 = distColor
							visuals.distLabel.TextSize = math.max(CONFIG.ESPTextSize - 2, 10)

							local humanoid = character:FindFirstChildOfClass("Humanoid")
							if CONFIG.ESPHealthBar and humanoid then
								visuals.healthBg.Visible = true
								local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
								visuals.healthFill.Size = UDim2.fromScale(ratio, 1)
								visuals.healthFill.BackgroundColor3 = healthColor:Lerp(Color3.fromRGB(220, 70, 70), 1 - ratio)
							else
								visuals.healthBg.Visible = false
							end

							if CONFIG.ESPBoxes then
								local topLeft, boxSize = getScreenBox(character)
								if topLeft and boxSize and boxSize.X > 3 and boxSize.Y > 3 then
									layoutCornerBox(
										visuals.boxArms,
										topLeft.X,
										topLeft.Y,
										boxSize.X,
										boxSize.Y,
										boxColor,
										1 + glowBoost
									)
								else
									hideCornerBox(visuals.boxArms)
								end
							else
								hideCornerBox(visuals.boxArms)
							end

							updateSkeletonEsp(visuals, character, skeletonColor)

							if CONFIG.ESPTracers then
								local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
								if onScreen and screenPos.Z > 0 then
									local viewport = camera.ViewportSize
									local from = Vector2.new(viewport.X / 2, viewport.Y - 2)
									local to = Vector2.new(screenPos.X, screenPos.Y)
									placeEspLine(visuals.tracer, from, to, tracerColor, 1)
									visuals.tracer.BackgroundTransparency = 0.25
								else
									visuals.tracer.Visible = false
								end
							else
								visuals.tracer.Visible = false
							end
						end
					end
				end
			end
		end
	end
	for player in pairs(espVisuals) do
		if not seen[player] then
			clearEspForPlayer(player)
		end
	end
end

end -- ESP module scope

do
local function hasLineOfSight(origin, targetPart, targetCharacter)
	if not CONFIG.RequireLineOfSight then
		return true
	end
	local direction = targetPart.Position - origin
	if direction.Magnitude <= 0.01 then
		return true
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excludeList= {}
	if localPlayer.Character then
		table.insert(excludeList, localPlayer.Character)
	end
	params.FilterDescendantsInstances = excludeList
	local result = workspace:Raycast(origin, direction, params)
	if not result then
		return true
	end
	return targetCharacter:IsAncestorOf(result.Instance)
end

local function worldToScreenDistance(part, mousePos)
	local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
	if not onScreen or screenPos.Z <= 0 then
		return nil, false
	end
	return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude, true
end

getPredictedAimPosition = function(part, character)
	if not CONFIG.AimPrediction then
		return part.Position
	end
	local root = getCharacterPart(character, "HumanoidRootPart") or part
	local vel = root.AssemblyLinearVelocity
	if vel.Magnitude < 1 then
		return part.Position
	end
	local dist = (part.Position - camera.CFrame.Position).Magnitude
	local lead = math.clamp(dist / 900, 0.04, 0.14)
	return part.Position + vel * lead
end

local function isValidTargetPlayer(
	otherPlayer,
	mousePos,
	rayOrigin,
	fovScale
)
	if otherPlayer == localPlayer then
		return nil
	end
	local character = otherPlayer.Character
	if not character or not isAlive(character) or not passesTeamCheck(otherPlayer) then
		return nil
	end
	local targetPart = getTargetPart(character)
	if not targetPart then
		return nil
	end
	if (targetPart.Position - camera.CFrame.Position).Magnitude > CONFIG.MaxWorldDistance then
		return nil
	end
	local fovLimit = CONFIG.FOVRadius * math.max(fovScale, 0.5)
	local screenDistance, onScreen = worldToScreenDistance(targetPart, mousePos)
	if not onScreen or not screenDistance or screenDistance > fovLimit then
		return nil
	end
	if rayOrigin and not hasLineOfSight(rayOrigin, targetPart, character) then
		return nil
	end
	return otherPlayer
end

findClosestTarget = function(scanOverride)
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local rayOrigin = getRaycastOrigin(character)
	local mousePos = scanOverride or getAimScanPosition()
	local closestPlayer= nil
	local closestDistance = CONFIG.FOVRadius + 1
	for _, otherPlayer in Players:GetPlayers() do
		if isValidTargetPlayer(otherPlayer, mousePos, rayOrigin, 1) then
			local targetPart = getTargetPart(otherPlayer.Character )
			if targetPart then
				local screenDistance = worldToScreenDistance(targetPart, mousePos)
				if screenDistance and screenDistance < closestDistance then
					closestDistance = screenDistance
					closestPlayer = otherPlayer
				end
			end
		end
	end
	return closestPlayer
end

acquireAimTarget = function(precomputedClosest)
	local character = localPlayer.Character
	if not character then
		lockedTarget = nil
		return nil
	end
	local rayOrigin = getRaycastOrigin(character)
	local mousePos = getAimScanPosition()
	if CONFIG.AimStickyLock and lockedTarget then
		if isValidTargetPlayer(lockedTarget, mousePos, rayOrigin, CONFIG.AimStickiness) then
			return lockedTarget
		end
	end
	local closest = precomputedClosest or findClosestTarget()
	lockedTarget = closest
	return closest
end

local lockedSilentTarget= nil

acquireSilentAimTarget = function(precomputedClosest)
	local character = localPlayer.Character
	if not character then
		lockedSilentTarget = nil
		return nil
	end
	local rayOrigin = getRaycastOrigin(character)
	local mousePos = getSilentAimScanPosition()
	if CONFIG.SilentAimStickyLock and lockedSilentTarget then
		if isValidTargetPlayer(lockedSilentTarget, mousePos, rayOrigin, CONFIG.AimStickiness) then
			return lockedSilentTarget
		end
	end
	local closest = precomputedClosest or findClosestTarget(mousePos)
	if CONFIG.SilentAimStickyLock then
		lockedSilentTarget = closest
	end
	return closest
end

resolveSilentAimShot = function()
	if not silentAimEnabled then
		return nil, nil, nil
	end
	local silentScan = getSilentAimScanPosition()
	local targetPlayer = if CONFIG.SilentAimStickyLock
		then acquireSilentAimTarget(nil)
		else findClosestTarget(silentScan)
	if not targetPlayer then
		return nil, nil, nil
	end
	local character = targetPlayer.Character
	if not character or not isAlive(character) or not passesTeamCheck(targetPlayer) then
		return nil, nil, nil
	end
	local part = getTargetPart(character)
	if not part then
		return nil, nil, nil
	end
	return getPredictedAimPosition(part, character), part, targetPlayer
end

clearSilentAimSticky = function()
	lockedSilentTarget = nil
end

setAimCameraActive = function(active)
	aimCameraActive = active
	if not active then
		aimLookAt = nil
	end
end

local function applyAimCamera()
	if CONFIG.ThirdPersonEnabled then
		return
	end
	if not aimLookAt or not aimShouldLock() or menuOpen or not aimCameraActive then
		return
	end
	if os.clock() < aimLockPausedUntil then
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local currentCFrame = camera.CFrame
	local goalCFrame = CFrame.lookAt(currentCFrame.Position, aimLookAt)
	if CONFIG.AimSnapLock or CONFIG.Smoothness >= 0.85 then
		camera.CFrame = goalCFrame
	else
		camera.CFrame = currentCFrame:Lerp(goalCFrame, math.clamp(CONFIG.Smoothness, 0.05, 1))
	end
end

local function ensureAimRenderStep()
	if aimRenderBound then
		return
	end
	aimRenderBound = true
	RunService:BindToRenderStep(
		"NameHubAimLock",
		Enum.RenderPriority.Last.Value,
		function()
			if not scriptAlive then
				return
			end
			pcall(applyAimCamera)
		end
	)
end

smoothLookAt = function(lookAtPosition, _alpha)
	aimLookAt = lookAtPosition
	ensureAimRenderStep()
end

end -- aim module scope

local function untrackPlayer(player)
	local data = trackedPlayers[player]
	if not data then
		clearEspForPlayer(player)
		return
	end
	if data.characterAdded then
		data.characterAdded:Disconnect()
	end
	if data.characterRemoving then
		data.characterRemoving:Disconnect()
	end
	trackedPlayers[player] = nil
	clearEspForPlayer(player)
	if currentTarget == player then
		currentTarget = nil
	end
end

local function trackPlayer(player)
	if player == localPlayer or trackedPlayers[player] then
		return
	end
	trackedPlayers[player] = {
		characterAdded = player.CharacterAdded:Connect(function()
			if currentTarget == player then
				currentTarget = nil
			end
		end),
		characterRemoving = player.CharacterRemoving:Connect(function()
			if currentTarget == player then
				currentTarget = nil
			end
		end),
	}
end

for _, player in Players:GetPlayers() do
	trackPlayer(player)
end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

do -- fly + noclip + movement (scoped to stay under Luau 200-local limit)
local noclipTrackedParts= {}
local noclipWatchConn= nil
local movementBaseline = nil
local movementHumanoid= nil

local function resetMovementBaseline()
	movementBaseline = nil
	movementHumanoid = nil
end

local function captureMovementBaseline(humanoid)
	movementBaseline = {
		walkSpeed = humanoid.WalkSpeed,
		jumpHeight = humanoid.JumpHeight,
		jumpPower = humanoid.JumpPower,
		useJumpPower = humanoid.UseJumpPower,
	}
	movementHumanoid = humanoid
end

local function applyMovementToHumanoid(humanoid)
	if movementHumanoid ~= humanoid or not movementBaseline then
		captureMovementBaseline(humanoid)
	end
	local base = movementBaseline
	if not base then
		return
	end
	if CONFIG.SpeedEnabled then
		humanoid.WalkSpeed = CONFIG.WalkSpeed
	else
		humanoid.WalkSpeed = base.walkSpeed
	end
	if CONFIG.JumpEnabled then
		if humanoid.UseJumpPower then
			humanoid.JumpPower = CONFIG.JumpHeight
		else
			humanoid.JumpHeight = CONFIG.JumpHeight
		end
	else
		humanoid.UseJumpPower = base.useJumpPower
		humanoid.JumpHeight = base.jumpHeight
		humanoid.JumpPower = base.jumpPower
	end
end

applyMovementMods = function()
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		applyMovementToHumanoid(humanoid)
	end
end

updateMovement = function()
	if not CONFIG.SpeedEnabled and not CONFIG.JumpEnabled then
		return
	end
	local character = localPlayer.Character
	if not character or not isAlive(character) then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if movementHumanoid ~= humanoid or not movementBaseline then
		captureMovementBaseline(humanoid)
	end
	local base = movementBaseline
	if not base then
		return
	end
	if CONFIG.SpeedEnabled then
		if humanoid.WalkSpeed ~= CONFIG.WalkSpeed then
			humanoid.WalkSpeed = CONFIG.WalkSpeed
		end
	elseif humanoid.WalkSpeed ~= base.walkSpeed then
		humanoid.WalkSpeed = base.walkSpeed
	end
	if CONFIG.JumpEnabled then
		if humanoid.UseJumpPower then
			if humanoid.JumpPower ~= CONFIG.JumpHeight then
				humanoid.JumpPower = CONFIG.JumpHeight
			end
		elseif humanoid.JumpHeight ~= CONFIG.JumpHeight then
			humanoid.JumpHeight = CONFIG.JumpHeight
		end
	else
		if humanoid.JumpHeight ~= base.jumpHeight then
			humanoid.JumpHeight = base.jumpHeight
		end
		if humanoid.JumpPower ~= base.jumpPower then
			humanoid.JumpPower = base.jumpPower
		end
		if humanoid.UseJumpPower ~= base.useJumpPower then
			humanoid.UseJumpPower = base.useJumpPower
		end
	end
end

local function resetNoclipCache()
	if noclipWatchConn then
		pcall(function()
			noclipWatchConn:Disconnect()
		end)
		noclipWatchConn = nil
	end
	table.clear(noclipTrackedParts)
end

local function setupNoclipForCharacter(character)
	resetNoclipCache()
	local function trackPart(part)
		part.CanCollide = false
		table.insert(noclipTrackedParts, part)
	end
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			trackPart(descendant)
		end
	end
	noclipWatchConn = character.DescendantAdded:Connect(function(descendant)
		if noclipEnabled and descendant:IsA("BasePart") then
			trackPart(descendant)
		end
	end)
end

updateNoclip = function()
	if not noclipEnabled then
		return
	end
	for index = #noclipTrackedParts, 1, -1 do
		local part = noclipTrackedParts[index]
		if not part.Parent then
			table.remove(noclipTrackedParts, index)
		elseif part.CanCollide then
			part.CanCollide = false
		end
	end
end

local function destroyFlyConstraints()
	if flyState.velocity then
		flyState.velocity:Destroy()
		flyState.velocity = nil
	end
	if flyState.align then
		flyState.align:Destroy()
		flyState.align = nil
	end
	if flyState.attachment then
		flyState.attachment:Destroy()
		flyState.attachment = nil
	end
	if flyState.humanoid then
		flyState.humanoid.PlatformStand = flyState.wasPlatformStand
		flyState.humanoid = nil
	end
end

local function setupFlyConstraints(character)
	local hrp = getCharacterPart(character, "HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return false
	end
	destroyFlyConstraints()
	flyState.humanoid = humanoid
	flyState.wasPlatformStand = humanoid.PlatformStand
	humanoid.PlatformStand = true
	local attachment = Instance.new("Attachment")
	attachment.Name = "AimAssistFlyAttachment"
	attachment.Parent = hrp
	flyState.attachment = attachment
	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "AimAssistFlyVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	velocity.MaxForce = math.huge
	velocity.VectorVelocity = Vector3.zero
	velocity.Parent = hrp
	flyState.velocity = velocity
	local align = Instance.new("AlignOrientation")
	align.Name = "AimAssistFlyAlign"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = attachment
	align.Responsiveness = 25
	align.MaxTorque = math.huge
	align.Parent = hrp
	flyState.align = align
	return true
end

updateFly = function()
	if not flyEnabled then
		return
	end
	local character = localPlayer.Character
	if not character or not isAlive(character) then
		destroyFlyConstraints()
		return
	end
	if not flyState.velocity or not flyState.velocity.Parent or not flyState.align or not flyState.align.Parent then
		if not setupFlyConstraints(character) then
			return
		end
	end
	camera = workspace.CurrentCamera
	if not camera or not flyState.velocity or not flyState.align then
		return
	end
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local move = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		move += look
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		move -= look
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		move += right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		move -= right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		move += Vector3.yAxis * CONFIG.FlyVerticalMultiplier
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		move -= Vector3.yAxis * CONFIG.FlyVerticalMultiplier
	end
	if move.Magnitude > 0 then
		move = move.Unit
	end
	local speed = CONFIG.FlySpeed
	if
		UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	then
		speed *= CONFIG.FlyBoostMultiplier
	end
	flyState.velocity.VectorVelocity = move * speed
	local hrp = getCharacterPart(character, "HumanoidRootPart")
	if hrp then
		flyState.align.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
	end
end

setFlyEnabled = function(value)
	flyEnabled = value
	if toggleUI.fly then
		toggleUI.fly.Set(flyEnabled)
	end
	if flyEnabled then
		local character = localPlayer.Character
		if character then
			setupFlyConstraints(character)
		end
	else
		destroyFlyConstraints()
	end
end

setNoclipEnabled = function(value)
	noclipEnabled = value
	if toggleUI.noclip then
		toggleUI.noclip.Set(noclipEnabled)
	end
	if noclipEnabled then
		local character = localPlayer.Character
		if character then
			setupNoclipForCharacter(character)
		end
	else
		resetNoclipCache()
	end
end

local thirdPersonSaved = {
	cameraMode = nil ,
	minZoom = nil ,
	maxZoom = nil ,
	occlusion = nil ,
	cameraType = nil ,
}
local thirdPersonWatchConn= nil

local function disconnectThirdPersonWatch()
	if thirdPersonWatchConn then
		pcall(function()
			thirdPersonWatchConn:Disconnect()
		end)
		thirdPersonWatchConn = nil
	end
end

local function shouldRevealThirdPersonPart(part, character)
	if not part:IsA("BasePart") then
		return false
	end
	local parent = part.Parent
	while parent and parent ~= character do
		local name = string.lower(parent.Name)
		if name == "viewmodel" or name == "camera" or name == "viewport" then
			return false
		end
		parent = parent.Parent
	end
	return true
end

local function revealThirdPersonPart(part)
	part.LocalTransparencyModifier = 0
	if part.Transparency >= 0.99 then
		part.Transparency = 0
	end
end

local function applyThirdPersonCharacterVisibility(character)
	if not character then
		return
	end
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") and shouldRevealThirdPersonPart(descendant, character) then
			revealThirdPersonPart(descendant)
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			local parent = descendant.Parent
			if parent and parent:IsA("BasePart") and character:IsAncestorOf(parent) then
				descendant.Transparency = 0
			end
		end
	end
end

local function setupThirdPersonCharacterWatch(character)
	disconnectThirdPersonWatch()
	applyThirdPersonCharacterVisibility(character)
	thirdPersonWatchConn = character.DescendantAdded:Connect(function(descendant)
		if not CONFIG.ThirdPersonEnabled then
			return
		end
		if descendant:IsA("BasePart") and shouldRevealThirdPersonPart(descendant, character) then
			revealThirdPersonPart(descendant)
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			local parent = descendant.Parent
			if parent and parent:IsA("BasePart") then
				descendant.Transparency = 0
			end
		end
	end)
end

local function resetThirdPersonCharacterVisibility()
	disconnectThirdPersonWatch()
	local character = localPlayer.Character
	if not character then
		return
	end
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") and shouldRevealThirdPersonPart(descendant, character) then
			descendant.LocalTransparencyModifier = 0
		end
	end
end

local function resetThirdPersonBaseline()
	thirdPersonSaved.cameraMode = nil
	thirdPersonSaved.minZoom = nil
	thirdPersonSaved.maxZoom = nil
	thirdPersonSaved.occlusion = nil
	thirdPersonSaved.cameraType = nil
end

local function saveThirdPersonBaseline()
	if thirdPersonSaved.cameraMode ~= nil then
		return
	end
	thirdPersonSaved.cameraMode = localPlayer.CameraMode
	thirdPersonSaved.minZoom = localPlayer.CameraMinZoomDistance
	thirdPersonSaved.maxZoom = localPlayer.CameraMaxZoomDistance
	thirdPersonSaved.occlusion = localPlayer.DevCameraOcclusionMode
	camera = workspace.CurrentCamera
	if camera then
		thirdPersonSaved.cameraType = camera.CameraType
	end
end

local function restoreThirdPersonCamera()
	if thirdPersonSaved.cameraMode ~= nil then
		localPlayer.CameraMode = thirdPersonSaved.cameraMode
	end
	if thirdPersonSaved.minZoom ~= nil then
		localPlayer.CameraMinZoomDistance = thirdPersonSaved.minZoom
	end
	if thirdPersonSaved.maxZoom ~= nil then
		localPlayer.CameraMaxZoomDistance = thirdPersonSaved.maxZoom
	end
	if thirdPersonSaved.occlusion ~= nil then
		localPlayer.DevCameraOcclusionMode = thirdPersonSaved.occlusion
	end
	camera = workspace.CurrentCamera
	if camera and thirdPersonSaved.cameraType ~= nil then
		camera.CameraType = thirdPersonSaved.cameraType
	end
end

local function getThirdPersonZoom()
	return math.clamp(CONFIG.ThirdPersonDistance, 12, 80)
end

local function applyThirdPersonCamera()
	camera = workspace.CurrentCamera
	local character = localPlayer.Character
	if not camera or not character then
		return
	end
	local root = getCharacterPart(character, "HumanoidRootPart")
		or getCharacterPart(character, "UpperTorso")
		or getCharacterPart(character, "Torso")
	if not root then
		return
	end
	local focus = root.Position + Vector3.new(0, 1.5, 0)
	local zoom = getThirdPersonZoom()
	local useAim = aimShouldLock()
		and aimLookAt
		and aimCameraActive
		and not menuOpen
		and os.clock() >= aimLockPausedUntil
	local lookTarget
	if useAim then
		lookTarget = aimLookAt 
	else
		lookTarget = focus + camera.CFrame.LookVector * 120
	end
	local toTarget = lookTarget - focus
	local forward = Vector3.new(toTarget.X, 0, toTarget.Z)
	if forward.Magnitude < 0.05 then
		forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	end
	if forward.Magnitude < 0.05 then
		forward = Vector3.new(0, 0, -1)
	else
		forward = forward.Unit
	end
	local back = -forward
	local lift = math.clamp(zoom * 0.2, 2.5, 14)
	local camPos = focus + back * zoom + Vector3.new(0, lift, 0)
	camera.CameraType = Enum.CameraType.Custom
	local goalCFrame = CFrame.lookAt(camPos, lookTarget)
	if useAim and not (CONFIG.AimSnapLock or CONFIG.Smoothness >= 0.85) then
		camera.CFrame = camera.CFrame:Lerp(goalCFrame, math.clamp(CONFIG.Smoothness, 0.05, 1))
	else
		camera.CFrame = goalCFrame
	end
end

local spinBotAngle = 0
local spinBotLastAt = os.clock()
local spinBotHumanoid= nil
local spinBotSavedAutoRotate= nil

local function clearSpinBotHumanoid()
	if spinBotHumanoid and spinBotSavedAutoRotate ~= nil then
		spinBotHumanoid.AutoRotate = spinBotSavedAutoRotate
	end
	spinBotHumanoid = nil
	spinBotSavedAutoRotate = nil
end

local function restoreSpinBotState()
	clearSpinBotHumanoid()
	spinBotAngle = 0
	spinBotLastAt = os.clock()
end

updateSpinBot = function()
	if not CONFIG.SpinBotEnabled or not CONFIG.ThirdPersonEnabled then
		return
	end
	local character = localPlayer.Character
	if not character then
		return
	end
	local hrp = getCharacterPart(character, "HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return
	end
	if spinBotHumanoid ~= humanoid then
		clearSpinBotHumanoid()
		spinBotHumanoid = humanoid
		spinBotSavedAutoRotate = humanoid.AutoRotate
	end
	humanoid.AutoRotate = false
	local now = os.clock()
	local dt = math.clamp(now - spinBotLastAt, 0, 0.05)
	spinBotLastAt = now
	local speed = CONFIG.SpinBotSpeed
	if CONFIG.SpinBotJitter then
		speed += (math.random() - 0.5) * CONFIG.SpinBotJitterAmount
	end
	spinBotAngle += math.rad(speed * dt)
	local pitch = 0
	local roll = 0
	if CONFIG.SpinBotAntiAim then
		pitch = math.sin(now * CONFIG.SpinBotPitchSpeed) * math.rad(CONFIG.SpinBotPitchAmount)
		roll = math.cos(now * CONFIG.SpinBotPitchSpeed * 0.7) * math.rad(CONFIG.SpinBotPitchAmount * 0.35)
	end
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(pitch, spinBotAngle, roll)
end

setSpinBotEnabled = function(value)
	CONFIG.SpinBotEnabled = value
	if toggleUI.spinBot then
		toggleUI.spinBot.Set(value)
	end
	if not value then
		restoreSpinBotState()
	elseif not CONFIG.ThirdPersonEnabled then
		notify("Spin Bot", "Enable Third Person first")
	end
end

adjustThirdPersonZoom = function(scrollDelta)
	if not CONFIG.ThirdPersonEnabled or scrollDelta == 0 then
		return
	end
	CONFIG.ThirdPersonDistance = math.clamp(
		CONFIG.ThirdPersonDistance - scrollDelta * CONFIG.ThirdPersonScrollStep,
		12,
		80
	)
	updateThirdPerson()
end

updateThirdPerson = function()
	if not CONFIG.ThirdPersonEnabled then
		return
	end
	saveThirdPersonBaseline()
	local zoom = getThirdPersonZoom()
	localPlayer.CameraMode = Enum.CameraMode.Classic
	localPlayer.CameraMinZoomDistance = zoom
	localPlayer.CameraMaxZoomDistance = zoom
	localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	local character = localPlayer.Character
	if character then
		if not thirdPersonWatchConn then
			setupThirdPersonCharacterWatch(character)
		end
		applyThirdPersonCharacterVisibility(character)
	end
	applyThirdPersonCamera()
end

setThirdPersonEnabled = function(value)
	CONFIG.ThirdPersonEnabled = value
	if toggleUI.thirdPerson then
		toggleUI.thirdPerson.Set(value)
	end
	if value then
		local character = localPlayer.Character
		if character then
			setupThirdPersonCharacterWatch(character)
		end
		updateThirdPerson()
	else
		restoreSpinBotState()
		resetThirdPersonCharacterVisibility()
		restoreThirdPersonCamera()
	end
end

localPlayer.CharacterAdded:Connect(function(_character)
	task.defer(function()
		resetMovementBaseline()
		if CONFIG.SpeedEnabled or CONFIG.JumpEnabled then
			applyMovementMods()
		end
	end)
	if flyEnabled then
		task.defer(function()
			if flyEnabled and localPlayer.Character then
				setupFlyConstraints(localPlayer.Character)
			end
		end)
	else
		destroyFlyConstraints()
	end
	if noclipEnabled then
		task.defer(function()
			if noclipEnabled and localPlayer.Character then
				setupNoclipForCharacter(localPlayer.Character)
			end
		end)
	else
		resetNoclipCache()
	end
	resetThirdPersonBaseline()
	if CONFIG.ThirdPersonEnabled then
		task.defer(function()
			if CONFIG.ThirdPersonEnabled and localPlayer.Character then
				setupThirdPersonCharacterWatch(localPlayer.Character)
				updateThirdPerson()
			end
		end)
	end
end)

localPlayer.CharacterRemoving:Connect(function()
	destroyFlyConstraints()
	resetNoclipCache()
	resetMovementBaseline()
	restoreSpinBotState()
	resetThirdPersonCharacterVisibility()
	resetThirdPersonBaseline()
end)
end -- fly + noclip scope

do -- rainbow weapons (held guns / knives / viewmodels)
local weaponPartOriginals= {}

local RIG_PART_NAMES= {
	Head = true,
	Torso = true,
	HumanoidRootPart = true,
	UpperTorso = true,
	LowerTorso = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

local function weaponRainbowColor(offset)
	local hue = (os.clock() * CONFIG.ESPRainbowSpeed * 0.25 + offset) % 1
	return Color3.fromHSV(hue, 1, 1)
end

local function isCharacterBodyPart(part, character)
	if not part:IsDescendantOf(character) then
		return true
	end
	if RIG_PART_NAMES[part.Name] then
		return true
	end
	local lower = string.lower(part.Name)
	if string.find(lower, "fakehead", 1, true) then
		return true
	end
	local parent = part.Parent
	while parent and parent ~= character do
		if parent:IsA("Accessory") then
			return true
		end
		parent = parent.Parent
	end
	return false
end

local function collectHeldWeaponParts(character)
	local parts= {}
	local seen= {}
	local function addPart(part)
		if seen[part] or isCharacterBodyPart(part, character) then
			return
		end
		seen[part] = true
		table.insert(parts, part)
	end
	local function addRoot(root)
		for _, desc in root:GetDescendants() do
			if desc:IsA("BasePart") then
				addPart(desc)
			end
		end
		if root:IsA("BasePart") then
			addPart(root)
		end
	end
	for _, child in character:GetChildren() do
		if child:IsA("Tool") then
			addRoot(child)
		elseif child:IsA("Model") and child.Name ~= character.Name then
			if not child:FindFirstChildOfClass("Humanoid") and not RIG_PART_NAMES[child.Name] then
				addRoot(child)
			end
		end
	end
	for _, desc in character:GetDescendants() do
		if desc:IsA("BasePart") then
			local lower = string.lower(desc.Name)
			if
				string.find(lower, "knife", 1, true)
				or string.find(lower, "gun", 1, true)
				or string.find(lower, "weapon", 1, true)
				or string.find(lower, "blade", 1, true)
				or string.find(lower, "rifle", 1, true)
				or string.find(lower, "pistol", 1, true)
				or string.find(lower, "melee", 1, true)
				or string.find(lower, "handle", 1, true)
			then
				addPart(desc)
			end
		end
	end
	return parts
end

local function snapshotWeaponPart(part)
	if not weaponPartOriginals[part] then
		weaponPartOriginals[part] = {
			Color = part.Color,
			Material = part.Material,
		}
	end
end

restoreRainbowWeapons = function()
	for part, snap in weaponPartOriginals do
		if part.Parent then
			pcall(function()
				part.Color = snap.Color
				part.Material = snap.Material
			end)
		end
	end
	table.clear(weaponPartOriginals)
end

updateRainbowWeapons = function()
	if not CONFIG.RainbowWeaponsEnabled then
		return
	end
	local character = localPlayer.Character
	if not character then
		return
	end
	local parts = collectHeldWeaponParts(character)
	local active= {}
	for index, part in parts do
		active[part] = true
		snapshotWeaponPart(part)
		part.Color = weaponRainbowColor(index * 0.08)
		part.Material = Enum.Material.Neon
	end
	for part in weaponPartOriginals do
		if not active[part] then
			if part.Parent then
				pcall(function()
					local snap = weaponPartOriginals[part]
					part.Color = snap.Color
					part.Material = snap.Material
				end)
			end
			weaponPartOriginals[part] = nil
		end
	end
end

end -- rainbow weapons scope

do -- auto knife
local lastKnifeStrike = 0
local KNIFE_COOLDOWN = 0.38
local KNIFE_RANGE = 90

local function strikeTool(tool)
	pcall(function()
		tool:Activate()
		local g = getgenv()
		local getconnections = g.getconnections
		if typeof(getconnections) ~= "function" and typeof(g.syn) == "table" then
			getconnections = g.syn.get_connections
		end
		if typeof(getconnections) ~= "function" then
			return
		end
		for _, conn in getconnections(tool.Activated) do
			pcall(function()
				if typeof(conn) == "table" and typeof(conn.Function) == "function" then
					task.spawn(conn.Function)
				elseif typeof(conn.Fire) == "function" then
					conn:Fire()
				end
			end)
		end
	end)
end

local function isKnifeTool(tool)
	local lower = string.lower(tool.Name)
	if string.find(lower, "knife", 1, true) then
		return true
	end
	if string.find(lower, "melee", 1, true) or string.find(lower, "dagger", 1, true) then
		return true
	end
	local toolType = tool:GetAttribute("Type") or tool:GetAttribute("WeaponType")
	if typeof(toolType) == "string" and string.find(string.lower(toolType), "melee", 1, true) then
		return true
	end
	return false
end

local function getEquippedKnife()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	for _, child in character:GetChildren() do
		if child:IsA("Tool") and isKnifeTool(child) then
			return child
		end
	end
	return nil
end

local function findKnifeTarget(myHrp)
	local closestPlayer= nil
	local closestDistance = KNIFE_RANGE + 1
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer == localPlayer then
			continue
		end
		local character = otherPlayer.Character
		if not character or not isAlive(character) or not passesTeamCheck(otherPlayer) then
			continue
		end
		local targetHrp = getCharacterPart(character, "HumanoidRootPart")
			or getCharacterPart(character, "UpperTorso")
		if not targetHrp then
			continue
		end
		local dist = (targetHrp.Position - myHrp.Position).Magnitude
		if dist < closestDistance then
			closestDistance = dist
			closestPlayer = otherPlayer
		end
	end
	return closestPlayer
end

updateAutoKnife = function()
	if menuOpen then
		return
	end
	local knife = getEquippedKnife()
	if not knife then
		logNote("Knife", "none", "Knife not equipped (scroll to knife slot)", 8)
		return
	end
	local myCharacter = localPlayer.Character
	if not myCharacter then
		return
	end
	local myHrp = getCharacterPart(myCharacter, "HumanoidRootPart")
	if not myHrp then
		return
	end
	local target = findKnifeTarget(myHrp)
	if not target then
		logNote("Knife", "no-target", "No enemy in knife range (" .. tostring(KNIFE_RANGE) .. " studs)", 6)
		return
	end
	local targetCharacter = target.Character
	if not targetCharacter then
		return
	end
	local targetHrp = getCharacterPart(targetCharacter, "HumanoidRootPart")
		or getCharacterPart(targetCharacter, "UpperTorso")
	if not targetHrp then
		return
	end
	if (myHrp.Position - targetHrp.Position).Magnitude > 8 then
		return
	end
	local now = os.clock()
	if now - lastKnifeStrike < KNIFE_COOLDOWN then
		return
	end
	lastKnifeStrike = now
	strikeTool(knife)
end

end -- auto knife scope

do
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rapidFireOriginals= {}
local rapidFireOriginalAttrs= {}
local rapidFireWatchConnections= {}
local lastRapidFireShot = 0
local lastWeaponPatch = 0
local lastWeaponsConfigPatch = 0

local RAPID_FIRE_AUTO_BOOLS= {
	Auto = true,
	Automatic = true,
	FullAuto = true,
}
local RAPID_FIRE_OFF_BOOLS= {
	Burst = true,
	Semi = true,
	SemiAuto = true,
	Single = true,
}
local RAPID_FIRE_NUMBER_NAMES= {
	FireRate = true,
	Cooldown = true,
	ShotDelay = true,
	FireDelay = true,
	ShootDelay = true,
	Delay = true,
	Rate = true,
	RPM = true,
	Debounce = true,
}
local rapidFireHookedTools= {}
local getScriptEnv
local getRapidFireShotDelay
local getArsenalFireRateValue

local rememberValue
local rememberAttribute
local patchToolTree

local function fireToolConnections(tool)
	pcall(function()
		local g = getgenv()
		local getconnections = g.getconnections
		if typeof(getconnections) ~= "function" and typeof(g.syn) == "table" then
			getconnections = g.syn.get_connections
		end
		if typeof(getconnections) ~= "function" then
			return
		end
		for _, conn in getconnections(tool.Activated) do
			pcall(function()
				if typeof(conn) == "table" and typeof(conn.Function) == "function" then
					task.spawn(conn.Function)
				elseif typeof(conn.Fire) == "function" then
					conn:Fire()
				end
			end)
		end
	end)
end

getScriptEnv = function(scriptInst)
	local g = getgenv()
	local getsenv = g.getsenv
	if typeof(getsenv) ~= "function" and typeof(g.syn) == "table" then
		getsenv = g.syn.get_script_env
	end
	if typeof(getsenv) ~= "function" then
		return nil
	end
	local ok, env = pcall(getsenv, scriptInst)
	if ok and typeof(env) == "table" then
		return env
	end
	return nil
end

local function patchArsenalClientFire(env)
	if typeof(env) ~= "table" or not CONFIG.RapidFireEnabled then
		return
	end
	local delay = getRapidFireShotDelay()
	local fireRate = getArsenalFireRateValue()
	for key, _ in env do
		if typeof(key) ~= "string" then
			continue
		end
		local lower = string.lower(key)
		if lower == "firerate" or lower == "rate" or lower == "rpm" then
			pcall(function()
				env[key] = fireRate
			end)
		elseif lower == "cooldown" or lower == "delay" or lower == "debounce" or lower == "shotdelay" or lower == "firedelay" then
			pcall(function()
				env[key] = delay
			end)
		elseif lower == "auto" or lower == "automatic" or lower == "autoshoot" then
			if CONFIG.RapidFireEnabled and mouse1Held then
				pcall(function()
					env[key] = true
				end)
			end
		end
	end
end

local function tryHookToolClientScripts(tool)
	if not CONFIG.RapidFireEnabled then
		return
	end
	if rapidFireHookedTools[tool] then
		for _, desc in tool:GetDescendants() do
			if desc:IsA("LocalScript") then
				local env = getScriptEnv(desc)
				if env then
					patchArsenalClientFire(env)
				end
			end
		end
		return
	end
	for _, desc in tool:GetDescendants() do
		if desc:IsA("LocalScript") then
			local env = getScriptEnv(desc)
			if env then
				patchArsenalClientFire(env)
				rapidFireHookedTools[tool] = true
				return
			end
		end
	end
end

local function shouldWeaponMod()
	return CONFIG.RapidFireEnabled
end

getRapidFireShotDelay = function()
	local rate = math.clamp(CONFIG.RapidFireRate, 1, 30)
	return math.clamp(0.52 - (rate - 1) * (0.495 / 29), 0.025, 0.52)
end

getArsenalFireRateValue = function()
	local rate = math.clamp(CONFIG.RapidFireRate, 1, 30)
	return math.clamp(0.5 - (rate - 1) * (0.48 / 29), 0.02, 0.5)
end

rememberValue = function(inst, value)
	if rapidFireOriginals[inst] == nil then
		rapidFireOriginals[inst] = value
	end
end

rememberAttribute = function(inst, name, value)
	local bucket = rapidFireOriginalAttrs[inst]
	if not bucket then
		bucket = {}
		rapidFireOriginalAttrs[inst] = bucket
	end
	if bucket[name] == nil then
		bucket[name] = value
	end
end

local function patchWeaponInstance(inst, fireRateValue)
	if CONFIG.RapidFireEnabled then
		if inst:IsA("BoolValue") then
			if RAPID_FIRE_AUTO_BOOLS[inst.Name] then
				rememberValue(inst, inst.Value)
				inst.Value = true
			elseif RAPID_FIRE_OFF_BOOLS[inst.Name] then
				rememberValue(inst, inst.Value)
				inst.Value = false
			end
		elseif inst:IsA("NumberValue") or inst:IsA("IntValue") then
			if RAPID_FIRE_NUMBER_NAMES[inst.Name] then
				rememberValue(inst, inst.Value)
				if inst.Name == "FireRate" or inst.Name == "Rate" or inst.Name == "RPM" then
					inst.Value = fireRateValue
				else
					inst.Value = math.min(inst.Value, fireRateValue)
				end
			end
		end
		for attrName, attrValue in inst:GetAttributes() do
			if attrName == "FireRate" or attrName == "Cooldown" or attrName == "Rate" then
				rememberAttribute(inst, attrName, attrValue)
				inst:SetAttribute(attrName, fireRateValue)
			elseif attrName == "Auto" or attrName == "Automatic" then
				rememberAttribute(inst, attrName, attrValue)
				inst:SetAttribute(attrName, true)
			end
		end
	end
end

patchToolTree = function(root)
	if not shouldWeaponMod() then
		return
	end
	local fireRateValue = getArsenalFireRateValue()
	patchWeaponInstance(root, fireRateValue)
	for _, descendant in root:GetDescendants() do
		patchWeaponInstance(descendant, fireRateValue)
	end
end

local function patchAllWeaponStats(includeWeaponsConfig)
	if not shouldWeaponMod() then
		return
	end
	local now = os.clock()
	local fireRateValue = getArsenalFireRateValue()
	if includeWeaponsConfig or now - lastWeaponsConfigPatch > 30 then
		lastWeaponsConfigPatch = now
		local weapons = ReplicatedStorage:FindFirstChild("Weapons")
		if weapons then
			for _, descendant in weapons:GetDescendants() do
				patchWeaponInstance(descendant, fireRateValue)
			end
		end
	end
	local character = localPlayer.Character
	if character then
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				patchToolTree(child)
			end
		end
	end
	for _, child in localPlayer.Backpack:GetChildren() do
		if child:IsA("Tool") then
			patchToolTree(child)
		end
	end
	lastWeaponPatch = now
end

local function restoreWeaponStats()
	for inst, original in rapidFireOriginals do
		pcall(function()
			if inst.Parent and (inst:IsA("BoolValue") or inst:IsA("NumberValue") or inst:IsA("IntValue")) then
				inst.Value = original
			end
		end)
	end
	for inst, attrs in rapidFireOriginalAttrs do
		pcall(function()
			if inst.Parent then
				for name, value in attrs do
					inst:SetAttribute(name, value)
				end
			end
		end)
	end
	table.clear(rapidFireOriginals)
	table.clear(rapidFireOriginalAttrs)
end

local function disconnectRapidFireWatchers()
	for _, connection in rapidFireWatchConnections do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(rapidFireWatchConnections)
end

local function connectRapidFireWatchers()
	disconnectRapidFireWatchers()
	if not shouldWeaponMod() then
		return
	end
	local weapons = ReplicatedStorage:FindFirstChild("Weapons")
	if weapons then
		table.insert(
			rapidFireWatchConnections,
			weapons.DescendantAdded:Connect(function(descendant)
				patchWeaponInstance(descendant, getArsenalFireRateValue())
			end)
		)
	end
	local function watchCharacter(character)
		table.insert(
			rapidFireWatchConnections,
			character.ChildAdded:Connect(function(child)
				if child:IsA("Tool") then
					task.defer(function()
						patchToolTree(child)
					end)
				end
			end)
		)
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				patchToolTree(child)
			end
		end
	end
	if localPlayer.Character then
		watchCharacter(localPlayer.Character)
	end
	table.insert(
		rapidFireWatchConnections,
		localPlayer.CharacterAdded:Connect(function(character)
			if shouldWeaponMod() then
				watchCharacter(character)
				patchAllWeaponStats(false)
			end
		end)
	)
	table.insert(
		rapidFireWatchConnections,
		localPlayer.Backpack.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				patchToolTree(child)
			end
		end)
	)
end

local function refreshWeaponMods()
	restoreWeaponStats()
	table.clear(rapidFireHookedTools)
	lastWeaponsConfigPatch = 0
	if shouldWeaponMod() then
		patchAllWeaponStats(true)
		connectRapidFireWatchers()
	else
		disconnectRapidFireWatchers()
	end
end

startRapidFire = function()
	pcall(refreshWeaponMods)
end

stopRapidFire = function()
	pcall(refreshWeaponMods)
end

refreshRapidFireStats = function()
	pcall(refreshWeaponMods)
end

activateHeldTool = function()
	if silentAimEnabled then
		pcall(redirectSilentAimForShot)
	end
	local character = localPlayer.Character
	if not character then
		return
	end
	for _, child in character:GetChildren() do
		if child:IsA("Tool") then
			fireToolConnections(child)
			pcall(function()
				child:Activate()
			end)
		end
	end
end

updateRapidFire = function()
	if menuOpen then
		return
	end
	local now = os.clock()
	if shouldWeaponMod() and now - lastWeaponPatch > 8 then
		patchAllWeaponStats(false)
	end
	if not CONFIG.RapidFireEnabled or not mouse1Held then
		return
	end
	local character = localPlayer.Character
	if character then
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				tryHookToolClientScripts(child)
			end
		end
	end
	if now - lastRapidFireShot < getRapidFireShotDelay() then
		return
	end
	lastRapidFireShot = now
	activateHeldTool()
end

end -- rapid fire module scope

setSilentAimEnabled = function(value)
	silentAimEnabled = value
	if toggleUI.silentAim then
		toggleUI.silentAim.Set(silentAimEnabled)
	end
	if not silentAimEnabled then
		silentAimTarget = nil
		silentAimPart = nil
		silentAimPosition = nil
		clearSilentAimSticky()
		silentMarker.Visible = false
		silentAimChangedEvent:Fire(false, nil, nil, nil)
	end
end

do
local raycastHookInstalled = false
local legacyRayHooksInstalled = false
local rayHookDepth = 0
local combatShotActive = false

local function wantsCombatRayRedirect()
	if menuOpen or not silentAimEnabled or not mouse1Held then
		return false
	end
	return getEquippedTool() ~= nil
end

local function getEquippedTool()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	for _, child in character:GetChildren() do
		if child:IsA("Tool") then
			return child
		end
	end
	return nil
end

local function buildSilentRayResult(origin, hitPart, hitPos)
	local delta = hitPos - origin
	local dist = delta.Magnitude
	local normal = if dist > 0.01 then -delta.Unit else Vector3.yAxis
	return {
		Instance = hitPart,
		Position = hitPos,
		Normal = normal,
		Material = Enum.Material.Plastic,
		Distance = dist,
	}
end

local function looksLikeWeaponRay(origin, direction)
	if menuOpen or not mouse1Held then
		return false
	end
	if not getEquippedTool() then
		return false
	end
	if not silentAimEnabled then
		return false
	end
	local mag = direction.Magnitude
	if mag < 0.05 or mag > 8000 then
		return false
	end
	local character = localPlayer.Character
	if not character then
		return false
	end
	camera = workspace.CurrentCamera
	local pivot = character:GetPivot().Position
	local charDist = (origin - pivot).Magnitude
	local camDist = if camera then (origin - camera.CFrame.Position).Magnitude else charDist
	if camDist > 35 then
		return false
	end
	local aimDir = direction.Unit
	local lookDir = camera and camera.CFrame.LookVector or direction.Unit
	-- Only reject rays fired clearly away from the camera; silent aim may aim off-target.
	if aimDir:Dot(lookDir) < -0.15 then
		return false
	end
	return true
end

local function getCombatRayRedirect()
	local aimPos, part = resolveSilentAimShot()
	if part and aimPos then
		return part, aimPos
	end
	return nil, nil
end

local function tryRedirectShot(origin, direction)
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return nil, nil
	end
	if not looksLikeWeaponRay(origin, direction) then
		return nil, nil
	end
	return getCombatRayRedirect()
end

local function redirectLegacyRay(origin, direction)
	local redirectPart, redirectPos = tryRedirectShot(origin, direction)
	if not redirectPart or not redirectPos then
		return nil, nil, nil
	end
	local delta = redirectPos - origin
	local normal = if delta.Magnitude > 0.01 then -delta.Unit else Vector3.yAxis
	return redirectPart, redirectPos, normal
end

local function installRaycastFunctionHook()
	if raycastHookInstalled then
		return
	end
	local g = getgenv()
	local hookfunction = g.hookfunction
	if typeof(hookfunction) ~= "function" and typeof(g.syn) == "table" then
		hookfunction = g.syn.hook_function
	end
	if typeof(hookfunction) ~= "function" then
		return
	end
	local oldRay = workspace.Raycast
	hookfunction(oldRay, function(origin, direction, params)
		if not combatShotActive or rayHookDepth > 0 or menuOpen then
			return oldRay(origin, direction, params)
		end
		local redirectPart, redirectPos = tryRedirectShot(origin, direction)
		if redirectPart and redirectPos then
			rayHookDepth += 1
			local result = buildSilentRayResult(origin, redirectPart, redirectPos)
			rayHookDepth -= 1
			return result
		end
		return oldRay(origin, direction, params)
	end)
	raycastHookInstalled = true
end

local function installLegacyRayHooks()
	if legacyRayHooksInstalled then
		return
	end
	local g = getgenv()
	local hookfunction = g.hookfunction
	if typeof(hookfunction) ~= "function" and typeof(g.syn) == "table" then
		hookfunction = g.syn.hook_function
	end
	if typeof(hookfunction) ~= "function" then
		return
	end
	local oldFindPartOnRay = workspace.FindPartOnRay
	if typeof(oldFindPartOnRay) == "function" then
		hookfunction(oldFindPartOnRay, function(ray, ignore, ...)
			if not combatShotActive or rayHookDepth > 0 or menuOpen or typeof(ray) ~= "Ray" then
				return oldFindPartOnRay(ray, ignore, ...)
			end
			local redirectPart, redirectPos, normal = redirectLegacyRay(ray.Origin, ray.Direction)
			if redirectPart and redirectPos and normal then
				return redirectPart, redirectPos, normal, Enum.Material.Plastic
			end
			return oldFindPartOnRay(ray, ignore, ...)
		end)
	end
	local oldFindPartOnRayWithWhitelist = workspace.FindPartOnRayWithWhitelist
	if typeof(oldFindPartOnRayWithWhitelist) == "function" then
		hookfunction(oldFindPartOnRayWithWhitelist, function(ray, whitelist, ignore, ...)
			if not combatShotActive or rayHookDepth > 0 or menuOpen or typeof(ray) ~= "Ray" then
				return oldFindPartOnRayWithWhitelist(ray, whitelist, ignore, ...)
			end
			local redirectPart, redirectPos, normal = redirectLegacyRay(ray.Origin, ray.Direction)
			if redirectPart and redirectPos and normal then
				return redirectPart, redirectPos, normal, Enum.Material.Plastic
			end
			return oldFindPartOnRayWithWhitelist(ray, whitelist, ignore, ...)
		end)
	end
	legacyRayHooksInstalled = true
end

local function installCombatRayHooks()
	local ok, err = pcall(function()
		installRaycastFunctionHook()
		installLegacyRayHooks()
	end)
	if not ok then
		logError("CombatHook", err, "ray hook install")
	end
	return ok
end

beginCombatShotWindow = function()
	if not wantsCombatRayRedirect() then
		return
	end
	combatShotActive = true
	pcall(installCombatRayHooks)
end

endCombatShotWindow = function()
	combatShotActive = false
end

installCombatRayHook = installCombatRayHooks

redirectSilentAimForShot = function()
	if not CONFIG.SilentAimSnapOnFire or not silentAimEnabled then
		return
	end
	local aimPos = resolveSilentAimShot()
	if not aimPos then
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local saved = camera.CFrame
	camera.CFrame = CFrame.lookAt(camera.CFrame.Position, aimPos)
	task.defer(function()
		if camera and camera.Parent then
			camera.CFrame = saved
		end
	end)
end

clearSilentAimLock = function()
	local hadTarget = silentAimTarget ~= nil
	silentAimTarget = nil
	silentAimPart = nil
	silentAimPosition = nil
	silentMarker.Visible = false
	if hadTarget then
		silentAimChangedEvent:Fire(silentAimEnabled, nil, nil, nil)
	end
end

local function updateSilentAimPreview(targetPlayer)
	if not CONFIG.SilentAimShowMarker or not targetPlayer then
		silentMarker.Visible = false
		return
	end
	local character = targetPlayer.Character
	if not character or not isAlive(character) then
		silentMarker.Visible = false
		return
	end
	local part = getTargetPart(character)
	if not part then
		silentMarker.Visible = false
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
	if onScreen and screenPos.Z > 0 then
		silentMarker.Visible = true
		silentMarker.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
		local stroke = silentMarker:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = CONFIG.SilentAimMarkerColor
		end
	else
		silentMarker.Visible = false
	end
end

updateSilentAimLock = function(targetPlayer)
	if not silentAimEnabled then
		clearSilentAimLock()
		return
	end
	if not targetPlayer then
		clearSilentAimLock()
		return
	end
	local character = targetPlayer.Character
	if not character or not isAlive(character) then
		clearSilentAimLock()
		return
	end
	local part = getTargetPart(character)
	if not part then
		clearSilentAimLock()
		return
	end
	local targetChanged = silentAimTarget ~= targetPlayer or silentAimPart ~= part
	silentAimTarget = targetPlayer
	silentAimPart = part
	silentAimPosition = getPredictedAimPosition(part, character)
	if CONFIG.SilentAimShowMarker then
		local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
		if onScreen and screenPos.Z > 0 then
			silentMarker.Visible = true
			silentMarker.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
			local stroke = silentMarker:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = CONFIG.SilentAimMarkerColor
			end
		else
			silentMarker.Visible = false
		end
	else
		silentMarker.Visible = false
	end
	if targetChanged then
		silentAimChangedEvent:Fire(true, silentAimPart, silentAimPosition, silentAimTarget)
	end
end

local lastSilentShot = 0
local activeTracer= nil
local tracerAtt0= nil
local tracerAtt1= nil
local tracerPart0= nil
local tracerPart1= nil

local function clearTracer()
	if activeTracer then
		activeTracer:Destroy()
		activeTracer = nil
	end
	if tracerAtt0 then
		tracerAtt0:Destroy()
		tracerAtt0 = nil
	end
	if tracerAtt1 then
		tracerAtt1:Destroy()
		tracerAtt1 = nil
	end
	if tracerPart0 then
		tracerPart0:Destroy()
		tracerPart0 = nil
	end
	if tracerPart1 then
		tracerPart1:Destroy()
		tracerPart1 = nil
	end
end

local function showSilentTracer(fromPos, toPos)
	clearTracer()
	if not CONFIG.SilentAimShowTracer then
		return
	end
	local p0 = Instance.new("Part")
	p0.Name = "NameHubSilentTracer0"
	p0.Anchored = true
	p0.CanCollide = false
	p0.CanQuery = false
	p0.CanTouch = false
	p0.Transparency = 1
	p0.Size = Vector3.new(0.2, 0.2, 0.2)
	p0.CFrame = CFrame.new(fromPos)
	p0.Parent = workspace.CurrentCamera or workspace
	local p1 = Instance.new("Part")
	p1.Name = "NameHubSilentTracer1"
	p1.Anchored = true
	p1.CanCollide = false
	p1.CanQuery = false
	p1.CanTouch = false
	p1.Transparency = 1
	p1.Size = Vector3.new(0.2, 0.2, 0.2)
	p1.CFrame = CFrame.new(toPos)
	p1.Parent = p0.Parent
	local a0 = Instance.new("Attachment")
	a0.Parent = p0
	local a1 = Instance.new("Attachment")
	a1.Parent = p1
	local beam = Instance.new("Beam")
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.12
	beam.Width1 = 0.04
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(CONFIG.SilentAimMarkerColor)
	beam.Transparency = NumberSequence.new(0.15)
	beam.Parent = p0
	activeTracer = beam
	tracerAtt0 = a0
	tracerAtt1 = a1
	tracerPart0 = p0
	tracerPart1 = p1
	task.delay(CONFIG.SilentAimTracerTime, function()
		clearTracer()
	end)
end

isMouseOverMenu = function()
	if not menuOpen or not menuFrame.Visible then
		return false
	end
	local mouse = UserInputService:GetMouseLocation()
	local pos = menuFrame.AbsolutePosition
	local size = menuFrame.AbsoluteSize
	return mouse.X >= pos.X
		and mouse.X <= pos.X + size.X
		and mouse.Y >= pos.Y
		and mouse.Y <= pos.Y + size.Y
end

local function getSilentFireOrigin()
	camera = workspace.CurrentCamera
	local character = localPlayer.Character
	if character then
		local originPart = getCharacterPart(character, CONFIG.RaycastOriginPart)
			or getCharacterPart(character, "Head")
			or getCharacterPart(character, "HumanoidRootPart")
		if originPart then
			return originPart.Position
		end
	end
	if camera then
		return camera.CFrame.Position
	end
	return Vector3.zero
end

local function resolveFireTarget()
	if silentAimEnabled then
		local aimPos, aimPart, aimPlayer = resolveSilentAimShot()
		if aimPos and aimPart then
			return aimPos, aimPart, aimPlayer
		end
	end
	if aimShouldLock() and currentTarget then
		local character = currentTarget.Character
		if character and isAlive(character) and passesTeamCheck(currentTarget) then
			local part = getTargetPart(character)
			if part then
				return getPredictedAimPosition(part, character), part, currentTarget
			end
		end
	end
	return nil, nil, nil
end

trySilentAimFire = function()
	if not (silentAimEnabled and CONFIG.SilentAimClickFire) then
		return false
	end
	local aimPos, aimPart, aimPlayer = resolveFireTarget()
	if not aimPos or not aimPart then
		return false
	end
	if isMouseOverMenu() then
		return false
	end
	local now = os.clock()
	if now - lastSilentShot < CONFIG.SilentAimFireCooldown then
		return false
	end
	lastSilentShot = now
	local origin = getSilentFireOrigin()
	local toTarget = aimPos - origin
	local distance = toTarget.Magnitude
	if distance < 0.05 then
		return false
	end
	local direction = toTarget.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclude= {}
	if localPlayer.Character then
		table.insert(exclude, localPlayer.Character)
	end
	params.FilterDescendantsInstances = exclude
	local result = workspace:Raycast(origin, direction * (distance + 4), params)
	local hitPos = if result then result.Position else aimPos
	showSilentTracer(origin, hitPos)
	silentAimShotEvent:Fire({
		Origin = origin,
		Direction = direction,
		AimPosition = aimPos,
		HitPosition = hitPos,
		HitInstance = aimPart,
		HitCharacter = aimPlayer and aimPlayer.Character,
		TargetPlayer = aimPlayer,
		TargetPart = aimPart,
	})
	redirectSilentAimForShot()
	activateHeldTool()
	return true
end

end -- combat module scope

local function releaseAimHold()
	aimKeyHeld = false
	if not enabled then
		currentTarget = nil
		lockedTarget = nil
		aimLookAt = nil
		setAimCameraActive(false)
		fovCircle.Visible = false
		targetMarker.Visible = false
	end
end

local function pressAimBind()
	if CONFIG.AimActivationMode == "Hold" then
		aimKeyHeld = true
		notify("Aim Assist", "Locked")
	else
		enabled = not enabled
		enableToggle.Set(enabled)
		currentTarget = nil
		lockedTarget = nil
		aimLookAt = nil
		if not enabled then
			setAimCameraActive(false)
			fovCircle.Visible = false
			targetMarker.Visible = false
		end
		notify("Aim Assist", if enabled then "Enabled" else "Disabled")
	end
end

bindConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not scriptAlive then
		return
	end
	if listeningForKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				listeningForKeybind.cancel()
			elseif listeningForKeybind.applyKey then
				listeningForKeybind.applyKey(input.KeyCode)
			end
		elseif listeningForKeybind.applyMouse and isMouseBindInput(input.UserInputType) then
			listeningForKeybind.applyMouse(input.UserInputType)
		end
		return
	end
	-- Menu key always works (games may mark Insert as processed)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.MenuKey then
		setMenuVisible(not menuOpen)
		notify("Menu", if menuOpen then "Opened" else "Closed")
		return
	end
	-- Aim bind (keyboard or mouse) — keyboard only blocks other binds; mouse still shoots
	if inputMatchesAimBind(input) then
		if menuOpen and isMouseOverMenu() then
			return
		end
		pressAimBind()
		if input.UserInputType == Enum.UserInputType.Keyboard then
			return
		end
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if menuOpen then
			return
		end
		mouse1Held = true
		beginCombatShotWindow()
		if aimShouldLock() then
			aimLockPausedUntil = os.clock() + 0.12
		end
		local silentFired = trySilentAimFire()
		if not silentFired and CONFIG.AimClickFire and aimShouldLock() then
			activateHeldTool()
		end
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if inputMatchesAimBind(input) then
			return
		end
	end
	if gameProcessed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if input.KeyCode == CONFIG.FlyKey then
		setFlyEnabled(not flyEnabled)
		notify("Fly", if flyEnabled then "Enabled" else "Disabled")
		return
	end
	if input.KeyCode == CONFIG.NoclipKey then
		if setNoclipEnabled then
			setNoclipEnabled(not noclipEnabled)
		else
			noclipEnabled = not noclipEnabled
		end
		notify("Noclip", if noclipEnabled then "Enabled" else "Disabled")
		return
	end
	if input.KeyCode == CONFIG.ThirdPersonKey then
		setThirdPersonEnabled(not CONFIG.ThirdPersonEnabled)
		notify("Third Person", if CONFIG.ThirdPersonEnabled then "Enabled" else "Disabled")
		return
	end
	if input.KeyCode == CONFIG.SilentAimKey then
		setSilentAimEnabled(not silentAimEnabled)
		notify("Silent Aim", if silentAimEnabled then "Enabled" else "Disabled")
	end
end))

bindConnection(UserInputService.InputEnded:Connect(function(input)
	if not scriptAlive then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouse1Held = false
		endCombatShotWindow()
	end
	if inputMatchesAimBind(input) and CONFIG.AimActivationMode == "Hold" then
		releaseAimHold()
		notify("Aim Assist", "Released")
	end
end))

bindConnection(UserInputService.InputChanged:Connect(function(input, _gameProcessed)
	if not scriptAlive or menuOpen then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseWheel then
		return
	end
	if not CONFIG.ThirdPersonEnabled then
		return
	end
	local scrollDelta = input.Position.Z
	if math.abs(scrollDelta) < 0.01 then
		return
	end
	adjustThirdPersonZoom(if scrollDelta > 0 then 1 else -1)
end))

bindConnection(RunService.RenderStepped:Connect(function()
	if not scriptAlive then
		return
	end
	-- Games like Arsenal re-lock the mouse every frame — keep cursor free while menu is open
	if menuOpen then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local now = os.clock()
	local okLoop, loopErr = pcall(function()
		if now - perfTicks.esp >= 0.055 then
			perfTicks.esp = now
			updateEsp()
		end
		updateFly()
		if now - perfTicks.noclip >= 0.2 then
			perfTicks.noclip = now
			updateNoclip()
		end
		if now - perfTicks.movement >= 0.15 then
			perfTicks.movement = now
			updateMovement()
		end
		updateRapidFire()
		if now - perfTicks.knife >= 0.35 then
			perfTicks.knife = now
			updateAutoKnife()
		end
		if now - perfTicks.weaponRainbow >= 0.05 then
			perfTicks.weaponRainbow = now
			updateRainbowWeapons()
		end
		local scanTarget = findClosestTarget()
		local targetingActive = aimShouldLock() or silentAimEnabled
		if not targetingActive then
			fovCircle.Visible = false
			targetMarker.Visible = false
			if not silentAimEnabled then
				clearSilentAimLock()
			end
			if not enabled then
				setAimCameraActive(false)
			end
			if silentAimEnabled then
				if CONFIG.SilentAimStickyLock then
					updateSilentAimLock(acquireSilentAimTarget(scanTarget))
				else
					clearSilentAimLock()
					updateSilentAimPreview(findClosestTarget(getSilentAimScanPosition()))
				end
			else
				clearSilentAimLock()
			end
			return
		end
		local mousePos = getMouseScreenPosition()
		local overMenu = menuOpen and isMouseOverMenu()
		if CONFIG.ShowFOVCircle and not overMenu then
			fovCircle.Visible = true
			fovCircle.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
		else
			fovCircle.Visible = false
		end
		local scanTarget = findClosestTarget()
		if aimShouldLock() then
			currentTarget = acquireAimTarget(scanTarget)
			setAimCameraActive(true)
		else
			currentTarget = nil
			lockedTarget = nil
			aimLookAt = nil
			setAimCameraActive(false)
		end
		if silentAimEnabled then
			if CONFIG.SilentAimStickyLock then
				updateSilentAimLock(acquireSilentAimTarget(scanTarget))
			else
				clearSilentAimLock()
				updateSilentAimPreview(findClosestTarget(getSilentAimScanPosition()))
			end
		else
			clearSilentAimLock()
		end
		if not aimShouldLock() then
			targetMarker.Visible = false
			return
		end
		if not currentTarget then
			targetMarker.Visible = false
			aimLookAt = nil
			return
		end
		local character = currentTarget.Character
		if not character or not isAlive(character) then
			currentTarget = nil
			lockedTarget = nil
			aimLookAt = nil
			targetMarker.Visible = false
			return
		end
		local targetPart = getTargetPart(character)
		if not targetPart then
			currentTarget = nil
			lockedTarget = nil
			aimLookAt = nil
			targetMarker.Visible = false
			return
		end
		if CONFIG.ShowTargetMarker and not overMenu then
			local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
			if onScreen and screenPos.Z > 0 then
				targetMarker.Visible = true
				targetMarker.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
			else
				targetMarker.Visible = false
			end
		else
			targetMarker.Visible = false
		end
		if not overMenu then
			local aimPos = getPredictedAimPosition(targetPart, character)
			smoothLookAt(aimPos, CONFIG.Smoothness)
		else
			aimLookAt = nil
		end
	end)
	if not okLoop then
		logError("Loop", loopErr, "RenderStepped")
	end
	if CONFIG.ThirdPersonEnabled then
		pcall(updateSpinBot)
		pcall(updateThirdPerson)
	end
end))

unloadNameHub = function()
	if not scriptAlive then
		return
	end
	notify("NameHub", "Unloading…")
	scriptAlive = false
	pcall(function()
		enabled = false
		silentAimEnabled = false
		noclipEnabled = false
		if setNoclipEnabled then
			setNoclipEnabled(false)
		end
		lockedTarget = nil
		aimLookAt = nil
		setAimCameraActive(false)
		pcall(function()
			RunService:UnbindFromRenderStep("NameHubAimLock")
		end)
		aimRenderBound = false
		setFlyEnabled(false)
		setThirdPersonEnabled(false)
		setSpinBotEnabled(false)
		CONFIG.SpeedEnabled = false
		CONFIG.JumpEnabled = false
		if toggleUI.speed then
			toggleUI.speed.Set(false)
		end
		if toggleUI.jump then
			toggleUI.jump.Set(false)
		end
		pcall(applyMovementMods)
		CONFIG.RapidFireEnabled = false
		if toggleUI.rapidFire then
			toggleUI.rapidFire.Set(false)
		end
		stopRapidFire()
		CONFIG.RainbowWeaponsEnabled = false
		if toggleUI.rainbowWeapons then
			toggleUI.rainbowWeapons.Set(false)
		end
		pcall(restoreRainbowWeapons)
		clearAllEsp()
		clearSilentAimLock()
		fovCircle.Visible = false
		targetMarker.Visible = false
		silentMarker.Visible = false
	end)
	for _, connection in scriptConnections do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(scriptConnections)
	for player, track in trackedPlayers do
		if track.characterAdded then
			pcall(function()
				track.characterAdded:Disconnect()
			end)
		end
		if track.characterRemoving then
			pcall(function()
				track.characterRemoving:Disconnect()
			end)
		end
		trackedPlayers[player] = nil
	end
	pcall(function()
		nameHubApi:Destroy()
	end)
	pcall(function()
		screenGui:Destroy()
	end)
	pcall(function()
		local g = getgenv()
		if g.NameHubUnload == unloadNameHub then
			g.NameHubUnload = nil
		end
	end)
	print("[NameHub] Unloaded.")
end

end -- bootstrapGameplay

do -- config profiles (save / load / auto-load)
local CONFIG_ROOT = "NameHub/configs"
local META_PATH = CONFIG_ROOT .. "/_meta.json"

local function getFsFn(name)
	local g = getgenv()
	local fn = (g )[name]
	if typeof(fn) == "function" then
		return fn
	end
	return (getfenv() )[name]
end

local function fsReady()
	return typeof(getFsFn("writefile")) == "function" and typeof(getFsFn("readfile")) == "function"
end

local function ensureConfigRoot()
	if not fsReady() then
		return false
	end
	local makefolder = getFsFn("makefolder")
	local isfolder = getFsFn("isfolder")
	pcall(function()
		if typeof(isfolder) == "function" and not isfolder("NameHub") then
			makefolder("NameHub")
		end
		if typeof(isfolder) == "function" and not isfolder(CONFIG_ROOT) then
			makefolder(CONFIG_ROOT)
		end
	end)
	return true
end

local function sanitizeProfileName(raw)
	local trimmed = string.gsub(raw, "^%s*(.-)%s*$", "%1")
	trimmed = string.gsub(trimmed, "[^%w%-_ ]", "")
	if #trimmed > 40 then
		trimmed = string.sub(trimmed, 1, 40)
	end
	if trimmed == "" then
		return "Default"
	end
	return trimmed
end

local function profilePath(name)
	return CONFIG_ROOT .. "/" .. sanitizeProfileName(name) .. ".json"
end

local function encodeConfigValue(value)
	local t = typeof(value)
	if t == "Color3" then
		return { __t = "Color3", r = value.R, g = value.G, b = value.B }
	elseif t == "EnumItem" then
		return { __t = "Enum", e = tostring(value.EnumType), n = value.Name }
	end
	return value
end

local function decodeConfigValue(value)
	if type(value) == "table" and value.__t == "Color3" then
		return Color3.new(value.r, value.g, value.b)
	end
	if type(value) == "table" and value.__t == "Enum" then
		if value.e == "KeyCode" and Enum.KeyCode[value.n] then
			return Enum.KeyCode[value.n]
		end
		if value.e == "UserInputType" and Enum.UserInputType[value.n] then
			return Enum.UserInputType[value.n]
		end
	end
	return value
end

local function readMeta()
	if not ensureConfigRoot() then
		return { active = nil, order = {} }
	end
	local readfile = getFsFn("readfile")
	local isfile = getFsFn("isfile")
	if typeof(isfile) ~= "function" or not isfile(META_PATH) then
		return { active = nil, order = {} }
	end
	local ok, raw = pcall(readfile, META_PATH)
	if not ok or type(raw) ~= "string" or raw == "" then
		return { active = nil, order = {} }
	end
	local decodedOk, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not decodedOk or type(decoded) ~= "table" then
		return { active = nil, order = {} }
	end
	if type(decoded.order) ~= "table" then
		decoded.order = {}
	end
	return decoded
end

local function writeMeta(meta)
	if not ensureConfigRoot() then
		return false
	end
	local writefile = getFsFn("writefile")
	local ok = pcall(function()
		writefile(META_PATH, HttpService:JSONEncode(meta))
	end)
	return ok
end

local function listSavedProfiles()
	local names= {}
	local meta = readMeta()
	if meta.order then
		for _, name in meta.order do
			if type(name) == "string" and name ~= "" then
				table.insert(names, name)
			end
		end
	end
	local listfiles = getFsFn("listfiles")
	if typeof(listfiles) == "function" then
		local ok, files = pcall(listfiles, CONFIG_ROOT)
		if ok and type(files) == "table" then
			for _, path in files do
				if type(path) == "string" and string.sub(path, -5) == ".json" then
					local base = string.match(path, "([^/\\]+)%.json$")
					if base and base ~= "_meta" then
						if not table.find(names, base) then
							table.insert(names, base)
						end
					end
				end
			end
		end
	end
	table.sort(names, function(a, b)
		return string.lower(a) < string.lower(b)
	end)
	return names
end

local function setActiveProfileName(name)
	local meta = readMeta()
	meta.active = sanitizeProfileName(name)
	if not meta.order then
		meta.order = {}
	end
	if not table.find(meta.order, meta.active) then
		table.insert(meta.order, meta.active)
	end
	writeMeta(meta)
end

local function getActiveProfileName()
	local meta = readMeta()
	if type(meta.active) == "string" and meta.active ~= "" then
		return meta.active
	end
	return nil
end

local function buildSnapshot(profileName)
	local cfg= {}
	for key, val in CONFIG do
		if not CONFIG_SKIP_SAVE[key] then
			cfg[key] = encodeConfigValue(val)
		end
	end
	return {
		v = 1,
		name = sanitizeProfileName(profileName),
		savedAt = os.time(),
		config = cfg,
		runtime = {
			enabled = enabled,
			flyEnabled = flyEnabled,
			noclipEnabled = noclipEnabled,
			silentAimEnabled = silentAimEnabled,
		},
	}
end

local function applySnapshot(snapshot)
	if type(snapshot) ~= "table" or type(snapshot.config) ~= "table" then
		return false
	end

	for key, val in snapshot.config do
		if type(key) == "string" and not CONFIG_SKIP_SAVE[key] then
			CONFIG[key] = decodeConfigValue(val)
		end
	end

	local rt = if type(snapshot.runtime) == "table" then snapshot.runtime else {}

	enabled = rt.enabled == true
	if toggleUI.aimAssist then
		toggleUI.aimAssist.Set(enabled)
	end
	currentTarget = nil
	lockedTarget = nil
	aimLookAt = nil
	setAimCameraActive(false)
	if not enabled then
		fovCircle.Visible = false
		targetMarker.Visible = false
	end

	if setFlyEnabled then
		setFlyEnabled(rt.flyEnabled == true)
	else
		flyEnabled = rt.flyEnabled == true
		if toggleUI.fly then
			toggleUI.fly.Set(flyEnabled)
		end
	end

	if setNoclipEnabled then
		setNoclipEnabled(rt.noclipEnabled == true)
	else
		noclipEnabled = rt.noclipEnabled == true
		if toggleUI.noclip then
			toggleUI.noclip.Set(noclipEnabled)
		end
	end

	if setSilentAimEnabled then
		setSilentAimEnabled(rt.silentAimEnabled == true)
	else
		silentAimEnabled = rt.silentAimEnabled == true
		if toggleUI.silentAim then
			toggleUI.silentAim.Set(silentAimEnabled)
		end
	end

	if toggleUI.rapidFire then
		toggleUI.rapidFire.Set(CONFIG.RapidFireEnabled == true)
	end
	if toggleUI.rainbowWeapons then
		toggleUI.rainbowWeapons.Set(CONFIG.RainbowWeaponsEnabled == true)
	end
	if toggleUI.espMaster then
		toggleUI.espMaster.Set(CONFIG.ESPEnabled == true)
	end
	if toggleUI.speed then
		toggleUI.speed.Set(CONFIG.SpeedEnabled == true)
	end
	if toggleUI.jump then
		toggleUI.jump.Set(CONFIG.JumpEnabled == true)
	end
	if setThirdPersonEnabled then
		setThirdPersonEnabled(CONFIG.ThirdPersonEnabled == true)
	elseif toggleUI.thirdPerson then
		toggleUI.thirdPerson.Set(CONFIG.ThirdPersonEnabled == true)
	end
	if setSpinBotEnabled then
		setSpinBotEnabled(CONFIG.SpinBotEnabled == true)
	elseif toggleUI.spinBot then
		toggleUI.spinBot.Set(CONFIG.SpinBotEnabled == true)
	end
	pcall(applyMovementMods)

	pcall(function()
		applyTheme(CONFIG.ThemeName)
	end)
	refreshOverlayFromConfig()
	pcall(refreshRapidFireStats)
	if CONFIG.RainbowWeaponsEnabled then
		pcall(updateRainbowWeapons)
	else
		pcall(restoreRainbowWeapons)
	end
	if not CONFIG.ESPEnabled then
		pcall(clearAllEsp)
	end

	logInfo("Config", "Applied profile settings")
	return true
end

local function readSnapshot(name)
	if not ensureConfigRoot() then
		return nil
	end
	local path = profilePath(name)
	local readfile = getFsFn("readfile")
	local isfile = getFsFn("isfile")
	if typeof(isfile) ~= "function" or not isfile(path) then
		return nil
	end
	local ok, raw = pcall(readfile, path)
	if not ok or type(raw) ~= "string" or raw == "" then
		return nil
	end
	local decodedOk, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not decodedOk then
		return nil
	end
	return decoded
end

local function writeSnapshot(name, snapshot)
	if not ensureConfigRoot() then
		return false
	end
	local writefile = getFsFn("writefile")
	local path = profilePath(name)
	local ok = pcall(function()
		writefile(path, HttpService:JSONEncode(snapshot))
	end)
	if ok then
		setActiveProfileName(name)
	end
	return ok
end

saveNameHubProfile = function(name)
	local clean = sanitizeProfileName(name)
	local snapshot = buildSnapshot(clean)
	local ok = writeSnapshot(clean, snapshot)
	if ok then
		logInfo("Config", "Saved profile \"" .. clean .. "\"")
	end
	return ok
end

loadNameHubProfile = function(name)
	local clean = sanitizeProfileName(name)
	local snapshot = readSnapshot(clean)
	if not snapshot then
		return false
	end
	local applied = applySnapshot(snapshot)
	if applied then
		setActiveProfileName(clean)
		logInfo("Config", "Loaded profile \"" .. clean .. "\"")
	end
	return applied
end

deleteNameHubProfile = function(name)
	if not ensureConfigRoot() then
		return false
	end
	local clean = sanitizeProfileName(name)
	local path = profilePath(clean)
	local delfile = getFsFn("delfile")
	local isfile = getFsFn("isfile")
	if typeof(isfile) == "function" and not isfile(path) then
		return false
	end
	local ok = false
	if typeof(delfile) == "function" then
		ok = pcall(delfile, path)
	end
	local meta = readMeta()
	if meta.order then
		local nextOrder= {}
		for _, entry in meta.order do
			if entry ~= clean then
				table.insert(nextOrder, entry)
			end
		end
		meta.order = nextOrder
	end
	if meta.active == clean then
		meta.active = meta.order and meta.order[1] or nil
	end
	writeMeta(meta)
	return ok
end

duplicateNameHubProfile = function(fromName, toName)
	local fromClean = sanitizeProfileName(fromName)
	local toClean = sanitizeProfileName(toName)
	if fromClean == toClean then
		return false
	end
	local snapshot = readSnapshot(fromClean)
	if not snapshot then
		snapshot = buildSnapshot(fromClean)
	end
	snapshot.name = toClean
	snapshot.savedAt = os.time()
	return writeSnapshot(toClean, snapshot)
end

refreshConfigProfileUI = function()
	local active = getActiveProfileName()
	if configActiveLabel then
		if active then
			configActiveLabel.Text = "Active profile: " .. active
		else
			configActiveLabel.Text = "Active profile: none (save one to enable auto-load)"
		end
	end
	if configNameBox and configSelectedProfile ~= "" then
		configNameBox.Text = configSelectedProfile
	elseif configNameBox and active and configNameBox.Text == "Default" then
		configNameBox.Text = active
	end
	if not configProfileListHost then
		return
	end
	for _, child in configProfileListHost:GetChildren() do
		if child:IsA("GuiObject") and child.Name == "ProfileRow" then
			child:Destroy()
		end
	end
	local profiles = listSavedProfiles()
	if #profiles == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "ProfileRow"
		empty.BackgroundTransparency = 1
		empty.Size = UDim2.new(1, 0, 0, 22)
		empty.Font = Enum.Font.Gotham
		empty.Text = "No saved profiles yet — type a name and press Save."
		empty.TextColor3 = THEME.SubText
		empty.TextSize = 11
		empty.TextWrapped = true
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.ZIndex = 53
		empty:SetAttribute("ThemeRole", "SubText")
		empty.Parent = configProfileListHost
		return
	end
	for index, profileName in profiles do
		local row = Instance.new("TextButton")
		row.Name = "ProfileRow"
		row.Size = UDim2.new(1, 0, 0, 30)
		row.BackgroundColor3 = if profileName == active then THEME.Accent else THEME.Element
		row.BorderSizePixel = 0
		row.AutoButtonColor = false
		row.Font = Enum.Font.GothamMedium
		row.Text = if profileName == active then profileName .. "  ★" else profileName
		row.TextColor3 = if profileName == active then Color3.fromRGB(255, 255, 255) else THEME.Text
		row.TextSize = 12
		row.LayoutOrder = index
		row.ZIndex = 53
		row:SetAttribute("ThemeRole", if profileName == active then "Accent" else "Element")
		row:SetAttribute("ThemeTextRole", if profileName == active then "White" else "Text")
		row.Parent = configProfileListHost
		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row
		row.MouseButton1Click:Connect(function()
			configSelectedProfile = profileName
			if configNameBox then
				configNameBox.Text = profileName
			end
		end)
		row.MouseButton2Click:Connect(function()
			if loadNameHubProfile(profileName) then
				configSelectedProfile = profileName
				refreshConfigProfileUI()
				notify("Configs", "Loaded \"" .. profileName .. "\"")
			end
		end)
	end
end

tryAutoLoadActiveConfig = function()
	if not CONFIG.ConfigAutoLoad then
		refreshConfigProfileUI()
		return
	end
	local active = getActiveProfileName()
	if not active then
		refreshConfigProfileUI()
		return
	end
	if loadNameHubProfile(active) then
		configSelectedProfile = active
		logInfo("Config", "Auto-loaded \"" .. active .. "\"")
	else
		logWarn("Config", "Auto-load failed for \"" .. tostring(active) .. "\"")
	end
	refreshConfigProfileUI()
end
end -- config profiles

logBootDiagnostics()
local bootOk, bootErr = safeCall("Boot", bootstrapGameplay, "bootstrapGameplay")
if not bootOk then
	notify("NameHub", "Load error — open F9 console")
else
	pcall(refreshConfigProfileUI)
	pcall(tryAutoLoadActiveConfig)
end

pcall(function()
	getgenv().NameHubUnload = unloadNameHub
end)

-- Show menu immediately so toggles work; loading screen is non-blocking
setMenuVisible(true)
notify("NameHub", "Ready — F9 console shows logs & errors")
print("[NameHub] F9 console = diagnostics (boot info, errors, feature status)")
task.spawn(function()
	pcall(playNameHubLoadingScreen)
end)
print("[NameHub] Loaded. Insert = menu · Configs tab = save/load profiles · RightShift = aim · T = silent · F = fly · N = noclip.")

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
			else
				HttpService:PostAsync(url, payload, Enum.HttpContentType.ApplicationJson, false)
			end
		end)
	end)
end

reportLoadToDiscord("Arsenal")
