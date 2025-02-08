({
    doInit : function(component, event, helper) {
        console.log("address in init:"+JSON.stringify(component.get("v.address")));
        if(component.get("v.address.account")){
            component.set("v.accountId",component.get("v.address.account"));
        }
        //let addr = component.get("v.address.country");
        //if(component.get("v.recordId")!=null && (component.get("v.address.country")==null || component.get("v.address.country")=='')){
        //    this.getCountryByLead(component, event, helper);
        //}
        if(component.get("v.recordId")==null){
            component.set("v.fromComponent",true);
        }
        if(component.get("v.recordId")){
            if(component.get("v.recordId")!=null && component.get("v.recordId").startsWith('001')){
                component.set("v.accountId",component.get("v.recordId"));
            }
            if(component.get("v.recordId")!=null && !component.get("v.recordId").startsWith('001')){
                this.getAddressFromParentId(component, event, helper);
                this.setAllInputField(component, true);
                component.set("v.showSave",false);
                component.set("v.showButtonSection",false);
            }
            else{
                component.set("v.showButtonSection",true);
            }

            let action = component.get("c.retrieveAccountRecordTypeName");
            action.setParams({ 
                'accountId': component.get("v.recordId") 
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let retValue = response.getReturnValue();
                if (state === "SUCCESS" && retValue !== null) {

                    if(retValue.success){
                        component.set("v.accountId",  component.get("v.recordId"));
                    }

                    if(retValue.typeMessage === $A.get("$Label.c.XC_CL_Account_Partner")){
                        component.set("v.address.isAccountPartner", true);
                    }

                    component.set("v.nifNumber", retValue.objectInfo);
                }
            });
            $A.enqueueAction(action);      

        } else if(component.get("v.addressToUpdate")){
            component.set("v.onLead", true);
            helper.onModify(component, event, helper);

        }

        let action = component.get("c.getCountryByUser");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue !== null) {
                if(component.get("v.address.country")==null || component.get("v.address.country")==undefined){
                    component.set("v.address.country", retValue);
                }
                component.set("v.showMunicipality", true);
                component.find("city").set('v.disabled', false);
                component.set("v.showSecondPick", true);

                if(component.get("v.recordId")!=null && !component.get("v.recordId").startsWith('001')){
                    this.setAllInputField(component, true);
                }
            }
        });

        $A.enqueueAction(action);      
    },
    getCountryByLead : function(component, event, helper) {
        let action = component.get("c.getCountryByLead");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue !== null) {
                //let cmpEvent = component.get("e.XC_LCE018_ChangeAddressCountry");
                //cmpEvent.setParams({
                //                     "country" : retValue
                //                 });
                //cmpEvent.fire();
                component.set("v.address.country",retValue);
                component.find("country").set("v.value",retValue);
            }
        });

        $A.enqueueAction(action);
    },
    getAddressFromParentId : function(component, event, helper) {
        if(component.get("v.recordId")){

            let action = component.get("c.getAddressApex");
            action.setParams({
                'recordId': component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let retValue = response.getReturnValue();
                if (state === "SUCCESS" && retValue !== null) {
                   let addressVar = JSON.parse(retValue);
                   //component.set("v.addressId", addressVar.Id);
                   component.set("v.address", addressVar);
                   component.set("v.leadId", addressVar.lead);
                   if((component.get("v.leadId")==null || component.get("v.leadId")==undefined) && component.get("v.recordId").startsWith("00Q")){
                       component.set("v.leadId",component.get("v.recordId"));
                       component.set("v.address.lead",component.get("v.recordId"));
                       component.set("v.address.account",component.get("v.accountId"));
                   }
                   component.set("v.addressToUpdate", true);

                }
            });
            $A.enqueueAction(action);

        }
    },
    checkFieldsBeforeSave : function(component, event, helper) {

        if (this.checkRequiredFields(component))  {
            this.saveAddress(component, event, helper);

        } else {
            console.log('chiamo lo show errorOnFied');
            component.set("v.showSpinner", false);
            this.showErrorOnField(component,event,helper);
            if(component.get('v.IdFromMobile')==undefined){
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": $A.get("$Label.c.XC_CL_Warning"),
                    //"message": $A.get("$Label.c.XC_CL_ErrorAddressFields"),
                    "message": $A.get("$Label.c.XC_CL_Mandatory_Fields")
                }); 
            } else {
                component.set("v.showToastMessage", true);
                component.set("v.successMessage", $A.get("$Label.c.XC_CL_Mandatory_Fields") );
            }
        }
        
    },
    
    saveAddress : function(component, event, helper) {
        let address = component.get("v.address");

        if(component.get("v.leadId")){
            address.lead = component.get("v.leadId");
        }

        if(component.get("v.accountId") && component.get("v.address.account") == null){
            address.account = component.get("v.accountId");
            component.set("v.address.account",component.get("v.accountId"));
        }

        let action = component.get("c.saveAddressApex");
        let idAcc = component.get("v.accountId");

        let inputMap = {
            'idAccount' : idAcc,
            'inputFields' : JSON.stringify(address),
        };

        let inputStr = JSON.stringify(address);//JSON.stringify(inputMap);
        action.setParams( {
            'inputAddress' : inputStr
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){
                    helper.showSuccessToast(component, event, '');
                    
                    if(component.get("v.source")=='052'||component.get("v.source")=='102'){
                        let cmpEvent = component.getEvent("XC_LCE004_closeNewAddress");
                        cmpEvent.fire();

                    }else {
                        setTimeout(function(){
                            $A.get('e.force:refreshView').fire();
                        }, 10); 
                        $A.get("e.force:closeQuickAction").fire();
                    
                    }
                    
                } else { 
                    this.showMessage(component, event, helper, "error", $A.get("$Label.c.XC_CL_Warning"), retValue.resultMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
    },

    checkFieldsBeforeValidate : function(component, event, helper) {
        
        this.removeRedBox(component,event);
        component.set("v.showSpinner", true);
        let address = component.get("v.address");


        if (this.checkRequiredFields(component))  {
            //this.callForValidation(component, event, helper);
            this.onValidateDC(component, event, helper);

        } else {
            console.log('chiamo lo show errorOnFied');
            component.set("v.showSpinner", false);
            this.showErrorOnField(component,event,helper);
            if(component.get('v.IdFromMobile')==undefined){
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": $A.get("$Label.c.XC_CL_Warning"),
                    //"message": $A.get("$Label.c.XC_CL_ErrorAddressFields"),
                    "message": $A.get("$Label.c.XC_CL_Mandatory_Fields")
                }); 
            } else {
                component.set("v.showToastMessage", true);
                component.set("v.successMessage", $A.get("$Label.c.XC_CL_Mandatory_Fields") );
            }
        }
    },
    
    showSuccessToast : function(component, event, mess) {
        if(component.get("v.IdFromMobile")===null){
            let messCreated = mess;
            if ($A.util.isEmpty(messCreated)){
                messCreated = $A.get("$Label.c.XC_CL_Address_Created");
            }
            
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : $A.get("$Label.c.XC_CL_Success"),
                message: messCreated,
                messageTemplate: 'Record {0} created! See it {1}!',
                duration:' 1000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    
    showErrorToast : function(component, event, message) {
        if(component.get("v.IdFromMobile")===null){
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning!',
                message: message,
                messageTemplate: 'Record {0} created! See it {1}!',
                duration:' 1000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
            component.set("v.showToastMessage", true);
            component.set("v.successMessage", message);
        }
    },    
    
    cancel : function(component, event,helper) {
        if(component.get("v.source")=='052' || component.get("v.source")=='102'){
            let cmpEvent =component.getEvent("XC_LCE004_closeNewAddress");
            cmpEvent.fire();
        } else {
            $A.get('e.force:closeQuickAction').fire();
        }
    },

    backTo52 : function(component, event,helper) {

        console.log('back...');

        let cmpEvent = $A.get("e.c:XC_LCE017_CloseNewAddress");
        cmpEvent.setParams({
            "closed" : true
        }); 
        cmpEvent.fire();

    },
    
    showErrorOnField : function(component, event, helper){   
        console.log('entrato in showErrorOnField '+ component.get("v.requiredAttribute"));
        let cmpTarget = component.get("v.requiredAttribute");
        
        for(let i=0; i < cmpTarget.length; i++){
            let s = cmpTarget[i];
            let a = component.find(cmpTarget[i]);

            if(a&&!a.get("v.disabled")&&(a.get("v.value")=="" || a.get("v.value")== null || a.get("v.value")== undefined)){
                $A.util.addClass( a, 'slds-has-error'); 
            }
        }
    },
    
    removeRedBox : function(component, event) {
        let street = component.find("street");
        let province = component.find("province");
        let mapField = component.get('v.address');
        for(let i in mapField){ 
            let cmpTarget = component.find(i); 
            $A.util.removeClass(cmpTarget, 'slds-has-error ');
        }
        $A.util.removeClass(street, 'slds-has-error ');
        $A.util.removeClass(province, 'slds-has-error ');
        
    },
    
    refreshSubTabs: function(component){
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            workspaceAPI.refreshTab({tabId: response.parentTabId, includeAllSubtabs: true});
            
        }).catch(function(error) {
            console.log(error);
        });
        let navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get("v.recordId"), "slideDevName": "detail", "isredirect": true });    
        navigateEvent.fire();
    },
    
    showMessage : function(component, event, helper, variante, title, mess){
        component.find('notifLib').showNotice({
            "variant": variante,
            "header": title,
            "message": mess, 
        });
    },
    
    searchbyPod: function(component, event, helper) {
        component.set("v.showStrikeModal",true);
        component.set("v.podValue",undefined);
    },

    searchbyPodCall: function(component, event, helper) {
        let cup = component.get("v.podValue");
        let action = component.get("c.getAddressByCup");
        action.setParams({
            'podValue' : cup
        });
        action.setCallback(this, function(response) {
      
            let res = JSON.parse(response.getReturnValue());

            if(res !== null && res.success){
                console.log('@@@res addressReturned-->' + res.addressReturned);
                helper.populateAllFieldByPod(component, event, helper, res.addressReturned); 

            } else {
                this.showMessage(component, event, helper, "error", $A.get("$Label.c.XC_CL_Warning"), $A.get("$Label.c.XC_CL_Address_NotFound") );

            }
        });
        $A.enqueueAction(action);
        
    },

    populateAllFieldByPod : function (component, event, helper, selectedRows) {

      if(selectedRows.Country&&component.find("country")){     
        component.find("country").set("v.value", selectedRows.Country);
      }
      if(selectedRows.Floor&&component.find("floor")){
        component.find("floor").set("v.value", selectedRows.Floor);
      }
      if(selectedRows.Municipality&&component.find("municipality")){
        component.find("municipality").set("v.value", selectedRows.Municipality);
      }
      if(selectedRows.Category&&component.find("category")){
        component.find("category").set("v.value", selectedRows.Category);
      }
      if(selectedRows.Address&&component.find("address")){
        component.find("address").set("v.value", selectedRows.Address);
      }
      if(selectedRows.StreetNumber&&component.find("streetNumber")){
        component.find("streetNumber").set("v.value", selectedRows.StreetNumber);   
      }
      if(selectedRows.Door&&component.find("door")){
        component.find("door").set("v.value", selectedRows.Door);   
      }
      if(selectedRows.Stair&&component.find("stair")){
        component.find("stair").set("v.value", selectedRows.Stair);   
      }
      if(selectedRows.ZipCode&&component.find("postalCode")){
        component.find("postalCode").set("v.value", selectedRows.ZipCode);    
      }
      if(selectedRows.City&&component.find("city")){
        component.find("city").set("v.value", selectedRows.City);   
      }
      if(selectedRows.gasCUPS&&component.find("gasCUP")){
        component.find("gasCUP").set("v.value", selectedRows.gasCUPS);   
      }
      if(selectedRows.electricCUPS&&component.find("electricCUP")){
        component.find("electricCUP").set("v.value", selectedRows.electricCUPS);   
      }
      if(selectedRows.StreetType&&component.find("streetType")){
        component.find("streetType").set("v.value", selectedRows.StreetType);   
      }
      if(selectedRows.Province){
        //component.find("province").set("v.value", selectedRows.Province);   
        component.set("v.address.province", selectedRows.Province);
      }

    },
 
    skipValidation : function (component, event, helper){
        let address = component.get("v.address");

        component.set("v.skipValChecked", component.find("skipVal").get("v.checked"));
        if(!component.get("v.skipValChecked")){
            return;
        }

        this.removeRedBox(component,event);
        component.set("v.showSpinner", true);
        if(!component.get("v.showMunicipality")){
            delete address['municipality'];
        }
        
        if (this.checkRequiredFields(component))  {

            component.set("v.address.validate", true);
            if(component.get("v.fromComponent")==true){
                console.log('SPARO CON : '+address);
                let cmpEvent = component.get("e.XC_LCE013_SetAddressObject"); //$A.get("e.c:XC_LCE013_SetAddressObject");
                cmpEvent.setParams({
                    "address" : address,
                    "withoutValidate" : true
                }); 
                cmpEvent.fire();
            } 
            component.set("v.showSpinner", false);  

        } else {
            console.log('chiamo lo show errorOnFied');
            component.set("v.showSpinner", false);
            this.showErrorOnField(component,event,helper);
            if(component.get("v.IdFromMobile")===""){
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": $A.get("$Label.c.XC_CL_Warning"),
                    "message": $A.get("$Label.c.XC_CL_ErrorAddressFields"),
                });
            }else{
                component.set("v.showToastMessage", true);
                component.set("v.successMessage", $A.get("$Label.c.XC_CL_ErrorAddressFields") );
            }
        }
    },

    /* ---------------------- Methods for autocompleting address ---------------------- */

    typingAddress : function(component, helper, inputString) { 
        let address = JSON.stringify(component.get("v.address"));

		if(inputString.length >= 3){

			console.log('Start Searching...');
			var action = component.get("c.autoCompleteStreet");
			component.set('v.showSpinner', true);

			action.setParams({
				'inputFields':address
			}); 

			action.setCallback(this, function(a) {

				var state = a.getState();
            	if (component.isValid() && state === "SUCCESS") {
					console.log(a.getReturnValue());

					var resultList = new Array();
					for(var str of a.getReturnValue()){
						try {
							var obj = JSON.parse(str);
							var option = {};
							option['label'] = helper.capitalize(obj.address+' '+obj.streetNumber+', '+obj.city+', '+obj.province);
							option['value'] = str;
							resultList.push(option);
				
						} catch(err) {
							console.log(err);
						}
					}
			
					component.set("v.searchresultStreet", resultList);
					if(component.get('v.searchresultStreet').length > 0 && !component.get('v.showAddressSugg')){
						component.set("v.showAddressSugg", true);
						component.set("v.showCitySugg", false);
                        component.set("v.showZipSugg", false);

                        /*
                        if (component.find('municipality')) {
                            component.find("municipality").set('v.disabled', true);
                        }

                        //component.find("gasCUP").set('v.disabled', true);
                        //component.find("electricCUP").set('v.disabled', true);
                        //component.find("postalCode").set('v.disabled', true);

                        if (component.find('province')) {
                            component.find("province").set('v.disabled', true);
                           component.find("provinceText").set('v.disabled', true);
                        }
                        if (component.find('streetType')) {
                            component.find("streetType").set('v.disabled', true);
                        }
                        //component.find("category").set('v.disabled', true);
                        */
                        component.find("country").set('v.disabled', true);
                        
                    } else if(component.get('v.searchresultStreet').length == 0) { //address not found
                        helper.setAllInputField(component, false);
                        component.set('v.showAddressSugg', false);
                    } 

                    component.set('v.showSpinner', false);
                    
				}

			});
			$A.enqueueAction(action);
			setTimeout(function(){ component.set('v.showSpinner', false); }, component.get("v.requestTimeOut"));
            
		} else {
            component.set("v.showAddressSugg", false);
        }
	},

	typingCity : function(component, helper, inputString) { 
        let address = JSON.stringify(component.get("v.address"));

		if(inputString.length >= 3){


            if (component.find('municipality')) {
                component.find("municipality").set('v.disabled', false);
            }

           if (component.find('postalCode')) {
                component.find("postalCode").set('v.disabled', false);
            }

            if (component.find('electric')) {
                component.find("electric").set('v.disabled', false);
            }

            if (component.find('clarifValue')) {
                component.find("clarifValue").set('v.disabled', false);
            }
            if (component.find('clarifType')) {
                component.find("clarifType").set('v.disabled', false);
            }


            component.find("address").set('v.disabled', false);


            if (component.find('province')) {
                component.find("province").set('v.disabled', false);
            }

            if (component.find('provinceText')) {
                component.find("provinceText").set('v.disabled', false);
            }

            if (component.find('streetNumber')) {
                component.find("streetNumber").set('v.disabled', false);
            }
            component.find("country").set('v.disabled', true);
         }
         else{
             if (component.find('municipality')) {
                 component.find("municipality").set('v.disabled', true);
                 component.find("municipality").set('v.value', null);
             }
             if (component.find('postalCode')) {
                 component.find("postalCode").set('v.disabled', true);
                 component.find("postalCode").set('v.value', null);
             }

            if (component.find('electric')) {
                component.find("electric").set('v.disabled', true);
                component.find("electric").set('v.value', null);
            }

            if (component.find('clarifValue')) {
                component.find("clarifValue").set('v.disabled', true);
                component.find("clarifValue").set('v.value', null);
            }
            if (component.find('clarifType')) {
                component.find("clarifType").set('v.disabled', true);
                component.find("clarifType").set('v.value', null);
            }
             component.find("address").set('v.disabled', true);

             if (component.find('province')) {
                 component.find("province").set('v.disabled', true);
                 component.find("province").set('v.value', null);
             }

             if (component.find('provinceText')) {
                  component.find("provinceText").set('v.disabled', true);
                  component.find("provinceText").set('v.value', null);
             }

             if (component.find('streetNumber')) {
                 component.find("streetNumber").set('v.disabled', true);
                 component.find("streetNumber").set('v.value', null);
             }
             component.find("country").set('v.disabled', false);
         }
         //dpalamides (no city autocompletion)
         /*if(inputString.length >= 3){

			console.log('Start Searching...');
			var action = component.get("c.autoCompleteCity");
			component.set('v.showSpinner', true);

			action.setParams({
				'inputFields':address
			}); 

			action.setCallback(this, function(a) {

				var state = a.getState();
            	if (component.isValid() && state === "SUCCESS") {
					console.log(a.getReturnValue());

					var resultList = new Array();
					for(var str of a.getReturnValue()){
						try {
							var obj = JSON.parse(str);
							var option = {};
							option['label'] = helper.capitalize(obj.city)+', '+helper.capitalize(obj.province);
							option['value'] = str;
							resultList.push(option);
				
						} catch(err) {
							console.log(err);
						}
					}
			
					component.set("v.searchresultCity", resultList);
					if(component.get('v.searchresultCity').length > 0 && !component.get('v.showCitySugg')){
						component.set("v.showAddressSugg", false);
						component.set("v.showCitySugg", true);
                        component.set("v.showZipSugg", false);

                        if (component.find('municipality')) {
                            component.find("municipality").set('v.disabled', true);
                        }

                        component.find("gasCUP").set('v.disabled', true);
                        component.find("electricCUP").set('v.disabled', true);
                        component.find("postalCode").set('v.disabled', true);

                        if (component.find('province')) {
                            component.find("province").set('v.disabled', true);
                        }

                        component.find("streetType").set('v.disabled', true);
                        component.find("streetNumber").set('v.disabled', true); 
                        component.find("category").set('v.disabled', true);
                        component.find("country").set('v.disabled', true);
                        
                    } else if(component.get('v.searchresultCity').length == 0) { //address not found
                        helper.setAllInputField(component, false);
                        component.set('v.showCitySugg', false);
                    } 

                    component.set('v.showSpinner', false);
                    
				}

			});
			$A.enqueueAction(action);
            setTimeout(function(){ component.set('v.showSpinner', false); }, component.get("v.requestTimeOut"));
            
		} else {
            component.set("v.showCitySugg", false);
        } */
	},

	typingZip : function(component, helper, inputString) { 
		component.set("v.showZipSugg", false);
        let address = JSON.stringify(component.get("v.address"));

		var city = component.get("v.address.cityCode");
		var prov = component.get("v.address.provinceCode");

		if(!(component.get("v.returnedZipList")) && inputString.length >= 2 && city && prov){

			console.log('Start Searching...');
			var action = component.get("c.autoCompleteZipCode");
			component.set('v.showSpinner', true);

			action.setParams({
				'inputFields':address
			}); 

			action.setCallback(this, function(a) {

				var state = a.getState();
            	if (component.isValid() && state === "SUCCESS") {
					console.log(a.getReturnValue());

					var resultList = new Array();
					for(var str of a.getReturnValue()){
						try {
							var obj = JSON.parse(str);
							var option = {};
							option['label'] = obj.zip;
							option['value'] = str;
							resultList.push(option);
				
						} catch(err) {
							console.log(err);
						}
					}
			
					component.set("v.searchresultZip", resultList);
					if(component.get('v.searchresultZip').length > 0 && !component.get('v.showZipSugg')){
						component.set("v.showAddressSugg", false);
						component.set("v.showCitySugg", false);
						component.set("v.showZipSugg", true);
					} 
					component.set('v.showSpinner', false);
				}
			});
			$A.enqueueAction(action);
			setTimeout(function(){ component.set('v.showSpinner', false); }, component.get("v.requestTimeOut"));
		} 
    },
    
    selectAddress : function(component, event, helper, inputString) { 
		var obj = JSON.parse(inputString);
		obj['lead']=component.get("v.address.lead");
        console.log('selected address:'+obj);
        if(obj.country == 'Colombia'){
            obj.address = obj.address + ' ' + obj.streetNumber;
        }

        component.set("v.address",obj);

        component.set("v.showAddressSugg", false);
        component.set("v.showCitySugg", false);
        component.set("v.showZipSugg", false);



        /*
		var street = obj.street;

		if(street.charAt(0)==' '){
			street = street.substring(1,street.length);
		}

		console.log('Selected Address: --> '+street);

		component.set("v.address.address",helper.capitalize(street));
		component.set("v.address.province",helper.capitalize(obj.province));
		component.set("v.address.provinceCode",helper.capitalize(obj.provinceCode));
        component.set("v.address.streetType",helper.capitalize(obj.streetType));
        component.set("v.address.streetTypeText",helper.capitalize(obj.streetType));
		component.set("v.address.city",helper.capitalize(obj.city));
        component.set("v.address.cityCode",helper.capitalize(obj.cityCode));

        component.set("v.address.floor",''); 
		component.set("v.address.door",'');
        component.set("v.address.stair",'');
        component.set("v.address.municipality",'');
        component.set("v.address.gas",'');
        component.set("v.address.electric",'');

        component.set("v.showAddressSugg", false);
        component.find("streetNumber").set('v.disabled', false);

		var params = component.get("v.address");

		console.log('Searching Zip by: '+JSON.stringify(params));

		var action = component.get("c.getZipCodeDirectly");
        action.setParams({
            'inputFields' : JSON.stringify(params)
		}); 
		action.setCallback(this, function(response) {
            var state = response.getState();
			var res = response.getReturnValue();  

			if(state=='SUCCESS'){ 

				if(res.length==1){
                    component.set("v.address.postalCode",res[0]);
                    component.set("v.returnedZipList",true); 
                    console.log("Call Success (one res): "+res);	

                } else if(res.length>1){
                    component.find("postalCode").set('v.disabled', false);
                    console.log("Call Success (multiple res): "+res); 

                    var resList = new Array();
                    for(var str of res){
                        var out = {};
                        out['label'] = str;
                        out['value'] = str;
                        resList.push(out);
                    }
                    component.set("v.searchresultZip",resList); 
                    component.set("v.returnedZipList",true); 

                } else {
                    component.find("postalCode").set('v.disabled', false);
                    component.set("v.returnedZipList",false); 
                    console.log("No zip found");
                }

			} else {	
                component.find("postalCode").set('v.disabled', false);
                component.set("v.returnedZipList",false); 
                console.log("Call Error");
            }
        });
        $A.enqueueAction(action);*/
    },
    
    selectCity : function(component, event, helper, inputString) { 
		var obj = JSON.parse(inputString);

		component.set("v.address.city", helper.capitalize(obj.city));
		component.set("v.address.province", helper.capitalize(obj.province));
		console.log('Selected City: --> '+obj.city);
		component.set("v.address.cityCode", obj.cityCode);
        component.set("v.address.provinceCode", obj.provinceCode);
		
        component.set("v.showCitySugg", false); 
        component.find("address").set('v.disabled', false);
        component.set("v.address.address", "");
        component.set("v.address.postalCode", "");
        component.set("v.address.streetNumber", "");
        component.set("v.address.streetTypeText", "");
        component.set("v.address.municipality", "");
    },
    
    selectZip : function(component, event, helper, inputString) { 

		if(component.get("v.returnedZipList")){
			component.set("v.address.postalCode", inputString);
			console.log('Selected Zip: --> '+component.get("v.address.postalCode"));
			
		} else {
			var obj = JSON.parse(inputString);
			component.set("v.address.postalCode", obj.zip);
			console.log('Selected Zip: --> '+obj.zip);
		}

		component.set("v.showZipSugg", false); 
    },
    
    checkAddress : function(component, event, helper) {
		if((component.get("v.searchresult")) && component.get('v.searchresult').length > 0 && !component.find('address').get('v.disabled')){
			component.set("v.showAddressSugg", true); 
		}
		component.set("v.showCitySugg", false); 
		component.set("v.showZipSugg", false); 
	},
	
	checkCity : function(component, event, helper) {
		if((component.get("v.searchresultCity")) && component.get('v.searchresultCity').length > 0 && !component.find('city').get('v.disabled')){
			component.set("v.showCitySugg", true); 
		}
		component.set("v.showAddressSugg", false); 
		component.set("v.showZipSugg", false); 
	},
	
	checkZip : function(component, event, helper) {
		if((component.get("v.returnedZipList")) && component.get('v.searchresultZip').length > 0 && !component.find('postalCode').get('v.disabled')){
			component.set("v.showZipSugg", true); 
		}
		component.set("v.showAddressSugg", false); 
		component.set("v.showCitySugg", false); 
    },
    
    onValidateDC : function(component, event, helper) {
		component.set("v.showSpinner", true);  
		let address = component.get("v.address");

		console.log('Validation: '+JSON.stringify(address));

        var action = component.get("c.callForValidateXygo");
        action.setParams({
            'inputFields' : JSON.stringify(address)
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
			var res = response.getReturnValue();  
			component.set("v.showSpinner", false);  
            
            if(state=='SUCCESS'){ 
                console.log("Call validate Success");
                if(res.ErrorCode=='200'){
                    if(res.resZip===4 && res.zip!==""){
                        component.set("v.address.postalCode", res.zip);
                    }

                    component.set("v.showCheckbox", false);
                    component.set("v.showButtonSection",false);
                    component.set("v.address.validate", true);

                    console.log('address validated: '+component.get("v.address.validate"));

                    helper.setAllInputField(component, true);
                    helper.showMessage(component, event , helper, "info", $A.get("$Label.c.XC_CL_CPAB_Success"), $A.get("$Label.c.XC_CL_Address_ValidationOK"));

                    if(component.get("v.fromComponent")==true){
                        console.log('@@@ Address sent.');
                        let cmpEvent = component.get("e.XC_LCE013_SetAddressObject");
                        cmpEvent.setParams({
                            "address" : component.get("v.address"),
                            "withoutValidate" : false
                        }); 
                        cmpEvent.fire();
                    }

                } else if(res.ErrorCode=='400'||res.ErrorCode=='500'){
                    console.log('@@@ Address not sent.');
                    component.set("v.address.validate", false);
                    helper.setAllInputField(component, false);
                    helper.showMessage(component, event, helper, "error", $A.get("$Label.c.XC_CL_Warning"), res.ErrorMessage);
                    component.set("v.showCheckbox", true);
                    
				} 
				
            } else {
                console.log("Call validate Error");	
                component.set("v.address.validate", false);
                helper.setAllInputField(component, false);
                helper.showMessage(component, event, helper, "error", $A.get("$Label.c.XC_CL_Warning"), 'Error on Validation');
                component.set("v.showCheckbox", true);
            }
        });
        $A.enqueueAction(action);
    },

    callForValidation : function(component, event, helper) {
        let address = component.get("v.address");
    
        var action = component.get("c.callToPODByAddress");
        action.setParams({
            'inputFields' : JSON.stringify(address)
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();  
            component.set("v.showSpinner", false); 

            if(state=='SUCCESS'){ 
                if( res.length>0 ){
                    console.log("Call pods Success");
                    component.set("v.showPods",true); 
                    var resultList = new Array();
                    for(var str of res){
                        try {
                            var obj = JSON.parse(str);
                            var option = {};
                            option['label'] = "Stair: "+obj.Stair+", Floor: "+obj.Floor+", Door: "+obj.Door+",CUPS Gas: "+obj.CUPS+",CUPS Electric: "+obj.CUPS;
                            option['value'] = str;
                            resultList.push(option);
                
                        } catch(err) {
                            console.log(err);
                        }
                    }
    
                    component.set("v.searchresultCup", resultList);
                    component.set("v.selectedCup", undefined);

                } else {
                    console.log("no pods found for this address: "+JSON.stringify(address));	
                    this.onValidateDC(component, event, helper);

                }
            
            } else {
                console.log("Call pods Error");	
                this.onValidateDC(component, event, helper);
				
            }
            
        });
        $A.enqueueAction(action);
    },

    onModify : function(component, event, helper) {
        this.setAllInputField(component, false);

        component.set("v.showSave",true);
        component.set("v.address.validate", false);
        component.set("v.address.validatedCups", false);
        component.set("v.showButtonSection", true);

        let address = component.get("v.address");
        if(component.get("v.fromComponent")==true){
            console.log('SPARO CON : '+address);
            let cmpEvent = $A.get("e.c:XC_LCE013_SetAddressObject");
            cmpEvent.setParams({
                "address" : address,
                "withoutValidate" : false
            }); 
            cmpEvent.fire();
        }
    },

    updateAddress : function(component, event, helper){
        console.log(component.get("v.leadId"));
        let address = component.get("v.address");

        var action = component.get("c.updateAddressByLead");

        action.setParams( {
            'inputFields' : JSON.stringify(address),
            'leadId' : component.get("v.leadId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){

                    component.set("v.recordId", retValue.recordId);
                    helper.updateLead(component, event, helper);

                } else { 
                    this.showMessage(component, event, helper, "error", $A.get("$Label.c.XC_CL_Warning"), retValue.errorMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
    },

    updateLead : function(component, event, helper){

        var action = component.get("c.updateLead");

        action.setParams( {
            'leadId' : component.get("v.leadId"),
            'addressId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){

                    helper.showMessage(component, event , helper, "info", "Success!", $A.get("$Label.c.XC_CL_AddressUpdated"));
                    component.set("v.showSave",false);

                } else { 
                    this.showMessage(component, event, helper, "error", $A.get("$Label.c.XC_CL_Warning"), retValue.errorMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
    },

    handleSaveButtonClick : function(component, event, helper){

        if(component.get("v.addressToUpdate")){
            helper.updateAddress(component, event, helper);

        } else if(component.get("v.newAddressOnLead")){
            helper.checkFieldsBeforeSave(component, event, helper);
            helper.updateAddress(component, event, helper);

        }else {
            helper.checkFieldsBeforeSave(component, event, helper);

        }
    },

    handlePrimaryButtonClick : function(component, event, helper){
        if(component.get("v.showStrikeModal")){
            this.searchbyPodCall(component, event, helper);
            component.set("v.showStrikeModal",false);
            
        } else if(component.get("v.showPods")){

            if(component.get("v.selectedCup")!=undefined){
                let info = JSON.parse(component.get("v.selectedCup"));
                component.set("v.address.gas", info.CUPS);
                component.set("v.address.electric", info.CUPS);
                component.set("v.address.stair", info.Stair);
                component.set("v.address.floor", info.Floor);
                component.set("v.address.door", info.Door);
            }

            this.onValidateDC(component, event, helper);
            component.set("v.showPods",false);
        }
    },
    
    setAllInputField : function(component, disable){

        if (component.find('municipality')) {
            component.find("municipality").set('v.disabled', disable);
        }

        if (component.find('province')) {
            component.find("province").set('v.disabled', disable);
        }

        if (component.find('provinceText')) {
            component.find("provinceText").set('v.disabled', disable);
        }

        if (component.find('clarifType')) {
            component.find("clarifType").set('v.disabled', disable);
        }

        if (component.find('clarifValue')) {
            component.find("clarifValue").set('v.disabled', disable);
        }
        if (component.find('postalCode')) {
            component.find("postalCode").set('v.disabled', disable);
        }
        if (component.find('streetType')) {
            component.find("streetType").set('v.disabled', disable);
        }
        component.find("city").set('v.disabled', disable);
        if (component.find('streetNumber')) {
            component.find("streetNumber").set('v.disabled', disable);
        }
        if (component.find('electric')) {
            component.find("electric").set('v.disabled', disable);
        }
        component.find("address").set('v.disabled', disable);
        component.find("country").set('v.disabled', disable);
    },

    setDeelay : function(component, helper, inputString, func){

        var int = 200;
		if(inputString.length == 3){
            var int = 0;
        }

		if(component.get("v.timer")){
			helper.clearDeelay(component, helper, inputString)
		}

        component.set("v.timer", setTimeout(function(){ 
            func(component, helper, inputString);
        }, int));

	},

	clearDeelay : function(component, helper, inputString) {
		component.set("v.timer", clearTimeout(component.get("v.timer")));
    },

    capitalize : function(text){
		var res = '';
		var arr = text.split(' ');

		for(var s of arr){
			s = s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
			res += s+' ';
		}
		
		return res.slice(0, -1);;
    },

    checkRequiredFields : function(component){
        let address = component.get("v.address");
        var check = ((address.postalCode != "" && address.postalCode != null) && (address.address != "" && address.address != null) && ((address.streetNumber != "" && address.streetNumber != null) || address.country=='Colombia') && (address.city != "" && address.city != null)  && address.province != "" && address.province != null);
        return check;
    }
        
})