local mainMod = "SUPER"     -- Sets "Windows" key as main modifier


hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("qs ipc call power-panel toggle"))
