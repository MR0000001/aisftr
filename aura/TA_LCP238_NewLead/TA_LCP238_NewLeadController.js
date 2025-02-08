({
    init: function (component, event, helper) {
        console.log('InCommunityExperience = ' + component.get("v.isCommunity"));
        helper.doInit(component, helper);
    },

    onSubmit: function (component, event, helper) {
        helper.onSubmitHelper(component, event, helper);
    },

    checkIfNIE: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if (selectedOptionValue != 'undefined' && selectedOptionValue === 'NIE') {
            component.set("v.showDate", true);
        } else {
            component.set("v.showDate", false);
        }
    },
    assignLeadChecked: function (component, event, helper) {
        helper.assignLeadCheckedHelper(component, event);
    },
    changePickVal: function (component, event, helper) {
        helper.changePickVal(component, event);
    },
    controlMandatoryFields: function (component, event, helper) {

    },
    openInsert: function (component, event, helper) {
        component.set("v.insertAddressClicked", false);
        helper.openInsert(component, event, helper);
    },
    handleComponentEvent: function (component, event, helper) {
        let map = event.getParam("address");
        console.log('ricevuta mappa ' + JSON.stringify(map));
        let withoutValidate = event.getParam("withoutValidate");
        component.set("v.withoutValidate", withoutValidate);
        let mandatoryFields = event.getParam("checkValue");
        component.set("v.addressMandatoryFields", mandatoryFields);
        component.set("v.addressFromEvent", map);

        component.set("v.changeIcon", true);

    },

    handleLEConsentsEvent: function (component, event, helper) {
        let relatedObject = event.getParam("relatedObject");
        if (relatedObject === 'Lead') {
            let consentsLE = event.getParam("consentsLE");
            let robinsonCustomer = event.getParam("robinsonCustomer");
            let thirdPartiesCheck = event.getParam("thirdPartiesCheck");
            let thirdPartiesVersion = event.getParam("thirdPartiesVersion");
            component.set("v.consentsLE", consentsLE);
            component.set("v.robinsonCustomer", robinsonCustomer);
            component.set("v.thirdPartiesCheck", thirdPartiesCheck);
            component.set("v.thirdPartiesVersion", thirdPartiesVersion);
        }
    },

    setAddressOpenable: function (component, event, helper) {

        let alwaysSet = event.getParam("alreadyPush");
        component.set("v.insertAddressClicked", true);
        component.set("v.alreadyPush", alwaysSet);
    },


    canInsertField: function (component, event, helper) {
        helper.onSubmitHelper(component, event);
    },

    goBackInCommunity: function (component, event, helper) {
        /*let windowRedirect = window.location.href;
        window.location.href = windowRedirect;*/
        helper.redirectToPage(component, "", true);
    },

    goBack: function (component, event, helper) {
        //helper.goBack(component, event);
        helper.redirectToPage(component, "", true);
    },
    setAddressOn: function (component, event, helper) {
        let checkbox = component.get("v.showAddress");
        if (checkbox) {
            component.set("v.showAddress", false);
        } else {
            component.set("v.showAddress", true);
        }
    },



    setDocOn: function (component, event, helper) {
        let checkbox = component.get("v.showDocument");
        if (checkbox) {
            var identityN = component.find("XC_DocumentNumber__c").get("v.value");
            component.set("v.numberAppoggio", identityN);
            //var exDate = component.find("XC_NIE_expiration_date__c").get("v.value");
            var exDate = component.get("v.expDate");
            component.set("v.exDateAppoggio", exDate);
            if (component.find("XC_NIE_expedition_date__c") != 'undefined' && component.find("XC_DocumentType__c") === 'NIE') {
                //var rDate = component.find("XC_NIE_expiration_date__c").get("v.value");
                var rDate = component.get("v.expDate");
                component.set("v.rDateAppoggio", rDate);
            }

            component.set("v.showDocument", false);
        } else {

            component.set("v.showDocument", true);
            component.find("XC_DocumentNumber__c").set("v.value", component.get("v.numberAppoggio"));
            //component.find("XC_NIE_expiration_date__c").set("v.value", component.get("v.exDateAppoggio"));
            component.set("v.expDate", component.get("v.exDateAppoggio"));
            if (component.find("XC_NIE_expedition_date__c") != 'undefined' && component.find("XC_DocumentType__c") === 'NIE') {
                component.find("XC_NIE_expedition_date__c").set("v.value", component.get("v.rDateAppoggio"));

            }

        }
    },

    handleSaveConsentsEvent: function (component, event, helper) { //dpalamides
            let relatedObject = event.getParam("consentsWrapper");
            component.set("v.saveConsentsWrapper",relatedObject);
            console.log("consentsEvent:"+JSON.stringify(relatedObject));
    },

    handleScheduleToday : function (component, event, helper) {
        helper.scheduleToday(component, event, helper);
    },

    handleScheduleOtherDay : function (component, event, helper) {
        helper.scheduleOtherDay(component, event, helper);
    },

    handleBookAppointmentModal : function (component, event, helper) {
        console.log('TA_LCP238_NewLead >> Controller >> handleBookAppointmentModal >> Start');
        helper.bookAppointmentModal(component, event, helper);
        console.log('TA_LCP238_NewLead >> Controller >> handleBookAppointmentModal >> End');
    },

    handleLeadCreatedOk : function (component, event, helper) {
        console.log('TA_LCP238_NewLead >> Controller >> handleLeadCreatedOk >> Start');
        helper.leadCreatedOk(component, event, helper);
        console.log('TA_LCP238_NewLead >> Controller >> handleLeadCreatedOk >> End');
    },

    handleCreateOnlyLead : function (component, event, helper) {
        console.log('TA_LCP238_NewLead >> Controller >> handleCreateOnlyLead >> Start');
        helper.createOnlyLead(component, event, helper);
        console.log('TA_LCP238_NewLead >> Controller >> handleCreateOnlyLead >> End');
    },

    handleCreateLeadAndSell : function (component, event, helper) {
        console.log('TA_LCP238_NewLead >> Controller >> handleCreateLeadAndSell >> Start');
        helper.createLeadAndSell(component, event, helper);
        console.log('TA_LCP238_NewLead >> Controller >> handleCreateLeadAndSell >> End');
    },

    handleDoRollback : function (component, event, helper) {
        console.log('TA_LCP238_NewLead >> Controller >> handleDoRollback >> Start');
        let action = event.getParam("action");
        if  (action == 'sendError'){
            helper.doRollback(component, event, helper);
        }
        console.log('TA_LCP238_NewLead >> Controller >> handleDoRollback >> End');
    },

    handleCompleteFlow : function (component, event, helper) {
        console.log('TA_LCP238_NewLead >> Controller >> handleCompleteFlow >> Start');
        helper.completeFlow(component, event, helper);
        console.log('TA_LCP238_NewLead >> Controller >> handleCompleteFlow >> End');
    }
})