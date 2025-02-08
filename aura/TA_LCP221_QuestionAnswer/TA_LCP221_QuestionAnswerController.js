({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP221_QuestionAnswer >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event);
        console.log('TA_LCP221_QuestionAnswer >> Controller >> handleInitialize >> End');
    },

    handleSelectAnswer : function(component, event, helper) {
        console.log('TA_LCP221_QuestionAnswer >> Controller >> handleSelectedAnswer >> Start');
        helper.selectAnswer(component, event);
        console.log('TA_LCP221_QuestionAnswer >> Controller >> handleSelectedAnswer >> End');
    },

    handleRefresh : function(component, event, helper) {
        console.log('TA_LCP221_QuestionAnswer >> Controller >> handleRefresh >> Start');
        if(event.getParam("action") == 'question-answer-blank') {
            helper.initialize(component, event);
        }
        console.log('TA_LCP221_QuestionAnswer >> Controller >> handleRefresh >> End');
    }
})