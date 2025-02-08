({
    populatePickValues: function (component, event, helper) {
        let action = component.get("c.getPicklistTechnicalValues");
        action.setCallback(this, function (a) {
            let state = a.getState();
            let techSkillList = a.getReturnValue();
            console.log('@@@@' + techSkillList);
            if (state === "SUCCESS") {
                component.set('v.techSkillOptions', helper.populatePicklist(component, event, helper, techSkillList, false));
                this.populatePickValuesCoverageTechSkill(component, event, helper);
                this.setFieldValues(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    populatePickValuesCoverageTechSkill: function (component, event, helper) {
        let action = component.get("c.getPicklistCoverageTechSkill");
        action.setCallback(this, function (a) {
            let state = a.getState();
            let CovTechSkillOptions = a.getReturnValue();
            console.log('@@@@' + CovTechSkillOptions);
            if (state === "SUCCESS") {
                component.set('v.CovTechSkillOptions', helper.populatePicklist(component, event, helper, CovTechSkillOptions, true));
                this.populatePickValuesWtCategory(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    populatePickValuesWtCategory: function (component, event, helper) {
        let action = component.get("c.getPicklistWorkTypeLabel");
        action.setCallback(this, function (a) {
            let state = a.getState();
            let wtCategoryOptions = a.getReturnValue();
            console.log('@@@@' + wtCategoryOptions);
            if (state === "SUCCESS") {
                component.set('v.wtCategoryOptions', helper.populatePicklistValue(component, event, helper, wtCategoryOptions));
            }
        });
        $A.enqueueAction(action);
    },

    populatePicklistValue: function (component, event, helper, listOptions) {
        let opts = [];
        for (let i = 0; i < listOptions.length; i++) {
            opts.push({
                value: listOptions[i].value,
                label: listOptions[i].label
            });
        }
        opts.push({
            value: '',
            label: $A.get("$Label.c.XC_CL_NoneText")
        });
        return opts;
    },

    populatePicklist: function (component, event, helper, listOptions, covTechSkill) {
        let opts = [];
        if(covTechSkill) {
            opts.push({
                value: '',
                label: $A.get("$Label.c.XC_CL_NoneText")
            });
        }
        for (let i = 0; i < listOptions.length; i++) {
            opts.push({
                value: listOptions[i],
                label: listOptions[i]
            });
        }
        return opts;
    },


    setFieldValues: function (component, event, helper) {
        let action = component.get("c.setFieldsValues");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                if (result) {
                    component.set("v.selectedTechSkill", result.XC_TechnicalSkill__c);
                    component.set("v.selectedCovTechSkill", result.XC_CoverageTechnicalSkill__c);
                    component.set("v.selectedWorkTypeCategory", result.XC_WorkTypeName__c);
                    component.set("v.skillId", result.XC_SkillId__c);
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, message, type) {
        component.set("v.spinnerControl", false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    },
    closeCurrentTab: function (component, event, helper, toRedirect) {

        let navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": toRedirect, "slideDevName": "detail", "isredirect": true });
        navigateEvent.fire();
    },
    goBack: function (component, event) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            let focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
    },

    updateProductSkillAssociation: function (component, event, helper) {
        let action = component.get("c.updateProductSkillAssociation");
        let mapSkillAss = {
            'selectedTechSkill': component.get("v.selectedTechSkill"),
            'selectedCovTechSkill': component.get("v.selectedCovTechSkill"),
            'workTypeLabel': component.get("v.selectedWorkTypeCategory"),
            'skillId': component.get("v.skillId"),
            'skillName': component.get("v.skillName"),
            'recordId': component.get("v.recordId")
        };
        console.log('@@@ mapSkillAss -> ', mapSkillAss);
        let mapSkillAssString = JSON.stringify(mapSkillAss);
        action.setParams({
            'mapSkillAssString': mapSkillAssString
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                if (result.success) {
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Success"), "success");
                    $A.get("e.force:refreshView").fire();
                    $A.get("e.force:closeQuickAction").fire();
                    this.closeCurrentTab(component, event, helper, result.recordId);
                }
                else {
                    helper.showToast(component, event, helper, result.resultMessage, "error");
                }
            }
        });
        $A.enqueueAction(action);
    }


})