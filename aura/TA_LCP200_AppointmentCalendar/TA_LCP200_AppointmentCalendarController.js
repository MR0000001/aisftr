({
    handleInitialize : function (component, event, helper) {
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> handleInitialize >> Start');
        helper.initialize(component, false);
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> handleInitialize >> End');
    },

    handleCardClick : function (component, event, helper) {
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> handleCardClick >> Start');
        helper.cardClick(component, event, helper);
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> handleCardClick >> End');
    },

    handleInitializeRefresh : function (component, event, helper) {
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> handleInitializeRefresh >> Start');
        //Remove cookie
        var cookieName = "selectedDate";
        helper.setCookie(cookieName, "", -1); // remove cookie
        helper.initialize(component, true);
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> handleInitializeRefresh >> End');
    },

    afterRender : function(component, event, helper) {
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> afterRender >> Start');
        this.superAfterRender();
        var targetEl = component.find("mainapp").getElement();
        targetEl.addEventListener("touchmove", function(e) {
            helper.initialize(component, true);
        }, false);
        console.log('TA_LCP200_AppointmentCalendar >> Controller >> afterRender >> End');
    }
})