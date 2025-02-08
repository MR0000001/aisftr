({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP205_Homepage >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP205_Homepage >> Controller >> handleInitialize >> End');
    },

    handleManageRedirect : function(component, event, helper) {
        let tabType = event.currentTarget.name;
        let redirectParam = '';

        if(tabType == 'agenda') {
            redirectParam = 'custom-calendar';
        } else if(tabType == 'newaccount') {
            // redirectParam = 'createnewlead';
            redirectParam = component.get("v.redirectParamAccount");
        } else if(tabType == 'account') {
            //redirectParam = 'account/Account';
            component.set("v.showSelectAccountModal", true);
            return;
        } else if(tabType == 'case') {
            redirectParam = 'recordlist/Case/Default';
        } else if(tabType == 'asset') {
            redirectParam = 'recordlist/Asset/Default';
        } else if(tabType == 'appointmentToBeConfirmed') {
            component.set("v.showAppointmentToBeConfirmed", true);
            return;
        } else if(tabType == 'workorder') {
            redirectParam = 'recordlist/WorkOrder/Default';
        }

        helper.redirectToPage(component, redirectParam, true);
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP205_Homepage >> Controller >> handleCloseModal >> Start');
        helper.closeModal(component, event, helper);
        console.log('TA_LCP205_Homepage >> Controller >> handleCloseModal >> End');
    },

    /*handleAgendaRedirect : function(component, event, helper) {
        console.log('TA_LCP205_Homepage >> Controller >> handleAgendaRedirect >> Start');
        helper.redirectToPage(component, 'custom-calendar', true);
        console.log('TA_LCP205_Homepage >> Controller >> handleAgendaRedirect >> End');
    },

    handleLeadRedirect : function(component, event, helper) {
        console.log('TA_LCP205_Homepage >> Controller >> handleLeadRedirect >> Start');
        helper.redirectToPage(component, 'createnewlead', true);
        console.log('TA_LCP205_Homepage >> Controller >> handleLeadRedirect >> End');
    },

    handleAccountRedirect : function(component, event, helper) {
        console.log('TA_LCP205_Homepage >> Controller >> handleAccountRedirect >> Start');
        helper.redirectToPage(component, 'account/Account', true);
        console.log('TA_LCP205_Homepage >> Controller >> handleAccountRedirect >> End');
    }*/
})