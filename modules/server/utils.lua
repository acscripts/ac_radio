---@param export string
---@return boolean
local function hasExport(export)
    local resource, exportName = string.strsplit('.', export)

    return pcall(function()
        return exports[resource][exportName]
    end)
end

return {
    hasExport = hasExport,
}
