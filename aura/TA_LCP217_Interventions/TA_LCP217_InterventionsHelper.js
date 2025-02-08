({
    init : function(component, event, helper, isRefresh, actionResponse) {
        console.log('TA_LCP217_Interventions >> Helper >> init >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

        let _helper = this;
        let objectId = component.get("v.workOrderId");
        let refreshButton;
        if(event.target) {
            refreshButton = event.target.name == 'refreshButton' ? true : false;
        }
        console.log('refreshButton : ' + refreshButton);

        let action = component.get("c.init");
        action.setParams({
            "objectId" : objectId,
            "actionResponse" : actionResponse,
            "jsonCustomConfigSerialized" : JSON.stringify(component.get("v.custom"))
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> initCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set("v.infoBag", JSON.parse(response.getReturnValue()));
                component.set("v.isDevHub", component.get("v.infoBag.isDevHub"));
                if(component.get("v.infoBag.numberOfWoli")) {
                    _helper.checkAllWoliStatus(component);
                    _helper.checkPercentageOfCompletion(component);
                    _helper.fireValidationEvent(component);
                }
                this.fireSendInitStateEvt(component, true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            component.set("v.isInitialized", true);
            if(isRefresh || refreshButton) _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP243_CreateRecordModal');
            console.log('TA_LCP217_Interventions >> Helper >> initCallback >> End');
        });

        $A.enqueueAction(action);
        if(refreshButton) _helper.fireToggleSpinnerEvent(component, true);
        console.log('TA_LCP217_Interventions >> Helper >> init >> End');
    },

    showDetail : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> showDetail >> Start');
        let macroBlockName = event.currentTarget.title;
        let macroBlockList = component.get('v.infoBag.macroBlockList');
        macroBlockList.forEach(function(macroBlock) {
            if(macroBlock.blockName == macroBlockName) {
                macroBlock.showExpandButton = !macroBlock.showExpandButton;
            }
        });
        component.set('v.infoBag.macroBlockList', macroBlockList);
        console.log('TA_LCP217_Interventions >> Helper >> showDetail >> End');
    },

    searchDocument : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> searchDocument >> Start');
        let _helper = this;
        let recId = event.getSource().get('v.recordId');
        let action = component.get('c.searchDocument');
        action.setParam("recId", recId);

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> searchDocumentCallback >> Start');
            if(response.getState() == 'SUCCESS') {
                let macroBlockList = component.get('v.infoBag.macroBlockList');
                macroBlockList.forEach(function(macroBlock) {
                    macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                        if(recId == woliWrapper.Id) {
                            woliWrapper.contentVersionList = response.getReturnValue();
                            woliWrapper.status = 'Closed';
                        }
                    });
                });

                component.set('v.infoBag.macroBlockList', macroBlockList);
                _helper.checkAllWoliStatus(component);
                _helper.checkPercentageOfCompletion(component);
                _helper.fireValidationEvent(component);
                _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP217_Interventions >> Helper >> searchDocumentCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP217_Interventions >> Helper >> searchDocument >> End');
    },

    /*
    callDoxee : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> callDoxee >> Start');
        class RequestWrapper {
            constructor() {
                let FileSize;
                let FileName;
                let FileCreationDate;
                let FileCategory;
                let FileBase64;
                let ObjectType;
                let ObjectID;
                let Company;
                let Country;
            }
        }

        let _helper = this;
        let fileInput = event.getSource().get("v.files");
        let file = fileInput[0];
        let objFileReader = new FileReader();

        objFileReader.onload = $A.getCallback(function() {
            let fileContents = objFileReader.result;
            let indexOfbase64 = 'base64,';
            let dataStart = fileContents.indexOf(indexOfbase64) + indexOfbase64.length;
            let base64 = fileContents.substring(dataStart);
            let workOrderId = component.get("v.workOrderId");
            let lineItemNumber = event.getSource().get('v.name');
            let inputWrapper = {'WorkOrderLineItemNumber' : lineItemNumber, 'Status' : 'Closed'};

            let rw = new RequestWrapper();
            rw.FileSize = file.size;
            rw.FileName = file.name;
            rw.FileCategory = 'SF_PHOTO';
            rw.FileBase64 = base64;
            rw.ObjectType = 'WORKORDER_LINEITEM';
            rw.ObjectID = event.getSource().get('v.id');
            rw.Company = '';
            rw.Country = '';

            let action = component.get('c.callDoxee');
            action.setParams({
                requestWrapper : JSON.stringify(rw),
                inputWrapper : JSON.stringify(inputWrapper),
                workOrderId : workOrderId
            });

            action.setCallback(this, function(response) {
                console.log('TA_LCP217_Interventions >> Helper >> callDoxeeCallback >> Start');
                if(response.getState() == 'SUCCESS') {
                    let macroBlockList = component.get('v.infoBag.macroBlockList');
                    macroBlockList.forEach(function(macroBlock) {
                        macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                            if(rw.ObjectID == woliWrapper.Id) {
                                //woliWrapper.doxeeURL = response.getReturnValue();
                                console.log('call doxee return value: ' + JSON.stringify(response.getReturnValue()));
                                woliWrapper.doxeeUrlManList = response.getReturnValue();
                                woliWrapper.status = 'Closed';
                            }
                        });
                    });
                    component.set('v.infoBag.macroBlockList', macroBlockList);
                    _helper.checkAllWoliStatus(component);
                    _helper.checkPercentageOfCompletion(component);
                    _helper.fireValidationEvent(component);
                    _helper.fireToggleSpinnerEvent(component, false,'TA_LCP217_Interventions');
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                }
                console.log('TA_LCP217_Interventions >> Helper >> callDoxeeCallback >> End');
            });
            _helper.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
            $A.enqueueAction(action);
        });

        objFileReader.readAsDataURL(file);
        console.log('TA_LCP217_Interventions >> Helper >> callDoxee >> End');
    },*/

    //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
    /*callDoxee : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> callDoxee >> Start');
        class RequestWrapper {
            constructor() {
                let FileSize;
                let FileName;
                let FileCreationDate;
                let FileCategory;
                let FileBase64;
                let ObjectType;
                let ObjectID;
                let Company;
                let Country;
            }
        }

        let _helper = this;
        let fileInput = event.getSource().get("v.files");
        let file = fileInput[0];
        let objFileReader = new FileReader();

        objFileReader.onload = $A.getCallback(function() {
            console.log('reader onload');
            let image = new Image();
            image.onload = $A.getCallback(function() {
                console.log('image onload');
                let canvas = document.createElement('canvas'),
                    max_size = 800,// TODO : pull max size from a site config
                    width = image.width,
                    height = image.height;
                if (width > height) {
                    if (width > max_size) {
                        height *= max_size / width;
                        width = max_size;
                    }
                } else {
                    if (height > max_size) {
                        width *= max_size / height;
                        height = max_size;
                    }
                }
                canvas.width = width;
                canvas.height = height;
                canvas.getContext('2d').drawImage(image, 0, 0, width, height);
                let dataUrl = canvas.toDataURL('image/jpeg');

                let fileContents = dataUrl;
                let indexOfbase64 = 'base64,';
                let dataStart = fileContents.indexOf(indexOfbase64) + indexOfbase64.length;
                let base64 = fileContents.substring(dataStart);
                let workOrderId = component.get("v.workOrderId");
                let lineItemNumber = event.getSource().get('v.name');
                let inputWrapper = {'WorkOrderLineItemNumber' : lineItemNumber, 'Status' : 'Closed'};

                let rw = new RequestWrapper();
                rw.FileSize = file.size;
                rw.FileName = file.name;
                rw.FileCategory = 'SF_PHOTO';
                rw.FileBase64 = base64;
                rw.ObjectType = 'WORKORDER_LINEITEM';
                rw.ObjectID = event.getSource().get('v.id');
                rw.Company = '';
                rw.Country = '';

                let action = component.get('c.callDoxee');
                action.setParams({
                    requestWrapper : JSON.stringify(rw),
                    inputWrapper : JSON.stringify(inputWrapper),
                    workOrderId : workOrderId
                });

                action.setCallback(this, function(response) {
                    console.log('TA_LCP217_Interventions >> Helper >> callDoxeeCallback >> Start');
                    if(response.getState() == 'SUCCESS') {
                        if (JSON.parse(response.getReturnValue()).ErrorCode){
                            console.log('ERROR: ' + response.getReturnValue());
                            component.set("v.showToastMessage", true);
                            component.set("v.isError", true);
                            component.set("v.toastMessage", JSON.parse(response.getReturnValue()).ErrorCode);
                        }
                        else {
                            let macroBlockList = component.get('v.infoBag.macroBlockList');
                            macroBlockList.forEach(function(macroBlock) {
                                macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                                    if(rw.ObjectID == woliWrapper.Id) {
                                        //woliWrapper.doxeeURL = response.getReturnValue();
                                        console.log('call doxee return value: ' + response.getReturnValue());
                                        woliWrapper.doxeeUrlManList = JSON.parse(response.getReturnValue());
                                        woliWrapper.status = 'Closed';
                                    }
                                });
                            });
                            component.set('v.infoBag.macroBlockList', macroBlockList);
                        }
                        _helper.checkAllWoliStatus(component);
                        _helper.checkPercentageOfCompletion(component);
                        _helper.fireValidationEvent(component);
                        _helper.fireToggleSpinnerEvent(component, false);
                    } else if(response.getState() == "ERROR") {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.stringify(response.getError()));
                    }
                    console.log('TA_LCP217_Interventions >> Helper >> callDoxeeCallback >> End');
                });
                _helper.fireToggleSpinnerEvent(component, true);
                $A.enqueueAction(action);
            });
            image.src = objFileReader.result;
            console.log('image.src');
        });

        objFileReader.readAsDataURL(file);
        console.log('TA_LCP217_Interventions >> Helper >> callDoxee >> End');
    },*/

    callDoxee : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> callDoxee >> Start');       
        let _helper = this;
        let fileInput = event.getSource().get("v.files");
        let file = fileInput[0];
        let objFileReader = new FileReader();
        let docExtensionList = ['.doc','.docm','.docx','.dot','.dotm','.dotx','.odt','.rtf','.txt'];
        let index = file.name.indexOf('.'); 
        let fileExtension = file.name.substring(index);
        let isDoc = docExtensionList.includes(fileExtension);
        let isPdf = file.name.endsWith('.pdf');

        objFileReader.onload = $A.getCallback(function() {
            console.log('reader onload');
            if(isPdf || isDoc){
                console.log('is pdf or doc: ' + fileExtension);               
                let dataUrl = objFileReader.result;
                _helper.prepareDataAndCallDoxee(component, event, dataUrl, file, isPdf, isDoc);
             }
            else{
                let image = new Image();
                image.onload = $A.getCallback(function() {
                    console.log('image onload');
                    let canvas = document.createElement('canvas'),
                        max_size = 800,// TODO : pull max size from a site config
                        width = image.width,
                        height = image.height;
                    if (width > height) {
                        if (width > max_size) {
                            height *= max_size / width;
                            width = max_size;
                        }
                    } else {
                        if (height > max_size) {
                            width *= max_size / height;
                            height = max_size;
                        }
                    }
                    canvas.width = width;
                    canvas.height = height;
                    canvas.getContext('2d').drawImage(image, 0, 0, width, height);
                    let dataUrl = canvas.toDataURL('image/jpeg');
                    _helper.prepareDataAndCallDoxee(component, event, dataUrl, file, isPdf, isDoc);                    
                });
                image.src = objFileReader.result;               
            }
        });

        objFileReader.readAsDataURL(file);
        console.log('TA_LCP217_Interventions >> Helper >> callDoxee >> End');
    },

    prepareDataAndCallDoxee : function(component, event, dataUrl, file, isPdf, isDoc){
        console.log('TA_LCP217_Interventions >> Helper >> prepareDataAndCallDoxee >> Start'); 
        class RequestWrapper {
            constructor() {
                let FileSize;
                let FileName;
                let FileCreationDate;
                let FileCategory;
                let FileBase64;
                let ObjectType;
                let ObjectID;
                let Company;
                let Country;
            }
        }
        let _helper = this; 
        let fileContents = dataUrl;
        let indexOfbase64 = 'base64,';
        let dataStart = fileContents.indexOf(indexOfbase64) + indexOfbase64.length;
        let base64 = fileContents.substring(dataStart);
        let workOrderId = component.get("v.workOrderId");
        let lineItemNumber = event.getSource().get('v.name');
        let inputWrapper = {'WorkOrderLineItemNumber' : lineItemNumber, 'Status' : 'Closed'};

        let rw = new RequestWrapper();
        rw.FileSize = file.size;
        rw.FileName = file.name;
        rw.FileCategory = 'SF_PHOTO';
        rw.FileBase64 = base64;
        rw.ObjectType = 'WORKORDER_LINEITEM';
        rw.ObjectID = event.getSource().get('v.id');
        rw.Company = '';
        rw.Country = '';

        let action = component.get('c.callDoxee');
        action.setParams({
            requestWrapper : JSON.stringify(rw),
            inputWrapper : JSON.stringify(inputWrapper),
            workOrderId : workOrderId,
            'isPdf' : isPdf,
            'isDoc' : isDoc
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> callDoxeeCallback >> Start');
            if(response.getState() == 'SUCCESS') {
                if (JSON.parse(response.getReturnValue()).ErrorCode){
                    console.log('ERROR: ' + response.getReturnValue());
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.parse(response.getReturnValue()).ErrorCode);
                }
                else {
                    let macroBlockList = component.get('v.infoBag.macroBlockList');
                    macroBlockList.forEach(function(macroBlock) {
                        macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                            if(rw.ObjectID == woliWrapper.Id) {                                
                                console.log('call doxee return value: ' + response.getReturnValue());
                                woliWrapper.doxeeUrlManList = JSON.parse(response.getReturnValue());
                                woliWrapper.status = 'Closed';
                            }
                        });
                    });
                    component.set('v.infoBag.macroBlockList', macroBlockList);
                }
                _helper.checkAllWoliStatus(component);
                _helper.checkPercentageOfCompletion(component);
                _helper.fireValidationEvent(component);
                _helper.fireToggleSpinnerEvent(component, false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP217_Interventions >> Helper >> callDoxeeCallback >> End');
        });          
        _helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(action);
        console.log('TA_LCP217_Interventions >> Helper >> prepareDataAndCallDoxee >> End');     
    },
    //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf

    removePhoto : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> removePhoto >> Start');
        let _helper = this;
        let contentDocumentId = [event.target.id];
        let woliId = [event.target.name];
        let macroBlockList = component.get('v.infoBag.macroBlockList');

        let action = component.get('c.removePhoto');
        action.setParams({
            "contentDocumentIdList" : contentDocumentId,
            "woliIdList" : woliId
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> removePhotoCallback >> Start');
            if(response.getState() == 'SUCCESS') {
                macroBlockList.forEach(function(macroBlock) {
                    macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                        if(woliId == woliWrapper.Id) {
                            woliWrapper.contentVersionList = response.getReturnValue();
                            if(woliWrapper.contentVersionList.length > 0) {
                                woliWrapper.status = 'Closed';
                            } else {
                                woliWrapper.status = 'New';
                            }
                        }
                    });
                });

                component.set('v.infoBag.macroBlockList', macroBlockList);
                _helper.checkAllWoliStatus(component);
                _helper.checkPercentageOfCompletion(component);
                _helper.fireValidationEvent(component);
                _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP217_Interventions >> Helper >> removePhotoCallback >> End');
        });

        this.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
        $A.enqueueAction(action);
        console.log('TA_LCP217_Interventions >> Helper >> removePhoto >> End');
    },

    deletePhoto : function (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> deletePhoto >> Start');
        let _helper = this;
        let woliId = event.target.id;
        let lineItemNumber = event.target.name;
        let dumUrl = event.target.title;
        let workOrderId = component.get("v.workOrderId");
        let inputWrapper = {
                            'WorkOrderLineItemNumber' : lineItemNumber,
                            'Status' : 'New'
                        };

        let action = component.get('c.deletePhoto');
        action.setParam("woliId", woliId);
        action.setParam("inputWrapper", JSON.stringify(inputWrapper));
        action.setParam("workOrderId", workOrderId);
        action.setParam("dumUrl", dumUrl);

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> deletePhotoCallback >> Start');
            if(response.getState() == 'SUCCESS') {
                let macroBlockList = component.get('v.infoBag.macroBlockList');
                macroBlockList.forEach(function(macroBlock) {
                    macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                        console.log('response delete photo: ' + JSON.stringify(response.getReturnValue()));
                        if(woliId == woliWrapper.Id) {                            
                            //woliWrapper.doxeeURL = null;
                            woliWrapper.doxeeUrlManList = response.getReturnValue(); 
                            if($A.util.isEmpty(response.getReturnValue())){
                                woliWrapper.status = 'New';
                            }
                        }
                    });
                });

                component.set('v.infoBag.macroBlockList', macroBlockList);
                _helper.checkAllWoliStatus(component);
                _helper.checkPercentageOfCompletion(component);
                _helper.fireValidationEvent(component);
                _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');
            }
        });

        this.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
        $A.enqueueAction(action);
        console.log('TA_LCP217_Interventions >> Helper >> deletePhoto >> End');
    },

    closeWoli : function  (component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> closeWoli >> Start');
        let _helper = this;
        let buttonName = event.target.name;
        let lineItemNumber = event.target.id;
        let woId = component.get("v.workOrderId");

        let inputWrapper = {
                            'WorkOrderLineItemNumber' : lineItemNumber,
                            'Status' : 'Closed',
                            'TechnicianResponse' : buttonName
                        };

        let action = component.get("c.closeWoli");
        action.setParam("inputWrapper", JSON.stringify(inputWrapper));
        action.setParam("woId", woId);

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> closeWoliCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let woliWrapperReturned = response.getReturnValue();
                let macroBlockList = component.get('v.infoBag.macroBlockList');
                macroBlockList.forEach(function(macroBlock) {
                    macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                        if(lineItemNumber == woliWrapper.lineItemNumber) {
                            woliWrapper.status = woliWrapperReturned.Status;
                            woliWrapper.technicianResponse = woliWrapperReturned.XC_TechnicianResponse__c;
                        }
                    });
                });

                component.set('v.infoBag.macroBlockList', macroBlockList);
                _helper.checkAllWoliStatus(component);
                _helper.checkPercentageOfCompletion(component);
                _helper.fireValidationEvent(component);
                _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP217_Interventions >> Helper >> closeWoliCallback >> End');
        });

        this.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
        $A.enqueueAction(action);
        console.log('TA_LCP217_Interventions >> Helper >> closeWoli >> End');
    },

    insertMeasure : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> insertMeasure >> Start');
        let _helper = this;
        let measureValue = event.getSource().get('v.value');
        if(measureValue) {
            measureValue = null;
        }
        let woliId = event.getSource().get('v.name');

        let action = component.get("c.insertMeasure");
        action.setParam("measureValue", measureValue);
        action.setParam("woliId", woliId);

        action.setCallback(this, function(response) {
            console.log('TA_LCP217_Interventions >> Helper >> insertMeasureCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let returnValue = response.getReturnValue();
                let macroBlockList = component.get('v.infoBag.macroBlockList');
                macroBlockList.forEach(function(macroBlock) {
                    macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                        if(woliId == woliWrapper.Id) {
                            woliWrapper.status = returnValue.Status;
                            if(measureValue != null && (measureValue < woliWrapper.minRange || measureValue > woliWrapper.maxRange)) {
                                woliWrapper.showWarning = true;
                            } else {
                                woliWrapper.showWarning = false;
                            }
                        }
                    });
                });
                component.set('v.infoBag.macroBlockList', macroBlockList);
                _helper.checkAllWoliStatus(component);
                _helper.checkPercentageOfCompletion(component);
                _helper.fireValidationEvent(component);
                _helper.fireToggleSpinnerEvent(component, false, 'TA_LCP217_Interventions');
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP217_Interventions >> Helper >> insertMeasureCallback >> End');
        });

        this.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
        $A.enqueueAction(action);
        console.log('TA_LCP217_Interventions >> Helper >> insertMeasure >> End');
    },

    checkAllWoliStatus : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> checkAllWoliStatus >> Start');
        let macroBlockList = component.get('v.infoBag.macroBlockList');
        macroBlockList.forEach(function(macroBlock) {
            macroBlock.blockColor = 'green';
            let wolisCompleted = [];
            let wolisNotCompleted = [];
            macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                if(woliWrapper.status == 'Closed' || !woliWrapper.required) {
                    wolisCompleted.push(woliWrapper);
                }
                else wolisNotCompleted.push(woliWrapper);
                if(wolisCompleted.length > 0 && wolisNotCompleted.length == 0)
                    macroBlock.blockColor = 'green';
                else if(wolisCompleted.length > 0 && wolisNotCompleted.length > 0)
                    macroBlock.blockColor = 'orange';
                else if(wolisCompleted.length == 0 && wolisNotCompleted.length > 0)
                    macroBlock.blockColor = 'red';
            });
        });
        component.set("v.infoBag.macroBlockList", macroBlockList);
        console.log('TA_LCP217_Interventions >> Helper >> checkAllWoliStatus >> End');
    },

    checkPercentageOfCompletion : function(component) {
        console.log('TA_LCP217_Interventions >> Helper >> checkPercentageOfCompletion >> Start');
        let macroBlockList = component.get('v.infoBag.macroBlockList');
        let percentageOfCompletion = 0;
        let numberOfWoli = component.get('v.infoBag.numberOfWoli');
        let _helper = this;
        let singlePercent = 100 / numberOfWoli;
        macroBlockList.forEach(function(macroBlock) {
            macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                if(woliWrapper.status == 'Closed' || !woliWrapper.required) {
                    percentageOfCompletion += singlePercent;
                    percentageOfCompletion = percentageOfCompletion > 99 ? 100 : percentageOfCompletion;
                }
            });
        });
        component.set("v.percentageOfCompletion", percentageOfCompletion);
        setTimeout(function() {
            _helper.createProgressCircle(percentageOfCompletion);
        }, 1000);
        console.log('TA_LCP217_Interventions >> Helper >> checkPercentageOfCompletion >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner, cmpName) {
        console.log('TA_LCP217_Interventions >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : cmpName,
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP217_Interventions >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP217_Interventions >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP217_Interventions",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP217_Interventions >> Helper >> fireSendInitStateEvt >> End');
    },

    showDescription : function(component, event, helper) {
        console.log('TA_LCP217_Interventions >> Helper >> showDescription >> Start');
        let woliId = event.getSource().get('v.id');
        let macroBlockList = component.get('v.infoBag.macroBlockList');
        macroBlockList.forEach(function(macroBlock) {
            macroBlock.woliListWrapper.forEach(function(woliWrapper) {
                if(woliId == woliWrapper.Id) {
                    woliWrapper.showDescription = !woliWrapper.showDescription;
                }
            });
        });
        component.set('v.infoBag.macroBlockList', macroBlockList);
        console.log('TA_LCP217_Interventions >> Helper >> showDescription >> End');
    },

    fireValidationEvent : function(component) {
        console.log('TA_LCP217_Interventions >> Helper >> fireEvts >> Start');
        let percentageOfCompletion = component.get("v.percentageOfCompletion");
        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : 'TA_LCP217_Interventions',
            "errors" : [$A.get("$Label.c.TA_InterventionsNotCompleted")],
            "validate" : percentageOfCompletion < 100 ? false : true
        });
        validationEvt.fire();
        console.log('TA_LCP217_Interventions >> Helper >> fireEvts >> End');
    },

    createProgressCircle : function(percentageOfCompletion) {
        console.log('TA_LCP217_Interventions >> Helper >> createProgressCircle >> Start');
        let el = document.getElementById('graph');
        let graphspan = document.getElementById("graphspan") || document.getElementById("graphspancompleted");
        let canvasgraph = document.getElementById("canvasgraph");

        if(graphspan != null) graphspan.remove();
        if(canvasgraph != null) canvasgraph.remove();

        let options = {
            percent:  el.getAttribute('data-percent') || 25,
            size: el.getAttribute('data-size') || 50,
            lineWidth: 5,
            rotate: el.getAttribute('data-rotate') || 0
        }

        let completed = options.percent == '100' ? true : false;

        let canvas = document.createElement('canvas');
        let span = document.createElement('span');
        span.textContent = (completed ? options.percent.substring(0, 3) : options.percent.substring(0,2)) + '%';
        span.id = completed ? "graphspancompleted" : "graphspan";

        if (typeof(G_vmlCanvasManager) !== 'undefined') {
            G_vmlCanvasManager.initElement(canvas);
        }

        let ctx = canvas.getContext('2d');
        canvas.width = canvas.height = options.size;
        canvas.id = "canvasgraph";

        el.appendChild(span);
        el.appendChild(canvas);

        ctx.translate(options.size / 2, options.size / 2);
        ctx.rotate((-1 / 2 + options.rotate / 180) * Math.PI);

        let radius = (options.size - options.lineWidth) / 2;

        let drawCircle = function(color, lineWidth, percent) {
                percent = Math.min(Math.max(0, percent || 1), 1);
                ctx.beginPath();
                ctx.arc(0, 0, radius, 0, Math.PI * 2 * percent, false);
                ctx.strokeStyle = color;
                ctx.lineCap = 'round';
                ctx.lineWidth = lineWidth
                ctx.stroke();
        };

        let circleColor = percentageOfCompletion == 0 ? 'rgba(255,64,64,1)' : percentageOfCompletion == 100 ? 'rgba(0, 201, 131, 1)' : 'rgba(255, 188, 0, 1)';

        drawCircle('transparent', options.lineWidth, 100 / 100);
        drawCircle(circleColor, options.lineWidth, options.percent / 100);
        console.log('TA_LCP217_Interventions >> Helper >> createProgressCircle >> End');
    },
    editRecord : function(component,idRecord,recordTypeId,objectName,modalTitleRecord){
        console.log('TA_LCP217_Interventions >> helper >> editRecord >> Start');
        console.log('idRecord',idRecord);
        console.log('recordTypeId',recordTypeId);
        console.log('objectName',objectName);
        //component.set('v.woliIdToEdit',idRecord);
        component.set('v.formRecordTypeId',recordTypeId);
        component.set('v.recordSubmitId', idRecord);
        component.set('v.buttonType','edit');
        component.set('v.objectName',objectName);
        component.set('v.showComponentEditRecord', !component.get('v.showComponentEditRecord'));
        component.set('v.showComponentCreateRecord', !component.get('v.showComponentCreateRecord'));
        console.log('TA_LCP217_Interventions >> helper >> editRecord >> End');
        let element = component.find("createModalComponent");
        console.log('elementCreateRecord :',element);
        element.set("v.modalTitleRecord",modalTitleRecord);
    },
    showActionModal : function (component,showAttribute,woliId){
        console.log('TA_LCP217_Interventions >> Controller >> handleAddProductConsumed >> Start');
        component.set("v.WOLIRecordId",woliId);
        component.set(showAttribute, !component.get(showAttribute));
        console.log(showAttribute,component.get(showAttribute));
        console.log('TA_LCP217_Interventions >> Controller >> handleAddProductConsumed >> End');
    },
    startFlow : function(component,recordId,flowName){
        console.log('TA_LCP217_Interventions >> Controller >> startFlow >> Start');
        let recordSubmitId = recordId;
        console.log('recordSubmitId: '+recordSubmitId);
        component.set("v.showComponentFlow",true);
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        var inputVariables = [{ name : "recordId", type : "String", value: recordSubmitId}];
        flow.startFlow(flowName,inputVariables);
        console.log('TA_LCP217_Interventions >> Controller >> startFlow >> End');
    }
})