<style>
    #DOLlink{
        cursor:pointer;
        font-size:20px;
        color:#005189
    }
    #AnalysisDataDiv{
        margin-top:1.5% !important;
    }
	.fa-info-circle{
		font-size:18px;
	}
</style>
<cfoutput>
    <div class="row">
        <div class="col-md-6">
        	<a href="javascript:void(0);" onClick="saveDecisionAnalysis();" id="DOLlink">Run decision Optimizer(Required)</a>
			<i class="fa fa-info-circle fa-1x" aria-hidden="true" data-toggle="tooltip" data-placement="right" title="Run Decision Optimizer"></i>
        </div>
    </div>
    <div id="AnalysisDataDiv"></div>
    <div class="row footer-row">
        <div class="col-md-6">
            <input type="button"  name="" id="saveAndExit" value="Save & Exit" class="saveAndExit" onclick='javascript:location.href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/CMS/ClientBridge/ClientBridgeSearchData.cfm?prospect=Y"' class="saveAndExit">
            <input type="button"   name="cancelAndExit" id="cancelAndExit" value="Cancel & Exit" class="cancelAndExit" onclick='javascript:location.href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/CMS/ClientBridge/ClientBridgeSearchData.cfm?prospect=Y"' class="saveAndExit">			 
        </div>
        <div class="col-md-6">
            <input type="button"  name="btnBack" id="btnBack"  	
			<cfif (session.source EQ 'REP' AND session.TargetAccountNumber NEQ '') OR session.Source EQ "Subsequent Checks" >
				onclick='javascript:location. href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/RegBI/sales/sales-main.cfm?step=5&OEUUID=#variables.OEUUID#&LStep=1"'
			<cfelseif session.MaintenanceForms Eq "yes">
				onclick='javascript:location.href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/CMS/ClientBridge/ClientBridgeSearchData.cfm?prospect=Y"'
			<cfelse>
				onclick='javascript:location. href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/RegBI/sales/sales-main.cfm?step=7&OEUUID=#variables.OEUUID#&LStep=1"'
			</cfif>
			 value="Back" class="btnBack btnAction" >		
            <input type="button" name="btnSave" id="btnSave"  
			<cfif (session.source EQ 'REP' AND session.TargetAccountNumber NEQ '') OR session.Source EQ "Subsequent Checks">
				onclick='javascript:location. href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/RegBI/sales/sales-main.cfm?step=5&OEUUID=#variables.OEUUID#&LStep=3"'
			<cfelseif session.MaintenanceForms Eq "yes">
				onclick='javascript:location.href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/CMS/ClientBridge/ClientBridgeSearchData.cfm?prospect=Y"'
			<cfelse>
				onclick='javascript:location. href="https://#GetToken(cgi.server_name, 1, ".")#.planmemberpartners.com/RegBI/sales/sales-main.cfm?step=7&OEUUID=#variables.OEUUID#&LStep=3"'
			</cfif>
			value="Next" class="btnSave btnAction">
        </div>		
    </div>
    <input type="hidden" id="OEUUID" value="#url.OEUUID#">
</cfoutput>
<script>
    function saveDecisionAnalysis(){
	let OEUUID = $('#OEUUID').val();
	SSO_FI360_request();
	$.ajax({
		url: '../Objects/onlineEnrollmentDAO.cfc?method=setAnalysisDecisionDate',
		data: {
			OEUUID: OEUUID
		},
		type: 'post',
		async: false,
		success: function()
		{
			console.log('Decision Date Updated');
		}
	});
	saveDecisionAnalysisDataLoad();
}
function saveDecisionAnalysisDataLoad(){
	let OEUUID = $('#OEUUID').val();
	let loadURL='';
	if(typeof OEUUID !== 'undefined' && OEUUID !== '' && OEUUID !== null){
		loadURL='/RegBI/templates/DecisionOptimizer.cfm?OEUUID='+OEUUID;
	}
	console.log(loadURL);
	if(loadURL){
		$.get(loadURL,function( data ) {
			$('#AnalysisDataDiv').html(data);
		});
	}else{
		console.log('Error: No page load');
	}		
}
function SSO_FI360_request()
{
	let OEUUID = $('#OEUUID').val();
	let url = '/SSO/Broadridge/BroadridgeSSO.cfm';
	window.open( url + "?oeuuid=" + OEUUID, "_blank");
}
</script>