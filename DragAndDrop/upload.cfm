<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
	<script src="dropzone.js"></script>
<style>
	form[name=serviceRequest] #file-dropzone {
    border: 1px dashed #000;
    background-color: #ffff99;
    height: 185px;
    min-height: 0px !important;
    margin: 0px 5px 5px 20px;
	cursor:pointer}
</style>
 <form name="serviceRequest"
		method="post"
		class="form-horizontal"
		role="form"
		enctype="multipart/form-data">
	<div class="sectionFive">
		<div class="row">
			<div class="col-sm-2">
				<div class="dropzone" id="file-dropzone">
					<div class="dz-message">
						<p>Drag and drop files here to upload. Dropping multiple files at once is supported.</p>
						<p>Click here to manually select files.</p>
					</div>
					<span class="fileupload-process hidden">
						<label>Total Progress</label>
						<div id="total-progress" class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
							<div class="progress-bar progress-bar-success" style="width:0%;"></div>
						</div>
					</span>
					
					<div class="table table-striped files hidden" id="previews">
						  <div id="previewTemplate" class="file-row">
							<!-- This is used as the file preview template -->
							<div>
								<span class="preview"><img data-dz-thumbnail /></span>
							</div>
							<div>
								<span class="name" data-dz-name></span>
								<span class="size" data-dz-size></span>
								<strong class="error text-danger" data-dz-errormessage></strong>
							</div>
							<div>
							   
								<div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
									  <div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress></div>
								</div>
							</div>
						  </div>
					</div>
				</div>
			</div>
			<div class="col-sm-9 noPadding">
				 
				<div id="attachments">
 				</div>
			</div>
		</div>
	</div>
</form>
<script>
	Dropzone.autoDiscover = false;
	$(document).ready(function(){
		initDropzone();
	});
	function initDropzone(){
		var previewNode = document.querySelector("#previewTemplate");
		previewNode.id = "";
		var previewTemplate = previewNode.parentNode.innerHTML;
		previewNode.parentNode.removeChild(previewNode);

		$('form[name=serviceRequest]').dropzone({
			url: "postFile.cfm"
			,maxFilesize: 100
			,paramName: "selectedFile"
			,createImageThumbnails: true
			,clickable: "#file-dropzone"
			,previewTemplate: previewTemplate
			,previewsContainer: "#previews" 
			,init: function() {
				this.on('success', function(file, json) { // file uploaded complete
					returnData = jQuery.parseJSON(json);
					systemFile = returnData.DATA.SYSTEMFILE[0];
					
					if (systemFile != 'error'){
						//checkFileType(systemFile,file.name);
					}
					else {
						alert('An error occurred while trying to upload this file.');
						refreshAttachments();
					}
				});
				this.on('addedfile', function(file) {
					dropzoneActivate(this.files.length);
				});
				this.on('drop', function(file) {
					dropzoneActivate(this.files.length);
				});
				this.on('totaluploadprogress', function(progress) {
					var allProgress = 0;
					var allFilesBytes = 0;
					var allSentBytes = 0;
					for(var a=0;a<this.files.length;a++) {
						allFilesBytes = allFilesBytes + this.files[a].size;
						allSentBytes = allSentBytes + this.files[a].upload.bytesSent;
						allProgress = (allSentBytes / allFilesBytes) * 100;
					}
					$('#total-progress .progress-bar').css('width',allProgress  + '%');
				});
				this.on('queuecomplete', function(file) {
					$('.dz-message').removeClass('d-none'); // replace default message
					$('.fileupload-process').addClass('d-none'); // hide total progress bar
					this.removeAllFiles(); // remove all files from queue, if not done, total progress is messed up the next round
				});
			}
		});
	}

	function dropzoneActivate(numFiles){
	$('#previews').removeClass('hidden');
	$('.dz-message').addClass('hidden');
	if (numFiles > 1) { // if uploading more than 1 file, show total progress bar
		$('#total-progress .progress-bar').css('width','0%');
    	$('.fileupload-process').removeClass('hidden');
	}
}
</script>