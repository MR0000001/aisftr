/**
 * Created by LCONATO00 on 15/05/2020.
 */
({
    doInit: function(component, event, helper) {
            helper.getTipologiesName(component, event);
            helper.getStatusName(component, event);
            var workspaceAPI = component.find("workspaceKMSearch");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: $A.get("$Label.c.KMSearch_TitleTab")
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "utility:search",
                    iconAlt: $A.get("$Label.c.KMSearch_TitleTab")

                });
            })
            .catch(function(error) {
                console.log(error);
            });
    },
    searchKnowledgeArticles: function(component, event, helper) {
                helper.validateSearch(component, event, helper);
    },
    resetFilters: function(component, event, helper) {
        component.set("v.articleTipology","");
        component.set("v.status","");
        component.set("v.creationDateFrom",null);
        component.set("v.creationDateTo",null);
        component.set("v.searchCompleted",false);
        component.set("v.messageFromEvent","");
        component.set("v.textToSearch","");
        var autComplComponent = component.find("structure-record");
        var callMethod = autComplComponent.clearOption();
     },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllKnowledge");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'last' then call 'last' helper method
            else if (whichBtn == 'last') {
                component.set("v.currentPage", component.get("v.totalPagesCount"));
                helper.last(component, event, sObjectList, end, start, pageSize);
            }
        // check if whichBtn value is 'first' then call 'first' helper method
                else if (whichBtn == 'first') {
                    component.set("v.currentPage", 1);
                    helper.first(component, event, sObjectList, end, start, pageSize);
                }
    },
    sortByTitle: function(component, event, helper) {
        helper.sortBy(component, "objKnowledge.Title");
    },
    sortByTipology: function(component, event, helper) {
        helper.sortBy(component, "objKnowledge.ArticleType__c");
    },
    sortByCategory: function(component, event, helper) {
            helper.sortBy(component, "objKnowledge.Category__c");
        },
    sortByStatus: function(component, event, helper) {
        helper.sortBy(component, "objKnowledge.PublishStatus");
    },
    sortByMacrostructure: function(component, event, helper) {
            helper.sortBy(component, "objKnowledge.MacrostructureReference__r.ExtendedName__c");
    },
    sortByCreatedDate: function(component, event, helper) {
        helper.sortBy(component, "objKnowledge.CreatedDate");
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.id;
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
        },

    navigateToNewKnowledge: function(component, event, helper) {
        var navService = component.find("navService");
        var pageRef = {
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Knowledge__kav",
                actionName: "new"
            },
            state: {
                nooverride: "1",
                useRecordTypeCheck: "1"
            }
        }
        navService.navigate(pageRef);
        },

    handleKeyPress : function (component,event,helper){
        

        var textInserted = component.get("v.textToSearch");
        console.log("tuo oggetto",JSON.stringify(textInserted));
        var splittedText = [];
        splittedText = textInserted.split(" ");
        console.log (splittedText.length);
        console.log(splittedText);
        if(splittedText.length > 2){
            splittedText.splice(2,1);
            component.set("v.textToSearch",splittedText[0] + ' ' + splittedText[1]);
            console.log(splittedText);
            var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "ERRORE",
                        "type": "error",
                        "message": $A.get("$Label.c.KMSearch_HelpText")
                    });
                }
                    toastEvent.fire();
        
        }
        
    },

    handleEvent : function (component,event,helper){
        var message = event.getParam("PassStructure");
        component.set("v.messageFromEvent",message);
        var str = component.get("v.messageFromEvent")
        console.log("idstruttura ", str);
    },

    handleEventDeletedIdStructure : function (component,event,helper){
        var message = event.getParam("DeleteStructureEvent");
        component.set("v.messageFromEvent",message);
        var str = component.get("v.messageFromEvent")
        console.log("idstruttura ", str);
    }

})