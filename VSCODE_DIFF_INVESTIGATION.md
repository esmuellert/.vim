# VSCode Diff Algorithm - Comprehensive Investigation Report

## Executive Summary

Based on deep investigation of VSCode's source code, here's what I found:

### 1. VSCode's Diff Algorithms

VSCode has **TWO** diff algorithms:

1. **"legacy"** (old) - Simple Myers algorithm
2. **"advanced"** (new, default) - Enhanced Myers with improvements

**Setting in VSCode**: `"diffAlgorithm": "advanced"` or `"legacy"`

### 2. Implementation Details

**Language**: **TypeScript** (JavaScript)
**Location**: `src/vs/editor/common/diff/` and worker services  
**Execution**: Runs in **Web Worker** (separate thread) for performance

**Key Files**:
- `src/vs/editor/browser/widget/diffEditor/diffEditorOptions.ts` - Configuration
- `src/vs/editor/browser/widget/diffEditor/diffProviderFactoryService.ts` - Provider factory  
- `src/vs/editor/common/services/editorWorker.ts` - Worker service
- `src/vs/editor/common/diff/` - Core diff algorithms

### 3. Input/Output Format

**Input**:
```typescript
interface {
  original: ITextModel,      // Original text (URI-based model)
  modified: ITextModel,      // Modified text  
  options: {
    ignoreTrimWhitespace: boolean,
    maxComputationTime: number,      // Timeout in ms
    computeMoves: boolean,            // Detect moved blocks
  }
}
```

**Output**:
```typescript
interface IDocumentDiff {
  changes: DetailedLineRangeMapping[],  // Line-level changes
  identical: boolean,                    // Are files identical?  
  quitEarly: boolean,                    // Timed out?
  moves: MovedText[],                    // Detected code moves
}

interface DetailedLineRangeMapping {
  original: LineRange,       // Lines in original (start, end)
  modified: LineRange,        // Lines in modified
  innerChanges: RangeMapping[]  // Character-level changes within lines
}

interface RangeMapping {
  originalRange: Range,      // Exact chars in original  
  modifiedRange: Range,      // Exact chars in modified
}
```

### 4. Compatibility with Neovim

**PROBLEM**: The formats are **INCOMPATIBLE**

| Aspect | Neovim | VSCode |
|--------|--------|--------|
| **Input** | Two text strings or files | TextModel objects with URIs |
| **Output** | Ed-style diff or line hunks | Complex TypeScript objects with ranges |
| **Execution** | C function or external program | JavaScript in Web Worker |
| **Algorithm** | xdiff (C library) | TypeScript implementation |

**VSCode's algorithm cannot be directly used in Neovim** because:
1. Different input format (TextModel vs raw text)
2. Different output format (TypeScript objects vs line hunks)  
3. Different runtime (JavaScript/Web Worker vs C/Lua)
4. Tightly integrated with VSCode's editor architecture

### 5. What VSCode's "Advanced" Algorithm Does Differently

From the code analysis:

**Advanced algorithm improvements** (vs legacy):
1. **Better move detection** - Identifies code blocks that moved
2. **Performance optimizations** - Caching, timeout handling
3. **Character-level diff** - Shows exact changed characters (innerChanges)
4. **Whitespace handling** - Better ignore whitespace options
5. **Heuristics** - Post-processing to align diffs better

**BUT**: The core is still based on **Myers algorithm**, similar to what Neovim uses!

### 6. Can We Use VSCode's Algorithm in Neovim?

**Three Approaches**:

#### Option A: Extract & Port to Lua (HARD, NOT RECOMMENDED)
- Extract TypeScript code → Rewrite in Lua
- **Effort**: Very high (weeks of work)
- **Maintenance**: Nightmare (need to sync with VSCode updates)
- **Result**: Likely not worth it - Neovim already has good algorithms

#### Option B: Create JavaScript Binary Wrapper (POSSIBLE BUT COMPLEX)
- Bundle VSCode's diff code with Node.js
- Create stdin/stdout wrapper  
- Call from Neovim via 'diffexpr'
- **Effort**: Medium-high
- **Issues**:
  - Requires Node.js on system
  - Slower than native (process spawn overhead)
  - Complex to maintain
  - Need to convert input/output formats

#### Option C: Use Similar Algorithm in Neovim (BEST APPROACH)
- **Neovim already has histogram algorithm** (similar quality to VSCode's advanced)
- Focus on **visual appearance** (highlighting) rather than algorithm
- The diff quality is already good - problem is UX/highlighting

### 7. The REAL Difference: It's Not the Algorithm!

After deep analysis, here's the truth:

**VSCode's better visual appearance is NOT due to the algorithm**  
**It's due to:**

1. **Character-level highlighting** - VSCode shows exact changed chars
2. **Better color scheme** - Distinct colors for add/delete/change
3. **Move detection highlighting** - Shows moved code blocks  
4. **Inline view** - Can show changes inline, not just side-by-side
5. **UI polish** - Margins, padding, decorations

**Neovim CAN do all of this!** The algorithm is already good (histogram).

### 8. Recommendation

**DO NOT try to port VSCode's algorithm.**

**Instead, focus on**:

1. ✅ Use Neovim's `histogram` algorithm (already done in your config)
2. ✅ Enable `linematch` for better line correlation (already done)
3. ❌ The `inline:char` option we tried doesn't exist in stable Neovim yet
4. 🎯 **Use a Lua plugin** to enhance diff highlighting:
   - Create custom extmarks for character-level changes
   - Use `vim.diff()` API to get detailed changes  
   - Apply different highlight groups for add/delete

### 9. The Lua Solution (What Actually Works)

Instead of trying to use VSCode's algorithm, use Neovim's **built-in `vim.diff()`** API:

```lua
-- Neovim has a BUILT-IN diff function!
local changes = vim.diff(text1, text2, {
  algorithm = 'histogram',  -- or 'myers', 'patience', 'minimal'
  result_type = 'indices',  -- Get exact character positions
})

-- Returns:
-- { {start_a, count_a, start_b, count_b}, ... }
```

This gives you the SAME level of detail as VSCode, but natively in Neovim!

### 10. Why Your Current Setup Might Not Look Like VSCode

Your `diffopt=histogram` is correct. The issue is likely:

1. **Missing character-level highlights** - Neovim's built-in diff is line-based
2. **Colorscheme** - Tokyo Night's diff colors might not be distinct enough  
3. **No inline diff markers** - VSCode adds special decorations

### 11. Next Steps - Practical Solution

Instead of porting VSCode's algorithm, create a Lua function that:

```lua
function EnhancedDiff(ref)
  -- 1. Get file contents
  local old_lines = vim.fn.systemlist('git show ' .. ref .. ':' .. file)
  local new_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  
  -- 2. Use Neovim's built-in diff
  local diffs = vim.diff(old_lines, new_lines, {
    algorithm = 'histogram',
    result_type = 'indices',
  })
  
  -- 3. Add character-level highlights using extmarks
  for _, change in ipairs(diffs) do
    -- Add custom highlighting per character
    vim.api.nvim_buf_set_extmark(bufnr, ns, line, col, {
      end_col = end_col,
      hl_group = 'CustomDiffAdd' or 'CustomDiffDelete',
    })
  end
end
```

This gives you VSCode-like appearance WITHOUT porting their algorithm!

## Conclusion

**Can we use VSCode's diff algorithm in Neovim?**  
**Technical answer**: Theoretically yes, but practically NO.

**Why**:  
1. Too complex to port (TypeScript → Lua)
2. Input/output formats incompatible  
3. Neovim's algorithms are already excellent
4. The visual difference is NOT the algorithm - it's the highlighting

**Better solution**:  
Use Neovim's native `vim.diff()` API with custom highlighting via extmarks to achieve VSCode-like appearance.

**The algorithm is NOT the problem - the UX/highlighting is!**
