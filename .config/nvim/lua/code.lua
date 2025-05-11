local success, val = pcall(function() return CODE_LOADED end)
if success and val then
  return
end

-- helpers {{{

--  }}}

-- plugins {{{

-- pre setup {{{

-- vim-slime {{{

vim.g.slime_paste_file = vim.fn.tempname()
vim.g.slime_dont_ask_default = true
vim.g.slime_bracketed_paste = true
vim.g.slime_no_mappings = true

vim.api.nvim_set_keymap("n", "gs:", ":<C-u>SlimeConfigAll<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "gss", "<Plug>SlimeLineSend", { noremap = true })
vim.api.nvim_set_keymap("n", "gs", "<Plug>SlimeMotionSend", { noremap = true })
vim.api.nvim_set_keymap("n", "gsi", "<Plug>SlimeParagraphSend", { noremap = true })
vim.api.nvim_set_keymap("x", "gsi", "<Plug>SlimeRegionSend", { noremap = true })
vim.api.nvim_set_keymap("n", "gs;", ":SlimeSend<CR>", { noremap = true })
vim.api.nvim_set_keymap("x", "gs;", ":SlimeSend<CR>", { noremap = true })

vim.api.nvim_create_user_command(
  "SlimeConfigAll",
  function(opts)
    vim.cmd.SlimeConfig()
    vim.g.slime_default_config = vim.b.slime_config
  end,
  { nargs=0 }
)

local function slime_tmux_uniform_config()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    has, _ = pcall(
      vim.api.nvim_buf_get_var,
      bufnr,
      "slime_config"
    )
    if has then
      vim.api.nvim_buf_set_var(
        bufnr,
        "slime_config",
        vim.g.slime_default_config
      )
    end
  end
end

function slime_setup_tmux()
  vim.api.nvim_create_user_command(
    "SlimeTmuxPane",
    function(opts)
      vim.g.slime_default_config =
      {
        socket_name = vim.g.slime_default_config.socket_name,
        target_pane = opts.fargs[1]
      }
      slime_tmux_uniform_config()
    end,
    { nargs=1 }
  )
  vim.api.nvim_create_user_command(
    "SlimeTmuxSocket",
    function(opts)
      vim.g.slime_default_config =
      {
        socket_name = opts.fargs[1],
        target_pane = vim.g.slime_default_config.target_pane,
      }
      slime_tmux_uniform_config()
    end,
    { nargs=1 }
  )

  vim.g.slime_target = 'tmux'
  vim.g.slime_default_config = {
    socket_name = vim.fn.get(vim.fn.split(vim.env.TMUX, ","), 0),
    target_pane = "{top-right}"
  }
end

function slime_setup_nvim()
  vim.g.slime_target = 'neovim'
  vim.g.slime_suggest_default = false
  vim.g.slime_menu_config = false
  vim.g.slime_input_pid = false

  -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/targets/neovim.md
  vim.g.slime_get_jobid = function()
    -- iterate over all buffers to find the first terminal with a valid job
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_get_option_value(
        "buftype", { buf = bufnr }
      ) == "terminal" then
        local chan = vim.api.nvim_get_option_value(
          "channel", { buf = bufnr }
        )
        if chan and chan > 0 then return chan end
      end
    end
    return nil
  end

  pcall(vim.api.nvim_del_user_command, "SlimeTmuxPane")
  pcall(vim.api.nvim_del_user_command, "SlimeTmuxSocket")
end

-- There may be repl running in tmux that
-- should be reused so this is global even with
-- gui running
if vim.env.TMUX then
  slime_setup_tmux()
else
  slime_setup_nvim()
end

--  }}}

--  }}}

pckr.add(
  { -- {{{
    "jpalardy/vim-slime",

    {
      "norcalli/nvim-colorizer.lua",--  {{{
      config = function()
        local color_css_conf = {
          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css = true,
          -- Enable all CSS *functions*: rgb_fn, hsl_fn
          css_fn = true,
        }
        local color_vim_conf = { names = true }

        require("colorizer").setup(--  {{{
            {
              "*",
              html = color_css_conf,
              css = color_css_conf,
              js = color_css_conf,
              ts = color_css_conf,
              vim = color_vim_conf,
              lua = color_vim_conf,
          }, {
            -- #RGB hex codes
            RGB = true,
            -- #RRGGBB hex codes
            RRGGBB = true,
            -- "Name" codes like Blue
            names = false,
            -- #RRGGBBAA hex codes
            RRGGBBAA = true,
            -- CSS rgb() and rgba() functions
            rgb_fn = true,
            -- CSS hsl() and hsla() functions
            hsl_fn = true,
            -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
            css = false,
            -- Enable all CSS *functions*: rgb_fn, hsl_fn
            css_fn = false,
            -- Set the display mode.
            -- Available modes: foreground, background
            mode = "background",
          }
        )--  }}}
      end,
    }, --  }}}

    {
      "neovim/nvim-lspconfig",--  {{{
      config = function()
        -- TODO
      end
    } --  }}}

    -- TODO C rainbow ?
  }
) -- }}}

-- post setup {{{

-- treesitter {{{

tsinstall = require('nvim-treesitter.install')

do
  -- This is because FileType is not triggered on first file
  -- somehow
  lazy_load_after_startup(function()
    vim.cmd.filetype("detect")
  end)
end

local function lazy_ts_ensure_installed(name, filetypes)
  if filetypes == nil then
    filetypes = name
  end
  lazy_load_on_filetypes(filetypes, function()
    -- TODO B failing silently
    vim.cmd.TSUpdate(name)
  end)
end

for key, name in pairs({
  [{"sh", "bash", "zsh"}] = "bash",
  "python",
  "powershell",
  "go",
  "rust",
  "cpp",
  "c",
  "html",
  "css",
  "java",
  "elixir",
  "julia",
  "ocaml",
  "haskell",
  "typst",
  "latex",
}) do
  local filetypes = nil
  if type(key) == "string" or type(key) == "table" then
    filetypes = key
  end
  lazy_ts_ensure_installed(name, filetypes)
end

--  }}}

-- TODO lsp

-- TODO formatters

--  }}}

--  }}}

if vim.fn.has("win32") == 1 then -- {{{

  tsinstall.compilers = { "zig", "cl", "cc", "gcc", "clang" }

  -- }}}
else -- {{{

end -- }}}

CODE_LOADED = true
