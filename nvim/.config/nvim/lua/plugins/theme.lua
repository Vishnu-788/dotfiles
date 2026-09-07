-- lua/plugins/rose-pine.lua
-- lua/plugins/rose-pine.lua
return {
   "rose-pine/neovim",
   name = "rose-pine",
   priority = 1000,   -- load before other plugins so colorscheme is available early
   opts = {
      variant = "auto", -- "main" | "moon" | "dawn"
      dark_variant = "main",
      styles = {
         transparency = true, -- <-- this is the key option
         italic = false
      },
   },
   config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
   end,
}
