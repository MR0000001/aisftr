({
    initialize : function(component, event) {
        console.log('TA_LCP221_QuestionAnswer >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
        component.set('v.layoutItemSize', 12 / component.get('v.custom').answersPerRow);
        component.set('v.selectedAnswer', null);

        let action = component.get("c.initialize");
        action.setParam("customSerialized", JSON.stringify(component.get("v.custom")));
        action.setCallback(this, function(response) {
            console.log('TA_LCP221_QuestionAnswer >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set("v.infoBag", JSON.parse(response.getReturnValue()));
                let answers = component.get('v.infoBag.answers');
                if(answers != null && answers.length > 0) {
                    answers.forEach(function(answer) {
                        if(answer.label != null && answer.label.length > 35) answer.label = answer.label.substring(0, 30) + '...';
                    });
                }
                component.set('v.infoBag.answers', answers);

                this.fireValidationEvent(component, false, component.get('v.infoBag').question.TA_Label__c);
                this.fireSendInitStateEvt(component, true);
                component.set('v.isInitialized', true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP221_QuestionAnswer >> Helper >> initializeCallback >> End');
        });
        $A.enqueueAction(action);
        console.log('TA_LCP221_QuestionAnswer >> Helper >> initialize >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP221_QuestionAnswer >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP221_QuestionAnswer",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP221_QuestionAnswer >> Helper >> fireSendInitStateEvt >> End');
    },

    fireValidationEvent : function(component, isValid, question) {
        console.log('TA_LCP221_QuestionAnswer >> Helper >> fireValidationEvent >> Start');
        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : 'TA_LCP221_QuestionAnswer',
            "errors" : [$A.get("$Label.c.TA_SectionIsInvalid") + ': ' + question],
            "validate" : isValid
        });
        validationEvt.fire();
        console.log('TA_LCP221_QuestionAnswer >> Helper >> fireValidationEvent >> End');
    },

    selectAnswer : function(component, event) {
        console.log('TA_LCP221_QuestionAnswer >> Helper >> selectAnswer >> Start');
        let oldAnswer = component.get("v.selectedAnswer");
        let newAnswer = event.currentTarget.id;
        let _helper = this;
        if(oldAnswer != newAnswer) {
            if(oldAnswer) {
                let oldIconElem = document.getElementById(oldAnswer).querySelector(".ta-select-icon-container").querySelector(".ta-select-icon");
                oldIconElem.classList.remove("ta-select-icon");
                oldIconElem.classList.add("slds-hidden");
            }
            let newIconElem = document.getElementById(newAnswer).querySelector(".ta-select-icon-container").querySelector(".slds-hidden");
            newIconElem.classList.remove("slds-hidden");
            newIconElem.classList.add("ta-select-icon");
            component.set("v.selectedAnswer", newAnswer);

            let answers = component.get("v.infoBag").answers;
            answers.forEach(function(answer) {
                if(answer.name == newAnswer) {
                    let answerToButton = $A.get("e.c:TA_LCE221_AnswerToButton");
                    answerToButton.setParams({"answerValue": answer.value});
                    answerToButton.fire();
                    _helper.fireValidationEvent(component, true, component.get('v.infoBag').question.TA_Label__c);
                }
            });
        }
        console.log('TA_LCP221_QuestionAnswer >> Helper >> selectAnswer >> End');
    }
})