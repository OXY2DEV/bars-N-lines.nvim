local storage = {};

storage.src = function (source)
	if source == "statusline" then
		return _G.__bars.statusline;
	elseif source == "statuscolumn" then
		return _G.__bars.statuscolumn;
	elseif source == "tabline" then
		return _G.__bars.tabline;
	end

	vim.notify("[ bars.storage ] : Source doesn't exist", vim.log.levels.WARN);
end

storage.get = function (source, id)
	if source == "statusline" then
		return _G.__bars.statusline.vars[id];
	elseif source == "statuscolumn" then
		return _G.__bars.statuscolumn.vars[id];
	elseif source == "tabline" then
		return _G.__bars.tabline.vars[id];
	end

	vim.notify("[ bars.storage ] : Source doesn't exist", vim.log.levels.WARN);
end

storage.set = function (source, id, value)
	if source == "statusline" then
		_G.__bars.statusline.vars[id] = value;
		return id;
	elseif source == "statuscolumn" then
		_G.__bars.statuscolumn.vars[id] = value;
		return id;
	elseif source == "tabline" then
		_G.__bars.tabline.vars[id] = value;
		return id;
	end

	vim.notify("[ bars.storage ] : Source doesn't exist", vim.log.levels.WARN);
end

storage.create_var = function (source, id, value)
	local src;

	if source == "statusline" then
		src = _G.__bars.statusline;
	elseif source == "statuscolumn" then
		src = _G.__bars.statuscolumn;
	elseif source == "tabline" then
		src = _G.__bars.tabline;
	else
		vim.notify("[ bars.storage ] : Source doesn't exist", vim.log.levels.WARN);
		return;
	end

	if id and not src[id] then
		src.vars[id] = value;
		src.__var_id = id + 1;
	elseif not src.vars[src.__var_id] then
		src.vars[src.__var_id] = value;
		src.__var_id = id + 1;
	end
end

storage.set_func = function (source, id, value)
	local src;

	if source == "statusline" then
		src = _G.__bars.statusline;
	elseif source == "statuscolumn" then
		src = _G.__bars.statuscolumn;
	elseif source == "tabline" then
		src = _G.__bars.tabline;
	else
		vim.notify("[ bars.storage ] : Source doesn't exist", vim.log.levels.WARN);
		return;
	end

	if not id then
		id = #vim.tbl_keys(src.funcs) + 1;
	end

	src.funcs[id] = value;
	return id;
end

return storage;
