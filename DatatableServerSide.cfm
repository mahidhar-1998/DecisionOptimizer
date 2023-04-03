function GetAccountStatements(ClientName='',ShowEntireRecords=0){
            $("##AccountstatementsGrid").DataTable({
            	"processing": true,
		        "serverSide": true,
		        "ajax":  {
		            url: "../MyDocs_v1/objects/getData.cfc",
			        type: "POST",
			        data: ({
                        method: 'GetAccountStatements',
			            PlayerID: #URL.PlayerID#,
                        UserType: '#URL.UserType#',
                        ClientName : ClientName,
                        ShowEntireRecords : ShowEntireRecords

			        }),
			        "dataSrc": function ( json ) {
		                return json.data;
		            }       
		        },
                "lengthChange": false,
                "lengthMenu": [10],
                "searching": true,
                "order": [[ 1, "desc" ]],
                "oLanguage": {
                    "sEmptyTable": "No Documents Available",
		            "sLengthMenu": "Show _MENU_",
                },
                drawCallback: function() {

                },

                "bDestroy": true,
                "bSort": true,
                columnDefs: [
                    {
                        targets: 0,
                        "sortable": false,
                        "searchable": true,
                        render: function(data, type, row) {
                            data=`${row[0]}`
                            return data;
                        }
                    },
                    {
                        targets: 1,
                        "searchable": false,
                        render: function(data, type, row) {
                            data = `${row[6]}`;
                            return data;
                        }
                    },
                    {
                        targets: 2,
                        "sortable": false,
                        "searchable": false,
                        render: function(data, type, row) {
                            data = `<a href="/ViewDoc.cfm?pdfloc=${row[5]}" target="_blank">${row[2]}</a>`;
                            return data;
                        }
                    },
                    {
                        targets: 3,
                        "sortable": false,
                        "searchable": false,
                        render: function(data, type, row) {
                            data = `<div class="dropdown mt-1" style ="border: none !important;"><a class="dropdown-toggle" href="##" id="dropdownMenuLink" data-bs-toggle="dropdown" aria-expanded="false"><img src="./Images/edit.svg" style="cursor: pointer;"></a><ul class="dropdown-menu" aria-labelledby="dropdownMenuLink"><li><a class="dropdown-item statementsFormlink" href="download.cfm?path=${row[5]}">Download</a></li></ul></div>`;
                            return data;
                        }
                    },
                ]
            });
        }