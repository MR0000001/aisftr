({
	retrieveAsset: function (component, event, helper) {
        let action = component.get("c.queryAsset");
        action.setParams({
            recordId: component.get("v.recordId"),

        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log('@@@data '+JSON.stringify(res));
                let currentData = [];
                for(var i=0; i<res.length;i++ ){
                    var row = res[i];
                    console.log('@row'+JSON.stringify(row));
                    let rowData = {};
                    if(row.Name != null){
                        rowData.Name = row.Name;
                        rowData.Link1 = '/'+row.Id ;
                    } 
                    if(row.XC_Contract__c && row.XC_Contract__r.ContractNumber){
                        rowData.XC_Contract__c = row.XC_Contract__r.ContractNumber;
                        rowData.Link7 = '/'+row.XC_Contract__c ;
                    }  
                    //rowData.XC_ContractStartDate__c = row.XC_ContractStartDate__c;
                    // rowData.XC_ContractEndDate__c = row.XC_ContractEndDate__c;
                    if(row.XC_Contract__c && row.XC_Contract__r.StartDate){
                        rowData.ContractStartDate = row.XC_Contract__r.StartDate;
                    }
                    if(row.XC_Contract__c && row.XC_Contract__r.EndDate){
                        rowData.ContractEndDate = row.XC_Contract__r.EndDate;
                    }
                    if(row.TAM_PartnerContract__c && row.TAM_PartnerContract__r.XC_ContractSAP__c){
                        rowData.XC_ContractSAP__c = row.TAM_PartnerContract__r.XC_ContractSAP__c;
                        rowData.Link2 = '/'+row.TAM_PartnerContract__c ;
                    }
                    if(row.TAM_PartnerContract__c && row.TAM_PartnerContract__r.ContractNumber){
                        rowData.ContractNumber = row.TAM_PartnerContract__r.ContractNumber;
                        rowData.Link3 = '/'+row.TAM_PartnerContract__c ;
                    }
                    if(row.TAM_PartnerContract__c && row.TAM_PartnerContract__r.AccountId){
                        rowData.AccountId = row.TAM_PartnerContract__r.Account.Name;
                        rowData.Link4 = '/'+row.TAM_PartnerContract__r.AccountId ;
                    }
                    rowData.Status = row.Status ;
                    rowData.Id = row.Id ;
                    currentData.push(rowData);
                }
                component.set("v.data",currentData);
                
                var pageSize = component.get("v.pageSize");
                // get size of all the records and then hold into an attribute "totalRecords"
                component.set("v.totalRecords", component.get("v.data").length);
                // set start as 0
                component.set("v.startPage",0);
                
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.data").length> i)
                        PaginationList.push(currentData[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                //component.set('v.isSending',false);
                console.log('%%%%%%'+JSON.stringify(PaginationList));
                //this.retrieveAsset1(component, event, helper);
            }
            $A.get('e.force:refreshView').fire();

        })
        $A.enqueueAction(action);
    },

         retrieveAsset1: function (component, event, helper) {
            let action = component.get("c.queryAssetCommercial");
            action.setParams({
                recordId: component.get("v.recordId"),
    
            })
            action.setCallback(this, function (response) {
                let state = response.getState();
                let res = response.getReturnValue();
                if (state === "SUCCESS") {
                    console.log('@@@data1 '+JSON.stringify(res));
                    let currentData1 = [];
                    for(var i=0; i<res.length;i++ ){
                        var row1 = res[i];
                        console.log('@row1'+JSON.stringify(row1));
                        let rowData1 = {};
                        if(row1.Name != null){
                            rowData1.Name = row1.Name;
                            rowData1.Link5 = '/'+row1.Id;
                            console.log('&&&'+JSON.stringify(row1))
                        }
                        rowData1.Quantity = row1.Quantity;
                        rowData1.NE__Activation_Date__c = row1.NE__Activation_Date__c;
                        rowData1.XC_LegalEntity__c = row1.XC_LegalEntity__c;
             /*           if(row1.NE__Current_Configuration_Item__c && row1.NE__Current_Configuration_Item__r.NE__StartDate__c){
                            rowData1.StartDate = row1.NE__Current_Configuration_Item__r.NE__StartDate__c;
                        }
                        if(row1.NE__Current_Configuration_Item__c && row1.NE__Current_Configuration_Item__r.NE__EndDate__c){
                            rowData1.EndDate = row1.NE__Current_Configuration_Item__r.NE__EndDate__c;
                        } */
                        if(row1.XC_Contract__c && row1.XC_Contract__r.Opportunity__c){
                            rowData1.OptyName = row1.XC_Contract__r.Opportunity__r.Name ;
                            rowData1.Link6 = '/'+row1.XC_Contract__r.Opportunity__c ;
                         }
                        rowData1.ContractStartDate = row1.XC_ContractStartDate__c ;
                        rowData1.ContractEndDate = row1.XC_ContractEndDate__c ;
                        rowData1.Status = row1.Status ;
                        rowData1.Id = row1.Id ;
                        console.log('%%%%%%'+JSON.stringify(rowData1));
                        currentData1.push(rowData1);
                    }
                    component.set("v.data1",currentData1);
                    
                    var pageSize2 = component.get("v.pageSize2");
                    // get size of all the records and then hold into an attribute "totalRecords"
                    component.set("v.totalRecords2", component.get("v.data1").length);
                    // set start as 0
                    component.set("v.startPage2",0);
                    
                    component.set("v.endPage2",pageSize2-1);
                    var PaginationList2 = [];
                    for(var i=0; i< pageSize2; i++){
                        if(component.get("v.data1").length> i)
                            PaginationList2.push(currentData1[i]);
               //         else
               //             PaginationList2.push(currentData1[i]);
                    }
                    component.set('v.PaginationList2', PaginationList2);
                    console.log('%%%%%% paginationlist2 '+ PaginationList2);

                    component.set('v.mycolumns', [{
                        label: 'Nome Asset',
                        fieldName: 'Link5', 
                        type: 'url', 
                        sortable: true,
                        hideDefaultActions : true ,
                        typeAttributes: {label: { fieldName:'Name'}, target: '_blank'}, 
                        initialWidth: 150
                    },
                    {
                        label: 'Quantità',
                        fieldName: 'Quantity',
                        type: 'text',
                        sortable: true,
                        hideDefaultActions : true ,
                        initialWidth: 150
                    },
                    {
                        label: 'Stato',
                        fieldName: 'Status',
                        type: 'text',
                        sortable: true,
                        hideDefaultActions : true ,
                        initialWidth: 150
                    },
                    {
                        label: 'Data Attivazione',
                        fieldName: 'NE__Activation_Date__c',
                        type: 'text',
                        sortable: true,
                        hideDefaultActions : true ,
                        initialWidth: 150
                    },
                    {
                        label: 'Data inizio contratto',
                        fieldName: 'ContractStartDate',
                        type: 'text',
                        sortable: true,
                        hideDefaultActions : true ,
                        initialWidth: 150
                    },
                    {
                        label: 'Data fine contratto',
                        fieldName: 'ContractEndDate',
                        type: 'text',
                        sortable: true,
                        hideDefaultActions : true ,
                        initialWidth: 150
                    },
                    /*{
                        label: 'Nome Opportunità',
                        fieldName: 'OptyName',
                        type: 'text',
                        initialWidth: 150
                    },*/
                    {
                        label: 'Nome Opportunità',
                        fieldName: 'Link6', 
                        type: 'url', 
                        sortable: true,
                        hideDefaultActions : true ,
                        typeAttributes: {label: { fieldName: 'OptyName' }, target: '_blank'}, 
                        initialWidth: 150
                    },
                    {
                        label: 'Legal Entity',
                        fieldName: 'XC_LegalEntity__c',
                        type: 'text',
                        sortable: true,
                        hideDefaultActions : true ,
                        initialWidth: 150
                    }
                ])
                    
                }
    $A.get('e.force:refreshView').fire();
    
            })
            $A.enqueueAction(action);
    
},
    technicalnext : function(component, event){
        var sObjectList = component.get("v.data");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        pageNumber = pageNumber + 1 ;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        component.set('v.pageNumber', pageNumber);
    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    technicalprevious : function(component, event){
        var sObjectList = component.get("v.data");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        pageNumber = pageNumber - 1 ;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
        component.set('v.pageNumber', pageNumber);
    },
    
    commercialnext : function(component, event){
        var sObjectList = component.get("v.data1");
        var end = component.get("v.endPage2");
        var start = component.get("v.startPage2");
        var pageSize = component.get("v.pageSize2");
        var pageNumber = component.get("v.pageNumber2");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        pageNumber = pageNumber + 1 ;
        component.set("v.startPage2",start);
        component.set("v.endPage2",end);
        component.set('v.PaginationList2', Paginationlist);
        component.set('v.pageNumber2', pageNumber);
    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    commercialprevious : function(component, event){
        var sObjectList = component.get("v.data1");
        var end = component.get("v.endPage2");
        var start = component.get("v.startPage2");
        var pageSize = component.get("v.pageSize2");
        var pageNumber = component.get("v.pageNumber2");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        pageNumber = pageNumber - 1 ;
        component.set("v.startPage2",start);
        component.set("v.endPage2",end);
        component.set('v.PaginationList2', Paginationlist);
        component.set('v.pageNumber2', pageNumber);
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.PaginationList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.PaginationList", data);
    },
    
    sortData2: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.PaginationList2");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.PaginationList2", data);
    },
    
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

})