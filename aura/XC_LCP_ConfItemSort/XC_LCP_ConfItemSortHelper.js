({
	getConfs : function(component, event, helper) {

        //CR-724-elisa.caldini@accenture.com-24.02.2021-change type quantity number->> text
            
		/*var action = component.get("c.getConfs");
        action.setParams({ orderId : component.get("v.recordId") });
          action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log( 'res',JSON.stringify(response.getReturnValue()));
                component.set("v.configurationItemHierarchy", response.getReturnValue());
            }
        });*/
        var action = component.get( "c.getConfs" );
        action.setParams({orderId : component.get("v.recordId")
        });
        action.setCallback(this, function( response ) {
           
            var state = response.getState();
           
            if ( state === "SUCCESS" ) {
                var rows = response.getReturnValue();
				for ( var i = 0; i < rows.length; i++ ) {
                    var row = rows[i];
                    if ( row.NE__ProdId__r) {
                        row.NE__ProdId__rName = row.NE__ProdId__r.Name;
                    }
                    if ( row.XC_Product2Id__r) {
                        row.XC_Product2Id__rName = row.XC_Product2Id__r.Name;
                        row.XC_Product2Id__rProductCode = row.XC_Product2Id__r.ProductCode;
                    }
                    if(null != row.NE__Order_Item_Attributes__r){
                        for(var j = 0; j < row.NE__Order_Item_Attributes__r.length; j++){
                            if(row.NE__Order_Item_Attributes__r[j].Name == 'Tipologia'){
                                row.Tipology =row.NE__Order_Item_Attributes__r[j].NE__Value__c;
                            }
                            if(row.NE__Order_Item_Attributes__r[j].Name == 'POD'){ 
                                row.POD = row.NE__Order_Item_Attributes__r[j].NE__Value__c;
                            }
                            if(row.NE__Order_Item_Attributes__r[j].Name == 'Potenza'){
                                row.Power=row.NE__Order_Item_Attributes__r[j].NE__Value__c;
                            }
                            if(row.NE__Order_Item_Attributes__r[j].Name == 'Annual Price'){
                                row.AnnualPrice = row.NE__Order_Item_Attributes__r[j].NE__Value__c;
                            }                                
                        }
                    }                   
                    row.recordOiLink = '/'+rows[i].Id;
                }
                component.set( "v.configurationItemHierarchy", rows);
            }
        });
     	$A.enqueueAction(action);
    },
    
    //Start CR758
    checkCommercial : function(component, event, helper){
        console.log("@@@@ checkCommercial");
    	var action = component.get("c.checkCommercial");
        console.log("@@@@@@ recordID: "+component.get("v.recordId"));
        action.setParams({
            'orderId' : component.get("v.recordId")
        });        
        
        action.setCallback(this, function( response ) {
            if(response.getState() === "SUCCESS"){
                component.set( "v.checkCommType", response.getReturnValue());
                
                var actions = [
                    { label: 'Edit', name: 'edit' },
                    { label: 'View', name: 'view' } ];
        
                var commType = component.get("v.checkCommType");
                console.log("@@@@@ commType " + commType);
                
                if(commType==0){
            		component.set('v.mycolumns', [
                        {label: 'Name', fieldName: 'recordOiLink', type: 'url', 
                        typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
                        {
                            label: 'Id prodotto',
                            fieldName: 'NE__ProdId__rName', 
                            type: 'text'
                        },{
                            label: 'XC_Product2Id',
                            fieldName: 'XC_Product2Id__rName',
                            type: 'text'
                        },{
                            label: 'Product Code',
                            fieldName: 'XC_Product2Id__rProductCode', 
                            type: 'text'
                        },{
                            label: 'Quantità',
                            fieldName: 'NE__Qty__c',
                            type: 'text'
                        },{
                            label: 'Costo Totale',
                            fieldName: 'XC_CostFull_Life__c',
                            type: 'number'
                        },{
                            label: 'Revenue Full Life',
                            fieldName: 'XC_RevenueFullLife__c',
                            type: 'number'
                        } ] );
                }
                if(commType==1){
                    component.set('v.mycolumns', [
                        {label: 'Name', fieldName: 'recordOiLink', type: 'url', 
                            typeAttributes: {
                                label: { fieldName: 'Name' }, target: '_self'}
                        },{
                            label: 'Id prodotto',
                            fieldName: 'NE__ProdId__rName', 
                            type: 'text'
                        },{
                            label: 'Root Order Item',
                            fieldName: 'NE__Root_Order_Item__c',
                            type: 'text'
                        },{
                            label: 'Prodotto Tecnico',
                            fieldName: 'XC_Product2Id__rName',
                            type: 'text'
                        },{
                            label: 'SAP Code',
                            fieldName: 'XC_Product2Id__rProductCode', 
                            type: 'text'
                        },{
                            label: 'Quantità',
                            fieldName: 'NE__Qty__c',
                            type: 'text'
                        },{
                            label: 'Costo totale',
                            fieldName: 'XC_CostFull_Life__c',
                            type: 'text'
                        },{
                            label: 'Ricavo totale',
                            fieldName: 'XC_RevenueFullLife__c',
                            type: 'text'
                        },{
                            label: 'Capex Full Life',
                            fieldName: 'XC_CapexFullLife__c',
                            type: 'text'
                        }
                    ]);
                }
                if(commType==2){
                    component.set('v.mycolumns', [
                        {label: 'Name', fieldName: 'recordOiLink', type: 'url', 
                            typeAttributes: {
                                label: { fieldName: 'Name' }, target: '_self'}
                        },{
                            label: 'Id prodotto',
                            fieldName: 'NE__ProdId__rName', 
                            type: 'text'
                        },{
                            label: 'Root Order Item',
                            fieldName: 'NE__Root_Order_Item__c',
                            type: 'text'
                        },
                        {
                            label: 'Tipologia',
                            fieldName: 'Tipology',
                            type: 'text'
                        },
                        {
                            label: 'POD',
                            fieldName: 'POD',
                            type: 'text'
                        },
                        {
                            label: 'Potenza',
                            fieldName: 'Power',
                            type: 'text'
                        },                    
                        {
                            label: 'Quantità',
                            fieldName: 'NE__Qty__c',
                            type: 'text'
                        },
                       {
                            label: 'Annual Price',
                            fieldName: 'AnnualPrice',
                            type: 'text'
                        },
                        {
                            label: 'Start Date',
                            fieldName: 'NE__StartDate__c',
                            type: 'text'
                        },{
                            label: 'End Date',
                            fieldName: 'NE__EndDate__c',
                            type: 'text'
                        }
                    ]);
                }
                console.log("@@@@@@@@@@@ checkCommType "+component.get("v.checkCommType"));
            }
		});
        $A.enqueueAction(action);
	}
    //End CR758
})