<cfparam name="form.selectedFile" default="">
<cfset variables.returnData = QueryNew("systemFile","varchar")>
<cfset queryAddRow(variables.returnData)>

<cftry>
	<cfset variables.systemFile = createUUID()>

	<cffile action = "upload"
		destination = "#expandpath("./uploads")#"
		fileField = "selectedFile"
		nameConflict = "makeunique">
		
	<cfset querySetCell(variables.returnData,"systemFile",variables.systemFile)>

	<cfcatch>
        <cfdump var="#cfcatch#" abort />
		<cfset querySetCell(variables.returnData,"systemFile","error")>
	</cfcatch>
</cftry>

<cfoutput>
	#serializeJSON(variables.returnData,"true")#
</cfoutput>