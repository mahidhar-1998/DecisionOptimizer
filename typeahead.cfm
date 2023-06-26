<script src="https://cdn.jsdelivr.net/typeahead.js/0.9.3/typeahead.min.js"></script>
<script>
$('#DocumentType').typeahead({
    name : 'search',
    limit: 10,
    minLength: 3,
    remote: {
        url : '../MyDocs_v1/searchdocumenttypes.cfm?query=%QUERY'		
    },
});
</script>

<cfquery name="clientScans" datasource="#application.OES#">
    SELECT DISTINCT FORM_ShortName FROM OES.dbo.OES_Forms WHERE FORM_ShortName LIKE <cfqueryparam value="%#URL.Query#%" cfsqltype="cf_sql_varchar">
</cfquery>
<cfloop query="clientScans">
    <cfset myStruct = StructNew() />
    <cfset myStruct["data"] = clientScans.FORM_ShortName />
    <cfset myStruct["value"] = clientScans.FORM_ShortName />
    <cfset ArrayAppend(DocumentArray, myStruct) />
</cfloop>

<CFOUTPUT>#SerializeJSON(DocumentArray,true)#</CFOUTPUT>