({
    init : function(component, callback) {
        console.log('TA_LCP218_DynamicRemind >> Helper >> init >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

        let fields = component.get('v.custom').fields;
        let customLabels = [];

        fields.forEach(function(field) {
            customLabels.push(field.nameAccordion);
            customLabels.push(field.valueAccordion);
        });

        let getCustomLabels = component.get('c.getCustomLabels');
        getCustomLabels.setParams({
            'workOrderId' : component.get('v.workOrderId'),
            'language' : component.get('v.language'),
            'customLabels' : customLabels
        });

        getCustomLabels.setCallback(this, function(response) {
            console.log('TA_LCP218_DynamicRemind >> Helper >> initCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let fields = component.get('v.custom').fields;
                let mdtLabels = response.getReturnValue();

                mdtLabels.forEach(function(mdtLabel) {
                    fields.forEach(function(field) {
                        if(field.nameAccordion == mdtLabel.MasterLabel) {
                            field.idAccordion = field.nameAccordion;
                            field.nameAccordion = mdtLabel.TA_Label__c;
                        } else if(field.valueAccordion == mdtLabel.MasterLabel) {
                            field.valueAccordion = mdtLabel.TA_Label__c;
                        }
                    });
                });

                component.set('v.custom.fields', fields);
                this.fireSendInitStateEvt(component, true);
                component.set('v.objWrapper', response.getReturnValue());
                component.set('v.fieldValue' , component.get('v.objWrapper.fields'));
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP218_DynamicRemind >> Helper >> initCallback >> End');
        });

        $A.enqueueAction(getCustomLabels);
        console.log('TA_LCP218_DynamicRemind >> Helper >> init >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP218_DynamicRemind >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP218_DynamicRemind",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP218_DynamicRemind >> Helper >> fireSendInitStateEvt >> End');
    },

    manageAccordion : function(component,event) {
        console.log('TA_LCP218_DynamicRemind >> Helper >> manageAccordion >> Start');
        let name = event.currentTarget.name;
        let fields = component.get('v.custom.fields');

        fields.forEach(function(field) {
            if(field.idAccordion == name) {
                if(field.showAccordion == 'true') {
                     field.showAccordion = 'false';
                } else if(field.showAccordion == 'false') {
                    field.showAccordion = 'true';
                }
            }
        });
        component.set('v.custom.fields', fields);
        console.log('TA_LCP218_DynamicRemind >> Helper >> manageAccordion >> End');
    }
})