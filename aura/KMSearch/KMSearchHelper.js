/**
 * Created by LCONATO00 on 15/05/2020.
 */
({
    getTipologiesName : function(component, event){
            component.set("v.showSpinner", true);
            var action = component.get("c.getTipologiesName");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var tipologyMap = [];
                    for(var key in result){
                        tipologyMap.push({key: key, value: result[key]});
                    }
                    component.set("v.articleTipologyNames", tipologyMap);
                    console.log("@@@@ typology "+component.get("v.articleTipologyNames"));
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(action);
        },
    getStatusName : function(component, event){
                component.set("v.showSpinner", true);
                var action = component.get("c.getStatusName");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        var statusMap = [];
                        for(var key in result){
                            statusMap.push({key: key, value: result[key]});
                        }
                        component.set("v.statusName", statusMap);
                    }
                    component.set("v.showSpinner", false);
                });
                $A.enqueueAction(action);
    },
    validateSearch : function(component, event,helper){
        var creationDateFrom = component.get("v.creationDateFrom");
        var creationDateTo = component.get("v.creationDateTo");
        var creationDateSearchCriteriaTo = component.find('creationDateSearchCriteriaTo');
        if(creationDateFrom != null && creationDateTo != null && creationDateFrom>creationDateTo){
            creationDateSearchCriteriaTo.setCustomValidity($A.get("$Label.c.KMSearch_FromGreaterThanTo"));
        }else{
            creationDateSearchCriteriaTo.setCustomValidity("");
            this.searchKnowledgeArticles(component,event,helper);
        }
        creationDateSearchCriteriaTo.reportValidity();

        },
    searchKnowledgeArticles : function(component, event, helper){
        var action = component.get("c.fetchKnowledgeWrapper");
        var tipologyId = component.get("v.articleTipology");
        component.set("v.Faqchosen",tipologyId=='FAQ Interne');
        var creationDateFrom = component.get("v.creationDateFrom");
        var creationDateTo = component.get("v.creationDateTo");
        var knowledgeStatus = component.get("v.status");
        var structureId = component.get("v.messageFromEvent");
        var textToSearchInQuery = component.get("v.textToSearch");
        console.log("structureId in helper",structureId);
        action.setParams({
                    "tipologyId" : (tipologyId!= '' && tipologyId!=null)?tipologyId:null,
                    "creationDateFrom" : creationDateFrom,
                    "creationDateTo" : creationDateTo,
                    "knowledgeStatus" : (knowledgeStatus!= '' && knowledgeStatus!=null)?knowledgeStatus:null,
                    "structureId" : (structureId!= '' && structureId!=null)?structureId:null,
                    "textToSearchInQuery" : (textToSearchInQuery!= '' && textToSearchInQuery!=null)?textToSearchInQuery:null
                });
                component.set("v.showSpinner", true);

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var oRes = response.getReturnValue();
                        if(oRes.length > 0){
                            component.set("v.bNoRecordsFound" , false);
                            component.set("v.searchCompleted",true);
                            component.set('v.listOfAllKnowledge', oRes);
                            var pageSize = component.get("v.pageSize");
                            var totalRecordsList = oRes;
                            var totalLength = totalRecordsList.length ;
                            component.set("v.totalRecordsCount", totalLength);
                            component.set("v.startPage",0);
                            component.set("v.currentPage", 1);
                            component.set("v.endPage",pageSize-1);
                            var PaginationLst = [];
                            for(var i=0; i < pageSize; i++){
                                if(component.get("v.listOfAllKnowledge").length > i){
                                    PaginationLst.push(oRes[i]);
                                }
                            }
                            component.set('v.PaginationList', PaginationLst);
                            component.set("v.selectedCount" , 0);
                            //use Math.ceil() to Round a number upward to its nearest integer
                            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));

                        }else{
                            // if there is no records then display message
                            component.set("v.bNoRecordsFound" , true);
                        }
                    }
                    else{
                        this.handleShowNotice(component, event, helper, {
                                                                   'header': $A.get("$Label.c.KMSearch_Error"),
                                                                   'message': response.getError()[0].message,
                                                                   'variant': 'error',
                                                                   'toReload': false
                                                                   });
                    }
                    component.set("v.showSpinner", false);
                });
                $A.enqueueAction(action);
    },
    handleShowNotice: function(component, event, helper, message) {
             component.find('notifLib').showNotice({
                 "variant": message.variant,
                 "header": message.header,
                 "message": message.message,
                 closeCallback: function() {
                     if(message.toReload){
                        console.log('### reload page');
                        setTimeout(function(){location.reload();}, 500);
                     }

                 }
             });
         },
    // navigate to next pagination record set
        next : function(component,event,sObjectList,end,start,pageSize){
            var Paginationlist = [];
            var counter = 0;
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){

                        Paginationlist.push(sObjectList[i]);

                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set('v.PaginationList', Paginationlist);
        },
        // navigate to previous pagination record set
        previous : function(component,event,sObjectList,end,start,pageSize){
            var Paginationlist = [];
            var counter = 0;
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){

                        Paginationlist.push(sObjectList[i]);

                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set('v.PaginationList', Paginationlist);
        },
        // navigate to last pagination record set
        last : function(component,event,sObjectList,end,start,pageSize){
            var Paginationlist = [];
            var totalCount = component.get("v.totalRecordsCount");
            var totalPages = component.get("v.totalPagesCount");
            for(var i= (totalPages-1) * pageSize; i < totalCount ; i++){
                if(i > -1){
                        Paginationlist.push(sObjectList[i]);
                }
            }
            start = (totalPages-1) * pageSize;
            end = totalPages * pageSize-1;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set('v.PaginationList', Paginationlist);
        },
        // navigate to first pagination record set
        first : function(component,event,sObjectList,end,start,pageSize){
            var Paginationlist = [];
            var size = Math.min(sObjectList.length, pageSize);
            for(var i= 0; i < size ; i++){
                if(i > -1){
                        Paginationlist.push(sObjectList[i]);

                }
            }
            start = 0;
            end = pageSize-1;
            component.set("v.startPage",start);
            component.set("v.endPage",end);
            component.set('v.PaginationList', Paginationlist);
        },
        sortBy: function(component, field) {

                var sortAsc = component.get("v.sortAsc"),
                    sortField = component.get("v.sortField"),
                    records = component.get("v.listOfAllKnowledge"),
                    fieldPath = field.split(/\./),
                    fieldValue = this.fieldValue;
                sortAsc = sortField != field || !sortAsc;
                records.sort(function(a,b){
                    var aValue = fieldValue(a, fieldPath).toLowerCase(),
                        bValue = fieldValue(b, fieldPath).toLowerCase(),
                        t1 = aValue == bValue,
                        t2 = (!aValue && bValue) || (aValue < bValue);
                    return t1? 0: (sortAsc?-1:1)*(t2?1:-1);

                });
                component.set("v.sortAsc", sortAsc);
                component.set("v.sortField", field);
                component.set("v.listOfAllKnowledge", records);
                var sObjectList = component.get("v.listOfAllKnowledge");
                var pageSize = component.get("v.pageSize");
                component.set("v.currentPage", 1);
                   var end = component.get("v.endPage");
                   var start = component.get("v.startPage");
                    this.first(component, event, sObjectList, end, start, pageSize);
            },
            fieldValue: function(object, fieldPath) {
                var result = object;
                fieldPath.forEach(function(field) {
                    if(result) {
                         if(result[field] != undefined){
                             result = result[field];
                         }else{
                             result = ' ';
                         }
                    }
                });
                return result;
            },

})