local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local menu        = "qs ipc call app-launcher toggle"

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("qs ipc call power-panel toggle"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs ipc call wifi toggle"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(menu))

