# 🎇 bars-N-lines.nvim

An example *bars & lines* plugin for `Neovim`.

![statuscolumn](https://github.com/OXY2DEV/bars-N-lines.nvim/blob/images/Main/statuscolumn.gif)
![statusline](https://github.com/OXY2DEV/bars-N-lines.nvim/blob/images/Main/statusline.gif)
![tabline](https://github.com/OXY2DEV/bars-N-lines.nvim/blob/images/Main/tabline.gif)

>[!NOTE]
> This plugin is in an *active development phase*. Breaking changes may occur.

>[!WARNING]
> This is not meant for usage in your config. This plugin just shows how to configure various bars & lines.

**🚨 The problem:**

When I first started learning to use Neovim, I would use plugin(s) to decorate my statusline, statuscolumn, tabline etc.

This unfortunately came with some drawbacks,

- Most of these plugins were made for **desktop** so for obvious reasons didn't work well on a **phone**.
- Sometimes I will see a *feature* I like, bit then realize that the plugin I use doesn't support them.
- Sometimes the *defaults* don't work due to insufficient screen space.
- Other times the plugin doesn't have much configuration option(s).
- Parts/Segments creating the bars & lines have no way to communicate with each other. So, I can't have a dynamically set statusline/statuscolumn/tabline.
- Adding features on a code-base you have no idea about is hard, especially if you are new(like me) etc.

I also encountered performance issues and *some* minor inconvenience when using these plugins.

So, I tried trying to manually create the statusline/statuscolumn etc. and realized that there's not much tutorial on this topic.

I only found 1 tutorial that *actually* covered the basics instead of just slapping a few code blocks.

**💡 What does this repo do:**

This repo is a simple *example* plugin that shows implementation of the commonly used parts in various bars & lines plugins.

Now, you no longer have to be like me and spend literal *hours*(or days in some cases) just to implement these without any plugins.

I am trying to make this as easy to understand as possible and hope that this will come in handy to anyone who wants to learn about this.

## ✨ Features

- 🪪 ID system for segments. Segments can now be rendered based on their ID. This means you can use data from one segment to affect another one without hacking the plugin.
- 📏 Consistent segments. All segments have similar structure to make configuration more consistent.
- 📐 Automatically calculates the length of segments. This is useful for custom segments on smaller screens as this can be used to ensure that nothing overflows.
- 💬 Simple structure. The plugin is much simpler than all the other similar plugins to help noobs like *me* to understand how things work.
- 📊 Performant(even on mobile). Due to it's limited scope & simple design it's relatively faster in most cases.
- 📦 No external dependencies. No more needing to install 3 plugins just to get a simple statusline.
- 📱 Mobile first. Made on a mobile, made for a mobile.
- 🪷 Fully customisable fold column. Supports **per level** customisation too!
- 🎉 Touch support! Supports clicks in statusline & tabline(for now).

And much more!

## 📦 Installation

### 💤 Lazy.nvim

For `plugins.lua` or `lazy.lua` users,

```lua
{
    "OXY2DEV/bars-N-lines.nvim",
    -- No point in lazy loading this
    lazy = false
}
```

For `plugins/bars.lua` users.

```lua
return {
    "OXY2DEV/bars-N-lines.nvim",
    lazy = false
}
```

### 🦠 Mini.deps

```lua
local MiniDeps = require("mini.deps");

MiniDeps.add({
    source = "OXY2DEV/bars-N-lines.nvim"
});
```

### 🌘 Rocks.nvim

> Not yet ready.

```vim
:Rocks install bars-N-lines.nvim
```

## 🧩 Setup

```lua
{
    exclude_filetypes = {},
    exclude_buftypes = {},

    statuscolumn = true,
    statusline = true,
    tabline = true
}
```

Check the wiki for full specification.

<!-- 
    vim:spell
-->
