<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>jQuery UI Autocomplete</title>
<link rel="stylesheet" href="//code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
 <script src="https://code.jquery.com/jquery-3.6.0.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
<div class="row ml-5">
  <div class="col-md-3">
    <label>Employee</label>
    <input type="text" class="form-control suggestName">
  </div>
</div>
 <div id="test">

 </div>
<script>
  $(".suggestName").autocomplete({
		source: function(request, response)
		{
			$.ajax({
				url: "/CMS/ClientBridgeReports/AUMReport/cfc/AUMReport.cfc?method=getAUMFundNameTickerJSON",,
				dataType: "json",
				data: {
					searchterm: request.term
				},
				success: function(data)
				{
					response(data);
          
				}
			});
		},
		minLength: 2,
		select: function(event, ui)
		{
      $(".suggestName").val(ui.item.user);
		},
		focus: function(event, ui)
		{
      $('.suggestName').val(ui.item.user)
			return false;
		},
	});
 
  <cffunction name="getAUMFundNameTickerJSON" access="remote" returnFormat="json">
		<cfargument name="searchterm" required="yes" type="string" />

		<cfquery name="local.qGetAUMFundNameTickerJSON" datasource="sqlweb_read">
			SELECT Distinct(Rtrim(LTRIM(Ticker))) Ticker, FundName
			FROM Reports.dbo.AUMFundsData
			WHERE Ticker like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchterm#%" />
		</cfquery>
		<!--- Build result array --->
		<cfset local.returnArray = ArrayNew(1) />
		<cfloop query="local.qGetAUMFundNameTickerJSON">
			<cfset local.titleStruct = structNew() />
			<cfset local.titleStruct['ticker'] = #local.qGetAUMFundNameTickerJSON.Ticker# />
			<cfset local.titleStruct['value'] = '#local.qGetAUMFundNameTickerJSON.Ticker# - #local.qGetAUMFundNameTickerJSON.FundName#' />
			<cfset local.titleStruct['label'] = '#local.qGetAUMFundNameTickerJSON.Ticker# - #local.qGetAUMFundNameTickerJSON.FundName#' />
		 
			<cfset arrayAppend(local.returnArray,local.titleStruct) />
		</cfloop>

		<!--- And return it --->
		<cfreturn local.returnArray />
	</cffunction>
</script>