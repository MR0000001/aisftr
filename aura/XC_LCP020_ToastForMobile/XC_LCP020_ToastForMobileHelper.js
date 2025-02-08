({
	waitAndCloseModel : function(component, event) {
        setTimeout(function(){
         component.destroy();
             }, 2300); 
    },
    
    closeModel : function(component, event) {
         component.destroy();
    }
})