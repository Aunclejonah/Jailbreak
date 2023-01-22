local Configuration = {
    scopeImage = "rbxassetid://12229810062",
    changeSensitivity = false
}

local player = game:GetService("Players").LocalPlayer

local gameFolder = game:GetService("ReplicatedStorage").Game
local itemSystem, itemCamera = require(gameFolder.ItemSystem.ItemSystem), require(gameFolder.ItemSystem.ItemCamera)
local vehicle = require(gameFolder.Vehicle)

local zoomData = getupvalue(require(player.PlayerScripts.PlayerModule.CameraModule.ZoomController).Update, 1)
local transparency = {}

local function Scope(oldFunction, item, begin)
    -- Toggle Transparency
    for _, descendant in next, item.Model:GetDescendants() do
        if descendant:IsA("BasePart") then
            if begin then
                transparency[descendant] = descendant.Transparency
            end

            descendant.Transparency = begin and 1 or transparency[descendant]
        end
    end

    local oldZoom = hookfunction(itemCamera.Zoom, function() end)

    local oldSetSensitivity
    oldSetSensitivity = hookfunction(itemCamera.setSensitivity, function(...)
        if Configuration.changeSensitivity then
            return oldSetSensitivity(...)
        end
    end)

    local oldSetCameraDistance = itemCamera.SetCameraDistance
    itemCamera.SetCameraDistance = function()
        if begin then
            zoomData.x = 0
            zoomData.goal = 0
        else
            zoomData.x = item._CameraDistance
            zoomData.goal = item._CameraDistance
            item._CameraDistance = nil
        end
    end

    oldFunction(item)

    local crosshair = player.PlayerGui:FindFirstChild("CrossHairGui")

    if crosshair then
        crosshair.Enabled = not crosshair.Enabled
    end

    itemCamera.Zoom = oldZoom
    itemCamera.setSensitivity = oldSetSensitivity
    itemCamera.SetCameraDistance = oldSetCameraDistance
end

local function ModifyItem(item)
    if not item.ScopeBegin then
        return
    end

    item.SpringBlur.Accelerate = function() end

    item.ScopeGui.Left.Visible = false
    item.ScopeGui.Right.Visible = false
    item.ScopeGui.Top.Visible = false
    item.ScopeGui.Bottom.Visible = false
    item.ScopeGui.ImageLabel.Image = Configuration.scopeImage

    local oldScopeBegin, oldScopeEnd = item.ScopeBegin, item.ScopeEnd

    item.ScopeBegin = function(item)
        Scope(oldScopeBegin, item, true)
    end

    item.ScopeEnd = function(item)
        Scope(oldScopeEnd, item, false)
    end
end

local oldGetLocalVehiclePacket = vehicle.GetLocalVehiclePacket
vehicle.GetLocalVehiclePacket = function(...)
    local callerFunction = debug.info(2, "n")
    
    if callerFunction = "ScopeBegin" or callerFunction == "handleEquipped" then
        return
    end
    
    return oldGetLocalVehiclePacket(...)
end

itemSystem.OnLocalItemEquipped:Connect(ModifyItem)

local localEquipped = itemSystem.GetLocalEquipped()

if localEquipped then
    ModifyItem(localEquipped)
end
