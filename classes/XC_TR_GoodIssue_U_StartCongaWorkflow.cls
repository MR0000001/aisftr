/**
* @author Patrizia.Arcidiacono@nttdata.com
* @date Creation 21/11/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_GoodIssue_U_StartCongaWorkflow  - Class that recover the info material and related records and pass the info to the Conga call
*                                                             that start with a workflow  
*/ 
public class XC_TR_GoodIssue_U_StartCongaWorkflow {
/**
* @author Patrizia.Arcidiacono@nttdata.com
* @date Creation 21/11/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_GoodIssue_U_StartCongaWorkflow  - Class that recover the info from material and related records and pass the info to the Conga call
*                                                             that start with a workflow  
*/ 
     public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_GoodIssue_U_StartCongaWorkflow');
    /** 
    * @description populate Conga Field
    * @param goodIssueId string 
    */
    @AuraEnabled 
    public static string populateFieldDDT(string goodIssueId) {
      string esito='OK';
      try{	
        list<gii__Shipment__c> ListNew = new List<gii__Shipment__c>([Select Id, XC_CongaDynamicAPI__c,XC_CongaStaticAPI__c  from gii__Shipment__c where id=: goodIssueId]);
        Map<String, APXTConga4__Conga_Template__c> templateMap = getTemplateMap();
        Map<String, APXTConga4__Conga_Merge_Query__c> congaMergeQueryMap = getCongaMergeQuery();
        system.debug('@@@@ templateMap:' + templateMap);
        system.debug('@@@@ congaMergeQueryMap :' + congaMergeQueryMap );
        for(gii__Shipment__c goodIssue : ListNew){
            callCongaforGoodIssue(goodIssue, templateMap, congaMergeQueryMap); 
            system.debug('@@@@ exit callCongaForGoodIssue :');
        }  
       }catch(Exception e){
           esito ='KO';
           system.debug('@@@@ exit callCongaForGoodIssue KO:' + e);
       }    
        return esito;
     }
    
     /**
    * @description call Conga For Good issue Maintenance
    * @author patrizia.arcidiacono@nttdata.com | 21/11/2019
    * @param goodIssue gii__Shipment__c
    * @param templateMap Map<String, APXTConga4__Conga_Template__c> 
    * @param congaMergeQueryMap Map<String, APXTConga4__Conga_Merge_Query__c>
    */
    private static void callCongaForGoodIssue(gii__Shipment__c goodIssue,  Map<String, APXTConga4__Conga_Template__c> templateMap, Map<String, APXTConga4__Conga_Merge_Query__c> congaMergeQueryMap){
       String queryId='';
       String congaQuery =''; 
        for(String congaQueryName : templateMap.keySet()){
            queryId = templateMap.get(congaQueryName).Id;
          
        }    
        congaQuery =  congaQuery + '[queryOnGoodIssue]'+ queryId;
        system.debug('@@@@ congaQuery:' + congaQuery);  
        setDynamicApi(goodIssue, congaQuery, queryId);
        system.debug('@@@@ exit :' + congaQuery);  
    }
    
    
    /**
    * @description call Conga For Good issue Maintenance
    * @author patrizia.arcidiacono@nttdata.com | 21/11/2019
    * @return Map<String, APXTConga4__Conga_Merge_Query__c>
    */
     private static Map<String, APXTConga4__Conga_Template__c> getTemplateMap(){
        Map<String, APXTConga4__Conga_Template__c> templateMap = new Map<String, APXTConga4__Conga_Template__c>();
        List<APXTConga4__Conga_Template__c> templatesList = new List<APXTConga4__Conga_Template__c>([SELECT Id, Name, APXTConga4__Name__c, APXTConga4__Template_Group__c 
                                                                                                FROM APXTConga4__Conga_Template__c 
                                                                                                WHERE Country__c = 'Colombia']); 
        for (APXTConga4__Conga_Template__c tem : templatesList) {
            templateMap.put(tem.APXTConga4__Name__c, tem);
        }
        system.debug('@@@@ getTemplateMap :' + templateMap);
        return templateMap;
      }    
    
      /**
    * @description call Conga For Good issue Maintenance
    * @author patrizia.arcidiacono@nttdata.com | 21/11/2019
    * @return Map<String, APXTConga4__Conga_Merge_Query__c>
    */
     private static Map<String, APXTConga4__Conga_Merge_Query__c> getCongaMergeQuery(){
        Map<String, APXTConga4__Conga_Merge_Query__c> congaMergeQueryMap = new Map<String, APXTConga4__Conga_Merge_Query__c>();
        List<APXTConga4__Conga_Merge_Query__c> congaMergeQueryList = new List<APXTConga4__Conga_Merge_Query__c>([SELECT Id, APXTConga4__Name__c, APXTConga4__Query__c 
                                                                                                            FROM APXTConga4__Conga_Merge_Query__c 
                                                                                                            WHERE APXTConga4__Name__c = 'queryOnGoodIssue']); 
        for (APXTConga4__Conga_Merge_Query__c tem : congaMergeQueryList) {
            congaMergeQueryMap.put(tem.APXTConga4__Name__c, tem);
        }
         system.debug('@@@@ getCongaMergeQuery:' + congaMergeQueryMap);
        return congaMergeQueryMap;
    } 
    
     /**
    * @description call Conga For Good issue Maintenance
    * @author patrizia.arcidiacono@nttdata.com | 21/11/2019
    * @param goodIssue gii__Shipment__c
    * @param congaQuery string 
    * @param congaTemplateId string
    */
    private static void setDynamicApi(gii__Shipment__c goodIssue, String congaQuery, String congaTemplateId){
       try{ 
        if(!String.isBlank(congaTemplateId) || !String.isBlank(congaQuery) ){
            String dynamicApi = '&Id=' + goodIssue.Id + '&QueryId=' +  congaQuery + '&TemplateId=' +  congaTemplateId
                        + '&OFN= gii__Shipment__c - SERVICE_REPORT' +
                        + '&DefaultPDF=1&qmode=SalesforceFile';
           system.debug('@@@@ setDynamicApi: ' + dynamicApi);
           goodIssue.XC_CongaDynamicAPI__c = goodIssue.XC_CongaDynamicAPI__c + dynamicApi;
           system.debug('@@@@ goodIssue.XC_CongaDynamicAPI__c' + goodIssue.XC_CongaDynamicAPI__c);	           
        }
      }catch(Exception e) {
          system.debug('@@@@ setDynamicApi error: ' + e);
      }    
    }

}