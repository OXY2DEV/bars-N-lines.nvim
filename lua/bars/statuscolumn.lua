local storage = require("bars.storage");
local utils = require("bars.utils");
local ffi = require("ffi");

local statuscolumn = {};

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

--- Turns a highlight group into a statusline part
---@param group_name (string | fun(): string)?
---@return string
local set_hl = function (group_name, ...)
	if type(group_name) ~= "string" then
		return "";
	elseif vim.fn.hlexists("Bars" .. group_name) == 1 then
		return "%#Bars" .. group_name .. "#";
	elseif vim.fn.hlexists(group_name) == 1 then
		return "%#" .. tostring(group_name) .. "#";
	else
		return "";
	end
end

--- Gets the value when the value can be
--- optionally a function
---@param val any
---@param ... any
---@return any
local get_value = function (val, ...)
	if pcall(val, ...) then
		return val(...);
	end

	return val;
end

--- Gets the output of a part of the statuscolumn
---@param part table
---@param window integer
---@return string
---@return integer
local get_output = function (part, window)
	local _t = "";
	local w = 0;

	if part.click then
		if type(part.click) == "string" then
			_t = "%@" .. part.click .. "@";
		elseif type(part.click) == "function" then
			local id = storage.set_func("statuscolumn", part.id or "unnamed", part.click);

			_t = "%@v:lua.__bars.statuscolumn.funcs." .. id .. "@";
		end
	end

	--- Renders a chunk
	---@param chunk [string, string | nil]
	local add = function (chunk)
		if chunk then
			local _c;

			if vim.islist(chunk) and (vim.islist(chunk[1])) then
				for _, mini_chunk in ipairs(chunk) do
					local _e;

					if #mini_chunk >= 2 then
						_e = vim.api.nvim_eval_statusline(set_hl(mini_chunk[2], window) .. get_value(mini_chunk[1], window), { winid = window });

						_t = _t .. set_hl(mini_chunk[2]) .. mini_chunk[1];
						w = w + _e.width;
					elseif type(mini_chunk[1]) == "string" then
						_e = vim.api.nvim_eval_statusline(mini_chunk[1], { winid = window });

						_t = _t .. mini_chunk[1];
						w = w + _e.width;
					end
				end
			elseif #chunk == 2 then
				_c = vim.api.nvim_eval_statusline(set_hl(chunk[2]) .. chunk[1], { winid = window });

				_t = _t .. set_hl(chunk[2]) .. chunk[1];
				w = w + _c.width;
			elseif type(chunk[1]) == "string" then
				_c = vim.api.nvim_eval_statusline(chunk[1], { winid = window });

				_t = _t .. chunk[1];
				w = w + _c.width;
			end
		end
	end

	add(part.content);

	if part.click then
		_t = _t .. "%X";
	end

	return _t, w;
end

---@type bars.statuscolumn.config
statuscolumn.configuration = {
	enable = true,
	parts = {
		{ type = "sign" },
		{
			type = "fold",

			markers = {
				default = {
					content = { "  " }
				},
				open = {
					{ " ", "BarsStatuscolumnFold1" }, { " ", "BarsStatuscolumnFold2" }, { " ", "BarsStatuscolumnFold3" },
					{ " ", "BarsStatuscolumnFold4" }, { " ", "BarsStatuscolumnFold5" }, { " ", "BarsStatuscolumnFold6" },
				},
				close = {
					{ "╴", "BarsStatuscolumnFold1" }, { "╴", "BarsStatuscolumnFold2" }, { "╴", "BarsStatuscolumnFold3" },
					{ "╴", "BarsStatuscolumnFold4" }, { "●╴", "BarsStatuscolumnFold5" }, { "◎╴", "BarsStatuscolumnFold6" },
				},

				scope = {
					{ "│ ", "BarsStatuscolumnFold1" }, { "│ ", "BarsStatuscolumnFold2" }, { "│ ", "BarsStatuscolumnFold3" },
					{ "│ ", "BarsStatuscolumnFold4" }, { "│ ", "BarsStatuscolumnFold5" }, { "│ ", "BarsStatuscolumnFold6" },
				},
				divider = {
					{ "├╴", "BarsStatuscolumnFold1" }, { "├╴", "BarsStatuscolumnFold2" }, { "├╴", "BarsStatuscolumnFold3" },
					{ "├╴", "BarsStatuscolumnFold4" }, { "├╴", "BarsStatuscolumnFold5" }, { "├╴", "BarsStatuscolumnFold6" },
				},
				foldend = {
					{ "╰╼", "BarsStatuscolumnFold1" }, { "╰╼", "BarsStatuscolumnFold2" }, { "╰╼", "BarsStatuscolumnFold3" },
					{ "╰╼", "BarsStatuscolumnFold4" }, { "╰╼", "BarsStatuscolumnFold5" }, { "╰╼", "BarsStatuscolumnFold6" },
				}
			},
		},
		{
			type = "number",
			mode = "hybrid",

			hl = "LineNr",
			lnum_hl = "BarsStatusColumnNum",
			relnum_hl = "LineNr",
			virtnum_hl = "TablineSel",
			wrap_hl = "TablineSel"
		},
		{
			type = "custom",
			value = { content = { " " } }
		},
		{
			type = "custom",
			value = function (_, win)
				if vim.api.nvim_get_current_win() ~= win then
					return {
						content = { "▎", "BarsStatusColumnGlow9" }
					};
				elseif vim.v.relnum <= 8 then
					return {
						content = { "▎", "BarsStatusColumnGlow" .. (vim.v.relnum + 1) }
					};
				else
					return {
						content = { "▎", "BarsStatusColumnGlow9" }
					};
				end
			end,
		}
	},

	custom = {
		{
			filetypes = {},
			buftypes = { "terminal" },
			parts = {}
		}
	}
}

--- Renders a custom part in the statuscolumn
---@param config bars.statuscolumn.custom
---@param buffer integer
---@param window integer
---@param len integer
---@return string
---@return integer
statuscolumn.m_custom = function (config, buffer, window, len)
	if type(config.value) == "table" then
		return get_output(config.value --[[@as [string, string?] ]], window);
	end

	if not config.value or not pcall(config.value --[[@as function]], buffer, window, len) then
		return "", 0;
	end

	return get_output(config.value(buffer, window, len), window);
end

--- Renders a foldcolumn
---@param config_table bars.statuscolumn.fold
---@param buffer integer
---@param window integer
---@return string
---@return integer
statuscolumn.m_fold = function (config_table, buffer, window)
	-- Can't use window-ID directly, we need the handle
	local handle = ffi.C.find_window_by_handle(window, nil);

	-- Next line
	local next_line = utils.clamp(vim.v.lnum + 1, 1, vim.api.nvim_buf_line_count(buffer));

	-- Fold related information to compare
	local foldInfo = ffi.C.fold_info(handle, vim.v.lnum);
	local foldInfo_after = ffi.C.fold_info(handle, next_line);

	local markers = config_table.markers;
	local closed;

	vim.api.nvim_win_call(window, function ()
		closed = vim.fn.foldclosed(vim.v.lnum);
	end)

	if foldInfo.start == vim.v.lnum then
		if closed ~= -1 then
			-- Opened fold
			return get_output({
				content = utils.format_input(markers.open, foldInfo.level)
			}, window);
		elseif foldInfo_after.level >= foldInfo.level then
			-- Closed fold
			return get_output({
				content = utils.format_input(markers.close, foldInfo.level)
			}, window);
		elseif foldInfo_after.level >= 1 then
			-- Inside a fold
			return get_output({
				content = utils.format_input(markers.scope, foldInfo.level)
			}, window);
		end
	elseif foldInfo.start ~= foldInfo_after.start and foldInfo.level >= foldInfo_after.level then
		if (foldInfo_after.level == 0 or (next_line == foldInfo_after.start and foldInfo_after.level <= vim.o.foldlevelstart)) and foldInfo.level >= foldInfo_after.level then
			-- End of fold
			return get_output({
				content = utils.format_input(markers.foldend, foldInfo.level)
			}, window);
		else
			-- Nested fold end
			return get_output({
				content = utils.format_input(markers.divider, foldInfo.level)
			}, window);
		end
	elseif foldInfo.level > 0 then
		if next_line == vim.v.lnum then
			-- End of fold
			return get_output({
				content = utils.format_input(markers.foldend, foldInfo.level)
			}, window);
		else
			-- Inside a fold
			return get_output({
				content = utils.format_input(markers.scope, foldInfo.level)
			}, window);
		end
	end

	return get_output(markers.default, window);
end

--- Renders a sign column
---@param config_table bars.statuscolumn.sign
---@param buffer integer
---@param window integer
---@return string
---@return integer
statuscolumn.m_signs = function (config_table, buffer, window)
	local signs = utils.sort_by_priority(
		vim.api.nvim_buf_get_extmarks(buffer,
			-1,
			{ vim.v.lnum - 1, 0 },
			{ vim.v.lnum - 1, -1 },
			{
				type = "sign",
				details = true
			}
		),
		config_table.min_priority
	);

	if signs and signs[1] and signs[1][4] and signs[1][4].sign_text then
		return get_output({
			content = {
				signs[1][4].sign_text,
				signs[1][4].sign_hl_group
			}
		}, window);
	end

	return "  ", 2;
end

--- Renders a number column
---@param config_table bars.statuscolumn.number
---@param buffer integer
---@param window integer
---@return string
---@return integer
statuscolumn.m_num = function (config_table, buffer, window)
	local max_num_len = math.max(2, vim.fn.strchars(vim.api.nvim_buf_line_count(buffer)))

	if config_table.mode == "absolute" then
		return get_output({
			content = { string.format("%+" .. max_num_len .. "s", tostring(vim.v.lnum)), config_table.lnum_hl or config_table.hl }
		}, window);
	elseif config_table.mode == "relative" then
		return get_output({
			content = { string.format("%+" .. max_num_len .. "s", tostring(vim.v.relnum)), config_table.relnum_hl or config_table.hl }
		}, window);
	else
		if vim.v.virtnum == 0 then
			if vim.v.relnum == 0 then
				return get_output({
					content = { string.format("%+" .. max_num_len .. "s", tostring(vim.v.lnum)), config_table.lnum_hl or config_table.hl }
				}, window);
			else
				return get_output({
					content = { string.format("%+" .. max_num_len .. "s", tostring(vim.v.relnum)), config_table.relnum_hl or config_table.hl }
				}, window);
			end
		elseif vim.v.virtnum < 0 then
			-- Virtual line
			return get_output({
				content = { string.rep(" ", max_num_len), config_table.virtnum_hl or config_table.hl }
			}, window);
		else
			-- Wrapped line
			return get_output({
				content = { string.rep(" ", max_num_len), config_table.wrap_hl or config_table.hl }
			}, window);
		end
	end
end

--- Draws the statuscolumn
---@param window integer
---@param buffer integer
---@return string
statuscolumn.draw = function (window, buffer)
	local conf = utils.find_config(statuscolumn.configuration, buffer);
	local texts, len = { "%#LineNr#"}, 0;

	for _, part in ipairs(conf) do
		local tmp, tmp_len = nil, 0;

		if part.type == "number" then
			tmp, tmp_len = statuscolumn.m_num(part, buffer, window);
		elseif part.type == "fold" then
			tmp, tmp_len = statuscolumn.m_fold(part, buffer, window);
		elseif part.type == "sign" then
			tmp, tmp_len =  statuscolumn.m_signs(part, buffer, window);
		elseif part.type == "custom" then
			tmp, tmp_len =  statuscolumn.m_custom(part, buffer, window, len);
		end

		if tmp then
			if part.id then
				table.insert(texts, part.id);
			else
				table.insert(texts, tmp);
			end

			len = len + (tmp_len or 0);
		end
	end


	-- Fix holes in the array
	local tmp_txt = {};

	for _, val in pairs(texts) do
		table.insert(tmp_txt, val);
	end

	texts = tmp_txt;

	return table.concat(texts)
end

--- Initializes the statuscolumn
---@param window integer
---@param buffer integer
statuscolumn.init = function (buffer, window)
	vim.wo[window].relativenumber = true; -- Redraw on cursor

	vim.wo[window].foldcolumn = "0";
	vim.wo[window].signcolumn = "no";

	vim.wo[window].numberwidth = 1; -- Prevent Click related bug

	vim.wo[window].statuscolumn = "%!v:lua.require('bars.statuscolumn').draw(" .. window .. "," .. buffer .. ")"
end

--- Disables the statuscolumn
---@param window integer
statuscolumn.disable = function (window)
	vim.wo[window].statuscolumn = "";
end

--- Sets up the statuscolumn
---@param config table?
statuscolumn.setup = function (config)
	if type(config) ~= "table" then
		return;
	end

	statuscolumn.configuration = vim.tbl_deep_extend("force", statuscolumn.configuration, config);
end

return statuscolumn;
