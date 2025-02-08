/**
* @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
* @date Creation 11/10/2019
* @date Modification 
* @description Class For create the dymanic URL FOR SURVEY 
*/
public without sharing class XC_TR_CustomerInteraction_U_surveyURL {
    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on beofore insert
     * @param listNews -.> list of new value of record
    */
    public static void checkSurveyOnCustomerInteraction(List<XC_Customer_Interaction__c> listNews) {
        Map<Id,XC_Customer_Interaction__c> mapOfCustomerAddSurvey = new Map<Id,XC_Customer_Interaction__c>();
       // Map<String,Map<Id,String>> mapParameterInput = new Map<String,Map<Id,String>>();
       
        List<String> listIdCILAN = new List<String>();
        List<String> listdSurveyId = new List<String>();
        Map<Id,String> mapIDCUKey = new Map<Id,String>();
        List<String> listIdCILE = new List<String>();
        List<String> listCIStream = new List<String>();


        List<Id> listIdCi = XC_UTIL_Sobject.getIds(listNews);
        List<XC_Customer_Interaction__c> newListUpdated= XC_UTIL_Sobject.selectAllFields(listIdCi, 'XC_Customer_Interaction__c');
        System.debug('@@NEW LIST' + newListUpdated);


        //
        for(XC_Customer_Interaction__c ciel : newListUpdated) {
            if(String.isNotBlank(ciel.XC_Communication_Type__c) && ciEl.XC_SurveyId__c!=null  && ciel.XC_LegalEntity__c != null && ciel.XC_Preferredlanguageofcontact__c!=null) {
                
                mapOfCustomerAddSurvey.put(ciel.Id,ciel);
                listIdCILAN.add(ciel.XC_Preferredlanguageofcontact__c);
                listIdCILE.add(ciel.XC_LegalEntity__c);
                listdSurveyId.add(ciel.XC_SurveyId__c);
                listCIStream.add(ciel.XC_Segment__c);
                //ADD Segment usage
                mapIDCUKey.put(ciel.Id,(ciel.XC_SurveyId__c+'_'+ciel.XC_LegalEntity__c+'_'+ciel.XC_Preferredlanguageofcontact__c+'_'+ciel.XC_Segment__c));

            } 
        }

        if(!mapOfCustomerAddSurvey.isEmpty()) {
            Map<String,XC_CM_SurveyMetadataType__mdt> mapKeySruveyCMTStatic = new Map<String,XC_CM_SurveyMetadataType__mdt>();

            for(XC_CM_SurveyMetadataType__mdt survMetadata : [SELECT XC_Url__c, XC_UniqueId__c,XC_Survey_Id__c ,XC_Legal_Entity__c,XC_Language__c, XC_ExpireDays__c, XC_LeadId__c, XC_ContactId__c, XC_AccountId__c, XC_CaseId__c, XC_WorkOrderId__c,XC_Product__c, XC_CustomerType__c,XC_Stream__c //CTIInteractionID 
                                                            FROM XC_CM_SurveyMetadataType__mdt WHERE XC_Legal_Entity__c IN : listIdCILE AND XC_Survey_Id__c IN : listdSurveyId
                                                              AND XC_Language__c IN : listIdCILAN AND XC_Stream__c IN : listCIStream AND XC_OrganizationId__c =: UserInfo.getOrganizationId()]) {
                
                //String keyCU=survMetadata.XC_Survey_Id__c+'_'+survMetadata.XC_Legal_Entity__c+'_'+survMetadata.XC_Language__c;
                mapKeySruveyCMTStatic.put((survMetadata.XC_Survey_Id__c+'_'+survMetadata.XC_Legal_Entity__c+'_'+survMetadata.XC_Language__c+'_'+survMetadata.XC_Stream__c),survMetadata);                                               
            }
         
            if(mapKeySruveyCMTStatic.isEmpty()) {return;}
            createDinamycURL(mapOfCustomerAddSurvey,mapIDCUKey,mapKeySruveyCMTStatic);
        }
    }
    

    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  createDinamycURL
     * @param mapOfCustomerAddSurvey -.> map of record of CustomerInteraction
     * @param mapIDCUKey
     * @param mapKeySruveyCMTStatic --> Map key XC_CM_SurveyMetadataType__mdt
    */
    private static void createDinamycURL(Map<Id,XC_Customer_Interaction__c> mapOfCustomerAddSurvey,Map<Id,String> mapIDCUKey,  Map<String,XC_CM_SurveyMetadataType__mdt> mapKeySruveyCMTStatic) {
        Map<Id,String> idCISTATICURL = new Map<Id,String>();
        //Variable field Map
        Map<String,Map<Id,String>> idCUProducOrCustomertVariablemap = new Map<String,Map<Id,String>>{'Product' => new Map<Id,String>(),'CustomerType' => new Map<Id,String>()};
       // Map<String,Map<Id,String>> idCUCustomerTypeVariablemap = new Map<String,Map<Id,Id>>{'CustomerType' => new Map<Id,Id>()];
        List<Map<Id,String>> listofMapURLPart = new List<Map<Id,String>>();
        Map<Id,Boolean> mapIdCIneedClone = new Map<Id,Boolean>();
        
        Map<Id,String> listIdCILAN = new Map<Id,String>();
        Map<Id,String> listdSurveyId = new Map<Id,String>();
        Map<Id,String> listIdCILE = new Map<Id,String>();
        Map<Id,String> listCIStream = new Map<Id,String>();
        Map<String,Map<Id,String>> mapInputParam = new Map<String,Map<Id,String>>();

        //Access To XC_CM_SurveySMSChannel_CIClone__mdt for create a List of Communication Type to Clone
        List<XC_CM_SurveySMSChannel_CIClone__mdt> commToCloneList_mdt= [SELECT Id,XC_CommTypeList_ToClone__c FROM XC_CM_SurveySMSChannel_CIClone__mdt WHERE XC_CommTypeList_ToClone__c!=null LIMIT 1];
        if(commToCloneList_mdt.isEmpty()) { return; }

        List<String> communicaitonTypeToClon = commToCloneList_mdt.get(0).XC_CommTypeList_ToClone__c.split(';');
        
        for(Id cuId: mapIDCUKey.keySet()) {
            String key=mapIDCUKey.get(cuId);

            //
            List<String> subkey=key.split('_');
            listdSurveyId.put(cuId,subkey[0]);
            listIdCILE.put(cuId,subkey[1]);
            listIdCILAN.put(cuId,subkey[2]);
            listCIStream.put(cuId,subkey[3]);
            //

            XC_Customer_Interaction__c custInter = mapOfCustomerAddSurvey.get(cuId);
           // String finalPartialUrl=null;
            String cuURL=null;
           // List<String> urlStringFirstPart = new List<String>();
            //List<String> urlStringSecondPart = new List<String>();
            if(!mapKeySruveyCMTStatic.containsKey(key)) {
                continue;
            }
            XC_CM_SurveyMetadataType__mdt surveyStMeta = mapKeySruveyCMTStatic.get(key);
            cuURL=surveyStMeta.XC_Url__c!=null ? surveyStMeta.XC_Url__c : 'Url Survey Not Found';
            //   System.debug('SURVEY STATIC URL'+ CuURL);
                
               
            //String firstPartJoin = String.join(new List<String>{cuURL,custInter.XC_SurveyId__c}, '/');
            // finalPartialUrl=firstPartJoin;
            String firstPartJoin=cuURL;
            String secondPartJoin = String.join(XC_TR_CustomerInteraction_U_surveyUtil.createUrlFromMethods(surveyStMeta,custInter),'').trim();
            // if(String.isNotEmpty(secondPartJoin)) {
            String finalPartialUrl='';
            if(!cuURL.containsAny('?')) {
                finalPartialUrl =  String.isNotEmpty(secondPartJoin) ? firstPartJoin+'?'+secondPartJoin : firstPartJoin;
            } else {
                finalPartialUrl =  String.isNotEmpty(secondPartJoin) ? firstPartJoin+secondPartJoin : firstPartJoin;
            }
         
            // } 
            //System.debug('URL F'+finalPartialUrl);
            idCISTATICURL.put(cuId,finalPartialUrl);
            variableFieldsCheck(surveyStMeta,custInter,idCUProducOrCustomertVariablemap);
            checkCommunicationType(custInter,mapIdCIneedClone,communicaitonTypeToClon);
        }

        //
        mapInputParam.put('MapIdKey',mapIDCUKey);
        mapInputParam.put('MapIdSurveyId',listdSurveyId);
        mapInputParam.put('MapIdLegalEntity',listIdCILE);
        mapInputParam.put('MapIdStream',listCIStream);
        mapInputParam.put('MapIdLanguage',listIdCILAN);
        //

        listofMapURLPart.add(idCISTATICURL);
       // for(String type : idCUProducOrCustomertVariablemap.keySet()) {
       //     listofMapURLPart.add(XC_TR_CustomerInteraction_U_surveyUtil.checkInfoVariableCI(idCUProducOrCustomertVariablemap.get(type),mapInputParam,type));
       // }
        
        listofMapURLPart.add(XC_TR_CustomerInteraction_U_surveyUtil.checkInfoVariableCI(idCUProducOrCustomertVariablemap,mapInputParam,'Product'));
        listofMapURLPart.add(XC_TR_CustomerInteraction_U_surveyUtil.checkInfoVariableCI(idCUProducOrCustomertVariablemap,mapInputParam,'CustomerType'));
       System.debug('listofMapURLPart'+listofMapURLPart);
     
       buildFinalUrl(listofMapURLPart,mapOfCustomerAddSurvey,mapIdCIneedClone);
    }

     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  variableFieldsCheck
     * @param surveyStMeta 
     * @param custInter
     * @param idCUProducOrCustomertVariablemap
    */
    private static void variableFieldsCheck(XC_CM_SurveyMetadataType__mdt surveyStMeta, XC_Customer_Interaction__c custInter, Map<String,Map<Id,String>> idCUProducOrCustomertVariablemap) {
        if(surveyStMeta.XC_Product__c && custInter.XC_ProductName__c!=null) {
            //idCUProductVariablemap.put('Product',new Map<Id,Id> {custInter.Id => custInter.XC_  });
            idCUProducOrCustomertVariablemap.get('Product').put(custInter.Id,custInter.XC_ProductName__c);
        }
        if(surveyStMeta.XC_CustomerType__c && custInter.XC_CustomerType__c!=null) {
            // idCUCustomerTypeVariablemap.put(custInter.Id,'CustomerType');
            idCUProducOrCustomertVariablemap.get('CustomerType').put(custInter.Id,custInter.XC_CustomerType__c);
        }           
    } 

    /**
    * @author Marco Ottaviano - mottaviano@deloitte.it
    * @description Method to check if the CommunicationType of the CI is it one of those that do not need cloning the current CI
    * @param newCi
    * @param mapIdCIneedClone
    **/
    public static void checkCommunicationType(XC_Customer_Interaction__c newCi, Map<Id,Boolean> mapIdCIneedClone,List<String> communicaitonTypeToClon) {
      
        if(communicaitonTypeToClon.contains(newCi.XC_Communication_Type__c) && newCi.XC_Channel__c =='SMS') {
            mapIdCIneedClone.put(newCi.Id,true);
        } else {
            mapIdCIneedClone.put(newCi.Id,false);
        } 
    }



      /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  buildFinalUrl
     * @param listofMapURLPart 
     * @param mapOfCustomerAddSurvey
     * @param mapIdCIneedClone
    */

    private static void buildFinalUrl(List<Map<Id,String>> listofMapURLPart,Map<Id,XC_Customer_Interaction__c> mapOfCustomerAddSurvey,Map<Id,Boolean> mapIdCIneedClone) {
        
        Map<Id,String> mapidCISTATICURL = listofMapURLPart.get(0);
        Map<Id,String> mapidCIVariableProductURL = listofMapURLPart.get(1);
        Map<Id,String> mapidCIVariableCustomerTypeURL = listofMapURLPart.get(2);
        List<XC_Customer_Interaction__c> customerToUp = new List<XC_Customer_Interaction__c>();
        List<XC_Customer_Interaction__c> customerToIns = new List<XC_Customer_Interaction__c>();

        for(Id cuId: mapOfCustomerAddSurvey.keyset()) {
            XC_Customer_Interaction__c customerIn = mapOfCustomerAddSurvey.get(cuId);
            XC_Customer_Interaction__c newcust= null;
            String surveyUrl ='';

            if(mapidCISTATICURL.containsKey(cuId)) {
                surveyUrl = mapidCISTATICURL.get(cuId);
                if(mapidCIVariableProductURL.containsKey(cuId)) {
                    surveyUrl=surveyUrl+mapidCIVariableProductURL.get(cuId);
                }
                if(mapidCIVariableCustomerTypeURL.containsKey(cuId)) {
                    surveyUrl=surveyUrl+mapidCIVariableCustomerTypeURL.get(cuId);
                }
               // System.debug('FINAL URL FOR CUSTOMER INTERACTION: '+ surveyUrl);
                //newcust.XC_SurveyUrl__c=surveyUrl;
            }

           /* if(customerIn.XC_Channel__c == 'SMS' && mapIdCIneedClone.get(cuId)) {
                newcust=customerIn.clone(false,false,false,false);
                newcust.XC_Communication_Type__c = customerIn.XC_Communication_Type__c+'_Survey'; //TO DO  Add to picklist XC_Communication_Type__c these values: /* ServiceAppointment_Cancelled_Survey - WorkOrder_QuoteNotCreated _Survey - Order_Cancelled_Survey - WorkOrder_ActivityReport_Survey --Case_Closed	Case_Closed_Survey */             
                //newcust.XC_SurveyUrl__c= surveyUrl;//EncodingUtil.urlEncode(surveyUrl,'UTF-8'); //surveyUrl; //EncodingUtil.urlEncode(,'UTF-8');
                //customerToIns.add(newcust);
          //  }

            if(!mapIdCIneedClone.get(cuId)) {
                newcust= new XC_Customer_Interaction__c(Id=customerIn.Id);
                newcust.XC_SurveyUrl__c= surveyUrl;//EncodingUtil.urlEncode(surveyUrl,'UTF-8');//EncodingUtil.urlEncode(surveyUrl,'UTF-8'); //surveyUrl; //EncodingUtil.urlEncode(surveyUrl,'UTF-8');
                customerToUp.add(newcust);
            }

        }

        if(!customerToUp.isEmpty()) {  XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true); XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); XC_UTIL_Sobject.updateListRecords(customerToUp); }
        //if(!customerToIns.isEmpty()) { XC_UTIL_Sobject.insertListRecords(customerToIns); }

       /*if(!customerToIns.isEmpty()) {
            //System.enqueueJob(new XC_NewCI_SMS_Survey(customerToIns));
            XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true); 
            XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);
            XC_UTIL_Sobject.insertListRecords(customerToIns);
            //insertCloneCI(JSON.serialize(customerToIns));
        }*/
       
    }


   /* @future
    public static void insertCloneCI(String stringListCItoInsert) {
      List<XC_Customer_Interaction__c> listCiToInsert = (List<XC_Customer_Interaction__c>)JSON.deserialize(stringListCItoInsert,List<XC_Customer_Interaction__c>.class);
      List<XC_UTIL_Sobject.WrapperResult> resList = XC_UTIL_Sobject.insertListRecords(listCiToInsert);
      System.debug('LIST Size Result CI '+ resList.size());
      System.debug('FIRST CI' + resList[0].recordId);
    }*/


     /**
     * The Class XC_NewCI_SMS_Survey.
     * @description  The Class XC_NewCI_SMS_Survey
     */
    /*  public without sharing class XC_NewCI_SMS_Survey implements Queueable {

        //The customer interaction. 
        private final List<XC_Customer_Interaction__c> ciList;

        /**
        * Instantiates a new XC_NewCI_SMS_Survey.
        *
        * @param ciList the infos map
        * @description constructor of XC_NewCI_SMS_Survey
        
        public XC_NewCI_SMS_Survey(List<XC_Customer_Interaction__c> ciList) {
            this.ciList = ciList;
        }
        /**
        * Execute.
        *
        * @param qc the QueueableContext
        * @description execute of XC_NewCI_SMS_Survey
        
        public void execute(QueueableContext qc){
            List<XC_UTIL_Sobject.WrapperResult> resList = XC_UTIL_Sobject.insertListRecords(ciList);
            System.debug('LIST Size Result CI '+ resList.size());
            System.debug('FIRST CI' + resList[0].recordId);
           
        }    
    } */


}