return {
   "nvim-telescope/telescope.nvim",
   version = "*",
   dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
   },
   opts = function()
      local actions = require("telescope.actions")

      return {
         defaults = {

            layout_config = {
               vertical = {
                  width = 0.9,
                  height = 0.9,
                  preview_height = 0.5,
                  mirror = true,
               },
            },
            mappings = {
               i = {
                  ["<esc>"] = false,
               },
               n = {
                  ["<esc>"] = false,
                  ["q"] = actions.close,
               },
            },
         },
      }
   end,

   config = function(_, opts)
      require("telescope").setup(opts)

      vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })

      vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "TelescopePromptTitle", { link = "Title" })

      vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { link = "Title" })

      vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { link = "NormalFloat" })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { link = "Title" })

      vim.api.nvim_set_hl(0, "TelescopeSelection", { link = "Visual" })
      vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { link = "Special" })
   end,
}
