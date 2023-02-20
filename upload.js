$('#uploadExcelLink').click(function(){
		$('#uploadExcelDoc').trigger('click'); 
	});

	$("#uploadExcelDoc").change(function()
		{
			var val = $(this).val();
			var Extension=val.substring(val.lastIndexOf('.') + 1).toLowerCase();
			if (Extension == "xlsx" || Extension == "xls")
			{
				var form = $(this)[0].files[0];
	
				var data = new FormData();
				data.append('UPLOADDOCUMENT',form);
				data.append('uploadDoc', form.name);
				data.append('DocumentName', 'uploadBucksData');
				data.append('DocumentType', 'PMBucks');
				data.append('Extension', Extension);

				$.ajax({
					type: "POST",
					enctype: 'multipart/form-data',
					url: "/PMBucks/functions.cfc?method=ReadExcelInfo",
					data: data,
					processData: false,
					contentType: false,
					cache: false,
					success: function(data)
					{
						loadShowUsers();
					},
					error: function(xhr)
					{
						console.log('Sorry, there was an error:' + xhr.responseText);
					}
				});
			}
			else
			{
				alert('Please upload xls/xlsx Files only');
			}
		});