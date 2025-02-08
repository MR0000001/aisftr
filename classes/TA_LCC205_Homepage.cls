public without sharing class TA_LCC205_Homepage {
    
    @AuraEnabled
    public static String getListView(String objName, String listViewName){
        System.debug('>_> Inside TA_LCC205_Homepage.getListView');
        String listViewId = '';
 
        List<ListView> listViews = [
                SELECT Id, Name, DeveloperName 
                FROM ListView 
                WHERE SobjectType = :objName
                AND Name = :listViewName];

        system.debug('>_> query result : ' + listViews);

        if( !listViews.isEmpty() ) listViewId = listViews[0].Id;

        return listViewId;
    }
}