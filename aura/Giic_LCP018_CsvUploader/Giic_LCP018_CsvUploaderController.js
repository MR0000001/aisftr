({
    doInit : function(component, event, helper) {
        var url = $A.get('$Resource.giic_DragEdrop');
        component.set('v.backgroundImageURL', url);

        
    },
    
	onDragOver : function(component, event, helper) {
		event.preventDefault();
	},
    
    onDrop : function(component, event, helper) {
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect='copy';
        var files=event.dataTransfer.files;
        helper.readFile(component,helper,files[0]);
        
	},
    
    processFileContent : function(component,event,helper){
       // helper.shootRecords(component,event,helper);
    },
    
    checkIfIsReady : function(component,event,helper){
        if(event.getParam("value")){
        	helper.shootRecords(component,event,helper);
        }
    },
    
    cancel : function(component,event,helper){
        component.set("v.showMain",true);
    }
})