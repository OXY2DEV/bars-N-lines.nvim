local utils = {};

--- Returns a list of attached windows
---@param buffer integer
---@return integer[]
utils.list_attached_wins = function (buffer)
	local windows = vim.api.nvim_list_wins();
	local filtered = {};

	for _, window in ipairs(windows) do
		if vim.api.nvim_win_get_buf(window) == buffer then
			table.insert(filtered, window);
		end
	end

	return filtered;
end

--- Finds the correct configuration table
---@param config bars.statusline.config | bars.statuscolumn.config
---@param buf integer
---@return unknown
utils.find_config = function (config, buf)
	local filetype = vim.bo[buf].filetype;
	local buftype = vim.bo[buf].buftype;

	if config.custom then
		for _, custom in ipairs(config.custom) do
			if vim.islist(custom.filetypes) and vim.list_contains(custom.filetypes, filetype) then
				return custom.parts;
			elseif vim.islist(custom.buftypes) and vim.list_contains(custom.buftypes, buftype) then
				return custom.parts;
			end
		end
	end

	return config.parts or {};
end

---@param hl string
---@return string | nil
utils.set_hl = function (hl)
	if type(hl) ~= "string" then
		return;
	end

	if hl:match("%#(.-)#") then
		return hl;
	end

	return "%#" .. hl .. "#"
end

utils.clamp = function (val, min, max)
	return math.min(math.max(val, min), max)
end

utils.tbl_clamp = function (input, number)
	if not vim.islist(input) then
		return input;
	end

	return input[utils.clamp(number, 1, #input)] or "";
end

utils.sort_by_priority = function (list, min_lval)
	local _item = {};
	local lval = min_lval or 0;

	for _, item in ipairs(list or {}) do
		if item[4] and item[4]["priority"] and item[4]["priority"] > lval then
			table.insert(_item, item)
		end
	end

	return _item;
end

utils.switch_to_buf = function (buf)
	local tabs = vim.api.nvim_list_tabpages();

	for _, tab in ipairs(tabs) do
		local windows = vim.api.nvim_tabpage_list_wins(tab);

		for _, window in ipairs(windows) do
			if vim.api.nvim_win_get_buf(window) == buf then
				vim.api.nvim_set_current_tabpage(tab);
				vim.api.nvim_set_current_win(window);
				return;
			end
		end
	end

	vim.api.nvim_set_current_buf(buf);
end

return utils;
