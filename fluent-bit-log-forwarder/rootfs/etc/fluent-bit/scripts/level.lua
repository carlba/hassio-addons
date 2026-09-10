function set_level(tag, timestamp, record)
    if record["MESSAGE"] and string.find(record["MESSAGE"], "Out of memory: Killed process", 1, true) then
        record["level"] = "error"
    end
    return 1, timestamp, record
end
