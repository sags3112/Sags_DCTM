#
#
# File:	 	object_breakdown.awk (trace rpc histogram)
#
# Synopsis:	This creates a histogram of the type of objects fetched
#		in the trace.  
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
#
#		
#
# Author:	Dan Hata
#
# Date:		1/18/2010
# version:	1.0 
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

/SysObjFullFetch/{
if (index($0, "SysObjFullFetch") > 0 )
	pos = index($0, "OBJECT_TYPE=");
	endpos = index($0, ", FOR_");
	rpc = substr($0, pos+12, endpos-(pos+12));
	if (rpc == null){
	pos = index($0, "type=");
	endpos = index($0, ", readOnly");
	rpc = substr($0, pos+5, endpos-(pos+5));
	}

	rpc = "SysObjFullFetch_"rpc;

}
		



	

/IsCurrent/{
if (index($0, "IsCurrent") > 0 )
	pos = index($0, "OBJECT_TYPE=");
	endpos = index($0, ", i_vstamp");
	rpc = substr($0, pos+12, endpos-(pos+12));
	rpc = "IsCurrent_"rpc;

	
}	
				
	





/ .RPC:/ {

		#print "found rpc = " rpc
		if (rpc == "foo") {
			#print "unknown RPC = " $0
		}

		rpc_calls[rpc]++;
		rpc_time[rpc] += $2 ;
		total_rpc_time += $2;
		rpc_name[rpc] = rpc;


		if (first_date == "none" ) {
			first_date = $1
			st_tms = $1;
		}
		
		
}





END {
	#CALCULATE THE TOTAL NUMBER OF SYSOBJFULLFETCHES
		for (i in rpc_name ) {
	if (rpc_calls[i] > 0 && (i != "foo") && (substr(i,0,3)=="Sys")){
		
			SysObjFullFetchCount++;
			SysObjFullFetchTotal=SysObjFullFetchTotal+rpc_calls[i];
		} 
	}
	
	#PRINT OUT RESULTS FOR SYSOBJFULLFETCH
	print "****** Total number of object fetches per type *****"
	print SysObjFullFetchCount " Unique Object Types Fetched"
	print SysObjFullFetchTotal " Total Objects Fetched"
	printf("%s\t%5s\n", "Fetches", "Type");
	

	for (i in rpc_name ) {
	if (rpc_calls[i] > 0 && (i != "foo") && (substr(i,0,3)=="Sys")){
		
			printf("%5d\t%s\n", rpc_calls[i], substr(i,17)); 
		} 
	}
	
	
	
		#CALCULATE THE TOTAL NUMBER OF ISCURRENTS
		for (i in rpc_name ) {
	if (rpc_calls[i] > 0 && (i != "foo") && (substr(i,0,3)=="IsC")){
		
			IsCurrentFetchCount++;
			IsCurrentTotal=IsCurrentTotal+rpc_calls[i];
		} 
	}
	
	
	
	print "\n****** Total number of iscurrent calls per type *****"
	print IsCurrentFetchCount " Unique Object Types IsCurrent Called"
	print IsCurrentTotal " Total IsCurrent Calls"
	printf("%s\t%5s\n", "Fetches", "Type");
	

	for (i in rpc_name ) {
		if (rpc_calls[i] > 0 && (i != "foo") && (substr(i,0,3)=="IsC")) {
		
		printf("%5d\t%s\n", rpc_calls[i], substr(i,11)  ); 
			
		} 
	}

	
}


