({
    doInit: function (component, event, helper) {
        helper.retrieveAsset(component, event, helper);
        helper.retrieveAsset1(component, event, helper);
    
        //From Community
        component.set('v.columns', [
            /*{
                label: 'Nome Asset',
                fieldName: 'Name',
                type: 'text',
                initialWidth: 150
            },*/
            {
                label: 'Nome Asset',
                fieldName: 'Link1', 
                type: 'url', 
                sortable: true,
                hideDefaultActions : true ,
                typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, 
                initialWidth: 150
            },
            /*{
                label: 'Contratto Attivo',
                fieldName: 'XC_Contract__c',
                type: 'text',
                hideDefaultActions : true ,
                initialWidth: 150
            },*/
            {
                label: 'Contratto Attivo',
                fieldName: 'Link7', 
                type: 'url', 
                sortable: true,
                hideDefaultActions : true ,
                typeAttributes: {label: { fieldName: 'XC_Contract__c' }, target: '_blank'}, 
                initialWidth: 150
            },
            {
                label: 'Data iniziale contratto attivo',
                fieldName: 'ContractStartDate',
                type: 'text',
                sortable: true,
                hideDefaultActions : true ,
                initialWidth: 150
            },
            {
                label: 'Data finale contratto attivo',
                fieldName: 'ContractEndDate',
                type: 'text',
                sortable: true,
                hideDefaultActions : true ,
                initialWidth: 150
            },
            /*{
                label: 'Contratto Passivo SAP',
                fieldName: 'NewPartnerContract',
                type: 'text',
                initialWidth: 150
            },*/
            {
                label: 'Contratto Passivo SAP',
                fieldName: 'Link2', 
                type: 'url', 
                sortable: true,
                hideDefaultActions : true ,
                typeAttributes: {label: { fieldName: 'XC_ContractSAP__c' }, target: '_blank'}, 
                initialWidth: 150
            },
            /*{
                label: 'Contratto Passivo XC',
                fieldName: 'ContractNumber',
                type: 'text',
                initialWidth: 150
            },*/
            {
                label: 'Contratto Passivo XC',
                fieldName: 'Link3', 
                type: 'url', 
                sortable: true,
                hideDefaultActions : true ,
                typeAttributes: {label: { fieldName: 'ContractNumber' }, target: '_blank'}, 
                initialWidth: 150
            },
            {
                label: 'Impresa legata al contratto passivo',
                fieldName: 'Link4', 
                type: 'url', 
                sortable: true,
                hideDefaultActions : true ,
                typeAttributes: {label: { fieldName: 'AccountId' }, target: '_blank'}, 
                initialWidth: 150
            },
            {
                label: 'Stato',
                fieldName: 'Status',
                type: 'text',
                sortable: true,
                hideDefaultActions : true ,
                initialWidth: 150
            }
    
        
        ]);
    
    
        console.log('@insidecontrollerdata1'+JSON.stringify(component.get("v.data1")));
        //From Community
        
        },
            
        technicalnext: function (component, event, helper) {
        helper.technicalnext(component, event);
        },
            
        technicalprevious: function (component, event, helper) {
        helper.technicalprevious(component, event);
        },
        
        commercialnext: function (component, event, helper) {
        helper.commercialnext(component, event);
        },
            
        commercialprevious: function (component, event, helper) {
        helper.commercialprevious(component, event);
        },
        
        sortColumn : function (component, event, helper) {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
        },
        
        sortColumn2 : function (component, event, helper) {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy2", fieldName);
            component.set("v.sortedDirection2", sortDirection);
            helper.sortData2(component, fieldName, sortDirection);
        },
    })