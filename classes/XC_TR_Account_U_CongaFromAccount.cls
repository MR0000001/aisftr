/**
* @author Daniele Lico
* @date Creation 11/06/2020
* @date Modification -
* @description XC_TR_Contract_U_CongaFromAccount 
*/

public without sharing class XC_TR_Account_U_CongaFromAccount {

    public static void populateAccountField(List<Account> listNew, Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        List<NE__Order__c> listAccountChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_NDADocumentNeeded__C'}, mapOldS, mapNewS);
            if(!listAccountChanged.isEmpty()){
                congaTemplateIdForAccount(listNew);
                }
       }    
        /**
         * @author Daniele Lico - dlico@deloitte.it 
         * @date Creation 11/06/2020
         * @description Method to insert Id Conga Templete
         * @param listContract List Account Instance of the Trigger handler
        */
    
        public static void congaTemplateIdForAccount (List<Account> listAccount){
    
           
    
            
            Set<String> sohoType = new Set<String>();
            Set<String> country = new Set<String>();
            Set<String> legalentity = new Set<String>();
            Set<Id> idAccount = new Set<Id> ();
            Map<Id,Account> accountMap = new Map<Id,Account> ([select Id, XC_Country__c, XC_Segment__c 
                                                 from Account where id in: listAccount]);
                                                 
                                                 
                                                 
                                                 
                                                 
            for(Account a1: accountMap.values()){
               
                sohoType.add(a1.XC_Segment__c);           
                country.add(a1.XC_Country__c);          
                idAccount.add(a1.id);
                   
            }
    
           
    
            List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
            if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
                ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_IsNDA__c,XC_CongaQuery__c
                        from XC_CongaTemplateMapping__c 
                        where XC_AccountType__c in: sohoType and XC_Country__c in: country 
                          and XC_IsNDA__c= true];
                        System.debug('DL@@@ in cmt' + ctM );
            }
    
            
            String templateId;
            String congaTemplateId;
            for(Account a1:listAccount){
                for(XC_CongaTemplateMapping__c ctM1: ctM){
                   
                            congaTemplateId = ctM1.XC_CongaQuery__c;
                            templateId = ctM1.XC_CongaIdTemplate__c;
                      
                            String concatenatedOrder=String.valueOf(idAccount);
                            concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                            
                            String staticApi = a1.XC_CongaStaticAPI__c;
                            String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                                + '&OFN=Account - NDA TO SIGN'
                                + '&DefaultPDF=0&qmode=SalesforceFile';
                            a1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                            
                    
                        break;
                        
                                 
            }
        }
    
        
            XC_UTIL_Sobject.updateListRecords(listAccount);  
                    
          
        }
    
    
    }