set disassembly-flavor intel

display/20i $rip

#break http_handle_request

break parse_request
commands
    set $preq = $rsi
    display/2dg $rsi
end

break parse_route

run
