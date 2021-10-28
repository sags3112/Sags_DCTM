#
#
# File:	 	trace_rpc_histD6 (trace rpc histogram)
#
# Synopsis:	analyzes the DFC rpc portion of the trace and creates a 
#		profile (or histogram) of calls and times. It outputs 
#		a profile for server rpcs. In addition, a sorted list of 
#		queries will be printed (descending)
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
# Author:	Ed Bueche
#
# Date:		6/3/2007
# version:	2.0 
#

function sort(ARRAY, ARRAY2, ELEMENTS,   temp, i, j) { 
	
        for (i = 2; i <= ELEMENTS; ++i) {
                for (j = i; ARRAY[j-1] < ARRAY[j]; --j) {
			
			#print "swap a[" j-1 "] = " ARRAY[j-1] " with a[" j "] = " ARRAY[j]
                        temp = ARRAY[j]
                        ARRAY[j] = ARRAY[j-1]
                        ARRAY[j-1] = temp

			temp = ARRAY2[j]
			ARRAY2[j] = ARRAY2[j-1]
                        ARRAY2[j-1] = temp
			if (j == 1) break;
			
                }
        }
	#print "done sorting"
        return
}
BEGIN{
	first_date = "none";
}
/./ { rpc = "foo"; }
/.RPC: applyForObject/ {
	pos = index($0, "applyForObject");
	endpos = index($0, ",");
	rpc = substr($0, pos+15, endpos-(pos+15));
	if (rpc != "null") 
		rpc = substr(rpc, 2, length(rpc)-2);
	
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
		query_resp[cnt] = $2;
		query[cnt] = 	query_str;
		cnt++;
	} else {
		rpc = "GET_ERRORS";
	}
	
	
	
}
/.RPC: getBlock/ {
	rpc = "getBlock";
}
/.RPC: fetchType/ {
	rpc = "Fetchtype";
	
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

		#print "found rpc = " rpc
		if (rpc == "foo") {
			print "unknown RPC = " $0
		}

		rpc_calls[rpc]++;
		rpc_time[rpc] += $2 ;
		total_rpc_time += $2;
		rpc_name[rpc] = rpc;


		if (first_date == "none" ) {
			first_date = $1
			st_tms = $1;
		}
		#current_date = $1 " " $2
		curr_tms = $1;
		if (threads[$4] != 1) {
			threads[$4] = 1;
			thread_cnt++;
		}
		if (connections[conn] != 1) {
			connections[conn] = 1;	
			connect_cnt++;
		}
		block[ $4] = block[$4] "\n\t" $2 "  " rpc "   " conn ;
		dfc_block_rpc_cnt[conn] ++;
		
		
}

/obtained from pool/ {
	si = index($0, "id=");
	ss = substr($0, si, 5);
	se = index(ss, ",");
	conn = substr(ss, 4, se-4);
	#print "session id = " conn
}
/returned to pool/ {
	
	rpc_last_message[ conn ] = $3;
}
/.INFO: Session/ {
	if ($10 == "created") {
		
	}

}



END {
	
	print "****** TRACE_RPC_HIST (D6 VERSION) ****\n"
	#printf ("START DATE:\t%25s\n", first_date)
	#printf ("ENDING DATE:\t%25s\n", current_date)
	printf ("DURATION (secs):\t%17.3f\n", ((curr_tms - st_tms)) );
	printf ("TIME SPENT EXECUTING RPCs (secs):%8.3f (which is %3.2f percent of total time)\n", total_rpc_time, 100*total_rpc_time/(curr_tms - st_tms));
	printf ("Threads :\t%25d\n", thread_cnt);
	printf ("Connections :\t%25d\n", connect_cnt);
	
	
	print "\n****** PROFILE OF rpc CALLS *****"
	printf("\n\n\n%10s\t%10s\t%5s\t%10s\n", "TOTAL TIME", "AVERAGE TIME (secs)", "CALLS", "RPC NAME");
	for (i in rpc_name ) {
		if (rpc_calls[i] > 0 ) {
			printf("%10.3f\t%10.3f\t%10d\t%s\n", rpc_time[i], (rpc_time[i]/rpc_calls[i]), rpc_calls[i], i  ); 
			rpc_total += rpc_time[i];
		} else {
			print "warning: rpc calls = " rpc_calls[i] " for " i
		}
	}
	#print "check: total method time = " meth_total "  total rpc_time = " rpc_total


	sort(query_resp, query, cnt,   temp, i, j) ;

	print "\n**** QUERY RESPONSE SORTED IN DESCENDING ORDER ****\n"
	printf("\nqry rsp\tquery\n");
	for (j = 0; j<cnt; j++) {
		printf("%3.3f\t%s\n", query_resp[j], query[j]);
	}
}


