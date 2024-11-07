using Revise
using AtlansApi
using JSON3
using HTTP


function post_request(url, headers, payload)
    try
        response = HTTP.post(url, headers, payload)
        return response
    catch e
        return e
    end
end


payload = AtlansApi.SAMPLE_PAYLOAD
url = "http://127.0.0.1:8081/run"
headers = ["Content-Type" => "application/json"]

result = post_request(url, headers, payload)

println("Response: ", String(result.body))
