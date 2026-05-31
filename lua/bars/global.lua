--- Goes to clicked line number.
_G.bars_goto_lnum = function ()
	---|fS

	local mousepos = vim.fn.getmousepos();
	local cursor = vim.api.nvim_win_get_cursor(mousepos.winid);

	pcall(vim.api.nvim_win_set_cursor, mousepos.winid, { mousepos.line, cursor[2] });

	---|fE
end

--[[
Updates the state for the diagnostic component in the `statusline` for the clicked window.

The states change which diagnostic types are shown. It can be any of,

1. `Errors`
2. `Warnings`
3. `Informations`
4. `Hints`
5. `All`

You can get the current state by running,

```vim
:=vim.w.bars_diagnostic_state
```
]]
_G.bars_change_diagnostic_state = function ()
	---|fS

	local statusline = require("bars.statusline");

	local mousepos = vim.fn.getmousepos();
	local window = mousepos.winid

	if statusline.state.window_state[window] ~= true then
		--- Window isn't connected to bars.
		return;
	end

	if type(vim.w[window].bars_diagnostic_state) ~= "number" then
		vim.w[window].bars_diagnostic_state = 1;
	elseif vim.w[window].bars_diagnostic_state < 5 then
		vim.w[window].bars_diagnostic_state = vim.w[window].bars_diagnostic_state + 1;
	else
		vim.w[window].bars_diagnostic_state = 1;
	end

	pcall(vim.api.nvim__redraw, {
		win = window,
		flush = true,
		statusline = true
	});

	---|fE
end


--[[
Increases from where the tab list in the tabline is shown from.
]]
_G.bars_tablist_start_increase = function ()
	---|fS

	if not vim.g.bars_tablist_start then
		vim.g.bars_tablist_start = 1;
		return;
	end

	---@type integer Number of tabs.
	local tabs = #vim.api.nvim_list_tabpages();

	if vim.g.bars_tablist_start + 1 > tabs then
		vim.g.bars_tablist_start = 1;
	else
		vim.g.bars_tablist_start = vim.g.bars_tablist_start + 1;
	end

	pcall(vim.api.nvim__redraw, {
		flush = true,
		tabline = true
	});

	---|fE
end

--[[
Decreases from where the tab list in the tabline is shown from.
]]
_G.bars_tablist_start_decrease = function ()
	---|fS

	if not vim.g.bars_tablist_start then
		vim.g.bars_tablist_start = 1;
		return;
	end

	---@type integer Number of tabs.
	local tabs = #vim.api.nvim_list_tabpages();

	if vim.g.bars_tablist_start - 1 < 1 then
		vim.g.bars_tablist_start = tabs;
	else
		vim.g.bars_tablist_start = vim.g.bars_tablist_start - 1;
	end

	pcall(vim.api.nvim__redraw, {
		flush = true,
		tabline = true
	});

	---|fE
end

--[[
Increases from where the buffer list in the tabline is shown from.
]]
_G.bars_buflist_start_increase = function ()
	---|fS

	if not vim.g.bars_buflist_start then
		vim.g.bars_buflist_start = 1;
		return;
	end

	local utils = package.loaded["bars.utils"];

	---@type integer Number of buffers.
	local bufs = #utils.get_valid_bufs();

	if vim.g.bars_buflist_start + 1 > bufs then
		vim.g.bars_buflist_start = 1;
	else
		vim.g.bars_buflist_start = vim.g.bars_buflist_start + 1;
	end

	pcall(vim.api.nvim__redraw, {
		flush = true,
		tabline = true
	});

	---|fE
end


--[[
Decreases from where the buffer list in the tabline is shown from.
]]
_G.bars_buflist_start_decrease = function ()
	---|fS

	if not vim.g.bars_buflist_start then
		vim.g.bars_buflist_start = 1;
		return;
	end

	local utils = package.loaded["bars.utils"];

	---@type integer Number of buffers.
	local bufs = #utils.get_valid_bufs();

	if vim.g.bars_buflist_start - 1 < 1 then
		vim.g.bars_buflist_start = bufs;
	else
		vim.g.bars_buflist_start = vim.g.bars_buflist_start - 1;
	end

	pcall(vim.api.nvim__redraw, {
		flush = true,
		tabline = true
	});

	---|fE
end

---@type table<integer, function> Maps a `buffer` to it's `click handler`.
_G.bars_tabline_to_buffer = {};

