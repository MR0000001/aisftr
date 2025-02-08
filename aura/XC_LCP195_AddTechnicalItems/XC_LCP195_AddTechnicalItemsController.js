({
    /*
     * This finction defined column header
     * and calls getProduct2 helper method for column data
     * editable:'true' will make the column editable
     * */
	doInit : function(component, event, helper) {
	      let action = component.get('c.checkFromCommunity');

          action.setCallback(this,function(response){
              let state = response.getState();
              let res = response.getReturnValue();
              if (state === "SUCCESS" && res != null) {
                 if(res==true){
                     //From Community
                     component.set('v.columns', [
                        {label: 'Name', fieldName: 'name', type: 'text'},
                        {label: 'Service Position', fieldName: 'positionName', type: 'text'},
                        {label: 'Product Code', fieldName: 'productCode', type: 'text'},
                        {label: 'Type', fieldName: 'type', type: 'text'},
                        {label: 'Quantity', fieldName: 'Quantity', type: 'text' ,editable: true}

                     ]);
                 }
                 else{
                     component.set('v.columns', [
                        {label: 'Name', fieldName: 'name', type: 'text'},

                        {label: 'Service Position', fieldName: 'positionName', type: 'text'},

                        {label: 'Product Code', fieldName: 'productCode', type: 'text'},
                         //{label: 'Type', fieldName: 'XC_Type__c', type: 'text'},
                         {label: 'Type', fieldName: 'type', type: 'text'},
                         {label: 'Price', fieldName: 'prodPrice', type: 'text' , typeAttributes: { currencyCode: 'EUR' }},
                         {label: 'Quantity', fieldName: 'Quantity', type: 'text' ,editable: true}
                         //{type:  'action', typeAttributes: { rowActions: actions } }
                         //{label: 'Action', fieldName: 'isoCode', type: 'text'}
                     ]);
                 }
              }
              component.set("v.spinner", false);
          });
          $A.enqueueAction(action);

      component.set('v.columns', [
			{label: 'Name', fieldName: 'name', type: 'text'},

			{label: 'Service Position', fieldName: 'positionName', type: 'text'},

			{label: 'Product Code', fieldName: 'productCode', type: 'text'},
            //{label: 'Type', fieldName: 'XC_Type__c', type: 'text'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'Price', fieldName: 'prodPrice', type: 'text' , typeAttributes: { currencyCode: 'EUR' }},
            {label: 'Quantity', fieldName: 'Quantity', type: 'text' ,editable: true}
            //{type:  'action', typeAttributes: { rowActions: actions } }
            //{label: 'Action', fieldName: 'isoCode', type: 'text'}
        ]);      
        //console.log('@@@ doInit - woliId:' + component.get("v.woliRecordId"));
        //console.log('@@@ doInit - contestStart:' + component.get("v.contestStart"));
        
        if(component.get("v.contestStartCI")==false) {
            component.set("v.noItemFound",true);
            helper.getOrdItemFromWoli(component,event, helper);
        }else{
            helper.checkValidItem(component,event, helper);
            component.set("v.noItemFound",true);
        	//DP performance ----- helper.getProduct2(component, helper);
			//helper.getFamilyValues(component, helper);
        	//helper.getCountryValue(component, helper);
        }
    },
    
    handleChangeShowMaterials : function(component, event, helper) { 
        if(component.get("v.contestStartCI")==false) {  
            helper.getOrdItemFromWoli(component,event, helper);
        }else{
        	//DP performance ----- helper.getProduct2(component, helper);
        } 
    },

	onNext : function(component, event, helper) { 
       //get current page numbe
        let pageNumber = component.get("v.pageNumber");
        //Setting current page number
        component.set("v.pageNumber", pageNumber+1);
        //Setting pageChange variable to true
        component.set("v.hasPageChanged", true);        
        if(helper.filtersNotIsEmpty(component, event, helper)){
            helper.search(component, event, helper);
        }
        else{
            helper.getProduct2(component, helper);
        }  
    },
    
    onPrev : function(component, event, helper) {        
       //get current page number
        let pageNumber = component.get("v.pageNumber");
        //Setting current page number
        component.set("v.pageNumber", pageNumber-1);
        //Setting pageChange variable to true
        component.set("v.hasPageChanged", true);
        
        if(helper.filtersNotIsEmpty(component, event, helper)){
            helper.search(component, event, helper);
        }
        else{
            helper.getProduct2(component, helper);
        }       
    },
    
    onRowSelection : function(component, event, helper) {
        if(!component.get("v.hasPageChanged") || component.get("v.initialLoad")){
			//set initial load to false
            component.set("v.initialLoad", false);
            //Get currently select rows, This will only give the rows available on current page
            let selectedRows = event.getParam('selectedRows');
            component.set("v.selected", selectedRows);
        
            //Get all selected rows from datatable, this will give all the selected data from all the pages
            let allSelectedRows = component.get("v.selection");
         
            //Get current page number
            let currentPageNumber = component.get("v.pageNumber");
            
            //Process the rows now
            //Condition 1 -> If any new row selected, add to our allSelectedRows attribute
            //Condition 2 -> If any row is deselected, remove from allSelectedRows attribute
            //Solution - Remove all rows from current page from allSelectedRows attribute and then add again
    
            //Removing all rows coming from curent page from allSelectedRows
            let i = allSelectedRows.length;
            
            console.log('@@@@ onRowSelection Removing:' + i);
            console.log('@@@@ onRowSelection - allSelectedRows :' + JSON.stringify(allSelectedRows));
            
            while (i--) {
                console.log('@@@@ while i--');
                let pageNumber = null;
                if(allSelectedRows[i] != null ){
                    allSelectedRows[i].split("-")[1];
                    
                }
                
                console.log('@@@@ onRowSelection - pagenumber:'+ pageNumber);
                console.log('@@@@ onRowSelection - currentPageNumber:'+ currentPageNumber);
               // if (pageNumber && pageNumber == currentPageNumber) { 
                    allSelectedRows.splice(i, 1);
                    console.log('@@@@ onRowSelection - removing'); 
                    
               // }  
            }
            
            //Adding all the new selected rows in allSelectedRows

            selectedRows.forEach(function(row) {
                allSelectedRows.push(row.glBookEntryId);
            });
            component.set("v.len", selectedRows.length);
            //Setting new value in selection attribute
            console.log('@@@@ onRowSelection - allSelectedRows:' +JSON.stringify(allSelectedRows));
          
            component.set("v.selection", allSelectedRows);
            
      //Start NR2248 Show Select Items Logic - vaibhav.c.anand@accenture.com
	  
          let currentSelectedRows =  component.get("v.selProd") ;
          let currentRows = event.getParam('selectedRows');
          console.log("@current selected "+event.getParam('selectedRows'));
          let data = currentRows.concat(component.get("v.SelectProd2")) ;

          component.set("v.SelectProd", data );
		  
      //End NR2248 Show Select Items Logic		  
           
        } else{
             component.set("v.hasPageChanged", false);
        }
    },
    
    /* this method save manual price and manual quantity edit*/
    handleSaveEdition: function (component, event, helper) {
        component.set("v.spinner", true);
        console.log('@@@@ handleSaveEdition - v.data:' + component.get("v.data"));
        let allSelectedRows = component.get("v.selection");
        console.log('@@@ handleSaveEdition - allSelectedRows '+JSON.stringify(allSelectedRows) );     
        let draftValues = event.getParam('draftValues');
      	console.log('@@@ handleSaveEdition - draftValues '+JSON.stringify(draftValues) );
        component.set("v.manualMapPrice", draftValues);
       	setTimeout(function() {
             component.set("v.spinner", false);
    	}, 3000);
    },  
	 checkCategoryFilter: function (component, event, helper) {
        let b = component.get("v.flagDisableCatFilter");
        component.set("v.flagDisableCatFilter",!b);
        
    },
     checkAvailabeMaterials: function (component, event, helper) {
                let b = component.get("v.showAvailable");
                component.set("v.showAvailable",!b);

     },

    /* this method call query on product and consider eventually manual edit filter*/
    doSearch : function(component, event, helper){
	
       //Start NR2248 Show Select Items Logic - vaibhav.c.anand@accenture.com
       let check = component.get("v.SelectProd");
       let check2 = [...new Set(check.concat(component.get("v.SelectProd2")))];
       component.set("v.SelectProd2", check2);
       component.set("v.searchcheck",true);
       //End NR2248 Show Select Items Logic	
	   
        if( helper.filtersNotIsEmpty(component, event, helper)){
    		console.log('@@@  doSearch - call search'); 
            helper.search(component, event, helper);
        }
        else{
            console.log('@@@ doSearch - call product2');
    		component.set("v.noItemFound", false);
        	helper.getProduct2(component, helper);
    	}

    },

	/* this method generate technical conf.item or product required based on paramenter came from scenario*/
    addTechItems : function(component, event, helper){
		helper.addTechnicalItems(component, event, helper);
    },

    /* NR2248 Meghana Begin*/
    showSelected : function(component, event, helper){
       // component.set("v.searchcheck",true);

       
        if(component.get("v.SelectProd").length  == 0)
        {
            component.find('notifLib').showToast({
                "variant": "Error",
                "title": "Error!",
                "message": "Nessun item selezionato."
            });

        }
        else{
            component.set('v.showcolumns', [
                {label: 'Name', fieldName: 'name', type: 'text', editable: false},
                {label: 'Service Position', fieldName: 'positionName', type: 'text', editable: false},
                {label: 'Product Code', fieldName: 'productCode', type: 'text', editable: false},
                {label: 'Type', fieldName: 'type', type: 'text', editable: false},
                {label: 'Quantity', fieldName: 'Quantity', type: 'text' ,editable: false}

             ]);
            component.find("product2DataTable").set("v.selectedRows",component.get("v.selection"));
            component.set("v.isModalOpen", true);
        }
    },

    UploadFinished: function (component, event) {
            // Get the list of uploaded files
            var uploadedFiles = event.getParam("files");
            component.set("v.uploadedcsv", uploadedFiles);
            let button = component.find('savebuttonid');
            button.set('v.disabled',false);
        },

    uploadCSV : function(component, event, helper){
        helper.uploadCSV(component, event, helper);
    },

    saveCSV : function(component, event, helper){
        let files = component.get("v.uploadedcsv");
        console.log('@@@ filestosave - '+JSON.stringify(files));
        helper.saveCSV(component, files, helper);
    },

    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
     },
    
     closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.uploadModalOpen", false);
     },
    /* NR2248 Meghana End*/
    
    cancelDialog : function(component,event, helper) {
        let idElement;
      //  component.set("v.whichOne", "Cancel");
        if(component.get("v.contestStartCI")==false) {  
            idElement = component.get("v.woliRecordId");
        }else{  
            idElement = component.get("v.recordId");
        } 
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": idElement,
            "slideDevName": "list"
        });
        sObjectEvent.fire();
    }
   
})