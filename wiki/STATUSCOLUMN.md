# 👾 Statuscolumn

The `statuscolumn` works similar to the `statusline` with some differences.

For example, the click functions are the same for every column. So, you can't add different functions in the same column.

Another difference is that unlike `statusline` this is run **per line**. So, you should avoid doing something complicated within the statuscolumn.

## 🔖 Useful expressions

Like in the `statusline`, the statuscolumn also has some useful expressions(e.g. text after `%`).

These are the most important ones,

- `%l`, The line number.
- `%r`, The relative line number.
- `%s`, The **sign column**.
- `%C`, The **fold column**.

>[!NOTE]
> The value of this expression is different for every line of the statuscolumn.

>[!TIP]
> You can check out the value of these variables with the following function.
> ```lua
> local get_val = function (var, lnum)
>   vim.print(vim.api.nvim_eval_statusline(var, {
>       use_statuscol_lnum = lnum or 1
>   }));
> end
> ```

You also get some of these variables in `Lua` too.

- `vim.v.lnum`, value of %l.
- `vim.v.relnum`, value of %r.
- `vim.v.virtnum`.

### 🤔 Virtnum(?)

The virtnum variable can have different values based on **what's on the line**.

Let's assume this is part of a *buffer* in `Neovim`.

```text
 ┏━━━━ Virtnum
 ┃ ┏━━ Lnum
 ┸ ┸
 0 1 ▍ This is a normal line.
 0 2 ▍ 
 0 3 ▍ This is a normal line,
-1 3 ▍      But with a virtual line.
 0 4 ▍ 
 0 5 ▍ This is a very long line that has been wrapped
+1 5 ▍ in 2 parts.
 0 6 ▍ 
```

As you can see, When a line is a `vitual line` the value is negative(-). However, If it is a `wrapped part` of a line it is positive(+).

On normal lines, it's 0.

>[!TIP]
> By using `virtnum` in a statuscolumn function, you can control when and how the line number is shown.

### 👀 Updating the statuscolumn

Normally, the `statuscolumn` only updates in specific scenarios.

However, you can change this behavior with the `relativenumber` option.

```lua
vim.o.relativenumber = true;
```

This will cause the `statuscolumn` to update when the cursor moves.

## 🔰 Various statuscolumn segments

### 📏 Segment: Line numbers

This segment shows the line number. It also handles **wraps**, **virtual lines**.

```lua
_G.MyCol = function ()
    -- Total number of lines in the buffer
    local lines = vim.api.nvim_eval_statusline("%L", {}).str;
    -- Maximum number of columns this segment will take
    local w = vim.fn.strdisplaywidth(lines) + 1;

    if vim.v.virtnum == 0 then
        -- Normal lines
        if vim.v.relnum == 0 then
            return "%#Special#" .. string.format("%+" .. w .. "s", tostring(vim.v.lnum));
        else
            return string.format("%+" .. w .. "s", tostring(vim.v.relnum));
        end
    elseif vim.v.virtnum < 0 then
        -- Virtual line
        return string.rep(" ", w);
    else
        -- Wrapped line
        return string.rep(" ", w)
    end
end

```

### 💡 Segment: Folds

This segment shows a custom fold column. It also shows the scope of the fold.

And it also supports nested folds.

Unfortunately for us, the information on folds provided by `Neovim` isn't enough(especially when the fold is open) for this to work completely.

This leads to some *edge-cases* flying under the radar.

Instead, we will use an *internal function* to get a bit more information on folds.

>[!NOTE]
> This approach was mentioned to me in a reddit comment(which I can no longer find) and I have seen this being used in `statuscol.nvim`.

```lua
local ffi = require("ffi");

--- This gives us access to the internal
--- "fold_info" function
---
--- This returns a table with the following structure
--- {
---   start, The start of the fold
---   level, The level of the fold
---   llevel, The level of the deepest nested fold
---   lines, When fold is closed the number of lines it contains
--- }
ffi.cdef([[
    typedef struct {} Error;
    typedef struct {} win_T;
    
    typedef struct {
        int start;
        int level;
        int llevel;
        int lines; // This one only works on closed folds
    } foldinfo_T;

    win_T *find_window_by_handle(int Window, Error *err);
    foldinfo_T fold_info(win_T* wp, int lnum);
]]);
```

Here's a function that uses this to create a custom fold column.

```lua
local clamp = function (val, min, max)
	return math.max(math.min(val, max), min);
end

_G.MyCol = function ()
	local buffer = tonumber(vim.api.nvim_eval_statusline("%n", {}).str);
	local window = vim.g.statusline_winid;

	-- Can't use window-ID directly, we need the handle
	local handle = ffi.C.find_window_by_handle(window, nil);

	-- Next line
	local next_line = clamp(vim.v.lnum + 1, 1, vim.api.nvim_buf_line_count(buffer));

	-- Fold related information to compare
	local foldInfo = ffi.C.fold_info(handle, vim.v.lnum);
	local foldInfo_after = ffi.C.fold_info(handle, next_line);

	if foldInfo.start == vim.v.lnum then
		if vim.fn.foldclosed(vim.v.lnum) ~= -1 then
			-- Opened fold
			return ""
		elseif foldInfo_after.level >= foldInfo.level then
			-- Closed fold
			return ""
		elseif foldInfo_after.level >= 1 then
			-- Inside a fold
			return "│"
		end
	elseif foldInfo.start ~= foldInfo_after.start and foldInfo.level >= foldInfo_after.level then
		if (foldInfo_after.level == 0 or (next_line == foldInfo_after.start and foldInfo_after.level <= vim.o.foldlevelstart)) and foldInfo.level >= foldInfo_after.level then
			-- End of fold
			return "╰╴";
		else
			-- Nested fold end
			return "├╴";
		end
	elseif foldInfo.level > 0 then
		if next_line == vim.v.lnum then
			-- End of fold
			return "╰╴";
		else
			-- Inside a fold
			return "│ ";
		end
	end

	return "  ";
end
```




