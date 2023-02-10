<cfinclude template="../sessionTimeout.cfm" />

<cfquery name="GetUsers" datasource="#application.datasource#">
	SELECT PL.ref, PL.LastName, PL.FirstName, PL.PMBuckBalance
	FROM planmemberpartnersdb.dbo.PartnerLogin PL
	INNER JOIN planmemberpartnersdb.dbo.PartnerLoginPERMISSIONS PLP ON PL.ref = PLP.UserID
	INNER JOIN planmemberpartnersdb.dbo.RepLoginID RL ON RL.partnerID = PL.ref
	INNER JOIN planmemberpartnersdb.dbo.cms2User C ON C.UserID = RL.UserID
	WHERE PLP.Affiliation = 2
		AND C.Status = 'Active'
	ORDER BY PL.LastName, PL.FirstName, PL.ref
</cfquery>

<cfsaveContent variable="xlsContent">
	<cfoutput query="GetUsers" group="ref">#lastName#[tab]#firstName#[tab]#dollarFormat(PMBuckBalance)#[rtn]</cfoutput>
</cfsaveContent>

<cfset xlsContent = replace(xlsContent,"[tab]",chr(9),"ALL") />
<cfset xlsContent = replace(xlsContent,"[rtn]",chr(13),"ALL") />

<cfset filePath = expandPath('.') />
<cfset fileName = "PMBuckExport_#DateFormat(now(),"mmmddyyyy")#.xls" />

<cffile action = "write"
		file = "#filePath#\#fileName#"
		output = "#xlsContent#"
		nameconflict="overwrite" />

<cfheader name="content-disposition" value="attachment;filename=#fileName#" /> 
<cfcontent type="application/vnd.ms-excel"
		   file="#filePath#\#fileName#"
		   deleteFile = "Yes" />