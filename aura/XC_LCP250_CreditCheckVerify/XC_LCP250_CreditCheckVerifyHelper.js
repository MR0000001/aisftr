/**
 * Created by dolombardi on 06/12/2019.
 */
({



              showToastError : function(component,oMessage,oHeader) {
                                  
                                  component.find('notifLib').showToast({
                                      "variant": "error",
                                      "title": oHeader,
                                      "message": oMessage
                                  });
                 $A.get("e.force:closeQuickAction").fire();

                 },


              showToastSuccess : function(component,oMessage,oHeader) {

                                                component.find('notifLib').showToast({
                                                    "variant": "success",
                                                    "title": oHeader,
                                                    "message": oMessage
                                                });
                 $A.get("e.force:closeQuickAction").fire();
                                                 //setTimeout(function(){ location.reload(); }, 1000);
                                            },








})