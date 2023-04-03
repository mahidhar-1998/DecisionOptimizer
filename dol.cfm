<cfloop query="attachedOES">
	<div class="row associatedOES" id="oes#VAL(attachedOES.currentRow)#">
		<div class="col-sm-3">
			<div class="input-group">
				<input type="text"
					class="form-control form-control-md OESID"
					name="OESID"
					autocomplete="false"
					placeholder="OES ID"
					<cfif VAL(attachedOES.OESID) GT 0>
						value="#VAL(attachedOES.OESID)#"
						readonly="true"
					</cfif>
					onKeyPress="oesHint(this);"
					onKeyUp="return numbersOnly(this);"
					onblur="checkOES(this);">
				<span class="clickable input-group-text oesBtn<cfif VAL(attachedOES.OESID) EQ 0> d-none</cfif>"
					onClick="oesInfo(this)">
					<span class="fas fa-check"></span>
				</span>
			</div>
		</div>
		<div class="col-sm-<cfif VAL(attachedOES.ref) EQ 0>7<cfelse>9</cfif>">
			<input type="text"
				class="form-control form-control-md"
				name="OESNotes"
				placeholder="Notes"
				<cfif VAL(attachedOES.ref) GT 0>
					readonly="true"
				</cfif>
				value="#TRIM(attachedOES.notes)#">
		</div>
		<cfif VAL(url.requestID) EQ 0 AND VAL(attachedOES.ref) EQ 0>
			<div class="col-sm-2">
				<span class="input-group-btn">
					<button class="btn btn-default btn-outline-secondary dupButton" type="button" onClick="duplicateInfo('associatedOES');">
						<span class="fas fa-plus"></span>
					</button>
					<button class="btn btn-default btn-outline-danger deleteButton d-none"
						type="button"
						onClick="deleteDiv($('##oes#VAL(attachedOES.currentRow)#'),'associatedOES')">
						<span class="fas fa-times"></span>
					</button>
				</span>
			</div>
		</cfif>
	</div>
</cfloop>
<script>
function duplicateInfo(objClass) { // duplicate object by parent class
	var lastObj = $('.' + objClass).first();
	var newObj = $(lastObj).clone();
	var dupIdentifier = "_dup_";
	var newID = makeID();
	
	$('#' + $(lastObj).attr('id') + ' .dupButton').addClass('d-none');
	$('#' + $(lastObj).attr('id') + ' .deleteButton').removeClass('d-none');

	$(newObj).attr('id',newID).insertAfter(lastObj);
	
	// find each input or select item and renames with a new ID
	$(newObj).find('input').each(function(){
		$(this).val('');
		});
	$(newObj).find('select').each(function(){
		$(this).val('');
		});
		
	var deleteFunction =  "deleteDiv($('#" + newID + "'),'" + objClass + "');";
	$('#' + newID + ' .deleteButton').unbind('click').attr('onclick',deleteFunction).removeClass('d-none');
	
	return newObj;
}

function deleteDiv(obj,objClass) { // remove duplicated fields
	$(obj).remove();
	$('.' + objClass + ' .dupButton').last().removeClass('d-none');
	if ($('.' + objClass).length == 1) {
		$('.' + objClass + ' .deleteButton').addClass('d-none');
		$('.' + objClass + ' .dupButton').removeClass('d-none');
	}
}

function makeID() { // creates a random string used for dup fields
	var randomID = "";
	var possible = "0123456789";
	for( var i=0; i < 20; i++ )
		randomID += possible.charAt(Math.floor(Math.random() * possible.length));
    return randomID;
}
</script>