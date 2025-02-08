({
    initialize : function(component) {
        console.log('TA_LCP222_IdentityCard >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.descriptionFront', $A.getReference("$Label.c." + component.get('v.custom').descriptionFront));
        component.set('v.descriptionRear', $A.getReference("$Label.c." + component.get('v.custom').descriptionRear));
        this.getDoxeeUrlManagements(component);        
        console.log('TA_LCP222_IdentityCard >> Helper >> initialize >> End');
    },

    deletePhoto : function(component, contentVersionType) {
        console.log('TA_LCP222_IdentityCard >> Helper >> deletePhoto >> Start');
        let objWrapper = component.get('v.objWrapper');
        let deleteDoxeeDocs = component.get('c.deleteDoxeeDocs');

        if(contentVersionType == 'IdentityCard_Front') {
            deleteDoxeeDocs.setParam("doxeeUrlManagementId", objWrapper.identityCardFront.Id);
            objWrapper.identityCardFront = {};
        } else if(contentVersionType == 'IdentityCard_Retro') {
            deleteDoxeeDocs.setParam("doxeeUrlManagementId", objWrapper.identityCardRetro.Id);
            objWrapper.identityCardRetro = {};
        }
        component.set('v.objWrapper', objWrapper);

        deleteDoxeeDocs.setCallback(this, function(response) {
            console.log('TA_LCP222_IdentityCard >> Helper >> deletePhotoCallback >> Start');
            if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                this.fireValidationEvent(component);
            }
            this.fireValidationEvent(component);
            console.log('TA_LCP222_IdentityCard >> Helper >> deletePhotoCallback >> End');
        });

        $A.enqueueAction(deleteDoxeeDocs);
        console.log('TA_LCP222_IdentityCard >> Helper >> deletePhoto >> End');
    },

    getDoxeeUrlManagements : function(component) {
        console.log('TA_LCP222_IdentityCard >> Helper >> getDoxeeUrlManagements >> Start');
        let getDoxeeUrlManagements = component.get("c.getDoxeeUrlManagements");        
        getDoxeeUrlManagements.setParams({
            "workOrderId": component.get('v.workOrderId'),
            "objectType": component.get('v.custom.ObjectType'),
            "fileCategoryFront" : component.get('v.custom.FileCategoryFront'),
            "fileCategoryRear" : component.get('v.custom.FileCategoryRear')
        });

        getDoxeeUrlManagements.setCallback(this, function(response) {
            console.log('TA_LCP222_IdentityCard >> Helper >> getDoxeeUrlManagementsCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.objWrapper', response.getReturnValue());
                console.log('@@@@ objWrapper + ' +JSON.stringify(response.getReturnValue()));
                component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                this.fireSendInitStateEvt(component, true);
                this.fireValidationEvent(component);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                this.fireValidationEvent(component);
            }
            console.log('TA_LCP222_IdentityCard >> Helper >> getDoxeeUrlManagementsCallback >> End');
        });

        $A.enqueueAction(getDoxeeUrlManagements);
        console.log('TA_LCP222_IdentityCard >> Helper >> getDoxeeUrlManagements >> End');
    },

    // callDoxee : function(component, event) {
    //     console.log('TA_LCP222_IdentityCard >> Helper >> callDoxee >> Start');
    //     let file = event.getSource().get("v.files")[0];
    //     let fileReader = new FileReader();
    //     let _helper = this;

    //     fileReader.onload = $A.getCallback(function() {
    //         let contents = fileReader.result;
    //         let indexOfbase64 = 'base64,';
    //         let dataStart = contents.indexOf(indexOfbase64) + indexOfbase64.length;
    //         let base64 = contents.substring(dataStart);
    //         let callDoxee = component.get("c.callDoxee");
    //         let fileCategory = event.getSource().get('v.title');
    //         let objectType = component.get("v.custom.ObjectType");
    //         let objectID = event.getSource().get('v.id');
    //         console.log('fileCategory: ' + fileCategory);
    //         console.log('objectType: ' + objectType);
    //         console.log('objectID: ' + objectID);
    //         let fileWrapper = {
    //             "FileSize" : file.size,
    //             "FileName" : file.name,
    //             "FileCategory" : fileCategory,
    //             "FileBase64" : base64,
    //             "ObjectType" : objectType,
    //             "ObjectID" : objectID,
    //             "Company" : "",
    //             "Country" : ""
    //         }

    //         callDoxee.setParams({"fileWrapper" : JSON.stringify(fileWrapper),
    //                              "identityCardType" : fileCategory,
    //                              'workOrderId' : component.get('v.workOrderId')
    //                             });

    //         callDoxee.setCallback(this, function(response) {
    //             console.log('TA_LCP222_IdentityCard >> Helper >> callDoxeeCallback >> Start');
    //             let objWrapperReturnValue = JSON.parse(response.getReturnValue());
    //             console.log('objWrapperReturnValue: ' + response.getReturnValue());
    //             if(response.getState() == "SUCCESS") {
    //                 let objWrapper = component.get('v.objWrapper');
    //                 if(event.getSource().get('v.name') == 'IdentityCard_Front' && objWrapperReturnValue.resp.Result.ErrorCode == '0') {
    //                     objWrapper.identityCardFront = objWrapperReturnValue.doxeeUrlManagement;
    //                 } else if(event.getSource().get('v.name') == 'IdentityCard_Retro' && objWrapperReturnValue.resp.Result.ErrorCode == '0') {
    //                     objWrapper.identityCardRetro = objWrapperReturnValue.doxeeUrlManagement;
    //                 }
    //                 else if(objWrapperReturnValue.resp.Result.ErrorCode != '0'){
    //                     component.set("v.showToastMessage", true);
    //                     component.set("v.isError", true);
    //                     component.set("v.toastMessage", JSON.stringify(objWrapperReturnValue.resp.Result.Message));                        
    //                 }
    //                 component.set('v.objWrapper', objWrapper); 

    //             } else if(response.getState() == "ERROR") {
    //                 component.set("v.showToastMessage", true);
    //                 component.set("v.isError", true);
    //                 component.set("v.toastMessage", JSON.stringify(response.getError()));
    //                 _helper.fireValidationEvent(component);
    //             }
    //             _helper.fireToggleSpinnerEvent(component, false);
    //             _helper.fireValidationEvent(component);
    //             console.log('TA_LCP222_IdentityCard >> Helper >> callDoxeeCallback >> End');
    //         });
    
    //         _helper.fireToggleSpinnerEvent(component, true);
    //         $A.enqueueAction(callDoxee);
    //     });

    //     fileReader.readAsDataURL(file);
    //     console.log('TA_LCP222_IdentityCard >> Helper >> callDoxee >> End');
    // },

    //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
    /*callDoxee : function(component, event) {
        console.log('TA_LCP222_IdentityCard >> Helper >> callDoxee >> Start');
        let file = event.getSource().get("v.files")[0];
        let fileReader = new FileReader();
        let _helper = this;

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

                // let contents = fileReader.result;
                let contents = dataUrl;
                let indexOfbase64 = 'base64,';
                let dataStart = contents.indexOf(indexOfbase64) + indexOfbase64.length;
                let base64 = contents.substring(dataStart);
                let callDoxee = component.get("c.callDoxee");
                let fileCategory = event.getSource().get('v.title');
                let objectType = component.get("v.custom.ObjectType");
                let objectID = event.getSource().get('v.id');
                console.log('fileCategory: ' + fileCategory);
                console.log('objectType: ' + objectType);
                console.log('objectID: ' + objectID);
                let fileWrapper = {
                    "FileSize" : file.size,
                    "FileName" : file.name,
                    "FileCategory" : fileCategory,
                    "FileBase64" : base64,
                    "ObjectType" : objectType,
                    "ObjectID" : objectID,
                    "Company" : "",
                    "Country" : ""
                }

                callDoxee.setParams({"fileWrapper" : JSON.stringify(fileWrapper),
                                    "identityCardType" : fileCategory,
                                    'workOrderId' : component.get('v.workOrderId')
                                    });

                callDoxee.setCallback(this, function(response) {
                    console.log('TA_LCP222_IdentityCard >> Helper >> callDoxeeCallback >> Start');
                    let objWrapperReturnValue = JSON.parse(response.getReturnValue());
                    console.log('objWrapperReturnValue: ' + response.getReturnValue());
                    if(response.getState() == "SUCCESS") {
                        let objWrapper = component.get('v.objWrapper');
                        if(event.getSource().get('v.name') == 'IdentityCard_Front' && objWrapperReturnValue.resp.Result.ErrorCode == '0') {
                            objWrapper.identityCardFront = objWrapperReturnValue.doxeeUrlManagement;
                        } else if(event.getSource().get('v.name') == 'IdentityCard_Retro' && objWrapperReturnValue.resp.Result.ErrorCode == '0') {
                            objWrapper.identityCardRetro = objWrapperReturnValue.doxeeUrlManagement;
                        }
                        else if(objWrapperReturnValue.resp.Result.ErrorCode != '0'){
                            component.set("v.showToastMessage", true);
                            component.set("v.isError", true);
                            component.set("v.toastMessage", JSON.stringify(objWrapperReturnValue.resp.Result.Message));                        
                        }
                        component.set('v.objWrapper', objWrapper); 

                    } else if(response.getState() == "ERROR") {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.stringify(response.getError()));
                        _helper.fireValidationEvent(component);
                    }
                    _helper.fireToggleSpinnerEvent(component, false);
                    _helper.fireValidationEvent(component);
                    console.log('TA_LCP222_IdentityCard >> Helper >> callDoxeeCallback >> End');
                });
        
                _helper.fireToggleSpinnerEvent(component, true);
                $A.enqueueAction(callDoxee);
            });

            image.src = fileReader.result;
            console.log('image.src');
        });

        fileReader.readAsDataURL(file);
        console.log('TA_LCP222_IdentityCard >> Helper >> callDoxee >> End');
    },*/

     callDoxee : function(component, event) {
        console.log('TA_LCP222_IdentityCard >> Helper >> callDoxee >> Start');
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
               _helper.prepareDataAndCallDoxee(component, event, dataUrl, file, isPdf, isDoc);
            }
            else{
                console.log('is image'); 
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

                image.src = fileReader.result;                
            }
        });        
        fileReader.readAsDataURL(file);
        console.log('TA_LCP222_IdentityCard >> Helper >> callDoxee >> End');
    },

    prepareDataAndCallDoxee : function(component, event, dataUrl, file, isPdf, isDoc){
        console.log('TA_LCP222_IdentityCard >> Helper >> prepareDataAndCallDoxee >> Start');        
        let _helper = this;
        let contents = dataUrl;
        let indexOfbase64 = 'base64,';
        let dataStart = contents.indexOf(indexOfbase64) + indexOfbase64.length;
        let base64 = contents.substring(dataStart);
        let callDoxee = component.get("c.callDoxee");
        let fileCategory = event.getSource().get('v.title');
        let objectType = component.get("v.custom.ObjectType");
        let objectID = event.getSource().get('v.id');
        console.log('fileCategory: ' + fileCategory);
        console.log('objectType: ' + objectType);
        console.log('objectID: ' + objectID);
        let fileWrapper = {
            "FileSize" : file.size,
            "FileName" : file.name,
            "FileCategory" : fileCategory,
            "FileBase64" : base64,
            "ObjectType" : objectType,
            "ObjectID" : objectID,
            "Company" : "",
            "Country" : ""
        }

        callDoxee.setParams({"fileWrapper" : JSON.stringify(fileWrapper),
                            "identityCardType" : fileCategory,
                            'workOrderId' : component.get('v.workOrderId'),
                            'isPdf' : isPdf,
                            'isDoc' : isDoc
                            });

        callDoxee.setCallback(this, function(response) {
            console.log('TA_LCP222_IdentityCard >> Helper >> prepareDataAndCallDoxee >> Start');
            let objWrapperReturnValue = JSON.parse(response.getReturnValue());
            console.log('objWrapperReturnValue: ' + response.getReturnValue());
            if(response.getState() == "SUCCESS") {
                let objWrapper = component.get('v.objWrapper');
                if(event.getSource().get('v.name') == 'IdentityCard_Front' && objWrapperReturnValue.resp.Result.ErrorCode == '0') {
                    objWrapper.identityCardFront = objWrapperReturnValue.doxeeUrlManagement;
                } else if(event.getSource().get('v.name') == 'IdentityCard_Retro' && objWrapperReturnValue.resp.Result.ErrorCode == '0') {
                    objWrapper.identityCardRetro = objWrapperReturnValue.doxeeUrlManagement;
                }
                else if(objWrapperReturnValue.resp.Result.ErrorCode != '0'){
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(objWrapperReturnValue.resp.Result.Message));                        
                }
                component.set('v.objWrapper', objWrapper); 

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.fireValidationEvent(component);
            }
            _helper.fireToggleSpinnerEvent(component, false);
            _helper.fireValidationEvent(component);
            console.log('TA_LCP222_IdentityCard >> Helper >> prepareDataAndCallDoxee >> End');
        });

        _helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(callDoxee);
        console.log('TA_LCP222_IdentityCard >> Helper >> prepareDataAndCallDoxee >> End');
    },
    //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP222_IdentityCard >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP222_IdentityCard",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP222_IdentityCard >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP222_IdentityCard >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP222_IdentityCard",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP222_IdentityCard >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireValidationEvent : function(component) {
        console.log('TA_LCP222_IdentityCard >> Helper >> fireValidationEvent >> Start');
        let objWrapper = component.get('v.objWrapper');
        console.log('objWrapper: ' + JSON.stringify(objWrapper));
        let validate = $A.util.isEmpty(objWrapper.identityCardFront) || $A.util.isEmpty(objWrapper.identityCardRetro) ? false : true;
        console.log('validate: ' + validate);

        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : 'TA_LCP222_IdentityCard' + component.get('v.title'),
            "errors" : ['Please upload ' + component.get('v.title')],
            "validate" : validate
        }); 
        validationEvt.fire(); 

        console.log('TA_LCP222_IdentityCard >> Helper >> fireValidationEvent >> End');
    }
})