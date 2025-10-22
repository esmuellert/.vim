# Neovim Diff Mode: Comprehensive Technical Analysis

## Overview of Neovim's Diff Implementation

Neovim uses a **side-by-side diff visualization** technique to show differences between files. The diff functionality is primarily implemented in `src/nvim/diff.c` and uses the **xdiff library** (`src/xdiff/`) as the core diff engine.

## Three Methods to Calculate Diffs

According to the code comments in `diff.c`, there are **three ways** to perform diff:

1. **External diff program** - Shell out to an external diff command using files
2. **Internal xdiff library** - Use the compiled-in xdiff library (default, recommended)
3. **Custom 'diffexpr'** - Let user-defined 'diffexpr' do the work using files

---

## Diff Algorithms Available

Neovim supports **multiple diff algorithms** through the `algorithm:` option in 'diffopt':

### 1. **Myers Algorithm** (Default)
- **Option**: `set diffopt=algorithm:myers`
- **Flag**: No special flag (default behavior)
- **Description**: The classic Myers algorithm - produces the smallest diff (minimal edit distance)
- **Use case**: General purpose, good for most scenarios
- **Code**: When no algorithm flag is set in xdiff

### 2. **Minimal Myers**
- **Option**: `set diffopt=algorithm:minimal`
- **Flag**: `XDF_NEED_MINIMAL`
- **Description**: Myers algorithm with extra effort to find the absolute minimal diff
- **Use case**: When you need the smallest possible diff, slower but more precise
- **Trade-off**: Can be significantly slower on large files

### 3. **Patience Algorithm**
- **Option**: `set diffopt=algorithm:patience`
- **Flag**: `XDF_PATIENCE_DIFF`
- **Description**: Patience diff algorithm - produces more "intuitive" diffs by finding unique lines first
- **Use case**: Better for code with lots of common lines (like function definitions)
- **Benefits**: Often produces more readable diffs for code

### 4. **Histogram Algorithm**
- **Option**: `set diffopt=algorithm:histogram`
- **Flag**: `XDF_HISTOGRAM_DIFF`
- **Description**: Extension of patience algorithm, uses histogram-based approach
- **Use case**: Similar to patience but generally faster
- **Benefits**: Good balance between readability and performance

---

## Additional Diff Processing Features

### Indent Heuristic
- **Flag**: `XDF_INDENT_HEURISTIC`
- **Option**: `set diffopt=indent-heuristic`
- **Description**: Post-processes diff output to slide diff hunks along whitespace
- **Effect**: Makes diffs align better with code structure (e.g., aligns to function boundaries)
- **Always enabled for inline diff**: When calculating character/word-level diffs

### Linematch
- **Option**: `set diffopt=linematch:N` (where N is max lines, e.g., `linematch:40`)
- **Description**: Performs line-by-line matching within diff blocks to find similar lines
- **Algorithm**: Uses xdiff internally to find most similar lines between diff blocks
- **Use case**: Shows which specific lines changed within a larger diff block
- **Implementation**: Splits diff blocks, matches lines using xdiff, then merges results

---

## How Diff Works: Technical Flow

### 1. Data Preparation
```c
// Buffer → Memory File (mmfile_t)
diff_write_buffer(buf, &mmfile, start_line, end_line);
// Converts buffer lines to a single memory block for xdiff
```

### 2. Algorithm Selection
```c
static int diff_algorithm = XDF_INDENT_HEURISTIC;  // default
// Can be changed via 'diffopt':
// - myers: 0
// - minimal: XDF_NEED_MINIMAL
// - patience: XDF_PATIENCE_DIFF
// - histogram: XDF_HISTOGRAM_DIFF
```

### 3. Diff Calculation
```c
// Call xdiff library
xdl_diff(&file1_mmfile, &file2_mmfile, &param, &emit_cfg, &emit_cb);

// param.flags contains:
// - Algorithm selection (myers/patience/histogram/minimal)
// - Whitespace handling (iwhite, iwhiteall, iwhiteeol)
// - Blank line ignore (iblank)
// - Indent heuristic
```

### 4. Result Processing
The xdiff library calls back with diff hunks:
```c
// Callback: xdiff_out()
// Receives: start_a, count_a (file1), start_b, count_b (file2)
// Stores in: diffhunk_T array
```

### 5. Diff Block Creation
Results are converted to Neovim's `diff_T` structures:
```c
typedef struct diff {
  linenr_T df_lnum[DB_COUNT];   // Line numbers in each buffer
  linenr_T df_count[DB_COUNT];  // Line counts in each buffer
  struct diff *df_next;          // Linked list
  bool is_linematched;           // Whether linematch was applied
  bool has_changes;              // Inline changes cached
  garray_T df_changes;           // Character/word-level changes
} diff_T;
```

---

## Inline Diff (Character/Word Level)

Neovim can show **inline differences** within changed lines using the `inline:` option:

### Options:
1. **`inline:none`** - No inline highlighting
2. **`inline:simple`** - Simple algorithm (find first/last different characters)
3. **`inline:char`** - Character-level diff using xdiff
4. **`inline:word`** - Word-level diff using xdiff (respects 'iskeyword')

### How Inline Diff Works:

1. **Split lines into tokens**:
   ```c
   // For char: each character (or multi-byte char) is a token
   // For word: split on word boundaries using 'iskeyword'
   ```

2. **Build temporary memory files**:
   ```c
   // Each token becomes a "line" in the mmfile, separated by NL
   // E.g., "hello world" → "h\ne\nl\nl\no\n \nw\no\nr\nl\nd\n"
   ```

3. **Run xdiff on tokens**:
   ```c
   diff_file_internal(&dio);  // Same xdiff call as line-level
   ```

4. **Map results back to original positions**:
   ```c
   // Use linemap_entry_T to track byte offsets in original buffer
   ```

5. **Refine results** (for char mode):
   ```c
   diff_refine_inline_char_highlight()
   // Merges small gaps to make output more readable
   ```

---

## Input/Output Data Structures

### Input to xdiff:
```c
typedef struct {
  char *ptr;    // Pointer to file content
  int size;     // Size in bytes
} mmfile_t;

typedef struct {
  unsigned long flags;  // Algorithm + whitespace options
  char **anchors;       // Diff anchors
  size_t anchors_nr;    // Number of anchors
} xpparam_t;

typedef struct {
  long ctxlen;          // Context lines (not used for diff mode)
  xdl_emit_hunk_consume_func_t hunk_func;  // Callback function
} xdemitconf_t;
```

### Output from xdiff:
```c
// Callback function signature:
typedef int (*xdl_emit_hunk_consume_func_t)(
    int start_a, int count_a,    // Old file: start line, count
    int start_b, int count_b,    // New file: start line, count
    void *cb_data                // User data
);
```

### Neovim's Storage:
```c
typedef struct {
  linenr_T lnum_orig;   // Line in original buffer
  int count_orig;        // Number of lines
  linenr_T lnum_new;    // Line in new buffer
  int count_new;         // Number of lines
} diffhunk_T;

// Converted to:
typedef struct diff {
  linenr_T df_lnum[DB_COUNT];     // Line numbers (up to 8 buffers)
  linenr_T df_count[DB_COUNT];    // Counts
  struct diff *df_next;            // Next diff block
  bool is_linematched;             // Linematch applied
  garray_T df_changes;             // Inline changes (diffline_change_T)
} diff_T;
```

---

## API Functions You Can Call

### From Vimscript/Lua:

1. **`:diffthis`** - Enable diff mode for current window
   ```vim
   :diffthis
   ```

2. **`:diffoff`** - Disable diff mode
   ```vim
   :diffoff
   :diffoff!  " All windows in tab
   ```

3. **`:diffupdate`** - Force diff recalculation
   ```vim
   :diffupdate
   :diffupdate!  " Also check if files changed externally
   ```

4. **Vimscript functions**:
   ```vim
   diff_filler(lnum)     " Returns filler lines above lnum
   diff_hlID(lnum, col)  " Returns highlight group at position
   ```

### From Lua:

```lua
-- Check if buffer is in diff mode
vim.wo.diff

-- Enable diff for current window
vim.cmd('diffthis')

-- Set diff options
vim.opt.diffopt = {
  'internal',           -- Use internal xdiff
  'filler',             -- Show filler lines
  'closeoff',           -- Turn off diff when closing window
  'algorithm:histogram', -- Use histogram algorithm
  'indent-heuristic',   -- Enable indent heuristic
  'linematch:60',       -- Enable linematch up to 60 lines
  'inline:char',        -- Character-level inline diff
}

-- Force update
vim.cmd('diffupdate')
```

---

## Customization via Options

### 'diffopt' - Main configuration option

**Syntax**: `set diffopt=option1,option2,...`

**Available options**:

| Option | Effect |
|--------|--------|
| `internal` | Use internal xdiff (recommended) |
| `filler` | Show filler lines for deleted/added lines |
| `context:N` | Show N lines of context (default: 6) |
| `icase` | Ignore case |
| `iwhite` | Ignore whitespace changes |
| `iwhiteall` | Ignore all whitespace |
| `iwhiteeol` | Ignore whitespace at end of line |
| `iblank` | Ignore blank lines |
| `algorithm:myers` | Use Myers algorithm (default) |
| `algorithm:minimal` | Use minimal Myers |
| `algorithm:patience` | Use Patience algorithm |
| `algorithm:histogram` | Use Histogram algorithm |
| `indent-heuristic` | Slide diffs along indentation |
| `horizontal` | Use horizontal splits |
| `vertical` | Use vertical splits |
| `closeoff` | Turn off diff when closing window |
| `followwrap` | Follow the 'wrap' option |
| `hiddenoff` | Turn off diff for hidden buffers |
| `foldcolumn:N` | Set foldcolumn width (default: 2) |
| `linematch:N` | Match similar lines (max N lines) |
| `inline:none` | No inline highlighting |
| `inline:simple` | Simple inline highlight |
| `inline:char` | Character-level inline highlight |
| `inline:word` | Word-level inline highlight |
| `anchor` | Use diff anchors |

### 'diffexpr' - Custom diff program

**Example**:
```vim
set diffexpr=MyDiff()
function MyDiff()
  silent execute '!diff -u ' . v:fname_in . ' ' . v:fname_new . ' > ' . v:fname_out
endfunction
```

### 'diffanchors' - Anchor points for diff

**Example**:
```vim
" Use marks as anchors
set diffanchors='a,'b

" Use line numbers
setlocal diffanchors=10,50,100

" Use patterns
set diffanchors=1/^function/,1/^class/
```

---

## Performance Considerations

1. **Algorithm Speed** (fastest to slowest):
   - myers (default) - Fast
   - histogram - Fast, good for code
   - patience - Medium
   - minimal - Slow, very thorough

2. **Inline diff overhead**:
   - `inline:simple` - Very fast
   - `inline:word` - Medium (depends on line length)
   - `inline:char` - Can be slow for long lines

3. **Linematch**:
   - Limited to configurable max lines (default 40)
   - Only runs when diff block is small enough
   - Uses xdiff internally (adds overhead)

4. **Large files**:
   - Internal diff is generally faster than external
   - indent-heuristic adds minimal overhead
   - Inline diff can be slow for very long lines

---

## Summary

**Neovim's diff mode**:
- Uses the **xdiff library** (same as Git uses)
- Supports **4 main algorithms**: Myers (default), Minimal, Patience, Histogram
- Can show **inline character/word-level** differences
- Supports **linematch** for better line-to-line correlation
- Can handle **up to 8 buffers** in diff mode simultaneously
- **Highly configurable** via 'diffopt'
- Can use **external diff** or **custom expressions** if needed

The implementation is robust, well-tested, and offers a good balance between performance and features for most use cases.
