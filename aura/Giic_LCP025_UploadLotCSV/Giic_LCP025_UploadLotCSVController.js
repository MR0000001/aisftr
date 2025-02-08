({
	closeModale : function(component, event, helper) {
      component.set("v.showModal",false);   
      $A.get("e.force:closeQuickAction").fire();
    },
    
     doInit : function(component,event, helper) { 
     
            
    },
    
    closeTable : function(component,event, helper) {
        console.log('RICEVUTO');
      var b = event.getParam("booleano");
      component.set("v.showModal", b);
        
    },
    
    
    incrementProgress : function(component,event, helper) {
        
        component.set("v.progress", component.get("v.progress")+1);
    },
    
     gotoURL : function (component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    var profUrl = $A.get('$Resource.giic_LotLoad')
    urlEvent.setParams({
      "url": profUrl
    });
    urlEvent.fire();
	},
    
    
    
    handleUploadFinished : function(component, event, helper) {
        //component.set("v.showSpinner" , true);
        var fileInput = component.find("file"); //.getElement();
        var files = event.getSource().get("v.files");
        var file = files[0];        //fileInput.files[0];
        if(file) {
            console.log("UPLOADED")
            var reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = function(evt) {
                var csv = evt.target.result;
                component.set("v.csvString", csv);
                component.set("v.showModal", false);
                helper.createCSVObject(component, event, helper);
            }
        }
    }
    
     
    
     
    
    
})