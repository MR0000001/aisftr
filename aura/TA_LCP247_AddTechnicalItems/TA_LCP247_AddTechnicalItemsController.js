({
    /*
     * This finction defined column header
     * and calls getProduct2 helper method for column data
     * editable:'true' will make the column editable
     * */

    doInit : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> doInit >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.initialize(component, event, helper);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> doInit >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> closeModal >> Start');
        component.set("v.isInitialized", false);
        component.set("v.data", undefined);
        component.set("v.dataPaginated", undefined);
        component.set("v.dataToShow", undefined);
        component.set("v.pageNumber", 0);
        component.set("v.lastPageNumber", 0);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> closeModal >> End');
    },

    handleChangeShowMaterials : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleChangeShowMaterials >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        if(component.get("v.contestStartCI") == false) {
            helper.getOrdItemFromWoli(component, event, helper);
        } else {
            //DP performance ----- helper.getProduct2(component, helper);
        }
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleChangeShowMaterials >> End');
    },

    onNext : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> onNext >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        let pageNumber = component.get("v.pageNumber") + 1;
        component.set("v.pageNumber", pageNumber);
        let dataPaginated = component.get("v.dataPaginated");
        component.set("v.dataToShow", dataPaginated[pageNumber]);
        let scrollDiv = document.getElementById('ta-modal-technical-item-body');
        scrollDiv.scrollTop = 0;
        helper.fireToggleSpinnerEvent(component, false);
        // window.scrollTo(0, 0);
        // component.set("v.hasPageChanged", true);
        // if(helper.filtersNotIsEmpty(component, event, helper)) {
        //     helper.search(component, event, helper);
        // } else {
        //     helper.getProduct2(component, helper);
        // }
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> onNext >> End');
    },

    onPrev : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> onPrev >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        let pageNumber = component.get("v.pageNumber") - 1;
        component.set("v.pageNumber", pageNumber);
        let dataPaginated = component.get("v.dataPaginated");
        component.set("v.dataToShow", dataPaginated[pageNumber]);
        let scrollDiv = document.getElementById('ta-modal-technical-item-body');
        scrollDiv.scrollTop = 0;
        helper.fireToggleSpinnerEvent(component, false);
        // window.scrollTo(0, 0);
        // component.set("v.hasPageChanged", true);
        // if(helper.filtersNotIsEmpty(component, event, helper)) {
        //     helper.search(component, event, helper);
        // } else {
        //     helper.getProduct2(component, helper);
        // }
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> onPrev >> End');
    },

    onRowSelection : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> onRowSelection >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.handleOnRowSelection(component, event, helper);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> onRowSelection >> End');
    },

    handleSelectProduct2 : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleSelectProduct2 >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        try {
            var elementIdList = event.target.id.split("_");
            var selected = [];
            if(component.get("v.selection")) {
                selected = component.get("v.selection");
            }
            selected.push(elementIdList[0]);

            var dataSelected = [];
            var data = component.get("v.data");
            data.forEach(function(item, index) {
                if(item.glBookEntryId == elementIdList[0]) {
                    dataSelected.push(item);
                }
            });
            component.set("v.selected", dataSelected);
            component.set("v.selection", selected);

            let dataPaginated = component.get("v.dataPaginated");
            let pageNumber = component.get("v.pageNumber");

            dataPaginated[pageNumber].forEach(function(product) {
                if(product.glBookEntryId == elementIdList[0]) {
                    product.selected = true;
                }
            });

            component.set("v.dataPaginated", dataPaginated);
            component.set("v.dataToShow", dataPaginated[pageNumber]);
        } catch(e) {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", e);
        }
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleSelectProduct2 >> End');
    },

    handleDeselectProduct2 : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleDeselectProduct2 >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        component.set("v.removeRunned", true);
        try {
            var elementIdList = event.target.id.split("_");
            let selection = component.get("v.selection");
            selection.forEach(function(item, index) {
                console.log(item + ' ' + index);
                if(item == elementIdList[0]) {
                    selection.splice(index, 1);
                }
            });

            component.set("v.selection", selection);
            component.set("v.selected", selection);

            let dataPaginated = component.get("v.dataPaginated");
            let pageNumber = component.get("v.pageNumber");

            dataPaginated[pageNumber].forEach(function(product) {
                if(product.glBookEntryId == elementIdList[0]) {
                    product.selected = false;
                }
            });

            component.set("v.dataPaginated", dataPaginated);
            component.set("v.dataToShow", dataPaginated[pageNumber]);
        } catch(e) {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", e);
        }
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleDeselectProduct2 >> End');
    },

    /* this method save manual price and manual quantity edit*/
    handleSaveEdition: function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleSaveEdition >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        let draftValues = event.getParam('draftValues');
        component.set("v.manualMapPrice", draftValues);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleSaveEdition >> End');
    },

	checkCategoryFilter : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> checkCategoryFilter >> Start');
        let b = component.get("v.flagDisableCatFilter");
        component.set("v.flagDisableCatFilter", !b);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> checkCategoryFilter >> End');
    },

    /* this method call query on product and consider eventually manual edit filter*/
    doSearch : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> doSearch >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        if(!component.get("v.noItemFound") || helper.filtersNotIsEmpty(component, event, helper)) {
            helper.search(component, event, helper);
        } else {
    		component.set("v.noItemFound", false);
        	helper.getProduct2(component, helper);
    	}
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> doSearch >> End');
    },

	/* this method generate technical conf.item or product required based on paramenter came from scenario*/
    addTechItems : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> addTechItems >> Start');
        helper.fireToggleSpinnerEvent(component, true);
		helper.addTechnicalItems(component, event, helper);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> addTechItems >> End');
    },

    cancelDialog : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> cancelDialog >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        let idElement;
        component.set("v.whichOne", "Cancel");
        if(component.get("v.contestStartCI") == false) {
            idElement = component.get("v.woliRecordId");
        } else {
            idElement = component.get("v.recordId");
        }
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": idElement,
            "slideDevName": "list"
        });
        sObjectEvent.fire();
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> cancelDialog >> End');
    },

    handleGoToSearch2 : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleGoToSearch2 >> Start');
        component.set("v.noItemFound", true);
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleGoToSearch2 >> End');
    },

    handleIsInitializedChange : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleIsInitializedChange >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        if(component.get("v.isInitialized")) {
            helper.initialize(component, event, helper);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log('TA_LCP247_AddTechnicalItems >> Controller >> handleIsInitializedChange >> End');
    }
})