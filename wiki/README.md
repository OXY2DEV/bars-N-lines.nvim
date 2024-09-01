# ✨ Bars & lines: An overview

`Neovim`(& `Vim` to a certain extent) comes with various UI elements. Among them this plugin shows usage of the following ones,

- Statusline
- Statuscolumn
- Tabline

Though they all look different, they are configured the same way.

If you run this command,

```vim
set statusline?
```

>[!IMPORTANT]
> From this point on when I say **statusline** I also refer to the other items listed above(unless otherwise stated).

You will see a string being printed. This is what the statusline *actually* looks like.


## 🔩 How various bars & lines work

As explained above, the bars & lines are actually just a *long* string that can contain **special patterns** that do certain things.

So, let's see what we can do,

### 🎨 Coloring text

You can color various parts of the statusline in different colors.

>[!TIP]
> As I will be using `Lua` in these examples, you can add `lua ` before them to directly run them from the cmdline.

For example,

```lua
vim.o.statusline="%#Special#Special text"
```

Results in a colored text. Highlight group name can be put within `%#` & `#` to apply it. This group will be applied until another highlight group is encountered.

However, highlight groups do not mix. For example, a highlight group with a foreground & a highlight group with a background color won't mix together.

```lua
vim.o.statusline="%#CursorLine#CursorLine%#Special#Special"
```

You can see that `CursorLine` highlight group doesn't mix with `Special`.

### 🚀 Information in the statusline

So far, we have only shown **static** text. Now, we will show some information in the statusline.

Lucky for us, Neovim provides an easy way to do this.

For example, these are some of the ones I commonly use in my statusline.

- `%l`, The line number
- `%c`, The column number
- `%L`, Number of lines in the buffer
- `%v`, Screen column number

There are also a few other ones that I sometimes use.

- `%t`, File name of the file in the buffer(this is called the **t**ail of the file path).
- `%f`, Relative path of the file in the buffer.
- `%F`, Full path of the file in the buffer.
- `%n`, Buffer number.

>[!NOTE]
> You can check the **statusline** help file(`:h 'statusline'`) to learn more.

You can use them like so,
```lua
vim.o.statusline="Line: %l | Column: %c"
```

### 👾 Dynamic statusline

Up until now, our statusline has been fixed. Even though we could see some information in the statusline, how they were shown was pre determined.

The statusline option can also be a **function** instead of a literal string.

Let's take this for example,
```lua
vim.o.statusline = "%!v:lua.MyStatusline()";
```

Let's break it down,

- `%!`, this tells Neovim to evaluate the text after it and use the returned value instead of the string itself.
- `v:lua`, this allows us to use `Lua` inside of the statusline.
- `MyStatusline()`, the function whose result will be used.

Here's a pretty simple example,

```lua
--- _G is optional
_G.MyStatusline = function ()
    local mode = vim.api.nvim_get_mode().mode;

    if mode == "n" then
        return " 🚀 Normal";
    elseif mode == "i" then
        return " 📜 Insert";
    elseif mode == "v" then
        return " 👀 Visual";
    elseif mode == "c" then
        return " 👾 Cmdline";
    else
        return " 🤨 " .. mode;
    end
end

vim.o.statusline = "%!v:lua.MyStatusline()";
```

>[!TIP]
> You can also give *parameters* to the function!

```lua
_G.MyStatusline = function (param)
    -- The parameters are always string
    return param;
end

vim.o.statusline = "%!v:lua.MyStatusline(10)";
```

### 💥 Clicks

You can also add **clickable** regions in the statusline.

Clickable regions start with `%@function_name@` and end with `%X` or `%T`.

```lua
_G.clicker = function ()
    vim.print("Clicked!");
end

vim.o.statusline = "%@v:lua.clicker@ Click me %X";
```

### 💨 Spacing

Generally, we would normally specify the output text. But sometimes we might want to add spacing between parts of the statusline.

We might want to add some parts to the left & some other parts to the right of the statusline.

That's where `%=` comes in. It will expand to fill in the empty spaces between the text before it & after it.

```lua
vim.o.statusline = "Left%=Right"
```

This makes aligning text a lot easier.

```lua
vim.o.statusline = "Left%=Center%=Right"
```

## 🔰 Various statusline segments

Now, that you have a general idea about how to create the statusline. Let's talk about how to create some of the generally used segments of the statusline.

### 🚀 Segment: Mode indicator

This segment shows the current mode(with custom texts & highlight groups).

```lua
--- You can use <C-v> in insert mode to enter
--- special characters, e.g. ^V
---
--- A list of [ text, hl ] tuples for various modes
---@type [string, string?][]
local modes = {
    default = { " 🌟 Normal ", "" },

    ["no"] = { " 🧭 N-operation ", ""       },
    ["i"]  = { " 📝 Insert "     , "Cursor" },
    ["v"]  = { " 👀 Visual "     , ""       },
    ["V"]  = { " 🛸 Visual "     , ""       }, 
    [""] = { " 🧩 Visual "     , ""       },
    ["c"]  = { " 👾 Cmdline "    , ""       },
    ["t"]  = { " 💻 Terminal "   , ""       }
};

---@return string
_G.s_mode = function ()
    local mode = vim.api.nvim_get_mode().mode;
    local conf =  modes[mode] or modes.default;

    -- This doesn't deal with edge cases such as providing
    -- wrong data type
    return (conf[2] and "%#" .. conf[2] .. "#" or "") .. conf[1];
end
```

### 🔖 Segment: Buffer name

This segment shows the buffer name and an icon.

```lua
local icons = {
    default = "📄 ",
    lua = "🌙 "
};

local get_icon = function(name)
    local ext = vim.fn.fnamemodify(name, ":e");

    return icons[ext] or icons.default;
end

local shells = { "bash", "zsh" };

_G.s_bufname = function ()
    -- Get the buffer name from "%t"
    local name = vim.api.nvim_eval_statusline("%t", {}).str;

    if name == "" then
        return " ❓ Unknown ";
    elseif vim.list_contains(shells, name) then
        -- Since this is a simple example I won't
        -- show the PID here
        return " ✨ " .. name;
    else
        -- You can hook this into an "icon provider"
        -- to show icons too
        return "%#Special# " .. get_icon(name) .. name;
    end
end
```

### 🚨 Segment: Diagnostics

This segment shows the number of various diagnostics in the current buffer.

```lua
_G.s_diagnostic = function ()
    -- This is done in 2 lines to reduce the amount
    -- of space used
    local buffer = vim.api.nvim_eval_statusline("%n", {}).str;
    buffer = tonumber(buffer);

    -- Storing the level info in case the levels are
    -- different in users machine
    local info = vim.diagnostic.severity.INFO;
    local hint = vim.diagnostic.severity.HINT;
    local error = vim.diagnostic.severity.ERROR;
    local warn = vim.diagnostic.severity.WARN;

    local count = vim.diagnostic.count;

    local i = count(buffer, { severity = info })[info] or 0;
    local h = count(buffer, { severity = hint })[hint] or 0;
    local w = count(buffer, { severity = warn })[warn] or 0;
    local e = count(buffer, { severity = error })[error] or 0;

    return " 💬 " .. i .. " 🧩 " .. h .. " 🚧 ".. w .. " 🚨 " .. e;
end
```

### 🧭 Segment: Git branch

This segment shows the current **Git** branch without any other plugins.

```lua
_G.s_git = function ()
    -- This gets the path of the file
    -- Then it gets the directory of that file
    local path = vim.api.nvim_eval_statusline("%F", {}).str;
    path = vim.fn.fnamemodify(path, ":h");

    -- Handle unnamed buffers
    if path == "[No Name]" then
        return "";
    end

    -- This command gets the current branch
    local git = vim.fn.system("git -C " ..
                path ..
                " rev-parse --abbrev-ref HEAD")
    ;

    -- Remove all the control characters. We only need the branch
    -- name
    git = git:gsub("%c", "");

    if git:match("^fatal") then
        -- Command failed, most likely not in a repo
        return "";
    else
        return " 🧭 " .. git;
    end
end
```

