local lush = require('lush')
local hsl = lush.hsl

-- Define color palette
local palette = {
  black  = hsl('#24292e'),
  white  = hsl('#ffffff'),
  gray   = { hsl('#fafbfc'), hsl('#f6f8fa'), hsl('#e1e4e8'), hsl('#d1d5da'), hsl('#959da5'), hsl('#6a737d'), hsl('#586069'), hsl('#444d56'), hsl('#2f363d'), hsl('#24292e') },
  blue   = { hsl('#f1f8ff'), hsl('#dbedff'), hsl('#c8e1ff'), hsl('#79b8ff'), hsl('#2188ff'), hsl('#0366d6'), hsl('#005cc5'), hsl('#044289'), hsl('#032f62'), hsl('#05264c') },
  green  = { hsl('#f0fff4'), hsl('#dcffe4'), hsl('#bef5cb'), hsl('#85e89d'), hsl('#34d058'), hsl('#28a745'), hsl('#22863a'), hsl('#176f2c'), hsl('#165c26'), hsl('#144620') },
  yellow = { hsl('#fffdef'), hsl('#fffbdd'), hsl('#fff5b1'), hsl('#ffea7f'), hsl('#ffdf5d'), hsl('#ffd33d'), hsl('#f9c513'), hsl('#dbab09'), hsl('#b08800'), hsl('#735c0f') },
  orange = { hsl('#fff8f2'), hsl('#ffebda'), hsl('#ffd1ac'), hsl('#ffab70'), hsl('#fb8532'), hsl('#f66a0a'), hsl('#e36209'), hsl('#d15704'), hsl('#c24e00'), hsl('#a04100') },
  red    = { hsl('#ffeef0'), hsl('#ffdce0'), hsl('#fdaeb7'), hsl('#f97583'), hsl('#ea4a5a'), hsl('#d73a49'), hsl('#cb2431'), hsl('#b31d28'), hsl('#9e1c23'), hsl('#86181d') },
  purple = { hsl('#f5f0ff'), hsl('#e6dcfd'), hsl('#d1bcf9'), hsl('#b392f0'), hsl('#8a63d2'), hsl('#6f42c1'), hsl('#5a32a3'), hsl('#4c2889'), hsl('#3a1d6e'), hsl('#29134e') },
  pink   = { hsl('#ffeef8'), hsl('#fedbf0'), hsl('#f9b3dd'), hsl('#f692ce'), hsl('#ec6cb9'), hsl('#ea4aaa'), hsl('#d03592'), hsl('#b93a86'), hsl('#99306f'), hsl('#6d224f') }
}

--- @diagnostic disable: undefined-global, unused-local
-- Create theme using lush
local theme = lush(function(injected_functions)
  local sym = injected_functions.sym

  return {
    Normal { fg = palette.gray[9], bg = palette.white },                       -- Normal text
    Variable { fg = palette.black },                                           -- Variables and identifiers
    Comment { fg = palette.gray[6] },                                          -- Comments
    Identifier { fg = palette.blue[7] },                                       -- Variables and identifiers
    Function { fg = palette.purple[6] },                                       -- Functions and methods
    Statement { fg = palette.red[6], },                                        -- Statements like `if`, `for`, etc.
    Keyword { fg = palette.red[6] },                                           -- Keywords like `return`, `function`
    Operator { fg = palette.red[6] },                                          -- Operators like `+`, `-`, `*`, etc.
    Constant { fg = palette.blue[7] },                                         -- Constants like numbers, booleans
    String { fg = palette.blue[9] },                                           -- Strings
    Type { fg = palette.red[6] },                                              -- Types and classes
    PreProc { fg = palette.red[6] },                                           -- Preprocessor commands
    Special { fg = palette.purple[6] },                                        -- Special symbols
    Visual { bg = palette.blue[1] },                                           -- Visual selection
    CursorLine { bg = palette.gray[2] },                                       -- Cursor line
    LineNr { fg = palette.gray[4] },                                           -- Line numbers
    CursorLineNr { fg = palette.black },                                       -- Cursor line number
    MatchParen { fg = palette.red[6], gui = 'bold,underline' },                -- Matching parenthesis
    Pmenu { fg = palette.gray[8], bg = palette.gray[1] },                      -- Popup menu
    PmenuSel { bg = palette.blue[2] },                                         -- Popup menu selection
    VertSplit { fg = palette.gray[3] },                                        -- Vertical split line
    StatusLine { fg = palette.gray[8], bg = palette.gray[1] },                 -- Status line
    StatusLineNC { fg = palette.gray[5], bg = palette.gray[1] },               -- Non-current status line
    Removed { fg = palette.red[6] },                                           -- Removed text
    Changed { fg = palette.blue[6] },                                          -- Changed text
    Added { fg = palette.green[6] },                                           -- Added text
    NonText { fg = palette.gray[3], bg = palette.white },                      -- Non-text characters

    ColorColumn { bg = palette.gray[2] },                                      -- Columns set with 'colorcolumn'
    Conceal { fg = palette.gray[4] },                                          -- Placeholder characters for concealed text
    Cursor { fg = palette.black, bg = palette.blue[6] },                       -- Character under the cursor
    CurSearch { fg = palette.white, bg = palette.yellow[5], gui = 'bold' },    -- Search pattern under the cursor
    lCursor { fg = palette.black, bg = palette.blue[6] },                      -- Character under the cursor with language mapping
    CursorIM { fg = palette.black, bg = palette.blue[6] },                     -- Like Cursor, but in IME mode
    CursorColumn { bg = palette.gray[1] },                                     -- Screen-column at the cursor
    Directory { fg = palette.blue[6] },                                        -- Directory names in listings
    EndOfBuffer { fg = palette.gray[4] },                                      -- Filler lines after the end of buffer
    TermCursor { fg = palette.black, bg = palette.blue[6] },                   -- Cursor in a focused terminal
    TermCursorNC { fg = palette.black, bg = palette.gray[5] },                 -- Cursor in an unfocused terminal
    ErrorMsg { fg = palette.red[6], gui = 'bold' },                            -- Error messages on the command line
    Folded { fg = palette.gray[6], bg = palette.gray[1] },                     -- Line used for closed folds
    FoldColumn { fg = palette.gray[4], bg = palette.gray[1] },                 -- 'foldcolumn'
    SignColumn { fg = palette.gray[5], bg = palette.white },                   -- Column where signs are displayed
    IncSearch { fg = palette.yellow[7], bg = palette.gray[3], gui = 'bold' },  -- 'incsearch' highlighting
    Substitute { fg = palette.white, bg = palette.orange[5], gui = 'bold' },   -- Replacement text highlighting
    LineNrAbove { fg = palette.gray[4] },                                      -- Line number above the cursor line
    LineNrBelow { fg = palette.gray[4] },                                      -- Line number below the cursor line
    CursorLineFold { fg = palette.gray[6], bg = palette.gray[1] },             -- FoldColumn when 'cursorline' is set
    CursorLineSign { fg = palette.gray[5], bg = palette.gray[1] },             -- SignColumn when 'cursorline' is set
    ModeMsg { fg = palette.blue[6], gui = 'bold' },                            -- 'showmode' message
    MsgArea { fg = palette.gray[9], bg = palette.white },                      -- Area for messages and cmdline
    MsgSeparator { fg = palette.gray[4] },                                     -- Separator for scrolled messages
    MoreMsg { fg = palette.green[6], gui = 'bold' },                           -- More-prompt
    NormalFloat { fg = palette.gray[9], bg = palette.gray[1] },                -- Normal text in floating windows
    FloatBorder { fg = palette.gray[5], bg = palette.gray[1] },                -- Border of floating windows
    FloatTitle { fg = palette.blue[6], gui = 'bold' },                         -- Title of floating windows
    NormalNC { fg = palette.gray[8], bg = palette.white },                     -- Normal text in non-current windows
    PmenuKind { fg = palette.purple[6] },                                      -- Popup menu: Normal item "kind"
    PmenuKindSel { fg = palette.white, bg = palette.purple[6] },               -- Popup menu: Selected item "kind"
    PmenuExtra { fg = palette.orange[6] },                                     -- Popup menu: Normal item "extra text"
    PmenuExtraSel { fg = palette.white, bg = palette.orange[6] },              -- Popup menu: Selected item "extra text"
    PmenuSbar { bg = palette.gray[2] },                                        -- Popup menu: Scrollbar
    PmenuThumb { bg = palette.gray[4] },                                       -- Popup menu: Thumb of the scrollbar
    Question { fg = palette.green[6] },                                        -- Hit-enter prompt and yes/no questions
    QuickFixLine { fg = palette.blue[6], bg = palette.gray[1], gui = 'bold' }, -- Current quickfix item
    Search { fg = palette.white, bg = palette.yellow[5], gui = 'bold' },       -- Last search pattern highlighting
    SpecialKey { fg = palette.orange[5] },                                     -- Unprintable characters
    SpellBad { sp = palette.red[6], gui = 'undercurl' },                       -- Word not recognized by spellchecker
    SpellCap { sp = palette.blue[6], gui = 'undercurl' },                      -- Word that should start with a capital
    SpellLocal { sp = palette.green[6], gui = 'undercurl' },                   -- Word recognized as local to another region
    SpellRare { sp = palette.purple[6], gui = 'undercurl' },                   -- Rarely used word
    TabLine { fg = palette.gray[6], bg = palette.gray[2] },                    -- Tab pages line, not active tab
    TabLineFill { bg = palette.gray[2] },                                      -- Tab pages line, where there are no labels
    TabLineSel { fg = palette.blue[6], bg = palette.gray[1], gui = 'bold' },   -- Active tab page label
    Title { fg = palette.gray[6], gui = 'bold' },                             -- Titles for output
    VisualNOS { bg = palette.red[1] },                                         -- Visual mode selection when not owning selection
    WarningMsg { fg = palette.yellow[6], gui = 'bold' },                       -- Warning messages
    Whitespace { fg = palette.gray[3] },                                       -- Whitespace characters
    Winseparator { fg = palette.gray[3] },                                     -- Separator between window splits
    WildMenu { fg = palette.white, bg = palette.blue[6], gui = 'bold' },       -- Current match in 'wildmenu' completion
    WinBar { fg = palette.blue[6], bg = palette.gray[2], gui = 'bold' },       -- Window bar of current window
    WinBarNC { fg = palette.gray[6], bg = palette.gray[2] },                   -- Window bar of not-current windows

    DiffAdd { fg = palette.green[6], bg = palette.green[1] },                  -- Diff mode: Added line
    DiffChange { fg = palette.green[6], bg = palette.green[1] },               -- Diff mode: Changed line
    DiffDelete { fg = palette.red[7], bg = palette.red[2] },                   -- Diff mode: Deleted line
    DiffText { fg = palette.green[6], bg = palette.green[3], gui = 'bold' },   -- Diff mode: Changed text within a changed line

    DiagnosticError { fg = palette.red[7] },
    DiagnosticWarn { fg = palette.yellow[7] },
    DiagnosticInfo { fg = palette.blue[6] },
    DiagnosticHint { fg = palette.green[6] },
    DiagnosticOk { fg = palette.green[5] },
    DiagnosticVirtualTextError { fg = palette.red[7] },
    DiagnosticVirtualTextWarn { fg = palette.yellow[7] },
    DiagnosticVirtualTextInfo { fg = palette.blue[6] },
    DiagnosticVirtualTextHint { fg = palette.green[6] },
    DiagnosticVirtualTextOk { fg = palette.green[5] },
    DiagnosticUnderlineError { sp = palette.red[7], gui = 'underline' },
    DiagnosticUnderlineWarn { sp = palette.yellow[7], gui = 'underline' },
    DiagnosticUnderlineInfo { sp = palette.blue[6], gui = 'underline' },
    DiagnosticUnderlineHint { sp = palette.green[6], gui = 'underline' },
    DiagnosticUnderlineOk { sp = palette.green[5], gui = 'underline' },
    DiagnosticFloatingError { fg = palette.red[7] },
    DiagnosticFloatingWarn { fg = palette.yellow[7] },
    DiagnosticFloatingInfo { fg = palette.blue[6] },
    DiagnosticFloatingHint { fg = palette.green[6] },
    DiagnosticFloatingOk { fg = palette.green[5] },
    DiagnosticSignError { fg = palette.red[7] },
    DiagnosticSignWarn { fg = palette.yellow[7] },
    DiagnosticSignInfo { fg = palette.blue[6] },
    DiagnosticSignHint { fg = palette.green[6] },
    DiagnosticSignOk { fg = palette.green[5] },

    -- Treesitter Typescript and Javascript
    sym('@variable.builtin.typescript') { fg = palette.blue[6] },
    sym('@attribute.typescript') { fg = palette.purple[6] },
    sym('@class_definition.typescript') { fg = palette.purple[6] },
    sym('@class_inherited.typescript') { fg = palette.purple[6] },
    -- All languages
    sym('@variable.parameter') { fg = palette.orange[6] },

    -- Builtin Typescript
    typescriptImport { Keyword },
    typescriptExport { Keyword },
    typescriptVariable { Keyword },

    typescriptDecorator { Special },
    typescriptClassname { fg = palette.purple[6] },
    typescriptClassHeritage { fg = palette.purple[6] },
    typescriptMember { Variable },
    typescriptIdentifier { Identifier },

    tsxIntrinsicTagName { fg = palette.green[7] },
    tsxAttrib { fg = palette.purple[6] },
    tsxTagName { fg = palette.blue[6] },

    -- ts_ls semantic token
    sym('@lsp.type.class.typescript') { fg = palette.purple[6] },
    sym('@lsp.type.interface.typescript') { fg = palette.purple[6] },
    sym('@lsp.type.property.typescript') { Variable },
    sym('@lsp.type.namespace.typescript') { fg = palette.purple[6] },
    sym('@lsp.type.member.typescript') { fg = palette.purple[6] },
    sym('@lsp.type.enum.typescript') { fg = palette.purple[6] },
    sym('@lsp.mod.local.typescript') { Identifier },
    sym('@lsp.mod.readonly.typescript') { Identifier },
    sym('@lsp.typemod.function.readonly.typescript') { Function },
    sym('@lsp.typemod.class.defaultLibrary.typescript') { Identifier },

    -- ts_ls tsx semantic token
    sym('@lsp.type.class.typescriptreact') { fg = palette.purple[6] },
    sym('@lsp.type.interface.typescriptreact') { fg = palette.purple[6] },
    sym('@lsp.type.property.typescriptreact') { Variable },
    sym('@lsp.type.namespace.typescriptreact') { fg = palette.purple[6] },
    sym('@lsp.type.member.typescriptreact') { fg = palette.purple[6] },
    sym('@lsp.type.enum.typescriptreact') { fg = palette.purple[6] },
    sym('@lsp.mod.local.typescriptreact') { Identifier },
    sym('@lsp.mod.readonly.typescriptreact') { Identifier },
    sym('@lsp.typemod.function.readonly.typescriptreact') { Function },
    sym('@lsp.typemod.class.defaultLibrary.typescriptreact') { Identifier },

    -- ts_ls html semantic token
    sym('tag.html') { fg = palette.green[7] },

    -- Illuminate
    IlluminatedWordRead { bg = palette.blue[2] },
    IlluminatedWordWrite { bg = palette.green[2] },
    IlluminatedWordText { bg = palette.blue[1] },
  }
end)

-- Return the lush theme
return theme
