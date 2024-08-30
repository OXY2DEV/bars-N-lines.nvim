local tabline = {};
local storage = require("bars.storage");
local icons = require("bars.icons");
local utils = require("bars.utils");

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

--- Turns a highlight group into tabline part
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

--- Turns a segment into a usable part in the tabline
---@param part bars.tabline.segment
---@return string
---@return integer
local get_output = function (part, opts)
	local _t = "";
	local w = 0;

	if part.click then
		if type(part.click) == "string" then
			_t = "%@" .. part.click .. "@";
		elseif type(part.click) == "function" then
			local id = storage.set_func("tabline", part.id or "unnamed", part.click);

			_t = "%@v:lua.__bars.tabline.funcs." .. id .. "@";
		end
	end

	if part.label then
		_t = "%" .. tostring(part.label) .. "T";
	end

	--- Renders a chunk
	---@param chunk [string, string | nil]?
	local add = function (chunk)
		if chunk then
			local _c;

			if vim.islist(chunk) and (vim.islist(chunk[1])) then
				for _, mini_chunk in ipairs(chunk) do
					local _e;

					if #mini_chunk >= 2 then
						_e = vim.api.nvim_eval_statusline(set_hl(mini_chunk[2]) .. mini_chunk[1], opts or {});

						_t = _t .. set_hl(mini_chunk[2]) .. mini_chunk[1];
						w = w + _e.width;
					elseif type(mini_chunk[1]) == "string" then
						_e = vim.api.nvim_eval_statusline(mini_chunk[1], opts or {});

						_t = _t .. mini_chunk[1];
						w = w + _e.width;
					end
				end
			elseif #chunk == 2 then
				_c = vim.api.nvim_eval_statusline(set_hl(chunk[2]) .. chunk[1], opts or {});

				_t = _t .. set_hl(chunk[2]) .. _c.str;
				w = w + _c.width;
			elseif type(chunk[1]) == "string" then
				_c = vim.api.nvim_eval_statusline(chunk[1], opts or {});

				_t = _t .. _c.str;
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

	if part.label then
		_t = _t .. "%X";
	end

	return _t, w;
end

---@type bars.tabline.config
tabline.configuration = {
	parts = {
		{
			type = "gap",
			id = 2
		},
		{
			type = "tabs",
			max_cols = 25,
			id = 3,

			active = {
				corner_left = { "", "BarsTablineTabActiveSep" },
				corner_right = { "", "BarsTablineTabActiveSep" },

				padding_left = { " ", "BarsTablineTabActive" },
				padding_right = { " " },
			},
			inactive = {
				corner_left = { "", "BarsTablineTabInactiveSep" },
				corner_right = { "",  "BarsTablineTabInactiveSep" },

				padding_left = { " ", "BarsTablineTabInactive" },
				padding_right = { " " },
			},
			wrap = { "⟩" }
		},
		{
			type = "bufs",
			id = 1,

			active = {
				corner_left = { "", "BarsTablineBufActiveSep" },
				corner_right = { "", "BarsTablineBufActiveSep" },

				padding_left = { " ", "BarsTablineBufActive" },
				padding_right = { " " },
			},
			inactive = {
				corner_left = { "", "BarsTablineBufInactiveSep" },
				corner_right = { "", "BarsTablineBufInactiveSep" },

				padding_left = { " ", "BarsTablineBufInactive" },
				padding_right = { " " },
			},

			ignore = { "" }
		},
	},

	skip_buftypes = { "nofile", "terminal" },
	skip_filetypes = { "noice" },
}



--- Shows buffers in the tabline
---@param config bars.tabline.bufs
---@param len integer
---@return string
---@return integer
tabline.m_bufs = function (config, len)
	local bufs = vim.api.nvim_list_bufs();
	local current = vim.api.nvim_get_current_buf();

	local count = config.max_count or 5;
	local tmpBufs = {};

	for _, buffer in ipairs(bufs) do
		local nm = vim.api.nvim_buf_get_name(buffer);

		for _, pattern in ipairs(config.ignore) do
			if pattern ~= "" and nm:match(pattern) then
				goto continue;
			elseif nm == "" then
				goto continue;
			end
		end

		table.insert(tmpBufs, buffer);
		::continue::
	end

	bufs = tmpBufs;

	-- From where we should list buffers?
	local rangeStart = storage.get("tabline", "bufViewStart");

	-- Get where to start the range
	if not rangeStart then
		rangeStart = 1;
		storage.set("tabline", "bufViewStart", 1);
	elseif rangeStart >= #bufs then
		rangeStart = 1;
		storage.set("tabline", "bufViewStart", 1);
	end

	-- Assign unique names to parts
	local names = {};
	local get_name = function (name)
		local segments = {};
		local tail = vim.fn.fnamemodify(name, ":t");

		for seg in name:gmatch("[^/]+") do
			if seg ~= "" and seg ~= tail then
				table.insert(segments, seg);
			else
				break;
			end
		end

		name = tail;

		while vim.list_contains(names, name) do
			name = truncate_segmant(table.remove(segments), 1) .. "/" .. name;
		end

		table.insert(names, name);
		return name;
	end

	-- Gets length of output text
	local get_len = function (...)
		local items = { ... };
		local _l = 0;

		for _, item in ipairs(items) do
			if type(item) == "string" then
				_l = _l + vim.fn.strdisplaywidth(item);
			elseif vim.islist(item) and item[1] then
				_l = _l + vim.fn.strdisplaywidth(item[1]);
			end
		end

		return _l;
	end

	local available = vim.o.columns - (len or 0);
	local _o = "";
	local render = function (active, buffer, name)
		local conf = config.inactive;
		local _t = "";

		if active == true then
			conf = config.active;
		end

		local l = get_len(conf.corner_left, conf.padding_left);
		local r = get_len(conf.corner_right, conf.padding_right);
		local w = get_len(config.wrap);

		if available <= l + r then
			-- Not enough space left
			if available >= w then
				-- Show the divider when possible
				_t = get_output({ content = config.wrap })
			end

			return;
		end

		-- available space is reduced
		available = available - (l + r);

		if active == true then
			storage.set_func("tabline", "bufIncreaseLimit", function ()
				local var = storage.get("tabline", "bufViewStart") or 0;
				storage.set("tabline", "bufViewStart", var + 1);

				vim.cmd("redrawt");
			end);
			_t = "%@v:lua.__bars.tabline.funcs.bufIncreaseLimit@";
		else
			local id = storage.set_func("tabline", "switchBuf" .. buffer, function ()
				utils.switch_to_buf(buffer);
			end);
			_t = "%@v:lua.__bars.tabline.funcs." .. id .. "@";
		end

		-- Left side
		_t = _t .. get_output({ content = conf.corner_left });
		_t = _t .. get_output({ content = conf.padding_left });

		-- Icon & text
		_t = _t .. vim.fn.strcharpart(icons.get(name) .. name, 0, available - 1);
		available = available - get_len(vim.fn.strcharpart(icons.get(name) .. name, 0, available - 1));

		-- Right side
		_t = _t .. get_output({ content = conf.padding_right });
		_t = _t .. get_output({ content = conf.corner_right });

		_t = _t .. "%X";

		if active == true then
			_o = _t .. _o;
		else
			_o = _o .. _t;
		end
	end

	local bufAdded = 0;
	local currAdded = false;

	-- Create a list of buffers to show
	for b, buf in ipairs(bufs) do
		if #bufs >= count then
			-- Not enough space
			if buf == current then
				render(true, buf, get_name(vim.api.nvim_buf_get_name(buf)))

				currAdded = true;
				bufAdded = bufAdded + 1;
			elseif b >= rangeStart and bufAdded < count then
				if currAdded == true and bufAdded < count then
					render(false, buf, get_name(vim.api.nvim_buf_get_name(buf)))

					bufAdded = bufAdded + 1;
				elseif currAdded == false and bufAdded < (count - 1) then
					render(false, buf, get_name(vim.api.nvim_buf_get_name(buf)))

					bufAdded = bufAdded + 1;
				end
			end
		else
			if buf == current then
				render(true, buf, get_name(vim.api.nvim_buf_get_name(buf)))
			else
				render(false, buf, get_name(vim.api.nvim_buf_get_name(buf)))
			end

			bufAdded = bufAdded + 1;
		end

		::continue::
	end

	return _o, 0;
end

--- Shows a lost of tabs
---@param config bars.tabline.tabs
---@return string
---@return integer
tabline.m_tabs = function (config)
	local tabs = vim.api.nvim_list_tabpages();
	local current = vim.api.nvim_get_current_tabpage();

	local count = config.max_count or 5;
	local _t = {};

	if #tabs > count then
		-- From where we should list tabs?
		local rangeStart = storage.get("tabline", "tabViewStart");

		-- Get where to start the range
		if not rangeStart then
			rangeStart = 1;
			storage.set("tabline", "tabViewStart", 1);
		elseif (#tabs - rangeStart) + 1 < count then
			rangeStart = 1;
			storage.set("tabline", "tabViewStart", 1);
		end

		local rangeEnd = rangeStart + count;
		local foundCurrent = false;

		for label, tab in ipairs(tabs) do
			if tab == current then
				foundCurrent = true;
				table.insert(_t, 1, {
					current = true,
					tab = tab, label = label
				});
			elseif label >= rangeStart and label <= rangeEnd then
				if foundCurrent == true and #_t < count then
					table.insert(_t, {
						current = false,
						tab = tab, label = label
					});
				elseif foundCurrent == false and #_t < (count - 1) then
					table.insert(_t, {
						current = false,
						tab = tab, label = label
					});
				end
			end
		end
	else
		for label, tab in ipairs(tabs) do
			if tab == current then
				table.insert(_t, {
					current = true,
					tab = tab, label = label
				});
			else
				table.insert(_t, {
					current = false,
					tab = tab, label = label
				});
			end
		end
	end

	local _o, _l = "", 0;

	for _, item in ipairs(_t) do
		local tmp, tmpl = get_output(vim.tbl_extend("force", item.current == true and config.active or config.inactive, {
			content = {
				tostring(item.tab)
			},
			label = item.label
		}));

		if item.current == true then
			tmp, tmpl = get_output(vim.tbl_extend("force", config.active or {}, {
				content = {
					tostring(item.tab)
				},

				id = "tabIncreaseLimit",
				click = function ()
					local var = storage.get("tabline", "tabViewStart") or 0;
					storage.set("tabline", "tabViewStart", var + 1);

					vim.cmd("redrawt");
				end
			}));
		end

		_o = _o .. tmp;
		_l = _l + tmpl
	end

	return _o, _l;
end

--- Renders a custom segment
---@param config bars.tabline.custom
---@param len integer
---@return string
---@return integer
tabline.m_custom = function (config, len)
	if not config.value or not pcall(config.value, len) then
		return "", 0;
	end

	return get_output(config.value(len))
end

--- Adds a gap to the tabline
---@param config bars.tabline.gap
---@return string
---@return integer
tabline.m_gap = function (config)
	return set_hl(config.hl) .. (config.before or "") .. "%=" .. (config.after or ""), 0;
end

--- Draws the tabline
---@return string
tabline.draw = function ()
	local texts, _l = {}, 0;

	for _, part in ipairs(tabline.configuration.parts) do
		local tmp, tmp_l;

		if part.type == "bufs" then
			tmp, tmp_l = tabline.m_bufs(part, _l);
		elseif part.type == "tabs" then
			tmp, tmp_l = tabline.m_tabs(part);
		elseif part.type == "custom" then
			tmp, tmp_l = tabline.m_custom(part, _l);
		elseif part.type == "gap" then
			tmp, tmp_l = tabline.m_gap(part);
		end

		if tmp then
			if part.id then
				table.insert(texts, part.id, tmp);
			else
				table.insert(texts, tmp);
			end

			_l = _l + tmp_l;
		end
	end

	-- Fix holes in the array
	local tmp_txt = {};

	for _, val in pairs(texts) do
		table.insert(tmp_txt, val);
	end

	texts = tmp_txt;

	return table.concat(texts);
end

--- Initializes the tabline
tabline.init = function ()
	vim.o.tabline = "%!v:lua.require('bars.tabline').draw()";
end

--- Disables the tabline
tabline.disable = function ()
	vim.g.tabline = "";
end

--- Sets up the tabline
---@param config bars.tabline.config
tabline.setup = function (config)
	if type(config) ~= "table" then
		return;
	end

	tabline.configuration = vim.tbl_deep_extend("force", tabline.configuration, config);
end

return tabline;
