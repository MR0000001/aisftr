/**
* @author Daniele Lico
* @date Creation 22/11/2019
* @date Modification -
* @description XC_TR_Configuration_U_CongaWFCustomObj 
*/

public without sharing class XC_TR_Configuration_U_CongaWFCustomObj {

    
    
    public static void checkRecordTypeForQuote(List<NE__Order__c> listOrder, Map<Id,NE__Order__c> mapOldS, Map<Id,NE__Order__c> mapNewS){
        List<NE__Order__c> listOrderChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_GenerateQuoteDocument__c'}, mapOldS, mapNewS);
        if(listOrderChanged.isEmpty()){ 
            return;
        }
        System.debug('in XC_TR_Configuration_U_CongaWFCustomObj' + listOrder);
        Id recTypeOpty = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeOpty).getRecordTypeId();
        Id recTypeQuote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeQuote).getRecordTypeId();
        Id recTypeOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        List<NE__Order__c> listOrderGenerateDocumentTrue = new List<NE__Order__c>();
        List<NE__Order__c> listOptyGenerateDocumentTrue = new List<NE__Order__c>();
        List<NE__Order__c> listOrderInProgress = new List<NE__Order__c>();
        Set<Id> setOrderIDForMilestone = new Set<Id>();

        for(NE__Order__c order : listOrder){


            if(order.recordTypeId == recTypeQuote && order.XC_GenerateQuoteDocument__c == true){
                //XC_TR_Configuration_U_CongaCustObjQuote.congaTemplateIdForQuote(listOrder);
                setOrderIDForMilestone.add(order.id);
                listOrderGenerateDocumentTrue.add(order);
                System.debug('DL@@@ wait for congaTemplateIdForQuote');
            }
			if(order.recordTypeId == recTypeOpty && order.XC_GenerateQuoteDocument__c == true){
                listOptyGenerateDocumentTrue.add(order);
                System.debug('DL@@@ wait for congaTemplateIdForOpty');
            }


            if(order.recordTypeId == recTypeOrder && order.XC_Status__c == 'In Progress'){
                //congaTemplateIdForOrder(listOrder);
                listOrderInProgress.add(order);
                 System.debug('DL@@@ wait listOrder' + listOrder);
            }               
        }
        if(!listOrderGenerateDocumentTrue.isEmpty()){
            List<NE__OrderItem__c> listOrderItemsAndMilestone = new List<NE__OrderItem__c>();
            listOrderItemsAndMilestone = retriveConfItem(listOrder,setOrderIDForMilestone);
            checkConfItemHaveMilestone(listOrderGenerateDocumentTrue,setOrderIDForMilestone, listOrderItemsAndMilestone);
            checkDurationRecurringIsFilled(listOrderGenerateDocumentTrue,setOrderIDForMilestone,listOrderItemsAndMilestone);
            checkNeedApprovalProcess(listOrderGenerateDocumentTrue,listOrderItemsAndMilestone);
            checkBillingProfileIsFilled(listOrderGenerateDocumentTrue,listOrderItemsAndMilestone);

            XC_TR_Configuration_U_CongaCustObjQuote.congaTemplateIdForQuote(listOrderGenerateDocumentTrue);
        }
        if(!listOptyGenerateDocumentTrue.isEmpty()){
            List<NE__OrderItem__c> listOrderItemsAndMilestone = new List<NE__OrderItem__c>();
           
            XC_TR_Configuration_U_CongaCustObjQuote.congaTemplateIdForQuote(listOptyGenerateDocumentTrue);
        }
        if(!listOrderInProgress.isEmpty()){
            congaTemplateIdForOrder(listOrderInProgress);
        }
        
    }

    /**
     * @author Daniele Lico - dlico@deloitte.it 
     * @date Creation 22/11/2019
     * @description Method to insert Id Conga Templete
     * @param listOrder List Order Instance of the Trigger handler
    */

    public static void congaTemplateIdForOrder (List<NE__Order__c> listOrder){

        
        /*Map<Id,NE__Order__c> c = new Map<Id,NE__Order__c> ([Select id,XC_LegalEntity__c,NE__AccountId__r.XC_SohoType__c,
                                                            NE__AccountId__r.XC_Country__c,NE__rTypeName__c 
                                                                from NE__Order__c where id IN: listOrder]);*/   
        //delete this query

        
        Set<String> sohoType = new Set<String>();
        Set<String> country = new Set<String>();
        Set<String> legalentity = new Set<String>();
        Set<Id> idOrder = new Set<Id> ();
        List<NE__Order__c> orderlist = [SELECT Id,NE__AccountId__r.XC_Country__c,NE__AccountId__r.XC_SohoType__c  
                                             from ne__order__c where id in: listOrder];
        for(NE__Order__c o1: orderlist){
            //legalentity.add(o1.XC_LegalEntity__c);
            sohoType.add(o1.NE__AccountId__r.XC_SohoType__c);
            System.debug('DL@@@ in o1.NE__AccountId__r.XC_SohoType__c' + o1.NE__AccountId__r.XC_SohoType__c );
            country.add(o1.NE__AccountId__r.XC_Country__c); 
            System.debug('DL@@@ in o1.NE__AccountId__r.XC_Country__c' + o1.NE__AccountId__r.XC_Country__c );
            idOrder.add(o1.id);     
            System.debug('DL@@@ in o1.id' + o1.id );
        }

        for(NE__Order__c o1: listOrder){
            legalentity.add(o1.XC_LegalEntity__c);  
            System.debug('DL@@@ in o1.XC_LegalEntity__c' + o1.XC_LegalEntity__c );  
        }

        List<XC_CongaTemplateMapping__c> ctM = new List<XC_CongaTemplateMapping__c>();
        if(Schema.sObjectType.XC_CongaTemplateMapping__c.isAccessible()){
            ctM = [ Select id,XC_CongaIdTemplate__c,Name,XC_AccountType__c,XC_CommercialProduct__c,XC_Bundle__c,
                    XC_LegalEntity__c,XC_CongaQuery__c
                    from XC_CongaTemplateMapping__c 
                    where XC_LegalEntity__c in: legalentity and XC_AccountType__c in: sohoType and XC_Country__c in: country 
                  	and XC_Bundle__c= false and XC_IsContract__c=false];
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
        for(NE__Order__c c1:listOrder){
            for(XC_CongaTemplateMapping__c ctM1: ctM){
                for(NE__OrderItem__c oi1: oi){
                    
                    if(ctM1.XC_CommercialProduct__c == oi1.NE__ProdId__c){
                        //concId += ctM1.XC_CongaIdTemplate__c + ',';   
                        congaTemplateId = ctM1.XC_CongaQuery__c;
                        templateId = ctM1.XC_CongaIdTemplate__c;
                        //orderId = oi1.NE__OrderId__c;
                        String concatenatedOrder=String.valueOf(idOrder);
                        concatenatedOrder = concatenatedOrder.removeEnd('}').removeStart('{');
                        
                        String staticApi = oi1.XC_CongaStaticAPI__c;
                        String dynamicApi = '&Id=' + concatenatedOrder + '&QueryId=' +  congaTemplateId + '&TemplateId=' +  templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                            + '&OFN= Quote - CONTRACT_TO_SIGN'
                            + '&DefaultPDF=0&qmode=SalesforceFile';
                        oi1.XC_CongaDynamicAPI__c = staticApi + dynamicApi;
                        
                    }
                    break;
                    
                }               
        }
    }


    //if(!oi.isEmpty() && !String.isBlank(templateId)){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 updated records --->' + oi);
        XC_UTIL_Sobject.updateListRecords(oi);  
                
        //} 
    }


    private static void checkConfItemHaveMilestone(List<NE__Order__c> listOrder, Set<Id> setOrderId, List<NE__OrderItem__c> listOrderItemsAndMilestone){
        Map<String,String> mapIdStatus = new Map<String,String>();
        for(NE__OrderItem__c ne : listOrderItemsAndMilestone){
            if(ne.XC_BillingModel__c=='Milestone'){
                mapIdStatus.put(ne.id,'KO');
                for(XC_Milestone__c m : ne.XC_Milestones__r){
                    mapIdStatus.put(m.XC_OrderItem__c, 'OK');
                }

            }
        }
        for(NE__Order__c order: listOrder){
            for(NE__OrderItem__c ne : listOrderItemsAndMilestone){
                if(ne.NE__OrderId__c == order.id && ne.NE__Root_Order_Item__c== Null){
                    if(mapIdStatus.get(ne.id)=='KO'){
                        order.addError(Label.XC_CL_PPM_GenerateDocumentError);
                    }
                }
            }
        }
    }


    private static void checkDurationRecurringIsFilled(List<NE__Order__c> listOrder, Set<Id> setOrderId, List<NE__OrderItem__c> listOrderItemsAndMilestone){
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
       for(NE__Order__c order: listOrder){
            for(NE__OrderItem__c ne : listOrderItemsAndMilestone){
                if(setSegmanet.contains(ne.XC_Segment__c)){
                    if(ne.XC_BillingModel__c=='Recurring' && ne.XC_RecurringDuration__c == Null) {
                        order.addError(Label.XC_CL_DurationField_Is_Filled);
                    }
                }
            }
        }

    }




    private static List<NE__OrderItem__c> retriveConfItem(List<NE__Order__c> listOrder, Set<Id> setOrderId){
        List<NE__OrderItem__c> listOrderItemsAndMilestone = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            listOrderItemsAndMilestone = [SELECT ID, (select id, XC_Rate__c, name, XC_StartDate__c,XC_EndDate__c,XC_OrderItem__c from XC_Milestones__r), NE__OrderId__c, XC_BillingModel__c, XC_RecurringDuration__c, XC_BillingProfileLineItem__c, XC_Segment__c, XC_LegalEntity__c,NE__Root_Order_Item__c, XC_NeedApproval__c, RecordType.DeveloperName FROM NE__OrderItem__c where NE__OrderId__c IN:setOrderId];
        }
        return listOrderItemsAndMilestone;

    }

    private static void checkNeedApprovalProcess(List<NE__Order__c> listOrder, List<NE__OrderItem__c> listOrderItemsAndMilestone){
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
        for(NE__Order__c order: listOrder){
            for(NE__OrderItem__c ne : listOrderItemsAndMilestone){
                if(setSegmanet.contains(ne.XC_Segment__c)&& ne.XC_NeedApproval__c){
                     order.addError(Label.XC_Markup_Need_ApprovalProcess);
                }
            }
        }

    }
    private static void checkBillingProfileIsFilled(List<NE__Order__c> listOrder, List<NE__OrderItem__c> listOrderItemsAndMilestone){
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
        for(NE__Order__c order: listOrder){
            for(NE__OrderItem__c ne : listOrderItemsAndMilestone){
                if(setSegmanet.contains(ne.XC_Segment__c)&& String.isBlank(ne.XC_BillingProfileLineItem__c) && ne.RecordType.DeveloperName != 'Technical_Item' && ne.XC_BillingModel__c !='Capex'){
                    order.addError(Label.BillingProfileErrorMessage);
                }
            }
        }
    }




}