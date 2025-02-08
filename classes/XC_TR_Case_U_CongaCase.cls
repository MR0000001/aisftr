/**
* @author Daniele Lico
* @date Creation 23/12/2020
* @date Modification -
* @description XC_TR_Case_U_CongaCase
*/	


public without sharing class XC_TR_Case_U_CongaCase {

    /*public static void populateCaseField(List<Case> listNew, Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        List<Case> listContractChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Generate_Case_Document__c'}, mapOldS, mapNewS);
            if(!listContractChanged.isEmpty()){
                congaTemplateIdForCase(listNew);
                }
       }*/
       public static void checkDocumentType(List<Case> listCase){ 
        List<Case> listSuspended = new List<Case>();
        List<Case> listReactivated = new List<Case>();
        List<Case> listExtended = new List<Case>();
        for(Case ca: listCase){
            if ( ca.SubCause__c== 'ATCL115' && ca.XC_Generate_Case_Document__c==true ) {
                listSuspended.add(ca);
            }
            if ( ca.SubCause__c== 'ATCL116' && ca.XC_Generate_Case_Document__c==true ) {
                listReactivated.add(ca);
            }
            if ( ca.SubCause__c== 'ATCL117' && ca.XC_Generate_Case_Document__c==true) {
                listExtended.add(ca);
            }

        }
        if(!listSuspended.isEmpty()){
            congaTemplateIdForCase(listSuspended);
        }
         if(!listReactivated.isEmpty()){
            congaTemplateIdForCaseReactvated(listReactivated);
        }
        if(!listExtended.isEmpty()){
            congaTemplateIdForCaseExtended(listExtended);
        }
    }

    public static void congaTemplateIdForCase (List<Case> listCase){

        Set<String> sohoType = new Set<String>();
        Set<String> country = new Set<String>();
        Set<String> legalEntity = new Set<String>();
        Set<Id> idCase = new Set<Id> ();
        
        Map<Id,Case> caseMap = new Map<Id,Case> ([SELECT Id,XC_Segment__c, XC_LegalEntity__c,Country__c
                                                                                FROM Case WHERE id in: listCase]);
                                                                                
                                                                                
        for(Case c1: caseMap.values()){
           
            legalEntity.add(c1.XC_LegalEntity__c);
            sohoType.add(c1.XC_Segment__c);           
            country.add(c1.Country__c);          
            idCase.add(c1.id);
            //system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
               
        }
        
        List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
        
        if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
            ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                    from XC_CongaTemplateMapping__c 
                    where XC_AccountType__c in: sohoType and XC_Country__c in: country 
                      and XC_IsCase__c = true and XC_CaseTypeDocument__c='LCL Suspended'];
                    //System.debug('LCL@@@ in cmt' + ctM );
        }
        
        
        String templateId;
        String congaTemplateId;
        
        for(Case c1:listCase){
            for(XC_CongaTemplateMapping__c ctM1: ctM){
                
                congaTemplateId = ctM1.XC_CongaQuery__c;
                templateId = ctM1.XC_CongaIdTemplate__c;
                  
                String concatenatedOrder=String.valueOf(idCase);
                concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                        
                String staticApi = c1.XC_CongaStaticAPI__c;
                String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                            +  '&OFN=Case - LCL_MANAGEMENT'
                            + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
                c1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                
                break;
            }
        }
    //XC_UTIL_Sobject.updateListRecords(listCase);  
}



public static void congaTemplateIdForCaseReactvated (List<Case> listCase){

    Set<String> sohoType = new Set<String>();
    Set<String> country = new Set<String>();
    Set<String> legalEntity = new Set<String>();
    Set<Id> idCase = new Set<Id> ();
    
    Map<Id,Case> caseMap = new Map<Id,Case> ([SELECT Id,XC_Segment__c, XC_LegalEntity__c,Country__c
                                                                            FROM Case WHERE id in: listCase]);
                                                                            
                                                                            
    for(Case c1: caseMap.values()){
       
        legalEntity.add(c1.XC_LegalEntity__c);
        sohoType.add(c1.XC_Segment__c);           
        country.add(c1.Country__c);          
        idCase.add(c1.id);
        //system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
           
    }
    
    List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
    
    if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
        ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                from XC_CongaTemplateMapping__c 
                where XC_AccountType__c in: sohoType and XC_Country__c in: country 
                  and XC_IsCase__c = true and XC_CaseTypeDocument__c='LCL Reactivated' ];
                //System.debug('LCL@@@ in cmt' + ctM );
    }
    
    
    String templateId;
    String congaTemplateId;
    
    for(Case c1:listCase){
        for(XC_CongaTemplateMapping__c ctM1: ctM){
            
            congaTemplateId = ctM1.XC_CongaQuery__c;
            templateId = ctM1.XC_CongaIdTemplate__c;
              
            String concatenatedOrder=String.valueOf(idCase);
            concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                    
            String staticApi = c1.XC_CongaStaticAPI__c;
            String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                        +  '&OFN=Case - LCL_MANAGEMENT'
                        + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
            c1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
            
            break;
        }
    }
//XC_UTIL_Sobject.updateListRecords(listCase);  
}


public static void congaTemplateIdForCaseExtended(List<Case> listCase){

    Set<String> sohoType = new Set<String>();
    Set<String> country = new Set<String>();
    Set<String> legalEntity = new Set<String>();
    Set<Id> idCase = new Set<Id> ();
    
    Map<Id,Case> caseMap = new Map<Id,Case> ([SELECT Id,XC_Segment__c, XC_LegalEntity__c,Country__c
                                                                            FROM Case WHERE id in: listCase]);
                                                                            
                                                                            
    for(Case c1: caseMap.values()){
       
        legalEntity.add(c1.XC_LegalEntity__c);
        sohoType.add(c1.XC_Segment__c);           
        country.add(c1.Country__c);          
        idCase.add(c1.id);
        //system.debug('sohotypeRaf '+ sohoType +'countryRAF' + country);
           
    }
    
    List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
    
    if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
        ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                from XC_CongaTemplateMapping__c 
                where XC_AccountType__c in: sohoType and XC_Country__c in: country 
                  and XC_IsCase__c = true and XC_CaseTypeDocument__c='LCL Extended' ];
                //System.debug('LCL@@@ in cmt' + ctM );
    }
    
    
    String templateId;
    String congaTemplateId;
    
    for(Case c1:listCase){
        for(XC_CongaTemplateMapping__c ctM1: ctM){
            
            congaTemplateId = ctM1.XC_CongaQuery__c;
            templateId = ctM1.XC_CongaIdTemplate__c;
              
            String concatenatedOrder=String.valueOf(idCase);
            concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                    
            String staticApi = c1.XC_CongaStaticAPI__c;
            String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                        +  '&OFN=Case - LCL_MANAGEMENT'
                        + '&DefaultPDF=0&qmode=SalesforceFile&WordStripIfs=1';
            c1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
            
            break;
        }
    }
//XC_UTIL_Sobject.updateListRecords(listCase);  
}
}