({
	cancel : function(component, event) {
		  setTimeout(function(){ 
            $A.get("e.force:closeQuickAction").fire();
         }, 2);
	},

	sendEvent : function(component, event, helper) {
       
		let evt= $A.get("e.c:XC_LCE011_DataTable");
		let rows=component.get("v.Selected");
        console.log(rows);
		if(rows.length!= 0){
            
            evt.setParams({
                "selectedRows" : rows
            });
			evt.fire();
      
         
		}
		
	},

	updateSelectedRowsHelper : function(component, event) {
		let selectedRows = event.getParam('selectedRows');
		component.set("v.Selected", selectedRows);  
		component.set("v.disabled", false);	
	}
})