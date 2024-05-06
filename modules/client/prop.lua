local createdProps = {}



---@param playerPed number
---@param serverId number
---@return number object
local function createRadioProp(playerPed, serverId)
    lib.requestModel(`prop_cs_hand_radio`)

    local coords = GetEntityCoords(playerPed)
    local object = CreateObject(`prop_cs_hand_radio`, coords.x, coords.y, coords.z, false, false, false)

    AttachEntityToEntity(object, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
    SetModelAsNoLongerNeeded(`prop_cs_hand_radio`)

    createdProps[serverId] = object

    return object
end

---@param serverId number
local function removeRadioProp(serverId)
    local object = createdProps[serverId]

    if object then
        if DoesEntityExist(object) then
            DeleteObject(object)
        end

        createdProps[serverId] = nil
    end
end



---@param bagName string
---@return number? playerPed
---@return number? serverId
local function getPedFromStateBagName(bagName)
    local playerId = GetPlayerFromStateBagName(bagName)
    if not playerId then return end

    if playerId == cache.playerId then
        return cache.ped, cache.serverId
    end

    local playerPed = lib.waitFor(function()
        local ped = GetPlayerPed(playerId)
        if ped > 0 then return ped end
    end, ("player '%s' did not exist in time"):format(playerId), 10000)

    Wait(0)

    return playerPed, GetPlayerServerId(playerId)
end



---@param bagName string
---@param value boolean
---@param replicated boolean
AddStateBagChangeHandler('ac:hasRadioProp', '', function(bagName, _, value, _, replicated)
    if replicated then return end

    local playerPed, serverId = getPedFromStateBagName(bagName)
    if not playerPed or not serverId then return end

    if value then
        createRadioProp(playerPed, serverId)
    else
        removeRadioProp(serverId)
    end
end)

---@param serverId number
RegisterNetEvent('onPlayerDropped', function(serverId)
    removeRadioProp(serverId)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        for _, object in pairs(createdProps) do
            if DoesEntityExist(object) then
                DeleteObject(object)
            end
        end
    end
end)
