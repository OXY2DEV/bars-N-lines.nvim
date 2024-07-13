---@meta


----------------------------
---     For bars.lua     ---
----------------------------


---@class setup_table
--- The table used for setting up the plugin
---
---@field global_disable table? A table containing filetypes & buftypes that should be ignored; statusline & statuscolumn will NOT be set for them
---@field custom_configs setup_custom[]? A table providing custom configuration tables for specific filetypes & buftypes
---@field default { statuscolumn: statuscolumn_config?, statusline: statusline_config?, tabline: tabline_config? } Default configuration table for various bars & lines

---@class setup_custom 
--- Table containing custom configurations for specific filetypes & buftypes;
--- Unset values will be inherited from the default values
---
---@field filetypes string[]? List of filetypes where the custom config will be used
---@field buftypes string[]? List of buftypes where the custom config will be used
---@field config { statuscolumn: table?, statusline: table?, tabline: table? } A table containing various configuration options


----------------------------
--- For statuscolumn.lua ---
----------------------------


---@class statuscolumn_config
--- Configuration table for the statuscolumn
---
---@field enable boolean? Enables/Disables the statuscolumn
---@field options statuscolumn_options Options for the statuscolumn

---@class statuscolumn_options
---Options for the statuscolumn
---
---@field set_defaults boolean? Sets the default options
---@field default_hl string? Sets the default highlight group for the statuscolumn
---@field components (statuscolumn_gap_config | statuscolumn_border_config | statuscolumn_number_config | statuscolumn_fold_config | statuscolumn_sign_config)[]?

---@class statuscolumn_gap_config
--- Configuration table for the gap component
---
---@field type string Determines a component's type
---@field hl string? The highlight group to use for the gap
---@field text string The string to use for the gap

---@class statuscolumn_border_config
--- Configuration table for the border component
---
---@field type string Determines a component's type
---@field text string The text to use as the border
---@field hl nil | string[] | { prefix: string, from: number, to: number } Highlight groups for coloring the border

---@class statuscolumn_number_config
--- Configuration for the line number component
---
---@field type string Determines a component's type
---@field mode string Chnages what numbers are shown
---@field hl nil | string[] | { prefix: string, from: number, to: number } Highlight groups for coloring the line numbers

---@class statuscolumn_fold_config
--- Configuration for the fold column component
---
---@field type string Determines a component's type
---@field mode string Chnages what numbers are shown
---@field hl { default: string?, closed: (string | string[])?, opened: (string | string[])?, scope: (string | string[])?, edge: (string | string[])?, branch: (string | string[])? }
---@field text { closed: (string | string[])?, opened: (string | string[])?, scope: (string | string[])?, edge: (string | string[])?, branch: (string | string[])? }
---@field space string? Text to use on lines with no folds

---@class statuscolumn_sign_config
--- Configuration table for the sign column component
---
---@field type string The component type
---@field resize boolean? Makes the sign column change it's width when it's empty
---@field space string? The text to show when the sign column is empty
---@field resize_space string? The text to show when resize is enabled and sign column is empty
---@field rules { min_priority: number?, max_priority: number?, skip_ns_ids: number[]? } Rules for signs, used for toggling specific signs off

---@class sign
--- Structure of the items returned by `nvim_buf_get_extmark()`
---
---@field [number] number | sign_details

---@class sign_details
--- Details regarding a sign
---
---@field ns_id number Namespace ID
---@field priority number Priority of the extmark
---@field right_gravity boolean Controls where extmarks go on text change
---@field sign_hl_group string The highlight group for the sign
---@field sign_text string Text to show on the sign column


----------------------------
--- For statusline.lua ---
----------------------------


---@class statusline_config
--- Configuration table for the statusline
---
---@field enable boolean? Enables/Disables the statusline
---@field options statusline_options Options for the statusline

---@class statusline_options
--- Options for the statusline
---
---@field set_defaults boolean? Sets the default options
---@field default_hl string? Default highlight group for the statusline
---@field components (statusline_mode_config | statusline_buf_name_config | statusline_mode_config)? List of components to show

---@class statusline_component_raw
--- Table that is used to print various components into the statusline
---
---@field prefix string? Text to add before the component, doesn't count towards the width
---@field default_hl string? Default highlight group for a component
---@field corner_left_hl string? Text used for the left corner
---@field corner_left string? Text to put in the left corner
---@field padding_left_hl string? Text used for the left padding
---@field padding_left string? Text to put in the left padding
---@field icon_hl string? Highlight group for the icon
---@field icon string? Icon for the component
---@field text_hl string? Highlight group for the text
---@field text string? Icon for the component
---@field padding_right_hl string? Text used for the right padding
---@field padding_right string? Text to put in the right padding
---@field corner_right_hl string? Text used for the right corner
---@field corner_right string? Text to put in the right corner
---@field postfix string? Text to add after the component, doesn't count towards the width

---@class statusline_mode_config
--- Configuration table for the mode component
---
---@field default statusline_component_raw Default configuration of the mode component, used when a mode isn't found
---@field modes table<string, statusline_component_raw> Configuration tables for different modes

---@class statusline_buf_name_config
--- Configuration table for the buffer name component
---
---@field default_hl string? Default highlight group for the component
---@field corner_left_hl string? Text used for the left corner
---@field corner_left string? Text to put in the left corner
---@field padding_left_hl string? Text used for the left padding
---@field padding_left string? Text to put in the left padding
---@field padding_right_hl string? Text used for the right padding
---@field padding_right string? Text to put in the right padding
---@field corner_right_hl string? Text used for the right corner
---@field corner_right string? Text to put in the right corner

---@class statusline_gap_config
--- Configuration table for the gap component
---
---@field hl string? Name pf the highlight group to use

---@class statusline_position_config
--- Configuration for the cursor position component
---
---@field default_hl string? Default highlight group for the component
---@field corner_left_hl string? Text used for the left corner
---@field corner_left string? Text to put in the left corner
---@field padding_left_hl string? Text used for the left padding
---@field padding_left string? Text to put in the left padding
---@field icon_hl string? Highlight group for the icon
---@field icon string? Icon for the component
---@field segmant_left string? Text to show on the left side of the separator
---@field separator string? Text between both segmants
---@field segmant_right string? Text to show on the right side of the separator
---@field padding_right_hl string? Text used for the right padding
---@field padding_right string? Text to put in the right padding
---@field corner_right_hl string? Text used for the right corner
---@field corner_right string? Text to put in the right corner


----------------------------
--- For tabline.lua ---
----------------------------


---@class tabline_config
--- Configuration table for the tabline
---
---@field enable boolean? Enables/Disables the tabline
---@field options tabline_options Options for the tabline

---@class tabline_options
--- Options for the tabline
---
---@field default_hl string? Default highlight group for the statusline
---@field components (statusline_mode_config | statusline_buf_name_config | statusline_mode_config)? List of components to show

---@class tabline_component_raw
--- This is used by the tabline to render different types of  components
---
---@field prefix string? Things to add before the component, doesn't count towards the text length
---@field click string? Click handler, enclosed within %@...@
---@field bg string? The highlight to use for the component
---@field corner_left_hl string? Highlight group to use for the left corner
---@field corner_left string Text for the left corner
---@field padding_left_hl string? Highlight group for the left padding 
---@field padding_left string? Text for the left padding
---@field icon_hl string? Highlight group for the icon
---@field icon string? Text for the icon
---@field text_hl string? Highlight group for the text
---@field text string? Text for the text
---@field padding_right_hl string? Highlight group for the right padding 
---@field padding_right string? Text for the right padding
---@field corner_right_hl string? Highlight group to use for the right corner
---@field corner_right string Text for the right corner
---@field postfix string? Things to add after the component, doesn't count towards the text length

---@class tabline_separator_config
--- Configuration table for the separator
---
---@field direction string? The direction where the separator will be placed
---@field text string The text to use as the separator
---@field hl string? The highlight group for the separator
---@field condition function Function to determine whether to draw the separator
---@field on_complete function Function to dun after rendering the separator
---@field on_skip function Function to run after the component is rendered but the separator isn't

---@class tabline_buf_filter_config
--- Configuration table for the buffer validator function
---
---@field filetypes string[]? List of filetypes to avoid
---@field buftypes string[]? List of buftyoes to avoid
---@field names string[]? List of buffer names to avoid

---@class tabline_list_item_config
--- Configuration for the tabs tabline component
---
---@field width number? Optional width(in characters) for the component.
---@field active tabline_component_raw Component to show when a specific tab is the current tab
---@field inactive tabline_component_raw Component to show when a tab isn't the current tab
---@field separator tabline_separator_config Configuration table for the separator used when the oist becomes larger than {max_entries}
---@field max_entries number? Maximum number of entries before the current tab is locked at the beginning of the list

---@class tabline_gap_config
--- Configuration table for the gap component
---
---@field hl string? Name pf the highlight group to use

---@class tabline_buffers_config
--- Configuration for the tabs tabline component
---
---@field width number? Optional width(in characters) for the component.
---@field active tabline_component_raw Component to show when a specific tab is the current tab
---@field inactive tabline_component_raw Component to show when a tab isn't the current tab
---@field separator tabline_separator_config Configuration table for the separator used when the oist becomes larger than {max_entries}
---@field max_entries number? Maximum number of entries before the current tab is locked at the beginning of the list
---@field ignore tabline_buf_filter_config Table used to filter through the current list of buffers

