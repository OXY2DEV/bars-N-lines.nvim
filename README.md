# 🎇 bars-N-lines.nvim

Custom statuscolumn, statusline & tabline for `neovim`.

Features:
- Highly customisable statuscolumn, statusline & tabline.
- Custom fold column
- Custom sign column(with resize support when there are no signs)
- Buffer list/window list on tabline
- Click functionality on buffer names & tab numbers in tabline
- Built for small screens(e.g. mobile)

> 🎨 Color utility features
- Functions to turn `hex` & `rgb` colors into tables
- Built-in gradient generator function
- Various easing options for creating gradients

>[!NOTE]
> This plugin is meant for personal use case and as such **WILL** go through breaking changes quite often.

## Usage <!-- -+ -->

For setting up the plugin you can just call `require("bars").setup()`.

The setup function with all of the available options is given below.

```lua
require("bars").setup({
    global_disable = {
        filetypes = {},
        buftypes = {}
    },

    default = {
        statuscolumn = {
            enable = true,
            options = {}
        },
        statusline = {
            enable = true,
            options = {}
        },

        tabline = {
            enable = true,
            options = {}
        }
    },

    custom_configs = {}
});
```

>[!NOTE]
> For getting colors you also need to call the `utility module`.
> ```lua
> require("bars.colors").setup();
> ```
> This is done to reduce load time as things like gradients can take a bit of time.
> You can also set `highlight groups` to show a different color based on the current colorscheme.

Here's what all of them do,

### global_disable <!-- -+ -->
`{ filetypes: string[], buftypes: string[] } or nil`

You can set specific filetypes and buftypes where the plugin will be *disabled*.

>[!NOTE]
> On buffers where the plugin is disabled the `statuscolumn`, `statusline` & `tabline` will not be set.
>
> If you would like to *hide* them for a specific buffer use the `custom_configs` option.

<!-- -_ -->

### default <!-- -+ -->
`{ statuscolumn: statuscolumn_config?, statusline: statusline_config?, tabline: tabline_config? }`

Default configuration of the plugin. More info on the various keys of this table is provided in their own sections.

>[!IMPORTANT]
> When using the `custom_configs` options, options that are not set will be *inherited* from the `default` option.
>
> So, if you only set the `statusline` for a buffer the `statuscolumn` & `tabline` will be configured using the values in the `default` table.

<!-- -_ -->

### custom_configs <!-- -+ -->
`{ { buftypes: string[]?, filetypes: string[]?, config: default }[] } or nil`

Custom configuration table for specific filetypes & buftypes. Inherits values from the `default` table.

>[!NOTE]
> If `filetypes` & `buftypes` are set together then the plugin will try to match both of them first and then will match them individually.
>
> This currently **has no extra functionality** and an option will be provided to better control this behaviour.

<!-- -_ -->

## Disabling the plugin on certain filetypes & buftypes <!-- -+ -->

The `global_disable` option has the following keys,
- filetypes
- buftypes

>[!NOTE]
> On skipped buffers the values of `statuscolumn`, `statusline` will not be set. So, their default value will be used.

### filetypes
`string[]`

A list of filetypes that will be skipped.

>[!IMPORTANT]
> Buffers are updated when their `filetype` changes. So, you don't need to do something like `filetypes = { "" }`.

<!-- -_ -->

## Setting the statuscolumn <!-- -+ -->

The `statuscolumn` is one of the keys available in the `default`(and in the items in `custom_configs`). This can be used to set up a custom statuscolumn.

The statuscolumn table with all the available options is given below.

```lua
{
    enable = true,
    options = {
        set_defaults = false,
        default_hl = nil,

        components = {}
    }
}
```

### enable
`boolean or nil`

Enables/Disables the statuscolumn.

### Options
`{ set_defaults: boolean?, default_hl: string?, components: table[] }`

The options used to configure the statuscolumn.

#### set_defaults
`boolean or nil`

Sets the default options for making the statuscolumn. It sets the following options,
- relativenumber(for refresh on cursor move)
- foldcolumn(set to 0, because the plugin doesn't make use of the default one)
- signcolumn(set to "no", because the plugin has it's own functions for showing signs)
- numberwidth(set to 1, prevents a mouse click bug in 0.10.0)

#### default_hl
`string or nil`

Useful for changing the background color for the statuscolumn. Also removes the `cursorline` highlight in the statuscolumn.

#### components
`table[]`

Components are used to easily add functionalities to the statuscolumn without having to write the code yourself. You can set a list of components to use in the statuscolumn.

Currently available components are.
- gap `Adds a simple gap in the statuscolumn, allows setting a custom highlight for the gap`
- border `Adds border in the statuscolumn, optionally supports gradients`
- number `Adds line numbers & relative line numbers to the statuscolumn, optionally supports gradients`
- fold `Adds a custom foldcolumn, provides various ways to show folds`
- sign `Adds a custom signcolumn, allows filtering of signs based on namespaces & priority`

>[!NOTE]
> Function as components will be added in the future allowing users to make custom components for their needs.

More information on the components are available in their own files.

<!-- -_ -->

## Setting the statusline <!-- -+ -->

Just like the `statuscolumn`, the `statusline` can also be set in the configuration table.

The statusline table with all the available options is given below.

```lua
{
    enable = true,
    options = {
        set_defaults = false,
        default_hl = nil,

        components = {}
    }
}
```

### enable
`boolean or nil`

Enables/Disables the statusline.

### Options
`{ set_defaults: boolean?, default_hl: string?, components: table[] }`

The options used to configure the statusline.

#### set_defaults
`boolean or nil`

Sets some default options for the statusline.

The following options are set.
- laststatus(set to 2, to use buffer specific statusline)
- cmdheight(set to 1, to prevent a bug in neovim leading the statusline to temporarily disappear)

#### default_hl
`string or nil`

Default highlight group for the statusline. Useful if you want to hide the statusline without disabling it.

#### components
`table[]`

List of components to show in the statusline.

Currently available components are,
- mode `Shows the current mode, supports icons & colors for individual modes`
- buf_name `Shows the buffer name with it's filetype icon`
- gap `Adds gap between components, optionally with a specific highlight group`
- cursor_position `Shows the current column & row with icon, currently unfinished`

More information about them are available in the statusline wiki files.

<!-- -_ -->

## Setting up the tabline <!-- -+ -->

Just like the `statuscolumn` & `statusline`, the `tabline` can also be set in the configuration table.

>[!NOTE]
> The tabline is `global` unlike the other ones. So, it works a bit differently then others.

The tabline table with all the available options is given below.

```lua
{
    enable = true,
    options = {
        default_hl = nil,

        components = {}
    }
}
```

### enable
`boolean or nil`

Enables/Disables the tabline.

### Options
`{ set_defaults: boolean?, default_hl: string?, components: table[] }`

The options used to configure the tabline.

#### default_hl
`string or nil`

Default highlight group for the statusline. Useful if you want to hide the statusline without disabling it.

#### components
`table[]`

List of components to show in the statusline.

Currently available components are,
- buffers `lists all the open buffers, conditions for listing them are also provided`
- windows `lists all the open windows in the current tab`
- tabs `lists the currently open tabs`

More information about them are available in the statusline wiki files.

<!-- -_ -->

<!--- -_ -->

<!-- 
    vim:spell
-->
