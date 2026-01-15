-- helpers {{{

-- general {{{

H = {
  table_join = function(t1, t2)
    if t1 == nil or t2 == nil then return end
    for k, v in pairs(t2) do
      if type(k) == "number" and t1[k] ~= nil then
        table.insert(t1, v)
      else
        t1[k] = v
      end
    end
  end,

  lazy_ensure_ts_installed = function(name, filetypes)
    if filetypes == nil then filetypes = name end
    LAZY_UTILS.load_on_filetypes(
      filetypes, function()
        -- TODO make this fail silently when network not available
        vim.cmd("silent! TSUpdate " .. name)
      end
    )
  end,

  calc_pumheight = function()
    local result = vim.opt.lines._value
    result = (result - result % 3) / 3
    return result
  end,

  qlcmd = function(cmd, count)
    local prefix = "c"
    if vim.g.qfloc == 1 then
      prefix = "l"
    end
    return function(...)
      local ccount = count
      if type(count) == "string" and #count > 0 then
        ccount = vim.v[count]
      end
      vim.cmd({
        cmd = prefix .. cmd,
        count = ccount,
        args = { ... },
      })
    end
  end,

  wrap_qfloc = function(func, args, fill_first)
    return function(...)
      local func_args = {}
      H.table_join(func_args, { loclist = vim.g.qfloc == 1 })
      H.table_join(func_args, args)
      if ... == nil and not fill_first then
        func(func_args)
      else
        func(..., func_args)
      end
    end
  end,

  -- https://stackoverflow.com/a/2982789
  -- translated into lua
  longest_line_length = function()
    return vim.fn.max(
      vim.fn.map(
        vim.fn.range(1, vim.fn.line('$')),
        function(_, line) return vim.fn.virtcol({ line, "$" }) - 1 end
      )
    )
  end,
}

HOOKS = {}

--  }}}

--  }}}

-- settings {{{

-- general options {{{

for _, option in pairs({
  "number",
  "relativenumber",
  "ruler",         -- show line and column in bottom
  "incsearch",     -- <3
  "ignorecase",    -- for smartcase to work
  "smartcase",     -- <3
  "showmatch",     -- show matching brackets when inserting
  "hidden",        -- allow leaving buffers unwritten when jumping
  "secure",        -- just in case something is wrong with modelines
  "autoindent",    -- auto indent after <CR> in insert mode
  "wildmenu",      -- TODO document
  "termguicolors", -- 24 bit colors are nice (if they are available)
  "undofile",      -- undo history persistent throughout editor on and off
  "splitright",
  "splitbelow",
  "wrap",
}) do
  vim.opt[option] = true
end

for _, option in pairs({
  "shelltemp", -- TODO document
  "timeout",   -- wait for next key in combination until it is pressed
  "autoread",  --  disable automatic read file when changed from outside
  "swapfile",  --
  "hlsearch",  -- let t be set
}) do
  vim.opt[option] = false
end

vim.opt.scrolloff = 5                        -- lines from edge when scrolling
vim.opt.splitkeep = "screen"                 -- TODO document
vim.opt.shortmess = "atsOF"                  -- less annoying messages
vim.opt.mouse = "a"                          -- enable full mouse experience
vim.opt.formatoptions:remove({ "j", "t" })   -- TODO document
vim.opt.formatoptions:append("croqlwn")      -- TODO document

vim.opt.wildchar = string.byte("\t")         -- TODO document
vim.opt.wildmode = "list:longest,full"       -- TODO document
vim.opt.wildoptions = "fuzzy,tagfile"        -- ??
vim.opt.omnifunc = "syntaxcomplete#Complete" -- default vim function for <C-x>o
vim.opt.complete = "w,b,s,i,d,.,k"           -- TODO document
vim.opt.switchbuf:append(                    -- TODO document
  { "usetab", "useopen" }
)

-- best completion settings out there
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.completeopt:append("fuzzy")
end

vim.opt.redrawtime = 5000 -- wait longer for drawging (helpful in bigger files)
vim.opt.pumwidth = 50     -- to see anything in completion window
vim.opt.pumheight = H.calc_pumheight()
vim.opt.cmdwinheight = 25 -- more commands in command line window
vim.opt.cedit = "<C-j>"   -- key to open command-line window in command mode

--  }}}

-- initialization {{{

vim.g.loaded_matchit = 1
vim.g.ql_height = 12

--  }}}

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

  --  }}}
else -- {{{
  GIT_EXECUTABLE = "git"
end  --  }}}

-- colors {{{

-- TODO good looking in cterm
-- isn't available sometimes
local success = pcall(vim.cmd.colorscheme, "zaibatsu")
if not success then pcall(vim.cmd.colorscheme, "retrobox") end

-- simple yet effective
vim.api.nvim_set_hl(0, "NormalFloat", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "MatchParen", { bold = true })

-- acceptable for now
vim.api.nvim_set_hl(0, "Pmenu", { link = "CursorColumn" })
vim.api.nvim_set_hl(0, "PmenuKind", { link = "SignColumn" })
vim.api.nvim_set_hl(0, "PmenuExtra", { link = "SignColumn" })

--  }}}

--  }}}

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
-- TODO change to operator
vim.keymap.set(
  "n", "yaee ", "gg0vG$y`'", { noremap = true }
)

vim.keymap.set("n", "Q", "<Nop>", { remap = true })
vim.keymap.set("", "<C-h>", "<C-]>", { remap = true })
vim.keymap.set("s", "<BS>", "<BS>i", { noremap = true })

vim.keymap.set("n", "<Space>y", "\"+y", { noremap = true })
vim.keymap.set("n", "<Space>Y", "\"+Y", { noremap = true })
vim.keymap.set("n", "<Space>u", "\"+p", { noremap = true })
vim.keymap.set("n", "<Space>U", "\"+P", { noremap = true })

--  }}}

-- settings {{{

for key, cmd in pairs({
  h = ":<C-u>set hls!<CR>",
  c = ":<C-u>set ignorecase!<CR>",
}) do
  vim.keymap.set(
    "n", "<Space>q" .. key, cmd, {}
  )
end

--  }}}

--  }}}

-- common plugins {{{

-- pckr setup {{{

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system({
      GIT_EXECUTABLE,
      "clone",
      "--filter=blob:none",
      "-b", -- because main can be broken
      "v1.1.2",
      "https://github.com/lewis6991/pckr.nvim",
      pckr_path,
    })
  end
  vim.opt.rtp:prepend(pckr_path)
end
bootstrap_pckr()

PCKR = require("pckr")
PCKR_UTIL = require("pckr.util")
PCKR_CMD = require("pckr.loader.cmd")
PCKR_KEYS = require("pckr.loader.keys")

PCKR.setup({
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
  "tpope/vim-eunuch",
  "wellle/targets.vim",

  {
    "machakann/vim-sandwich", --  {{{
    config = function()
      vim.cmd.runtime("macros/sandwich/keymap/surround.vim")
      vim.keymap.set("x", "zs", "<Plug>(sandwich-add)")
      -- TODO how to replace
      -- vim.keymap.set("x", "zS", "<Plug>VgSurround")

      vim.keymap.set({ "x", "o" }, "is", "<Plug>(textobj-sandwich-query-i)")
      vim.keymap.set({ "x", "o" }, "as", "<Plug>(textobj-sandwich-query-a)")
      vim.keymap.set({ "x", "o" }, "iS", "<Plug>(textobj-sandwich-auto-i)")
      vim.keymap.set({ "x", "o" }, "aS", "<Plug>(textobj-sandwich-auto-a)")
    end
  }, --  }}}

  {
    "justinmk/vim-sneak",   --  {{{

    config_pre = function() --  {{{
      vim.g["sneak#prompt"] = " <sneak> "
      vim.g["sneak#use_ic_scs"] = 1
      vim.g["sneak#label"] = 1
      vim.g["sneak#s_next"] = 0
    end,                --  }}}

    config = function() --  {{{
      for key_in, key_out in pairs({
        ["<C-n>"] = ";",
        ["<C-p>"] = ",",
        ["<C-q>s"] = "s",
        ["<C-q>S"] = "S",
        f = "f",
        F = "F",
        t = "t",
        T = "T",
      }) do
        vim.keymap.set(
          "", key_in, "<Plug>Sneak_" .. key_out, { noremap = true }
        )
      end
      -- part of vscode-neovim command output window workaround
      vim.keymap.set("", "s", "<C-q>s", { remap = true })
      vim.keymap.set("", "S", "<C-q>S", { remap = true })
    end --  }}}
  },    --  }}}

  {
    "tpope/vim-repeat", --  {{{
    config = function()
      -- because RepeatDot sometimes fails
      vim.keymap.set("n", "<Space>.", ".", { noremap = true })
    end
  }, --  }}}
}    --  }}}

--  }}}

if vim.g.vscode then
  --  {{{

  VSCODE = require("vscode")
  -- TODO make 'autochdir' work with vscode

  -- action binds {{{

  function VSCodeMap(name)
    return function()
      VSCODE.call(name)
    end
  end

  vim.keymap.set({ "n", "x" }, "+", VSCodeMap("workbench.action.editor.nextChange"))
  vim.keymap.set({ "n", "x" }, "-", VSCodeMap("workbench.action.editor.previousChange"))

  for key, cmd in pairs({
    gu = "git.unstageChange",
    gn = "editor.action.dirtydiff.next",
    gp = "editor.action.dirtydiff.previous",

    sc = "workbench.action.showCommands",
    sf = "workbench.action.quickOpen",

    dn = "editor.action.marker.next",
    dp = "editor.action.marker.prev",
    Dn = "editor.action.marker.nextInFiles",
    Dp = "editor.action.marker.prevInFiles",

    dd = "editor.action.revealDefinition",
    dD = "editor.action.revealDeclaration",
    dlr = "editor.action.goToReferences",
    di = "editor.action.peekImplementation",

    dr = "editor.action.rename",
    da = "editor.action.quickFix",
    dh = "editor.action.showHover",
    de = "editor.action.showHover",
    df = "editor.action.formatDocument",
  }) do
    vim.keymap.set("n", "<Leader>" .. key, VSCodeMap(cmd))
  end

  for key, cmd in pairs({
    -- vscode needs it like that
    gs = "git.stageSelectedRanges",
    gr = "git.revertSelectedRanges",
    ss = "workbench.action.findInFiles",
  }) do
    vim.keymap.set({ "n", "x" }, "<Leader>" .. key, VSCodeMap(cmd))
  end

  vim.keymap.set("x", "gc", function()
    VSCODE.call("editor.action.commentLine")
    VSCODE.call("vscode-neovim.escape", { key = "v" })
  end)

  for key, cmd in pairs({
    -- this is broken
    gu = "git.unstageSelectedRanges",
    df = "editor.action.formatSelection",
  }) do
    vim.keymap.set("x", "<Leader>" .. key, VSCodeMap(cmd))
  end

  --  }}}

  -- vertical scrolling {{{

  -- TODO move cursor (probably impossible)
  vim.keymap.set(
    { "n", "x" }, "zh", function()
      local amount = math.min(vim.v.count1, H.longest_line_length())
      for _ = 1, amount do
        VSCODE.call("scrollLeft")
      end
    end
  )
  vim.keymap.set(
    { "n", "x" }, "zl", function()
      local amount = math.min(vim.v.count1, H.longest_line_length())
      for _ = 1, amount do
        VSCODE.call("scrollRight")
      end
    end
  )

  vim.keymap.set(
    { "n", "x" }, "zH", function()
      for _ = 1, math.floor(vim.fn.winwidth(0) / 2) do
        VSCODE.call("scrollLeft")
      end
    end
  )
  vim.keymap.set(
    { "n", "x" }, "zL", function()
      for _ = 1, math.floor(vim.fn.winwidth(0) / 2) do
        VSCODE.call("scrollRight")
      end
    end
  )

  --  }}}

  -- fixing vscode-neovim binds {{{

  -- some original bindings get overwritten by vscode extension and
  -- they are too good to just let go
  pcall(vim.keymap.del, "n", "==")
  pcall(vim.keymap.del, { "n", "x" }, "=")
  pcall(vim.keymap.del, "n", "gqq")
  pcall(vim.keymap.del, { "n", "x" }, "gq")

  -- vim sneak
  -- because vscode-neovim plugin opens cmd output window for s and S
  -- sneak commands
  vim.keymap.set("", "s",
    function()
      local cmdheight = vim.o.cmdheight
      vim.o.cmdheight = 3
      vim.cmd.execute("\"normal \\<C-q>s\"")
      vim.o.cmdheight = cmdheight
    end,
    { noremap = true }
  )
  vim.keymap.set("", "S",
    function()
      local cmdheight = vim.o.cmdheight
      vim.o.cmdheight = 3
      vim.cmd.execute("\"normal \\<C-q>s\"")
      vim.o.cmdheight = cmdheight
    end,
    { noremap = true }
  )

  --  }}}

  -- settings and backup bindings {{{

  vim.opt.redrawtime = 0
  vim.opt.scrolloff = 6

  -- settings
  for key, cmd in pairs({
    -- TODO make this more like nvim counterparts
    w = VSCodeMap("editor.action.toggleWordWrap"),
    W = VSCodeMap("editor.action.toggleWordWrap"),
    -- loosely similar to nvim counterpart
    s = VSCodeMap("workbench.action.toggleStatusbarVisibility"),
  }) do
    vim.keymap.set("n", "<Space>q" .. key, cmd, { noremap = true })
  end

  for name, value in pairs({
    -- those can't be done using (neo)vim config
    ["editor.lineNumbers"] = "relative",
    -- sad that the only possible indicator is indent
    ["editor.wrappingIndent"] = "indent",

    ["editor.inlayHints.enabled"] = "offUntilPressed",
    ["window.customMenuBarAltFocus"] = false,
    ["diffEditor.maxFileSize"] = 0,
    ["workbench.editor.scrollToSwitchTabs"] = true,
  }) do
    VSCODE.update_config(name, value, "global")
  end

  --  }}}

  -- other stuff {{{

  -- for testing and quick additions
  -- no idea how good it really will be
  vim.api.nvim_create_user_command(
    "ReloadNvimConfig", function()
      vim.cmd({
        cmd = "source",
        args = { vim.fn.stdpath("config") .. "/init.lua" },
        -- TODO silent
      })
    end, {}
  )

  H.table_join(
    plugin_configs,
    { "Rellikeht/vim-extras" }
  )
  PCKR.add(plugin_configs)

  --  }}}

  return
  --  }}}
end

H.table_join(
  plugin_configs,
  { --  {{{
    "ryvnf/readline.vim",
    "kmonad/kmonad-vim",
    "CervEdin/vim-minizinc",

    {
      "Rellikeht/vim-extras", --  {{{
      config = function()
        vim.keymap.set("n", "<Tab>o", ":+0TabOpen<Space>", {})
        EXTRAS = require("extras")
      end
    }, --  }}}

    {
      "Rellikeht/lazy-utils", --  {{{
      config = function()
        LAZY_UTILS = require("lazy_utils")
        if HOOKS.lazy_utils ~= nil then
          HOOKS.lazy_utils()
          HOOKS.lazy_utils = nil
        end
      end
    }, --  }}}

    {
      "Rellikeht/arglist-plus", --  {{{
      config = function()
        vim.keymap.set("n", "<Space>n", "<Plug>ANext", {})
        vim.keymap.set("n", "<Space>p", "<Plug>APrev", {})
        vim.keymap.set("n", "<Space>o", ":AEdit<Space>", {})
        vim.keymap.set("n", "<Space>O", ":AEditBuf<Space>", {})
        vim.keymap.set("n", "<Space>e", ":<C-u>AGo<Space>", {})
        vim.keymap.set("n", "<Space>E", ":<C-u>AGo!<Space>", {})
        vim.keymap.set("n", "<Space>j", ":ASelect<CR>", {})
        vim.keymap.set("n", "<Space>J", ":ASelect!<CR>", {})
        vim.keymap.set("n", "<Space>ll", "<Plug>AList", {})
        vim.keymap.set("n", "<Space>lL", "<Plug>AVertList", {})
        vim.keymap.set("n", "<Space>la", ":AAdd<Space>", {})
        vim.keymap.set("n", "<Space>la", ":AAddBuf<Space>", {})
        vim.keymap.set("n", "<Space>lr", ":AReplace<Space>", {})
        vim.keymap.set("n", "<Space>lR", ":AReplaceBuf<Space>", {})
        vim.keymap.set("n", "<Space>lm", ":AMoveCurN<CR>", {})
        vim.keymap.set("n", "<Space>lM", ":<C-u>AMoveCur<Space>", {})
        vim.keymap.set("n", "<Space>lc", "<Plug>AGlobToLoc", {})

        vim.keymap.set("n", "<Space>ld", ":<C-u>ADelN<CR>", {})
        vim.keymap.set("n", "<Space>lD", ":<C-u>ADel<CR>", {})
        vim.keymap.set("n", "<Space>lq", ":<C-u>ABufDelN<Space>", {})
        vim.keymap.set("n", "<Space>lQ", ":<C-u>ABufWipeN<Space>", {})

        vim.keymap.set("n", "<Space>lu", function()
          vim.cmd.AEdit(vim.fn.expand("<cfile>"))
        end, {})
        vim.keymap.set("n", "<Space>lU", function()
          vim.cmd.AAdd(vim.fn.expand("<cfile>"))
        end, {})

        vim.api.nvim_create_autocmd(
          "FileType", {
            pattern = "netrw",
            callback = function()
              vim.keymap.set("n", "<Space>lu", function()
                vim.cmd.AEdit(vim.g["extras#get_netrw_fp"]())
              end, { buffer = true, silent = true })
              vim.keymap.set("n", "<Space>lU", function()
                vim.cmd.AAdd(vim.g["extras#get_netrw_fp"]())
              end, { buffer = true, silent = true })
            end
          }
        )
      end
    }, --  }}}

    {
      "andymass/vim-matchup", --  {{{
      config_pre = function()
        -- this makes things little faster and isn't that useful
        vim.g.matchup_matchparen_enabled = false
        -- not really needed, but nice when matchparen gets enabled
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
        vim.g.matchup_surround_enabled = true
        vim.g.matchup_delim_noskips = false
        vim.g.matchup_delim_stopline = 100000
        vim.g.matchup_motion_cursor_end = true
      end,
    }, --  }}}

    {
      "tpope/vim-fugitive", --  {{{
      config = function()
        vim.keymap.set("n", "<Leader>G", ":<C-u>G<CR>", {})
        -- TODO is this enough
        -- (https://github.com/junegunn/gv.vim exists)
        vim.api.nvim_create_user_command(
          "GV",
          -- a dog (https://stackoverflow.com/a/35075021)
          -- "G log --all --decorate --oneline --graph",
          -- overengineered version
          function(opts)
            vim.cmd(
              "G log" ..
              " --all" ..
              " --decorate" ..
              " --graph" ..
              " --date='format:%F %T'" ..
              " --format='%h %cd%d %s (%an)'" ..
              (opts.bang and " %" or "")
            )
          end,
          { bang = true, nargs = "*" }
        )
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
        require("nvim-autopairs").setup({
          disable_filetype = {
            "markdown",
            "text",
            "fzf",
            "fugitive",
          },
          disable_in_macro = true,
          disable_in_visualblock = false,
          disable_in_replace_mode = true,
        })
      end,
    }, --  }}}

    {
      "nvim-treesitter/nvim-treesitter", --  {{{
      requires = {
        "Rellikeht/lazy-utils"           -- for helpers in config
      },
      run = ":TSUpdate",
      branch = "master",
      config = function()
        TREESITTER = require("nvim-treesitter")
        TREESITTER.prefer_git = false
        LAZY_UTILS.load_on_startup(
          function()
            TREESITTER.setup({
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
              indent = { enable = true },
              incremental_selection = { enable = true },
              sync_install = false,
              auto_install = false,

              matchup = {
                enable = true,
                disable_virtual_text = true,
                include_match_words = true,
              },
            })
          end
        )

        if HOOKS.nvim_treesitter ~= nil then
          HOOKS.nvim_treesitter()
          HOOKS.nvim_treesitter = nil
        end
      end,
    }, --  }}}

    {
      "junegunn/fzf.vim", --  {{{
      requires = {
        "junegunn/fzf",
        "Rellikeht/vim-extras",   -- for helpers in config
        "Rellikeht/arglist-plus", -- for helpers in config
      },
      config = function()
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
          ["alt-t"] = function(files)
            vim.cmd.TabOpen("+0")
            vim.fn["aplus#define"](EXTRAS.map(vim.fn.fnameescape, files))
            vim.fn["aplus#select"](0)
          end,
          ["alt-T"] = function(files)
            for _, file in pairs(EXTRAS.map(vim.fn.fnameescape, files)) do
              vim.cmd.tabedit(file)
            end
          end,
          ["alt-v"] = function(files)
            vim.cmd.view(EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-l"] = function(files)
            vim.fn["aplus#define"](EXTRAS.map(vim.fn.fnameescape, files))
            vim.fn["aplus#select"](0)
          end,
          ["alt-L"] = function(files)
            vim.fn["aplus#define"](EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-e"] = function(files)
            vim.fn["aplus#edit"]("$", 0, EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-E"] = function(files)
            vim.fn["aplus#edit"]("", 0, EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-a"] = function(files)
            vim.fn["aplus#add"]("$", EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-A"] = function(files)
            vim.fn["aplus#add"]("", EXTRAS.map(vim.fn.fnameescape, files))
          end,
          ["alt-b"] = function(files)
            vim.cmd.BAdd(EXTRAS.map(vim.fn.fnameescape, files))
          end,
        }

        -- TODO fzf preview position switch
        vim.keymap.set("n", "<Leader>sc", ":<C-u>Files<Space>")
        vim.keymap.set("n", "<Leader>sb", ":<C-u>Buffers<CR>")
        vim.keymap.set("n", "<Leader>sl", ":<C-u>BLines<CR>")
        vim.keymap.set("n", "<Leader>sL", ":<C-u>Lines<CR>")
        vim.keymap.set("n", "<Leader>s?", ":<C-u>HelpTags<CR>")

        -- TODO project roots

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
      end
    }, --  }}}

    {
      "Rellikeht/fzf-vim-additional", --  {{{
      requires = {
        "junegunn/fzf",
        "junegunn/fzf.vim"
      },
      config = function()
        vim.keymap.set("n", "<Leader>sg", ":<C-u>Dgrep<Space>")
        vim.keymap.set("n", "<Leader>sG", ":<C-u>Digrep<Space>")
        vim.keymap.set("n", "<Leader>sr", ":<C-u>Drg<Space>")
        vim.keymap.set("n", "<Leader>sR", ":<C-u>Dru<Space>")
        vim.keymap.set("n", "<Leader>sa", ":<C-u>Dag<Space>")
        vim.keymap.set("n", "<Leader>sA", ":<C-u>Dau<Space>")
      end
    } --  }}}

  }
) --  }}}

PCKR.add(plugin_configs)

-- other settings {{{

vim.cmd.filetype("plugin", "indent", "on")
vim.cmd.syntax("on")

vim.opt.autochdir = true

vim.opt.softtabstop = 4         -- amount of spaces when pressing tab
vim.opt.shiftwidth = 4          -- amount of spaces for other indentation
vim.opt.tabstop = 4             -- width of tab characters
vim.opt.textwidth = 72          -- TODO should this be set here

vim.opt.maxmempattern = 2000000 -- computers are fast enough for big patterns
vim.opt.fileencoding = "utf8"   -- why isn't this a default
vim.opt.updatetime = 2000       -- waiting for CursorHold and writing to swap
vim.opt.undolevels = 20000
vim.opt.history = 10000

vim.opt.conceallevel = 1         -- show concealled characters under cursor
vim.opt.foldmethod = "marker"    -- I don't like automatic folding
vim.opt.foldmarker = " {{{, }}}" -- just in case some formatter fucks up
vim.opt.foldlevel = 0
vim.opt.showbreak = "> "         -- wrap indicator
vim.opt.wrapmargin = 1           -- size of margin on the right

vim.opt.expandtab = true         -- use spaces instead of tabs
vim.opt.cursorline = true        -- highlight line where cursor is

-- TODO is this necessary
-- vim.opt.ttimeout = true
-- vim.opt.ttimeoutlen = 100

-- builtin terminal may be useful and <c-w> isn't necessary
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { remap = true })
vim.keymap.set("t", "<C-q><C-w>", "<C-w>", { noremap = true })
vim.keymap.set("t", "<C-q><C-q>", "<C-q>", { noremap = true })
vim.keymap.set(
  "t", "<C-q><C-n>", "<C-\\><C-n>", { noremap = true }
)
vim.keymap.set(
  "t", "<C-q><C-o>", "<C-\\><C-o>", { noremap = true }
)

-- fixing diffs colors
vim.cmd [[
hi Added
            \ ctermbg=DarkGreen guibg=#0d5826
            \ ctermfg=NONE guifg=NONE
hi Removed
            \ ctermbg=DarkRed guibg=#800620
            \ ctermfg=NONE guifg=NONE

" TODO fix coloring in diff split
" those don't work
"hi DiffText
"            \ ctermbg=Gray guibg=#566670
"            \ ctermfg=NONE guifg=NONE
hi Changed
            \ ctermbg=DarkBlue guibg=#0f1a7f
            \ ctermfg=NONE guifg=NONE
]]

-- sw=4 and sts=4 by default, why
vim.g.markdown_recommended_style = false
vim.g.markdown_minlines = 1000

--  }}}

-- keybindings {{{

-- tabs {{{

vim.keymap.set(
  "n", "<C-w><C-h>",
  ":<C-u>exe 'tab tag '.expand('<cword>')<CR>", {}
)

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

--  }}}

-- info {{{

for key, cmd in pairs({
  m = ":<C-u>marks<CR>",
  b = ":<C-u>ls<CR>",
}) do
  vim.keymap.set(
    "n", "<Space>i" .. key, cmd, {}
  )
end

--  }}}

-- other {{{

for key, cmd in pairs({
  w = ":<C-u>setlocal wrap!<CR>",
  W = ":<C-u>set wrap!<CR>",
  s = ":<C-u>SetOptionCount laststatus<CR>",
}) do
  vim.keymap.set("n", "<Space>q" .. key, cmd, { noremap = true })
end

vim.keymap.set("i", "<C-Space>",
  "(pumvisible()) ? '<C-n>' : (&omnifunc == '') ? '<C-n>' : '<C-x><C-o>'",
  { expr = true, noremap = true }
)

--  }}}

--  }}}

-- filetypes {{{

-- ugly but handy
vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = { --  {{{
      -- "python",
      "nix",
      "lua",
      "vim",
      "zig",
      "nim",
      "markdown",
      "ocaml",
      "elixir",
      "haskell",
      "kbd",
    }, --  }}}
    callback = function()
      vim.bo.softtabstop = 2
      vim.bo.shiftwidth = 2
    end
  }
)

--  }}}

-- quickfix {{{

vim.g.qfloc = 1

vim.keymap.set("n", ";t", function()
  vim.g.qfloc = (vim.g.qfloc + 1) % 2
  if vim.g.qfloc == 1 then
    vim.cmd.echo("\"Using location list (local)\"")
  else
    vim.cmd.echo("\"Using quickfix list (global)\"")
  end
end, { noremap = true })

for key, map in pairs({
  [";n"] = H.qlcmd("next", "count1"),
  [";p"] = H.qlcmd("previous", "count1"),
  [";0"] = H.qlcmd("first"),
  [";$"] = H.qlcmd("last"),
  [";h"] = H.qlcmd("history", "count1"),
  [";<"] = H.qlcmd("older", "count1"),
  [";>"] = H.qlcmd("newer", "count1"),
  [";w"] = function()
    local height = vim.v.count
    if height == 0 then height = vim.g.ql_height end
    H.qlcmd("open", height)()
  end,
}) do
  vim.keymap.set("n", key, map, { noremap = true, silent = true })
end

vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = "qf",
    callback = function()
      vim.keymap.set(
        { "n", "v" }, "q", ":q<CR>", { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", "<", H.qlcmd("older", "count1"), { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", ">", H.qlcmd("newer", "count1"), { noremap = true, buffer = true }
      )
      vim.keymap.set(
        "n", "J", "j<CR>", { noremap = true, buffer = true, silent = true }
      )
      vim.keymap.set(
        "n", "K", "k<CR>", { noremap = true, buffer = true, silent = true }
      )

      -- just a default <CR> with fold opening
      vim.keymap.set(
        "n", "<CR>", "<CR>zv", {
          noremap = true, buffer = true, silent = true,
        }
      )
      -- jump like <CR> but return cursor to qf/loc window
      vim.keymap.set(
        "n", "<C-h>", function()
          local qpos = vim.fn.getcurpos()
          vim.cmd.execute("\"normal \\<CR>\"")
          vim.cmd.execute("\"normal \\<C-w>w\"")
          vim.fn.setpos(".", qpos)
        end, {
          buffer = true, noremap = true,
        }
      )
      -- jump to element and close window
      vim.keymap.set(
        "n", "<BS>", function()
          vim.cmd.execute("\"normal \\<CR>\"")
          H.qlcmd("close")()
        end, {
          buffer = true, silent = true, noremap = true
        }
      )
    end
  }
)

--  }}}

if vim.g.neovide then
  -- {{{

  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_cursor_hack = false
  vim.g.neovide_scale_factor = 0.95

  vim.keymap.set("n", "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { noremap = true })
  vim.keymap.set("n", "<C-w>u", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { noremap = true })

  --  }}}
elseif vim.fn.has("gui_running") == 1 then
  -- {{{
  --  }}}
else
  -- {{{
end --  }}}

function CODE()
  if CODE_LOADED ~= nil then return end

  PCKR.add({ -- {{{

    {
      "jpalardy/vim-slime",   --  {{{

      config_pre = function() --  {{{
        vim.g.slime_paste_file = vim.fn.tempname()
        vim.g.slime_dont_ask_default = true
        vim.g.slime_bracketed_paste = true
        vim.g.slime_no_mappings = true
      end,                --  }}}

      config = function() --  {{{
        vim.keymap.set(
          "n", "gs:", ":<C-u>SlimeConfigAll<CR>", { noremap = true }
        )
        vim.keymap.set(
          "n", "gss", "<Plug>SlimeLineSend", { noremap = true }
        )
        vim.keymap.set(
          "n", "gs", "<Plug>SlimeMotionSend", { noremap = true }
        )
        vim.keymap.set(
          "n", "gsi", "<Plug>SlimeParagraphSend", { noremap = true }
        )
        vim.keymap.set(
          "x", "gsi", "<Plug>SlimeRegionSend", { noremap = true }
        )
        vim.keymap.set("n", "gs;", ":SlimeSend<CR>", { noremap = true })
        vim.keymap.set("x", "gs;", ":SlimeSend<CR>", { noremap = true })

        vim.api.nvim_create_user_command(
          "SlimeConfigAll", function(_)
            vim.cmd.SlimeConfig()
            vim.g.slime_default_config = vim.b.slime_config
          end, { nargs = 0 }
        )

        function Slime_setup_tmux()
          local function slime_tmux_uniform_config()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              local has, _ = pcall(
                vim.api.nvim_buf_get_var, bufnr, "slime_config"
              )
              if has then
                vim.api.nvim_buf_set_var(
                  bufnr, "slime_config", vim.g.slime_default_config
                )
              end
            end
          end

          vim.api.nvim_create_user_command(
            "SlimeTmuxPane", function(opts)
              vim.g.slime_default_config = {
                socket_name = vim.g.slime_default_config.socket_name,
                target_pane = opts.fargs[1],
              }
              slime_tmux_uniform_config()
            end, { nargs = 1 }
          )
          vim.api.nvim_create_user_command(
            "SlimeTmuxSocket", function(opts)
              vim.g.slime_default_config = {
                socket_name = opts.fargs[1],
                target_pane = vim.g.slime_default_config.target_pane,
              }
              slime_tmux_uniform_config()
            end, { nargs = 1 }
          )

          vim.g.slime_target = "tmux"
          vim.g.slime_default_config = {
            socket_name = vim.fn.get(vim.fn.split(vim.env.TMUX, ","), 0),
            target_pane = "{top-right}",
          }
        end

        function Slime_setup_nvim()
          vim.g.slime_target = "neovim"
          vim.g.slime_suggest_default = false
          vim.g.slime_menu_config = false
          vim.g.slime_input_pid = false

          -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/targets/neovim.md
          vim.g.slime_get_jobid = function()
            -- iterate over all buffers to find the first terminal with a valid job
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ==
                  "terminal" then
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
          Slime_setup_tmux()
        else
          Slime_setup_nvim()
        end
      end --  }}}
    },    --  }}}

    {
      "mhinz/vim-signify", --  {{{
      config = function()
        vim.cmd.SignifyToggle()
        vim.keymap.set(
          "n", "+", "<Plug>(signify-next-hunk)", { noremap = true }
        )
        vim.keymap.set(
          "n", "-", "<Plug>(signify-prev-hunk)", { noremap = true }
        )
        vim.keymap.set(
          "n", "<Leader>gs", vim.cmd.SignifyHunkDiff, {
            noremap = true,
            desc = "diff for hunk under cursor"
          })
        vim.keymap.set(
          "n", "<Leader>gu", vim.cmd.SignifyHunkUndo, {
            noremap = true,
            desc = "undo hunk under cursor"
          })

        vim.api.nvim_create_autocmd(
          "User", {
            pattern = "SignifyHunk",
            callback = function()
              local h = vim.fn["sy#util#get_hunk_stats"]()
              if vim.fn.empty(h) == 0 then
                print("[Hunk " .. h.current_hunk .. "/" .. h.total_hunks .. "]")
              end
            end
          }
        )
      end
    }, --  }}}

    {
      "norcalli/nvim-colorizer.lua", --  {{{
      config = function()
        local color_css_conf = {
          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css = true,
          -- Enable all CSS *functions*: rgb_fn, hsl_fn
          css_fn = true,
        }
        local color_vim_conf = { names = true }

        require("colorizer").setup({ --  {{{
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
        }) --  }}}
      end,
    },     --  }}}

    {
      "neovim/nvim-lspconfig",  --  {{{
      requires = {
        "Rellikeht/vim-extras", -- for helpers in config
      },
      config = function()
        if vim.fn.has("nvim-0.10") == 0 then return end
        if vim.fn.has("nvim-0.11") == 1 then -- {{{
          -- for backwards compatibility
          function NvimDiagPrev(config)
            return function()
              H.table_join(config, { count = -vim.v.count1, float = true })
              vim.diagnostic.jump(config)
            end
          end

          function NvimDiagNext(config)
            return function()
              H.table_join(config, { count = vim.v.count1, float = true })
              vim.diagnostic.jump(config)
            end
          end
        else
          function NvimDiagNext()
            ---@diagnostic disable-next-line: deprecated
            vim.diagnostic.goto_next()
          end

          function NvimDiagPrev()
            ---@diagnostic disable-next-line: deprecated
            vim.diagnostic.goto_prev()
          end
        end --  }}}

        local lspconfig = require("lspconfig")
        lspconfig.util.default_config = vim.tbl_extend(
          "force",
          lspconfig.util.default_config,
          { message_level = nil }
        )

        -- commands {{{

        vim.keymap
            .set("n", "<Leader>dqi", ":<C-u>LspInfo<CR>", {})
        vim.keymap.set(
          "n", "<Leader>dqr", ":<C-u>LspRestart<CR>", {}
        )
        vim.keymap.set(
          "n", "<Leader>de", vim.diagnostic.open_float,
          { desc = "show diagnostics under cursor" }
        )

        vim.keymap.set(
          "n", "<Leader>dp",
          NvimDiagPrev({
            severity = {
              vim.diagnostic.severity.ERROR,
              vim.diagnostic.severity.WARN
            }
          }), { desc = "[N] prev error or warning" }
        )
        vim.keymap.set(
          "n", "<Leader>dn",
          NvimDiagNext({
            severity = {
              vim.diagnostic.severity.ERROR,
              vim.diagnostic.severity.WARN,
            },
          }), { desc = "[N] next error or warning" }
        )

        vim.keymap.set(
          "n", "<Leader>dP", NvimDiagPrev(
            { severity = { vim.diagnostic.severity.ERROR } }
          ), { desc = "[N] prev error" }
        )
        vim.keymap.set(
          "n", "<Leader>dN", NvimDiagNext(
            { severity = { vim.diagnostic.severity.ERROR } }
          ), { desc = "[N] next error" }
        )

        vim.keymap.set(
          "n", "<Leader>dk",
          NvimDiagPrev({
            severity = {
              vim.diagnostic.severity.INFO,
              vim.diagnostic.severity.HINT,
            },
          }), { desc = "[N] prev hint/info" }
        )
        vim.keymap.set(
          "n", "<Leader>dj", NvimDiagNext({
            severity = {
              vim.diagnostic.severity.INFO,
              vim.diagnostic.severity.HINT,
            },
          }), { desc = "[N] next hint/info" }
        )

        vim.keymap.set(
          "n", "<Leader>dll", function(_)
            if vim.g.qfloc == 1 then
              vim.diagnostic.setloclist({ open = true })
            else
              vim.diagnostic.setqflist({ open = true })
            end
          end, {
            noremap = true,
            desc = "populate quickfix/loclist with diagnostics",
          }
        )

        --  }}}

        vim.api.nvim_create_autocmd( -- {{{
          "LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(args)
              -- helpers {{{

              local bufnr = args.buf
              local client = vim.lsp.get_client_by_id(
                args.data.client_id
              )

              --  }}}

              -- insert mode {{{

              if client and
                  client.server_capabilities.completionProvider then
                -- Enable completion triggered by <c-x><c-o>
                -- TODO this seems to disappear
                vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
              end
              if client and
                  client.server_capabilities.definitionProvider then
                vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
              end

              --  }}}

              -- navigation {{{

              vim.keymap.set(
                "n", "<Leader>dd", H.wrap_qfloc(vim.lsp.buf.definition),
                { desc = "go to definition", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dD", H.wrap_qfloc(vim.lsp.buf.declaration),
                { desc = "go to declaration", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>di", H.wrap_qfloc(vim.lsp.buf.implementation)
                , { desc = "go to implementation", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dt", H.wrap_qfloc(vim.lsp.buf.type_definition)
                ,
                { desc = "go to type definition", buffer = bufnr }
              )

              --  }}}

              -- info {{{

              vim.keymap.set(
                "n", "<Leader>ds", vim.lsp.buf.signature_help,
                { desc = "signature help", buffer = bufnr }
              )
              vim.keymap.set(
                "n", "<Leader>dh", vim.lsp.buf.hover, {
                  desc = "display hover information about the symbol under the cursor",
                  buffer = bufnr,
                }
              )
              -- TODO version only for current file (cfilter/lfilter is
              -- the only way)
              vim.keymap.set(
                "n", "<Leader>dlr",
                H.wrap_qfloc(
                  vim.lsp.buf.references,
                  { includeDeclaration = false },
                  true
                ), {
                  desc = "populate quickfix list with references",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>dls", H.wrap_qfloc(vim.lsp.buf.document_symbol), {
                  desc = "populate quickfix/loclist with symbols in current file",
                  buffer = bufnr,
                }
              )

              --  }}}

              -- actions {{{

              vim.keymap.set(
                "n", "<Leader>dr", vim.lsp.buf.rename, {
                  desc = "rename symbol under cursor",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                { "n", "x" }, "<Leader>df", function()
                  vim.lsp.buf.format({ async = false })
                  vim.cmd.norm("zv")
                end, {
                  desc = "format buffer using lsp",
                  buffer = bufnr,
                }
              )
              vim.keymap.set(
                "n", "<Leader>da", vim.lsp.buf.code_action,
                { desc = "execute code action", buffer = bufnr }
              )

              --  }}}

              LSP_CONFIG_CALLBACK(bufnr)
            end,
          }
        ) --  }}}
      end,
    },    --  }}}

    {
      "Rellikeht/nvim-lsp-config", --  {{{
      requires = {
        "neovim/nvim-lspconfig",
        "Rellikeht/lazy-utils",
        "mfussenegger/nvim-jdtls",
        "p00f/clangd_extensions.nvim",
      },
      config = function()
        LSP_CONFIG_CALLBACK = function(bufnr)
          local lsp_config = require("nvim_lsp_config")
          lsp_config.wrap_float()
          vim.keymap.set(
            "n", "<Leader>dH",
            function()
              lsp_config.buf_hover_preview({}, bufnr)
            end, {
              desc = "display information about the symbol under the cursor in preview window",
              buffer = bufnr,
            }
          )
          vim.keymap.set(
            "i", "<C-_>",
            function()
              lsp_config.insert_hover({
                relative = "cursor",
                anchor_bias = "above",
                focusable = false,
                zindex = 1000,
              }, bufnr)
            end,
            {
              desc = "display hover information about the symbol under the cursor",
              buffer = bufnr,
            }
          )
        end
      end,
    }, --  }}}

    {
      "HiPhish/info.vim", --  {{{
      config = function()
        vim.api.nvim_create_autocmd(
          "FileType", {
            pattern = "info",
            callback = function()
              vim.keymap.set("n", "<Leader>n", "<Plug>(InfoNext)", { noremap = true })
              vim.keymap.set("n", "<Leader>p", "<Plug>(InfoPrev)", { noremap = true })
              vim.keymap.set("n", "<Leader>u", "<Plug>(InfoPrev)", { noremap = true })
              vim.keymap.set("n", "<Leader>m", "<Plug>(InfoMenu)", { noremap = true })
              vim.keymap.set("n", "<Leader>o", "<Plug>(InfoGoto)", { noremap = true })
            end,
          }
        )
      end
    }, --  }}}

    -- TODO rainbow ?
    -- TODO formatters (neoformat)
    -- TODO snippets
  }
  )                                  --  }}}

  HOOKS.nvim_treesitter = function() -- treesitter {{{
    for key, name in pairs({
      ["*"] = "comment",
      [{ "sh", "bash", "zsh" }] = "bash",
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
    }
    ) do
      local filetypes = nil
      if type(key) == "string" or type(key) == "table" then
        filetypes = key
      end
      H.lazy_ensure_ts_installed(name, filetypes)
    end

    if vim.fn.has("win32") == 1 then -- {{{
      TREESITTER.compilers = { "zig", "cl", "cc", "gcc", "clang" }

      --  }}}
    else -- {{{
    end  --  }}}
  end

  if TREESITTER ~= nil then
    HOOKS.nvim_treesitter()
    HOOKS.nvim_treesitter = nil
  end

  --  }}}

  -- auto filetype detect {{{

  local function filetype_detect_callback(ev)
    if vim.b[ev.buf].filetype_detected or vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local omnifunc = vim.bo[ev.buf].omnifunc
    -- seems to work the same
    -- vim.cmd("silent! filetype detect")
    vim.cmd({
      cmd = "filetype",
      args = { "detect" },
      mods = { silent = true },
    })
    vim.b[ev.buf].filetype_detected = true
    -- custom and lsp omnifunc gets overwritten during filetype
    -- detection
    vim.bo[ev.buf].omnifunc = omnifunc
  end

  -- because code command may be run after opening some buffers and lsp
  -- or orther goodies won't be loaded automatically then
  vim.api.nvim_create_autocmd(
    "BufEnter", {
      callback = filetype_detect_callback
    }
  )
  filetype_detect_callback({ buf = vim.fn.bufnr() })

  --  }}}

  CODE_LOADED = true
end

-- additional {{{

pcall(require, "local")

-- Special Code command as part of config
vim.api.nvim_create_user_command("Code", CODE, { nargs = 0 })

vim.api.nvim_create_user_command(
  "RSource", function(opts)
    require(opts.fargs[1])
  end, { nargs = 1 }
)

--  }}}
