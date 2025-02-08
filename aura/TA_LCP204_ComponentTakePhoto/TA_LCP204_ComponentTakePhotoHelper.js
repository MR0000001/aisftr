({
    initialize : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
        component.set('v.minQtyImagesLabel', $A.getReference('$Label.c.TA_MinQtyImages'));
        helper.getFile(component, event, helper);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> initialize >> End');
    },

    getFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> getFile >> Start');
        let workOrder = component.get("v.workOrder");
        let getFile = component.get("c.getFile");
        getFile.setParams({
            "workOrder" : workOrder,
            "customConfigSerialized" : JSON.stringify(component.get("v.custom")),
        });

        getFile.setCallback(this, function(response) {
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> getFileCallback >> Start');
            if(response.getState() == "SUCCESS") {               
                component.set("v.workOrder", JSON.parse(response.getReturnValue()).workOrder);                
                //JS - ENXCRM-214 - 28/04/2022 - START
                component.set("v.caseId", JSON.parse(response.getReturnValue()).workOrder.CaseId);
                if(JSON.parse(component.get('v.fieldSet')).custom.saveOnCase == 'true'){
                    component.set("v.saveOnCase", true);
                }
                //JS - ENXCRM-214 - 28/04/2022 - END
                if(JSON.parse(response.getReturnValue()).getFileResponse) {
                    component.set("v.listPhotosUrl", JSON.parse(response.getReturnValue()).getFileResponse);
                    if(component.get('v.listPhotosUrl') != null) {
                        let numberOfImgs = component.get('v.numberOfImgs');
                        component.get('v.listPhotosUrl').forEach(function(photo) {
                            numberOfImgs++;
                        });
                        component.set('v.numberOfImgs', numberOfImgs);
                        if(numberOfImgs > 0) {
                            component.set('v.indexImages', numberOfImgs);
                        }

                        if(component.get('v.custom').minQtyImages > component.get('v.numberOfImgs')) helper.fireValidationEvt(component, [component.get('v.title') + ': ' + component.get('v.minQtyImagesLabel') + ' ' + component.get('v.custom').minQtyImages], 'TA_LCP204_ComponentTakePhoto');
                        else helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhoto');
                    }
                } else if(JSON.parse(response.getReturnValue()).error) {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.parse(response.getReturnValue()).error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            this.fireSendInitStateEvt(component, true);
            component.set("v.isInitialized", true);
            
            if(component.get("v.custom").fileCategory == 'SF_EXTRA_COST_INVOICE'){ 
                if(!component.get("v.workOrder").XC_ExtraCost__c) component.set("v.isInitialized", false); 
                else component.set("v.extraCostInvoiceToSend",true);
                helper.checkExtraCostInvoiceValidation(component, event);     
            }
            
            //START [20220517AL] - NR2551
            if(component.get("v.custom").fileCategory == 'SF_PERMITTING_FORM') {
                if(component.get("v.workOrder").XC_PermittingForm__c == 'Needed') component.set("v.permittingFormRequired", true);
                else component.set("v.isInitialized", false); 
                helper.checkPermittingForm(component, event);  
            }
            //END [20220517AL] - NR2551
            
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> getFileCallback >> End');
        });

        $A.enqueueAction(getFile);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> getFile >> End');
    },
    /* [ADC] start fix resize photo
    uploadFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFile >> Start');
        let file = event.getSource().get("v.files")[0];
        let fileReader = new FileReader();

        fileReader.onload = $A.getCallback(function() {
            let contents = fileReader.result;
            let indexOfbase64 = 'base64,';
            let dataStart = contents.indexOf(indexOfbase64) + indexOfbase64.length;
            let base64 = contents.substring(dataStart);
            let fileWrapper = {
                "FileSize" : file.size,
                "FileName" : file.name,
                "FileCategory" : "SF_GENERIC_DOCUMENT",
                "FileBase64" : base64,
                "ObjectType" : "WORKORDER",
                "ObjectID" : event.getSource().get('v.id'),
                "Company" : "",
                "Country" : ""
            }

            let uploadFile = component.get("c.uploadFile");
            uploadFile.setParam("fileWrapper", JSON.stringify(fileWrapper));

            uploadFile.setCallback(this, function(response) {
                console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFileCallback >> Start');
                if(response.getState() == "SUCCESS") {
                    if(JSON.parse(response.getReturnValue()).uploadFileResponse) {
                        let listPhotosUrl = component.get("v.listPhotosUrl");
                        listPhotosUrl.push(JSON.parse(response.getReturnValue()).uploadFileResponse);
                        component.set("v.listPhotosUrl", listPhotosUrl);
                    } else if(JSON.parse(response.getReturnValue()).error) {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.parse(response.getReturnValue()).error);
                    }
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                }
                helper.fireToggleSpinnerEvent(component, false);
                console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFileCallback >> End');
            });

            $A.enqueueAction(uploadFile);
        });

        fileReader.readAsDataURL(file);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFile >> End');
    },
    */    
    //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
    /*uploadFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFile >> Start');
        let file = event.getSource().get("v.files")[0];
        let fileReader = new FileReader();
        

        fileReader.onload = $A.getCallback(function() {
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
                let contents = dataUrl;
                let indexOfbase64 = 'base64,';
                let dataStart = contents.indexOf(indexOfbase64) + indexOfbase64.length;
                let base64 = contents.substring(dataStart);
                let fileWrapper = {
                    "FileSize" : file.size,
                    "FileName" : component.get('v.custom').fileName != null ? (component.get('v.custom').fileName + '_' + component.get('v.indexImages') + file.name.slice(-4)) : file.name,
                    "FileCategory" : "SF_GENERIC_DOCUMENT",
                    "FileBase64" : base64,
                    "ObjectType" : "WORKORDER",
                    "ObjectID" : event.getSource().get('v.id'),
                    "Company" : "",
                    "Country" : ""
                }

                let uploadFile = component.get("c.uploadFile");
                uploadFile.setParam("fileWrapper", JSON.stringify(fileWrapper));

                uploadFile.setCallback(this, function(response) {
                    console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFileCallback >> Start');
                    if(response.getState() == "SUCCESS") {
                        if(JSON.parse(response.getReturnValue()).uploadFileResponse) {
                            let listPhotosUrl = component.get("v.listPhotosUrl");
                            listPhotosUrl.push(JSON.parse(response.getReturnValue()).uploadFileResponse);
                            component.set("v.listPhotosUrl", listPhotosUrl);
                            component.set('v.numberOfImgs', component.get('v.numberOfImgs') + 1);
                            component.set('v.indexImages', component.get('v.indexImages') + 1);

                            if(component.get('v.custom').minQtyImages > component.get('v.numberOfImgs')) helper.fireValidationEvt(component, [component.get('v.minQtyImagesLabel') + ' ' + component.get('v.custom').minQtyImages]);
                            else helper.fireValidationEvt(component, []);

                        } else if(JSON.parse(response.getReturnValue()).error) {
                            component.set("v.showToastMessage", true);
                            component.set("v.isError", true);
                            component.set("v.toastMessage", JSON.parse(response.getReturnValue()).error);
                        }
                    } else if(response.getState() == "ERROR") {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.stringify(response.getError()));
                    }
                    helper.fireToggleSpinnerEvent(component, false);
                    console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFileCallback >> End');
                });

                $A.enqueueAction(uploadFile);
            });
            image.src = fileReader.result;
            console.log('image.src');
        });

        fileReader.readAsDataURL(file);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFile >> End');
    },*/
    // [ADC] end fix resize photo

    uploadFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFile >> Start');
        let file = event.getSource().get("v.files")[0];
        let fileReader = new FileReader();
        let _helper = this;
        let docExtensionList = ['.doc','.docm','.docx','.dot','.dotm','.dotx','.odt','.rtf','.txt'];
        let index = file.name.indexOf('.'); 
        let fileExtension = file.name.substring(index);
        let isDoc = docExtensionList.includes(fileExtension);
        let isPdf = file.name.endsWith('.pdf');

        fileReader.onload = $A.getCallback(function() {
            console.log('reader onload');
            if(isPdf || isDoc){
                console.log('is pdf or doc: ' + fileExtension);          
                let dataUrl = fileReader.result;
                _helper.prepareDataAndCallDoxee(component, event, dataUrl, file, fileExtension, isPdf, isDoc);
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
                    _helper.prepareDataAndCallDoxee(component, event, dataUrl, file, fileExtension, isPdf, isDoc);                    
                });
                image.src = fileReader.result;               
            }
        });

        fileReader.readAsDataURL(file);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFile >> End');
    },

    prepareDataAndCallDoxee : function(component, event, dataUrl, file, fileExtension, isPdf, isDoc){
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> prepareDataAndCallDoxee >> Start');
        //JS - ENXCRM-214 - 28/04/2022 - START
        let saveOnCase = component.get("v.saveOnCase");
        //JS - ENXCRM-214 - 28/04/2022 - END
        let contents = dataUrl;
        let _helper = this;
        let indexOfbase64 = 'base64,';
        let dataStart = contents.indexOf(indexOfbase64) + indexOfbase64.length;
        let base64 = contents.substring(dataStart);
        let fileCategory = component.get("v.custom").fileCategory != null ? component.get("v.custom").fileCategory : "SF_GENERIC_DOCUMENT";
        //JS - ENXCRM-214 - 28/04/2022 - START
        /*let fileWrapper = {
            "FileSize" : file.size,
            "FileName" : component.get('v.custom').fileName != null ? (component.get('v.custom').fileName + '_' + component.get('v.indexImages') + fileExtension) : file.name,
            "FileCategory" : fileCategory,
            "FileBase64" : base64,
            "ObjectType" : "WORKORDER",
            "ObjectID" : event.getSource().get('v.id'),
            "Company" : "",
            "Country" : ""
        }*/

        let fileWrapper = {
            "FileSize" : file.size,
            "FileName" : component.get('v.custom').fileName != null ? (component.get('v.custom').fileName + '_' + component.get('v.indexImages') + fileExtension) : file.name,
            "FileCategory" : fileCategory,
            "FileBase64" : base64,
            "ObjectType" : saveOnCase ? "CASE" : "WORKORDER",
            "ObjectID" : event.getSource().get('v.id'),
            "Company" : "",
            "Country" : ""
        }
        //JS - ENXCRM-214 - 28/04/2022 - END  
        let uploadFile = component.get("c.uploadFile");
        uploadFile.setParam("fileWrapper", JSON.stringify(fileWrapper));
        uploadFile.setParam("isPdf", isPdf);
        uploadFile.setParam("isDoc", isDoc);

        uploadFile.setCallback(this, function(response) {
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFileCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(JSON.parse(response.getReturnValue()).uploadFileResponse) {
                    let listPhotosUrl = component.get("v.listPhotosUrl");
                    listPhotosUrl.push(JSON.parse(response.getReturnValue()).uploadFileResponse);
                    component.set("v.listPhotosUrl", listPhotosUrl);
                    component.set('v.numberOfImgs', component.get('v.numberOfImgs') + 1);
                    component.set('v.indexImages', component.get('v.indexImages') + 1);

                    if(component.get('v.custom').minQtyImages > component.get('v.numberOfImgs')) _helper.fireValidationEvt(component, [component.get('v.title') + ': ' + component.get('v.minQtyImagesLabel') + ' ' + component.get('v.custom').minQtyImages], 'TA_LCP204_ComponentTakePhoto');
                    else _helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhoto');

                    if(component.get("v.custom").fileCategory == 'SF_EXTRA_COST_INVOICE'){              
                        _helper.checkExtraCostInvoiceValidation(component, event);               
                    }

                    //START [20220517AL] - NR2551
                    if(component.get("v.custom").fileCategory == 'SF_PERMITTING_FORM') _helper.checkPermittingForm(component);               
                    //END [20220517AL] - NR2551

                } else if(JSON.parse(response.getReturnValue()).error) {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.parse(response.getReturnValue()).error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            _helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> uploadFileCallback >> End');
        });
        $A.enqueueAction(uploadFile);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> prepareDataAndCallDoxee >> End');
    },
    //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf

    deleteFile : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> deleteFile >> Start');
        let photoId = event.currentTarget.id;
        let deleteFile = component.get('c.deleteFile');
        deleteFile.setParam('doxeeUrlManagementId', photoId);

        deleteFile.setCallback(this, function(response) {
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> deleteFileCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(JSON.parse(response.getReturnValue()).deleteFileResponse) {
                    let photoId = JSON.parse(response.getReturnValue()).deleteFileResponse;
                    let newListPhotoUrl = [];
                    let listPhotosUrl = component.get("v.listPhotosUrl");

                    listPhotosUrl.forEach(function(photoUrl) {
                        if(photoId != photoUrl.Id) {
                            newListPhotoUrl.push(photoUrl);
                        }
                    });

                    component.set("v.listPhotosUrl", newListPhotoUrl);
                    component.set('v.numberOfImgs', component.get('v.numberOfImgs') - 1);

                    if(component.get('v.custom').minQtyImages > component.get('v.numberOfImgs')) helper.fireValidationEvt(component, [component.get('v.title') + ': ' + component.get('v.minQtyImagesLabel') + ' ' + component.get('v.custom').minQtyImages], 'TA_LCP204_ComponentTakePhoto');
                    else helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhoto');

                    //START [20220517AL] - NR2551
                    if(component.get("v.custom").fileCategory == 'SF_PERMITTING_FORM') {
                        helper.checkPermittingForm(component, event);  
                    }
                    //END [20220517AL] - NR2551
                    
                } else if(JSON.parse(response.getReturnValue()).error) {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.parse(response.getReturnValue()).error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> deleteFileCallback >> End');
        });

        $A.enqueueAction(deleteFile);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> deleteFile >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP204_ComponentTakePhoto",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP204_ComponentTakePhoto",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireValidationEvt : function(component, errors, cmpName) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> fireValidationEvt >> Start');
        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : cmpName,
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true
        }); 
        validationEvt.fire();
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> fireValidationEvt >> End');
    },

    updateWasteDisposal : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> updateWasteDisposal >> Start');       
        let action = component.get('c.updateWasteDisposal');
        let fileCategory = component.get("v.custom").fileCategory;
        action.setParams({
            'woSerialized' : JSON.stringify(component.get("v.workOrder"))
            //'wasteDisposal' : wasteDisposal
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> updateWasteDisposalCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    component.set("v.workOrder", JSON.parse(response.getReturnValue().woSerialized));
                    if(fileCategory == 'SF_WASTE_IDENTIFICATION_FORM' || fileCategory == 'SF_TRANSPORT_DOCUMENT'){
                        if(component.get('v.workOrder').XC_WasteDisposal__c == true && JSON.parse(response.getReturnValue().numberOfDocs < 2)) helper.fireValidationEvt(component, [$A.get('$Label.c.TA_TradeInError')], 'TA_LCP204_ComponentTakePhoto');
                        else helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhoto');
                    }
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP204_ComponentTakePhoto >> Helper >> updateWasteDisposalCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> updateWasteDisposal >> End');
    },

    checkExtraCostInvoiceValidation : function(component, event, helper) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> checkExtraCostInvoiceValidation >> Start');
        let _helper = this;
        let fileCategory = component.get("v.custom").fileCategory;
        let listPhotosUrl = component.get('v.listPhotosUrl');
        let extraCostInvoiceToSend = component.get("v.extraCostInvoiceToSend");        
        if(fileCategory == 'SF_EXTRA_COST_INVOICE'){
            if(extraCostInvoiceToSend){
                if(listPhotosUrl.length > 0){
                    listPhotosUrl.forEach(function(invoice) {
                        if(invoice.TA_Type__c == fileCategory){                                                       
                            _helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhotoInvoice');
                            return;
                        }
                        else {                              
                            _helper.fireValidationEvt(component, [$A.get('$Label.c.TA_ExtraCostError')], 'TA_LCP204_ComponentTakePhotoInvoice');
                        }
                    });
                }
                else {                          
                    _helper.fireValidationEvt(component, [$A.get('$Label.c.TA_ExtraCostError')], 'TA_LCP204_ComponentTakePhotoInvoice');
                }
            }
            else {                  
                _helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhotoInvoice');
            }
        }
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> checkExtraCostInvoiceValidation >> End');
    },

    //START [20220517AL] - NR2551
    checkPermittingForm : function(component) {
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> checkPermittingForm >> Start');
        
        let _helper = this;
        let listPhotosUrl = component.get('v.listPhotosUrl');
        let permittingFormRequired = component.get("v.permittingFormRequired");        
        console.log('@@@ checkPermittingForm > permittingFormRequired', permittingFormRequired);
        
        if(permittingFormRequired){
            if(listPhotosUrl.length > 0){
                listPhotosUrl.forEach(function(invoice) {
                    if(invoice.TA_Type__c == 'SF_PERMITTING_FORM'){                                                       
                        _helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhotoPermittingForm');
                        return;
                    }
                });
            } else  _helper.fireValidationEvt(component, [$A.get('$Label.c.TA_PermittingFormError')], 'TA_LCP204_ComponentTakePhotoPermittingForm'); 
        } else _helper.fireValidationEvt(component, [], 'TA_LCP204_ComponentTakePhotoPermittingForm');
        
        console.log('TA_LCP204_ComponentTakePhoto >> Helper >> checkPermittingForm >> End');
    }
    //END [20220517AL] - NR2551
})