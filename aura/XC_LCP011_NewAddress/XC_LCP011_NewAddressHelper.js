({
    doInit : function(component, event, helper) {
        
        if(component.get("v.address")){
            var mapField = component.get("v.address");
            for(let i in mapField){ 
                let cmpTarget = component.find(i); 
                if(cmpTarget){
                    cmpTarget.set("v.value",mapField[i]);
                } 
            }
        }

        if(component.get("v.address.account")){
            let action = component.get("c.retrieveAccountRecordTypeName");
            action.setParams({ 
                'accountId': component.get("v.address.account")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let retValue = response.getReturnValue();
                if (state === "SUCCESS" && retValue !== null){
                    if(retValue.typeMessage === $A.get("$Label.c.XC_CL_Account_Partner")){
                        component.set("v.address.isAccountPartner", true);
                    } 
                }
            });
            $A.enqueueAction(action);      
        }

        if(component.get("v.addressToUpdate")){
            component.find("city").set('v.disabled', true);
            component.find("category").set('v.disabled', true);
            component.find("floor").set('v.disabled', true);
            component.find("door").set('v.disabled', true);
            component.find("stair").set('v.disabled', true);
            component.find("clarifType").set('v.disabled', true);
            component.find("clarifValue").set('v.disabled', true);
            component.find('country').set('v.disabled', true);
            component.find('saveButton').set('v.disabled', true);
            component.set("v.showButtonSection",false);

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

        let action = component.get("c.saveAddressApex");

        action.setParams( {
            'inputAddress' : JSON.stringify(address)
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){
                    this.showMessage(component, "info", "Success!", "Address created");
                    
                    if(component.get("v.source")=='052'||component.get("v.source")=='102'){
                        let cmpEvent = component.getEvent("XC_LCE004_closeNewAddress");
                        cmpEvent.fire();

                    } else {
                        setTimeout(function(){
                            $A.get('e.force:refreshView').fire();
                        }, 10); 
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    
                } else { 
                    this.showMessage(component, "error", "Warning", retValue.resultMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
    },

    checkFieldsBeforeValidate : function(component, event, helper) {
        
        this.removeRedBox(component,event);
        component.set("v.showSpinner", true);
        let address = component.get("v.address");

        if(!component.get("v.showMunicipality")){
            delete address['municipality'];
        }
        
        if (this.checkRequiredFields(component))  {
            this.callForPods(component, event, helper);

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
                title : 'Success',
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
        if(component.get("v.source")=='052'||component.get("v.source")=='102'){
            let cmpEvent =component.getEvent("XC_LCE004_closeNewAddress");
            cmpEvent.fire();
        } else {
            $A.get('e.force:closeQuickAction').fire();
        }
    },
    
    showErrorOnField : function(component, event, helper){   
        console.log('entrato in showErrorOnField '+ component.get("v.requiredAttribute"));
        let cmpTarget = component.get("v.requiredAttribute");
        
        for(let i=0; i < cmpTarget.length; i++){
            let a = component.find(cmpTarget[i]);
            if(a&&!a.get("v.disabled")&&!a.get("v.value")){
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
    
    showMessage : function(component, variante, title, mess){
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
                helper.populateAllFields(component, event, helper, res.addressReturned); 

            } else {
                this.showMessage(component, "error", "Warning", $A.get("$Label.c.XC_CL_Address_NotFound") );

            }
        });
        $A.enqueueAction(action);
        
    },

    populateAllFields : function (component, event, helper, selectedRows) {

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
            if(component.get("v.source")=='002'||component.get("v.source")=='003'){
                console.log('SPARO CON : '+address);
                let cmpEvent = component.getEvent("XC_LCE013_SetAddressObject");
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
							option['label'] = helper.capitalize(obj.streetType+' '+obj.street+', '+obj.city+', '+obj.province);
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
                        //component.find("category").set('v.disabled', true);
                        //component.find("country").set('v.disabled', true);
                        
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

        component.set("v.address.streetType","");
        component.set("v.address.streetTypeText","");
		component.set("v.address.cityCode", "");
		component.set("v.address.province","");
		component.set("v.address.provinceCode", "");
		component.set("v.address.postalCode", "");

		if(inputString.length >= 3){

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
                        //component.find("category").set('v.disabled', false);
                        //component.find("country").set('v.disabled', true);
                        
                    } else if(component.get('v.searchresultCity').length == 0) { //address not found
                        helper.setAllInputField(component, false);
                        component.set('v.showCitySugg', false);
                    } 

                    component.set('v.showSpinner', false);
                    
				} else {
                    helper.setAllInputField(component, false);
                    component.set('v.showCitySugg', false);
                }

			});
			$A.enqueueAction(action);
            setTimeout(function(){ component.set('v.showSpinner', false); }, component.get("v.requestTimeOut"));
            
		} else {
            component.set("v.showCitySugg", false);
        }
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
        $A.enqueueAction(action);
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

        var action = component.get("c.callForValidateDC");
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
                    /*
                    if(res.resZip===4 && res.zip!==""){
                        component.set("v.address.postalCode", res.zip);
                    }
                    */

                    component.set("v.showCheckbox", false);
                    component.set("v.address.municipality", helper.capitalize(res.MunicipalityDesc));
                    component.set("v.showButtonSection",false);
                    component.set("v.address.validate", true);
                    component.set("v.address.validatedCups", (component.get("v.address.gas")!='')||(component.get("v.address.electric")!=''));
                    console.log('cups validated: '+component.get("v.address.validatedCups"));
                    console.log('address validated: '+component.get("v.address.validate"));

                    helper.setAllInputField(component, true);
                    helper.showMessage(component, "info", "Success!", $A.get("$Label.c.XC_CL_Address_ValidationOK"));

                    if(component.get("v.source")=='002'||component.get("v.source")=='003'){
                        console.log('@@@ Address sent.');
                        let cmpEvent = component.getEvent("XC_LCE013_SetAddressObject");
                        cmpEvent.setParams({
                            "address" : address,
                            "withoutValidate" : false
                        }); 
                        cmpEvent.fire();
                    }

                } else if(res.ErrorCode=='400'||res.ErrorCode=='500'){
                    console.log('@@@ Address not sent.');
                    component.set("v.address.validate", false);
                    helper.setAllInputField(component, false);
                    helper.showMessage(component, "error", "Warning", res.ErrorMessage);
                    component.set("v.showCheckbox", true);
                    
				} 
				
            } else {
                console.log("Call validate Error");	
                component.set("v.address.validate", false);
                helper.setAllInputField(component, false);
                helper.showMessage(component, "error", "Warning", 'Error on Validation');
                component.set("v.showCheckbox", true);
            }
        });
        $A.enqueueAction(action);
    },

    callForPods : function(component, event, helper) {
        let address = component.get("v.address");    
        var action = component.get("c.callToPODByAddress");
        action.setParams({
            'inputFields' : JSON.stringify(address)
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();  
            component.set("v.showSpinner", false); 
			DEBUGGER;
            if(state=='SUCCESS'){ 
                if( res.length>0 ){

                    component.set("v.podsTableColumns",[
                        {label: "Stair", fieldName : 'Stair'},
                        {label: "Floor", fieldName:'Floor'},
                        {label: "Door", fieldName:'Door'},
                        {label: "Gas", fieldName : 'Gas'},
                        {label: "Electric", fieldName : 'Electric'}
                    ]);

                    console.log("Call pods Success");
                    component.set("v.showPods",true); 
                    var resultList = new Array();
                    for(var str of res){
                        try {
                            var obj = JSON.parse(str);
                            var option = {
                                "Stair" : obj.Stair, 
                                "Floor" : obj.Floor, 
                                "Door" : obj.Door, 
                                "Gas" : obj.CUPS, 
                                "Electric" : obj.CUPS
                            };

                            console.log(option);
                            
                            //option['label'] = "Stair: "+obj.Stair+", Floor: "+obj.Floor+", Door: "+obj.Door+",CUPS Gas: "+obj.CUPS+",CUPS Electric: "+obj.CUPS;
                            //option['value'] = str;
                            resultList.push(option);
                
                        } catch(err) {
                            console.log(err);
                        }
                    }
    
                    component.set("v.podsTableData", resultList);
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

        if (component.find('clarifType')) {
            component.find("clarifType").set('v.disabled', false);
        }

        if (component.find('clarifValue')) {
            component.find("clarifValue").set('v.disabled', false);
        }
        
        component.find("country").set('v.disabled', false);
        component.find("city").set('v.disabled', false);
        component.find("address").set('v.disabled', false);
        component.find("address").set('v.disabled', false);
        component.find("stair").set('v.disabled', false);
        component.find("door").set('v.disabled', false);
        component.find("floor").set('v.disabled', false);
        component.find("category").set('v.disabled', false);
        component.set("v.showSave",true);
        component.set("v.address.validate", false);
        component.set("v.address.validatedCups", false);
        component.set("v.showButtonSection", true);

        let address = component.get("v.address");
        if(component.get("v.source")=='002'||component.get("v.source")=='003'){
            console.log('SPARO CON : '+address);
            let cmpEvent = component.getEvent("XC_LCE013_SetAddressObject");
            cmpEvent.setParams({
                "address" : address,
                "withoutValidate" : false
            }); 
            cmpEvent.fire();
        }
    },

    updateAddress : function(component, event, helper){
        let address = component.get("v.address");

        var action = component.get("c.updateAddressByLead");

        action.setParams( {
            'inputFields' : JSON.stringify(address)
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){
                    component.set("v.recordId", retValue.recordId);
                    this.showMessage(component, "info", "Success!", "Address updated");

                } else { 
                    this.showMessage(component, "error", "Warning", retValue.errorMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
    },

    handleSaveButtonClick : function(component, event, helper){
        if(component.get("v.addressToUpdate")){
            helper.updateAddress(component, event, helper);
            component.find('country').set('v.disabled', true);
            component.find('editButton').set('v.disabled', false);
            component.find('saveButton').set('v.disabled', true);

        } else {
            helper.checkFieldsBeforeSave(component, event, helper);
            component.set("v.addressToUpdate", true);
        }
    },

    handlePrimaryButtonClick : function(component, event, helper){
        if(component.get("v.showStrikeModal")){
            this.searchbyPodCall(component, event, helper);
            component.set("v.showStrikeModal",false);
            
        } else if(component.get("v.showPods")){

            if(component.get("v.selectedCup")!=undefined){
                let info = component.get("v.selectedCup")[0];
                component.set("v.address.gas", info.Gas);
                component.set("v.address.electric", info.Electric);
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

        if (component.find('clarifType')) {
            component.find("clarifType").set('v.disabled', disable);
        }

        if (component.find('clarifValue')) {
            component.find("clarifValue").set('v.disabled', disable);
        }

        component.find("gasCUP").set('v.disabled', disable);
        component.find("electricCUP").set('v.disabled', disable);
        component.find("postalCode").set('v.disabled', disable);
        component.find("stair").set('v.disabled', disable);
        component.find("door").set('v.disabled', disable);
        component.find("floor").set('v.disabled', disable);
        component.find("streetType").set('v.disabled', disable);
        component.find("city").set('v.disabled', disable);
        component.find("streetNumber").set('v.disabled', disable);
        component.find("category").set('v.disabled', disable);
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
        var check = ((address.streetType != "" || address.streetTypeText != "") && address.address != "" && address.streetNumber != "" && address.city != "" && address.postalCode != "" && address.province != "" );
        return check;
    }, 

    setPickCountry : function(component, selectedOptionValue){
        let ev = component.getEvent("XC_LCE018_ChangeAddressCountry");
		ev.setParams({
			"country" : selectedOptionValue
		}); 
        ev.fire();
    },

    clearAddress : function(component, event, helper){
        component.find("city").set("v.value", "");
        component.find("streetType").set("v.value", "");
        component.find("streetNumber").set("v.value", "");
        component.find("floor").set("v.value", "");
        component.find("door").set("v.value", "");
        component.find("stair").set("v.value", "");
        component.find("gasCUP").set("v.value", "");
        component.find("category").set("v.value", "");
        component.find("province").set("v.value", "");
        component.find("address").set("v.value", "");
        component.find("postalCode").set("v.value", "");
        component.find("municipality").set("v.value", "");
        component.find("clarifType").set("v.value", "");
        component.find("clarifValue").set("v.value", "");
        component.find("electricCUP").set("v.value", "");
    }, 

    editPressed : function(component, event, helper){
        helper.onModify(component, event, helper);
        component.find('country').set('v.disabled', false);
        component.find('editButton').set('v.disabled', true);
        component.find('saveButton').set('v.disabled', false);
    }
        
})