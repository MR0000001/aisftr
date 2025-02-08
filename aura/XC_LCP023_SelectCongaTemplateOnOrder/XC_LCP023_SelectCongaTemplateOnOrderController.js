({
    init : function(component,event,helper) {
        helper.doInit(component,event);
        //helper.doInitItem(component,event);
    },
    
    clickDownload: function(component,event,helper){
        helper.clickDownloadHelper(component,event);
    },

    clickDownloadItem: function(component,event,helper){
        //helper.clickDownloadItemHelper(component,event);
    }  
})