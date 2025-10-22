# Comprehensive Diff Architecture Investigation
**Date:** 2025-10-22T04:26:04Z  
**Purpose:** Understand how VSCode and Neovim convert diff data to rendered UI to design a VSCode-like diff implementation for Neovim

---

## Executive Summary

After comprehensive investigation of both VSCode and Neovim source code, I've discovered:

1. **VSCode's approach is FUNDAMENTALLY DIFFERENT** from simply applying highlights - it uses a complete custom rendering engine
2. **Neovim's `:diffthis` is NOT suitable** for VSCode-style per-buffer highlighting
3. **A working solution EXISTS** but requires understanding the architectural differences

---

## Part 1: VSCode Diff Architecture

### 1.1 Core Components (From microsoft/vscode source)

```
┌─────────────────────────────────────────────────────────┐
│ DiffEditorWidget (diffEditorWidget.ts)                 │
│ - Main orchestrator                                     │
│ - Manages two separate CodeEditorWidget instances      │
│ - Controls layout, scrolling synchronization           │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ DiffComputer (defaultLinesDiffComputer.ts)              │
│ - Runs diff algorithm (Myers-based, advanced)          │
│ - Returns: DetailedLineRangeMapping[]                   │
│   • Line-level changes (LineRange)                      │
│   • Character-level changes (RangeMapping[])            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ DiffEditorViewModel (diffEditorViewModel.ts)            │
│ - Converts diff data to view model                      │
│ - Handles line alignment (CRITICAL!)                    │
│ - Inserts "ghost lines" to align left/right            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Decorations System                                       │
│ - Left editor gets "delete" decorations (red)          │
│ - Right editor gets "insert" decorations (green)        │
│ - Applied PER EDITOR INSTANCE                           │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Key Data Flow

**Input:**
```typescript
original: ITextModel  // Left content
modified: ITextModel  // Right content
```

**Diff Computation:**
```typescript
interface DetailedLineRangeMapping {
  original: LineRange        // e.g., lines 10-15 in left
  modified: LineRange        // e.g., lines 10-17 in right
  innerChanges: RangeMapping[]  // Character-level deltas
}
```

**Line Alignment (THE CRITICAL PART):**
```typescript
// VSCode inserts EMPTY LINES to make both sides align!
//
// Example:
// LEFT (original):          RIGHT (modified):
// Line 1: foo               Line 1: foo
// Line 2: bar (deleted)     [GHOST LINE]
// Line 3: baz               Line 2: baz
// Line 4: qux (deleted)     [GHOST LINE]  
// Line 5: end               Line 3: end
//                           Line 4: new line (added)
// [GHOST LINE]              Line 5: another new
```

This is WHY VSCode diffs look aligned - they literally INSERT invisible lines!

**Decoration Application:**
```typescript
// LEFT editor
editor.setDecorations([{
  range: {startLine: 2, endLine: 2},
  className: 'char-delete'  // RED
}])

// RIGHT editor  
editor.setDecorations([{
  range: {startLine: 4, endLine: 4},
  className: 'char-insert'  // GREEN
}])
```

### 1.3 Why VSCode Works

1. **Two independent editor instances** - can have different decorations
2. **Ghost lines for alignment** - makes visual comparison easy
3. **Per-editor decoration system** - native support for buffer-specific highlights
4. **Custom scroll synchronization** - keeps both sides in sync

---

## Part 2: Neovim Diff Architecture

### 2.1 Built-in `:diffthis` (From neovim/neovim source)

```
┌─────────────────────────────────────────────────────────┐
│ diff.c - Core diff implementation                       │
│ - Uses xdiff library (libgit2's diff engine)            │
│ - Computes diff between buffers                         │
│ - Outputs: diff_T structure (internal)                  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ drawline.c - Rendering                                   │
│ - Applies GLOBAL highlight groups:                      │
│   • DiffAdd (added lines)                               │
│   • DiffDelete (deleted lines)                          │
│   • DiffChange (changed lines)                          │
│   • DiffText (changed CHARACTERS - the "delta")         │
│ - Same highlights used in ALL diff windows              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Filler Lines (Alignment)                                 │
│ - Neovim DOES insert filler lines!                      │
│ - But highlights are still GLOBAL                        │
└─────────────────────────────────────────────────────────┘
```

### 2.2 The FUNDAMENTAL Problem

**Neovim's highlight system for diff mode:**
- `DiffText` is applied to BOTH buffers
- No mechanism to say "use red in left, green in right"
- Highlight groups are GLOBAL, not buffer-specific

**Why this matters:**
- Even if we use extmarks, `:diffthis` mode overrides them
- The "delta" highlighting is hardcoded to use `DiffText`

### 2.3 Neovim's `vim.diff()` API

```lua
vim.diff(text1, text2, {
  algorithm = 'histogram',  -- or 'myers', 'patience', 'minimal'
  result_type = 'indices',  -- or 'unified'
})

-- Returns:
-- { {start_a, count_a, start_b, count_b}, ... }
-- Example: { {1, 1, 1, 1} } means:
--   Line 1, count 1 in text1 → Line 1, count 1 in text2
```

**This is GOOD** - it gives us the raw diff data!  
**But** - we need to implement the alignment and rendering ourselves.

---

## Part 3: Why Previous Attempts Failed

### 3.1 Attempt 1: Use `:diffthis` + extmarks
❌ **Failed** - `:diffthis` applies global `DiffText`, extmarks can't override it effectively

### 3.2 Attempt 2: Don't use `:diffthis`, just extmarks
❌ **Failed** - No line alignment, diff is unreadable (exactly what you experienced!)

### 3.3 The Missing Piece: **FILLER LINES**

Both attempts missed the CRITICAL component: **LINE ALIGNMENT**

Without filler lines:
```
LEFT:                   RIGHT:
1: foo                  1: foo
2: bar (deleted)        2: baz (THIS SHOULD BE LINE 3!)
3: baz                  3: new line (added)
```

This is UNREADABLE because lines don't correspond!

With filler lines:
```
LEFT:                   RIGHT:
1: foo                  1: foo
2: bar (deleted)        [FILLER]
3: baz                  2: baz
4:                      3: new line (added)
```

Now it's READABLE!

---

## Part 4: The Correct Solution Architecture

### 4.1 Required Components

```
┌──────────────────────────────────────────────────────────┐
│ 1. DIFF COMPUTATION                                      │
│    Input: left_lines[], right_lines[]                    │
│    Process: Use vim.diff() with histogram                │
│    Output: Diff hunks with line/char positions           │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 2. ALIGNMENT CALCULATION (THE CRITICAL PART!)            │
│    Process:                                              │
│    - For each diff hunk, calculate required fillers      │
│    - Build "aligned" line arrays                         │
│    - Track which lines are real vs. filler               │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 3. BUFFER CREATION                                       │
│    - Create left buffer with aligned content             │
│    - Create right buffer with aligned content            │
│    - Mark filler lines (concealed or grayed out)         │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 4. HIGHLIGHTING                                          │
│    Left buffer:                                          │
│    - DiffChange background for changed lines             │
│    - DiffDeleteChar (RED) extmarks for delta             │
│    Right buffer:                                         │
│    - DiffChange background for changed lines             │
│    - DiffAddChar (GREEN) extmarks for delta              │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│ 5. SCROLL SYNCHRONIZATION                                │
│    - Use scrollbind + custom autocmd                     │
│    - Keep both windows at same line number               │
└──────────────────────────────────────────────────────────┘
```

### 4.2 Alignment Algorithm (Pseudocode)

```lua
function align_buffers(left_lines, right_lines, diff_hunks)
  local aligned_left = {}
  local aligned_right = {}
  local left_idx = 1
  local right_idx = 1
  
  for _, hunk in ipairs(diff_hunks) do
    local start_a, count_a, start_b, count_b = 
      hunk[1], hunk[2], hunk[3], hunk[4]
    
    -- Add unchanged lines before this hunk
    while left_idx < start_a or right_idx < start_b do
      table.insert(aligned_left, left_lines[left_idx])
      table.insert(aligned_right, right_lines[right_idx])
      left_idx = left_idx + 1
      right_idx = right_idx + 1
    end
    
    -- Handle the diff hunk
    if count_a == 0 and count_b > 0 then
      -- Lines added in right
      for i = 1, count_b do
        table.insert(aligned_left, '[FILLER]')  -- Empty/grayed line
        table.insert(aligned_right, right_lines[right_idx])
        right_idx = right_idx + 1
      end
    elseif count_a > 0 and count_b == 0 then
      -- Lines deleted in left
      for i = 1, count_a do
        table.insert(aligned_left, left_lines[left_idx])
        table.insert(aligned_right, '[FILLER]')
        left_idx = left_idx + 1
      end
    else
      -- Lines changed
      local max_count = math.max(count_a, count_b)
      for i = 1, max_count do
        if i <= count_a then
          table.insert(aligned_left, left_lines[left_idx])
          left_idx = left_idx + 1
        else
          table.insert(aligned_left, '[FILLER]')
        end
        
        if i <= count_b then
          table.insert(aligned_right, right_lines[right_idx])
          right_idx = right_idx + 1
        else
          table.insert(aligned_right, '[FILLER]')
        end
      end
    end
  end
  
  -- Add remaining lines
  while left_idx <= #left_lines do
    table.insert(aligned_left, left_lines[left_idx])
    table.insert(aligned_right, right_lines[right_idx] or '[FILLER]')
    left_idx = left_idx + 1
    right_idx = right_idx + 1
  end
  
  return aligned_left, aligned_right
end
```

### 4.3 Why This Works

1. **Alignment** - Both buffers have same number of lines, easy to compare
2. **Per-buffer highlights** - Each buffer gets its own extmarks (red vs green)
3. **No :diffthis conflict** - We don't use built-in diff mode at all
4. **Visual clarity** - Filler lines make correspondence obvious

---

## Part 5: Implementation Plan

### Phase 1: Core Alignment Engine (CRITICAL)
**File:** `lua/core/diff/alignment.lua`

```lua
- compute_diff_hunks()      -- Use vim.diff()
- align_buffers()           -- Implement algorithm above
- create_filler_lines()     -- Generate filler content
```

**Success criteria:** Two buffers with same line count, visually aligned

### Phase 2: Buffer Management  
**File:** `lua/core/diff/buffers.lua`

```lua
- create_diff_buffers()     -- Create left/right buffers
- populate_buffers()        -- Fill with aligned content
- mark_filler_lines()       -- Conceal or gray out fillers
```

**Success criteria:** Side-by-side view with filler lines visible

### Phase 3: Highlighting System
**File:** `lua/core/diff/highlights.lua`

```lua
- apply_line_highlights()   -- DiffChange background
- apply_char_highlights()   -- Red/green delta extmarks
- clear_highlights()        -- Cleanup function
```

**Success criteria:** Red delta in left, green delta in right

### Phase 4: Synchronization
**File:** `lua/core/diff/sync.lua`

```lua
- setup_scrollbind()        -- Enable scroll sync
- setup_autocmds()          -- Handle cursor movement
- sync_windows()            -- Keep views aligned
```

**Success criteria:** Scrolling one side scrolls the other

### Phase 5: Main Orchestrator
**File:** `lua/core/diff/init.lua`

```lua
function DiffWithGit(ref)
  local left_lines = get_git_version(ref)
  local right_lines = get_current_buffer()
  
  local hunks = compute_diff_hunks(left_lines, right_lines)
  local aligned_left, aligned_right = align_buffers(left_lines, right_lines, hunks)
  
  local left_buf, right_buf = create_diff_buffers(aligned_left, aligned_right)
  
  apply_highlights(left_buf, right_buf, hunks)
  setup_synchronization(left_buf, right_buf)
end
```

---

## Part 6: Estimated Complexity

| Component | Complexity | Lines of Code | Risk |
|-----------|-----------|---------------|------|
| Alignment Algorithm | **HIGH** | ~150 | **HIGH** - Core logic, must be correct |
| Buffer Management | Medium | ~80 | Low - Straightforward |
| Highlighting | Medium | ~100 | Medium - Extmarks can be tricky |
| Synchronization | Low | ~50 | Low - Standard scrollbind |
| Integration | Low | ~30 | Low - Glue code |
| **TOTAL** | | **~410 LOC** | |

**Time Estimate:** 2-4 hours for experienced Lua developer

---

## Part 7: Critical Questions to Answer

### 7.1 How to represent filler lines?

**Option A:** Empty strings with concealment
```lua
aligned_left = {'foo', '', 'baz'}  -- '' is filler
-- Mark with conceal or NonText highlight
```

**Option B:** Special marker strings
```lua
aligned_left = {'foo', '<<<FILLER>>>', 'baz'}
-- Use conceal to hide the marker
```

**Option C:** Virtual text (nvim 0.10+)
```lua
-- Use virtual lines feature (if available)
vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
  virt_lines = {{'', 'NonText'}},
})
```

**Recommendation:** Option C if nvim ≥ 0.10, otherwise Option A

### 7.2 How to handle very large diffs?

VSCode uses "collapsed regions" for large hunks. We could:
- Initially show only first N lines of large hunks
- Add fold markers to expand/collapse
- Use virtual scrolling for massive files

### 7.3 What about moved code blocks?

VSCode detects and highlights moved blocks. This is **optional enhancement** - not needed for MVP.

---

## Part 8: Judgment - Can We Mimic VSCode?

### Answer: **YES, but it requires proper architecture**

**What we CANNOT do:**
- ❌ Use Neovim's `:diffthis` and get per-buffer highlights
- ❌ Simply apply extmarks without alignment  
- ❌ Reuse VSCode's TypeScript code directly

**What we CAN do:**
- ✅ Implement our own diff view with proper alignment
- ✅ Use `vim.diff()` for computing changes
- ✅ Apply per-buffer highlights with extmarks
- ✅ Achieve visual appearance very close to VSCode

**The key difference:**
- VSCode: Complete custom editor widget with built-in alignment
- Our solution: Use Neovim buffers + manual alignment + extmarks

**Feasibility:** **MEDIUM**
- Not trivial, but absolutely doable
- Main challenge: Alignment algorithm correctness
- Once alignment works, rest is straightforward

---

## Part 9: Recommended Next Steps

1. **Prototype alignment algorithm** (2 hours)
   - Test with simple examples
   - Verify line correspondence

2. **Implement buffer creation** (1 hour)
   - Create side-by-side view
   - Show filler lines

3. **Add highlighting** (1 hour)  
   - Test per-buffer extmarks
   - Verify red/green delta

4. **Polish and integrate** (1 hour)
   - Scroll sync
   - Edge cases
   - Error handling

**Total: ~5 hours of focused development**

---

## Part 10: References

### VSCode Source Files:
- `src/vs/editor/browser/widget/diffEditor/diffEditorWidget.ts` - Main diff editor
- `src/vs/editor/common/diff/defaultLinesDiffComputer/defaultLinesDiffComputer.ts` - Diff algorithm
- `src/vs/editor/browser/widget/diffEditor/diffEditorViewModel.ts` - Alignment logic

### Neovim Source Files:
- `src/nvim/diff.c` - Built-in diff implementation
- `src/nvim/drawline.c` - Rendering and highlights

### Neovim API:
- `vim.diff()` - Diff computation
- `vim.api.nvim_buf_set_extmark()` - Per-buffer highlights
- `vim.wo.scrollbind` - Scroll synchronization

---

## Conclusion

The path forward is clear:
1. Don't use `:diffthis`
2. Implement proper alignment
3. Use extmarks for per-buffer highlights

**This is absolutely achievable** and will give you VSCode-like diff appearance in Neovim!

---

*End of Investigation Report*
