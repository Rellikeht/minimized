-- helpers {{{

-- general {{{

local function calc_pumheight()
  local result = vim.opt.lines._value
  result = (result - result % 3) / 3
  return result
end

function UpdateTable(t1, t2)
  for k, v in pairs(t2) do
    table.insert(t1, k, v)
  end
end

vim.g.B = function(n)
  if n == nil then
    n = 1
  end
  local s = ""
  for _ = 1, n do
    s = s .. "../"
  end
  return s
end

--  }}}

-- commands {{{

vim.api.nvim_create_user_command(
  "Tabe", function(opts)
    local count = opts.count
    if count == 0 then count = -1 end
    vim.cmd(opts.count .. "tabnew")
    -- This full lua version is closest to working
    -- but negative indices are too much for it
    -- vim.cmd.tabnew({range={count}})
    vim.cmd.arglocal({ bang = true })
    vim.cmd.args({ args = opts.fargs, bang = true })
  end, { complete = "file", nargs = "*", count = 1 }
)

--  }}}

--  }}}

-- settings {{{

-- general options {{{

for _, option in pairs(
  {
    "ruler",
    "incsearch",
    "ignorecase",
    "smartcase",
    "showmatch",
    "hidden",
    "secure",
    "wrap", -- TODO ??
    "autoindent",
    "cindent",
    "wildmenu",
    "termguicolors",
    "ttimeout",
    "splitright",
    "splitbelow",
    "autochdir",
    "undofile",
  }
) do vim.opt[option] = true end

for _, option in pairs({
  "shelltemp",
  "timeout",
  "autoread",
  "swapfile",
  "hlsearch",
}) do
  vim.opt[option] = false
end

vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.tabstop = 4

vim.opt.shellxquote = ""
vim.opt.maxmempattern = 2000000
vim.opt.fileencoding = "utf8"
vim.opt.ttimeoutlen = 100
vim.opt.updatetime = 2000

vim.opt.conceallevel = 2
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = " {{{, }}}"
vim.opt.foldlevel = 0
vim.opt.showbreak = "\\> "
vim.opt.wrapmargin = 1

vim.opt.mouse = "a"
vim.opt.scrolloff = 5
vim.opt.splitkeep = "screen"
vim.opt.shortmess = "atsOF"

vim.opt.undolevels = 10000
vim.opt.history = 10000

vim.opt.formatoptions:remove({ "j", "t" })
vim.opt.formatoptions:append("croqlwn")

vim.opt.wildchar = string.byte("\t")
vim.opt.wildmode = "list:longest,full"
vim.opt.wildoptions = "fuzzy,tagfile,pum"
vim.opt.complete = "w,b,s,i,d,.,k"
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.completeopt:append("fuzzy")
end

vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.pumwidth = 20
vim.opt.pumheight = calc_pumheight()
vim.opt.cmdwinheight = 25

-- }}}

-- initialization {{{

vim.cmd.filetype("on")
vim.cmd.filetype("plugin", "on")
vim.cmd.filetype("indent", "on")
vim.cmd.syntax("on")
vim.g.loaded_matchit = 1

-- }}}

if vim.fn.has("win32") == 1 then -- {{{
  -- must have really
  vim.opt.shell = "powershell.exe"

  -- some nice options
  vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
  vim.opt.shellquote = ""
  vim.opt.shellpipe = "| Out-File -Encoding UTF8 %s"
  vim.opt.shellredir = "| Out-File -Encoding UTF8 %s"

  GIT_EXECUTABLE = "git.exe"

  -- }}}
else -- {{{
  GIT_EXECUTABLE = "git"
end  -- }}}

-- filetypes {{{

vim.g.markdown_minlines = 300

vim.api.nvim_create_autocmd(
  { "BufRead", "BufNewFile" },
  { pattern = "*.md", command = "set syntax=markdown" }
)

--  }}}

-- colors {{{

-- isn't available sometimes
local success = pcall(vim.cmd.colorscheme, "zaibatsu")
if not success then pcall(vim.cmd.colorscheme, "retrobox") end

-- vim.api.nvim_set_hl(0, "Todo", {fg="#ffcf2f", bg="#0e1224", bold=true})

-- simple yet effective
vim.api.nvim_set_hl(0, "NormalFloat", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { bold = true })

-- acceptable for now
vim.api.nvim_set_hl(0, "Pmenu", { link = "CursorColumn" })
vim.api.nvim_set_hl(0, "PmenuKind", { link = "SignColumn" })
vim.api.nvim_set_hl(0, "PmenuExtra", { link = "SignColumn" })

-- }}}

-- }}}

-- keybindings {{{

-- general {{{

-- search like a pro
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })

-- move lines in visual mode
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

-- just in case
vim.keymap.set("n", "<Space>", "<Nop>", {})
vim.keymap.set("n", ",", "<Nop>", { remap = true })
vim.keymap.set("n", ";", "<Nop>", { remap = true })

vim.g.mapleader = ","
vim.g.maplocalleader = "_"

-- Select whole buffer without plugins
vim.keymap.set("v", "aee", "gg0oG$", { noremap = true })
vim.keymap.set("v", "iee", "aee", { noremap = true })
vim.keymap.set(
  "n", "yaee ", "gg0vG$y`'", { noremap = true }
)

vim.keymap.set("n", "Q", "<Nop>", { remap = true })
vim.keymap.set("", "<C-h>", "<C-]>", { remap = true })
vim.keymap.set(
  "n", "<C-w><C-h>",
  ":<C-u>exe 'tab tag '.expand('<cword>')<CR>", {}
)
vim.keymap.set(
  "n", "<C-w>gf", ":<C-u>tabedit <cfile><CR>", {}
)
vim.keymap.set("s", "<BS>", "<BS>i", { noremap = true })

vim.keymap.set("n", "<Space>y", "\"+y", { noremap = true })
vim.keymap.set("n", "<Space>Y", "\"+Y", { noremap = true })
vim.keymap.set("n", "<Space>u", "\"+p", { noremap = true })
vim.keymap.set("n", "<Space>U", "\"+P", { noremap = true })

-- }}}

-- tabs {{{

vim.keymap.set("n", "<Tab>", "<Nop>", { noremap = true })
vim.keymap.set("n", "<C-j>", "<Tab>", { noremap = true })
vim.keymap.set(
  "n", "<Tab><Tab>", ":<C-u>tab<Space>", {}
)
vim.keymap.set(
  "n", "<Tab><S-Tab>", ":<C-u>-tab<Space>", {}
)
vim.keymap.set(
  "n", "<Tab>h", ":<C-u>tab help<Space>", {}
)
vim.keymap.set(
  "n", "<Tab>H", ":<C-u>-tab help<Space>", {}
)

-- }}}

-- settings {{{

for key, cmd in pairs(
  {
    h = ":<C-u>set hls!<CR>",
    w = ":<C-u>setlocal wrap!<CR>",
    W = ":<C-u>set wrap!<CR>",
  }
) do
  vim.keymap.set(
    "n", "<Space>q" .. key, cmd, {}
  )
end

--  }}}

-- info {{{

for key, cmd in pairs(
  {
    m = ":<C-u>marks<CR>",
    b = ":<C-u>ls<CR>",
  }
) do
  vim.keymap.set(
    "n", "<Space>i" .. key, cmd, {}
  )
end

--  }}}

-- }}}

-- common plugins {{{

-- pre setup {{{

-- sneak & quickscope
vim.g["sneak#prompt"] = " <sneak> "
vim.g["sneak#use_ic_scs"] = true
vim.g["sneak#label"] = true
vim.g["sneak#next"] = false

-- matchup
vim.g.matchup_matchparen_offscreen = { method = "popup" }
vim.g.matchup_surround_enabled = true
vim.g.matchup_delim_noskips = 0

--  }}}

-- pckr setup {{{

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system(
      {
        GIT_EXECUTABLE,
        "clone",
        "--filter=blob:none",
        "https://github.com/lewis6991/pckr.nvim",
        pckr_path,
      }
    )
  end
  vim.opt.rtp:prepend(pckr_path)
end
bootstrap_pckr()

PCKR = require("pckr")
PCKR_UTIL = require("pckr.util")
PCKR_CMD = require("pckr.loader.cmd")
PCKR_KEYS = require("pckr.loader.keys")

PCKR.setup(
  {
    pack_dir = PCKR_UTIL.join_paths(
      vim.fn.stdpath("data"), "site"
    ),
    -- Limit the number of simultaneous jobs. nil means no limit
    max_jobs = nil,
    autoremove = true,
    autoinstall = true,
    git = {
      cmd = "git",
      clone_timeout = 60,
      -- Lua format string used for "aaa/bbb" style plugins
      default_url_format = "https://github.com/%s",
    },
    log = { level = "warn" },
    lockfile = {
      path = PCKR_UTIL.join_paths(
        vim.fn.stdpath("config"), "pckr", "lockfile.lua"
      ),
    },
  }
)

--  }}}

local plugin_configs = { -- {{{
  "tpope/vim-tbone",
  "tpope/vim-abolish",
  "wellle/targets.vim",

  {
    "Rellikeht/arglist-plus", --  {{{
    config = function()
      vim.keymap.set("n", "<Space>n", "<Plug>ANext", {})
      vim.keymap.set("n", "<Space>p", "<Plug>APrev", {})
      vim.keymap.set("n", "<Space>ll", "<Plug>AAList", {})
      vim.keymap.set("n", "<Space>le", ":<C-u>AGo<Space>", {})
      vim.keymap.set("n", "<Space>lo", ":AEdit<Space>", {})
      vim.keymap.set("n", "<Space>la", ":AAdd<Space>", {})
      vim.keymap.set("n", "<Space>ld", ":<C-u>ADel<Space>", {})
      vim.keymap.set("n", "<Space>lc", "<Plug>AGtoL", {})
    end
  }, --  }}}

  {
    "justinmk/vim-sneak", --  {{{
    config = function()
      for key_in, key_out in pairs(
        {
          ["<C-n>"] = ";",
          ["<C-p>"] = ",",
          s = "s",
          S = "S",
          f = "f",
          F = "F",
          t = "t",
          T = "T",
        }
      ) do
        vim.keymap.set(
          "", key_in, "<Plug>Sneak_" .. key_out, { noremap = true }
        )
      end
    end
  }, --  }}}

  {
    "unblevable/quick-scope", --  {{{
    config = function()
      vim.g.qs_delay = 40
      vim.g.qs_hi_priority = 2
      vim.g.qs_second_highlight = true

      vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = "#c81f16" })
      vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = "#ff5642" })
    end
  }, --  }}}

  {
    "tpope/vim-surround", --  {{{
    config = function()
      vim.keymap.set("x", "<Space>a", "<Plug>VSurround", {})
      vim.keymap.set("x", "<Space>A", "<Plug>VgSurround", {})
    end
  }, --  }}}

  {
    "tpope/vim-repeat", --  {{{
    config = function()
      -- because RepeatDot sometimes fails
      vim.keymap.set("n", "<Space>.", ".", { noremap = true })
    end
  }, --  }}}
}    -- }}}

--  }}}

if vim.g.vscode then
  --  {{{

  VSCODE = require("vscode")
  vim.keymap.set("x", "gc", function()
    VSCODE.call("editor.action.commentLine")
    VSCODE.call("vscode-neovim.escape", { key = "v" })
  end)
  vim.keymap.set({ "n", "x" }, "+", function()
    VSCODE.call("workbench.action.editor.nextChange")
  end)
  vim.keymap.set({ "n", "x" }, "-", function()
    VSCODE.call("workbench.action.editor.previousChange")
  end)
  vim.keymap.set("n", "<Leader>gu", function()
    VSCODE.call("git.revertSelectedRanges")
  end)
  vim.keymap.set("n", "<Leader>gn", function()
    VSCODE.call("editor.action.dirtydiff.next")
  end)
  vim.keymap.set("n", "<Leader>gp", function()
    VSCODE.call("editor.action.dirtydiff.previous")
  end)

  vim.keymap.set("n", "<Leader>sf", function()
    VSCODE.call("workbench.action.quickOpen")
  end)
  vim.keymap.set("n", "<Leader>sc", function()
    VSCODE.call("workbench.action.showCommands")
  end)
  vim.keymap.set("n", "<Leader>ss", function()
    VSCODE.call("workbench.action.findInFiles")
  end)

  PCKR.add(plugin_configs)
  return
  -- }}}
end

UpdateTable(
  plugin_configs,
  { --  {{{
    "Rellikeht/lazy-utils",
    "andymass/vim-matchup",
    "ryvnf/readline.vim",

    {
      "tpope/vim-fugitive", --  {{{
      config = function()
        vim.keymap.set("n", "<Leader>G", ":<C-u>G<CR>", {})
        vim.keymap.set("n", "<Leader>g<Space>", ":<C-u>G<Space>", {})
      end
    }, --  }}}

    {
      "mbbill/undotree", --  {{{
      config = function()
      end
    }, --  }}}

    {
      "windwp/nvim-autopairs", -- {{{
      config = function()
        require("nvim-autopairs").setup(
          {
            disable_filetype = {
              "markdown",
              "text",
              "fzf",
              "fugitive",
            },
            disable_in_macro = true,
            disable_in_visualblock = false,
            disable_in_replace_mode = true,
          }
        )
      end,
    }, --  }}}

    {
      "nvim-treesitter/nvim-treesitter", --  {{{
      requires = { "Rellikeht/lazy-utils" },
      run = ":TSUpdate",
      config = function()
        require("nvim-treesitter.install").prefer_git = false
        require("lazy_utils").load_on_startup(
          function()
            require "nvim-treesitter.configs".setup(
              {
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = { enable = true },
                sync_install = false,
                auto_install = false,

                matchup = {
                  enable = true,
                  disable_virtual_text = true,
                  include_match_words = true,
                },
              }
            )
          end
        )
      end,
    }, --  }}}

    {
      "junegunn/fzf.vim", --  {{{
      requires = { "junegunn/fzf" },
      config = function()
        -- slighty longer than in original :D
        -- https://github.com/junegunn/fzf.vim/blob/master/README.md#status-line-of-terminal-buffer
        vim.api.nvim_create_autocmd(
          "FileType", {
            pattern = "fzf",
            callback = function()
              local previous = {
                laststatus = vim.opt.laststatus._value,
                showmode = vim.opt.showmode._value,
                ruler = vim.opt.ruler._value,
              }
              vim.opt.laststatus = 0
              vim.opt.showmode = false
              vim.opt.ruler = false
              vim.api.nvim_create_autocmd(
                "BufLeave", {
                  pattern = "<buffer>",
                  callback = function()
                    vim.opt.laststatus = previous.laststatus
                    vim.opt.showmode = previous.showmode
                    vim.opt.ruler = previous.ruler
                  end
                })
            end
          }
        )

        vim.g.fzf_layout = { down = "100%" }
        vim.g.fzf_vim = { preview_window = { "down,50%,border-none" } }
        vim.g.fzf_history_dir = vim.fn.stdpath("data") .. "/fzf-history"

        vim.g.fzf_colors = {
          fg = { "fg", "Normal" },
          bg = { "bg", "Normal" },
          hl = { "fg", "Comment" },
          ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
          ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
          ["hl+"] = { "fg", "Statement" },
          info = { "fg", "PreProc" },
          prompt = { "fg", "Conditional" },
          pointer = { "fg", "Exception" },
          marker = { "fg", "Keyword" },
          spinner = { "fg", "Label" },
          header = { "fg", "Comment" },
        }

        vim.g.fzf_action = {
          ["alt-t"] = function(lines)
            vim.cmd.Tabe()
            -- TODO incorporate arglist-plus
            vim.cmd.args(lines)
          end,
          ["alt-T"] = "Tabe",
          ["alt-v"] = "view",
        }

        -- because those are nice and this config should be as
        -- self contained as it is possible
        vim.env.FZF_DEFAULT_OPTS = [[
--border=none
--bind 'alt-k:preview-up,alt-j:preview-down'
--bind 'ctrl-k:kill-line,ctrl-j:ignore'
--bind 'ctrl-s:change-preview-window(hidden|)'
--bind 'alt-K:preview-half-page-up,alt-J:preview-half-page-down'
--bind 'alt-U:half-page-up,alt-D:half-page-down'
--bind 'ctrl-c:cancel,ctrl-g:clear-selection'
--bind 'alt-p:prev-history,alt-n:next-history'
--bind 'alt-P:prev-selected,alt-N:next-selected'
--bind 'ctrl-p:up,ctrl-n:down'
--bind 'ctrl-t:toggle'
]]

        -- TODO add commands
      end
    }, --  }}}

  }
) --  }}}

PCKR.add(plugin_configs)

-- other settings {{{

for _, option in pairs(
  {
    "number",
    "relativenumber",
    "cursorline",
    "expandtab",
    "smarttab",
  }
) do vim.opt[option] = true end

vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { remap = true })
vim.keymap.set("t", "<C-q><C-w>", "<C-w>", { noremap = true })
vim.keymap.set("t", "<C-q><C-q>", "<C-q>", { noremap = true })
vim.keymap.set(
  "t", "<C-q><C-n>", "<C-\\><C-n>", { noremap = true }
)
vim.keymap.set(
  "t", "<C-q><C-o>", "<C-\\><C-o>", { noremap = true }
)

-- TODO fix coloring of diffs
-- those below don't work
vim.cmd [[
hi DiffAdd
            \ ctermbg=DarkGreen guibg=#0d5826
            \ ctermfg=NONE guifg=NONE
hi DiffText
            \ ctermbg=Gray guibg=#566670
            \ ctermfg=NONE guifg=NONE
hi DiffChange
            \ ctermbg=DarkBlue guibg=#0f1a7f
            \ ctermfg=NONE guifg=NONE
hi DiffDelete
            \ ctermbg=DarkRed guibg=#800620
            \ ctermfg=NONE guifg=NONE

"hi DiffAdd ctermbg=DarkGreen guibg=#0d5826
"hi DiffText ctermbg=Gray guibg=#566670
"hi DiffChange ctermbg=DarkBlue guibg=#0f1a7f
"hi DiffDelete ctermbg=DarkRed guibg=#800620
]]

-- }}}

if vim.g.neovide then
  -- {{{

  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_cursor_hack = false
  vim.g.neovide_scale_factor = 0.95

  -- }}}
elseif vim.fn.has("gui_running") == 1 then
  -- {{{
  -- }}}
else
  -- {{{
end -- }}}

-- additional {{{

pcall(require, "local")

vim.api.nvim_create_user_command(
  "Code", function()
    require("code")
  end, { nargs = 0 }
)

--  }}}
