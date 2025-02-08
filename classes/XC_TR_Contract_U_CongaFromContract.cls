/**
* @author Daniele Lico
* @date Creation 02/06/2020
* @date Modification -
* @description XC_TR_Contract_U_CongaFromContract 
*/

public without sharing class XC_TR_Contract_U_CongaFromContract {

    public static void populateContractField(List<Contract> listNew, Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        List<NE__Order__c> listContractChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Generate_Contract_Document__c'}, mapOldS, mapNewS);
            if(!listContractChanged.isEmpty()){
                congaTemplateIdForContract(listNew);
                }
       }    
        /**
         * @author Daniele Lico - dlico@deloitte.it 
         * @date Creation 02/06/2020
         * @description Method to insert Id Conga Templete
         * @param listContract List Contract Instance of the Trigger handler
        */
    
        public static void congaTemplateIdForContract (List<Contract> listContract){
    
            
            /*Map<Id,NE__Order__c> c = new Map<Id,NE__Order__c> ([Select id,XC_LegalEntity__c,NE__AccountId__r.XC_SohoType__c,
                                                                NE__AccountId__r.XC_Country__c,NE__rTypeName__c 
                                                                    from NE__Order__c where id IN: listOrder]);*/   
            //delete this query
    
            
            Set<String> sohoType = new Set<String>();
            Set<String> country = new Set<String>();
            Set<String> legalentity = new Set<String>();
            Set<Id> idContract = new Set<Id> ();
            Set<Id> idOrder = new Set<Id> ();
            Map<Id,Contract> contractMap = new Map<Id,Contract> ([select Id, Account.XC_Country__c, Account.XC_Segment__c,XC_Configurations__c,XC_LegalEntity__c  
                                                 from Contract where id in: listContract]);
                                                 
                                                 
                                                 
                                                 
                                                 
            for(Contract c1: contractMap.values()){
               
                sohoType.add(c1.Account.XC_Segment__c);           
                country.add(c1.Account.XC_Country__c);          
                idContract.add(c1.id);  
                idOrder.add(c1.XC_Configurations__c);
                legalentity.add(c1.XC_LegalEntity__c); 
                   
            }
    
            /*for(Contract c1: listContract){
                legalentity.add(c1.XC_LegalEntity__c);  
                System.debug('DL@@@ in o1.XC_LegalEntity__c' + c1.XC_LegalEntity__c );  
            }*/
    
            List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
            if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
                ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_CommercialProduct__c,XC_Bundle__c,
                        XC_LegalEntity__c,XC_CongaQuery__c
                        from XC_CongaTemplateMapping__c 
                        where XC_LegalEntity__c in: legalentity and XC_AccountType__c in: sohoType and XC_Country__c in: country 
                          and XC_IsContract__c= true];
                        System.debug('DL@@@ in cmt' + ctM );
            }
    
            List<NE__OrderItem__c> oi = new List<NE__OrderItem__c>();
            if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){ 
                oi =   [select id, NE__ProdId__c,NE__OrderId__c,XC_CongaStaticAPI__c from NE__OrderItem__c where 
                            (NE__OrderId__r.NE__Type__c  ='InOrder' and NE__OrderId__c in :idOrder)
                            or (NE__Action__c ='Add' and NE__OrderId__r.NE__Type__c ='ChangeOrder' 
                            and NE__OrderId__r.NE__OrderStatus__c='Pending' and NE__OrderId__c in :idOrder)];
                            System.debug('DL@@@ in oi' + oi );                  
    
            }
            String orderId;
            String templateId;
            String congaTemplateId;
            String concId = '';
            for(Contract c1:listContract){
                for(XC_CongaTemplateMapping__c ctM1: ctM){
                    for(NE__OrderItem__c oi1: oi){
                        
                        if(ctM1.XC_CommercialProduct__c == oi1.NE__ProdId__c){
                            //concId += ctM1.XC_CongaIdTemplate__c + ',';   
                            congaTemplateId = ctM1.XC_CongaQuery__c;
                            templateId = ctM1.XC_CongaIdTemplate__c;
                            //orderId = oi1.NE__OrderId__c;
                            String concatenatedOrder=String.valueOf(idContract);
                            concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                            
                            String staticApi = c1.XC_CongaStaticAPI__c;
                            String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                                + '&OFN=Contract - CONTRACT_TO_SIGN'
                                + '&DefaultPDF=0&qmode=SalesforceFile' + '&APDF= 1';
                            c1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                            break;
                            
                        }
                    }               
            }
        }
    
        //if(!oi.isEmpty() && !String.isBlank(templateId)){
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 updated records --->' + oi);
            XC_UTIL_Sobject.updateListRecords(listContract);  
                    
            //} 
        }
    
    
    }