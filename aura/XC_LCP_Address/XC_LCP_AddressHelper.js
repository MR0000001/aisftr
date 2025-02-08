({
doInit: function (component, event, helper) {
	
        if (component.get('v.address')) {
            var mapField = component.get('v.address')
            for (let i in mapField) {
                let cmpTarget = component.find(i)
                if (cmpTarget) {
                    cmpTarget.set('v.value', mapField[i])
                }
            }
        }
        console.log('recordId' + component.get('v.recordId'));
        if(component.get('v.recordId')){
            var actionIsSFM = component.get("c.getRecordTypeParentObject")
            actionIsSFM.setParams({ 
                'recordId': component.get("v.recordId")
            });   
            actionIsSFM.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if(state=='SUCCESS'){
                    component.set("v.isSFMObject", res);
                    console.log('is SFM?' + component.get('v.isSFMObject'));
                    component.set('v.skipValChecked', true);
                }
            });
            $A.enqueueAction(actionIsSFM);    
        }

        if(component.get('v.parentRecordType') &&  component.get('v.parentRecordType').includes('SFM')){
            component.set('v.isSFMObject', true);
            console.log('is SFM?' + component.get('v.isSFMObject')); 
        }
        if(component.get('v.parentRecordType') &&  component.get('v.parentRecordType')== 'XC_Global'){
            component.set('v.skipValChecked', true);
        }
        if (component.get('v.addressToUpdate')) {
            this.setDisabledFieldsSet1(component, helper, true)
            helper.setDisabled(component, 'saveButton', true)
            component.set('v.showButtonSection', false)
        }

        if(component.get("v.address.country") ){
            let selectedOptionValue = component.get("v.address.country")
            helper.setPickCountry(component, selectedOptionValue, helper)
        } else {
            var action = component.get("c.getCountryByUser")
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if(state=='SUCCESS'){
                    component.set("v.address.country", res);
					
                    let selectedOptionValue = component.get("v.address.country")
                    helper.setPickCountry(component, selectedOptionValue, helper)
                }
            });
            $A.enqueueAction(action);    
        }
      
    },

    checkFieldsBeforeSave: function (component, event, helper) {
        if (this.checkRequiredFields(component)) {
            this.saveAddress(component, event, helper)
        } else {
            helper.notifyError($A.get('$Label.c.XC_CL_Mandatory_Fields'), $A.get('$Label.c.XC_CL_Warning'))
            component.set('v.addressToUpdate', false)
        }
    },

    saveAddress: function (component, event, helper) {
        let address = component.get('v.address')
        component.set('v.showSpinner', true)
        helper.callMethod(component, 'saveAddressApex', { 'inputAddress': JSON.stringify(address), 'recordId': component.get('v.recordId') })
            .then($A.getCallback(r => {
                component.set('v.showSpinner', false)
                helper.notifySuccess($A.get('$Label.c.XC_CL_Address_Created'))
                if (component.get('v.source') == '052' || component.get('v.source') == '102'  || component.get('v.source') == '120')  { //CR762 15-07-22
                    let cmpEvent = component.getEvent('XC_LCE004_closeNewAddress')
                    cmpEvent.fire()
                } else {
                    setTimeout(function () {
                        $A.get('e.force:refreshView').fire()
                    }, 10)
                    $A.get('e.force:closeQuickAction').fire()
                }
            }))
            .catch(e => {
                console.log('callbackKo')
                component.set('v.showSpinner', false)
                helper.notifyError(e)
            })
    },

    checkFieldsBeforeValidate: function (component, event, helper) {
        component.set('v.showAddressSugg', false)
        component.set('v.showCitySugg', false)
        component.set('v.showZipSugg', false)

        this.removeRedBox(component, event)
        let address = component.get('v.address')

        if (this.checkRequiredFields(component)) {
            this.callForPods(component, event, helper)
        } else {
            helper.notifyError($A.get('$Label.c.XC_CL_Mandatory_Fields'), $A.get('$Label.c.XC_CL_Warning'))
        }
    },

    cancel: function (component, event, helper) {
        if (component.get('v.source') == '052' || component.get('v.source') == '102') {
            let cmpEvent = component.getEvent('XC_LCE004_closeNewAddress')
            cmpEvent.fire()
        } else {
            $A.get('e.force:closeQuickAction').fire()
        }
    },

    showErrorOnField: function (component, event, helper) {
        console.log('entrato in showErrorOnField ' + component.get('v.requiredAttribute'))
        let cmpTarget = component.get('v.requiredAttribute')

        for (let i = 0; i < cmpTarget.length; i++) {
            let a = component.find(cmpTarget[i])
            if (a && !a.get('v.disabled') && !a.get('v.value')) {
                $A.util.addClass(a, 'slds-has-error')
            }
        }
    },

    removeRedBox: function (component, event) {
        let street = component.find('street')
        let province = component.find('province')
        let mapField = component.get('v.address')
        for (let i in mapField) {
            let cmpTarget = component.find(i)
            $A.util.removeClass(cmpTarget, 'slds-has-error ')
        }
        $A.util.removeClass(street, 'slds-has-error ')
        $A.util.removeClass(province, 'slds-has-error ')
    },

    searchbyPod: function (component, event, helper) {
        component.set('v.showStrikeModal', true)
        component.set('v.podValue', undefined)
    },

    searchbyPodCall: function (component, event, helper) {
        let cup = component.get('v.podValue')
        component.set('v.showSpinner', true)
        helper.callMethod(component, 'getAddressByCup', { 'podValue': cup })
            .then(r => {
                component.set('v.showSpinner', false)
                const res = JSON.parse(r)
                if (res !== null && res.success) {
                    console.log('@@@res addressReturned-->' + res.addressReturned)
                    helper.populateAllFields(component, event, helper, res.addressReturned)
                } else {
                    helper.notifyError($A.get('$Label.c.XC_CL_Address_NotFound'), $A.get('$Label.c.XC_CL_Warning'))
                }
            })
            .catch(e => {
                component.set('v.showSpinner', false)
                console.log(e)
            })
    },

    populateAllFields: function (component, event, helper, selectedRows) {
        if (selectedRows.Country) helper.setValue(component, 'country', selectedRows.Country)
        if (selectedRows.Floor) helper.setValue(component, 'floor', selectedRows.Floor)
        if (selectedRows.Municipality) helper.setValue(component, 'municipality', selectedRows.Municipality)
        if (selectedRows.Category) helper.setValue(component, 'category', selectedRows.Category)
        if (selectedRows.Address) helper.setValue(component, 'address', selectedRows.Address)
        if (selectedRows.StreetNumber) helper.setValue(component, 'streetNumber', selectedRows.StreetNumber)
        if (selectedRows.Door) helper.setValue(component, 'door', selectedRows.Door)
        if (selectedRows.Stair) helper.setValue(component, 'stair', selectedRows.Stair)
        if (selectedRows.ZipCode) helper.setValue(component, 'postalCode', selectedRows.ZipCode)
        if (selectedRows.City) helper.setValue(component, 'city', selectedRows.City)
        if (selectedRows.gasCUPS) helper.setValue(component, 'gasCUP', selectedRows.gasCUPS)
        if (selectedRows.electricCUPS) helper.setValue(component, 'electricCUP', selectedRows.electricCUPS)
        if (selectedRows.StreetType) helper.setValue(component, 'streetType', selectedRows.StreetType)
        if (selectedRows.Province) component.set('v.address.province', selectedRows.Province)
    },

    skipValidation: function (component, event, helper) {
        let address = component.get('v.address')
        if (component.find('skipVal')){
        component.set('v.skipValChecked', component.find('skipVal').get('v.checked'))
        } 
        if (!component.get('v.skipValChecked')) return
        this.removeRedBox(component, event)
        if (this.checkRequiredFields(component)) {
            helper.emitEvent(component, address, true)
        } else {
            helper.notifyError($A.get('$Label.c.XC_CL_ErrorAddressFields'), $A.get('$Label.c.XC_CL_Warning'))
        }
    },

    /* ---------------------- Methods for autocompleting address ---------------------- */
    typingCity: function (component, helper) {
        let address = JSON.stringify(component.get('v.address'))
        component.set('v.address.streetType', '')
        component.set('v.address.streetTypeText', '')
        component.set('v.address.cityCode', '')
        component.set('v.address.province', '')
        component.set('v.address.provinceCode', '')
        component.set('v.address.postalCode', '')

        const inputString = component.get('v.address.city')

        if (!inputString) {
            helper.emptySubCity(component, helper)
            helper.setDisableSubCity(component, helper, true)
        }

        if (inputString.length >= 3) {
            component.set('v.showSpinner', true)
            helper.callMethod(component, 'autoCompleteCity', { 'inputFields': address })
                .then(r => {
                    component.set('v.showSpinner', false)
                    console.log(r)
                    if(!r){
                    	component.set('v.showCitySugg', false)
                        helper.setAllInputField(component, helper, false);
                    } else {
                        var resultList = helper.getResultList(r, 'city')
                        component.set('v.searchresultCity', resultList)
                        //forse da cambiare per swicth latam a ubiest
                        if (component.get('v.searchresultCity').length > 0 && /*component.get('v.address.country')!='Chile' &&*/ !component.get('v.isSFMObject')) { // && !component.get('v.showCitySugg')) {                        if (component.get('v.searchresultCity').length > 0 && component.get('v.address.country')!='Chile' && !component.get('v.isSFMObject')) { // && !component.get('v.showCitySugg')) {
                            component.set('v.showAddressSugg', false)
                            component.set('v.showCitySugg', true)
                            helper.setDisableSubCity(component, helper, false)
                            
                        } else { //city not found
                            component.set('v.showCitySugg', false)
                    		component.set('v.searchresultCity', null)
                            helper.setAllInputField(component, helper, false);
                        }      
                    }
                    
                })
                .catch(e => {
                    console.log(e)
                    component.set('v.showSpinner', false)
                    component.set('v.showCitySugg', false)
                })
        } else {
            component.set('v.showCitySugg', false)
        }
    },

    typingAddress: function (component, helper) {
        let address = JSON.stringify(component.get('v.address'))
        const inputString = component.get('v.address.address')

        if (!inputString) {
            helper.emptySubAddress(component, helper)
            helper.setDisableSubAddress(component, helper, true)
        }
        if (inputString.length >= 3 ) {

            component.set('v.showSpinner', true)
            helper.callMethod(component, 'autoCompleteStreet', { 'inputFields': address })
                .then(r => {
                    component.set('v.showSpinner', false)
                    console.log(r)
                    if(!r){
                        component.set('v.showAddressSugg', false)
                    	helper.setAllInputField(component, helper, false);
                    	
                    } else {
                        var resultList = helper.getResultList(r, 'street')
                        component.set('v.searchresultStreet', resultList)
                        if (component.get('v.searchresultStreet').length > 0 ) {
                            component.set('v.showAddressSugg', true)
                            component.set('v.showCitySugg', false)
                            helper.setDisableSubAddress(component, helper, false)
                    		helper.setDisabled(component, 'streetType', true)
                    		helper.setDisabled(component, 'province', true)
                        } else if (component.get('v.searchresultStreet').length == 0) { //address not found
                            component.set('v.showAddressSugg', false)
                        }
                    }
                    
                })
                .catch(e => {
                    component.set('v.showSpinner', false)
                    console.log(e)
                })
        } else {
            component.set('v.showAddressSugg', false)
        }
    },

    typingZip: function (component, helper) {
        console.log('typingZip');
        component.set('v.showZipSugg', false)
        let address = JSON.stringify(component.get('v.address'))
        var city = component.get('v.address.cityCode')
        var prov = component.get('v.address.provinceCode')
        var street = component.get('v.address.streetNumber')

        const inputString = component.get('v.address.postalCode')
        
		if (!(component.get('v.returnedZipList')) && city && prov) {            
            component.set('v.showSpinner', true)
         //   helper.callMethod(component, 'getZipDirectly', { 'inputFields': JSON.stringify(params) })
            helper.callMethod(component, 'getZipDirectly', { 'inputFields': address })
            
            // helper.callMethod(component, 'autoCompleteZipCode', { 'inputFields': address })
//                .then(r => {
//                    component.set('v.showSpinner', false)
//                    console.log(r)
//                    var resultList = helper.getResultList(r, 'zip')
//                    component.set('v.searchresultZip', resultList)
//                    if (component.get('v.searchresultZip').length > 0) { // && !component.get('v.showZipSugg')) {
//                        component.set('v.showAddressSugg', false)
//                        component.set('v.showCitySugg', false)
//                        component.set('v.showZipSugg', true)
//                    }
//                })
//                .catch(e => {
//                    component.set('v.showSpinner', false)
//                    console.log('rgs cATCH' +e)
//                })
			
             //helper.callMethod(component, 'getZipDirectly', { 'inputFields': JSON.stringify(params) })
        
                 .then(r => {
                    console.log(r)
                    component.set('v.showSpinner', false)
                    
                    let addRes = JSON.parse(r);
                    if(addRes.zip_code){
                        component.set('v.address.postalCode', addRes.zip_code) 
                     	
                     	
                    }
                 })
                 .catch(e => {
                     console.log('Call Error: ' + e)
                     helper.setDisabled(component, 'postalCode', true)
                 })
        }
    },

    selectAddress: function (component, event, helper, inputString) {
        var obj = JSON.parse(inputString)
														
        component.set('v.address.city', helper.capitalize(obj.city))
        component.set('v.address.cityCode', obj.city_code)
											   
        
        if(component.get('v.address').country == 'Italy' ){
        	component.set('v.address.province', obj.province )
        } else {
            component.set('v.address.province', helper.capitalize(obj.province))
        }
        
        component.set('v.address.provinceCode', obj.province_code)
        component.set('v.address.address', helper.capitalize(obj.street))
        component.set('v.address.addressCode', obj.street_code)
        if(obj.street_type){
            component.set('v.address.streetType', helper.capitalize(obj.street_type))
        	component.set('v.address.streetTypeText', helper.capitalize(obj.street_type))
        }
        component.set('v.address.floor', '')
        component.set('v.address.door', '')
        component.set('v.address.stair', '')
        if(obj.municipality_desc){
            if(component.get('v.address').country != 'Chile' ){            
        	    component.set('v.address.municipality', helper.capitalize(obj.municipality_desc))
            }
        } 
        if(obj.zip_code){
        	component.set('v.address.postalCode', helper.capitalize(obj.zip_code))
        } 
        if(obj.street_number){
        	component.set('v.address.streetNumber', obj.street_number)
        }
        if(component.get('v.address').country == 'Colombia' || component.get('v.address').country == 'Chile' ){
            component.set('v.address.addressRef', obj.street_type)
            helper.setDisabled(component, 'postalCode', true)
            helper.setDisabled(component, 'addressRefVal', false)
            helper.setDisabled(component, 'gasCUP', true)

																					
															
        }
        component.set('v.address.gas', '')
        component.set('v.address.electric', '')
        component.set('v.showAddressSugg', false)
        helper.setDisabled(component, 'streetNumber', false)


        //TODO: riabilitare alla fine, se funziona
         var params = component.get('v.address')
         console.log('Searching Zip by: ' + JSON.stringify(params))
														  
         if (component.get('v.address').country == 'Colombia' || component.get('v.address').country != 'Chile' ){
             helper.callMethod(component, 'getZipDirectly', { 'inputFields': JSON.stringify(params) })
                 .then(r => {
                    let addRes = JSON.parse(r);
                    if(addRes.zip_code){
                        component.set('v.address.postalCode', addRes.zip_code)
                     	component.set('v.address.postalCode', '')
                    }
                 })
                 .catch(e => {
                     console.log('Call Error: ' + e)
                     helper.setDisabled(component, 'postalCode', true)
                 })
         }
			 
    },

    selectCity: function (component, event, helper, inputString) {
        var obj = JSON.parse(inputString)
        component.set('v.address.city', helper.capitalize(obj.city))
        component.set('v.address.cityCode', obj.city_code)
        
        if(component.get('v.address').country == 'Italy' ){
        	component.set('v.address.province', obj.province )
        } else {
			if(component.get('v.address').country == 'Colombia' || component.get('v.address').country == 'Chile' ){
                component.set('v.address.municipality', helper.capitalize(obj.province))
                component.set('v.address.department', helper.capitalize(obj.province))
                component.set('v.address.daneCode', obj.dane_code)               
                component.set('v.address.sidewalk', obj.hamlet)
                component.set('v.address.locality', obj.hamlet)
                
              
            }																									   
            component.set('v.address.province', helper.capitalize(obj.province))
        }
        
        component.set('v.address.province_code', obj.province_code)
        component.set('v.address.address', '')
        //component.set('v.address.postalCode', '')
        component.set('v.address.streetNumber', '')
        component.set('v.address.streetTypeText', '')
        if(component.get('v.address').country != 'Colombia' && component.get('v.address').country != 'Chile' ){
            component.set('v.address.municipality', '')
            component.set('v.address.postalCode', '')
        }
        component.set('v.showCitySugg', false)
        //RO: 20220531 NR1957 - Remove Chile from original IF
        //if(obj.country == 'Italia'||obj.country == 'Chile' ){
        if(obj.country == 'Italia'){
            component.set('v.address.region', helper.capitalize(obj.municipality_desc))
            helper.setDisabled(component, 'region', false)
        }
        //RO: 20220531 NR1957 - Condition for Chile Only
        if(obj.country == 'Chile'){
            component.set('v.address.region', helper.capitalize(obj.municipality_desc))
            helper.setDisabled(component, 'region', true)
        }
        helper.setDisabled(component, 'address', false)
        
    },

    selectZip: function (component, event, helper, inputString) {
        var obj = JSON.parse(inputString)
        console.log('Selected Zip: --> ' + obj.zip_code)
		component.set('v.address.postalCode', helper.capitalize(obj.zip_code))												   
        //component.set('v.address.postalCode', obj.zip_code)
        component.set('v.showZipSugg', false)
		
												 
    },

    checkAddress: function (component, event, helper) {
        if ((component.get('v.searchresult')) && component.get('v.searchresult').length > 0 && !component.find('address').get('v.disabled')) {
            component.set('v.showAddressSugg', true)
        }
        component.set('v.showCitySugg', false)
        component.set('v.showZipSugg', false)
    },

    checkCity: function (component, event, helper) {
        if ((component.get('v.searchresultCity')) && component.get('v.searchresultCity').length > 0 && !component.find('city').get('v.disabled')) {
            component.set('v.showCitySugg', true)
        }
        component.set('v.showAddressSugg', false)
        component.set('v.showZipSugg', false)
    },

    checkZip: function (component, event, helper) {
        if ((component.get('v.returnedZipList')) && component.get('v.searchresultZip').length > 0 && !component.find('postalCode').get('v.disabled')) {
            component.set('v.showZipSugg', true)
        }
        component.set('v.showAddressSugg', false)
        component.set('v.showCitySugg', false)
    },

    onValidate: function (component, event, helper) {
											
        let address = component.get('v.address')
        component.set('v.showSpinner', true)
        helper.callMethod(component, 'callForValidate', { 'inputFields': JSON.stringify(address) })
            .then(res => {
                if(res ==  $A.get('$Label.c.XC_CL_Address_Incorrect')){
                    component.set('v.showSpinner', false)
                    helper.notifyError($A.get('$Label.c.XC_CL_Address_Incorrect'), $A.get('$Label.c.XC_CL_Warning'))
                    helper.setValidateError(component, helper)
                }
                let addRes = JSON.parse(res);
                component.set('v.showSpinner', false)
                component.set('v.showCheckbox', false)
                if(addRes.municipality_desc){
                    if(component.get('v.address').country != 'Chile' ){                    
                	    component.set('v.address.municipality', helper.capitalize(addRes.municipality_desc))
                    }
            	}
                if(addRes.municipality_desc&&address.country=='Italy'){
                	component.set('v.address.region', helper.capitalize(addRes.municipality_desc))
            	}
                if(addRes.zip_code){
                	component.set('v.address.postalCode', addRes.zip_code)
            	}
                component.set('v.showButtonSection', false)
                component.set('v.address.validate', true)
                component.set('v.address.validatedCups', (component.get('v.address.gas') != '') || (component.get('v.address.electric') != ''))
                console.log('Call validate Success: ' + res)
                console.log('cups validated: ' + component.get('v.address.validatedCups'))
                console.log('address validated: ' + component.get('v.address.validate'))

																				  
																	   
																			
                helper.setAllInputField(component, helper, true)
					 
				 
                helper.notifySuccess($A.get('$Label.c.XC_CL_Address_ValidationOK'))
                helper.emitEvent(component, address, false)
            })
            .catch(e => {
                component.set('v.showSpinner', false)
                helper.notifyError($A.get('$Label.c.XC_CL_Address_Incorrect'), $A.get('$Label.c.XC_CL_Warning'))
                helper.setValidateError(component, helper)
            })
    },

    setValidateError: function (component, helper) {
        component.set('v.address.validate', false)
        helper.setAllInputField(component, helper, false)
        component.set('v.showCheckbox', true)
    },

    callForPods: function (component, event, helper) {
        let address = component.get('v.address')
        component.set('v.showSpinner', true)
        helper.callMethod(component, 'callToPODByAddress', { 'inputFields': JSON.stringify(address) })
            .then(res => {
                component.set('v.showSpinner', false)

                if (res.length > 0) {
                    console.log('Call pods Success')
                    component.set('v.showPods', true)
                    var resultList = helper.getResultList(res, 'pods')
                    component.set('v.podsTableData', resultList)
                    component.set('v.selectedCup', undefined)
                } else {
                    console.log('no pods found for this address: ' + JSON.stringify(address))
                    this.onValidate(component, event, helper)
                }
            })
            .catch(e => {
                component.set('v.showSpinner', false)
                console.log('Call pods Error')
                this.onValidate(component, event, helper)
            })
    },

    getServerSystem: function (component, event, helper) {
        var action = component.get("c.getServerSystem");
        action.setParams({ 
            'country': component.get("v.address.country")
        });
        action.setCallback(this, function(response) {                
            var state = response.getState();
            var res = response.getReturnValue();
            console.log('asd'+res+' '+state);
            if(state!='SUCCESS' || component.get('v.isSFMObject') || component.get('v.parentRecordType') == 'XC_Global'){
                helper.setValidateError(component, helper)
                if(component.find('skipVal')){
                    component.find('skipVal').set('v.checked', true) 
                    component.find('skipVal').set('v.disabled', true)
                }
                component.set('v.skipValChecked', true)
            } else {
                if(component.find('skipVal')){
                    component.find('skipVal').set('v.checked', false) 
                    component.find('skipVal').set('v.disabled', false)
                }
                component.set('v.skipValChecked', false)
                component.set('v.showCheckbox', false)
            }
        });
        $A.enqueueAction(action);
    },

    onModify: function (component, event, helper) {
        helper.setDisabledFieldsSet1(component, helper, false)
        helper.setDisabled(component, 'address', false)
        helper.setDisabled(component, 'streetNumber', false)   
        component.set('v.showSave', true)
        component.set('v.address.validate', false)
        component.set('v.address.validatedCups', false)
        component.set('v.showButtonSection', true)

        let address = component.get('v.address')
        helper.emitEvent(component, address, false)
    },

    updateAddress: function (component, event, helper) {
        let address = component.get('v.address')

        helper.callMethod(component, 'updateAddressByLead', { 'inputFields': JSON.stringify(address), 'recordId': component.get('v.recordId') })
            .then(r => {
                if(!component.get('v.isSFMObject')){
                    component.set('v.recordId', r)
                }
                helper.notifySuccess($A.get('$Label.c.XC_CL_AddressUpdated'))
            })
            .catch(e => {
                helper.notifyError(e, $A.get('$Label.c.XC_CL_Warning'))
            })
    },

    handleSaveButtonClick: function (component, event, helper) {
        if (component.get('v.addressToUpdate')) {
            helper.updateAddress(component, event, helper)
            helper.setDisabled(component, 'country', true)
            helper.setDisabled(component, 'editButton', false)
            helper.setDisabled(component, 'saveButton', true)
            component.set('v.showSave',false)
        } else if (component.get('v.source')=='013') {
            component.set('v.addressToUpdate', true)
            helper.checkFieldsBeforeSave(component, event, helper)
            helper.setDisabled(component, 'editButton', false)
            helper.setDisabled(component, 'saveButton', true)
            component.set('v.showSave',false)
        } else {
            component.set('v.addressToUpdate', true)
            helper.checkFieldsBeforeSave(component, event, helper)
        }
    },

    handlePrimaryButtonClick: function (component, event, helper) {
        if (component.get('v.showStrikeModal')) {
            this.searchbyPodCall(component, event, helper)
            component.set('v.showStrikeModal', false)
        } else if (component.get('v.showPods')) {
            if (component.get('v.selectedCup') != undefined) {
                let info = component.get('v.selectedCup')[0]
                component.set('v.address.gas', info.Gas)
                component.set('v.address.electric', info.Electric)
                component.set('v.address.stair', info.Stair)
                component.set('v.address.floor', info.Floor)
                component.set('v.address.door', info.Door)
            }
            this.onValidate(component, event, helper)
            component.set('v.showPods', false)
        }
    },

    capitalize: function (text) {
        return text.split(' ').map(v => v.charAt(0).toUpperCase() + v.slice(1).toLowerCase()).join(' ')
    },

    checkRequiredFields: function (component) {
        const hiddenFields = component.get('v.hiddenFields')
        const address = component.get('v.address')
        if(!component.get('v.isSFMObject')){

            var cond = ((!!address.streetTypeText || !!hiddenFields['XC_StreetTypeText__c'])
                && !!address.address
                && ((!!address.streetNumber  || !!hiddenFields['XC_StreetNumber__c']))
                && (!!address.region || !!hiddenFields['XC_Region__c'] || address.country != 'Italy' )
                && !!address.city 
                && ((!!address.postalCode  || !!hiddenFields['XC_PostalCode__c']))
                && (!!address.province || !!hiddenFields['XC_AddressProvince__c'])
                && (!!address.daneCode || !!hiddenFields['XC_DaneCode__c'] || address.country != 'Colombia' ));

            return cond;
        }else{
            return (!!address.address && !!address.city && !!address.country )
        }
    },

    setPickCountry: function (component, selectedOptionValue, helper) {
        if(!component.get('v.addressToUpdate')){
            helper.emptySubCountry(component, helper)
        }
        if (!selectedOptionValue) {
            helper.setDisableSubCountry(component, helper, false)
        } else {
            component.set('v.showSpinner', true)
            helper.callMethod(component, 'getHiddenFieldsByCountry', { 'country': selectedOptionValue, 'isSFMObject': component.get('v.isSFMObject') })
                .then(r => {
                    console.log(r)
                    r = r || []
                    var tmp = {}
                    r.forEach(v => {
                        console.log(v)
                        tmp[v] = v
                    })
                    component.set('v.hiddenFields', tmp)
                    helper.setDisabled(component, 'city', component.get('v.addressToUpdate'))
                    component.set('v.showSpinner', false)
                    helper.getServerSystem(component, event, helper)
                })
                .catch(e => {
                    component.set('v.showSpinner', false)
                    helper.notifyError(e)
                })

        }

        //TODO: questa roba serve ancora? non direi
        // let ev = component.getEvent('XC_LCE018_ChangeAddressCountry')
        // ev.setParams({
        //     'country': selectedOptionValue
        // })
        // ev.fire()
    },

    setDeelay : function(component, helper, inputString, func){

        var int = 1000;
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

    clearAddress: function (component, event, helper) {
        helper.setValue(component, 'city', '')
        helper.setValue(component, 'streetType', '')
        helper.setValue(component, 'streetNumber', '')
        helper.setValue(component, 'floor', '')
        helper.setValue(component, 'door', '')
        helper.setValue(component, 'stair', '')
        helper.setValue(component, 'gasCUP', '')
        helper.setValue(component, 'category', '')
        helper.setValue(component, 'province', '')
        helper.setValue(component, 'address', '')
        helper.setValue(component, 'postalCode', '')
        helper.setValue(component, 'municipality', '')
        helper.setValue(component, 'clarifType', '')
        helper.setValue(component, 'clarifValue', '')
        helper.setValue(component, 'electricCUP', '')
        helper.setValue(component, 'note', '')
        helper.setValue(component, 'daneCode', '')
    },

    editPressed: function (component, event, helper) {
        helper.onModify(component, event, helper)
        helper.setDisabled(component, 'country', false)
        helper.setDisabled(component, 'editButton', true)
        helper.setDisabled(component, 'saveButton', false)
    },

    emitEvent: function (component, address, withoutValidate) {
		
        if (component.get('v.source') == '002' || component.get('v.source') == '003') {
            var isSFM = component.get('v.isSFMObject');
            if((isSFM != undefined && isSFM) || (component.get('v.parentRecordType') != undefined && component.get('v.parentRecordType') == 'XC_Global' )){
                withoutValidate = true;
            }
            console.log('SPARO CON : ' + address)
            let cmpEvent = component.getEvent('XC_LCE013_SetAddressObject')
            
            cmpEvent.setParams({
                'address': address,
                'withoutValidate': withoutValidate
            })
            cmpEvent.fire()
        }
    },

    setAllInputField: function (component, helper, disable) {
        helper.setDisabledFieldsSet1(component, helper, disable)
        helper.setDisabled(component, 'municipality', disable)
        helper.setDisabled(component, 'province', disable)
        helper.setDisabled(component, 'gasCUP', disable)
        helper.setDisabled(component, 'electricCUP', disable)
        helper.setDisabled(component, 'postalCode', disable)
		helper.setDisabled(component, 'postalCode', disable)													
        helper.setDisabled(component, 'streetNumber', disable)
        helper.setDisabled(component, 'address', disable)
        helper.setDisabled(component, 'streetType', disable)
        helper.setDisabled(component, 'note', disable)
        helper.setDisabled(component, 'daneCode', disable)
    },

    setDisabledFieldsSet1: function (component, helper, disabled) {
        helper.setDisabled(component, 'city', disabled)
        helper.setDisabled(component, 'category', disabled)
        helper.setDisabled(component, 'floor', disabled)
        helper.setDisabled(component, 'door', disabled)
        helper.setDisabled(component, 'stair', disabled)
        helper.setDisabled(component, 'country', disabled)
        helper.setDisabled(component, 'clarifType', disabled)
        helper.setDisabled(component, 'clarifValue', disabled)
        helper.setDisabled(component, 'region', disabled)
    },

    getResultList: function (r, type) {
        return r.map(v => {
            var tmp = {}
            if (type === 'city') {
                tmp.value = JSON.stringify(v)
                if(r[0]&&r[0].country==='Italia'){
                    tmp.label = this.capitalize(v.city) + ', ' + v.province
                } else {
                    tmp.label = this.capitalize(v.city) + ', ' + this.capitalize(v.province)
                }
            } else if (type == 'zip') {
                tmp.value = JSON.stringify(v)
                tmp.label = v.zip_code
            } else if (type == 'street') {
                tmp.value = JSON.stringify(v)
                if(r[0]&&r[0].country==='Italia'){
                    if(v.street_type){
                    	tmp.label = this.capitalize(v.street_type + ' ' + v.street + ', ' + v.city + ', ')+ v.province
                	} else {
                    	tmp.label = this.capitalize(v.street + ', ' + v.city + ', ')+ v.province
                	}
                } else {
                    if(v.street_type){
                    	tmp.label = this.capitalize(v.street_type + ' ' + v.street + ', ' + v.city + ', ' + v.province)
                	} else {
                    	tmp.label = this.capitalize(v.street + ', ' + v.city + ', ' + v.province)
                	}
                }
                
            } else if (type == 'pods') {
                tmp = {
                    Stair: v.Stair,
                    Floor: v.Floor,
                    Door: v.Door,
                    Gas: v.CUPS,
                    Electric: v.CUPS
                }
            }
            return tmp
        })
    },

    setDisableSubCountry: function (component, helper, value) {
        helper.setDisabled(component, 'city', value)
        helper.setDisableSubCity(component, helper, value)
    },

    setDisableSubCity: function (component, helper, value) {
        helper.setDisabled(component, 'province', true)
        helper.setDisabled(component, 'address', true)
        helper.setDisabled(component, 'municipality', true)
        helper.setDisabled(component, 'gasCUP', true)
        //helper.setDisabled(component, 'electricCUP', true)
        helper.setDisabled(component, 'streetType', true)
        helper.setDisableSubAddress(component, helper, true)
    },

    setDisableSubAddress: function (component, helper, value) {
        helper.setDisabled(component, 'streetNumber', value)
        helper.setDisabled(component, 'postalCode', value)
    },

    emptySubCountry: function (component, helper) {
        component.set('v.address.city', '')
        helper.emptySubCity(component, helper)
    },

    emptySubCity: function (component, helper) {
        component.set('v.address.address', '')
        component.set('v.address.addressCode', '')
        component.set('v.address.municipality', '')
        helper.emptySubAddress(component, helper)
    },

    emptySubAddress: function (component, helper) {
        component.set('v.address.streetNumber', '')
        component.set('v.address.postalCode', '')
        component.set('v.address.addressCode', '')
        component.set('v.address.streetType', '')
        component.set('v.address.streetTypeText', '')
    },

    setDisabled: function (component, name, disabled) {
        if (component.find(name)){
            if(Array.isArray(component.find(name))){
                for(var c in component.find(name)){
                    component.find(name)[c].set('v.disabled', disabled)  
                }
            } else {
            	component.find(name).set('v.disabled', disabled)   
            }
        } 
    },

    setValue: function (component, name, value) {
        if (component.find(name)) component.find(name).set('v.value', value)
    },

    sendChanges: function (cmp, hlp) {
        hlp.emitEvent(cmp, cmp.get('v.address'), (cmp.get('v.address.validate')||cmp.get('v.skipValChecked')))
    }
})