({
	initialize : function(component) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> initialize >> Start');
        let _helper = this;
        _helper.checkProfileUser(component);        
        console.log('TA_LCP258_HSEQManagement >> Helper >> initialize >> End');
    },

    checkProfileUser : function(component) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> checkProfileUser >> Start');
        let _helper = this;
        let checkIfExternal = component.get('c.checkProfileUser');
    
        checkIfExternal.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                component.set('v.isExternal', response.getReturnValue());
                _helper.getHSEQList(component);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
        });

        $A.enqueueAction(checkIfExternal);
        console.log('TA_LCP258_HSEQManagement >> Helper >> checkProfileUser >> End');
    },

	getHSEQList : function(component) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> getHSEQList >> Start');
        let _helper = this;
        let getHSEQList = component.get('c.getHSEQList');
        getHSEQList.setParams({
            "condition" : JSON.stringify(component.get("v.custom")),
            "isExternal" : component.get('v.isExternal')
        });

        getHSEQList.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                let result = response.getReturnValue();

                let tmpResult = [];
                result.map(res => {
                    if(component.get("v.qualityCheckToReview") && res.toReview) tmpResult.push(res);
                    else if(!component.get("v.qualityCheckToReview") && !res.toReview) tmpResult.push(res);
                });

                component.set('v.hseqList', tmpResult);
                component.set('v.hseqListAll', tmpResult);
                let partners = [];
                let cities = [];
                partners.push($A.get("$Label.c.TA_ViewAll"));
                cities.push($A.get("$Label.c.TA_ViewAll"));
                tmpResult.forEach(function(item) {
                    item.fields.forEach(function(field) {
                        if (field.name == 'partner' && field.value && !partners.includes(field.value)) partners.push(field.value);
                        if (field.name == 'city' && field.value && !cities.includes(field.value)) cities.push(field.value);
                    });
                });

                component.set("v.partnerList", partners);
                component.set("v.cityList", cities);

                /* 21062022 FD - ENXCRM-208 - START */
                var currentDate = new Date();
                var dd = String(currentDate.getDate()).padStart(2, '0');
                var mm = String(currentDate.getMonth()+1).padStart(2, '0');
                var yyyy= currentDate.getFullYear();

                currentDate= yyyy + "-" + mm + "-" + dd;                
                component.set("v.selectedStartDate", currentDate);

                Date.prototype.addDays = function(days) {
                    var date = new Date(this.valueOf());
                    date.setDate(date.getDate() + days);
                    return date;
                }
                
                var date = new Date();
                var endDate = date.addDays(10);
                var dd = String(endDate.getDate()).padStart(2, '0');
                var mm = String(endDate.getMonth()+1).padStart(2, '0');
                var yyyy= endDate.getFullYear();
                endDate= yyyy + "-" + mm + "-" + dd; 
                component.set("v.selectedEndDate", endDate);

                _helper.changeFilterValue(component);

                /* 21062022 FD - ENXCRM-208 - END*/
               
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set('v.isSpinnerVisible', false);
            component.set('v.isInitialized', true);
        });

        $A.enqueueAction(getHSEQList);
        
        console.log('TA_LCP258_HSEQManagement >> Helper >> getHSEQList >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP258_HSEQManagement",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP258_HSEQManagement >> Helper >> fireToggleSpinnerEvent >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> closeModal >> Start');
        component.set("v.isOpen", false);
        component.set('v.isInitialized', false);
        console.log('TA_LCP258_HSEQManagement >> Helper >> closeModal >> End');
    },

    cardClick : function(component, event, helper) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> cardClick >> Start');
        if (!component.get('v.isExternal')){
            this.createWOFromCase(component, event.currentTarget.id)
        } else {
            this.fireAppointmentPreviewEvent(component, event.currentTarget.id);
        }
        console.log('TA_LCP258_HSEQManagement >> Helper >> cardClick >> End');
    },

    createWOFromCase : function(component, caseId) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> createWOFromCase >> Start');
        let createDummyWorkOrderFromCase = component.get('c.createDummyWorkOrderFromCase');
        createDummyWorkOrderFromCase.setParams({
            "caseId" : caseId
        });

        createDummyWorkOrderFromCase.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                let result = response.getReturnValue();
                if(result.success) this.fireAppointmentPreviewEvent(component,result.workOrderId);
                else {       
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", result.errorMessage)
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set('v.isSpinnerVisible', false);
        });

        $A.enqueueAction(createDummyWorkOrderFromCase);
        console.log('TA_LCP258_HSEQManagement >> Helper >> createWOFromCase >> End');
    },

    fireAppointmentPreviewEvent : function(component, urlToRedirect) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> fireAppointmentPreviewEvent >> Start');
        var myEvent = component.getEvent("appointmentPreviewEvent");
        myEvent.setParams({
            "urlToRedirect" : urlToRedirect
        });
        myEvent.fire();
        console.log('TA_LCP258_HSEQManagement >> Helper >> fireAppointmentPreviewEvent >> End');
    },

    changeFilterValue : function(component) {
        console.log('TA_LCP258_HSEQManagement >> Helper >> changeFilterValue >> Start');
    
        function compareMaps(selectedValues, fields) {
            for (let key in selectedValues) {
                for(let j in fields){
                    if(fields[j].name == key && selectedValues[key] != fields[j].value) return false;
                    //XINSAPP-523 - jacopo.scaravaggi@webresults.it - 08/04/2022 - START
                    if(fields[j].name == 'date'){
                        if(Date.parse(fields[j].value) < Date.parse(selectedValues['startDate']) || Date.parse(fields[j].value) > Date.parse(selectedValues['endDate'])) return false;
                    }
                    //XINSAPP-523 - jacopo.scaravaggi@webresults.it - 08/04/2022 - END
                }
            }            

            return true;
        }

        let selectedValuesMap = {};

        if( component.get("v.selectedPartner") && component.get("v.selectedPartner") != $A.get("$Label.c.TA_ViewAll") ) selectedValuesMap['partner'] = component.get("v.selectedPartner");
        if( component.get("v.selectedCity") && component.get("v.selectedCity") != $A.get("$Label.c.TA_ViewAll") ) selectedValuesMap['city'] = component.get("v.selectedCity");
        //XINSAPP-523 - jacopo.scaravaggi@webresults.it - 08/04/2022 - START
        //if( component.get("v.selectedDate") && component.get("v.selectedDate") != $A.get("$Label.c.TA_ViewAll") ) selectedValuesMap['date'] = component.get("v.selectedDate");
        if( component.get("v.selectedStartDate") && component.get("v.selectedStartDate") != $A.get("$Label.c.TA_ViewAll") ) selectedValuesMap['startDate'] = component.get("v.selectedStartDate");
        if( component.get("v.selectedEndDate") && component.get("v.selectedEndDate") != $A.get("$Label.c.TA_ViewAll") ) selectedValuesMap['endDate'] = component.get("v.selectedEndDate");
        //XINSAPP-523 - jacopo.scaravaggi@webresults.it - 08/04/2022 - END

        let filteredList = component.get('v.hseqListAll').filter(function(hseq){

            return compareMaps(selectedValuesMap, hseq.fields);

        });

        console.log(filteredList);
        component.set("v.hseqList", filteredList);

        
        console.log('TA_LCP258_HSEQManagement >> Helper >> changeFilterValue >> End');
    }

})