-- Sample input:
-- {
--     "message": "Reloading user from user provider.",
--     "context": [
--     ],
--     "level": 100,
--     "level_name": "DEBUG",
--     "channel": "security",
--     "datetime": {
--         "date": "2014-05-23 14:19:19",
--         "timezone_type": 3,
--         "timezone": "UTC"
--     },
--     "extra": {
--         "url": "\/app_dev.php\/",
--         "ip": "127.0.0.1",
--         "http_method": "GET",
--         "server": "connect.product.localhost",
--         "referrer": null
--     }
-- }

require "cjson"
local dt = require "date_time"
require "string"

local msg_type = read_config("type")
local msg_hostname = read_config("hostname")
local msg_facet = read_config("facet")
local msg_server = read_config("server")
local grammar = dt.build_strftime_grammar("%Y-%m-%d %H:%M:%S")
local severity_map = {
    DEBUG = 7,
    INFO = 6,
    NOTICE = 5,
    WARNING = 4,
    ERROR = 3,
    CRITICAL = 2,
    ALERT = 1,
    EMERGENCY = 0
}

local msg = {
    Fields = {
        Context = nil,
        Extra = nil,
        LogUuid = nil,
        Facet = msg_facet,
        Server = msg_server
    },
    Hostname = msg_hostname,
    Payload = nil,
    Timestamp = nil,
    Type = msg_type
}

function process_message()
    local payload = read_message("Payload");

    local ok, json = pcall(cjson.decode, payload)
    if not ok then return -1 end

    msg.Severity = severity_map[json.level_name]
    msg.Logger = json.channel
    msg.Payload = json.message
    msg.Fields.SeverityText = json.level_name
    msg.Fields.Context = cjson.encode(json.context)
    if json.extra.uuid then
        msg.Fields.LogUuid = json.extra.uuid
        json.extra.uuid = nil
    end
    msg.Fields.Extra = cjson.encode(json.extra)

    local d = grammar:match(json.datetime.date)
    if d then
        -- WARNING: the date should be in UTC
        msg.Timestamp = dt.time_to_ns(d)
    else
        error('unable to decode datetime')
    end

    local ok = pcall(inject_message, msg)
    if not ok then return -1 end

    return 0
end
