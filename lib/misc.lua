function sign(x)
	if x<0 then
		return -1
	elseif x>0 then
		return 1
	else
		return 0
	end
end

function min(t)
	if #t == 0 then return nil, nil end

	local key, value = 1, t[1]
	for i = 2, #t do
		if value > t[i] then
			key, value = i, t[i]
		end
	end
	return key, value
end

function max(t)
	if #t == 0 then return nil, nil end

	local key, value = 1, t[1]
	for i = 2, #t do
		if value < t[i] then
			key, value = i, t[i]
		end
	end
	return key, value
end

function exist_in(a,t)
	if #t == 0 then return nil end

	local found = false

	for i = 1, #t do
		if a == t[i] then
			found = true
		end
	end

	return found
end

function key_of(a,t)
	if #t == 0 then return nil end

	local found = false
	local key = nil

	for i = 1, #t do
		if a == t[i] then
			found = true
			key = i
		end
	end

	return found, key
end

function cat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function cat2(t)
	new_t = {}
	for i=1,#t do
		for j = 1, #t[i] do
			new_t[#new_t+1] = t[i][j]
		end
	end
	return new_t
end
