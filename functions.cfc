<cfcomponent>
    <cffunction name="ReadExcelInfo" returntype="any" returnFormat="JSON" access="remote">
        <cfargument name="UPLOADDOCUMENT" type="string" required="false" />
        <cfargument name="uploadDoc" type="string" required="false" />
        <cfargument name="DocumentName" type="string" required="false" />
        <cfargument name="DocumentType" type="string" required="false" />
        <cfargument name="Extension" type="string" required="false" />

        <cfset arguments.UPLOADDOCUMENT = REReplace(arguments.UPLOADDOCUMENT,"[^0-9A-Za-z]","","all") />
        <cfset variables.systemFile = createUUID() />
        <cfset variables.FileServer = '\\' & application.FileServer2 />
        <cfset variables.NASUploads = "#variables.FileServer#\Inetpub\scans.planmember.com\OnlineEnrollment" />
        <cffile action = "upload" 
                destination = "#variables.NASUploads#\#variables.systemFile#.#arguments.Extension#" 
                fileField = "UPLOADDOCUMENT" 
                nameConflict = "overwrite">
                
        <cfset local.fileToOpen = '#variables.NASUploads#\' & cffile.serverfile />

        <cfspreadsheet action="read" 
                    src="#local.fileToOpen#" 
                    query="InsertPMBucksInfo" 
                    excludeHeaderRow="true"
                    headerrow="1">

        <cfset local.resultArr = arraynew(1) />
        <cfset local.fileData = StructNew() />
			 
        <cfloop query="InsertPMBucksInfo">
            <cfset local.details = arrayNew(1) />
            <cfset arrayappend(local.details ,InsertPMBucksInfo['Ref']) /> 
            <cfset arrayappend(local.details ,InsertPMBucksInfo['AddBalance']) />
            <cfset arrayappend(local.details ,InsertPMBucksInfo['SubBalance']) />
            <cfset arrayappend(local.details ,InsertPMBucksInfo['Cap']) />
            <cfset arrayAppend(local.resultArr,local.details) />				 
        </cfloop> 

        <cfloop from="1" to="#arrayLen(local.resultArr)#" index="idx">
            <cfif idx EQ 1>
                <cfset local.fileData.ref = 1 />		<!--- ref --->
				<cfset local.fileData.AddBalance  = 2 />    <!--- Add Balance --->
                <cfset local.fileData.SubBalance  = 3 />    <!---Sub Balance --->
                <cfset local.fileData.cap  = 4 />     <!---Set Cap --->
            </cfif>
             
            <cfset ref = "#local.resultArr[idx][local.fileData.ref]#" />
            <cfset AddBalance = "#local.resultArr[idx][local.fileData.AddBalance]#" />
            <cfset SubBalance = "#local.resultArr[idx][local.fileData.SubBalance]#" />
            <cfset Cap = "#local.resultArr[idx][local.fileData.cap]#" />

            <cfset allowedList = "1,2,3,4,5,6,7,8,9,0,." />
            <cfset postingUser = 0 />
            <cfif isDefined('session.PUBLICUserID')>
                <cfset postingUser = session.PUBLICUserID />
            </cfif>
            <!--- Add Balance --->
            <cfif VAL(AddBalance) NEQ 0 AND AddBalance NEQ "">
                <cfset post = 0 />
                <cfset tempBalance = "" />
                <cfloop index="i" from="1" to="#LEN(AddBalance)#">
                    <cfset this = mid(AddBalance,i,1) />
                    <cfif listFind(allowedList,this) GT 0>
                        <cfset tempBalance = tempBalance & this />
                    </cfif>
                </cfloop>
                <cfset post = 1 />
    
                <cfset balanceMod = VAL(tempBalance) />
                <cfset notes = "Added #DollarFormat(VAL(tempBalance))# to Balance" />

                <cfquery name="CheckBalance" datasource="sqlweb_read">
                    SELECT PMBuckCap, PMBuckBalance
                    FROM planmemberpartnersdb.dbo.PartnerLogin
                    WHERE ref = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ref#">
                </cfquery>
            
                <cfif #CheckBalance.PMBuckBalance# + #VAL(balanceMod)# LTE #CheckBalance.PMBuckCap#>
                    <cfquery datasource="sqlweb_write">
                        UPDATE planmemberpartnersdb.dbo.PartnerLogin
                        SET PMBuckBalance = (PMBuckBalance + <cfqueryparam cfsqltype="cf_sql_float" value="#VAL(balanceMod)#" />)
                        WHERE ref = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ref#">;
                        
                        INSERT INTO planmemberpartnersdb.dbo.PMBucksNotes
                            (userID,
                            dateAdded,
                            amount,
                            Note,
                            postingUser,
                            IsCapAlter)
                        VALUES
                            (<cfqueryparam cfsqltype="cf_sql_integer" value="#ref#" />,
                            GETDATE(),
                            <cfqueryparam cfsqltype="cf_sql_float" value="#VAL(balanceMod)#" />,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#notes#" />,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(postingUser)#" />,
                            1)
                    </cfquery>
                </cfif>
            </cfif>
            <!--- Subtract Balance --->
            <cfif VAL(SubBalance) NEQ 0 AND SubBalance NEQ "">
                <cfset post = 0 />
                <cfset tempBalance = "" />
                <cfset postingUser = 0 />
                <cfloop index="i" from="1" to="#LEN(SubBalance)#">
                    <cfset this = mid(SubBalance,i,1) />
                    <cfif listFind(allowedList,this) GT 0>
                        <cfset tempBalance = tempBalance & this />
                    </cfif>
                </cfloop>
                <cfset post = 1 />
                <cfset balanceMod = (VAL(tempBalance)*-1) />
                <cfset notes = "Subtracted #DollarFormat(VAL(tempBalance))# to Balance" />
		
                <cfquery datasource="sqlweb_write">
                    UPDATE planmemberpartnersdb.dbo.PartnerLogin
                    SET PMBuckBalance = (PMBuckBalance + <cfqueryparam cfsqltype="cf_sql_float" value="#VAL(balanceMod)#" />)
                    WHERE ref = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ref#" />;
                    
                    INSERT INTO planmemberpartnersdb.dbo.PMBucksNotes
                        (userID,
                        dateAdded,
                        amount,
                        Note,
                        postingUser,
                        IsCapAlter)
                    VALUES
                        (<cfqueryparam cfsqltype="cf_sql_integer" value="#ref#" />,
                        GETDATE(),
                        <cfqueryparam cfsqltype="cf_sql_float" value="#VAL(balanceMod)#" />,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#notes#" />,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(postingUser)#" />,
                        1)
                </cfquery>
            </cfif>
             <!---Reset Cap--->
	        <cfif VAL(Cap) NEQ 0 AND Cap NEQ "" >
                <cfset post = 0 />
                <cfset tempBalance = "" />
                <cfloop index="i" from="1" to="#LEN(Cap)#">
                    <cfset this = mid(Cap,i,1) />
                    <cfif listFind(allowedList,this) GT 0>
                        <cfset tempBalance = tempBalance & this />
                    </cfif>
                </cfloop>
                <cfset post = 1 />
                <cfset notes = "Added #DollarFormat(VAL(tempBalance))# to Cap" />
                <cfset newcap = VAL(tempBalance) />
            
                <cfquery datasource="sqlweb_write">
                    UPDATE planmemberpartnersdb.dbo.PartnerLogin
                    SET PMBuckCap = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#VAL(newcap)#" />
                    WHERE ref = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ref#" />;
                    
                    INSERT INTO planmemberpartnersdb.dbo.PMBucksNotes
                        (userID,
                        dateAdded,
                        amount,
                        Note,
                        postingUser,
                        IsCapAlter)
                    VALUES
                        (<cfqueryparam cfsqltype="cf_sql_integer" value="#ref#" />,
                        GETDATE(),
                        <cfqueryparam cfsqltype="cf_sql_float" value="#VAL(newcap)#" />,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#notes#" />,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(postingUser)#" />,
                        1)
                </cfquery>
	        </cfif>
        </cfloop>

    </cffunction>
</cfcomponent>