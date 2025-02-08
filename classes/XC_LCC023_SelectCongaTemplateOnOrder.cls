/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 04/10/2018
* @date Modification dd/mm/yyyy
* @description XC_LCC023_SelectCongaTemplateOnOrder – Controller for XC_LCP023_SelectCongaTemplateOnOrder Component 
*/

public without sharing class XC_LCC023_SelectCongaTemplateOnOrder {
    
    /**
     * The Class ListWrapper.
     * @description List Wrapper
     */
    public class ListWrapper{
        
        /** The lista id. 
        * @description listaId
        */
        @AuraEnabled public List<String> listaId  {get;set;}
        
        /** The lista name. 
        * @description listaName
        */
        @AuraEnabled public Set<String> listaName  {get;set;}
    } 

    private class UrlWrapper{
        String idOrder = '';
        String templateId = '';
        String orName = '';
        String myDate = '';
    }

    /**
     * Gets the pick list values into list.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param idOrder the id order
     * @return the pick list values into list
     * @description Method to pass to the component XC_LCC023_SelectCongaTemplateOnOrder the values of the Conga template picklist
     */
    @AuraEnabled        
    public static ListWrapper getPickListValuesIntoList(String idOrder){
        String statusOrder = 'Undefined';
        ListWrapper lwr = new ListWrapper();
        Set<String> listCatalogName = new Set<String>{'All'};
        List<NE__Order__c >listOrder = new List<NE__Order__c>(); 
        List<NE__OrderItem__c> listOrderItem = new List<NE__OrderItem__c>();
        List<Id> listOrderItemId = new List<Id>();
        List<String> pickListValuesList = new List<String>();       
        List<String> picklistValueId = new List<String>();  
       
        List<APXTConga4__Conga_Template__c> listaTemplate= new list<APXTConga4__Conga_Template__c>();
        
        if(!Schema.SObjectType.NE__Order__c.isAccessible()) {
            return new ListWrapper();
        }
        Map<Id,NE__Order__c> listOrderMap = new Map<Id,NE__Order__c>([SELECT Id, XC_Status__c from NE__Order__c WHERE Id =: idOrder]);
        listOrder = listOrderMap.values();
         if(!Schema.SObjectType.NE__OrderItem__c.isAccessible()) {
                    return new ListWrapper();}
        Map<Id,NE__OrderItem__c> listOrderItemMap = new Map<Id,NE__OrderItem__c>([SELECT Id,Name, NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name 
        FROM NE__OrderItem__c WHERE NE__OrderId__c =: idOrder]);

        listOrderItem = listOrderItemMap.values();

        for(NE__OrderItem__c oit : listOrderItem){
            listCatalogName.add(oit.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name);
        }

        lwr.listaId = picklistValueId;
        lwr.listaName = listCatalogName;
        return lwr;
    } 

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description Method to find the correct Conga Template from the value selected in the pop-up picklist 
                    and to create the Conga url passed to the component 
     * @param templateName  
     * @param idOrder 
     * @return String           
    **/
    @AuraEnabled        
    public static String getIdValueAndSetUrl(String templateName, String idOrder){   
        Set<String> listCatalogName = new Set<String>();
        List<Id> listeTemplateId = new List<String>(); 
        Map<Id,NE__Order__c> orderNameMap = new Map<Id,NE__Order__c>([SELECT Id, Name, (select Id from NE__Order_Items__r) 
                                        from NE__Order__c where Id =: idOrder]);
        List<NE__Order__c> orderName = orderNameMap.values(); 
        
        Map<Id,NE__OrderItem__c> listOrderItemMap = new Map<Id,NE__OrderItem__c>([SELECT Id,Name, NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name 
                                from NE__OrderItem__c where NE__OrderId__c =: idOrder]);
        List<NE__OrderItem__c> listOrderItem = listOrderItemMap.values();
        if(templateName == 'All'){
            for(NE__OrderItem__c oit : listOrderItem){
                listCatalogName.add(oit.NE__CatalogItem__r.NE__Catalog_Category_Name__r.Name);
            }
        }
        else{
            listCatalogName.add(templateName);
        }
        if(!Schema.SObjectType.APXTConga4__Conga_Template__c.isAccessible()) {
            return 'NO ACCESS';
        }
        Map<Id,APXTConga4__Conga_Template__c> listaTemplateMap = new Map<Id,APXTConga4__Conga_Template__c>([SELECT Id, Name, APXTConga4__Name__c 
        from APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c IN: listCatalogName]);  
        List<APXTConga4__Conga_Template__c> listaTemplate = listaTemplateMap.values();
        for(APXTConga4__Conga_Template__c congatemp : listaTemplate){
            listeTemplateId.add(congatemp.Id);
        }
        String orName = '';
        Datetime myDT = Datetime.now();
        String myDate = myDT.format('dd/MM/YYYY HH:mm');
        if(!orderName.isEmpty()){
            orName = orderName[0].Name;
        }
        if(!listeTemplateId.isEmpty()){
            UrlWrapper wr = new UrlWrapper();
            wr.templateId = string.join(listeTemplateId,','); 
            wr.idOrder = idOrder;
            wr.orName = orName;
            wr.myDate = myDate;
            return createUrl(wr);
        }
        return null;
    }  

    private static String createUrl(UrlWrapper wr){  

        //String listCatalogNameString = string.join(listCatalogName,'-');
        String dm = Url.getSalesforceBaseUrl().toExternalForm();
        // It's necessary to use a List<String> because just a String type doesn't accept a curly brace.
        List<String> subst = new List<String>();
        subst.add(dm);
        subst.add('/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl=;');
        subst.add('{');
        subst.add('!API.Partner_Server_URL_370');
        subst.add('}');
        subst.add('&Id=');
        subst.add(wr.idOrder);
        //WARNING: Get the queries needed for the template population of the pdf file. It's needed to change the Id if the query or the org change.
        subst.add('&QueryId=[queryorderitem]a2p0D0000004Dhk,[xcqueryaccount]a2p0D0000004Dhp,[queryitemLED]a2p0D0000004E0J,[queryitemAIRCONDITIO]a2p0D0000004E0K,[queryitemBOILER]a2p0D0000004E0O&TemplateId=');
        subst.add(wr.templateId);
        subst.add('&OFN=');
        subst.add(wr.orName);
        subst.add('+');
        subst.add(wr.myDate);     
        /* DefaultPDF=1 Set the output format in PDF, SC0=1 Enable Save a Copy,SC1=SalesforceFile save file in files, 
            DS7=11 Background Mode is enabled and the merged document is attached to Salesforce Files for the Master Object,
            APDF=0 Individual PDFs will not be assembled, but rather left as individual PDFs. */
        subst.add('&DefaultPDF=1&SC0=1&SC1=SalesforceFile&DS7=11&APDF=0');
        String finalUrl = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}',subst);
        return finalUrl; 
    }
}