({
    handleClick : function (cmp, event, helper) {
  		console.log("You clicked: " + event.getSource().get("v.label"));
        helper.handleClickHelper(cmp, event, helper);
        console.log("You clicked: " + event.getSource().get("v.label"));
    }
})