<!--- AutoQueryParam updated this file 04-03-2017 13:35:16 --->
<cfparam name="url.affiliate" default="">
<!DOCTYPE html>
<html>
<head>
	<title>PM Partners Login</title>
	<meta name="LoadBalancerServer" content="<cfoutput>#application.LoadBalancerServer#</cfoutput>">
</head>
<body>
<cftry>

	<cfset errorHashed = HASH(lCase(Error.Diagnostics))>
	<cfset serverName = replace(LEFT(server_name,50),"www.","","all")>
	<cfif application.LoadBalancerServer NEQ "?">
		<cfset servername = LEFT(serverName &  "-" & application.LoadBalancerServer,50)>
	</cfif>

	<cfset errorMsg = error.Diagnostics>
	<cfif ArrayLen(error.TagContext)>
		<cfset ErrorMsg = ErrorMsg & "<br><br>This error is called from:<br>">
		<cfloop from="1" to="#ArrayLen(error.TagContext)#" index="i">
			<cfset ErrorMsg = ErrorMsg & " " & i & " " & error.TagContext[i].template & " line " & error.TagContext[i].line & "<br>">
		</cfloop>
	</cfif>

	<!--- determine if this is a new or existing error --->
	<cfquery name="checkErrors" datasource="SQLWEB_Write">
		SELECT TOP 1 errorID, fixTime 
		FROM ErrorHandler.dbo.errors
		WHERE errorHashed = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#errorHashed#">
		AND Server = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#serverName#">
		AND Template = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(Error.Template,255)#">
	</cfquery>

	<!--- error type --->
	<cfif checkErrors.recordCount EQ 0><!--- new error --->

		<cfquery datasource="SQLWEB_Write" result="result">
			INSERT INTO ErrorHandler.dbo.Errors
			(
					errorHashed, 
					Server, 
					Template, 
					ErrorMessage
			) 
			VALUES
			(
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#errorHashed#">, 
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(serverName,50)#">, 
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(Error.Template,255)#">, 
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#errorMsg#">
			);
		</cfquery>
		<cfset errorID = result.identityCol>

	<cfelse><!--- existing error --->

		<cfset errorID = checkErrors.errorID>
		<cfquery datasource="SQLWEB_Write">
			<cfif NOT isDate(checkErrors.FixTime)><!--- reopen error --->
				UPDATE ErrorHandler.dbo.errors SET archived=0 WHERE errorID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#VAL(errorID)#">;
			<cfelse>
				INSERT INTO ErrorHandler.dbo.ErrorNotes
				(
					errorID, 
					noteType, 
					postingUser, 
					timeSubmitted, 
					Notes
				) 
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(errorID)#">, 
					0, 
					'System', 
					GETDATE(), 
					'Error reopened'
				);
				UPDATE ErrorHandler.dbo.errors SET fixTime=NULL, devNotified=0, archived=0 WHERE errorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(errorID)#">;
			</cfif>
		</cfquery>
	</cfif>
	<!--- / error type --->

	<cfif isDefined('remote_addr')>
		<cfset userIP = remote_addr>
	<cfelse>
		<cfset userIP = 0>
	</cfif>

	<!--- insert user info --->
	<cfquery datasource="SQLWEB_Write" result="result">
		INSERT INTO ErrorHandler.dbo.error_userInfo
		(
			errorID, 
			ErrorTime, 
			userIP, 
			UserBrowser, 
			HTTPReferer, 
			queryString
		) 
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(errorID)#">, 
			GETDATE(), 
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(userIP,15)#">, 
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(Error.Browser,150)#">, 
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(error.HTTPReferer,255)#">, 
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(error.queryString,255)#">
		);
	</cfquery>
	<cfset userRef = result.identityCol>

<br><br><font face="arial" size="2">The template you were just accessing has experienced an unexpected error.<br>An error message has been sent to the e-Business Services team and we will resolve this problem ASAP.<br>We apologize for any inconvenience.<br><br><b>Error ID #:</b> <cfoutput>#errorID#</cfoutput><br>

<cfoutput>
<iframe src="#application.url#/errorhandler/show.cfm?userRef=#userRef#" width="1" height="1" frameBorder="No"></iframe>
<!-- Error Message

#Replace(errorMsg,"<br>","#chr(13)#","all")#

-->
</cfoutput>

	<cfcatch></cfcatch>
</cftry>
</body>
</html>