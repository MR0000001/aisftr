({
    doInit: function (component, event, helper) {

        helper.doInit(component, event, helper);

    },

    closeZuora: function (component, event, helper) {
        console.log('chiudo Zuora cmp');
        let closeAll = event.getParam("closeAll");
        if (closeAll) {
            $A.get("e.force:closeQuickAction").fire();
        } else {
            component.set("v.showZuora", false);
            helper.doInit(component, event, helper);
        }
    },

    closeDocSection: function (component, event, helper) {

        component.set("v.showInsertDocument", false);
    },

    createPersonalDoc: function (component, event, helper) {
        helper.createPersonalDoc(component, event, helper);
    },

    checkDoc: function (component, event, helper) {
        let country = component.get("v.docCountry");
        let docType = component.get("v.docType");
        let docNumber = component.get("v.docNumber");
        if (country != undefined && docType != undefined && docNumber != undefined) {
            component.set("v.blockDocSave", false);
        } else {
            component.set("v.blockDocSave", true);
        }
    },

    createOrder: function (component, event, helper) {
        component.set("v.showSpinner", true);
        let a = component.get('v.testvalue');
        console.log('qua' + JSON.stringify(a));
        helper.updateConfItem(component, event, helper);
    },
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    createPayment: function (component, event, helper) {

        helper.populateBillingTable(component, event, helper);


    },
    createNEWPayment: function (component, event, helper) {
        component.set("v.configurationId", component.get("v.recordId"));
        component.set("v.showZuora", true);

        let modaltarget = component.find('IntModal');
        let backdroptarget = component.find('ModalbackdropInt');

        $A.util.addClass(modaltarget, 'slds-fade-in-open');
        $A.util.addClass(backdroptarget, 'slds-backdrop--open');

    },



    handleComponentEvent: function (component, event, helper) {
        console.log('ricevuto');
        let confItemId = event.getParam("recordId");
        let paymentMethod = event.getParam("paymentMethod");
        let billingProfile = event.getParam("billingProfile");
        let installmentPlanFields = event.getParam("installmentPlanFields");
        let list = [paymentMethod, billingProfile, installmentPlanFields];
        let map = {};
        map = component.get("v.totalMap");
        map[confItemId] = list;
        component.set("v.totalMap", map);
        if(billingProfile!==""){
            component.set("v.disabledSubmit", false);
        }
        console.log('LISTA FINALE = ' + JSON.stringify(component.get("v.totalMap")));
    },

    setAddressValue: function (component, event, helper) {
        let selectedOptionValue = event.getParam("value");
        if (selectedOptionValue != undefined && selectedOptionValue != '') {
            component.set("v.addressId", selectedOptionValue);
            component.set("v.addressOK", true);
            component.set("v.disablePayment", false);
        }

    },
    openZuora: function (component, event, helper) {

        component.set("v.objectType", 'NE__Billing_Profile__c');
        let selectedRows = event.getParam('selectedRows');
        selectedRows = selectedRows[0];
        let type = selectedRows.NE__Payment__c
        let bankNumber = selectedRows.NE__Iban__c

        console.log('SELECTED ROW PAYMENT TYPE:: ' + selectedRows.NE__Payment__c);



        //component.set("v.accountId", selectedRows.Id); 
        component.set("v.paymentTypeFromTable", type);
        component.set("v.billingProfileId", selectedRows.Id);
        component.set("v.configurationId", component.get("v.recordId"));
        component.set("v.showZuora", true);

        if (bankNumber) {
            component.set("v.bankNumberFromTable", bankNumber);
        }


        let modaltarget = component.find('IntModal');
        let backdroptarget = component.find('ModalbackdropInt');

        $A.util.addClass(modaltarget, 'slds-fade-in-open');
        $A.util.addClass(backdroptarget, 'slds-backdrop--open');

    },

    closeStrikeModal: function (component, event, helper) {
        console.log('ricevuto');
        let r = event.getParam("closeStrikeModal");
        if (r) {
            setTimeout(function () {
                component.set("v.showTable", false);
                component.set("v.showZuora", false);
            }, 3500);
        }
    },
    closeFirstModal: function (component, event, helper) {
        let modaltarget = component.find('ExtModal');
        let backdroptarget = component.find('Modalbackdrop');

        $A.util.removeClass(modaltarget, 'slds-fade-in-open');
        $A.util.removeClass(backdroptarget, 'slds-backdrop--open');
    },

    closeSecondModal: function (component, event, helper) {

        let modaltarget = component.find('IntModal');
        let backdroptarget = component.find('ModalbackdropInt');

        $A.util.removeClass(modaltarget, 'slds-fade-in-open');
        $A.util.removeClass(backdroptarget, 'slds-backdrop--open');
    },

    createAddress: function (component, event, helper) {
        component.set("v.showNewAddress", true);

        let modaltarget = component.find('addrModal');
        let backdroptarget = component.find('Modalbackdrop');

        $A.util.addClass(modaltarget, 'slds-fade-in-open');
        $A.util.addClass(backdroptarget, 'slds-backdrop--open');
    },

    closeNewAddress: function (component, event, helper) {
        helper.doInit(component, event, helper);

        let modaltarget = component.find('addrModal');
        let backdroptarget = component.find('Modalbackdrop');

        $A.util.removeClass(modaltarget, 'slds-fade-in-open');
        $A.util.removeClass(backdroptarget, 'slds-backdrop--open');


        component.set("v.showNewAddress", false);
    },

    closeChildComponent: function (component, event, helper) {

        //close on zuora child component --> this will close the inner modal and then refresh the datatable

        let modaltarget = component.find('IntModal');
        let backdroptarget = component.find('ModalbackdropInt');

        $A.util.removeClass(modaltarget, 'slds-fade-in-open');
        $A.util.removeClass(backdroptarget, 'slds-backdrop--open');
        //helper.populateBillingTable(component,event,helper);

        let modaltargetext = component.find('ExtModal');
        let backdroptargetext = component.find('Modalbackdrop');

        $A.util.removeClass(modaltargetext, 'slds-fade-in-open');
        $A.util.removeClass(backdroptargetext, 'slds-backdrop--open');

        component.set('v.showZuora',false);


    },

    closeAddrModal: function (component, event, helper) {
        component.set("v.showNewAddress", false);
        let modaltarget = component.find('addrModal');
        let backdroptarget = component.find('Modalbackdrop');

        $A.util.removeClass(modaltarget, 'slds-fade-in-open');
        $A.util.removeClass(backdroptarget, 'slds-backdrop--open');

    }

})