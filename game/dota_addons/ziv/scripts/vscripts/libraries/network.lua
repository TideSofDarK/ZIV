SU = {}

SU.STAT_SETTINGS = LoadKeyValues('scripts/kv/StatUploaderSettings.kv')
SU.is_stat_server_up = true

-- Request function
function SU:SendRequest( request_params, success_callback )
  if not SU.is_stat_server_up then
    return
  end
  
  -- Adding auth key
  request_params.AuthKey = SU.STAT_SETTINGS.AuthKey
  -- DeepPrintTable(request_params)

  -- Create the request
  local request = CreateHTTPRequest('POST', SU.STAT_SETTINGS.Host)
  request:SetHTTPRequestGetOrPostParameter('CommandParams', json.encode(request_params))

  -- Send the request
  request:Send(function(res)
    if res.StatusCode ~= 200 or not res.Body then
        -- Bad request
        SU.is_stat_server_up = false
        
        print("Request error. See info below: ")
        DeepPrintTable(res)
        return
    end

    -- Try to decode the result
    local obj, pos, err = json.decode(res.Body, 1, nil)
    
    -- if not a JSON send full body
    if obj == nil then
      obj = res.Body
    end
    
    -- Feed the result into our callback
    success_callback(obj)
  end)
end

function SU:SendAuthInfo()
  CustomGameEventManager:Send_ServerToAllClients("su_auth_params", { URL = SU.STAT_SETTINGS.Host, AuthKey = SU.STAT_SETTINGS.AuthKey } )
end

-------------------------------------------------------------------------------
-- Testing functions
-------------------------------------------------------------------------------

function SU:Test()
  local request_params = {
    Command = "Testing"
  }
    
  SU:SendRequest( request_params, function(obj)
      print("Testing result: ", obj)
  end)
end

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------
table.filter = function(t, filter_iter)
  local out = {}

  for k, v in pairs(t) do
    if filter_iter(k, v, t) then out[k] = v end
  end

  return out
end