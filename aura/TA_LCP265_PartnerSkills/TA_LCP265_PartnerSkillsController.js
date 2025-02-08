({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP265_PartnerSkills >> Controller >> handleInitialize >> End');
    },

    handleToggleSkills : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills >> Controller >> toggleSkills >> Start');
        helper.toggleSkills(component, event, helper);
        console.log('TA_LCP265_PartnerSkills >> Controller >> toggleSkills >> End');
    },

    handleGoPrevious : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills >> Controller >> handleGoPrevious >> Start');
        helper.goPrevious(component, event, helper);
        console.log('TA_LCP265_PartnerSkills >> Controller >> handleGoPrevious >> End');
    },

    handleGoNext : function(component, event, helper) {
        console.log('TA_LCP265_PartnerSkills >> Controller >> handleGoNext >> Start');
        helper.goNext(component, event, helper);
        console.log('TA_LCP265_PartnerSkills >> Controller >> handleGoNext >> End');
    },
})