-----------------------------------------------------------------------
-- LibDBIcon-1.0
--
-- Allows addons to easily create a lightweight minimap icon as an alternative to heavier LDB displays.
--

local MAJOR, MINOR = "LibDBIcon-1.0", 47
if not LibStub then error(MAJOR .. " requires LibStub.") end
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.objects = lib.objects or {}
lib.callbackRegistered = lib.callbackRegistered or nil
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.notCreated = lib.notCreated or {}
lib.tooltip = lib.tooltip or nil

local next, Minimap = next, Minimap
local isDraggingButton = false

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function onEnter(self)
	if isDraggingButton then return end

	for _, button in next, lib.objects do
		if button.dataObject == self.dataObject then
			if button.dataObject.OnEnter then
				button.dataObject.OnEnter(button)
			end
			break
		end
	end
end

local function onLeave(self)
	if isDraggingButton then return end

	for _, button in next, lib.objects do
		if button.dataObject == self.dataObject then
			if button.dataObject.OnLeave then
				button.dataObject.OnLeave(button)
			end
			break
		end
	end
end

local function onClick(self, b)
	if isDraggingButton then return end
	for _, button in next, lib.objects do
		if button.dataObject == self.dataObject then
			if button.dataObject.OnClick then
				button.dataObject.OnClick(button, b)
			end
			break
		end
	end
end

local function onMouseDown(self)
	self.isMouseDown = true
	self.icon:UpdateCoord()
end

local function onMouseUp(self)
	self.isMouseDown = false
	self.icon:UpdateCoord()
end

local function onUpdate(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	local pos = 225
	if self.db then
		pos = math.deg(math.atan2(py - my, px - mx)) % 360
		self.db.minimapPos = pos
	else
		pos = self.minimapPos or pos
		self.minimapPos = pos
	end
	local angle = math.rad(pos or 0)
	local x, y = math.cos(angle), math.sin(angle)
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = { "TOPLEFT", "TOPRIGHT", "BOTTOMRIGHT", "BOTTOMLEFT" }
	local quadrant = floor((angle + 0.785398163) / 1.570796327) % 4 + 1
	local minimapRadius = (Minimap:GetWidth() / 2) + 5
	if minimapShape == "ROUND" then
		x, y = x * minimapRadius, y * minimapRadius
	elseif minimapShape == "SQUARE" then
		local diagRadius = 103.13708498985
		x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
	elseif minimapShape == "CORNER-TOPLEFT" then
		if quadrant == 1 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "CORNER-TOPRIGHT" then
		if quadrant == 2 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "CORNER-BOTTOMRIGHT" then
		if quadrant == 3 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "CORNER-BOTTOMLEFT" then
		if quadrant == 4 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-TOPLEFT" then
		if quadrant == 1 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-TOPRIGHT" then
		if quadrant == 2 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-BOTTOMRIGHT" then
		if quadrant == 3 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-BOTTOMLEFT" then
		if quadrant == 4 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	end

	self:ClearAllPoints()
	self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function onDragStart(self)
	self:LockHighlight()
	self.isMouseDown = true
	self.icon:UpdateCoord()
	self:SetScript("OnUpdate", onUpdate)
	isDraggingButton = true
	lib.tooltip:Hide()
	for _, button in next, lib.objects do
		if button.dataObject and button.dataObject.OnLeave and button ~= self then
			button.dataObject.OnLeave(button)
		end
	end
end

local function onDragStop(self)
	self:SetScript("OnUpdate", nil)
	self.isMouseDown = false
	self.icon:UpdateCoord()
	self:UnlockHighlight()
	isDraggingButton = false
end

local function createButton(name, object, db)
	local button = CreateFrame("Button", "LibDBIcon10_"..name, Minimap)
	button.dataObject = object
	button.db = db
	button:SetFrameStrata("MEDIUM")
	button:SetSize(31, 31)
	button:SetFrameLevel(8)
	button:RegisterForClicks("anyUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
	local overlay = button:CreateTexture(nil, "OVERLAY")
	button.overlay = overlay
	overlay:SetSize(53, 53)
	overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
	overlay:SetPoint("TOPLEFT")

	local background = button:CreateTexture(nil, "BACKGROUND")
	button.background = background
	background:SetSize(20, 20)
	background:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = button:CreateTexture(nil, "ARTWORK")
	button.icon = icon
	icon:SetSize(17, 17)
	icon:SetPoint("TOPLEFT", 7, -6)
	button.isMouseDown = false

	local coords = { 0, 1, 0, 1 }
	function icon:UpdateCoord()
		local coords = object.iconCoords or coords
		local deltaX, deltaY = 0, 0
		if button.isMouseDown then
			deltaX = (coords[2] - coords[1]) * 0.05
			deltaY = (coords[4] - coords[3]) * 0.05
		end
		self:SetTexCoord(coords[1] + deltaX, coords[2] - deltaX, coords[3] + deltaY, coords[4] - deltaY)
	end

	icon:UpdateCoord()

	icon:SetTexture(object.icon)

	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnClick", onClick)
	button:SetScript("OnDragStart", onDragStart)
	button:SetScript("OnDragStop", onDragStop)
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)

	lib.objects[name] = button

	if lib.loggedIn then
		lib:SetButtonToPosition(button, db[name] and db[name].minimapPos or object.minimapPos or 225)
	end

	lib.callbacks:Fire("LibDBIcon_IconCreated", button, name) -- Fire 'Icon Created' callback
end

-- We could use a metatable.__index on lib.objects, but then we'd create
-- the icons when checking things like :IsRegistered, which is not necessary.
local function check(name)
	if lib.notCreated[name] then
		createButton(name, lib.notCreated[name][1], lib.notCreated[name][2])
		lib.notCreated[name] = nil
	end
end

-- Wait a bit with the initial positioning to let any GetMinimapShape addons
-- load up.
if not lib.loggedIn then
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		for _, button in next, lib.objects do
			lib:SetButtonToPosition(button, button.db[button.dataObject.text] and button.db[button.dataObject.text].minimapPos or button.dataObject.minimapPos or 225)
		end
		lib.loggedIn = true
		f:SetScript("OnEvent", nil)
	end)
	f:RegisterEvent("PLAYER_LOGIN")
end

local function getDatabase(name)
	return lib.objects[name] and lib.objects[name].db or lib.notCreated[name] and lib.notCreated[name][2]
end

function lib:Register(name, object, db)
	if not object.icon then error("Can't register LDB objects without icons set!") end

	if lib.objects[name] or lib.notCreated[name] then error("Already registered.") end
	if not db or not db.hide then
		lib.notCreated[name] = { object, db }
	end
end

function lib:Hide(name)
	if not lib.objects[name] then return end
	lib.objects[name]:Hide()
end

function lib:Show(name)
	check(name)
	local button = lib.objects[name]
	if button then
		button:Show()
		lib:SetButtonToPosition(button, button.db[name] and button.db[name].minimapPos or button.dataObject.minimapPos or 225)
	end
end

function lib:IsRegistered(name)
	return (lib.objects[name] and true) or (lib.notCreated[name] and true) or false
end

function lib:Refresh(name, db)
	local button = lib.objects[name]
	if db then
		button.db = db
	end
	lib:SetButtonToPosition(button, button.db[name] and button.db[name].minimapPos or button.dataObject.minimapPos or 225)
	if not button.db[name] or not button.db[name].hide then
		button:Show()
	else
		button:Hide()
	end
end

function lib:SetButtonToPosition(button, position)
	local angle = math.rad(position or 0)
	local x, y = math.cos(angle), math.sin(angle)

	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = { "TOPLEFT", "TOPRIGHT", "BOTTOMRIGHT", "BOTTOMLEFT" }
	local quadrant = floor((angle + 0.785398163) / 1.570796327) % 4 + 1
	local minimapRadius = (Minimap:GetWidth() / 2) + 5
	if minimapShape == "ROUND" then
		x, y = x * minimapRadius, y * minimapRadius
	elseif minimapShape == "SQUARE" then
		local diagRadius = 103.13708498985
		x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
	elseif minimapShape == "CORNER-TOPLEFT" then
		if quadrant == 1 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "CORNER-TOPRIGHT" then
		if quadrant == 2 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "CORNER-BOTTOMRIGHT" then
		if quadrant == 3 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "CORNER-BOTTOMLEFT" then
		if quadrant == 4 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-TOPLEFT" then
		if quadrant == 1 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-TOPRIGHT" then
		if quadrant == 2 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-BOTTOMRIGHT" then
		if quadrant == 3 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	elseif minimapShape == "TRICORNER-BOTTOMLEFT" then
		if quadrant == 4 then
			x, y = 0, 0
		else
			local diagRadius = 103.13708498985
			x, y = max(-minimapRadius, min(x*diagRadius, minimapRadius)), max(-minimapRadius, min(y*diagRadius, minimapRadius))
		end
	end

	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function lib:GetMinimapButton(name)
	return lib.objects[name]
end

do
	local function OnTooltipShow(tooltip)
		if not tooltip or not tooltip.SetText then return end
		tooltip:SetText("LibDBIcon")
		tooltip:AddLine("Click to drag this button around the minimap.", 1, 1, 1)
	end
	lib.tooltip = lib.tooltip or CreateFrame("GameTooltip", "LibDBIconTooltip", UIParent, "GameTooltipTemplate")
	lib.tooltip.OnTooltipShow = OnTooltipShow
end

function lib:SetButtonRadius(name, radius)
	if not lib.objects[name] then return end
	-- This is not implemented yet
end

function lib:IsButtonCompartmentAvailable()
	return false
end

function lib:AddButtonToCompartment(name)
	-- This is not implemented yet
end

function lib:RemoveButtonFromCompartment(name)
	-- This is not implemented yet
end