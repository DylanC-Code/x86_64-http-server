set disassembly-flavor intel


#break http_handle_request

#break   parse_body
#commands
#    x/db $rsi
#    x/20cb $rsi + 1
#end


#break parse_body
#commands
#    display/10i $rip
#end

#break parse_content_length
#commands
#    display/20cb  $rdi + $rcx
#    display/d $rcx
#    display/d $rdx
#end

break get_content_len
commands
    display/10i $rip
end

#break parse_content_length
#commands
#    display/10i $rip
#end

run
