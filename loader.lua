local F, Q = pcall(game.GetService, game, "HttpService")
if F and Q then
    local function F(F)
        for Q = #F, 1, -1 do
            if F:sub(Q, Q) == "/" then
                return F:sub(Q + 1)
            end
        end
        return F
    end
    local function Y(Y)
        local E = F(Y)
        local n = "http://127.0.0.1:6463/rpc?v=1"
        local j = {["Content-Type"] = "application/json", Origin = "https://discord.com"}
        local s = {cmd = "INVITE_BROWSER", args = {code = E}, nonce = Q:GenerateGUID(false)}
        local q = syn and syn.request or http_request or request or http and http.request
        if q then
            pcall(function()
                q({Url = n, Method = "POST", Headers = j, Body = Q:JSONEncode(s)})
            end)
        end
    end
    Y("https://discord.com/invite/CaUVkK2YuV")
end

-- Directly load the script without key validation
local E = (loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua")))()
E.script_id = "ed58a7c08024fcb2909098cc898418c1"
E.load_script()
print("Script loaded successfully.")
