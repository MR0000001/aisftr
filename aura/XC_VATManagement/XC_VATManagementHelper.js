({
  getOIs: function (component, event, helper) {
    var orderId = component.get("v.recordId");
    /*var action = component.get("c.getOIsWrapper");

    action.setParams({
      orderId: orderId
    });

    action.setCallback(
      this,
      $A.getCallback(function (response) {
        debugger;
        var state = response.getState();
        if (state === "SUCCESS") {
          var resultado = response.getReturnValue();
          console.log(resultado);

          var lista = [];

          var ois = [];
          for (var key in resultado) {
            ois.push({ value: resultado[key], key: key }); //Here we are creating the list to show on UI.
          }

          var mapaAux = ois[0].value;

          for(var clave in mapaAux){
            lista.push({value: mapaAux[clave], key: clave });
          }

          //component.set("v.ois", ois[0]);
          //component.set("v.ois", lista[0].value);
          //component.set("v.ois", lista);
          component.set("v.ois", ois);
          component.set("v.mapaOIs", resultado);

          var prueba = component.get("v.ois");
          debugger;

        } else if (state === "ERROR") {
          var errors = response.getError();
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "¡Error!",
            message: errors,
            type: "error"
          });
          toastEvent.fire();
          console.error(errors);
        }
      })
    );
    $A.enqueueAction(action);*/

    var action = component.get("c.getOIsWrapper2");

    action.setParams({
      orderId: orderId
    });

    action.setCallback(
        this,
        $A.getCallback(function (response) {
          //debugger;
          var state = response.getState();
          if (state === "SUCCESS") {
            var resultado = response.getReturnValue();
            console.log(resultado);
            
            component.set("v.wrappers", resultado);

            //Damos forma a la tabla
            var actions = [
              { label: "Show details", name: "show_details" },
              { label: "Delete", name: "delete" }
            ];

            component.set("v.columns", [
              { label: "Número", fieldName: "Name", type: "text" },
              { label: "Nombre", fieldName: "NE__ProdName__c", type: "text" },
              //{ type: "action", typeAttributes: { rowActions: actions } }
              /*{
                label: "",
                name: "configuracionServicioHUB",
                type: "button",
                typeAttributes: {
                  label: { fieldName: "configuracionServicioHUB" },
                  name: "show_Configuracion"
                }
              }*/
              { label: "Tipo impuesto", fieldName: "XC_Tax_Type__c", type: "text", editable: true }
            ]);
          } else if (state === "ERROR") {
            var errors = response.getError();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "¡Error!",
              message: errors,
              type: "error"
            });
            toastEvent.fire();
            console.error(errors);
          }
        })
      );
      $A.enqueueAction(action);
  },

  wrapperMethod : function (component, event, helper){
    var action = component.get("c.wrapperMethod");
    var orderId = component.get("v.recordId");

    component.set('v.showSpinner', true);

    action.setParams({
      orderId: orderId
    });

    action.setCallback(
      this,
      $A.getCallback(function (response) {
        //debugger;
        var state = response.getState();
        component.set('v.showSpinner', false);
        if (state === "SUCCESS") {
          var resultado = response.getReturnValue();
          console.log(resultado);
          console.log(resultado.wrappers);
          console.log(resultado.tiposImpuestos);
          
          component.set("v.wrappers", resultado.wrappers);
          component.set("v.tiposImpuestos", resultado.tiposImpuestos);
          var tiposImpuestos = component.get("v.tiposImpuestos");
          var draft = [];
          var listaMapa = [];
          for (var key in tiposImpuestos) {
            draft.push({ value: tiposImpuestos[key], key: key });
          }

          //debugger;
          //Intentar sustituir key (Id del OI padre) por orden numérico en pantalla. Es decir, primer OI padre será listaMapa[0], segundo el listaMapa[1], etc
          //MIRAR POR QUÉ VIENE SOLO UN IMPUESTO SI DEBERÍAN SER DOS PARENT OIs
          for(var i = 0; i<resultado.wrappers.length; i++){
            var encontrado = false;

            for(var j = 0; j<draft.length && !encontrado; j++){
              if(resultado.wrappers[i].padre.XC_BillingProfileLineItem__c != null && resultado.wrappers[i].padre.XC_BillingProfileLineItem__c == draft[j].key){
                listaMapa.push(draft[j].value);
                resultado.wrappers[i].impuesto = draft[j].value;
                encontrado = true;
              }
            }
            
          }


          component.set('v.listaMapa', listaMapa);
          //debugger;
        } else if (state === "ERROR") {
          var errors = response.getError();
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "¡Error!",
            message: errors,
            type: "error"
          });
          toastEvent.fire();
          console.error(errors);
        }
      })
    );
    $A.enqueueAction(action);
  },

  saveTaxes : function (component, event, helper){
    var action = component.get("c.saveTaxes");
    
    var wrappers = component.get('v.wrappers');

    var oisNamesWrapper = [];

    for(var i = 0; i < wrappers.length; i++){
      oisNamesWrapper.push(wrappers[i].padre.Name);
      var hijos = wrappers[i].hijos;
      for (var j = 0; j < hijos.length; j++){
        oisNamesWrapper.push(hijos[j].Name);
      }
    }

    action.setParams({
      oisNames: oisNamesWrapper
    });

    action.setCallback(
        this,
        $A.getCallback(function (response) {
          debugger;
          var state = response.getState();
          if (state === "SUCCESS") {
            
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                title: "Success!",
                message: "Save taxes completed",
                type: "success"
              });
              toastEvent.fire();

              var dismissActionPanel = $A.get("e.force:closeQuickAction");
              dismissActionPanel.fire();
          } else if (state === "ERROR") {
            var errors = response.getError();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Error!",
              message: errors,
              type: "error"
            });
            toastEvent.fire();
            console.error(errors);
          }
        })
      );
      $A.enqueueAction(action);
  }
});