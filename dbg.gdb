display/20i $rip
display/16xb  (unsigned char*)buffer

break http_handle_request
break is_get

run
