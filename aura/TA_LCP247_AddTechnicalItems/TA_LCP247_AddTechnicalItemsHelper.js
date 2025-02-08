({
    initialize : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> initialize >> Start');
        component.set('v.columns', [
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'Service Position', fieldName: 'positionName', type: 'text'},
            {label: 'Product Code', fieldName: 'productCode', type: 'text'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'Price', fieldName: 'prodPrice', type: 'text', typeAttributes: {currencyCode: 'EUR'}},
            {label: 'Quantity', fieldName: 'Quantity', type: 'text', editable: true}
        ]);

        if(component.get("v.contestStartCI") == false) {
            component.set("v.noItemFound", true);
            helper.getOrdItemFromWoli(component, event, helper);
        } else {
            helper.checkValidItem(component, event, helper);
            component.set("v.noItemFound", true);
        }
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> initialize >> End');
    },

    getProduct2 : function(component, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> getProduct2 >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        let action = component.get("c.getLimitedProduct2");
		let listParam = {
            pageSize : component.get("v.pageSize").toString(),
            pageNumber : component.get("v.pageNumber").toString(),
			orderItemId : component.get("v.recordId"),
            rtWoli: component.get("v.rtWoli"), // retrieve country from contest product required
            searchMaterial : component.get("v.showMaterials"),
            segment : component.get("v.woliSegment"),
            woliId : component.get("v.woliRecordId")
        };

        action.setParams({
            'listParam': JSON.stringify(listParam)
		});

        action.setCallback(this, function(response) {
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> getProduct2Callback >> Start');
            if(response.getState() == "SUCCESS") {
                let result = response.getReturnValue();
                let objInfo = [];
                if(window.location.origin.search("exdevhub") != -1) {
                    result.objectInfo = "{\"legalEntity\":\"EnelXItalia\",\"country\":\"Italy\",\"showSelectMaterial\":false,\"product2List\":[{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"LoT2\",\"prodPrice\":\"124.00\",\"positionName\":null,\"positionCode\":null,\"name\":\"Product Lot2Test\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E0000077EQmQAM\",\"idGlProduct\":\"a7G0D0000008glkUAA\",\"id\":\"a7G0D0000008glkUAA\",\"glBookEntryId\":\"a7G0D0000008glkUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"LoT3\",\"prodPrice\":\"40.00\",\"positionName\":null,\"positionCode\":null,\"name\":\"Product Lot3Test\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E0000077F3ZQAU\",\"idGlProduct\":\"a7G0D0000008gllUAA\",\"id\":\"a7G0D0000008gllUAA\",\"glBookEntryId\":\"a7G0D0000008gllUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"Pr_SERIAL_1\",\"prodPrice\":\"111.00\",\"positionName\":null,\"positionCode\":null,\"name\":\"Product Serialized Test\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E0000076pOVQAY\",\"idGlProduct\":\"a7G0D0000008glmUAA\",\"id\":\"a7G0D0000008glmUAA\",\"glBookEntryId\":\"a7G0D0000008glmUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null}]}";
                }

                objInfo = JSON.parse(result.objectInfo);
                component.set("v.showFlagForMaterials", objInfo['showSelectMaterial']);

                let dataPaginated = {};
                let dataInPage = [];
                let countPage = 0;
                objInfo['product2List'].forEach(function(product2) {
                    product2.selected = false;
                    dataInPage.push(product2);
                    if(dataInPage.length >= component.get("v.pageSize")) {
                        dataPaginated[countPage] = dataInPage;
                        dataInPage = [];
                        countPage ++;
                    }
                });

                if(dataInPage.length) {
                    dataPaginated[countPage] = dataInPage;
                }

                component.set("v.dataPaginated", dataPaginated);
                component.set("v.dataToShow", dataPaginated["0"]);
                component.set("v.lastPageNumber", Object.keys(dataPaginated).length);

                // if(objInfo['product2List'].length < component.get("v.pageSize")) {
                //     component.set("v.isLastPage", true);
                // } else {
                //     component.set("v.isLastPage", false);
                // }

                //Modify response to include the page number as well
                //in the id attribute of each row
                //This will help us to filter out the rows displayed on each page
                objInfo['product2List'].forEach(function(row) {
                	row.Id = row.Id + '-' + component.get("v.pageNumber").toString();
                });

                if(objInfo['product2List'].length > 0) {
                    let cntrId = objInfo['product2List'][0].contractId;
                    component.set("v.contractId", cntrId);
                }

                component.set("v.resultSize", objInfo['product2List'].length);
                component.set("v.data", objInfo['product2List']);
                component.set("v.country", objInfo['country']);
                //Set selected rows with our selection attribute which has id of each attribute
				component.find("product2DataTable").set("v.selectedRows", component.get("v.selection"));
                component.set("v.hasPageChanged", false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> getProduct2Callback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> cancelDialog >> End');
    },

    /* if called is from ProductRequired Function */
    getOrdItemFromWoli : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> getOrdItemFromWoli >> Start');
        let action = component.get("c.getOrderItemFromWoli");

        action.setParams({
           	'woliId' : component.get("v.woliRecordId")
		});

        action.setCallback(this, function(response) {
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> getOrdItemFromWoliCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
					component.set("v.country", response.getReturnValue()[0].country);
                    component.set("v.rtWoli", response.getReturnValue()[0].rtWoli);
                    component.set("v.workOrderId", response.getReturnValue()[0].workOrderId);
                    component.set("v.woliSegment", response.getReturnValue()[0].segment);
                    component.set("v.woliLegalEntity", response.getReturnValue()[0].legalEntity);
				}
			} else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> getOrdItemFromWoliCallback >> End');
		});

		$A.enqueueAction(action);
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> getOrdItemFromWoli >> End');
	},

    filtersNotIsEmpty : function(component, event, helper) {
        if(component.find("Product2Name").get("v.value")) {
            return true;
        }
        if(component.find("TypeName").get("v.value")) {
            return true;
        }
        if(component.find("SapCode").get("v.value")) {
            return true;
        }
        if(component.find("PositionName").get("v.value")) {
            return true;
        }
        if(component.find("FlagApplyFilter").get("v.value")) {
            return true;
        }
        return false;
    },

    search : function(component, event, helper){
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> search >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        var filterMap = [component.find("Product2Name").get("v.value"),
                            component.find("TypeName").get("v.value"),
                            component.find("SapCode").get("v.value"),
                            component.find("PositionName").get("v.value"),
                            component.get("v.flagDisableCatFilter")
                        ];

        let listParam = {
                    pageSize : component.get("v.pageSize").toString(),
                    pageNumber : component.get("v.pageNumber").toString(),
        			orderItemId : component.get("v.recordId"),
                    rtWoli: component.get("v.rtWoli"), // retrieve country from contest product required
                    searchMaterial : component.get("v.showMaterials"),
                    segment : component.get("v.woliSegment"),
                    woliId : component.get("v.woliRecordId"),
                    searchFilters :filterMap
                };

        let action = component.get("c.getLimitedProduct2");

        action.setParams({
            'listParam':JSON.stringify(listParam)
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> searchCallback >> Start');
            component.set("v.noItemFound", false);
            if(response.getState() == "SUCCESS") {
                let result = response.getReturnValue();
                let objInfo = [];
                if(window.location.origin.search("exdevhub") != -1) {
                    result.objectInfo = "{\"legalEntity\":\"EnelXItalia\",\"country\":\"Italy\",\"showSelectMaterial\":false,\"product2List\":[{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"LoT2\",\"prodPrice\":\"124.00\",\"positionName\":null,\"positionCode\":null,\"name\":\"Product Lot2Test\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E0000077EQmQAM\",\"idGlProduct\":\"a7G0D0000008glkUAA\",\"id\":\"a7G0D0000008glkUAA\",\"glBookEntryId\":\"a7G0D0000008glkUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"LoT3\",\"prodPrice\":\"40.00\",\"positionName\":null,\"positionCode\":null,\"name\":\"Product Lot3Test\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E0000077F3ZQAU\",\"idGlProduct\":\"a7G0D0000008gllUAA\",\"id\":\"a7G0D0000008gllUAA\",\"glBookEntryId\":\"a7G0D0000008gllUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"Pr_SERIAL_1\",\"prodPrice\":\"111.00\",\"positionName\":null,\"positionCode\":null,\"name\":\"Product Serialized Test\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E0000076pOVQAY\",\"idGlProduct\":\"a7G0D0000008glmUAA\",\"id\":\"a7G0D0000008glmUAA\",\"glBookEntryId\":\"a7G0D0000008glmUAA\",\"country\":null,\"contractId\":null},{\"workOrderId\":null,\"type\":\"Material\",\"segment\":null,\"rtWoli\":null,\"quantity\":\"0\",\"productCode\":\"DEPRECATED-125540902B\",\"prodPrice\":null,\"positionName\":null,\"positionCode\":null,\"name\":\"Spare Part Partner Test2\",\"legalEntity\":null,\"isoCode\":null,\"idProduct\":\"01t6E00000759ihQAA\",\"idGlProduct\":\"a7G0D0000008glnUAA\",\"id\":\"a7G0D0000008glnUAA\",\"glBookEntryId\":\"a7G0D0000008glnUAA\",\"country\":null,\"contractId\":null}]}";
                }

                objInfo = JSON.parse(result.objectInfo);
                component.set("v.showFlagForMaterials", objInfo['showSelectMaterial']);

                let dataPaginated = {};
                let dataInPage = [];
                let countPage = 0;
                objInfo['product2List'].forEach(function(product2) {
                    product2.selected = false;
                    dataInPage.push(product2);
                    if(dataInPage.length >= component.get("v.pageSize")) {
                        dataPaginated[countPage] = dataInPage;
                        dataInPage = [];
                        countPage ++;
                    }
                });

                if(dataInPage.length) {
                    dataPaginated[countPage] = dataInPage;
                }

                component.set("v.dataPaginated", dataPaginated);
                component.set("v.dataToShow", dataPaginated["0"]);
                component.set("v.lastPageNumber", countPage);

                // if(objInfo['product2List'].length < component.get("v.pageSize")) {
                //     component.set("v.isLastPage", true);
                // } else {
                //     component.set("v.isLastPage", false);
                // }

                //Modify response to include the page number as well
                //in the id attribute of each row
                //This will help us to filter out the rows displayed on each page
                objInfo['product2List'].forEach(function(row) {
                    row.Id = row.Id+'-'+ component.get("v.pageNumber").toString();
                });

                if(objInfo['product2List'].length > 0) {
                    let cntrId = objInfo['product2List'][0].contractId;
                    component.set("v.contractId", cntrId);
                }

                component.set("v.resultSize", objInfo['product2List'].length);
                component.set("v.data", objInfo['product2List']);
                component.set("v.country", objInfo['country']);
                //Set selected rows with our selection attribute which has id of each attribute
                component.find("product2DataTable").set("v.selectedRows", component.get("v.selection"));
                component.set("v.hasPageChanged", false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> searchCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> search >> End');
    },

    addTechnicalItems : function(component, event, helper){
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> addTechnicalItems >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        try {
            let recordIdNavigate;
            let items = component.get("v.selection");
            let contestCI = component.get("v.contestStartCI");
            let listParam = {
                rows: JSON.stringify(items),
                contractId : component.get("v.contractId"),
                ordItem: component.get("v.orderItemRecord"),
                woliId:component.get("v.woliRecordId"),
                wbeElement: component.get("v.wbeElement"),
                costCenter: component.get("v.costCenter"),
                contestCI:contestCI,
                mapManualPrice: JSON.stringify(component.get("v.manualMapPrice")),
                workOrderId : component.get("v.workOrderId"),
                rtWoli : component.get("v.rtWoli"),
                segment : component.get("v.woliSegment"),
                legalEntity : component.get("v.woliLegalEntity"),
            };

            if(items.length > 0) {
                let action = component.get("c.generateTechnicalItems");

                action.setParams({
                    'listParam' : JSON.stringify(listParam),
                    'selectedProduct' : component.get("v.selected"),
                    'mapManualPrice': JSON.stringify(component.get("v.manualMapPrice"))
                });

                if(contestCI) {
                    recordIdNavigate = component.get("v.orderItemRecord").Id;
                } else {
                    recordIdNavigate = component.get("v.woliRecordId");
                }

                action.setCallback(this, function(response) {
                    console.log('TA_LCP247_AddTechnicalItems >> Helper >> addTechnicalItemsCallback >> Start');
                    if(response.getState() == "SUCCESS") {
                        let type = response.getReturnValue().typeMessage;
                        let message = response.getReturnValue().resultMessage;
                        let titleMessage = response.getReturnValue().titleMessage;

                        let isError = false;
                        if(type == "Error") {
                            isError = true;
                        }

                        component.set("v.showToastMessage", true);
                        component.set("v.isError", isError);
                        component.set("v.toastMessage", titleMessage + ': ' + message);
                        helper.fireRefreshEvt(component);
                    } else if(response.getState() == "ERROR") {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.stringify(response.getError()));
                    }
                    helper.fireToggleSpinnerEvent(component, false);
                    console.log('TA_LCP247_AddTechnicalItems >> Helper >> addTechnicalItemsCallback >> End');
                });
                $A.enqueueAction(action);
            } else {
                helper.fireToggleSpinnerEvent(component, false);
            }
        } catch(e) {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", e);
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> addTechnicalItems >> End');
    },

    showDetailedToast : function(component, title, message, type, duration) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> showDetailedToast >> Start');
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "duration": duration,
            "variant": type
        });
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> showDetailedToast >> End');
    },

    checkValidItem : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> checkValidItem >> Start');
        let action = component.get("c.checkConfItem");

        action.setParams({
            'recordId': component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> checkValidItemCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    helper.showDetailedToast(component, '', response.getReturnValue(), "error", "5000");
                    $A.get("e.force:closeQuickAction").fire();
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP247_AddTechnicalItems >> Helper >> checkValidItemCallback >> End');
        });
    
        $A.enqueueAction(action);
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> checkValidItem >> End');
    },

    fireRefreshEvt : function(component) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> fireRefreshEvt >> Start');
        let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
        fireRefreshEvt.setParam('action', 'refresh intervention');
        var params = {};
        params.showComponentLabel = 'showComponentAddPC';
        fireRefreshEvt.setParam('params', params);
        fireRefreshEvt.fire();
        component.set("v.isInitialized",false);
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> fireRefreshEvt >> End');
    },

    handleOnRowSelection : function(component, event, helper) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> handleOnRowSelection >> Start');
        if(!component.get("v.hasPageChanged") || component.get("v.initialLoad")) {
            //set initial load to false
            component.set("v.initialLoad", false);
            //Get currently select rows, This will only give the rows available on current page
            let selectedRows = event.getParam('selectedRows');
            component.set("v.selected", selectedRows);

            //Get all selected rows from datatable, this will give all the selected data from all the pages
            let allSelectedRows = component.get("v.selection");

            //Get current page number
            let currentPageNumber = component.get("v.pageNumber");

            //Process the rows now
            //Condition 1 -> If any new row selected, add to our allSelectedRows attribute
            //Condition 2 -> If any row is deselected, remove from allSelectedRows attribute
            //Solution - Remove all rows from current page from allSelectedRows attribute and then add again

            //Removing all rows coming from curent page from allSelectedRows
            let i = allSelectedRows.length;
            while(i--) {
                let pageNumber = allSelectedRows[i].split("-")[1];
                allSelectedRows.splice(i, 1);
            }
            //Adding all the new selected rows in allSelectedRows

            selectedRows.forEach(function(row) {
                allSelectedRows.push(row.glBookEntryId);
                // allSelectedRows.push(row.prodPrice);

            });

            //Setting new value in selection attribute

            component.set("v.selection", allSelectedRows);
        } else {
            component.set("v.hasPageChanged", false);
        }
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> handleOnRowSelection >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP247_AddTechnicalItems",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP247_AddTechnicalItems >> Helper >> fireToggleSpinnerEvent >> End');
    }
})