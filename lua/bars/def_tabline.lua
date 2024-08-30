---@meta

--- Configuration table for the tabline
---@class bars.tabline.config
---
--- Enables/Disables this module
---@field enable? boolean
---
--- Parts of the tabline
---@field parts table[]


--- Configuration table for the gaps in the tabline
---@class bars.tabline.gap
---
--- Highlight group for the gap
---@field hl? string
---
--- Text to add before the gap
---@field before? string
---
--- Text to add after the  gap
---@field after? string


--- Configuration table for a segment in the tabline
---@class bars.tabline.segment
---
--- ID, used for assigning click function names
---@field id? integer | string
---
--- A function to run when clicking this segment
---@field click? string | function
---
--- Label for switching between tabs
---@field label? integer
---
--- Left corner
---@field corner_left? [ string, string?]
---
--- Left padding
---@field padding_left? [ string, string?]
---
--- Main content
---@field content? [ string, string?]
---
--- Right padding
---@field padding_right? [ string, string?]
---
--- Right corner
---@field corner_right? [ string, string?]


--- Configuration table for a custom segment
---@class bars.tabline.custom
---
--- Segment type
---@field type "custom"
---
--- The text to show
---@field value fun(len: integer): bars.tabline.segment


--- Configuration table for showing tabs
---@class bars.tabline.tabs
---
--- Segment type
---@field type "tabs"
---
--- The max number of tabs to show, default 5
---@field max_count? integer
---
--- Segment config for current tab
---@field active bars.tabline.segment
---
--- Segment config for non-current tab(s)
---@field inactive bars.tabline.segment


--- Configuration table for buffers
---@class bars.tabline.bufs
---
--- Segment type
---@field type "bufs"
---
--- Buffer names to ignore
---@field ignore string[]?
---
--- Maximum number of buffers to show
---@field max_count? integer
---
--- Segment config for current buffer
---@field active bars.tabline.segment
---
--- Segment config for other buffer(s)
---@field inactive bars.tabline.segment
---
--- Text to show when the buffer list is wrapped.
---
--- Doesn't show anything if not enough space
--- is available
---@field wrap? [string, string?]

