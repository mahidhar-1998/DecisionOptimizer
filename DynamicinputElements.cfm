<cfparam name="URL.OESID" default="0">

<cfoutput>
	<div class="mainContainer">
		<cfloop from="1" to="5" index="k">
			<div class="row oesInfo#k#" style="margin-left: 2px;margin-top: 10px; <cfif k GT 1>display: none;</cfif>">
				<div class="col-sm-3">
					<div class="input-group">
						<input type="text"
							autocomplete="false"
							class="form-control OESID"
							id="oesid_#k#"
							name="OESID_#k#"
							placeholder="OESID"
							<!--- onKeyPress="associateOESHint(this);" --->
							onKeyUp="return numbersOnly(this);"
							onblur="checkAssociateOES(this);">
						<span class="clickable input-group-text oesBtn hidden">
							<span class="fas fa-check"></span>
						</span>
					</div>
				</div>
				<div class="col-sm-9">
					<div class="input-group">
						<!--- <span class="input-group-btn"> --->
				  			<input type="text" class="form-control oesNotes" name="oesNotes_#k#" id="oesNotes_#k#" placeholder="Notes">
							<button class="btn btn-info dupButton input-group-btn" type="button" onclick="duplicateInfo(#k#);">
								<i class="fas fa-plus"></i>
							</button>
							<button class="btn btn-danger input-group-btn deleteButton <cfif k EQ 1>hidden</cfif>" type="button" onclick="deleteDiv(#k#);">
								<i class="fas fa-close"></i> 
							</button>
						<!--- </span> --->
					</div>
				</div>
			</div>
		</cfloop>
	</div>
	<br>
	<div class="row">
		<div class="col-sm-12 text-end">
			<!--- <button class="btn btn-primary" id="attachOESBtn" type="button" onclick="postAssociatedOES(#url.OESID#);" id="associatedoes"> --->
			<button class="btn btn-primary" type="button" onclick="postAssociatedOES(#url.OESID#);" id="associatedoes">
				SUBMIT 
			</button>
		</div>
	</div>
</cfoutput>
<script>
function duplicateInfo(rowvalue){
	var nextrow = rowvalue+1;
	$(".oesInfo"+nextrow).show();
	$(".oesInfo"+rowvalue).find('.dupButton').addClass('hidden');
	$(".oesInfo"+rowvalue).find('.deleteButton').removeClass('hidden');
	
}

function deleteDiv(getrow){
	$(".oesInfo"+getrow).hide();
	if(getrow > 1){
		var prevrow = getrow-1;
		$(".oesInfo"+prevrow).find('.dupButton').removeClass('hidden');
	}
	if(getrow == 2){
		var prevrow = getrow-1;
		$(".oesInfo"+prevrow).find('.deleteButton').addClass('hidden');
	}
}

function postAssociatedOES(oesIdVal) {
	var errors = 0;
	var errorMsg = '';
	for(var i=1 ; i<6 ; i++){
		if($(".oesInfo"+i).is(":visible")){
			if ($("#oesid_"+i).val() == '' ){
				errors = errors + 1;
				errorMsg ='OES id required\n';
				$("#oesid_"+i).focus();
			}
		}
	}
	if (errors > 0) {
		setTimeout(function() {
			alert(errorMsg);
		}, 100);
	}
	else {
		var assOesInfoArray = []; 
		for (var i = 1; i < 6; i++) {
			assOesInfoArray[i] = [];
			assOesInfoArray[i][0] = $("#oesid_"+i).val();
			assOesInfoArray[i][1] = $("#oesNotes_"+i).val();
			assOesInfoArray[i][2] = '0';// ensure there is at least one value in the JSON - my cf dev machine freaks out with an empty JSON string
		}
		$.post('../COM/oesDAO.cfc', { 
			method: 'associatedOesInfo'
			,oesID: oesIdVal
			,assInfoJSON: JSON.stringify(assOesInfoArray)
		}, function(returnData) {
				alert('The associated OES added successfully');
				$('#accosictedOESList').html('');
				$.ajax({
				url: '/readOnly/associatedOESList.cfm?OESID='+oesIdVal,
				type: 'get',
				data: 'none',
				contentType: false,
				cache: false,
				processData: false
				}).done(function(response){
					$('#attachNew').load('/readOnly/associatedOESNew.cfm?OESID='+oesIdVal);
					$('#accosictedOESList').html(response);
			});
		});
	}
}

</script>

<cffunction name="associatedOesInfo" access="remote" returntype="void">
		<cfargument name="oesID" type="numeric" required="Yes">
		<cfargument name="assInfoJSON" type="any" default="">
		

		<cfif isJSON(arguments.assInfoJSON)>
			<cfset local.data = deserializeJSON(arguments.assInfoJSON)>

			<cfloop from="2" to="#arrayLen(local.data)#" index="row">
				<cfif local.data[row][1] GT 0>
					<cfquery name="postData" datasource="#application.SQLWEB_Write#">
						INSERT INTO [OES].[dbo].[associated_oesInfo]
						([oesId]
						,[associatedOESId]
						,[oesNotes])
						VALUES
						(<cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(arguments.oesID)#">
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(local.data[row][1])#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LEFT(TRIM(local.data[row][2]),255)#">)
					</cfquery>
				</cfif>
			</cfloop>

		</cfif>

	</cffunction>