-- =========================================================================
-- 🔐 QB-ANTIBACKDOOR
-- Server Security Monitor & Exploitation Prevention Framework
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- 🛡️ System Exclusions (Resources allowed to process system functions)
local TRUSTED_RESOURCES = {
    ["qb-core"] = true,
    ["monitor"] = true, -- txAdmin
    ["mapmanager"] = true,
    ["playernames"] = true,
    ["ox_inventory"] = true,
    ["antibackdoor"] = true,
    ["qb-antibackdoor"] = true
}

-- 📢 Centralized Alert Logger
local function LogSecurityBreach(resource, sourcePlayer, threatType, details)
    local playerName = "SERVER_INTERNAL"
    local license = "N/A"
    
    if sourcePlayer and sourcePlayer > 0 then
        playerName = GetPlayerName(sourcePlayer) or "Unknown"
        license = GetPlayerIdentifierByType(sourcePlayer, 'license') or "N/A"
    end

    print("^1==================================================================^7")
    print("^1[🔐 QB-ANTIBACKDOOR] THREAT BLOCKER ACTIONED!^7")
    print(string.format("^3[Type]^7 %s", threatType))
    print(string.format("^3[Origin Resource]^7 %s", resource or "Unknown"))
    print(string.format("^3[Executor]^7 %s (ID: %s)", playerName, tostring(sourcePlayer)))
    print(string.format("^3[License]^7 %s", license))
    print(string.format("^3[Payload/Details]^7 %s", details))
    print("^1==================================================================^7")

    if sourcePlayer and sourcePlayer > 0 then
        DropPlayer(sourcePlayer, "[🔐 QB-ANTIBACKDOOR]: Unauthorized Server Execution Blocked.")
    end
end

-- =========================================================================
-- 1. MONITORING DYNAMIC CODE EXECUTION (load / loadstring intercepts)
-- =========================================================================
local raw_load = load
local raw_loadstring = loadstring

_G.load = function(chunk, chunkname, mode, env)
    local callingResource = GetInvokingResource()
    
    if callingResource and not TRUSTED_RESOURCES[callingResource] then
        LogSecurityBreach(callingResource, source, "Dynamic Code Injection Attempt (load)", tostring(chunk):sub(1, 100))
        return function() end
    end
    return raw_load(chunk, chunkname, mode, env)
end

if raw_loadstring then
    _G.loadstring = function(str)
        local callingResource = GetInvokingResource()
        
        if callingResource and not TRUSTED_RESOURCES[callingResource] then
            LogSecurityBreach(callingResource, source, "Dynamic Code Injection Attempt (loadstring)", tostring(str):sub(1, 100))
            return function() end
        end
        return raw_loadstring(str)
    end
end

-- =========================================================================
-- 2. MONITORING SUSPICIOUS NETWORKING (PerformHttpRequest Abuse)
-- =========================================================================
local raw_PerformHttpRequest = PerformHttpRequest

_G.PerformHttpRequest = function(url, cb, method, data, headers)
    local callingResource = GetInvokingResource()
    
    if callingResource and not TRUSTED_RESOURCES[callingResource] then
        local lowerURL = url:lower()
        if lowerURL:find("pastebin") or lowerURL:find("githubusercontent") or lowerURL:find("api/webhooks") then
            LogSecurityBreach(callingResource, source, "Malicious External Content Fetch", url)
            if cb then cb(403, "Forbidden by QB-AntiBackdoor", {}) end
            return
        end
    end
    return raw_PerformHttpRequest(url, cb, method, data, headers)
end

-- =========================================================================
-- 3. DETECTING & BLOCKING UNSANITIZED/SUSPICIOUS CLIENT OVEREXTENSIONS
-- =========================================================================
local raw_TriggerClientEvent = TriggerClientEvent

_G.TriggerClientEvent = function(eventName, targetSrc, ...)
    local callingResource = GetInvokingResource()

    if targetSrc == -1 and callingResource and not TRUSTED_RESOURCES[callingResource] then
        local lowerEvent = eventName:lower()
        if lowerEvent:find("admin") or lowerEvent:find("exploit") or lowerEvent:find("execute") or lowerEvent:find("runstring") then
            LogSecurityBreach(callingResource, source, "Malicious Global Client Broadcast Blocked", eventName)
            return
        end
    end
    return raw_TriggerClientEvent(eventName, targetSrc, ...)
end


-- =========================================================================
-- 4. DELAYED STARTUP MESSAGE (Forces display after Nucleus Authentication)
-- =========================================================================
CreateThread(function()
    -- We wait until the server is fully initialized and open for connections
    while not GetResourceState("qb-core") == "started" do
        Wait(500)
    end
    
    -- An extra delay to guarantee citizen-server-impl finishes printing the Nucleus URL
    Wait(2500) 
    
    print("^2[🔐 QB-ANTIBACKDOOR] Runtime protection successfully armed and monitoring network threads.^7")
end)