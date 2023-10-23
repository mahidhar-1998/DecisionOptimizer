<cfinclude template="/SessionTimeOUT.cfm">
<cfparam name="variables.ClientFileName" default=""/>
<cftry>
	<cfset variables.pdfloc = Decrypt(trim(URLDecode(url.pdfloc)), application.EncryptionKey, "CFMX_COMPAT", "HEX")>

	<cfset variables.FilePath = ListFirst(variables.pdfloc, "|")/>
<!--- 	 <cfdump var="#variables.FilePath#" abort>   --->
	<cfset variables.FileName = ListLast(variables.FilePath, "\")/>
	<cfset variables.FileExtension = ListLast(variables.FileName, ".")/>
	<cfset variables.ClientFileName = ListLast(variables.pdfloc, "|")/>
	
	<cfif variables.ClientFileName EQ "">
		<cfset variables.ClientFileName = variables.FileName />
	</cfif>
 
	<cfif FileExists(variables.FilePath)>
		<cfswitch expression="#variables.FileExtension#">
			<cfcase value="xls,csv,xlsx">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#variables.ClientFileName#">
				<cfcontent type="application/msexcel" variable="#variables.fileContent#" reset="yes">  			
			</cfcase>
			<cfcase value="doc,docx">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#variables.ClientFileName#">    
				<cfcontent type="application/msword" variable="#variables.fileContent#">  			
			</cfcase>
			<cfcase value="rtf">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#"> 
				<cfcontent type="application/rtf" variable="#variables.fileContent#">  			
			</cfcase>
			<cfcase value="txt">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#">     
				<cfcontent type="text/plain" variable="#variables.fileContent#">  				
			</cfcase>
			<cfcase value="ppt">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#"> 
				<cfcontent type="application/ppt" variable="#variables.fileContent#"> 						
			</cfcase>
			<cfcase value="pps">
      	<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
      	<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#"> 
      	<cfcontent type="application/pps" variable="#variables.fileContent#">  			
			</cfcase>
			<cfcase value="mp3">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#">     
				<cfcontent type="application/mp3" variable="#variables.fileContent#">  
			</cfcase>
			<cfcase value="wma">
				<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
				<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#">     
				<cfcontent type="application/wma" variable="#variables.fileContent#">  					
			</cfcase>
			<cfcase value="tif">
      	<cffile action="readBinary" file="#variables.FilePath#" variable="variables.fileContent">
      	<cfheader name="Content-disposition" value="attachment;filename=#trim(filename)#">       
      	<cfcontent type="image/tif" variable="#variables.fileContent#">  			
			</cfcase>
			<cfcase value="jpg,jpeg,png">
				<cfimage source="#variables.FilePath#" action="writeToBrowser">			
			</cfcase>
			<cfcase value="pdf">
				<cffile action = "readBinary" file="#variables.FilePath#" variable="variables.fileContent"/>
				<cfheader name="Content-Disposition" value="inline; filename=#variables.ClientFileName#" />
				<cfcontent type="application/pdf" variable="#variables.fileContent#" />			
			</cfcase>
			<cfcase value="zip">
				<cfheader name="Content-Disposition" value="attachment; filename=#ReplaceNoCase(variables.ClientFileName, " ", "_", "all")#">
				<cfcontent file="#variables.FilePath#" type="application/zip">	
			</cfcase>			
			<cfdefaultcase>
				<h1>File format not supported</h1>
				<cflog file="ViewDoc" text="Unsupported file type: #variables.FilePath#"/>
			</cfdefaultcase>
		</cfswitch>
	<cfelse>
		<h3>Document not found</h3><cfoutput>#variables.FilePath#</cfoutput>
	</cfif>
	<cfcatch>
		<cflog file="ViewDoc" text="#variables.pdfloc#"/>
	</cfcatch>
</cftry>
