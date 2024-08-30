---@meta

---@alias bars.statuscolumn.segment [string, string?]

--- Configuration table for the statuscolumn module
---@class bars.statuscolumn.config
---
--- Enables/Disables this module
---@field enable? boolean
---
--- Parts to use for the statuscolumn
---@field parts (bars.statuscolumn.number | bars.statuscolumn.sign | bars.statuscolumn.fold | bars.statuscolumn.custom)[]
---
--- Custom configs
---@field custom table[]


--- Configuration table for custom components
---@class bars.statuscolumn.custom
---
--- Part type
---@field type "custom"
---
--- Value to show
---@field value (bars.statuscolumn.segment | fun(buffer: integer, window: integer, len: integer): bars.statuscolumn.segment)


--- Configuration table for fold column
---@class bars.statuscolumn.fold
---
--- Part type
---@field type "fold"
---
--- Various markers for folds
---@field markers bars.statuscolumn.fold.markers


---@class bars.statuscolumn.fold.markers
---
---@field default bars.statuscolumn.segment
---
---@field open bars.statuscolumn.segment[]
---@field close bars.statuscolumn.segment[]
---@field scope bars.statuscolumn.segment[]
---@field divider bars.statuscolumn.segment[]
---@field foldend bars.statuscolumn.segment[]


--- Configuration table for sign column
---@class bars.statuscolumn.sign
---
--- Part type
---@field type "sign"
---
---@field min_priority? integer


--- Configuration table for line numbers
---@class bars.statuscolumn.number
---
--- Part type
---@field type "number"
---
--- Number mode
---@field mode string
---
--- Default highlight group
---@field hl? string
---
--- Line number highlight group
---@field lnum_hl? string
---
--- Relative line number highlight group
---@field relnum_hl? string
---
--- Virtual line highlight group
---@field virtnum_hl? string
---
--- Wrapped line highlight group
---@field wrap_hl? string


