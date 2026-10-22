-- NameHub Â· Da Hood build 2026-08-23T14:52:00.093Z
print("[NameHub] Boot dahood 2026-08-23T14:52:00.093Z")
--[[
	NameHub Â· Da Hood
	Fresh build for Da Hood only. Arsenal lives in /script.lua.
]]

local DA_HOOD_PLACE_IDS= {
	[2788229376] = true, -- Da Hood
}

local function isDaHoodPlace()
	return DA_HOOD_PLACE_IDS[game.PlaceId] == true
end

local CONFIG = {
	MenuKey = Enum.KeyCode.Insert,
	ToggleKey = Enum.KeyCode.RightShift,
	ToggleMouse = nil ,
	AimActivationMode = "Hold",
	FOVRadius = 280,
	ShowFOVCircle = true,
	ShowTargetMarker = true,
	ShowTargetInfo = true,
	TargetMarkerColor = Color3.fromRGB(255, 80, 80),
	Smoothness = 0.95,
	AimSnapLock = true,
	AimStickyLock = true,
	AimRapidFireEnabled = false,
	AimRapidFireRate = 18,
	TargetPartName = "Head",
	SilentAimEnabled = false,
	SilentAimKey = Enum.KeyCode.T,
	SilentFOVRadius = 280,
	SilentShowFOVCircle = true,
	SilentAimShowMarker = true,
	SilentAimMarkerColor = Color3.fromRGB(170, 110, 255),
	SilentAimStickyLock = false,
	SilentAimShowTracer = true,
	SilentAimFireCooldown = 0.05,
	SilentRapidFireEnabled = false,
	SilentRapidFireRate = 18,
	SilentAimTracerTime = 0.08,
	ThirdPersonEnabled = false,
	ThirdPersonKey = Enum.KeyCode.G,
	ThirdPersonDistance = 32,
	ThirdPersonScrollStep = 3,
	AutoGetUpEnabled = false,
	AntiStompEnabled = false,
	MaxWorldDistance = 600,
	TeamCheckEnabled = false,
	WallCheckEnabled = true,
	SkipKnocked = true,
	SkipGrabbed = true,
	ESPEnabled = true,
	ESPBoxes = true,
	ESPNames = true,
	ESPDistance = true,
	ESPHealthBar = true,
	ESPTracers = false,
	ESPTracerThickness = 1,
	ESPTracerFromBottom = true,
	ESPSkeleton = false,
	ESPSkeletonColor = Color3.fromRGB(255, 180, 80),
	ESPHighlights = true,
	ESPHighlightColor = Color3.fromRGB(255, 75, 75),
	ESPArmorBar = true,
	ESPWeaponLabel = true,
	ESPGunESP = false,
	ESPMaxDistance = 400,
	ESPEnemyColor = Color3.fromRGB(255, 70, 90),
	ESPTracerColor = Color3.fromRGB(255, 120, 120),
	SpeedEnabled = false,
	WalkSpeed = 22,
	SpeedKey = Enum.KeyCode.V,
	JumpEnabled = false,
	JumpHeight = 50,
	JumpKey = Enum.KeyCode.J,
	FlyEnabled = false,
	FlySpeed = 35,
	FlyBoostMultiplier = 2,
	FlyVerticalMultiplier = 1,
	FlyKey = Enum.KeyCode.F,
	NoclipEnabled = false,
	NoclipKey = Enum.KeyCode.N,
	AutoRedeemCodes = false,
	AtmFarmEnabled = false,
	AtmFarmInvisible = true,
	AtmFarmWebhookUrl = "",
	AtmFarmWebhookEnabled = false,
	DiscordInviteUrl = "https://discord.gg/AgNz693jKs",
	ShopTeleportTarget = "LMG",
	ThemeName = "Midnight",
}

local UI_CONFIG_PATH = "NameHub/dahood-ui.json"
local saveUiConfig
local applySavedUiLayout

do
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

	local function ensureConfigFolder()
		if not fsReady() then
			return false
		end
		pcall(function()
			local makefolder = getFsFn("makefolder")
			local isfolder = getFsFn("isfolder")
			if typeof(makefolder) == "function" then
				if typeof(isfolder) ~= "function" or not isfolder("NameHub") then
					makefolder("NameHub")
				end
			end
		end)
		return true
	end

	local savedLayout= nil

	local function loadUiConfigFromDisk()
		if not ensureConfigFolder() then
			return
		end
		local readfile = getFsFn("readfile")
		local isfile = getFsFn("isfile")
		if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" or not isfile(UI_CONFIG_PATH) then
			return
		end
		local ok, raw = pcall(readfile, UI_CONFIG_PATH)
		if not ok or type(raw) ~= "string" or raw == "" then
			return
		end
		local decodedOk, decoded = pcall(function()
			return game:GetService("HttpService"):JSONDecode(raw)
		end)
		if not decodedOk or type(decoded) ~= "table" then
			return
		end
		savedLayout = decoded
		if type(decoded.webhookUrl) == "string" then
			CONFIG.AtmFarmWebhookUrl = decoded.webhookUrl
		end
		if decoded.webhookEnabled == true or decoded.webhookEnabled == false then
			CONFIG.AtmFarmWebhookEnabled = decoded.webhookEnabled
		end
	end

	saveUiConfig = function()
		if not ensureConfigFolder() then
			return
		end
		local writefile = getFsFn("writefile")
		if typeof(writefile) ~= "function" then
			return
		end
		local payload= {
			webhookUrl = CONFIG.AtmFarmWebhookUrl,
			webhookEnabled = CONFIG.AtmFarmWebhookEnabled,
		}
		if menuFrame then
			payload.menuAnchor = { menuFrame.AnchorPoint.X, menuFrame.AnchorPoint.Y }
			payload.menuPos = {
				menuFrame.Position.X.Scale,
				menuFrame.Position.X.Offset,
				menuFrame.Position.Y.Scale,
				menuFrame.Position.Y.Offset,
			}
			payload.menuSize = { menuFrame.Size.X.Offset, menuFrame.Size.Y.Offset }
		end
		if keybindHudFrame then
			payload.keybindPos = {
				keybindHudFrame.Position.X.Scale,
				keybindHudFrame.Position.X.Offset,
				keybindHudFrame.Position.Y.Scale,
				keybindHudFrame.Position.Y.Offset,
			}
			payload.keybindSize = { keybindHudFrame.Size.X.Offset, keybindHudFrame.Size.Y.Offset }
		end
		pcall(function()
			writefile(UI_CONFIG_PATH, game:GetService("HttpService"):JSONEncode(payload))
		end)
	end

	applySavedUiLayout = function()
		if type(savedLayout) ~= "table" then
			return
		end
		if menuFrame and type(savedLayout.menuPos) == "table" and #savedLayout.menuPos == 4 then
			if type(savedLayout.menuAnchor) == "table" and #savedLayout.menuAnchor == 2 then
				menuFrame.AnchorPoint = Vector2.new(savedLayout.menuAnchor[1], savedLayout.menuAnchor[2])
			end
			local p = savedLayout.menuPos
			menuFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
		end
		if menuFrame and type(savedLayout.menuSize) == "table" and #savedLayout.menuSize == 2 then
			menuFrame.Size = UDim2.fromOffset(
				math.clamp(savedLayout.menuSize[1], 760, 1100),
				math.clamp(savedLayout.menuSize[2], 480, 900)
			)
		end
		if keybindHudFrame and type(savedLayout.keybindPos) == "table" and #savedLayout.keybindPos == 4 then
			local p = savedLayout.keybindPos
			keybindHudFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
		end
		if keybindHudFrame and type(savedLayout.keybindSize) == "table" and #savedLayout.keybindSize == 2 then
			keybindHudFrame.Size = UDim2.fromOffset(
				math.clamp(savedLayout.keybindSize[1], 120, 340),
				math.clamp(savedLayout.keybindSize[2], 90, 380)
			)
		end
	end

	loadUiConfigFromDisk()
end

local TARGET_PART_OPTIONS = { "Head", "HumanoidRootPart", "UpperTorso" }
local SHOP_TELEPORT_DEFS= {
	{ label = "LMG", gunName = "LMG", fallback = Vector3.new(-621, 23, -301) },
	{ label = "Revolver", gunName = "Revolver", fallback = Vector3.new(-582, 7.172, -739.015) },
	{ label = "Double-Barrel SG", gunName = "Double-Barrel SG" },
	{ label = "Tactical Shotgun", gunName = "TacticalShotgun" },
	{ label = "AK47", gunName = "AK47" },
	{ label = "Shotgun", gunName = "Shotgun" },
	{ label = "RPG", gunName = "RPG", fallback = Vector3.new(112.622, -26.212, -277.321) },
	{ label = "Flamethrower", gunName = "Flamethrower" },
	{ label = "Silencer AR", gunName = "SilencerAR" },
	{ label = "Drum Gun", gunName = "DrumGun" },
	{ label = "Gun Shop", fallback = Vector3.new(-582, 7.172, -739.015) },
	{ label = "Jewelry Store", fallback = Vector3.new(9.926, 17.864, 786.788) },
}
local SHOP_TELEPORT_LABELS= {}
local shopTeleportByLabel= {}
for _, shopDef in SHOP_TELEPORT_DEFS do
	table.insert(SHOP_TELEPORT_LABELS, shopDef.label)
	shopTeleportByLabel[shopDef.label] = shopDef
end
local AIM_MODE_OPTIONS = { "Toggle", "Hold" }

-- Active codes (GameRant + other verified Aug 2026 lists)
local ACTIVE_CODES= {
	"WORLDCUP26",
	"FOURTH26",
	"BALLOON",
	"BOSS",
	"BUILD",
	"EASTER26",
	"DEAGLE",
	"SpringTime26",
	"SPRING26",
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

if not isDaHoodPlace() then
	warn(
		string.format(
			"[NameHub DH] Da Hood only â PlaceId %s (%s) is not supported.",
			tostring(game.PlaceId),
			game.Name
		)
	)
	return
end

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local scriptAlive = true
local menuOpen = false
local uiLoading = true
local aimEnabled = false
local aimKeyHeld = false
local mouse1Held = false
local currentTarget= nil
local lockedTarget= nil
local aimLookAt= nil
local aimCameraActive = false
local aimRenderBound = false
local fovCircle
local silentFovCircle
local targetMarker
local silentMarker
local silentAimEnabled = false
local lockedSilentTarget= nil
local lastSilentShot = 0
local lastGetUpAttempt = 0
local setAimEnabled
local aimShouldLock
local getAimScanPosition
local savedMouseBehavior= nil
local savedMouseIconEnabled = true
local perfTicks = { esp = 0, noclip = 0 }
local movementConns= {}
local movementStepBound = false
local flyStepBound = false
local noclipTrackedParts= {}
local noclipPartState= {}
local noclipWatchConn= nil
local flySavedAutoRotate= nil
local flyHumanoidConn= nil
local ensureFlyLoop
local prepareFlyCharacter
local stopFlyCharacter
local setupNoclipForCharacter
local restoreNoclipParts
local keybindHudFrame
local refreshKeybindHud
local updateThirdPerson
local restoreThirdPersonCamera
local clearGunEspLabels
local updateTargetMarker
local updateTargetInfo
local updateSilentMarker
local tryAutoGetUp
local installSilentAimHooks
local startAtmFarmLoop
local stopAtmFarmLoop
local restoreAtmFarmVisibility
local refreshAtmFarmStats
local resetAtmFarmStats
local updateRapidFire
local atmFarmStatsUI= {}

local THEME_PRESETS = {
	Midnight = {
		Background = Color3.fromRGB(16, 16, 18),
		Topbar = Color3.fromRGB(12, 12, 14),
		Element = Color3.fromRGB(22, 22, 25),
		ElementHover = Color3.fromRGB(30, 30, 34),
		Accent = Color3.fromRGB(230, 55, 85),
		Text = Color3.fromRGB(232, 232, 236),
		SubText = Color3.fromRGB(118, 116, 130),
		Stroke = Color3.fromRGB(48, 48, 54),
		Success = Color3.fromRGB(230, 55, 85),
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
local function syncThemeCompat()
	THEME.Muted = THEME.SubText
	THEME.Border = THEME.Stroke
	THEME.ToggleOff = Color3.fromRGB(60, 60, 65)
end

do
	local preset = THEME_PRESETS[CONFIG.ThemeName] or THEME_PRESETS.Midnight
	for key, value in preset do
		THEME[key] = value
	end
	syncThemeCompat()
end

local function tagTheme(inst, role, textRole)
	inst:SetAttribute("ThemeRole", role)
	if textRole then
		inst:SetAttribute("ThemeTextRole", textRole)
	end
end

local movementBase = { walkSpeed = 16, jumpHeight = 50, jumpPower = 50, useJumpPower = true }
local toggleUI= {}
local listeningForKeybind = nil

local Util= {}
do
	function Util.isMouseBindInput(inputType)
		return inputType == Enum.UserInputType.MouseButton1
			or inputType == Enum.UserInputType.MouseButton2
			or inputType == Enum.UserInputType.MouseButton3
	end

	function Util.formatInputBindLabel(key, mouse)
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

	function Util.getCharacterPart(character, partName)
		local part = character:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			return part
		end
		return nil
	end

	function Util.getTargetPart(character)
		return Util.getCharacterPart(character, CONFIG.TargetPartName)
			or Util.getCharacterPart(character, "HumanoidRootPart")
			or Util.getCharacterPart(character, "UpperTorso")
	end

	function Util.isAlive(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		return humanoid ~= nil and humanoid.Health > 0
	end

	function Util.isKnocked(character)
		if not CONFIG.SkipKnocked then
			return false
		end
		local effects = character:FindFirstChild("BodyEffects")
		if not effects then
			return false
		end
		local ko = effects:FindFirstChild("K.O")
		return ko ~= nil and ko:IsA("BoolValue") and ko.Value
	end

	function Util.isGrabbed(character)
		if not CONFIG.SkipGrabbed then
			return false
		end
		local effects = character:FindFirstChild("BodyEffects")
		if not effects then
			return false
		end
		local grabbed = effects:FindFirstChild("Grabbed")
		return grabbed ~= nil and grabbed:IsA("BoolValue") and grabbed.Value
	end

	function Util.getBodyEffectBool(character, effectName)
		local effects = character:FindFirstChild("BodyEffects")
		if not effects then
			return false
		end
		local value = effects:FindFirstChild(effectName)
		return value ~= nil and value:IsA("BoolValue") and value.Value
	end

	function Util.getCharacterWeaponName(character)
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				return child.Name
			end
		end
		return "None"
	end

	function Util.getCharacterArmorValues(character)
		local effects = character:FindFirstChild("BodyEffects")
		if not effects then
			return 0, 200
		end
		local armor = effects:FindFirstChild("Armor")
		if armor and armor:IsA("IntValue") then
			return math.max(0, armor.Value), 200
		end
		return 0, 200
	end

	function Util.getDistanceToCharacter(character)
		local myCharacter = localPlayer.Character
		if not myCharacter then
			return nil
		end
		local myRoot = Util.getCharacterPart(myCharacter, "HumanoidRootPart")
		local theirRoot = Util.getCharacterPart(character, "HumanoidRootPart")
		if not myRoot or not theirRoot then
			return nil
		end
		return (theirRoot.Position - myRoot.Position).Magnitude
	end

	function Util.getPlayerCash()
		local dataFolder = localPlayer:FindFirstChild("DataFolder")
		if not dataFolder then
			return nil
		end
		local currency = dataFolder:FindFirstChild("Currency")
		if currency and (currency:IsA("IntValue") or currency:IsA("NumberValue")) then
			return currency.Value
		end
		return nil
	end

	function Util.formatCashAmount(amount)
		local rounded = math.floor(amount + 0.5)
		if rounded < 0 then
			return "-$" .. tostring(math.abs(rounded))
		end
		return "$" .. tostring(rounded)
	end

	function Util.formatFarmDuration(seconds)
		local total = math.max(0, math.floor(seconds))
		local mins = math.floor(total / 60)
		local secs = total % 60
		return string.format("%d:%02d", mins, secs)
	end

	function Util.passesTeamCheck(otherPlayer)
		if not CONFIG.TeamCheckEnabled or otherPlayer == localPlayer then
			return otherPlayer ~= localPlayer
		end
		if localPlayer.Team and otherPlayer.Team and localPlayer.Team ~= otherPlayer.Team then
			return true
		end
		local myColor = localPlayer.TeamColor
		local theirColor = otherPlayer.TeamColor
		if myColor and theirColor and myColor ~= theirColor then
			return true
		end
		return false
	end

	function Util.hasLineOfSight(targetPart, targetCharacter)
		if not CONFIG.WallCheckEnabled then
			return true
		end
		camera = workspace.CurrentCamera
		if not camera then
			return true
		end
		local origin = camera.CFrame.Position
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

	function Util.isValidTarget(otherPlayer, mousePos, fovRadius)
		if otherPlayer == localPlayer then
			return false
		end
		local character = otherPlayer.Character
		if not character or not Util.isAlive(character) or Util.isKnocked(character) or Util.isGrabbed(character) then
			return false
		end
		if not Util.passesTeamCheck(otherPlayer) then
			return false
		end
		local part = Util.getTargetPart(character)
		if not part then
			return false
		end
		if (part.Position - camera.CFrame.Position).Magnitude > CONFIG.MaxWorldDistance then
			return false
		end
		if not Util.hasLineOfSight(part, character) then
			return false
		end
		local screenPos = camera:WorldToViewportPoint(part.Position)
		if screenPos.Z <= 0 then
			return false
		end
		local radius = fovRadius or CONFIG.FOVRadius
		return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude <= radius
	end

	function Util.getMouseViewport()
		local mouse = UserInputService:GetMouseLocation()
		local inset = GuiService:GetGuiInset()
		return Vector2.new(mouse.X, mouse.Y - inset.Y)
	end

	function Util.findClosestTargetAt(mousePos, fovRadius)
		camera = workspace.CurrentCamera
		local radius = fovRadius or CONFIG.FOVRadius
		local best= nil
		local bestDist = radius + 1
		for _, other in Players:GetPlayers() do
			if Util.isValidTarget(other, mousePos, radius) then
				local part = Util.getTargetPart(other.Character )
				if part then
					local screenPos = camera:WorldToViewportPoint(part.Position)
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist < bestDist then
						bestDist = dist
						best = other
					end
				end
			end
		end
		return best
	end

	function Util.findClosestTarget()
		return Util.findClosestTargetAt(getAimScanPosition())
	end
end

-- Cleanup old instances
do
	pcall(function()
		local g = getgenv()
		if typeof(g.NameHubDHUnload) == "function" then
			g.NameHubDHUnload()
		end
	end)
	for _, parent in { playerGui, game:GetService("CoreGui") } do
		local ui = parent:FindFirstChild("NameHubDHUI")
		if ui then
			ui:Destroy()
		end
	end
end

local Layout= {}
do
	function Layout.makeDraggable(frame, handle, onChanged, beforeStart)
		local dragging = false
		local startMouse = Vector2.zero
		local startPos = UDim2.new()
		handle.Active = true
		handle.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			if beforeStart then
				beforeStart()
			end
			dragging = true
			startMouse = input.Position
			startPos = frame.Position
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
			local delta = input.Position - startMouse
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not dragging then
				return
			end
			dragging = false
			if onChanged then
				onChanged()
			end
		end)
	end

	function Layout.makeResizable(
		frame,
		handle,
		minSize,
		maxSize,
		onChanged,
		beforeStart
	)
		local resizing = false
		local startMouse = Vector2.zero
		local startSize = Vector2.zero
		handle.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			if beforeStart then
				beforeStart()
			end
			resizing = true
			startMouse = input.Position
			startSize = Vector2.new(frame.Size.X.Offset, frame.Size.Y.Offset)
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
			local delta = input.Position - startMouse
			local width = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
			local height = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
			frame.Size = UDim2.fromOffset(width, height)
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not resizing then
				return
			end
			resizing = false
			if onChanged then
				onChanged()
			end
		end)
	end

	function Layout.createResizeGrip(parent, zIndex)
		local grip = Instance.new("TextButton")
		grip.Name = "ResizeGrip"
		grip.AnchorPoint = Vector2.new(1, 1)
		grip.Position = UDim2.new(1, -4, 1, -4)
		grip.Size = UDim2.fromOffset(14, 14)
		grip.BackgroundTransparency = 1
		grip.BorderSizePixel = 0
		grip.Font = Enum.Font.GothamBold
		grip.Text = "â¢"
		grip.TextColor3 = Color3.fromRGB(150, 156, 170)
		grip.TextSize = 10
		grip.AutoButtonColor = false
		grip.ZIndex = zIndex
		grip.Parent = parent
		return grip
	end

	function Layout.normalizeTopLeftAnchor(frame)
		if frame.AnchorPoint == Vector2.new(0, 0) then
			return
		end
		local pos = frame.AbsolutePosition
		frame.AnchorPoint = Vector2.new(0, 0)
		frame.Position = UDim2.fromOffset(pos.X, pos.Y)
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NameHubDHUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1_000_000
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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

fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Size = UDim2.fromOffset(CONFIG.FOVRadius * 2, CONFIG.FOVRadius * 2)
fovCircle.Visible = false
fovCircle.ZIndex = 40
fovCircle.Parent = screenGui
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(180, 140, 255)
fovStroke.Thickness = 2
fovStroke.Transparency = 0.35
fovStroke.Parent = fovCircle
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

silentFovCircle = Instance.new("Frame")
silentFovCircle.Name = "SilentFOVCircle"
silentFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
silentFovCircle.BackgroundTransparency = 1
silentFovCircle.Size = UDim2.fromOffset(CONFIG.SilentFOVRadius * 2, CONFIG.SilentFOVRadius * 2)
silentFovCircle.Visible = false
silentFovCircle.ZIndex = 39
silentFovCircle.Parent = screenGui
local silentFovStroke = Instance.new("UIStroke")
silentFovStroke.Color = CONFIG.SilentAimMarkerColor
silentFovStroke.Thickness = 2
silentFovStroke.Transparency = 0.25
silentFovStroke.Parent = silentFovCircle
local silentFovCorner = Instance.new("UICorner")
silentFovCorner.CornerRadius = UDim.new(1, 0)
silentFovCorner.Parent = silentFovCircle

local function createMarkerFrame(name, color)
	local marker = Instance.new("Frame")
	marker.Name = name
	marker.AnchorPoint = Vector2.new(0.5, 0.5)
	marker.BackgroundTransparency = 1
	marker.Size = UDim2.fromOffset(18, 18)
	marker.Visible = false
	marker.ZIndex = 41
	marker.Parent = screenGui
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Transparency = 0.15
	stroke.Parent = marker
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = marker
	return marker
end

targetMarker = createMarkerFrame("TargetMarker", CONFIG.TargetMarkerColor)
silentMarker = createMarkerFrame("SilentAimMarker", CONFIG.SilentAimMarkerColor)

local keybindHudTitle = Instance.new("TextLabel")
keybindHudTitle.Name = "Title"
keybindHudTitle.BackgroundTransparency = 1
keybindHudTitle.Position = UDim2.fromOffset(10, 6)
keybindHudTitle.Size = UDim2.new(1, -20, 0, 14)
keybindHudTitle.Font = Enum.Font.GothamBold
keybindHudTitle.Text = "KEYBINDS"
keybindHudTitle.TextColor3 = THEME.Text
keybindHudTitle.TextSize = 11
keybindHudTitle.TextXAlignment = Enum.TextXAlignment.Left
keybindHudTitle.ZIndex = 26
tagTheme(keybindHudTitle, "Text")

keybindHudFrame = Instance.new("Frame")
keybindHudFrame.Name = "KeybindHud"
keybindHudFrame.AnchorPoint = Vector2.new(0, 0)
keybindHudFrame.Position = UDim2.fromOffset(10, 10)
keybindHudFrame.Size = UDim2.fromOffset(158, 148)
keybindHudFrame.BackgroundColor3 = THEME.Topbar
keybindHudFrame.BackgroundTransparency = 0.08
keybindHudFrame.BorderSizePixel = 0
keybindHudFrame.ZIndex = 25
tagTheme(keybindHudFrame, "Topbar")
keybindHudFrame.Parent = screenGui
local keybindHudCorner = Instance.new("UICorner")
keybindHudCorner.CornerRadius = UDim.new(0, 8)
keybindHudCorner.Parent = keybindHudFrame
local keybindHudStroke = Instance.new("UIStroke")
keybindHudStroke.Color = THEME.Border
keybindHudStroke.Transparency = 0.35
tagTheme(keybindHudStroke, "Border")
keybindHudStroke.Parent = keybindHudFrame
keybindHudTitle.Parent = keybindHudFrame

local keybindHudBody = Instance.new("TextLabel")
keybindHudBody.Name = "Body"
keybindHudBody.BackgroundTransparency = 1
keybindHudBody.Position = UDim2.fromOffset(10, 22)
keybindHudBody.Size = UDim2.new(1, -16, 1, -28)
keybindHudBody.Font = Enum.Font.GothamMedium
keybindHudBody.Text = ""
keybindHudBody.TextColor3 = THEME.Text
keybindHudBody.TextSize = 11
keybindHudBody.TextXAlignment = Enum.TextXAlignment.Left
keybindHudBody.TextYAlignment = Enum.TextYAlignment.Top
keybindHudBody.ZIndex = 26
tagTheme(keybindHudBody, "Text")
keybindHudBody.Parent = keybindHudFrame

local keybindHudDragHandle = Instance.new("Frame")
keybindHudDragHandle.Name = "DragHandle"
keybindHudDragHandle.BackgroundTransparency = 1
keybindHudDragHandle.Position = UDim2.fromOffset(0, 0)
keybindHudDragHandle.Size = UDim2.new(1, 0, 0, 20)
keybindHudDragHandle.ZIndex = 27
keybindHudDragHandle.Parent = keybindHudFrame

local keybindHudResizeGrip = Layout.createResizeGrip(keybindHudFrame, 27)
Layout.makeDraggable(keybindHudFrame, keybindHudDragHandle, function()
	pcall(saveUiConfig)
end)
Layout.makeResizable(keybindHudFrame, keybindHudResizeGrip, Vector2.new(120, 90), Vector2.new(340, 380), function()
	pcall(saveUiConfig)
end)

refreshKeybindHud = function()
	local aimLabel = Util.formatInputBindLabel(CONFIG.ToggleKey, CONFIG.ToggleMouse)
	keybindHudBody.Text = table.concat({
		"Menu Â· " .. CONFIG.MenuKey.Name,
		"Aim Â· " .. aimLabel,
		"Silent Â· " .. CONFIG.SilentAimKey.Name,
		"Speed Â· " .. CONFIG.SpeedKey.Name,
		"Jump Â· " .. CONFIG.JumpKey.Name,
		"Fly Â· " .. CONFIG.FlyKey.Name,
		"Noclip Â· " .. CONFIG.NoclipKey.Name,
		"3rd Â· " .. CONFIG.ThirdPersonKey.Name,
	}, "\n")
end
refreshKeybindHud()

local targetInfoFrame = Instance.new("Frame")
targetInfoFrame.Name = "TargetInfo"
targetInfoFrame.AnchorPoint = Vector2.new(1, 0.5)
targetInfoFrame.Position = UDim2.new(1, -12, 0.5, 0)
targetInfoFrame.Size = UDim2.fromOffset(196, 248)
targetInfoFrame.BackgroundColor3 = THEME.Topbar
targetInfoFrame.BackgroundTransparency = 0.08
targetInfoFrame.BorderSizePixel = 0
targetInfoFrame.Visible = false
targetInfoFrame.ZIndex = 25
tagTheme(targetInfoFrame, "Topbar")
targetInfoFrame.Parent = screenGui

local targetInfoCorner = Instance.new("UICorner")
targetInfoCorner.CornerRadius = UDim.new(0, 8)
targetInfoCorner.Parent = targetInfoFrame

local targetInfoStroke = Instance.new("UIStroke")
targetInfoStroke.Color = THEME.Border
targetInfoStroke.Transparency = 0.35
tagTheme(targetInfoStroke, "Border")
targetInfoStroke.Parent = targetInfoFrame

local targetInfoTitle = Instance.new("TextLabel")
targetInfoTitle.Name = "Title"
targetInfoTitle.BackgroundTransparency = 1
targetInfoTitle.Position = UDim2.fromOffset(10, 8)
targetInfoTitle.Size = UDim2.new(1, -20, 0, 14)
targetInfoTitle.Font = Enum.Font.GothamBold
targetInfoTitle.Text = "TARGET INFO"
targetInfoTitle.TextColor3 = THEME.Text
targetInfoTitle.TextSize = 11
targetInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
targetInfoTitle.ZIndex = 26
tagTheme(targetInfoTitle, "Text")
targetInfoTitle.Parent = targetInfoFrame

local targetInfoName = Instance.new("TextLabel")
targetInfoName.Name = "Name"
targetInfoName.BackgroundTransparency = 1
targetInfoName.Position = UDim2.fromOffset(10, 24)
targetInfoName.Size = UDim2.new(1, -20, 0, 18)
targetInfoName.Font = Enum.Font.GothamBold
targetInfoName.Text = "â"
targetInfoName.TextColor3 = THEME.Accent
targetInfoName.TextSize = 13
targetInfoName.TextXAlignment = Enum.TextXAlignment.Left
targetInfoName.TextTruncate = Enum.TextTruncate.AtEnd
targetInfoName.ZIndex = 26
tagTheme(targetInfoName, "Accent")
targetInfoName.Parent = targetInfoFrame

local targetInfoSource = Instance.new("TextLabel")
targetInfoSource.Name = "Source"
targetInfoSource.BackgroundTransparency = 1
targetInfoSource.Position = UDim2.fromOffset(10, 42)
targetInfoSource.Size = UDim2.new(1, -20, 0, 12)
targetInfoSource.Font = Enum.Font.GothamMedium
targetInfoSource.Text = ""
targetInfoSource.TextColor3 = THEME.SubText
targetInfoSource.TextSize = 10
targetInfoSource.TextXAlignment = Enum.TextXAlignment.Left
targetInfoSource.ZIndex = 26
tagTheme(targetInfoSource, "SubText")
targetInfoSource.Parent = targetInfoFrame

local targetInfoHealthBg = Instance.new("Frame")
targetInfoHealthBg.Name = "HealthBg"
targetInfoHealthBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
targetInfoHealthBg.BorderSizePixel = 0
targetInfoHealthBg.Position = UDim2.fromOffset(10, 60)
targetInfoHealthBg.Size = UDim2.new(1, -20, 0, 8)
targetInfoHealthBg.ZIndex = 26
targetInfoHealthBg.Parent = targetInfoFrame

local targetInfoHealthBgCorner = Instance.new("UICorner")
targetInfoHealthBgCorner.CornerRadius = UDim.new(0, 4)
targetInfoHealthBgCorner.Parent = targetInfoHealthBg

local targetInfoHealthFill = Instance.new("Frame")
targetInfoHealthFill.Name = "Fill"
targetInfoHealthFill.BackgroundColor3 = Color3.fromRGB(90, 220, 120)
targetInfoHealthFill.BorderSizePixel = 0
targetInfoHealthFill.Size = UDim2.fromScale(1, 1)
targetInfoHealthFill.ZIndex = 27
targetInfoHealthFill.Parent = targetInfoHealthBg

local targetInfoHealthFillCorner = Instance.new("UICorner")
targetInfoHealthFillCorner.CornerRadius = UDim.new(0, 4)
targetInfoHealthFillCorner.Parent = targetInfoHealthFill

local targetInfoArmorBg = Instance.new("Frame")
targetInfoArmorBg.Name = "ArmorBg"
targetInfoArmorBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
targetInfoArmorBg.BorderSizePixel = 0
targetInfoArmorBg.Position = UDim2.fromOffset(10, 72)
targetInfoArmorBg.Size = UDim2.new(1, -20, 0, 6)
targetInfoArmorBg.ZIndex = 26
targetInfoArmorBg.Parent = targetInfoFrame

local targetInfoArmorBgCorner = Instance.new("UICorner")
targetInfoArmorBgCorner.CornerRadius = UDim.new(0, 4)
targetInfoArmorBgCorner.Parent = targetInfoArmorBg

local targetInfoArmorFill = Instance.new("Frame")
targetInfoArmorFill.Name = "Fill"
targetInfoArmorFill.BackgroundColor3 = Color3.fromRGB(120, 170, 255)
targetInfoArmorFill.BorderSizePixel = 0
targetInfoArmorFill.Size = UDim2.fromScale(0, 1)
targetInfoArmorFill.ZIndex = 27
targetInfoArmorFill.Parent = targetInfoArmorBg

local targetInfoArmorFillCorner = Instance.new("UICorner")
targetInfoArmorFillCorner.CornerRadius = UDim.new(0, 4)
targetInfoArmorFillCorner.Parent = targetInfoArmorFill

local targetInfoBody = Instance.new("TextLabel")
targetInfoBody.Name = "Body"
targetInfoBody.BackgroundTransparency = 1
targetInfoBody.Position = UDim2.fromOffset(10, 84)
targetInfoBody.Size = UDim2.new(1, -16, 1, -92)
targetInfoBody.Font = Enum.Font.GothamMedium
targetInfoBody.Text = ""
targetInfoBody.TextColor3 = THEME.Text
targetInfoBody.TextSize = 11
targetInfoBody.TextXAlignment = Enum.TextXAlignment.Left
targetInfoBody.TextYAlignment = Enum.TextYAlignment.Top
targetInfoBody.ZIndex = 26
tagTheme(targetInfoBody, "Text")
targetInfoBody.Parent = targetInfoFrame

pcall(function()
	local g = getgenv()
	local protect = g.protect_gui or (typeof(g.syn) == "table" and g.syn.protect_gui) or g.protectgui
	if typeof(protect) == "function" then
		protect(screenGui)
	end
end)

local function notify(title, detail)
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(250, if detail then 52 else 36)
	card.BackgroundColor3 = THEME.Topbar
	card.BorderSizePixel = 0
	card.AnchorPoint = Vector2.new(1, 1)
	card.Position = UDim2.new(1, -16, 1, -16)
	card.ZIndex = 200
	card.Parent = screenGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(10, 8)
	titleLabel.Size = UDim2.new(1, -16, 0, 18)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 201
	titleLabel.Parent = card
	if detail then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromOffset(10, 26)
		sub.Size = UDim2.new(1, -16, 0, 16)
		sub.Font = Enum.Font.Gotham
		sub.Text = detail
		sub.TextColor3 = THEME.SubText
		sub.TextSize = 11
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.ZIndex = 201
		sub.Parent = card
	end
	task.delay(2.5, function()
		if card.Parent then
			card:Destroy()
		end
	end)
end

local menuFrame
local applyTheme
local createTab
local createSection
local beginPage
local createToggle
local createSlider
local createButton
local createKeybind
local createDropdown
local createInputBind
local createStatLine
local createTextField
local selectTab

do
menuFrame = Instance.new("Frame")
menuFrame.Name = "NameHubMenu"
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.Position = UDim2.fromScale(0.5, 0.5)
menuFrame.Size = UDim2.fromOffset(860, 540)
menuFrame.BackgroundColor3 = THEME.Background
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 50
tagTheme(menuFrame, "Background")
menuFrame.Parent = screenGui
local menuStroke = Instance.new("UIStroke")
menuStroke.Color = THEME.Stroke
menuStroke.Thickness = 1
menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tagTheme(menuStroke, "Stroke")
menuStroke.Parent = menuFrame

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 46)
topbar.BackgroundColor3 = THEME.Topbar
topbar.BorderSizePixel = 0
topbar.ZIndex = 51
tagTheme(topbar, "Topbar")
topbar.Parent = menuFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(16, 0)
titleLabel.Size = UDim2.fromOffset(130, 46)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "NAMEHUB"
titleLabel.TextColor3 = THEME.Accent
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 52
tagTheme(titleLabel, "Accent")
titleLabel.Parent = topbar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.AnchorPoint = Vector2.new(1, 0.5)
subtitleLabel.Position = UDim2.new(1, -16, 0.5, 0)
subtitleLabel.Size = UDim2.fromOffset(90, 20)
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "da hood"
subtitleLabel.TextColor3 = THEME.SubText
subtitleLabel.TextSize = 12
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
subtitleLabel.ZIndex = 52
tagTheme(subtitleLabel, "SubText")
subtitleLabel.Parent = topbar

local menuResizeGrip = Layout.createResizeGrip(menuFrame, 55)
local function normalizeMenuLayout()
	Layout.normalizeTopLeftAnchor(menuFrame)
end
Layout.makeDraggable(menuFrame, topbar, function()
	pcall(saveUiConfig)
end, normalizeMenuLayout)
Layout.makeResizable(menuFrame, menuResizeGrip, Vector2.new(760, 480), Vector2.new(1100, 900), function()
	pcall(saveUiConfig)
end, normalizeMenuLayout)

local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.fromOffset(132, 0)
tabBar.Size = UDim2.new(1, -240, 1, 0)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 53
tabBar.Parent = topbar
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabBar

local pagesHost = Instance.new("Frame")
pagesHost.Position = UDim2.fromOffset(0, 46)
pagesHost.Size = UDim2.new(1, 0, 1, -68)
pagesHost.BackgroundTransparency = 1
pagesHost.ZIndex = 50
pagesHost.Parent = menuFrame

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 16, 1, -8)
footer.Size = UDim2.new(1, -32, 0, 16)
footer.Font = Enum.Font.Gotham
footer.TextSize = 11
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.TextColor3 = THEME.SubText
footer.Text = "Insert · da hood"
footer.ZIndex = 52
tagTheme(footer, "SubText")
footer.Parent = menuFrame

local pages = {}
local pageColumns = {}
local columnCursor = {}
local tabButtons = {}
local tabCount = 0
local layoutOrder = 0
local selectedTab = "Main"

local function nextOrder()
	layoutOrder += 1
	return layoutOrder
end

local function columnRowCount(col)
	local count = 0
	for _, child in col:GetChildren() do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UIStroke") then
			count += 1
		end
	end
	return count
end

local function widgetHost()
	local cols = pageColumns[selectedTab]
	if not cols then
		return pages[selectedTab]
	end
	local index = columnCursor[selectedTab] or 1
	if columnRowCount(cols[index]) >= 8 then
		local nextIndex = (index % 3) + 1
		if columnRowCount(cols[nextIndex]) < columnRowCount(cols[index]) then
			index = nextIndex
			columnCursor[selectedTab] = index
		end
	end
	return cols[index]
end

local function createPage(id)
	local page = Instance.new("Frame")
	page.Name = "Page_" .. id
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.ZIndex = 50
	page.Parent = pagesHost
	local cols = {}
	for i = 1, 3 do
		local col = Instance.new("ScrollingFrame")
		col.Name = "Column" .. i
		col.BackgroundColor3 = THEME.Element
		col.BorderSizePixel = 0
		col.ScrollBarThickness = 3
		col.ScrollBarImageColor3 = THEME.Accent
		col.AutomaticCanvasSize = Enum.AutomaticSize.Y
		col.CanvasSize = UDim2.fromOffset(0, 0)
		col.ScrollingDirection = Enum.ScrollingDirection.Y
		col.ScrollingEnabled = true
		col.Active = true
		col.ElasticBehavior = Enum.ElasticBehavior.Never
		col.Size = UDim2.new(1 / 3, -12, 1, -12)
		col.Position = UDim2.new((i - 1) / 3, 8, 0, 6)
		col.ZIndex = 51
		tagTheme(col, "Element")
		col.Parent = page
		local stroke = Instance.new("UIStroke")
		stroke.Color = THEME.Stroke
		stroke.Thickness = 1
		tagTheme(stroke, "Stroke")
		stroke.Parent = col
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 4)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = col
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = col
		cols[i] = col
	end
	pageColumns[id] = cols
	columnCursor[id] = 1
	pages[id] = page
	return page
end

selectTab = function(id)
	selectedTab = id
	for name, page in pages do
		page.Visible = name == id
	end
	for name, btn in tabButtons do
		local active = name == id
		btn.BackgroundTransparency = 1
		btn.TextColor3 = if active then THEME.Text else THEME.SubText
		local line = btn:FindFirstChild("Underline")
		if line then
			line.Visible = active
			line.BackgroundColor3 = THEME.Accent
		end
	end
end

createTab = function(id, label)
	tabCount += 1
	createPage(id)
	local btn = Instance.new("TextButton")
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.Size = UDim2.fromOffset(0, 46)
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.Text = string.upper(label)
	btn.TextColor3 = THEME.SubText
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.ZIndex = 54
	btn.Parent = tabBar
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = btn
	local line = Instance.new("Frame")
	line.Name = "Underline"
	line.AnchorPoint = Vector2.new(0.5, 1)
	line.Position = UDim2.new(0.5, 0, 1, 0)
	line.Size = UDim2.new(1, -12, 0, 2)
	line.BackgroundColor3 = THEME.Accent
	line.BorderSizePixel = 0
	line.Visible = false
	line.ZIndex = 55
	line.Parent = btn
	tabButtons[id] = btn
	btn.MouseButton1Click:Connect(function()
		selectTab(id)
	end)
end

createSection = function(title)
	local cols = pageColumns[selectedTab]
	if cols then
		local best = columnCursor[selectedTab] or 1
		local bestCount = columnRowCount(cols[best])
		if bestCount > 0 then
			for i = 1, 3 do
				local count = columnRowCount(cols[i])
				if count < bestCount then
					best = i
					bestCount = count
				end
			end
			columnCursor[selectedTab] = best
		end
	end
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 22)
	shell.BackgroundTransparency = 1
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = widgetHost()
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = string.upper(title)
	label.TextColor3 = THEME.Muted
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 53
	tagTheme(label, "Muted")
	label.Parent = shell
end

beginPage = function(id)
	selectedTab = id
	if not pages[id] then
		createPage(id)
	end
end

createToggle = function(name, desc, initial, onChange)
	local shell = Instance.new("TextButton")
	shell.Size = UDim2.new(1, 0, 0, 28)
	shell.BackgroundTransparency = 1
	shell.BorderSizePixel = 0
	shell.Text = ""
	shell.AutoButtonColor = false
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = widgetHost()
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, -24, 1, 0)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	tagTheme(nameLabel, "Text")
	nameLabel.Parent = shell
	local toggleBg = Instance.new("Frame")
	toggleBg.AnchorPoint = Vector2.new(1, 0.5)
	toggleBg.Position = UDim2.new(1, 0, 0.5, 0)
	toggleBg.Size = UDim2.fromOffset(14, 14)
	toggleBg.BackgroundColor3 = if initial then THEME.Accent else THEME.ToggleOff
	toggleBg.BorderSizePixel = 0
	toggleBg.ZIndex = 53
	toggleBg:SetAttribute("ThemeToggleOn", initial)
	tagTheme(toggleBg, if initial then "Accent" else "ToggleOff")
	toggleBg.Parent = shell
	local mark = Instance.new("Frame")
	mark.Name = "Mark"
	mark.AnchorPoint = Vector2.new(0.5, 0.5)
	mark.Position = UDim2.fromScale(0.5, 0.5)
	mark.Size = UDim2.fromOffset(8, 8)
	mark.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	mark.BorderSizePixel = 0
	mark.Visible = initial
	mark.ZIndex = 54
	mark.Parent = toggleBg
	local enabled = initial
	local function setValue(value)
		enabled = value
		toggleBg.BackgroundColor3 = if value then THEME.Accent else THEME.ToggleOff
		toggleBg:SetAttribute("ThemeToggleOn", value)
		tagTheme(toggleBg, if value then "Accent" else "ToggleOff")
		mark.Visible = value
	end
	shell.MouseButton1Click:Connect(function()
		setValue(not enabled)
		onChange(enabled)
	end)
	return { Set = setValue }
end

createSlider = function(name, desc, min, max, initial, onChange)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 48)
	shell.BackgroundTransparency = 1
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = widgetHost()
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -24, 0, 16)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	tagTheme(nameLabel, "Text")
	nameLabel.Parent = shell
	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.fromOffset(12, 24)
	valueLabel.Size = UDim2.new(1, -24, 0, 14)
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.Text = desc .. " Â· " .. tostring(initial)
	valueLabel.TextColor3 = THEME.SubText
	valueLabel.TextSize = 11
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.ZIndex = 53
	tagTheme(valueLabel, "SubText")
	valueLabel.Parent = shell
	local track = Instance.new("TextButton")
	track.Position = UDim2.fromOffset(0, 40)
	track.Size = UDim2.new(1, 0, 0, 4)
	track.BackgroundColor3 = THEME.ToggleOff
	track.BorderSizePixel = 0
	track.Text = ""
	track.AutoButtonColor = false
	track.ZIndex = 53
	tagTheme(track, "ToggleOff")
	track.Parent = shell
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((initial - min) / (max - min), 1)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 54
	tagTheme(fill, "Accent")
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	local current = initial
	local function setValue(value)
		current = math.clamp(value, min, max)
		fill.Size = UDim2.fromScale((current - min) / (max - min), 1)
		valueLabel.Text = desc .. " Â· " .. tostring(math.floor(current + 0.5))
		onChange(current)
	end
	track.MouseButton1Down:Connect(function()
		local function updateFromInput()
			local rel = (UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			setValue(min + math.clamp(rel, 0, 1) * (max - min))
		end
		updateFromInput()
		local moveConn
		local upConn
		moveConn = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				updateFromInput()
			end
		end)
		upConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				moveConn:Disconnect()
				upConn:Disconnect()
			end
		end)
	end)
end

createButton = function(name, color, onClick)
	local shell = Instance.new("TextButton")
	shell.Size = UDim2.new(1, 0, 0, 36)
	shell.BackgroundColor3 = color
	shell.BorderSizePixel = 0
	shell.Font = Enum.Font.GothamBold
	shell.Text = name
	shell.TextColor3 = Color3.new(1, 1, 1)
	shell.TextSize = 13
	shell.AutoButtonColor = true
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = widgetHost()
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Stroke
	stroke.Thickness = 1
	tagTheme(stroke, "Stroke")
	stroke.Parent = shell
	shell.MouseButton1Click:Connect(onClick)
end

createKeybind = function(name, desc, initial, onChanged)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 54)
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = widgetHost()
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	local shellStroke = Instance.new("UIStroke")
	shellStroke.Color = THEME.Border
	shellStroke.Transparency = 0.55
	shellStroke.Parent = shell
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -130, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -130, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = THEME.Muted
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 53
	descLabel.Parent = shell
	local currentKey = initial
	local bindButton = Instance.new("TextButton")
	bindButton.AnchorPoint = Vector2.new(1, 0.5)
	bindButton.Position = UDim2.new(1, -12, 0.5, 0)
	bindButton.Size = UDim2.fromOffset(110, 28)
	bindButton.BackgroundColor3 = THEME.Background
	bindButton.BorderSizePixel = 0
	bindButton.Font = Enum.Font.GothamBold
	bindButton.Text = currentKey.Name
	bindButton.TextColor3 = THEME.Text
	bindButton.TextSize = 12
	bindButton.ZIndex = 53
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
				refreshKeybindHud()
				notify(name, "Bound to " .. keyCode.Name)
			end,
			cancel = function()
				showCurrent()
				listeningForKeybind = nil
			end,
		}
	end)
end

local openDropdownCloser = nil

createDropdown = function(
	name,
	desc,
	options,
	initial,
	onChanged
)
	local ROW = 28
	local listMax = math.min(#options * ROW + 6, 154)
	local HEADER_H = 34
	local TRIGGER_H = 30
	local TRIGGER_Y = HEADER_H
	local LIST_Y = TRIGGER_Y + TRIGGER_H + 6
	local COLLAPSED_H = LIST_Y + 6
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, COLLAPSED_H)
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	tagTheme(shell, "Element")
	shell.Parent = widgetHost()
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	local shellStroke = Instance.new("UIStroke")
	shellStroke.Color = THEME.Border
	shellStroke.Transparency = 0.55
	tagTheme(shellStroke, "Border")
	shellStroke.Parent = shell

	local index = table.find(options, initial) or 1
	local isOpen = false

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 6)
	nameLabel.Size = UDim2.new(1, -24, 0, 16)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	tagTheme(nameLabel, "Text")
	nameLabel.Parent = shell

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 20)
	descLabel.Size = UDim2.new(1, -24, 0, 14)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = THEME.Muted
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 53
	tagTheme(descLabel, "Muted")
	descLabel.Parent = shell

	local trigger = Instance.new("TextButton")
	trigger.Name = "DropdownTrigger"
	trigger.Position = UDim2.fromOffset(12, TRIGGER_Y)
	trigger.Size = UDim2.new(1, -24, 0, TRIGGER_H)
	trigger.BackgroundColor3 = THEME.Topbar
	trigger.BorderSizePixel = 0
	trigger.AutoButtonColor = false
	trigger.Font = Enum.Font.GothamMedium
	trigger.Text = ""
	trigger.TextColor3 = THEME.Text
	trigger.TextSize = 12
	trigger.ZIndex = 53
	tagTheme(trigger, "Topbar", "Text")
	trigger.Parent = shell
	local triggerCorner = Instance.new("UICorner")
	triggerCorner.CornerRadius = UDim.new(0, 6)
	triggerCorner.Parent = trigger
	local triggerStroke = Instance.new("UIStroke")
	triggerStroke.Color = THEME.Border
	triggerStroke.Transparency = 0.45
	tagTheme(triggerStroke, "Border")
	triggerStroke.Parent = trigger

	local triggerLabel = Instance.new("TextLabel")
	triggerLabel.BackgroundTransparency = 1
	triggerLabel.Position = UDim2.fromOffset(10, 0)
	triggerLabel.Size = UDim2.new(1, -28, 1, 0)
	triggerLabel.Font = Enum.Font.GothamMedium
	triggerLabel.Text = options[index]
	triggerLabel.TextColor3 = THEME.Text
	triggerLabel.TextSize = 12
	triggerLabel.TextXAlignment = Enum.TextXAlignment.Left
	triggerLabel.ZIndex = 54
	tagTheme(triggerLabel, "Text")
	triggerLabel.Parent = trigger

	local chevron = Instance.new("TextLabel")
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -8, 0.5, 0)
	chevron.Size = UDim2.fromOffset(16, 16)
	chevron.Font = Enum.Font.GothamBold
	chevron.Text = "â¾"
	chevron.TextColor3 = THEME.Muted
	chevron.TextSize = 12
	chevron.ZIndex = 54
	tagTheme(chevron, "Muted")
	chevron.Parent = trigger

	local list = Instance.new("Frame")
	list.Name = "DropdownList"
	list.Visible = false
	list.Position = UDim2.fromOffset(12, LIST_Y)
	list.Size = UDim2.new(1, -24, 0, listMax)
	list.BackgroundColor3 = THEME.Topbar
	list.BorderSizePixel = 0
	list.ClipsDescendants = true
	list.ZIndex = 60
	tagTheme(list, "Topbar")
	list.Parent = shell
	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 6)
	listCorner.Parent = list
	local listStroke = Instance.new("UIStroke")
	listStroke.Color = THEME.Border
	listStroke.Thickness = 1
	tagTheme(listStroke, "Border")
	listStroke.Parent = list
	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop = UDim.new(0, 4)
	listPad.PaddingBottom = UDim.new(0, 4)
	listPad.PaddingLeft = UDim.new(0, 4)
	listPad.PaddingRight = UDim.new(0, 4)
	listPad.Parent = list
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 3)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = list

	local optionButtons= {}

	local function refreshOptionStyles()
		for i, btn in optionButtons do
			local selected = i == index
			btn.BackgroundColor3 = if selected then THEME.Accent else THEME.Element
			btn.TextColor3 = if selected then Color3.fromRGB(255, 255, 255) else THEME.Text
			tagTheme(btn, if selected then "Accent" else "Element", if selected then "White" else "Text")
		end
	end

	local function setOpen(state)
		if state and openDropdownCloser then
			openDropdownCloser()
		end
		isOpen = state
		list.Visible = state
		shell.Size = UDim2.new(1, 0, 0, if state then LIST_Y + listMax + 8 else COLLAPSED_H)
		chevron.Text = if state then "â´" else "â¾"
		if state then
			openDropdownCloser = function()
				isOpen = false
				list.Visible = false
				shell.Size = UDim2.new(1, 0, 0, COLLAPSED_H)
				chevron.Text = "â¾"
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
		onChanged(options[index])
		notify(name, options[index])
	end

	for i, option in options do
		local btn = Instance.new("TextButton")
		btn.Name = "Option_" .. option
		btn.Size = UDim2.new(1, 0, 0, ROW - 2)
		btn.BackgroundColor3 = THEME.Element
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.GothamMedium
		btn.Text = option
		btn.TextColor3 = THEME.Text
		btn.TextSize = 12
		btn.TextXAlignment = Enum.TextXAlignment.Center
		btn.LayoutOrder = i
		btn.ZIndex = 61
		tagTheme(btn, "Element", "Text")
		btn.Parent = list
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
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

createInputBind = function(
	name,
	desc,
	initialKey,
	initialMouse,
	onChanged
)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 54)
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	shell.Parent = widgetHost()
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	local shellStroke = Instance.new("UIStroke")
	shellStroke.Color = THEME.Border
	shellStroke.Transparency = 0.55
	shellStroke.Parent = shell
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 8)
	nameLabel.Size = UDim2.new(1, -130, 0, 18)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	nameLabel.Parent = shell
	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 28)
	descLabel.Size = UDim2.new(1, -130, 0, 16)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = THEME.Muted
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 53
	descLabel.Parent = shell
	local currentKey = initialKey
	local currentMouse = initialMouse
	local bindButton = Instance.new("TextButton")
	bindButton.AnchorPoint = Vector2.new(1, 0.5)
	bindButton.Position = UDim2.new(1, -12, 0.5, 0)
	bindButton.Size = UDim2.fromOffset(110, 28)
	bindButton.BackgroundColor3 = THEME.Background
	bindButton.BorderSizePixel = 0
	bindButton.Font = Enum.Font.GothamBold
	bindButton.Text = Util.formatInputBindLabel(currentKey, currentMouse)
	bindButton.TextColor3 = THEME.Text
	bindButton.TextSize = 12
	bindButton.ZIndex = 53
	bindButton.Parent = shell
	local bindCorner = Instance.new("UICorner")
	bindCorner.CornerRadius = UDim.new(0, 6)
	bindCorner.Parent = bindButton
	local function showCurrent()
		bindButton.Text = Util.formatInputBindLabel(currentKey, currentMouse)
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
				refreshKeybindHud()
				notify(name, "Bound to " .. keyCode.Name)
			end,
			applyMouse = function(mouseType)
				currentMouse = mouseType
				currentKey = Enum.KeyCode.Unknown
				showCurrent()
				listeningForKeybind = nil
				onChanged(currentKey, currentMouse)
				refreshKeybindHud()
				notify(name, "Bound to " .. Util.formatInputBindLabel(currentKey, currentMouse))
			end,
			cancel = function()
				showCurrent()
				listeningForKeybind = nil
			end,
		}
	end)
end

createStatLine = function(title, initial)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 34)
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	tagTheme(shell, "Element")
	shell.Parent = widgetHost()
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	local shellStroke = Instance.new("UIStroke")
	shellStroke.Color = THEME.Border
	shellStroke.Transparency = 0.55
	tagTheme(shellStroke, "Border")
	shellStroke.Parent = shell

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 0)
	nameLabel.Size = UDim2.new(0.55, 0, 1, 0)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = title
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 12
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	tagTheme(nameLabel, "Text")
	nameLabel.Parent = shell

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -12, 0, 0)
	valueLabel.Size = UDim2.new(0.42, 0, 1, 0)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.Text = initial
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.ZIndex = 53
	tagTheme(valueLabel, "Accent")
	valueLabel.Parent = shell

	return {
		Set = function(text)
			valueLabel.Text = text
		end,
	}
end

createTextField = function(name, desc, initial, onChanged)
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, 0, 0, 74)
	shell.BackgroundColor3 = THEME.Element
	shell.BorderSizePixel = 0
	shell.LayoutOrder = nextOrder()
	shell.ZIndex = 52
	tagTheme(shell, "Element")
	shell.Parent = widgetHost()
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = shell
	local shellStroke = Instance.new("UIStroke")
	shellStroke.Color = THEME.Border
	shellStroke.Transparency = 0.55
	tagTheme(shellStroke, "Border")
	shellStroke.Parent = shell

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(12, 6)
	nameLabel.Size = UDim2.new(1, -24, 0, 16)
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.Text = name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 53
	tagTheme(nameLabel, "Text")
	nameLabel.Parent = shell

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(12, 22)
	descLabel.Size = UDim2.new(1, -24, 0, 14)
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = THEME.Muted
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.ZIndex = 53
	tagTheme(descLabel, "Muted")
	descLabel.Parent = shell

	local input = Instance.new("TextBox")
	input.Position = UDim2.fromOffset(12, 40)
	input.Size = UDim2.new(1, -24, 0, 28)
	input.BackgroundColor3 = THEME.Topbar
	input.BorderSizePixel = 0
	input.ClearTextOnFocus = false
	input.Font = Enum.Font.Gotham
	input.PlaceholderText = "https://discord.com/api/webhooks/..."
	input.Text = initial
	input.TextColor3 = THEME.Text
	input.TextSize = 11
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.TextWrapped = true
	input.ZIndex = 53
	tagTheme(input, "Topbar", "Text")
	input.Parent = shell
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 6)
	inputCorner.Parent = input
	local inputPad = Instance.new("UIPadding")
	inputPad.PaddingLeft = UDim.new(0, 8)
	inputPad.PaddingRight = UDim.new(0, 8)
	inputPad.Parent = input

	local function commit()
		local value = string.gsub(input.Text, "^%s+", "")
		value = string.gsub(value, "%s+$", "")
		input.Text = value
		onChanged(value)
		pcall(saveUiConfig)
	end

	input.FocusLost:Connect(function()
		commit()
	end)

	return {
		Set = function(text)
			input.Text = text
		end,
	}
end

applyTheme = function(themeName)
	local preset = THEME_PRESETS[themeName]
	if not preset then
		return
	end
	CONFIG.ThemeName = themeName
	for key, value in preset do
		THEME[key] = value
	end
	syncThemeCompat()

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
		elseif role == "SubText" or role == "Muted" then
			return THEME.SubText
		elseif role == "Stroke" or role == "Border" then
			return THEME.Stroke
		elseif role == "ToggleOff" then
			return THEME.ToggleOff
		elseif role == "White" then
			return Color3.fromRGB(255, 255, 255)
		end
		return nil
	end

	local function paint(inst)
		if inst:GetAttribute("ThemeToggleOn") ~= nil and inst:IsA("GuiObject") then
			local on = inst:GetAttribute("ThemeToggleOn") == true
			local c = colorForRole(on and "Accent" or "ToggleOff")
			if c then
				inst.BackgroundColor3 = c
			end
			return
		end

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
				if inst:IsA("ScrollingFrame") then
					inst.ScrollBarImageColor3 = THEME.Accent
				end
				if (inst:IsA("TextLabel") or inst:IsA("TextButton")) and inst.BackgroundTransparency >= 1 then
					if role == "Text" or role == "SubText" or role == "Muted" or role == "White" or role == "Accent" then
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
	paint(keybindHudFrame)
	for _, d in keybindHudFrame:GetDescendants() do
		paint(d)
	end
	paint(targetInfoFrame)
	for _, d in targetInfoFrame:GetDescendants() do
		paint(d)
	end
	selectTab(selectedTab)
end
end

local redeemAllCodes
local startAutoRedeemLoop
do
	local redeemBusy = false
	local autoRedeemLoopRunning = false
	local cachedCodeRemotes = nil

local function addCodeRemote(list, seen, inst)
	if inst and not seen[inst] and (inst:IsA("RemoteFunction") or inst:IsA("RemoteEvent")) then
		seen[inst] = true
		table.insert(list, inst)
	end
end

local function collectCodeRemotes()
	local list= {}
	local seen= {}
	local rs = ReplicatedStorage

	local interactions = rs:FindFirstChild("Interactions")
	if interactions then
		local server = interactions:FindFirstChild("Server")
		if server then
			addCodeRemote(list, seen, server:FindFirstChild("RedeemCode"))
			addCodeRemote(list, seen, server:FindFirstChild("EnterCode"))
		end
	end

	local remotes = rs:FindFirstChild("Remotes")
	if remotes then
		addCodeRemote(list, seen, remotes:FindFirstChild("EnterCode"))
		addCodeRemote(list, seen, remotes:FindFirstChild("RedeemCode"))
		for _, child in remotes:GetChildren() do
			if string.find(string.lower(child.Name), "code", 1, true) then
				addCodeRemote(list, seen, child)
			end
		end
	end

	addCodeRemote(list, seen, rs:FindFirstChild("EnterCode"))
	addCodeRemote(list, seen, rs:FindFirstChild("RedeemCode"))

	return list
end

local function getCodeRemotes()
	if cachedCodeRemotes and #cachedCodeRemotes > 0 then
		return cachedCodeRemotes
	end
	pcall(function()
		ReplicatedStorage:WaitForChild("Interactions", 12)
	end)
	pcall(function()
		ReplicatedStorage:WaitForChild("Remotes", 8)
	end)
	cachedCodeRemotes = collectCodeRemotes()
	return cachedCodeRemotes
end

local function isRedeemResultGood(result, cashBefore, cashAfter)
	if cashBefore and cashAfter and cashAfter > cashBefore then
		return true
	end
	if result == true then
		return true
	end
	if typeof(result) == "string" then
		local lower = string.lower(result)
		if
			string.find(lower, "invalid", 1, true)
			or string.find(lower, "already", 1, true)
			or string.find(lower, "expired", 1, true)
			or string.find(lower, "error", 1, true)
		then
			return false
		end
		if
			string.find(lower, "redeem", 1, true)
			or string.find(lower, "success", 1, true)
			or string.find(lower, "claimed", 1, true)
			or string.find(lower, "reward", 1, true)
			or string.find(lower, "valid", 1, true)
		then
			return true
		end
	end
	return false
end

local function tryInvokeCodeRemote(remote, code, cashBefore)
	local ok, result = pcall(function()
		if remote:IsA("RemoteFunction") then
			return remote:InvokeServer(code)
		end
		if remote:IsA("RemoteEvent") then
			remote:FireServer(code)
			return "fired"
		end
		return nil
	end)
	if not ok then
		return false, result
	end
	task.wait(0.35)
	local cashAfter = Util.getPlayerCash()
	if isRedeemResultGood(result, cashBefore, cashAfter) then
		return true, result
	end
	if remote:IsA("RemoteFunction") then
		ok, result = pcall(function()
			return remote:InvokeServer({ Code = code })
		end)
		if ok then
			task.wait(0.35)
			cashAfter = Util.getPlayerCash()
			if isRedeemResultGood(result, cashBefore, cashAfter) then
				return true, result
			end
		end
	end
	return false, result
end

local function tryMainEventRedeem(code, cashBefore)
	local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
	if not mainEvent or not mainEvent:IsA("RemoteEvent") then
		return false
	end
	local payloads = {
		{ "EnterCode", code },
		{ "RedeemCode", code },
		{ "Code", code },
		{ code },
	}
	for _, payload in payloads do
		pcall(function()
			mainEvent:FireServer(table.unpack(payload))
		end)
		task.wait(0.35)
		local cashAfter = Util.getPlayerCash()
		if cashBefore and cashAfter and cashAfter > cashBefore then
			return true
		end
	end
	return false
end

local function tryGuiRedeem(code, cashBefore)
	pcall(function()
		local clientEvents = ReplicatedStorage:FindFirstChild("ClientEvents")
		local openWindow = if clientEvents then clientEvents:FindFirstChild("OpenWindow") else nil
		if openWindow and openWindow:IsA("BindableEvent") then
			openWindow:Fire("Codes")
		end
	end)
	task.wait(0.2)

	local codeBox= nil
	for _, desc in playerGui:GetDescendants() do
		if desc:IsA("TextBox") then
			local hint = string.lower(desc.Name .. " " .. (desc.PlaceholderText or "") .. " " .. desc.Text)
			if string.find(hint, "code", 1, true) or string.find(hint, "enter", 1, true) then
				codeBox = desc
				break
			end
		end
	end
	if codeBox then
		codeBox.Text = code
	end

	for _, desc in playerGui:GetDescendants() do
		if desc:IsA("TextButton") then
			local label = string.lower(desc.Text)
			if label == "redeem" or string.find(label, "redeem", 1, true) then
				pcall(function()
					local g = getgenv()
					local getconns = g.getconnections or (typeof(g.syn) == "table" and g.syn.get_connections)
					if typeof(getconns) == "function" then
						for _, conn in getconns(desc.MouseButton1Click) do
							if typeof(conn.Fire) == "function" then
								conn:Fire()
							end
						end
					else
						desc:Activate()
					end
				end)
			end
		end
	end

	task.wait(0.5)
	local cashAfter = Util.getPlayerCash()
	return cashBefore ~= nil and cashAfter ~= nil and cashAfter > cashBefore
end

local function redeemSingleCode(code)
	local cashBefore = Util.getPlayerCash()
	for _, remote in getCodeRemotes() do
		local ok = tryInvokeCodeRemote(remote, code, cashBefore)
		if ok then
			return true
		end
	end
	if tryMainEventRedeem(code, cashBefore) then
		return true
	end
	if tryGuiRedeem(code, cashBefore) then
		return true
	end
	return false
end

redeemAllCodes = function(silent)
	if redeemBusy then
		if not silent then
			notify("Codes", "Already redeemingâ¦")
		end
		return
	end
	cachedCodeRemotes = nil
	local remotes = getCodeRemotes()
	redeemBusy = true
	local attempted = 0
	local succeeded = 0
	local cashStart = Util.getPlayerCash() or 0
	for _, code in ACTIVE_CODES do
		if not scriptAlive then
			break
		end
		attempted += 1
		if redeemSingleCode(code) then
			succeeded += 1
		end
		task.wait(0.35)
	end
	redeemBusy = false
	if not silent then
		local cashEnd = Util.getPlayerCash() or cashStart
		local gained = math.max(0, cashEnd - cashStart)
		if gained > 0 then
			notify("Codes", string.format("+$%s cash Â· %d/%d codes", tostring(gained), succeeded, attempted))
		elseif succeeded > 0 then
			notify("Codes", string.format("Redeemed %d/%d (may already be claimed)", succeeded, attempted))
		elseif #remotes == 0 then
			notify("Codes", "Redeem remote missing â rejoin and try again")
		else
			notify("Codes", string.format("No cash gained Â· tried %d codes", attempted))
		end
	end
end

startAutoRedeemLoop = function()
	if autoRedeemLoopRunning then
		return
	end
	autoRedeemLoopRunning = true
	task.spawn(function()
		task.wait(3)
		while scriptAlive and CONFIG.AutoRedeemCodes do
			redeemAllCodes(true)
			local waited = 0
			while scriptAlive and CONFIG.AutoRedeemCodes and waited < 90 do
				task.wait(1)
				waited += 1
			end
		end
		autoRedeemLoopRunning = false
	end)
end
end

local teleportToShopSelection
do
local function getShopFolder()
	local ignored = workspace:FindFirstChild("Ignored")
	if not ignored then
		return nil
	end
	local shop = ignored:FindFirstChild("Shop")
	if shop and shop:IsA("Folder") then
		return shop
	end
	return nil
end

local function findShopListing(gunName)
	local shopFolder = getShopFolder()
	if not shopFolder then
		return nil
	end
	local prefix = "[" .. gunName .. "]"
	for _, child in shopFolder:GetChildren() do
		if child.Name:sub(1, #prefix) == prefix then
			return child
		end
	end
	for price = 1, 50000 do
		local listing = shopFolder:FindFirstChild(prefix .. " - $" .. price)
		if listing then
			return listing
		end
	end
	return nil
end

local function teleportCharacterToCFrame(target)
	local character = localPlayer.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return false
	end
	root.CFrame = target
	return true
end

teleportToShopSelection = function(label)
	local def = shopTeleportByLabel[label]
	if not def then
		return false, "Unknown shop"
	end
	if def.gunName then
		local listing = findShopListing(def.gunName)
		if listing then
			local head = listing:FindFirstChild("Head")
			if head and head:IsA("BasePart") then
				if teleportCharacterToCFrame(head.CFrame * CFrame.new(0, 3, 0)) then
					return true, def.label
				end
			end
		end
	end
	if def.fallback then
		if teleportCharacterToCFrame(CFrame.new(def.fallback)) then
			return true, def.label .. " (fallback)"
		end
	end
	return false, "Shop not found â rejoin or pick another location"
end
end

do
	local atmFarmLoopActive = false
	local farmInvisActive = false
	local farmSessionStartCash = 0
	local farmSessionStartClock = 0
	local farmAtmBreakCount = 0
	local lockedFarmCashier= nil
	local farmVisSaved= {}
	local farmHumanoidSaved = nil
	local FIST_TOOL_NAME = "Combat"

	local function rememberPart(part)
		if farmVisSaved[part] then
			return
		end
		farmVisSaved[part] = {
			Transparency = part.Transparency,
			LocalTransparencyModifier = part.LocalTransparencyModifier,
			CanCollide = part.CanCollide,
		}
	end

	local function rememberDecal(decal)
		if farmVisSaved[decal] then
			return
		end
		farmVisSaved[decal] = {
			Transparency = decal.Transparency,
		}
	end

	local function applyAtmFarmInvisibility()
		if not CONFIG.AtmFarmEnabled or not CONFIG.AtmFarmInvisible then
			return
		end
		local character = localPlayer.Character
		if not character then
			return
		end
		for _, desc in character:GetDescendants() do
			if desc:IsA("BasePart") then
				rememberPart(desc)
				desc.LocalTransparencyModifier = 1
				desc.Transparency = 1
				desc.CanCollide = false
			elseif desc:IsA("Decal") then
				rememberDecal(desc)
				desc.Transparency = 1
			elseif desc:IsA("Texture") then
				if not farmVisSaved[desc] then
					farmVisSaved[desc] = { Transparency = desc.Transparency }
				end
				desc.Transparency = 1
			end
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if not farmHumanoidSaved then
				farmHumanoidSaved = { DisplayDistanceType = humanoid.DisplayDistanceType }
			end
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
		farmInvisActive = true
	end

	local function restoreAtmFarmVisibilityImpl()
		if not farmInvisActive then
			return
		end
		for inst, saved in farmVisSaved do
			if inst.Parent then
				if inst:IsA("BasePart") then
					if saved.Transparency ~= nil then
						inst.Transparency = saved.Transparency
					end
					if saved.LocalTransparencyModifier ~= nil then
						inst.LocalTransparencyModifier = saved.LocalTransparencyModifier
					end
					if saved.CanCollide ~= nil then
						inst.CanCollide = saved.CanCollide
					end
				elseif inst:IsA("Decal") or inst:IsA("Texture") then
					if saved.Transparency ~= nil then
						inst.Transparency = saved.Transparency
					end
				end
			end
		end
		table.clear(farmVisSaved)
		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and farmHumanoidSaved and farmHumanoidSaved.DisplayDistanceType then
				humanoid.DisplayDistanceType = farmHumanoidSaved.DisplayDistanceType
			end
		end
		farmHumanoidSaved = nil
		farmInvisActive = false
	end

	restoreAtmFarmVisibility = restoreAtmFarmVisibilityImpl

	local function sendAtmFarmWebhook(title, description)
		if not CONFIG.AtmFarmWebhookEnabled then
			return
		end
		local url = CONFIG.AtmFarmWebhookUrl
		if typeof(url) ~= "string" or url == "" then
			return
		end
		if not string.find(url, "discord.com/api/webhooks", 1, true) then
			return
		end
		local payload = HttpService:JSONEncode({
			username = "NameHub Â· Da Hood",
			embeds = {
				{
					title = title,
					description = description,
					color = 5793266,
					footer = {
						text = localPlayer.Name .. " Â· PlaceId " .. tostring(game.PlaceId),
					},
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				},
			},
		})
		task.spawn(function()
			pcall(function()
				local g = getgenv()
				local req = g.request or g.http_request
				if typeof(g.syn) == "table" and typeof(g.syn.request) == "function" then
					req = g.syn.request
				end
				if typeof(req) == "function" then
					req({
						Url = url,
						Method = "POST",
						Headers = { ["Content-Type"] = "application/json" },
						Body = payload,
					})
				else
					HttpService:PostAsync(url, payload, Enum.HttpContentType.ApplicationJson, false)
				end
			end)
		end)
	end

	refreshAtmFarmStats = function()
		local cash = Util.getPlayerCash()
		local profit = if cash then cash - farmSessionStartCash else 0
		if atmFarmStatsUI.profit then
			atmFarmStatsUI.profit.Set(Util.formatCashAmount(profit))
		end
		if atmFarmStatsUI.cash then
			atmFarmStatsUI.cash.Set(if cash then Util.formatCashAmount(cash) else "â")
		end
		if atmFarmStatsUI.atms then
			atmFarmStatsUI.atms.Set(tostring(farmAtmBreakCount))
		end
		if atmFarmStatsUI.time then
			local elapsed = if farmSessionStartClock > 0 then os.clock() - farmSessionStartClock else 0
			atmFarmStatsUI.time.Set(Util.formatFarmDuration(elapsed))
		end
	end

	local function resetAtmFarmStatsImpl()
		farmSessionStartCash = Util.getPlayerCash() or 0
		farmSessionStartClock = if CONFIG.AtmFarmEnabled then os.clock() else 0
		farmAtmBreakCount = 0
		releaseFarmCashier()
		refreshAtmFarmStats()
	end

	resetAtmFarmStats = resetAtmFarmStatsImpl

	local function getFireClickDetector()
		local g = getgenv()
		if typeof(g.fireclickdetector) == "function" then
			return g.fireclickdetector
		end
		if typeof(g.syn) == "table" and typeof(g.syn.fire_click_detector) == "function" then
			return g.syn.fire_click_detector
		end
		return nil
	end

	local function tpCharacterTo(target)
		local character = localPlayer.Character
		if not character then
			return false
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			return false
		end
		root.CFrame = target
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			pcall(function()
				humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end)
		end
		return true
	end

	local function getCashierHead(cashier)
		local head = cashier:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head
		end
		return nil
	end

	local function getCashierAttackCFrame(cashier)
		local head = getCashierHead(cashier)
		if not head then
			return nil
		end
		local look = head.CFrame.LookVector
		local flatLook = Vector3.new(look.X, 0, look.Z)
		if flatLook.Magnitude < 0.01 then
			flatLook = Vector3.new(0, 0, -1)
		else
			flatLook = flatLook.Unit
		end
		local standPos = head.Position - flatLook * 5.75 + Vector3.new(0, -2.35, 0)
		local cashiers = workspace:FindFirstChild("Cashiers")
		if cashiers then
			for _, other in cashiers:GetChildren() do
				if other:IsA("Model") and other ~= cashier and other.Name ~= "VAULT" then
					local otherHead = getCashierHead(other)
					if otherHead then
						local away = standPos - otherHead.Position
						local flatAway = Vector3.new(away.X, 0, away.Z)
						local separation = flatAway.Magnitude
						if separation < 14 and separation > 0.01 then
							standPos += flatAway.Unit * ((14 - separation) * 1.15)
						end
					end
				end
			end
		end
		return CFrame.lookAt(standPos, head.Position + Vector3.new(0, -0.75, 0))
	end

	local function holdFarmPositionForCashier(cashier, duration)
		local endAt = os.clock() + duration
		while scriptAlive and CONFIG.AtmFarmEnabled and os.clock() < endAt do
			local target = getCashierAttackCFrame(cashier)
			if target then
				tpCharacterTo(target)
			end
			task.wait(0.05)
		end
	end

	local function isCharacterFarmReady()
		local character = localPlayer.Character
		if not character or not character:FindFirstChild("FULLY_LOADED_CHAR") then
			return false
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return false
		end
		local effects = character:FindFirstChild("BodyEffects")
		if effects then
			local ko = effects:FindFirstChild("K.O")
			if ko and ko:IsA("BoolValue") and ko.Value then
				return false
			end
		end
		return true
	end

	local function pickSingleFarmCashier()
		local cashiers = workspace:FindFirstChild("Cashiers")
		if not cashiers then
			return nil
		end
		local candidates= {}
		for _, child in cashiers:GetChildren() do
			if child:IsA("Model") and child.Name ~= "VAULT" then
				local humanoid = child:FindFirstChildOfClass("Humanoid")
				local head = getCashierHead(child)
				if humanoid and head and humanoid.Health > 0 then
					table.insert(candidates, { model = child, head = head })
				end
			end
		end
		if #candidates == 0 then
			return nil
		end
		table.sort(candidates, function(a, b)
			if math.abs(a.head.Position.X - b.head.Position.X) > 0.5 then
				return a.head.Position.X < b.head.Position.X
			end
			if math.abs(a.head.Position.Z - b.head.Position.Z) > 0.5 then
				return a.head.Position.Z < b.head.Position.Z
			end
			return a.model.Name < b.model.Name
		end)
		return candidates[1].model
	end

	local function findAvailableCashier()
		return pickSingleFarmCashier()
	end

	local function isCashierValid(cashier)
		if not cashier or not cashier.Parent then
			return false
		end
		local humanoid = cashier:FindFirstChildOfClass("Humanoid")
		local head = cashier:FindFirstChild("Head")
		return humanoid ~= nil
			and head ~= nil
			and head:IsA("BasePart")
			and humanoid.Health > 0
	end

	local function acquireFarmCashier()
		if lockedFarmCashier and isCashierValid(lockedFarmCashier) then
			return lockedFarmCashier
		end
		if lockedFarmCashier then
			local cashiers = workspace:FindFirstChild("Cashiers")
			local savedName = lockedFarmCashier.Name
			if cashiers then
				local sameName = cashiers:FindFirstChild(savedName)
				if sameName and sameName:IsA("Model") and isCashierValid(sameName) then
					lockedFarmCashier = sameName
					return sameName
				end
			end
		end
		lockedFarmCashier = pickSingleFarmCashier()
		return lockedFarmCashier
	end

	local function forceTpToFarmCashier(cashier)
		local attackCFrame = getCashierAttackCFrame(cashier)
		if not attackCFrame then
			return false
		end
		tpCharacterTo(attackCFrame)
		return true
	end

	local farmWasReady = false
	local farmRespawnConn= nil

	local function onFarmCharacterSpawned()
		if not CONFIG.AtmFarmEnabled or not atmFarmLoopActive then
			return
		end
		task.spawn(function()
			for _ = 1, 40 do
				if not scriptAlive or not CONFIG.AtmFarmEnabled or not atmFarmLoopActive then
					return
				end
				if isCharacterFarmReady() then
					break
				end
				task.wait(0.25)
			end
			if not isCharacterFarmReady() then
				return
			end
			local cashier = acquireFarmCashier()
			if not cashier then
				return
			end
			stowNonFistTools()
			for _ = 1, 6 do
				if not scriptAlive or not CONFIG.AtmFarmEnabled or not atmFarmLoopActive then
					return
				end
				forceTpToFarmCashier(cashier)
				holdFarmPositionForCashier(cashier, 0.12)
			end
		end)
	end

	local function releaseFarmCashier()
		lockedFarmCashier = nil
	end

	local function stowTools()
		local character = localPlayer.Character
		local backpack = localPlayer:FindFirstChild("Backpack")
		if not character or not backpack then
			return
		end
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				child.Parent = backpack
			end
		end
	end

	local function stowNonFistTools()
		local character = localPlayer.Character
		local backpack = localPlayer:FindFirstChild("Backpack")
		if not character or not backpack then
			return
		end
		for _, child in character:GetChildren() do
			if child:IsA("Tool") and child.Name ~= FIST_TOOL_NAME then
				child.Parent = backpack
			end
		end
		for _, child in backpack:GetChildren() do
			if child:IsA("Tool") and child.Name ~= FIST_TOOL_NAME then
				child.Parent = backpack
			end
		end
	end

	local function equipFists()
		local character = localPlayer.Character
		local backpack = localPlayer:FindFirstChild("Backpack")
		if not character or not backpack then
			return nil
		end
		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				child.Parent = backpack
			end
		end
		local fists = backpack:FindFirstChild(FIST_TOOL_NAME)
		if fists and fists:IsA("Tool") then
			fists.Parent = character
			return fists
		end
		return nil
	end

	local function fistHitOnce()
		local fists = equipFists()
		if not fists then
			return
		end
		pcall(function()
			fists:Activate()
		end)
		task.wait(0.12)
		pcall(function()
			fists:Activate()
		end)
	end

	local function collectNearbyMoney(cashier)
		local dropFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop")
		local character = localPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local fcd = getFireClickDetector()
		if not dropFolder or not root or not root:IsA("BasePart") or not fcd then
			return 0
		end
		local anchor = root.Position
		if cashier then
			local head = getCashierHead(cashier)
			if head then
				anchor = head.Position
			end
		end
		local collected = 0
		for _, item in dropFolder:GetChildren() do
			if item.Name == "MoneyDrop" then
				local pos= nil
				if item:IsA("BasePart") then
					pos = item.Position
				else
					local attr = item:GetAttribute("OriginalPos")
					if typeof(attr) == "Vector3" then
						pos = attr
					end
				end
				if pos and (pos - anchor).Magnitude <= 14 and (pos - root.Position).Magnitude <= 18 then
					local click = item:FindFirstChildOfClass("ClickDetector")
					if click then
						pcall(fcd, click)
						collected += 1
					end
				end
			end
		end
		return collected
	end

	startAtmFarmLoop = function()
		if atmFarmLoopActive then
			return
		end
		farmSessionStartCash = Util.getPlayerCash() or 0
		farmSessionStartClock = os.clock()
		farmAtmBreakCount = 0
		lockedFarmCashier = nil
		farmWasReady = false
		refreshAtmFarmStats()
		sendAtmFarmWebhook(
			"ATM Farm Started",
			string.format(
				"**%s** started farming.\nStarting cash: **%s**",
				localPlayer.Name,
				Util.formatCashAmount(farmSessionStartCash)
			)
		)
		atmFarmLoopActive = true
		if farmRespawnConn then
			farmRespawnConn:Disconnect()
		end
		farmRespawnConn = localPlayer.CharacterAdded:Connect(function()
			onFarmCharacterSpawned()
		end)
		task.spawn(function()
			while scriptAlive and CONFIG.AtmFarmEnabled and atmFarmLoopActive do
				if CONFIG.AtmFarmInvisible then
					applyAtmFarmInvisibility()
				end
				if not isCharacterFarmReady() then
					farmWasReady = false
					task.wait(0.5)
					continue
				end

				if not farmWasReady then
					farmWasReady = true
					stowNonFistTools()
					local respawnCashier = acquireFarmCashier()
					if respawnCashier then
						for _ = 1, 4 do
							forceTpToFarmCashier(respawnCashier)
							holdFarmPositionForCashier(respawnCashier, 0.15)
						end
					end
				end

				stowNonFistTools()

				local cashier = acquireFarmCashier()
				if not cashier then
					task.wait(1)
					continue
				end

				local attackCFrame = getCashierAttackCFrame(cashier)
				if not attackCFrame then
					task.wait(0.35)
					continue
				end

				local atmBrokenThisCycle = false

				tpCharacterTo(attackCFrame)
				task.wait(0.35)
				holdFarmPositionForCashier(cashier, 0.2)
				stowNonFistTools()
				fistHitOnce()
				task.wait(0.45)
				holdFarmPositionForCashier(cashier, 0.25)

				local collectUntil = os.clock() + 8
				local idleTicks = 0
				while scriptAlive and CONFIG.AtmFarmEnabled and os.clock() < collectUntil do
					holdFarmPositionForCashier(cashier, 0.08)
					local picked = collectNearbyMoney(cashier)
					if picked > 0 then
						idleTicks = 0
						task.wait(0.12)
					else
						idleTicks += 1
						task.wait(0.2)
					end
					local hum = cashier:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health <= 0 then
						if not atmBrokenThisCycle then
							atmBrokenThisCycle = true
							farmAtmBreakCount += 1
							refreshAtmFarmStats()
						end
						if idleTicks >= 3 then
							break
						end
					end
					if idleTicks >= 10 then
						break
					end
				end

				stowTools()
				if atmBrokenThisCycle or not isCashierValid(cashier) then
					releaseFarmCashier()
					task.wait(1.2)
				else
					task.wait(0.45)
				end
			end
			atmFarmLoopActive = false
			restoreAtmFarmVisibilityImpl()
		end)
		task.spawn(function()
			while scriptAlive and CONFIG.AtmFarmEnabled and atmFarmLoopActive do
				if CONFIG.AtmFarmInvisible then
					applyAtmFarmInvisibility()
				end
				task.wait(0.12)
			end
		end)
		task.spawn(function()
			while scriptAlive and CONFIG.AtmFarmEnabled and atmFarmLoopActive do
				refreshAtmFarmStats()
				task.wait(1)
			end
		end)
	end

	stopAtmFarmLoop = function()
		if atmFarmLoopActive then
			local cash = Util.getPlayerCash() or farmSessionStartCash
			local profit = cash - farmSessionStartCash
			local elapsed = if farmSessionStartClock > 0 then os.clock() - farmSessionStartClock else 0
			refreshAtmFarmStats()
			sendAtmFarmWebhook(
				"ATM Farm Stopped",
				string.format(
					"**%s** stopped farming.\nProfit: **%s**\nATMs broken: **%d**\nTime: **%s**",
					localPlayer.Name,
					Util.formatCashAmount(profit),
					farmAtmBreakCount,
					Util.formatFarmDuration(elapsed)
				)
			)
		end
		atmFarmLoopActive = false
		if farmRespawnConn then
			farmRespawnConn:Disconnect()
			farmRespawnConn = nil
		end
		farmWasReady = false
		releaseFarmCashier()
		stowTools()
		restoreAtmFarmVisibilityImpl()
	end
end

createTab("Main", "Main")
createTab("AtmFarm", "Farm")
createTab("Aimbot", "Aim")
createTab("Silent", "Silent")
createTab("Visuals", "ESP")
createTab("Settings", "Set")
selectTab("Main")

beginPage("Main")
createSection("MAIN")

local function setSpeedEnabled(value, silent)
	CONFIG.SpeedEnabled = value
	if toggleUI.speed then
		toggleUI.speed.Set(value)
	end
	if value then
		ensureMovementLoop()
	end
	applyMovementMods()
	if not silent then
		notify("Speed", if value then "ON" else "OFF")
	end
end

local function setJumpEnabled(value, silent)
	CONFIG.JumpEnabled = value
	if toggleUI.jump then
		toggleUI.jump.Set(value)
	end
	if value then
		ensureMovementLoop()
	end
	applyMovementMods()
	if not silent then
		notify("Jump", if value then "ON" else "OFF")
	end
end

toggleUI.speed = createToggle("Speed", "Faster walk while enabled", CONFIG.SpeedEnabled, function(value)
	setSpeedEnabled(value, true)
end)
createKeybind("Speed Keybind", "Toggle walk speed on/off", CONFIG.SpeedKey, function(keyCode)
	CONFIG.SpeedKey = keyCode
end)
createSlider("Walk Speed", "Studs per second", 16, 120, CONFIG.WalkSpeed, function(value)
	CONFIG.WalkSpeed = value
	if CONFIG.SpeedEnabled then
		applyMovementMods()
	end
end)
toggleUI.jump = createToggle("Jump Height", "Higher jumps", CONFIG.JumpEnabled, function(value)
	setJumpEnabled(value, true)
end)
createKeybind("Jump Keybind", "Toggle jump height on/off", CONFIG.JumpKey, function(keyCode)
	CONFIG.JumpKey = keyCode
end)
createSlider("Jump Height", "Jump power", 7, 150, CONFIG.JumpHeight, function(value)
	CONFIG.JumpHeight = value
	if CONFIG.JumpEnabled then
		applyMovementMods()
	end
end)

createSection("SHOP TELEPORT")

local selectedShopTeleport = CONFIG.ShopTeleportTarget

createDropdown(
	"Shop",
	"Teleport to a gun shop listing or nearby location",
	SHOP_TELEPORT_LABELS,
	CONFIG.ShopTeleportTarget,
	function(value)
		selectedShopTeleport = value
		CONFIG.ShopTeleportTarget = value
	end
)
createButton("Teleport To Shop", Color3.fromRGB(88, 101, 242), function()
	local ok, detail = teleportToShopSelection(selectedShopTeleport)
	if ok then
		notify("Shop Teleport", "Teleported to " .. detail)
	else
		notify("Shop Teleport", detail)
	end
end)

createSection("FLY & NOCLIP")

local function setFlyEnabled(value, silent)
	CONFIG.FlyEnabled = value
	if toggleUI.fly then
		toggleUI.fly.Set(value)
	end
	if value then
		ensureFlyLoop()
		prepareFlyCharacter()
	else
		stopFlyCharacter()
	end
	if not silent then
		notify("Fly", if value then "ON" else "OFF")
	end
end

local function setNoclipEnabled(value, silent)
	CONFIG.NoclipEnabled = value
	if toggleUI.noclip then
		toggleUI.noclip.Set(value)
	end
	if value then
		local character = localPlayer.Character
		if character then
			setupNoclipForCharacter(character)
		end
	else
		restoreNoclipParts()
	end
	if not silent then
		notify("Noclip", if value then "ON" else "OFF")
	end
end

toggleUI.fly = createToggle(
	"Fly",
	"CFrame fly â WASD + Space/Ctrl Â· no velocity constraints",
	CONFIG.FlyEnabled,
	function(value)
		setFlyEnabled(value, true)
	end
)
createKeybind("Fly Keybind", "Toggle fly on/off", CONFIG.FlyKey, function(keyCode)
	CONFIG.FlyKey = keyCode
end)
createSlider("Fly Speed", "Studs per second (keep low to avoid flags)", 10, 100, CONFIG.FlySpeed, function(value)
	CONFIG.FlySpeed = value
end)
createSlider("Fly Boost", "Speed multiplier while holding Shift", 1, 4, CONFIG.FlyBoostMultiplier, function(value)
	CONFIG.FlyBoostMultiplier = value
end)
createSlider("Vertical Mult", "Up/down speed (Space / LeftCtrl)", 0.25, 3, CONFIG.FlyVerticalMultiplier, function(value)
	CONFIG.FlyVerticalMultiplier = value
end)

toggleUI.noclip = createToggle("Noclip", "Walk through walls while enabled", CONFIG.NoclipEnabled, function(value)
	setNoclipEnabled(value, true)
end)
createKeybind("Noclip Keybind", "Toggle noclip on/off", CONFIG.NoclipKey, function(keyCode)
	CONFIG.NoclipKey = keyCode
end)

createSection("QUALITY OF LIFE")

local function setThirdPersonEnabled(value, silent)
	CONFIG.ThirdPersonEnabled = value
	if toggleUI.thirdPerson then
		toggleUI.thirdPerson.Set(value)
	end
	if not value then
		restoreThirdPersonCamera()
	else
		updateThirdPerson()
	end
	if not silent then
		notify("Third Person", if value then "ON" else "OFF")
	end
end

local function setSilentAimEnabled(value, silent)
	silentAimEnabled = value
	if toggleUI.silentAim then
		toggleUI.silentAim.Set(value)
	end
	if not value then
		lockedSilentTarget = nil
		silentMarker.Visible = false
		silentFovCircle.Visible = false
	end
	if not silent then
		notify("Silent Aim", if value then "ON" else "OFF")
	end
end

toggleUI.thirdPerson = createToggle("Third Person", "Zoom-out camera behind your character", CONFIG.ThirdPersonEnabled, function(value)
	setThirdPersonEnabled(value, true)
end)
createKeybind("Third Person Key", "Toggle third person on/off", CONFIG.ThirdPersonKey, function(keyCode)
	CONFIG.ThirdPersonKey = keyCode
end)
createSlider("Third Person Distance", "Default zoom Â· scroll wheel in 3rd person", 12, 80, CONFIG.ThirdPersonDistance, function(value)
	CONFIG.ThirdPersonDistance = value
	if CONFIG.ThirdPersonEnabled then
		updateThirdPerson()
	end
end)
createToggle("Auto Get Up", "Try to stand up faster when K.O.", CONFIG.AutoGetUpEnabled, function(value)
	CONFIG.AutoGetUpEnabled = value
end)
createToggle("Anti Stomp", "Spam get-up while knocked to avoid stomps", CONFIG.AntiStompEnabled, function(value)
	CONFIG.AntiStompEnabled = value
end)
createToggle("Target Marker", "Ring on the player aim is locking", CONFIG.ShowTargetMarker, function(value)
	CONFIG.ShowTargetMarker = value
	if not value then
		targetMarker.Visible = false
	end
end)

beginPage("AtmFarm")
createSection("ATM FARM")
toggleUI.atmFarm = createToggle(
	"ATM Farm",
	"Fists only â TP to ATM, punch once, auto pickup cash Â· loops until off",
	CONFIG.AtmFarmEnabled,
	function(value)
		CONFIG.AtmFarmEnabled = value
		if value then
			startAtmFarmLoop()
			notify("ATM Farm", "Started")
		else
			stopAtmFarmLoop()
			notify("ATM Farm", "Stopped")
		end
	end
)
createToggle(
	"Farm Invisibility",
	"Hide your character while ATM farm is on â harder for others to target you",
	CONFIG.AtmFarmInvisible,
	function(value)
		CONFIG.AtmFarmInvisible = value
		if not value then
			restoreAtmFarmVisibility()
		end
	end
)

createSection("SESSION STATS")
atmFarmStatsUI.profit = createStatLine("Session Profit", "$0")
atmFarmStatsUI.cash = createStatLine("Current Cash", "â")
atmFarmStatsUI.atms = createStatLine("ATMs Broken", "0")
atmFarmStatsUI.time = createStatLine("Farm Time", "0:00")
createButton("Reset Stats", Color3.fromRGB(88, 101, 242), function()
	resetAtmFarmStats()
	notify("ATM Farm", "Session stats reset")
end)

createSection("DISCORD WEBHOOK")
createToggle(
	"Webhook Alerts",
	"Send Discord messages when farm starts and stops",
	CONFIG.AtmFarmWebhookEnabled,
	function(value)
		CONFIG.AtmFarmWebhookEnabled = value
		pcall(saveUiConfig)
	end
)
createTextField(
	"Webhook URL",
	"Paste your Discord webhook URL here",
	CONFIG.AtmFarmWebhookUrl,
	function(value)
		CONFIG.AtmFarmWebhookUrl = value
		pcall(saveUiConfig)
	end
)
task.defer(refreshAtmFarmStats)

beginPage("Aimbot")
createSection("AIMBOT")

setAimEnabled = function(value, silent)
	aimEnabled = value
	if toggleUI.aim then
		toggleUI.aim.Set(value)
	end
	if not value then
		currentTarget = nil
		lockedTarget = nil
		aimLookAt = nil
		aimCameraActive = false
		fovCircle.Visible = false
	end
	if not silent then
		notify("Aim Assist", if value then "ON" else "OFF")
	end
end

toggleUI.aim = createToggle("Aim Assist", "Lock onto players in FOV", aimEnabled, function(value)
	setAimEnabled(value, true)
end)
createInputBind(
	"Aimbot Keybind",
	"Keyboard Â· LMB Â· RMB â Hold locks while pressed",
	CONFIG.ToggleKey,
	CONFIG.ToggleMouse,
	function(keyCode, mouseType)
		CONFIG.ToggleKey = keyCode
		CONFIG.ToggleMouse = mouseType
		refreshKeybindHud()
	end
)
createDropdown(
	"Aim Mode",
	"Hold = lock while key held Â· Toggle = press to switch",
	AIM_MODE_OPTIONS,
	CONFIG.AimActivationMode,
	function(value)
		CONFIG.AimActivationMode = value
		if value == "Hold" and aimEnabled then
			setAimEnabled(false, true)
		end
		aimKeyHeld = false
		currentTarget = nil
		lockedTarget = nil
		aimLookAt = nil
		aimCameraActive = false
		fovCircle.Visible = false
	end
)
createSlider("FOV Radius", "Pixel radius around crosshair", 80, 400, CONFIG.FOVRadius, function(value)
	CONFIG.FOVRadius = value
end)
createSlider("Smoothness", "Higher = harder lock (0.95+ = snap)", 0.05, 1, CONFIG.Smoothness, function(value)
	CONFIG.Smoothness = value
end)
createSlider("Max Distance", "Ignore targets beyond range", 50, 800, CONFIG.MaxWorldDistance, function(value)
	CONFIG.MaxWorldDistance = value
end)
createDropdown("Target Part", "Aim point on the character", TARGET_PART_OPTIONS, CONFIG.TargetPartName, function(value)
	CONFIG.TargetPartName = value
end)
createToggle("Snap Lock", "Instant snap like Arsenal (or use 0.95+ smooth)", CONFIG.AimSnapLock, function(value)
	CONFIG.AimSnapLock = value
end)
createToggle("Sticky Lock", "Keep target until they leave FOV", CONFIG.AimStickyLock, function(value)
	CONFIG.AimStickyLock = value
end)
createToggle("Rapid Fire", "Hold LMB to fire faster while aimbot is active", CONFIG.AimRapidFireEnabled, function(value)
	CONFIG.AimRapidFireEnabled = value
end)
createSlider("Rapid Fire Rate", "Higher = faster shots while aimbot rapid fire is on", 1, 30, CONFIG.AimRapidFireRate, function(value)
	CONFIG.AimRapidFireRate = value
end)
createToggle("FOV Circle", "Show aim FOV ring", CONFIG.ShowFOVCircle, function(value)
	CONFIG.ShowFOVCircle = value
end)
createSection("OVERLAY")
createToggle("Target Info", "Side panel with full stats while locked on someone", CONFIG.ShowTargetInfo, function(value)
	CONFIG.ShowTargetInfo = value
	if not value then
		targetInfoFrame.Visible = false
	end
end)
createSection("CHECKS")
createToggle("Team Check", "Skip same team / team color", CONFIG.TeamCheckEnabled, function(value)
	CONFIG.TeamCheckEnabled = value
	currentTarget = nil
	lockedTarget = nil
end)
createToggle("Skip Knocked", "Ignore K.O. players", CONFIG.SkipKnocked, function(value)
	CONFIG.SkipKnocked = value
end)
createToggle("Skip Grabbed", "Ignore grabbed players", CONFIG.SkipGrabbed, function(value)
	CONFIG.SkipGrabbed = value
end)
createToggle("Wall Check", "Only lock players with clear line of sight", CONFIG.WallCheckEnabled, function(value)
	CONFIG.WallCheckEnabled = value
	currentTarget = nil
	lockedTarget = nil
end)

beginPage("Silent")
createSection("SILENT AIM")
toggleUI.silentAim = createToggle(
	"Silent Aim",
	"Redirect gun rays to FOV targets Â· experimental",
	silentAimEnabled,
	function(value)
		setSilentAimEnabled(value, true)
	end
)
createKeybind("Silent Aim Key", "Toggle silent aim on/off", CONFIG.SilentAimKey, function(keyCode)
	CONFIG.SilentAimKey = keyCode
end)
createSlider("Silent FOV Radius", "Pixel radius around crosshair", 80, 400, CONFIG.SilentFOVRadius, function(value)
	CONFIG.SilentFOVRadius = value
end)
createToggle("Silent FOV Circle", "Show purple FOV ring while silent is on", CONFIG.SilentShowFOVCircle, function(value)
	CONFIG.SilentShowFOVCircle = value
	if not value then
		silentFovCircle.Visible = false
	end
end)
createToggle("Sticky Lock", "Keep silent target until invalid", CONFIG.SilentAimStickyLock, function(value)
	CONFIG.SilentAimStickyLock = value
	lockedSilentTarget = nil
end)
createToggle("Silent Marker", "Purple ring on silent target", CONFIG.SilentAimShowMarker, function(value)
	CONFIG.SilentAimShowMarker = value
	if not value then
		silentMarker.Visible = false
	end
end)
createToggle("Show Tracer", "Brief line when a shot redirects", CONFIG.SilentAimShowTracer, function(value)
	CONFIG.SilentAimShowTracer = value
end)
createSlider("Fire Cooldown", "Lower = faster Â· value is x0.01 sec", 1, 50, 5, function(value)
	CONFIG.SilentAimFireCooldown = value / 100
end)
createToggle("Rapid Fire", "Hold LMB to fire faster while silent aim is on", CONFIG.SilentRapidFireEnabled, function(value)
	CONFIG.SilentRapidFireEnabled = value
end)
createSlider("Rapid Fire Rate", "Higher = faster shots while silent rapid fire is on", 1, 30, CONFIG.SilentRapidFireRate, function(value)
	CONFIG.SilentRapidFireRate = value
end)

beginPage("Visuals")
createSection("ESP")
local espToggle = createToggle("ESP Enabled", "Show players through walls", CONFIG.ESPEnabled, function(value)
	CONFIG.ESPEnabled = value
	if not value then
		updateEsp()
	end
end)
createToggle("Boxes", "Corner boxes on players", CONFIG.ESPBoxes, function(value)
	CONFIG.ESPBoxes = value
end)
createToggle("Names", "Show player names", CONFIG.ESPNames, function(value)
	CONFIG.ESPNames = value
end)
createToggle("Distance", "Show distance in studs", CONFIG.ESPDistance, function(value)
	CONFIG.ESPDistance = value
end)
createToggle("Health Bar", "Show health bar", CONFIG.ESPHealthBar, function(value)
	CONFIG.ESPHealthBar = value
end)
createToggle("Skeleton", "Bone lines on players", CONFIG.ESPSkeleton, function(value)
	CONFIG.ESPSkeleton = value
end)
createToggle("Chams", "Highlight outline through walls", CONFIG.ESPHighlights, function(value)
	CONFIG.ESPHighlights = value
end)
createToggle("Armor Bar", "Show Da Hood armor on ESP", CONFIG.ESPArmorBar, function(value)
	CONFIG.ESPArmorBar = value
end)
createToggle("Weapon Label", "Show equipped gun name", CONFIG.ESPWeaponLabel, function(value)
	CONFIG.ESPWeaponLabel = value
end)
createToggle("Gun ESP", "Labels on dropped guns in the world", CONFIG.ESPGunESP, function(value)
	CONFIG.ESPGunESP = value
	if not value then
		clearGunEspLabels()
	end
end)
createToggle("Tracers", "Line from screen to player", CONFIG.ESPTracers, function(value)
	CONFIG.ESPTracers = value
end)
createSlider("Tracer Thickness", "Line width in pixels", 1, 4, CONFIG.ESPTracerThickness, function(value)
	CONFIG.ESPTracerThickness = value
end)
createToggle("Tracer From Bottom", "Off = draw from screen center", CONFIG.ESPTracerFromBottom, function(value)
	CONFIG.ESPTracerFromBottom = value
end)
createSlider("ESP Max Distance", "Hide ESP beyond range", 50, 800, CONFIG.ESPMaxDistance, function(value)
	CONFIG.ESPMaxDistance = value
end)

beginPage("Settings")
createSection("APPEARANCE")
createDropdown(
	"Theme",
	"Open the list and pick a theme",
	THEME_OPTIONS,
	CONFIG.ThemeName,
	function(value)
		applyTheme(value)
	end
)
createSection("CODES")
createToggle("Auto Redeem Codes", "Redeem all active Da Hood codes", CONFIG.AutoRedeemCodes, function(value)
	CONFIG.AutoRedeemCodes = value
	if value then
		startAutoRedeemLoop()
		notify("Auto Redeem", "Enabled â trying all codes")
	else
		notify("Auto Redeem", "Disabled")
	end
end)
createButton("Redeem All Now", Color3.fromRGB(70, 130, 220), function()
	task.spawn(function()
		redeemAllCodes(false)
	end)
end)
createSection("SCRIPT")
createButton("Join Discord", Color3.fromRGB(88, 101, 242), function()
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
	end)
	notify("Discord", if copied then "Invite copied" else url)
end)
createButton("Unload NameHub DH", Color3.fromRGB(200, 60, 70), function()
	if getgenv().NameHubDHUnload then
		getgenv().NameHubDHUnload()
	end
end)

selectTab("Main")
applyTheme(CONFIG.ThemeName)
applySavedUiLayout()
pcall(saveUiConfig)

aimShouldLock = function()
	if CONFIG.AimActivationMode == "Hold" then
		return aimEnabled or aimKeyHeld
	end
	return aimEnabled
end

getAimScanPosition = function()
	camera = workspace.CurrentCamera
	if camera and aimShouldLock() and not menuOpen then
		return camera.ViewportSize * 0.5
	end
	return Util.getMouseViewport()
end

local function forceMenuCursor(wantCursor)
	if wantCursor then
		if savedMouseBehavior == nil then
			savedMouseBehavior = UserInputService.MouseBehavior
			savedMouseIconEnabled = UserInputService.MouseIconEnabled
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	else
		if savedMouseBehavior ~= nil then
			UserInputService.MouseBehavior = savedMouseBehavior
			UserInputService.MouseIconEnabled = savedMouseIconEnabled
			savedMouseBehavior = nil
		end
	end
end

local function applyMouseState()
	if menuOpen then
		-- Da Hood resets mouse every frame in third person â keep cursor free for the menu
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	elseif aimShouldLock() then
		-- LockCenter breaks Da Hood speed/jump â hide the cursor without locking when those are on
		if CONFIG.SpeedEnabled or CONFIG.JumpEnabled or CONFIG.FlyEnabled then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = false
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end
	end
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

local function releaseAimHold()
	aimKeyHeld = false
	if not aimEnabled then
		currentTarget = nil
		lockedTarget = nil
		aimLookAt = nil
		aimCameraActive = false
		fovCircle.Visible = false
	end
end

local function pressAimBind()
	if menuOpen then
		return
	end
	if CONFIG.AimActivationMode == "Hold" then
		aimKeyHeld = true
	else
		setAimEnabled(not aimEnabled)
	end
end

local function setMenuVisible(visible)
	menuOpen = visible
	menuFrame.Visible = visible
	keybindHudFrame.Visible = not visible
	forceMenuCursor(visible)
end

local function applyAimCamera()
	if CONFIG.ThirdPersonEnabled then
		return
	end
	if not aimLookAt or not aimShouldLock() or menuOpen or not aimCameraActive then
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local current = camera.CFrame
	local goal = CFrame.lookAt(current.Position, aimLookAt)
	if CONFIG.AimSnapLock or CONFIG.Smoothness >= 0.85 then
		camera.CFrame = goal
	else
		camera.CFrame = current:Lerp(goal, math.clamp(CONFIG.Smoothness, 0.05, 1))
	end
end

local function ensureAimRenderStep()
	if aimRenderBound then
		return
	end
	aimRenderBound = true
	RunService:BindToRenderStep("NameHubDHAim", Enum.RenderPriority.Last.Value, function()
		if scriptAlive then
			pcall(applyAimCamera)
		end
	end)
end

local function resetMovementBaseline()
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	movementBase.walkSpeed = humanoid.WalkSpeed
	movementBase.jumpHeight = humanoid.JumpHeight
	movementBase.jumpPower = humanoid.JumpPower
	movementBase.useJumpPower = humanoid.UseJumpPower
end

local function applyMovementMods()
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if CONFIG.SpeedEnabled then
		humanoid.WalkSpeed = CONFIG.WalkSpeed
	else
		humanoid.WalkSpeed = movementBase.walkSpeed
	end
	if CONFIG.JumpEnabled then
		if humanoid.UseJumpPower then
			humanoid.JumpPower = CONFIG.JumpHeight
		else
			humanoid.JumpHeight = CONFIG.JumpHeight
		end
	else
		humanoid.JumpHeight = movementBase.jumpHeight
		humanoid.JumpPower = movementBase.jumpPower
		humanoid.UseJumpPower = movementBase.useJumpPower
	end
end

local function disconnectMovementHooks()
	for _, conn in movementConns do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(movementConns)
end

local function hookMovementHumanoid(humanoid)
	disconnectMovementHooks()
	resetMovementBaseline()
	table.insert(
		movementConns,
		humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			if not scriptAlive or not CONFIG.SpeedEnabled then
				return
			end
			if humanoid.WalkSpeed ~= CONFIG.WalkSpeed then
				humanoid.WalkSpeed = CONFIG.WalkSpeed
			end
		end)
	)
	table.insert(
		movementConns,
		humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
			if not scriptAlive or not CONFIG.JumpEnabled or humanoid.UseJumpPower then
				return
			end
			if humanoid.JumpHeight ~= CONFIG.JumpHeight then
				humanoid.JumpHeight = CONFIG.JumpHeight
			end
		end)
	)
	table.insert(
		movementConns,
		humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
			if not scriptAlive or not CONFIG.JumpEnabled or not humanoid.UseJumpPower then
				return
			end
			if humanoid.JumpPower ~= CONFIG.JumpHeight then
				humanoid.JumpPower = CONFIG.JumpHeight
			end
		end)
	)
	applyMovementMods()
end

local function ensureMovementLoop()
	if movementStepBound then
		return
	end
	movementStepBound = true
	RunService:BindToRenderStep("NameHubDHMove", Enum.RenderPriority.Last.Value, function()
		if scriptAlive and (CONFIG.SpeedEnabled or CONFIG.JumpEnabled) then
			applyMovementMods()
		end
	end)
end

local function bindMovementForCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
		or character:WaitForChild("Humanoid", 15) 
	if humanoid and humanoid:IsA("Humanoid") then
		hookMovementHumanoid(humanoid)
	end
	if CONFIG.NoclipEnabled then
		setupNoclipForCharacter(character)
	end
	if CONFIG.FlyEnabled then
		prepareFlyCharacter()
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

restoreNoclipParts = function()
	resetNoclipCache()
	for part, wasCollide in noclipPartState do
		if part.Parent then
			part.CanCollide = wasCollide
		end
	end
	table.clear(noclipPartState)
end

setupNoclipForCharacter = function(character)
	resetNoclipCache()
	local function trackPart(part)
		if noclipPartState[part] == nil then
			noclipPartState[part] = part.CanCollide
		end
		part.CanCollide = false
		table.insert(noclipTrackedParts, part)
	end
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			trackPart(descendant)
		end
	end
	noclipWatchConn = character.DescendantAdded:Connect(function(descendant)
		if CONFIG.NoclipEnabled and descendant:IsA("BasePart") then
			trackPart(descendant)
		end
	end)
end

local function updateNoclip()
	if not CONFIG.NoclipEnabled then
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

local function getFlyInputDirection()
	camera = workspace.CurrentCamera
	if not camera then
		return Vector3.zero, CONFIG.FlySpeed
	end
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	look = Vector3.new(look.X, 0, look.Z)
	right = Vector3.new(right.X, 0, right.Z)
	if look.Magnitude > 0 then
		look = look.Unit
	end
	if right.Magnitude > 0 then
		right = right.Unit
	end
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
	return move, speed
end

local function disconnectFlyHooks()
	if flyHumanoidConn then
		pcall(function()
			flyHumanoidConn:Disconnect()
		end)
		flyHumanoidConn = nil
	end
end

prepareFlyCharacter = function()
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if flySavedAutoRotate == nil then
		flySavedAutoRotate = humanoid.AutoRotate
	end
	humanoid.AutoRotate = false
	humanoid.PlatformStand = false
	disconnectFlyHooks()
	flyHumanoidConn = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
		if scriptAlive and CONFIG.FlyEnabled and humanoid.PlatformStand then
			humanoid.PlatformStand = false
		end
	end)
	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	end)
end

stopFlyCharacter = function()
	local character = localPlayer.Character
	if not character then
		flySavedAutoRotate = nil
		disconnectFlyHooks()
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = Util.getCharacterPart(character, "HumanoidRootPart")
	if humanoid then
		if flySavedAutoRotate ~= nil then
			humanoid.AutoRotate = flySavedAutoRotate
		end
		flySavedAutoRotate = nil
		humanoid.PlatformStand = false
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		end)
	end
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	disconnectFlyHooks()
end

local function updateFly(deltaTime)
	if not CONFIG.FlyEnabled or menuOpen or CONFIG.AtmFarmEnabled then
		return
	end
	local character = localPlayer.Character
	if not character or not Util.isAlive(character) then
		return
	end
	local hrp = Util.getCharacterPart(character, "HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return
	end
	if flySavedAutoRotate == nil then
		prepareFlyCharacter()
	end
	humanoid.PlatformStand = false
	local move, speed = getFlyInputDirection()
	local step = move * speed * deltaTime
	if step.Magnitude > 0 then
		hrp.CFrame = hrp.CFrame + step
	end
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	pcall(function()
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

ensureFlyLoop = function()
	if flyStepBound then
		return
	end
	flyStepBound = true
	RunService:BindToRenderStep("NameHubDHFly", Enum.RenderPriority.First.Value, function(deltaTime)
		if scriptAlive and CONFIG.FlyEnabled and not CONFIG.AtmFarmEnabled then
			pcall(updateFly, deltaTime)
		end
	end)
end

do
local function layoutCornerBox(arms, x, y, w, h, color)
	local len = math.clamp(math.min(w, h) * 0.22, 5, 11)
	local t = 1
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

local function placeEspLine(frame, from, to, color, thickness)
	local delta = to - from
	local length = delta.Magnitude
	if length < 1 then
		frame.Visible = false
		return
	end
	frame.Visible = true
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.25
	frame.Size = UDim2.fromOffset(length, thickness)
	frame.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
	frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

local function getTracerOrigin(viewport)
	if CONFIG.ESPTracerFromBottom then
		return Vector2.new(viewport.X / 2, viewport.Y - 2)
	end
	return Vector2.new(viewport.X / 2, viewport.Y / 2)
end

local function getFootPart(character)
	return Util.getCharacterPart(character, "LeftFoot")
		or Util.getCharacterPart(character, "Left Leg")
		or Util.getCharacterPart(character, "LeftLowerLeg")
		or Util.getCharacterPart(character, "HumanoidRootPart")
end

local SKELETON_BONES= {
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
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local espVisuals= {}
local gunEspLabels= {}
local espMissCounts= {}
local ESP_HIDE_GRACE = 3
local espHost = Instance.new("Frame")
espHost.Name = "ESP"
espHost.BackgroundTransparency = 1
espHost.Size = UDim2.fromScale(1, 1)
espHost.ZIndex = 30
espHost.Parent = screenGui

local function getPlayerWeaponName(character)
	for _, child in character:GetChildren() do
		if child:IsA("Tool") then
			return child.Name
		end
	end
	return nil
end

local function getPlayerArmorValues(character)
	local effects = character:FindFirstChild("BodyEffects")
	if not effects then
		return 0, 200
	end
	local armor = effects:FindFirstChild("Armor")
	if armor and armor:IsA("IntValue") then
		return math.max(0, armor.Value), 200
	end
	return 0, 200
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

clearGunEspLabels = function()
	for inst, label in gunEspLabels do
		if label then
			label:Destroy()
		end
		gunEspLabels[inst] = nil
	end
end

local function updateGunEspLabels()
	if not CONFIG.ESPEnabled or not CONFIG.ESPGunESP then
		clearGunEspLabels()
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local seen= {}
	for _, inst in workspace:GetDescendants() do
		if inst:IsA("Tool") and inst.Parent == workspace and inst:FindFirstChild("Handle") then
			seen[inst] = true
			local handle = inst:FindFirstChild("Handle") 
			local screenPos = camera:WorldToViewportPoint(handle.Position)
			if screenPos.Z > 0 then
				local label = gunEspLabels[inst]
				if not label then
					label = Instance.new("TextLabel")
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.GothamBold
					label.TextSize = 11
					label.TextColor3 = Color3.fromRGB(255, 210, 90)
					label.TextStrokeTransparency = 0.45
					label.ZIndex = 32
					label.Parent = espHost
					gunEspLabels[inst] = label
				end
				label.Visible = true
				label.Text = inst.Name
				label.Position = UDim2.fromOffset(screenPos.X - 30, screenPos.Y - 10)
				label.Size = UDim2.fromOffset(80, 14)
			elseif gunEspLabels[inst] then
				gunEspLabels[inst].Visible = false
			end
		end
	end
	for inst, label in gunEspLabels do
		if not seen[inst] then
			label:Destroy()
			gunEspLabels[inst] = nil
		end
	end
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

local function getEspScreenBox(character)
	local topLeft, boxSize = getScreenBox(character)
	if topLeft and boxSize and boxSize.X >= 2 and boxSize.Y >= 2 then
		return topLeft, boxSize
	end

	local head = Util.getTargetPart(character)
	local foot = getFootPart(character)
	if head and foot then
		local hPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
		local fPos = camera:WorldToViewportPoint(foot.Position - Vector3.new(0, 2.5, 0))
		if hPos.Z > 0 or fPos.Z > 0 then
			local minY = math.min(hPos.Y, fPos.Y)
			local maxY = math.max(hPos.Y, fPos.Y)
			local height = math.max(maxY - minY, 8)
			local width = math.max(height * 0.55, 8)
			local cx = (hPos.X + fPos.X) * 0.5
			return Vector2.new(cx - width * 0.5, minY), Vector2.new(width, height)
		end
	end

	local root = Util.getCharacterPart(character, "HumanoidRootPart") or head
	if not root then
		return nil, nil
	end
	local sp = camera:WorldToViewportPoint(root.Position)
	if sp.Z <= 0 then
		return nil, nil
	end
	local height = 50
	local width = 28
	return Vector2.new(sp.X - width * 0.5, sp.Y - height * 0.5), Vector2.new(width, height)
end

local function hideEspVisuals(visuals)
	visuals.root.Visible = false
	hideCornerBox(visuals.boxArms)
	visuals.name.Visible = false
	visuals.dist.Visible = false
	visuals.healthBg.Visible = false
	visuals.tracer.Visible = false
	if visuals.weapon then
		visuals.weapon.Visible = false
	end
	if visuals.armorBg then
		visuals.armorBg.Visible = false
	end
	if visuals.highlight then
		visuals.highlight.Enabled = false
	end
	for _, line in visuals.skeletonLines do
		line.Visible = false
	end
end

local function markEspMiss(player, visuals)
	local misses = (espMissCounts[player] or 0) + 1
	espMissCounts[player] = misses
	if misses >= ESP_HIDE_GRACE and visuals then
		hideEspVisuals(visuals)
	end
end

local function clearEspMiss(player)
	espMissCounts[player] = nil
end

local function createSkeletonLine(parent, name)
	local line = Instance.new("Frame")
	line.Name = name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = CONFIG.ESPSkeletonColor
	line.BorderSizePixel = 0
	line.BackgroundTransparency = 0.05
	line.Visible = false
	line.ZIndex = 31
	line.Parent = parent
	return line
end

local function updateSkeletonEsp(visuals, character)
	if not CONFIG.ESPSkeleton then
		for _, line in visuals.skeletonLines do
			line.Visible = false
		end
		return
	end
	local lineIndex = 0
	for _, bone in SKELETON_BONES do
		local a = Util.getCharacterPart(character, bone[1])
		local b = Util.getCharacterPart(character, bone[2])
		if a and b then
			local sa = camera:WorldToViewportPoint(a.Position)
			local sb = camera:WorldToViewportPoint(b.Position)
			if sa.Z > 0 and sb.Z > 0 then
				lineIndex += 1
				local line = visuals.skeletonLines[lineIndex]
				if line then
					placeEspLine(
						line,
						Vector2.new(sa.X, sa.Y),
						Vector2.new(sb.X, sb.Y),
						CONFIG.ESPSkeletonColor,
						1
					)
				end
			end
		end
	end
	for i = lineIndex + 1, #visuals.skeletonLines do
		visuals.skeletonLines[i].Visible = false
	end
end

local function createEspFeature(player)
	local root = Instance.new("Frame")
	root.Name = player.Name
	root.BackgroundTransparency = 1
	root.Visible = false
	root.ZIndex = 31
	root.Parent = espHost
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Size = UDim2.fromScale(1, 1)
	box.Parent = root
	local boxArms= {}
	for _ = 1, 8 do
		local arm = Instance.new("Frame")
		arm.BorderSizePixel = 0
		arm.BackgroundColor3 = CONFIG.ESPEnemyColor
		arm.Visible = false
		arm.Parent = box
		table.insert(boxArms, arm)
	end
	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.TextSize = 12
	name.TextColor3 = THEME.Text
	name.TextStrokeTransparency = 0.5
	name.ZIndex = 32
	name.Parent = root
	local weapon = Instance.new("TextLabel")
	weapon.BackgroundTransparency = 1
	weapon.Font = Enum.Font.GothamMedium
	weapon.TextSize = 10
	weapon.TextColor3 = Color3.fromRGB(255, 210, 90)
	weapon.TextStrokeTransparency = 0.5
	weapon.Visible = false
	weapon.ZIndex = 32
	weapon.Parent = root
	local dist = Instance.new("TextLabel")
	dist.BackgroundTransparency = 1
	dist.Font = Enum.Font.Gotham
	dist.TextSize = 11
	dist.TextColor3 = THEME.SubText
	dist.TextStrokeTransparency = 0.6
	dist.ZIndex = 32
	dist.Parent = root
	local healthBg = Instance.new("Frame")
	healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	healthBg.BorderSizePixel = 0
	healthBg.ZIndex = 32
	healthBg.Parent = root
	local healthFill = Instance.new("Frame")
	healthFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
	healthFill.BorderSizePixel = 0
	healthFill.ZIndex = 33
	healthFill.Parent = healthBg
	local armorBg = Instance.new("Frame")
	armorBg.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
	armorBg.BorderSizePixel = 0
	armorBg.Visible = false
	armorBg.ZIndex = 32
	armorBg.Parent = root
	local armorFill = Instance.new("Frame")
	armorFill.BackgroundColor3 = Color3.fromRGB(88, 140, 255)
	armorFill.BorderSizePixel = 0
	armorFill.ZIndex = 33
	armorFill.Parent = armorBg
	local tracer = Instance.new("Frame")
	tracer.Name = "Tracer"
	tracer.BackgroundColor3 = CONFIG.ESPTracerColor
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.ZIndex = 30
	tracer.Parent = espHost
	local skeletonLines= {}
	for i = 1, #SKELETON_BONES do
		table.insert(skeletonLines, createSkeletonLine(espHost, "Skel_" .. player.Name .. "_" .. i))
	end
	return {
		root = root,
		boxArms = boxArms,
		name = name,
		weapon = weapon,
		dist = dist,
		healthBg = healthBg,
		healthFill = healthFill,
		armorBg = armorBg,
		armorFill = armorFill,
		tracer = tracer,
		skeletonLines = skeletonLines,
		highlight = nil,
	}
end

local function clearEspForPlayer(player)
	local visuals = espVisuals[player]
	if visuals then
		visuals.root:Destroy()
		if visuals.tracer then
			visuals.tracer:Destroy()
		end
		for _, line in visuals.skeletonLines do
			line:Destroy()
		end
		if visuals.highlight then
			visuals.highlight:Destroy()
		end
		espVisuals[player] = nil
	end
	clearEspMiss(player)
end

updateEsp = function()
	if not CONFIG.ESPEnabled then
		for player in espVisuals do
			clearEspForPlayer(player)
		end
		clearGunEspLabels()
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local camPos = camera.CFrame.Position
	local viewportSize = camera.ViewportSize
	local tracerOrigin = getTracerOrigin(viewportSize)
	local seen= {}

	for _, other in Players:GetPlayers() do
		if other == localPlayer then
			continue
		end

		local character = other.Character
		if not character or not Util.isAlive(character) then
			clearEspForPlayer(other)
			continue
		end

		if Util.isKnocked(character) then
			seen[other] = true
			local knockedVisuals = espVisuals[other]
			if knockedVisuals then
				hideEspVisuals(knockedVisuals)
			end
			continue
		end

		local root = Util.getCharacterPart(character, "HumanoidRootPart")
		if not root then
			clearEspForPlayer(other)
			continue
		end

		local dist = (root.Position - camPos).Magnitude
		if dist > CONFIG.ESPMaxDistance or not Util.passesTeamCheck(other) then
			clearEspForPlayer(other)
			continue
		end

		seen[other] = true
		local visuals = espVisuals[other] or createEspFeature(other)
		espVisuals[other] = visuals

		local topLeft, boxSize = getEspScreenBox(character)
		if not topLeft or not boxSize then
			markEspMiss(other, visuals)
			continue
		end
		clearEspMiss(other)

		local x = topLeft.X
		local y = topLeft.Y
		local width = boxSize.X
		local height = boxSize.Y
		visuals.root.Visible = true

		if CONFIG.ESPBoxes then
			layoutCornerBox(visuals.boxArms, x, y, width, height, CONFIG.ESPEnemyColor)
		else
			hideCornerBox(visuals.boxArms)
		end

		if CONFIG.ESPNames then
			visuals.name.Visible = true
			local displayName = other.DisplayName
			if visuals.name.Text ~= displayName then
				visuals.name.Text = displayName
			end
			visuals.name.Position = UDim2.fromOffset(x, y - 16)
			visuals.name.Size = UDim2.fromOffset(width, 14)
		else
			visuals.name.Visible = false
		end

		if CONFIG.ESPWeaponLabel then
			local weaponName = getPlayerWeaponName(character)
			if weaponName then
				visuals.weapon.Visible = true
				visuals.weapon.Text = "[" .. weaponName .. "]"
				visuals.weapon.Position = UDim2.fromOffset(x, y - 28)
				visuals.weapon.Size = UDim2.fromOffset(width, 12)
			else
				visuals.weapon.Visible = false
			end
		else
			visuals.weapon.Visible = false
		end

		if CONFIG.ESPDistance then
			visuals.dist.Visible = true
			local distText = string.format("%dm", math.floor(dist + 0.5))
			if visuals.dist.Text ~= distText then
				visuals.dist.Text = distText
			end
			visuals.dist.Position = UDim2.fromOffset(x, y + height + 2)
			visuals.dist.Size = UDim2.fromOffset(width, 12)
		else
			visuals.dist.Visible = false
		end

		if CONFIG.ESPHealthBar then
			local hum = character:FindFirstChildOfClass("Humanoid")
			local pct = if hum then math.clamp(hum.Health / hum.MaxHealth, 0, 1) else 0
			visuals.healthBg.Visible = true
			visuals.healthBg.Position = UDim2.fromOffset(x - 5, y)
			visuals.healthBg.Size = UDim2.fromOffset(3, height)
			visuals.healthFill.Size = UDim2.new(1, 0, pct, 0)
			visuals.healthFill.Position = UDim2.new(0, 0, 1 - pct, 0)
		else
			visuals.healthBg.Visible = false
		end

		if CONFIG.ESPArmorBar then
			local armorValue, armorMax = getPlayerArmorValues(character)
			local pct = if armorMax > 0 then math.clamp(armorValue / armorMax, 0, 1) else 0
			visuals.armorBg.Visible = true
			visuals.armorBg.Position = UDim2.fromOffset(x - 9, y)
			visuals.armorBg.Size = UDim2.fromOffset(3, height)
			visuals.armorFill.Size = UDim2.new(1, 0, pct, 0)
			visuals.armorFill.Position = UDim2.new(0, 0, 1 - pct, 0)
		else
			visuals.armorBg.Visible = false
		end

		if CONFIG.ESPHighlights then
			if not visuals.highlight or not visuals.highlight.Parent then
				if visuals.highlight then
					visuals.highlight:Destroy()
				end
				local highlight = Instance.new("Highlight")
				highlight.Name = "NameHubDHHighlight"
				highlight.FillColor = CONFIG.ESPHighlightColor
				highlight.OutlineColor = CONFIG.ESPHighlightColor
				highlight.FillTransparency = 0.82
				highlight.OutlineTransparency = 0.15
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Adornee = character
				highlight.Parent = character
				visuals.highlight = highlight
			end
			visuals.highlight.Enabled = true
			visuals.highlight.Adornee = character
		elseif visuals.highlight then
			visuals.highlight.Enabled = false
		end

		if CONFIG.ESPTracers then
			local screenPos = camera:WorldToViewportPoint(root.Position)
			if screenPos.Z > 0 then
				placeEspLine(
					visuals.tracer,
					tracerOrigin,
					Vector2.new(screenPos.X, screenPos.Y),
					CONFIG.ESPTracerColor,
					math.max(1, math.floor(CONFIG.ESPTracerThickness + 0.5))
				)
			else
				visuals.tracer.Visible = false
			end
		else
			visuals.tracer.Visible = false
		end

		updateSkeletonEsp(visuals, character)
	end

	for player in espVisuals do
		if not seen[player] then
			clearEspForPlayer(player)
		end
	end
	updateGunEspLabels()
end
end

local thirdPersonSaved = {
	cameraMode = nil ,
	minZoom = nil ,
	maxZoom = nil ,
	occlusion = nil ,
	cameraType = nil ,
}

restoreThirdPersonCamera = function()
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
	thirdPersonSaved.cameraMode = nil
	thirdPersonSaved.minZoom = nil
	thirdPersonSaved.maxZoom = nil
	thirdPersonSaved.occlusion = nil
	thirdPersonSaved.cameraType = nil
end

updateThirdPerson = function()
	if not CONFIG.ThirdPersonEnabled or menuOpen then
		return
	end
	if thirdPersonSaved.cameraMode == nil then
		thirdPersonSaved.cameraMode = localPlayer.CameraMode
		thirdPersonSaved.minZoom = localPlayer.CameraMinZoomDistance
		thirdPersonSaved.maxZoom = localPlayer.CameraMaxZoomDistance
		thirdPersonSaved.occlusion = localPlayer.DevCameraOcclusionMode
		camera = workspace.CurrentCamera
		if camera then
			thirdPersonSaved.cameraType = camera.CameraType
		end
	end
	local zoom = math.clamp(CONFIG.ThirdPersonDistance, 12, 80)
	localPlayer.CameraMode = Enum.CameraMode.Classic
	localPlayer.CameraMinZoomDistance = zoom
	localPlayer.CameraMaxZoomDistance = zoom
	localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	camera = workspace.CurrentCamera
	local character = localPlayer.Character
	if not camera or not character then
		return
	end
	local root = Util.getCharacterPart(character, "HumanoidRootPart")
		or Util.getCharacterPart(character, "UpperTorso")
	if not root then
		return
	end
	local focus = root.Position + Vector3.new(0, 1.5, 0)
	local lookTarget = if aimLookAt and aimCameraActive and aimShouldLock()
		then aimLookAt 
		else focus + camera.CFrame.LookVector * 120
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
	local camPos = focus - forward * zoom + Vector3.new(0, math.clamp(zoom * 0.2, 2.5, 14), 0)
	camera.CameraType = Enum.CameraType.Custom
	camera.CFrame = CFrame.lookAt(camPos, lookTarget)
end

local function resolveSilentAimShot()
	if not silentAimEnabled or menuOpen then
		return nil, nil, nil
	end
	local scanPos = Util.getMouseViewport()
	local fov = CONFIG.SilentFOVRadius
	local targetPlayer= nil
	if CONFIG.SilentAimStickyLock and lockedSilentTarget then
		if Util.isValidTarget(lockedSilentTarget, scanPos, fov) then
			targetPlayer = lockedSilentTarget
		end
	end
	if not targetPlayer then
		targetPlayer = Util.findClosestTargetAt(scanPos, fov)
		if CONFIG.SilentAimStickyLock then
			lockedSilentTarget = targetPlayer
		end
	end
	if not targetPlayer then
		return nil, nil, nil
	end
	local character = targetPlayer.Character
	if not character then
		return nil, nil, nil
	end
	local part = Util.getTargetPart(character)
	if not part then
		return nil, nil, nil
	end
	return part.Position, part, targetPlayer
end

updateSilentMarker = function(targetPlayer)
	if not CONFIG.SilentAimShowMarker or not silentAimEnabled or not targetPlayer then
		silentMarker.Visible = false
		return
	end
	local character = targetPlayer.Character
	local part = if character then Util.getTargetPart(character) else nil
	if not part then
		silentMarker.Visible = false
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local screenPos = camera:WorldToViewportPoint(part.Position)
	if screenPos.Z <= 0 then
		silentMarker.Visible = false
		return
	end
	local inset = GuiService:GetGuiInset()
	silentMarker.Visible = true
	silentMarker.Position = UDim2.fromOffset(screenPos.X + inset.X, screenPos.Y + inset.Y)
end

updateTargetMarker = function()
	if not CONFIG.ShowTargetMarker or not currentTarget or menuOpen then
		targetMarker.Visible = false
		return
	end
	local character = currentTarget.Character
	local part = if character then Util.getTargetPart(character) else nil
	if not part then
		targetMarker.Visible = false
		return
	end
	camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local screenPos = camera:WorldToViewportPoint(part.Position)
	if screenPos.Z <= 0 then
		targetMarker.Visible = false
		return
	end
	local inset = GuiService:GetGuiInset()
	targetMarker.Visible = true
	targetMarker.Position = UDim2.fromOffset(screenPos.X + inset.X, screenPos.Y + inset.Y)
end

updateTargetInfo = function()
	if not CONFIG.ShowTargetInfo or menuOpen then
		targetInfoFrame.Visible = false
		return
	end

	local targetPlayer= currentTarget
	local lockSource = "Aim Lock"
	if not targetPlayer and silentAimEnabled then
		local _, _, silentTarget = resolveSilentAimShot()
		targetPlayer = silentTarget
		lockSource = "Silent Aim"
	end

	if not targetPlayer then
		targetInfoFrame.Visible = false
		return
	end

	local character = targetPlayer.Character
	if not character then
		targetInfoFrame.Visible = false
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local targetPart = Util.getTargetPart(character)
	if not humanoid or not targetPart then
		targetInfoFrame.Visible = false
		return
	end

	local maxHealth = math.max(humanoid.MaxHealth, 1)
	local health = math.clamp(humanoid.Health, 0, maxHealth)
	local healthRatio = health / maxHealth
	targetInfoHealthFill.Size = UDim2.fromScale(healthRatio, 1)
	if healthRatio > 0.55 then
		targetInfoHealthFill.BackgroundColor3 = Color3.fromRGB(90, 220, 120)
	elseif healthRatio > 0.25 then
		targetInfoHealthFill.BackgroundColor3 = Color3.fromRGB(240, 190, 70)
	else
		targetInfoHealthFill.BackgroundColor3 = Color3.fromRGB(240, 90, 90)
	end

	local armor, armorMax = Util.getCharacterArmorValues(character)
	local armorRatio = if armorMax > 0 then math.clamp(armor / armorMax, 0, 1) else 0
	targetInfoArmorBg.Visible = armorMax > 0
	targetInfoArmorFill.Size = UDim2.fromScale(armorRatio, 1)

	local statusParts= {}
	if health <= 0 then
		table.insert(statusParts, "Dead")
	end
	if Util.getBodyEffectBool(character, "K.O") then
		table.insert(statusParts, "Knocked")
	end
	if Util.getBodyEffectBool(character, "Grabbed") then
		table.insert(statusParts, "Grabbed")
	end
	if #statusParts == 0 then
		table.insert(statusParts, "Alive")
	end

	local teamLabel = "None"
	if targetPlayer.Team then
		teamLabel = targetPlayer.Team.Name
	elseif targetPlayer.TeamColor then
		teamLabel = targetPlayer.TeamColor.Name
	end

	local distance = Util.getDistanceToCharacter(character)
	local distanceLabel = if distance then string.format("%d studs", math.floor(distance + 0.5)) else "â"
	local losLabel = if Util.hasLineOfSight(targetPart, character) then "Clear" else "Blocked"
	local displayName = targetPlayer.DisplayName
	local username = targetPlayer.Name
	local weapon = Util.getCharacterWeaponName(character)

	targetInfoFrame.Visible = true
	targetInfoName.Text = if displayName ~= username
		then string.format("%s (@%s)", displayName, username)
		else displayName
	targetInfoSource.Text = lockSource .. " Â· " .. CONFIG.TargetPartName
	targetInfoBody.Text = table.concat({
		string.format("Health Â· %d / %d", math.floor(health + 0.5), math.floor(maxHealth + 0.5)),
		string.format("Armor Â· %d / %d", armor, armorMax),
		"Weapon Â· " .. weapon,
		"Distance Â· " .. distanceLabel,
		"Team Â· " .. teamLabel,
		"Status Â· " .. table.concat(statusParts, " Â· "),
		"Line of sight Â· " .. losLabel,
		"UserId Â· " .. tostring(targetPlayer.UserId),
	}, "\n")
end

tryAutoGetUp = function()
	if not CONFIG.AutoGetUpEnabled and not CONFIG.AntiStompEnabled then
		return
	end
	local character = localPlayer.Character
	if not character then
		return
	end
	local effects = character:FindFirstChild("BodyEffects")
	if not effects then
		return
	end
	local ko = effects:FindFirstChild("K.O")
	if not ko or not ko:IsA("BoolValue") or not ko.Value then
		return
	end
	local now = os.clock()
	local delay = if CONFIG.AntiStompEnabled then 0.08 else 0.35
	if now - lastGetUpAttempt < delay then
		return
	end
	lastGetUpAttempt = now
	local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
	if mainEvent then
		pcall(function()
			mainEvent:FireServer("GetUp")
		end)
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end
end

installSilentAimHooks = function()
	local g = getgenv()
	local hookfunction = g.hookfunction
	if typeof(hookfunction) ~= "function" and typeof(g.syn) == "table" then
		hookfunction = g.syn.hook_function
	end
	if typeof(hookfunction) ~= "function" or g.NameHubDHRayHook then
		return
	end

	local rayHookDepth = 0

	local function wantsSilentRedirect(origin, direction)
		if not silentAimEnabled or menuOpen or not mouse1Held or not getEquippedTool() then
			return false
		end
		if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
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
		if not camera then
			return false
		end
		local pivot = character:GetPivot().Position
		if (origin - pivot).Magnitude > 40 and (origin - camera.CFrame.Position).Magnitude > 40 then
			return false
		end
		return true
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

	local function getSilentRedirect(origin, direction)
		if not wantsSilentRedirect(origin, direction) then
			return nil, nil
		end
		local aimPos, part = resolveSilentAimShot()
		if part and aimPos then
			return part, aimPos
		end
		return nil, nil
	end

	local oldRay = workspace.Raycast
	g.NameHubDHRayHook = hookfunction(oldRay, function(origin, direction, params)
		if rayHookDepth > 0 then
			return oldRay(origin, direction, params)
		end
		local redirectPart, redirectPos = getSilentRedirect(origin, direction)
		if redirectPart and redirectPos then
			rayHookDepth += 1
			local result = buildSilentRayResult(origin, redirectPart, redirectPos)
			rayHookDepth -= 1
			return result
		end
		return oldRay(origin, direction, params)
	end)

	local oldFindPartOnRay = workspace.FindPartOnRay
	if typeof(oldFindPartOnRay) == "function" then
		hookfunction(oldFindPartOnRay, function(ray, ignore, ...)
			if rayHookDepth > 0 or typeof(ray) ~= "Ray" then
				return oldFindPartOnRay(ray, ignore, ...)
			end
			local redirectPart, redirectPos = getSilentRedirect(ray.Origin, ray.Direction)
			if redirectPart and redirectPos then
				local delta = redirectPos - ray.Origin
				local normal = if delta.Magnitude > 0.01 then -delta.Unit else Vector3.yAxis
				return redirectPart, redirectPos, normal, Enum.Material.Plastic
			end
			return oldFindPartOnRay(ray, ignore, ...)
		end)
	end
end

task.defer(installSilentAimHooks)

do
	local lastAimRapidShot = 0
	local lastSilentRapidShot = 0
	local FARM_MELEE = { Combat = true, ["[HeavyWeights]"] = true, ["[Knife]"] = true }

	local function getRapidFireDelay(rate)
		local clamped = math.clamp(rate, 1, 30)
		return math.clamp(0.52 - (clamped - 1) * (0.495 / 29), 0.025, 0.52)
	end

	local function getRapidFireTool()
		local character = localPlayer.Character
		if not character then
			return nil
		end
		for _, child in character:GetChildren() do
			if child:IsA("Tool") and child:FindFirstChild("Handle") and not FARM_MELEE[child.Name] then
				return child
			end
		end
		return nil
	end

	local function fireHeldTool(tool)
		pcall(function()
			local g = getgenv()
			local getconnections = g.getconnections
			if typeof(getconnections) ~= "function" and typeof(g.syn) == "table" then
				getconnections = g.syn.get_connections
			end
			if typeof(getconnections) == "function" then
				for _, conn in getconnections(tool.Activated) do
					pcall(function()
						if typeof(conn) == "table" and typeof(conn.Function) == "function" then
							task.spawn(conn.Function)
						elseif typeof(conn) == "table" and typeof(conn.Fire) == "function" then
							conn:Fire()
						end
					end)
				end
			end
			tool:Activate()
		end)
	end

	updateRapidFire = function()
		if menuOpen or not mouse1Held then
			return
		end
		local tool = getRapidFireTool()
		if not tool then
			return
		end
		local now = os.clock()
		if silentAimEnabled and CONFIG.SilentRapidFireEnabled then
			local delay = getRapidFireDelay(CONFIG.SilentRapidFireRate)
			if now - lastSilentRapidShot >= delay then
				lastSilentRapidShot = now
				fireHeldTool(tool)
			end
			return
		end
		if aimShouldLock() and CONFIG.AimRapidFireEnabled then
			local delay = getRapidFireDelay(CONFIG.AimRapidFireRate)
			if now - lastAimRapidShot >= delay then
				lastAimRapidShot = now
				fireHeldTool(tool)
			end
		end
	end
end

local function acquireAimTarget()
	if CONFIG.AimStickyLock and lockedTarget then
		if Util.isValidTarget(lockedTarget, getAimScanPosition()) then
			return lockedTarget
		end
	end
	local closest = Util.findClosestTarget()
	lockedTarget = closest
	return closest
end

local connections= {}

local function bind(conn)
	table.insert(connections, conn)
end

bind(UserInputService.InputBegan:Connect(function(input, _gameProcessed)
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
		elseif listeningForKeybind.applyMouse and Util.isMouseBindInput(input.UserInputType) then
			listeningForKeybind.applyMouse(input.UserInputType)
		end
		return
	end
	if inputMatchesAimBind(input) and not menuOpen then
		pressAimBind()
		if input.UserInputType == Enum.UserInputType.Keyboard then
			return
		end
	end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == CONFIG.MenuKey then
			if uiLoading then
				return
			end
			setMenuVisible(not menuOpen)
			notify("Menu", if menuOpen then "Opened" else "Closed")
			return
		end
		if input.KeyCode == CONFIG.SpeedKey then
			setSpeedEnabled(not CONFIG.SpeedEnabled)
			return
		end
		if input.KeyCode == CONFIG.JumpKey then
			setJumpEnabled(not CONFIG.JumpEnabled)
			return
		end
		if input.KeyCode == CONFIG.FlyKey then
			setFlyEnabled(not CONFIG.FlyEnabled)
			return
		end
		if input.KeyCode == CONFIG.NoclipKey then
			setNoclipEnabled(not CONFIG.NoclipEnabled)
			return
		end
		if input.KeyCode == CONFIG.ThirdPersonKey then
			setThirdPersonEnabled(not CONFIG.ThirdPersonEnabled)
			return
		end
		if input.KeyCode == CONFIG.SilentAimKey then
			setSilentAimEnabled(not silentAimEnabled)
			return
		end
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouse1Held = true
	end
end))

bind(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouse1Held = false
	end
	if inputMatchesAimBind(input) and CONFIG.AimActivationMode == "Hold" then
		releaseAimHold()
	end
end))

bind(UserInputService.InputChanged:Connect(function(input)
	if not scriptAlive or menuOpen or not CONFIG.ThirdPersonEnabled then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local delta = input.Position.Z
		if delta ~= 0 then
			CONFIG.ThirdPersonDistance = math.clamp(
				CONFIG.ThirdPersonDistance - delta * CONFIG.ThirdPersonScrollStep,
				12,
				80
			)
			updateThirdPerson()
		end
	end
end))

bind(RunService.RenderStepped:Connect(function()
	if not scriptAlive then
		return
	end
	pcall(applyMouseState)
	local ok, err = pcall(function()
		camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local scanPos = getAimScanPosition()
		local inset = GuiService:GetGuiInset()
		if aimShouldLock() and not menuOpen then
			if CONFIG.ShowFOVCircle then
				fovCircle.Visible = true
				fovCircle.Size = UDim2.fromOffset(CONFIG.FOVRadius * 2, CONFIG.FOVRadius * 2)
				fovCircle.Position = UDim2.fromOffset(scanPos.X + inset.X, scanPos.Y + inset.Y)
			else
				fovCircle.Visible = false
			end
			currentTarget = acquireAimTarget()
			aimCameraActive = currentTarget ~= nil
			if currentTarget then
				local character = currentTarget.Character
				local part = if character then Util.getTargetPart(character) else nil
				if part then
					aimLookAt = part.Position
					ensureAimRenderStep()
				else
					aimLookAt = nil
				end
			else
				aimLookAt = nil
			end
		else
			fovCircle.Visible = false
			currentTarget = nil
			aimLookAt = nil
			aimCameraActive = false
		end
		local silentScan = Util.getMouseViewport()
		if silentAimEnabled and not menuOpen then
			if CONFIG.SilentShowFOVCircle then
				silentFovCircle.Visible = true
				silentFovCircle.Size = UDim2.fromOffset(CONFIG.SilentFOVRadius * 2, CONFIG.SilentFOVRadius * 2)
				silentFovCircle.Position = UDim2.fromOffset(silentScan.X + inset.X, silentScan.Y + inset.Y)
			else
				silentFovCircle.Visible = false
			end
			local _pos, _part, silentTarget = resolveSilentAimShot()
			updateSilentMarker(silentTarget)
		else
			silentFovCircle.Visible = false
			silentMarker.Visible = false
		end
		updateTargetMarker()
		updateTargetInfo()
		updateRapidFire()
	end)
	if not ok then
		warn("[NameHub DH] Loop error:", err)
	end
end))

bind(RunService.Heartbeat:Connect(function()
	if not scriptAlive then
		return
	end
	if CONFIG.SpeedEnabled or CONFIG.JumpEnabled then
		applyMovementMods()
	end
	local now = os.clock()
	if CONFIG.NoclipEnabled and now - perfTicks.noclip >= 0.2 then
		perfTicks.noclip = now
		pcall(updateNoclip)
	end
	if CONFIG.ThirdPersonEnabled then
		pcall(updateThirdPerson)
	end
	pcall(tryAutoGetUp)
	if CONFIG.ESPEnabled then
		if now - perfTicks.esp >= 0.04 then
			perfTicks.esp = now
			local ok, err = pcall(updateEsp)
			if not ok then
				warn("[NameHub DH] ESP error:", err)
			end
		end
	end
end))

localPlayer.CharacterAdded:Connect(function(character)
	task.defer(function()
		bindMovementForCharacter(character)
	end)
end)

local function unloadNameHubDH()
	if not scriptAlive then
		return
	end
	scriptAlive = false
	aimEnabled = false
	aimKeyHeld = false
	aimLookAt = nil
	CONFIG.FlyEnabled = false
	CONFIG.NoclipEnabled = false
	CONFIG.ThirdPersonEnabled = false
	CONFIG.AtmFarmEnabled = false
	CONFIG.AtmFarmInvisible = false
	CONFIG.AimRapidFireEnabled = false
	CONFIG.SilentRapidFireEnabled = false
	silentAimEnabled = false
	stopAtmFarmLoop()
	restoreAtmFarmVisibility()
	stopFlyCharacter()
	restoreNoclipParts()
	restoreThirdPersonCamera()
	clearGunEspLabels()
	targetMarker.Visible = false
	silentMarker.Visible = false
	targetInfoFrame.Visible = false
	silentFovCircle.Visible = false
	pcall(function()
		RunService:UnbindFromRenderStep("NameHubDHAim")
	end)
	pcall(function()
		RunService:UnbindFromRenderStep("NameHubDHMove")
	end)
	pcall(function()
		RunService:UnbindFromRenderStep("NameHubDHFly")
	end)
	disconnectMovementHooks()
	for _, conn in connections do
		pcall(function()
			conn:Disconnect()
		end)
	end
	forceMenuCursor(false)
	pcall(saveUiConfig)
	pcall(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end)
	screenGui:Destroy()
end

getgenv().NameHubDHUnload = unloadNameHubDH

setMenuVisible(false)
task.defer(function()
	local character = localPlayer.Character
	if character then
		bindMovementForCharacter(character)
	end
end)
if CONFIG.AutoRedeemCodes then
	startAutoRedeemLoop()
end
task.defer(function()
	if CONFIG.ESPEnabled then
		updateEsp()
	end
end)

local loaderFrame = Instance.new("Frame")
loaderFrame.Name = "Loader"
loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
loaderFrame.Position = UDim2.fromScale(0.5, 0.5)
loaderFrame.Size = UDim2.fromOffset(460, 124)
loaderFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
loaderFrame.BorderSizePixel = 0
loaderFrame.ZIndex = 80
loaderFrame.Parent = screenGui
local loaderStroke = Instance.new("UIStroke")
loaderStroke.Color = Color3.fromRGB(48, 48, 54)
loaderStroke.Parent = loaderFrame
local loaderLogo = Instance.new("TextLabel")
loaderLogo.BackgroundTransparency = 1
loaderLogo.Position = UDim2.fromOffset(18, 16)
loaderLogo.Size = UDim2.new(1, -120, 0, 24)
loaderLogo.Font = Enum.Font.GothamBold
loaderLogo.TextSize = 18
loaderLogo.TextXAlignment = Enum.TextXAlignment.Left
loaderLogo.TextColor3 = Color3.fromRGB(230, 55, 85)
loaderLogo.Text = "NAMEHUB"
loaderLogo.ZIndex = 81
loaderLogo.Parent = loaderFrame
local loaderPercent = Instance.new("TextLabel")
loaderPercent.BackgroundTransparency = 1
loaderPercent.AnchorPoint = Vector2.new(1, 0)
loaderPercent.Position = UDim2.new(1, -18, 0, 16)
loaderPercent.Size = UDim2.fromOffset(80, 24)
loaderPercent.Font = Enum.Font.GothamBold
loaderPercent.TextSize = 18
loaderPercent.TextXAlignment = Enum.TextXAlignment.Right
loaderPercent.TextColor3 = Color3.fromRGB(232, 232, 236)
loaderPercent.Text = "1%"
loaderPercent.ZIndex = 81
loaderPercent.Parent = loaderFrame
local loaderStatus = Instance.new("TextLabel")
loaderStatus.BackgroundTransparency = 1
loaderStatus.Position = UDim2.fromOffset(18, 44)
loaderStatus.Size = UDim2.new(1, -36, 0, 18)
loaderStatus.Font = Enum.Font.Gotham
loaderStatus.TextSize = 13
loaderStatus.TextXAlignment = Enum.TextXAlignment.Left
loaderStatus.TextColor3 = Color3.fromRGB(118, 116, 130)
loaderStatus.Text = "loading"
loaderStatus.ZIndex = 81
loaderStatus.Parent = loaderFrame
local loaderTrack = Instance.new("Frame")
loaderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
loaderTrack.BorderSizePixel = 0
loaderTrack.Position = UDim2.fromOffset(18, 78)
loaderTrack.Size = UDim2.new(1, -36, 0, 8)
loaderTrack.ZIndex = 81
loaderTrack.Parent = loaderFrame
local loaderFill = Instance.new("Frame")
loaderFill.BackgroundColor3 = Color3.fromRGB(230, 55, 85)
loaderFill.BorderSizePixel = 0
loaderFill.Size = UDim2.new(0.01, 0, 1, 0)
loaderFill.ZIndex = 82
loaderFill.Parent = loaderTrack
local loaderHint = Instance.new("TextLabel")
loaderHint.BackgroundTransparency = 1
loaderHint.Position = UDim2.fromOffset(18, 94)
loaderHint.Size = UDim2.new(1, -36, 0, 16)
loaderHint.Font = Enum.Font.Gotham
loaderHint.TextSize = 11
loaderHint.TextXAlignment = Enum.TextXAlignment.Left
loaderHint.TextColor3 = Color3.fromRGB(118, 116, 130)
loaderHint.Text = "da hood"
loaderHint.ZIndex = 81
loaderHint.Parent = loaderFrame

print("[NameHub DH] Da Hood build loading", game.PlaceId)
task.spawn(function()
	for step = 1, 100 do
		if not scriptAlive then
			return
		end
		loaderPercent.Text = tostring(step) .. "%"
		loaderFill.Size = UDim2.new(step / 100, 0, 1, 0)
		if step < 30 then
			loaderStatus.Text = "loading"
		elseif step < 60 then
			loaderStatus.Text = "preparing visuals"
		elseif step < 100 then
			loaderStatus.Text = "starting"
		else
			loaderStatus.Text = "ready"
		end
		task.wait(0.018)
	end
	uiLoading = false
	if loaderFrame then
		loaderFrame:Destroy()
	end
	setMenuVisible(true)
	notify("NameHub DH", "Insert opens the menu")
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
			else
				HttpService:PostAsync(url, payload, Enum.HttpContentType.ApplicationJson, false)
			end
		end)
	end)
end

reportLoadToDiscord("Da Hood")
