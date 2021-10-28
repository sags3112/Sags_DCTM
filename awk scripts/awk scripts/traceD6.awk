#
#
# File:	 	traceD6 (trace rpc list)
#
# Synopsis:	analyzes the DFC rpc portion of the trace and spits out
#		a running list of RPCs with their thread, rpc name, response time,
#		and timeofday stamp.
#		if the operation had a query then its information is also provided.
#
#		
#
# Notes:	
#
#
#		the dfc settings expected by this analysis program include:
#
#		dfc.tracing.enable=true
#		dfc.tracing.verbose=true
#		dfc.tracing.verbosity=verbose
#		dfc.tracing.max_stack_depth=0
#		dfc.tracing.include_rpcs=true
#		dfc.tracing.mode=compact
#		dfc.tracing.include_session_id=true
#		dfc.tracing.dir=c:/temp/trace
#
#		notes: 
#			- tested with DFC build 6.0.0.76
#			- the response times in the "compact" mode can be flakey (if calls per thread are 
#			assumed to be synchronous for a given session). I'm checking on this..
#		
#
# 
#
# Date:		6/3/2007
# version:	2.0 
#


BEGIN{
	first_date = "none";
	print "analysis program version 2 based on DFC build 6.0.0.76"
}
/./ { rpc = "foo"; query_str = ""; }
/.RPC: applyForObject/ {
	pos = index($0, "applyForObject");
	endpos = index($0, ",");
	rpc = substr($0, pos+15, endpos-(pos+15));
	if (rpc != "null") 
		rpc = substr(rpc, 2, length(rpc)-2);
	if (rpc == "AUTHENTICATE_USER") {
		ui = index($0, "LOGON_NAME=");
		un1 = substr($0, ui+11, 100);
		ui = index(un1, ",");
		user = substr(un1, 0, ui-1);
		query_str = user
	}
	if (rpc == "SysObjFullFetch" || rpc == "FETCH_CONTENT") {
		oi = index($0, "DfId");
		objectid = substr($0, oi+5, 16);
		query_str = objectid;
	}
	

	
}

/.RPC: multiNext/ {
	
	rpc = "multiNext";
	#print "found rpc = " rpc
}

/.RPC: applyForCollection/ {
	if (index($0, "EXEC") > 0 ) {
		rpc = "EXEC_QUERY";
		qi = index($0, "QUERY=");
		qs = substr($0, qi, 2048);
		qi = index(qs, "FOR_UPDATE");
		query_str = substr(qs, 7, qi-9);
		#print "found query = " query_str
		if (length(query_str) < 5) {
			print "bad query = " $0
		}
		
	} else {
		rpc = "GET_ERRORS";
	}
	
	
	
}
/.RPC: getBlock/ {
	rpc = "getBlock";
}
/.RPC: fetchType/ {
	rpc = "Fetchtype";
	oi = index($0, "fetchType");
	ft = substr($0, oi+11, 30);
	oi = index(ft, ",");
	type = substr(ft, 0, oi-2);
	query_str = type;
	
}
/.RPC: applyForTime/ {
	rpc = "applyForTime";
}
/.RPC: newSessionByAddr/ {
	rpc = "newSessionByAddr";
}
/.RPC: applyForInt/ {
#	rpc = "applyForInt";
	pos = index($0, "applyForInt");
	endpos = index($0, ",");
	rpc = substr($0, pos+15, endpos-(pos+15));
	if (rpc != "null") 
		rpc = substr(rpc, 2, length(rpc)-2);
}
/.RPC: applyForBool/ {
#	rpc = "applyForInt";
	pos = index($0, "applyForBool");
	endpos = index($0, ",");
	rpc = substr($0, pos+15, endpos-(pos+15));
	if (rpc != "null") 
		rpc = substr(rpc, 2, length(rpc)-2);
}
/RPC: closeSession/ {
	rpc = "closeSession";
}
/ .RPC:/ {
		print $1 " & " $2 " & " $4 " & " rpc "  " query_str
		#print "found rpc = " rpc

		
		
}




END {
	

}



