return {
   {
      "nvim-tree/nvim-web-devicons",
      config = function()
         require("nvim-web-devicons").setup({
            override = {
               zsh = {
                  icon = "",
                  color = "#428850",
                  cterm_color = "65",
                  name = "Zsh"
               }
            },
            color_icons = true,
            default = true,
         })
      end
   },
   {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
         "nvim-tree/nvim-web-devicons",
      },
      config = function()
         require("nvim-tree").setup({
            update_focused_file = {
               enable = true,
               update_root = true
            },

            filters = {
               dotfiles = false,
               git_ignored = false,
            },

            hijack_unnamed_buffer_when_opening = false,
            hijack_directories = {
               enable = false,
            },

            view = {
               width = 40,
               signcolumn = "yes",
            },
            renderer = {
               highlight_git = true,
               highlight_opened_files = "none",
               icons = {
                  modified_placement = "right_align",
                  diagnostics_placement = "right_align",
                  show = {
                     git = false,
                     diagnostics = true,
                     file = true,
                     folder = false,
                  },
                  glyphs = {
                     modified = "[+]"
                  },
               },
            },

            modified = { enable = true, show_on_dirs = false },
            diagnostics = {
               enable = true,
               show_on_dirs = true,
               severity = {
                  min = vim.diagnostic.severity.ERROR,
               },
               icons = {
                  hint = "[H]",
                  info = "[I]",
                  warning = "[!]",
                  error = "[E]",
               },
            },
         })
      end,
   },
}
