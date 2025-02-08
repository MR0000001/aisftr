({
  doInit: function (component, event, helper) {
    //debugger;
    //helper.getOIs(component, event, helper);
    helper.wrapperMethod(component, event, helper);
  },

  showPicklist: function (component, event, helper) {
    console.log("El evento: " + event.getParam("value"));
    //var myCmp = component.find("Exencion");
    console.log("El evento source name: " + event.getSource());
    //console.log('El evento Id: '+event.getSource().get('v.name'));
    var source = event.getSource();
    var prueba = source.getLocalId();
    //let paramStr = JSON.stringify(event.getParams(), null, 4);

    var submitButton = component.find("submitButton");
    if (submitButton != null) {
      for (var i = 0; i < submitButton.length; i++) {
        var oculto = $A.util.hasClass(submitButton[i], "slds-hidden");

        if (oculto) {
          $A.util.removeClass(submitButton[i], "slds-hidden");
        } /*else{
                    $A.util.addClass(submitButton[i], "slds-hidden");
                }*/
      }
    }

    //var myInputs = component.find("myDiv").find({instancesOf : "lightning:inputField"});
    //alert('There are ' + myInputs.length + ' lightning:inputField elements within myDiv.');

    /*var myREF = component.find("myDiv").find({instancesOf : "lightning:recordEditForm"});
        console.log('ALC INICIO MY REF: ');
        let prueba3 = JSON.stringify(myREF);

        let recordEditForms = component.find('myForm');
        debugger;
        console.log('ALC FIN MY REF');
        //alert('There are ' + myREF.length + ' lightning:recordEditForm elements within myDiv.');*/
  },

  guardar: function (component, event, helper) {
    /*var myREF = component.find("myDiv").find({instancesOf : "lightning:recordEditForm"});
        debugger;
        for (var i = 0; i < myREF.length; i++) {
            debugger;
            myREF.submit();
        }*/
    /*debugger;
    component
      .find("myDiv")
      .find({ instancesOf: "lightning:recordEditForm" })
      .forEach((form) => {
        form.submit();
      });
    debugger;*/
    helper.saveTaxes(component, event, helper);
  },

  onRecordSubmit: function (component, event, helper) {
    event.preventDefault(); // stop form submission
    var eventtest = event.getParams();
    var eventFields = event.getParam("fields");
    //eventFields["Field__c"] = "Test Value";
    console.log("Los campos son: " + eventFields);
    component.find("myform").submit(eventFields);
  },

  onsuccess: function (component, event, helper) {
    var titleLabel = $A.get("$Label.c.XC_Success");
    var messageLabel = $A.get("$Label.c.XC_Updated_Successfully");
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: titleLabel,
      message: messageLabel,
      type: "success"
    });
    toastEvent.fire();
  },

  onerror: function (component, event, helper) {
    var errors = JSON.stringify(event.getParam("output").fieldErrors);//.errors;//event.getParam("message");
    var errorsParsed = errors.split(',');
    var errorMessages;
    var errorMessagesAux;
    var errorMessage = '';
    for(var i = 0; i<errorsParsed.length; i++){
      if(errorsParsed[i].includes("message")){
        errorMessages = errorsParsed[i].split('"message":"');
      }
    }

    if(errorMessages.length>0){
      errorMessagesAux = errorMessages[1].split('"');
      errorMessage = errorMessagesAux[0];
    }

    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "¡Error!",
      message: errorMessage,
      type: "error"
    });
    toastEvent.fire();
  }
});