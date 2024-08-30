---@meta

--- Variable storage for bars-N-lines
---@class bars.storage
---
---@field statusline bars.storage.value
---@field statuscolumn bars.storage.value
---@field tabline bars.storage.value

---@class bars.storage.value
---
--- Stores functions with their ID as keys
---@field funcs function[]
---
--- Stores variables with their ID as keys
---@field vars any[]


--- Configuration tale for the plugin
---@class bars.config
---
---@field ignore string[]?
---
---@field exclude_filetypes? string[]
---@field exclude_buftypes? string[]
---
---@field statuscolumn? bars.statuscolumn.config | boolean
---@field statusline? bars.statusline.config | boolean
---@field tabline? bars.tabline.config | boolean

