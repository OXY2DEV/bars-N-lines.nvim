# 🛸 Tabline

The `tabline` works similar to the `statusline`. It is a global one, unlike the `statusline` which is per window.

## 🔖 Useful expressions

Like `statusline` & `statuscolumn`, the tabline also comes with it's own special expression.

Currently it only has `%nl`. This allows creating *clickable* tabs.

## 🔰 Various tabline segments

### 📏 Segment: Workspace-like tabs

In *titling window managers* you may have seen **workspace** that hold a bunch of windows.

This is basically just that. It is pretty simple to implement too.

```lua
_G.s_workspaces = function ()
    local tabs = vim.api.nvim_list_tabpages();
    local current = vim.api.nvim_get_current_tabpage();

    local _o = "";

    for t, tab in ipairs(tabs) do
        if tab == current then
            --- I am using "table.concat" to make
            --- it look simpler
            _o = _o .. table.concat({
                "%#Normal#",
                "",
                "%#Cursor#",
                " " .. t .. " ",
                "%#Normal#",
                ""
            });
        else
            _o = _o .. table.concat({
                "%" .. t .. "T", -- Click start
                "%#Normal#",
                "",
                " " .. t .. " ", -- Tab number
                "",
                "%X"             -- Click end
            });
        end
    end

    return _o;
end
```

