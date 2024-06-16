-- luacheck: push ignore
local v = vim
-- luacheck: pop

v.api.nvim_create_user_command("FormatDateTimeAndZoneInfo", function()
    v.cmd("%s/datetime\\.datetime/dt\\.datetime/g")
    v.cmd('%s/zoneinfo\\.ZoneInfo(key="UTC")/UTC/g')
end, {})

local function CreateInsertCodeUserCommand(name, imports, text)
    v.api.nvim_create_user_command(name, function()
        local current_line = v.fn.line(".")
        v.cmd("normal! gg")
        for _, import in ipairs(imports) do
            v.cmd("normal! O" .. import)
        end
        v.cmd("normal! " .. (current_line + #imports) .. "G")
        v.cmd("normal! O" .. text)
        v.cmd("normal! zz")
    end, {})
end

CreateInsertCodeUserCommand(
    "HypothesisSettingsFilterTooMuch",
    { "from hypothesis import HealthCheck, settings" },
    "@settings(suppress_health_check=[HealthCheck.filter_too_much])"
)
CreateInsertCodeUserCommand(
    "HypothesisSettingsMaxExamples",
    { "from hypothesis import settings" },
    "@settings(max_examples=1)"
)
CreateInsertCodeUserCommand("MarkOnly", { "from pytest import mark" }, "@mark.only")
CreateInsertCodeUserCommand(
    "MarkParametrize",
    { "from pytest import mark, param" },
    '@mark.parametrize("param1", [param()])'
)
CreateInsertCodeUserCommand("MarkSkip", { "from pytest import mark" }, "@mark.skip")
CreateInsertCodeUserCommand("MarkXFail", { "from pytest import mark" }, "@mark.xfail")
