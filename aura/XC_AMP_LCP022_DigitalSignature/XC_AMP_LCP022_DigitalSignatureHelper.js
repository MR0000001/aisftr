({
	doInit: function (component, event, helper) {
		let recordTypeId = component.get("v.recordTypeId");
		let fieldsList = component.get("v.fieldsList");
		let objectType = component.get("v.objectType");
	},

	validateData: function (component, event, helper) {

		//validate data and send data event to main component once all data are valid
		let fieldList = component.get("v.fieldsList");
		let fieldApiNames = fieldList.map(field => field.fieldName);
		let inputCmps = component.find('field');

		//check if all fields are valid
		let isAllValid = inputCmps.reduce(function (validSoFar, currentInput) {
			let validField = true;
			if (currentInput.get("v.required") && $A.util.isEmpty(currentInput.get("v.value"))) {
				validField = false;
			}
			return validSoFar && validField;
		}, true);

		console.log('CONTACT CHECK FIELD VALIDITY ' + isAllValid);

		if (isAllValid === true) {
			//send parent component event with all data
			helper.sendValidEventData(component, event, helper);
		} else {
			helper.invalidateSection(component, event, helper);
		}

	},

	sendValidEventData: function (component, event, helper) {

		let inputCmps = component.find('field');

		let fieldData = {};
		inputCmps.forEach((currentInput) => {
			let apiName = currentInput.get("v.fieldName");
			let value = currentInput.get("v.value");
			fieldData[apiName] = value;
		});

		let eventObj = {
			"recordTypeId": component.get("v.recordTypeId"),
			"sObjectName": component.get("v.objectType"),
			"sectionName": component.get("v.sectionName"),
			"isSectionValid": true,
			"fields": fieldData
		}

		helper.fireAMPEvent(component, eventObj);

	},

	invalidateSection: function (component, event, helper) {
		let eventObj = {
			"recordTypeId": component.get("v.recordTypeId"),
			"sObjectName": component.get("v.objectType"),
			"sectionName": component.get("v.sectionName"),
			"isSectionValid": false,
			"fields": {}
		}
		helper.fireAMPEvent(component, eventObj);
	},
	loadPredefaultValues: function (component, event, helper) {


		//prepopulating XC_AccountPhonePrefix__c
		let inputCmps = component.find('field');
		inputCmps.forEach((currentInput) => {
			if(currentInput.get("v.fieldName")==="XC_MobilePrefix__c"){
				currentInput.set("v.value",component.get("v.extraFields.phonePrefix"));
			}else if (currentInput.get("v.fieldName") === "XC_Birth_Country__c") {
				currentInput.set("v.value", component.get("v.extraFields.userCountry"));
			}else if (currentInput.get("v.fieldName") === "XC_Citizenship__c") {
				//currentInput.set("v.value", component.get("v.extraFields.userCountry"));
			}
		});

	}

})