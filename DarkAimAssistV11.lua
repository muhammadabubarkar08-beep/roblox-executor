local HttpService = game:GetService("HttpService")

local url = "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/DarkAimAssistV11.lua"

local source = HttpService:GetAsync(url)
local hubModule = loadstring(source)

assert(hubModule, "Could not load Dark Aim Assist V11")

hubModule()
