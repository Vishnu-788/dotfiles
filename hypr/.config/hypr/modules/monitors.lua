------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.25",
})


-- Without this there are grains on screen for certain applications like FDM, Genshin, etc.
hl.config({
   xwayland = {
      force_zero_scaling = true
   }
})


