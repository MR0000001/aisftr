/**
 * Created by dolombardi on 06/12/2019.
 */
({


              handleShowNotice : function(component,oVariant,oHeader,oMessage) {
                 component.find('notifLib').showNotice({
                     "variant": oVariant,
                     "header": oHeader,
                     "message": oMessage,
                     closeCallback: function() {

                       window.setTimeout(function(){ $A.get("e.force:closeQuickAction").fire(); }, 0);
                      /* window.setTimeout(function(){ $A.get("e.force:refreshView").fire(); }, 0);*/

                         setTimeout(function(){ location.reload(); }, 2000);
                         //return;
                     }
                 });
             },
              showToastError : function(component,oMessage,oHeader) {
                                  $A.get("e.force:closeQuickAction").fire();
                                  component.find('notifLib').showToast({
                                      "variant": "error",
                                      "title": oHeader,
                                      "message": oMessage
                                  });
                              },


              showToastSuccess : function(component,oMessage,oHeader) {
                                                $A.get("e.force:closeQuickAction").fire();
                                                component.find('notifLib').showToast({
                                                    "variant": "success",
                                                    "title": oHeader,
                                                    "message": oMessage
                                                });
                                                 //setTimeout(function(){ location.reload(); }, 1000);
                                            },








})