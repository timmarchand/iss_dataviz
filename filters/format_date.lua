-- Adapted from https://github.com/iagoleal/iagoleal.github.io/blob/master/filters/date.lua
local function split(s, delimiter)
    result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

local function format_date(date_str)
    if date_str:match("^%d%d%d%d%-%d%d%-%d%d$") then
        local date = pandoc.utils.normalize_date(date_str)
        local year, month, day = table.unpack(split(date, '-'))
        return os.date("%A, %B %d, %Y", os.time({ year = year, month = month, day = day })):gsub(" 0", " ")
    end
    return date_str
end

function Meta(m)
    if m.date then
        m.date = format_date(pandoc.utils.stringify(m.date))
    end
    if m.date_end then
        m.date_end = format_date(pandoc.utils.stringify(m.date_end))
    end
    return m
end
