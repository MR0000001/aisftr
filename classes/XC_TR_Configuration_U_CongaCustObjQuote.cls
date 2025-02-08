/**
* @author Daniele Lico
* @date Creation 28/11/2019
* @date Modification -
* @description XC_TR_Configuration_U_CongaWFCustomObj 
*/

public without sharing class XC_TR_Configuration_U_CongaCustObjQuote {

    /**
     * @author Daniele Lico - dlico@deloitte.it 
     * @date Creation 28/11/2019
     * @description Method to insert Id Conga Templete
     * @param listOrder List Order Instance of the Trigger handler
    */

    public static void congaTemplateIdForQuote (List<NE__Order__c> listOrder){
        System.debug('DL@@@ in congaTemplateIdForQuote' + listOrder );
        Set<String> sohoType = new Set<String>();
        Set<String> country = new Set<String>();
        Set<String> legalentity = new Set<String>();
        Set<Id> idOrder = new Set<Id>();
        List<NE__Order__c> orderlist = [SELECT Id,NE__AccountId__r.XC_Country__c,NE__AccountId__r.XC_Segment__c ,XC_LegalEntity__c,XC_Country__c, NE__OptyId__r.XC_RPFVerification__c, NE__OptyId__r.XC_ConsipLot__r.XC_LotNumber__c
                                             from ne__order__c where id in: listOrder];
        Map<Id,NE__Order__c> orderMap = new Map<Id,NE__Order__c>(orderlist);
        for(NE__Order__c o1: orderlist){
            System.debug('giulia +' + o1.Id);
            sohoType.add(o1.NE__AccountId__r.XC_Segment__c);
            System.debug('DL@@@ in o1.NE__AccountId__r.XC_SohoType__c' + o1.NE__AccountId__r.XC_Segment__c );
            country.add(o1.NE__AccountId__r.XC_Country__c);
            System.debug('DL@@@ in o1.NE__AccountId__r.XC_Country__c' + o1.NE__AccountId__r.XC_Country__c );
            idOrder.add(o1.id);
            System.debug('DL@@@ in o1.id' + o1.id );
        }   

        Id commProdId;
        for(NE__Order__c o1: listOrder){
            legalentity.add(o1.XC_LegalEntity__c);  
            System.debug('DL@@@ in o1.XC_LegalEntity__c' + o1.XC_LegalEntity__c );  

            System.debug('DL@@@ in o1.XC_LegalEntity__c' + o1.XC_LegalEntity__c );

        }

        List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
        if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
            ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_CommercialProduct__c,XC_CommercialProduct__r.Name,XC_Bundle__c,
                    XC_LegalEntity__c,XC_CongaQuery__c,XC_RPFVerification__c, XC_LotType__c
                    from XC_CongaTemplateMapping__c 
                    where XC_LegalEntity__c in: legalentity and XC_AccountType__c in: sohoType /*and XC_Country__c in: country */
                  and XC_Bundle__c= true]; 

                    System.debug('DL@@@ in cmt' + ctM );
        }

        List<NE__OrderItem__c> oi = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){ 
            oi =   [select id, NE__ProdId__c,NE__OrderId__c,XC_CongaStaticAPI__c,NE__ProdId__r.name from NE__OrderItem__c where 
                        (NE__OrderId__r.NE__Type__c  ='InOrder' and NE__OrderId__c in :idOrder)];
                        System.debug('DL@@@ in oi' + oi );                  

        }
        String orderId;
        String templateId;
        String congaTemplateId;
        String concId = '';
        Map<String,NE__OrderItem__c> mapItem = new Map<String,NE__OrderItem__c>(); 
        mapItem = differentItem(oi);
        system.debug('DL'+ mapItem);
        system.debug('DL' + ctM);
        Id recTypeOpty = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeOpty).getRecordTypeId();       
        for(NE__Order__c c1:listOrder){
            for(XC_CongaTemplateMapping__c ctM1: ctM){
                for(NE__OrderItem__c oi1: mapItem.values()){
                    System.debug('c1.recordTypeId-->' + c1.recordTypeId);
                    System.debug('orderMap.get(c1.Id)-->' + orderMap.get(c1.Id));
                    System.debug('NE__OptyId__r.XC_RPFVerification__c-->' + orderMap.get(c1.Id).NE__OptyId__r.XC_RPFVerification__c);
					Boolean templateOK =  ((c1.recordTypeId == recTypeOpty && orderMap.get(c1.Id)!= null && orderMap.get(c1.Id).NE__OptyId__r.XC_RPFVerification__c == ctM1.XC_RPFVerification__c && (orderMap.get(c1.Id).NE__OptyId__r.XC_ConsipLot__r.XC_LotNumber__c != null && ctM1.XC_LotType__c != null && orderMap.get(c1.Id).NE__OptyId__r.XC_ConsipLot__r.XC_LotNumber__c.contains(ctM1.XC_LotType__c))) 
                                                || (c1.recordTypeId != recTypeOpty && ctM1.XC_RPFVerification__c == null && ctM1.XC_LotType__c == null && ctM1.XC_CommercialProduct__c == oi1.NE__ProdId__c));
                    System.debug('templateOK ctM1' + ctM1);
                    System.debug('templateOK lotnumb' + orderMap.get(c1.Id).NE__OptyId__r.XC_ConsipLot__r.XC_LotNumber__c);
                    if(templateOK){
						System.debug('Giulia--> Conga Comm Prod' + ctM1.XC_CommercialProduct__c);
						System.debug('Giulia--> conf item ProdId' + oi1.NE__ProdId__c);
                        congaTemplateId = ctM1.XC_CongaQuery__c;                        
                        templateId = ctM1.XC_CongaIdTemplate__c ;     
                        System.debug('Giulia -->' + templateId);
                        //orderId = oi1.NE__OrderId__c;
                        String concatenatedOrder=String.valueOf(idOrder);
                        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                  //      String concatenatedTemlplate=String.valueOf(templateId);
                        String staticApi = oi1.XC_CongaStaticAPI__c;
                        String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                        + (c1.recordTypeId == recTypeOpty ? '&OFN= Verifica RPF - CONTRACT_TO_SIGN' : '&OFN= Quote - CONTRACT_TO_SIGN')
                        + '&DefaultPDF=0&qmode=SalesforceFile';

                       /* if(c1.NE__AccountId__r.XC_Country__c == 'Colombia'){
                            dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                                + '&OFN= Quote - CONTRACT_TO_SIGN'
                                + '&DefaultPDF=0&qmode=SalesforceFile';
                            }*/
                            if(c1.XC_Country__c == 'Chile'){
                                dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                                    + '&OFN=' + ctM1.XC_CommercialProduct__r.Name +' - CONTRACT_TO_SIGN'
                                    + '&DefaultPDF=0&qmode=SalesforceFile';
                                }
                        //String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId + '&OFN= Quote - CONTRACT_TO_SIGN' + '&DefaultPDF=0&qmode=SalesforceFile' + '&APDF= 1';
                        System.debug('@@@' + '&Id=' + idOrder);
                        /*if(dynamicApi.contains('{') ){
                            dynamicApi = dynamicApi.remove('{');
                        }
                        if(dynamicApi.contains('}')){
                            dynamicApi = dynamicApi.remove('}');
                        }*/
                        System.debug('DL@@@ in dynamicApi' + dynamicApi );
                        oi1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;

                        System.debug('DL@@@ in staticApi' + staticApi );
                        if(c1.recordTypeId == recTypeOpty){
                            break;
                        }
                    }
					
                }           
        }
    }
    System.debug('DL@@@ in oi' + oi );
    //if(!oi.isEmpty() && !String.isBlank(templateId)){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 updated records --->' + oi);
        XC_UTIL_Sobject.updateListRecords(oi);  
                
        //} 
    }

    private static Map<String,NE__OrderItem__c> differentItem (List<NE__OrderItem__c> listaOrder){
        Map<String,NE__OrderItem__c> mapItem = new Map<String,NE__OrderItem__c>();       
        for(NE__OrderItem__c oItem:listaOrder){
            mapItem.put(oItem.NE__ProdId__r.name,oItem);
        }
           
        return mapItem;
    }

}