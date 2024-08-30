local icons = require("bars.icons");
local utils = require("bars.utils");
local storage = require("bars.storage");

local statusline = {};

--- Truncates a segment of a path
---@param segment string
---@param len integer?
---@return string
local truncate_segmant = function (segment, len)
	if segment:match("^%.") then
		return vim.fn.strcharpart(segment, 0, (len or 1) + 1);
	else
		return vim.fn.strcharpart(segment, 0, len or 1);
	end
end

--- Turns a highlight group into a statusline part
---@param group_name string?
---@return string
local set_hl = function (group_name)
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

--- Turns a segmant into a usable part in the statusline
---@param part any
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
			local id = storage.set_func("statusline", part.id or "unnamed", part.click);

			_t = "%@v:lua.__bars.statusline.funcs." .. id .. "@";
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
						_e = vim.api.nvim_eval_statusline(set_hl(mini_chunk[2]) .. mini_chunk[1], { winid = window });

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

	add(part.corner_left);
	add(part.padding_left);
	add(part.content);
	add(part.padding_right);
	add(part.corner_right);

	if part.click then
		_t = _t .. "%X";
	end

	return _t, w;
end



---@type bars.statusline.config
statusline.config = {
	enable = true,
	parts = {
		{
			type = "mode",

			default = {
				corner_left = { " ", "BarsStatuslineNormal" },

				content = { " Normal" },

				padding_right = { " " },
				corner_right = { "", "BarsStatuslineNormalSep" }
			},

			modes = {
				["i"] = {
					corner_left = { " ", "BarsStatuslineInsert" },
					content = { " Insert" },
					corner_right = { "", "BarsStatuslineInsertSep" }
				},
				["R"] = {
					corner_left = { " ", "BarsStatuslineInsert" },
					content = { " Replace" },
					corner_right = { "", "BarsStatuslineInsertSep" }
				},
				["c"] = {
					corner_left = { " ", "BarsStatuslineCmd" },
					content = { " Command" },
					corner_right = { "", "BarsStatuslineCmdSep" }
				},
				["v"] = {
					corner_left = { " ", "BarsStatuslineVisual" },
					content = { "󰸿 Visual" },
					corner_right = { "", "BarsStatuslineVisualSep" }
				},
				["V"] = {
					corner_left = { " ", "BarsStatuslineVLine" },
					content = { "󰸽 Visual" },
					corner_right = { "", "BarsStatuslineVLineSep" }
				},
				[""] = {
					corner_left = { " ", "BarsStatuslineVBlock" },
					content = { "󰹀 Visual" },
					corner_right = { "", "BarsStatuslineVBlockSep" }
				},
			}
		},
		{
			type = "bufname",
			default = {
				id = "BufName",
				click = function ()
					local diagMode = storage.get("statusline", "diagnosticMode");

					if diagMode and diagMode < 5 then
						storage.set("statusline", "diagnosticMode", diagMode + 1);
					elseif diagMode then
						storage.set("statusline", "diagnosticMode", 0);
					else
						storage.set("statusline", "diagnosticMode", 1);
					end

					vim.cmd("redraws");
				end
			}
		},
		{
			type = "diagnostic",
			mode = function ()
				return storage.get("statusline", "diagnosticMode");
			end,

			info = " 󰍣 ",
			hint = "  ",
			warn = "  ",
			error = "  ",
		},
		{
			type = "gap"
		},
		{
			type = "git_branch",
			default = {
				corner_left = { "󰊢 ", "Comment" },
				content = {}
			},
			branches = {
				{
					match = "dev",
					corner_left = { "󰊢 ", "CmdViolet" },
				}
			}
		},
		{
			type = "ruler",

			max_len = 10,
			parts = {
				default = "─",
				line = "◆",
				column = "◇",
				both = "◈",
			}
		},
	},

	custom = {}
};


--- Renders a custom part
---@param config bars.statusline.config.custom
---@param buffer integer
---@param window integer
---@param len integer
---@return string
---@return integer
statusline.m_custom = function (config, buffer, window, len)
	if not config.value or not pcall(config.value, buffer, window, len) then
		return "", 0;
	end

	return get_output(config.value(buffer, window, len))
end

--- Renders a gap
---@param config bars.statusline.config.gap
---@return string
---@return integer
statusline.m_gap = function (config)
	return set_hl(config.hl) .. "%=", 0;
end

--- Renders a ruler
---@param config bars.statusline.config.ruler
---@param buffer integer
---@param window integer
---@return string
---@return integer
statusline.m_ruler = function (config, buffer, window)
	local id = "rulerMode";
	local _out = "";

	if not storage.get("statusline", id) then
		storage.set("statusline", id, 0);
	end

	local mode = storage.get("statusline", id);

	if mode == 0 then
		_out = "  %l  %c";
	elseif mode == 1 then
		local total = tonumber(vim.api.nvim_eval_statusline("%L", { winid = window }).str);
		local line = tonumber(vim.api.nvim_eval_statusline("%l", { winid = window }).str);

		local amount = math.max(1, math.floor((line / total) * config.max_len));
		_out = (amount < math.floor(config.max_len / 2)) and "󰸽 " or "󰹁 ";

		for l = 1, config.max_len, 1 do
			if l == amount then
				_out = _out .. config.parts.line
			else
				_out = _out .. config.parts.default
			end
		end
	elseif mode == 2 then
		local line = tonumber(vim.api.nvim_eval_statusline("%l", { winid = window }).str);
		local col = tonumber(vim.api.nvim_eval_statusline("%c", { winid = window }).str);
		local total = math.max(1, #vim.fn.getbufline(buffer, line)[1]);

		local amount = math.max(1, math.floor((col / total) * config.max_len));
		_out = (amount < math.floor(config.max_len / 2)) and "󰹀 " or "󰸾 ";

		for c = 1, config.max_len, 1 do
			if c == amount then
				_out = _out .. config.parts.column;
			else
				_out = _out .. config.parts.default;
			end
		end
	elseif mode == 3 then
		local line = tonumber(vim.api.nvim_eval_statusline("%l", { winid = window }).str);
		local col = tonumber(vim.api.nvim_eval_statusline("%c", { winid = window }).str);

		local total_l = tonumber(vim.api.nvim_eval_statusline("%L", { winid = window }).str);
		local total_c = math.max(1, #vim.fn.getbufline(buffer, line)[1]);

		local l = math.max(1, math.floor((line / total_l) * config.max_len));
		local c = math.max(1, math.floor((col / total_c) * config.max_len));
		_out = "󰸿 ";

		for i = 1, config.max_len, 1 do
			if i == c and i == l then
				_out = _out .. config.parts.both;
			elseif i == c then
				_out = _out .. config.parts.column;
			elseif i == l then
				_out = _out .. config.parts.line;
			else
				_out = _out .. config.parts.default;
			end
		end
	elseif mode == 4 then
		local date = os.date("*t");

		_out = date.hour .. " : " .. date.min;
	end

	return get_output({
		corner_left = { "", config.sep_hl or "BarsStatuslineRulerSep" },
		padding_left = { " ", config.hl or "BarsStatuslineRuler" },
		content = { _out },
		padding_right = { " " },

		id = "rulerFunc",
		click = function ()
			local prev = storage.get("statusline", id);

			if prev < (config.modes or 4) then
				storage.set("statusline", id, prev + 1);
			else
				storage.set("statusline", id, 0);
			end

			vim.cmd("redraws");
		end
	}, window);
end

--- Renders diagnostic count
---@param config bars.statusline.config.diagnostic
---@param buffer integer
---@param window integer
---@return string
---@return integer
statusline.m_diagnostics = function (config, buffer, window)
	local mode = 5;

	if pcall(config.mode --[[@as function]], buffer) then
		mode = config.mode(buffer);
	elseif type(config.mode) == "number" then
		mode = config.mode --[[@as integer]];
	end

	local lvl_info = vim.diagnostic.severity.INFO;
	local lvl_hint = vim.diagnostic.severity.HINT;
	local lvl_error = vim.diagnostic.severity.ERROR;
	local lvl_warn = vim.diagnostic.severity.WARN;

	if mode == 1 then
		local count = vim.diagnostic.count(buffer, { severity = lvl_info });

		return get_output({
			content = { (config.info or "") .. (count[lvl_info] or 0), config.info_hl or "DiagnosticInfo" }
		}, window)
	elseif mode == 2 then
		local count = vim.diagnostic.count(buffer, { severity = lvl_hint });

		return get_output({
			content = { (config.hint or "") .. (count[lvl_hint] or 0), config.hint_hl or "DiagnosticHint" }
		}, window)
	elseif mode == 3 then
		local count = vim.diagnostic.count(buffer, { severity = lvl_warn });

		return get_output({
			content = { (config.warn or "") .. (count[lvl_warn] or 0), config.warn_hl or "DiagnosticWarn" }
		}, window)
	elseif mode == 4 then
		local count = vim.diagnostic.count(buffer, { severity = lvl_error });

		return get_output({
			content = { (config.error or "") .. (count[lvl_error] or 0), config.error_hl or "DiagnosticError" }
		}, window)
	elseif mode == 5 then
		local i_count = vim.diagnostic.count(buffer, { severity = lvl_info })[lvl_info];
		local h_count = vim.diagnostic.count(buffer, { severity = lvl_hint })[lvl_hint];
		local w_count = vim.diagnostic.count(buffer, { severity = lvl_warn })[lvl_warn];
		local e_count = vim.diagnostic.count(buffer, { severity = lvl_error })[lvl_error];

		return get_output({
			content = {
				{ i_count and (config.info or "") .. i_count or "" , i_count and (config.info_hl or "DiagnosticInfo") or nil },
				{ h_count and (config.hint or "") .. h_count or "" , h_count and (config.hint_hl or "DiagnosticHint") or nil },
				{ w_count and (config.warn or "") .. w_count or "" , w_count and (config.warn_hl or "DiagnosticWarn") or nil },
				{ e_count and (config.error or "") .. e_count or "", e_count and (config.error_hl or "DiagnosticError") or nil },
			}
		}, window);
	else
		return "", 0;
	end
end

--- Renders current branch name
---@param config bars.statusline.config.git
---@param window integer
---@return string
---@return integer
statusline.m_git_branch = function (config, window)
	-- Gets the current branch
	local git = vim.fn.system("git rev-parse --abbrev-ref HEAD");
	git = git:gsub("[^%a]*", "");

	if git:match("^fatal") then
		return "", 0;
	else
		local conf = vim.tbl_extend("force", config.default or {}, {
			content = { git .. " ", config.default and config.default.hl or nil },
		});

		for _, branch in ipairs(config.branches or {}) do
			if git:match(branch.match) then
				conf = vim.tbl_extend("force", branch, {
					content = { git .. " ", config.default and config.default.hl or nil },
				});
			end
		end

		return get_output(conf, window)
	end
end

--- Renders buffer name
---@param config bars.statusline.config.bufname
---@param buffer integer
---@param window integer
---@return string
---@return integer
statusline.m_bn = function (config, buffer, window)
	local bufname = vim.api.nvim_buf_get_name(buffer);
	local icon = icons.get(bufname);

	-- Handle special names that aren't file
	if vim.fn.filereadable(bufname) == 0 then
		if bufname == "" then
			return get_output({
				padding_right = { "" },
				corner_right = { "", "BarsStatuslineBufSep" }
			}, window);
		end

		return get_output({
			corner_right = { "", "BarsStatuslineBufSep" }
		}, window);
	end

	local name = vim.fn.fnamemodify(bufname, ":t");
	local extension = name:match("%.(.-)$");

	local conf = config.default or {};

	if config.extensions and config.extensions[extension] then
		conf = config.extensions[extension]
	end

	local short_path = {};

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local tmp = vim.api.nvim_buf_get_name(buf);

		if buf ~= buffer and tmp:match(name .. "$") then
			bufname = bufname:gsub(name .. "$", "");
			bufname = bufname:gsub("/$", "");
			tmp = tmp:gsub(name .. "$", "");
			tmp = tmp:gsub("/$", "");

			while bufname:match("/?([^/]-)$") do
				local segmant = bufname:match("/?([^/]-)$");

				if tmp:match(segmant .. "$") then
					table.insert(short_path, { truncate_segmant(segmant) .. "/", conf.path_hl })

					bufname = bufname:gsub(segmant, "");
					bufname = bufname:gsub("/$", "");
					tmp = tmp:gsub(segmant, "");
					tmp = tmp:gsub("/$", "");
				else
					table.insert(short_path, { truncate_segmant(segmant) .. "/", conf.path_leader_hl })

					break;
				end
			end
		end
	end

	local content = {
		{ icon, conf.icon_hl },
		{ name, conf.name_hl }
	};

	for _, part in ipairs(short_path) do
		table.insert(content, 2, part);
	end

	return get_output(vim.tbl_extend("force", {
		padding_left = { " ", "BarsStatuslineBuf" },
		content = content,
		padding_right = { " " },
		corner_right = { "", "BarsStatuslineBufSep" }
	}, conf), window);
end

--- Renders current mode
---@param config bars.statusline.config.mode
---@param window integer
---@return string
---@return integer
statusline.m_mode = function (config, window)
	local mode = vim.api.nvim_get_mode().mode;
	local conf = config.default;

	if config.modes and config.modes[mode] then
		conf = vim.tbl_extend("keep", config.modes[mode], config.default);
	end

	return get_output(conf, window);
end







--- Draws the statusline
---@param buffer integer
---@param window integer
---@return string
statusline.draw = function (buffer, window)
	local config = utils.find_config(statusline.config, buffer);
	local texts, len = {}, 0;

	for _, part in ipairs(config) do
		local tmp, tmp_len = nil, 0;

		if part.type == "mode" then
			tmp, tmp_len = statusline.m_mode(part, window);
		elseif part.type == "bufname" then
			tmp, tmp_len = statusline.m_bn(part, buffer, window);
		elseif part.type == "git_branch" then
			tmp, tmp_len = statusline.m_git_branch(part, window);
		elseif part.type == "gap" then
			tmp, tmp_len = statusline.m_gap(part);
		elseif part.type == "ruler" then
			tmp, tmp_len = statusline.m_ruler(part, buffer, window);
		elseif part.type == "diagnostic" then
			tmp, tmp_len = statusline.m_diagnostics(part, buffer, window);
		elseif part.type == "custom" then
			tmp, tmp_len = statusline.m_custom(part, buffer, window, len)
		end

		if tmp then
			if part.id then
				table.insert(texts, part.id, tmp);
			else
				table.insert(texts, tmp);
			end

			len = len + tmp_len;
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

--- Initializes the module in a specific window
---@param buffer integer
---@param window integer
statusline.init = function (buffer, window)
	vim.wo[window].statusline = "%!v:lua.require('bars.statusline').draw(" .. buffer .. "," .. window .. ")";
end

--- Resets the statusline in a specific window
---@param window integer
statusline.disable = function (window)
	vim.wo[window].statusline = "";
end

--- Setup function, used for updating config
---@param config (bars.statusline.config | boolean)?
statusline.setup = function (config)
	if type(config) == "table" then
		-- Update config table
		statusline.config = vim.tbl_extend("force", statusline.config, config);
	elseif config and (config == false or config.enable == false) then
		-- Module is disabled
		return;
	end

	-- vim.g.cmdheight = 0;
end

return statusline;
