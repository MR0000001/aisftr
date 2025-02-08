({	
    
    doInit : function(component, event, helper) {
		helper.init(component, event);
	},
	
	handleEditClick : function(component, event, helper) {
		helper.handleEditClick(component, event);
	},

	handleCancelClick : function(component, event, helper) {
         console.log('entrato in handleCancelClick');
         
		 helper.navigatePage(component, event);
	},
    handleSave : function(component, event, helper) {
        helper.handleSave(component, event);
	},

	handleSuccess : function(component, event, helper) {
		
		helper.handleEditClick(component, event);
	},

	onSubmit :  function(component, event, helper) {
		helper.onSubmitHelper(component, event);
	},
  
    onValidate :  function(component, event, helper) {
        console.log('onvalidate');
		helper.onValidate(component, event);
	},

	setReadOnlyForInput : function (component,event,helper){
		helper.setReadOnlyForInput(component, event);
	},
    saveNoValid :  function (component,event,helper){
    	 
         component.set("v.validationOK",true);   
	}
    

	
})