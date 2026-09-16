local mainMod = "SUPER" -- Sets "Windows" key as main modifier

function formatIPC(module)
   return string.format("qs ipc call %s toggle", module)
end

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(formatIPC("power-panel")))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(formatIPC("wifi")))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(formatIPC("app-launcher")))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(formatIPC("screenshot")))
