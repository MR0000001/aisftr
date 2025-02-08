/**
* @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
* @date Creation 15/10/2019
* @date Modification 
* @description Class Util Class for XC_TR_CustomerInteraction_U_surveyURL -- Util class to create survey URL
*/

public without sharing class XC_TR_CustomerInteraction_U_surveyUtil {
     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  checkInfoVariableCIForQuery
     * @param idCUVariablemap 
     * @param mapInputParam
     * @param type
     * @return mapVariableUrlReturn
    */
   /*public static Map<Id,String> checkInfoVariableCIForQuery(Map<Id,String> idCUVariablemap, Map<String,Map<Id,String>> mapInputParam,String type) {
       Map<Id,String> mapVariableUrlReturn = new Map<Id,String>();
       Map<Id,Account> mapAccountSelected = new Map<Id,Account>();
       Map<Id,NE__Product__c> mapCommProductSelected = new Map<Id,NE__Product__c>();
       Map<Id,String> mapIdquadKey = new Map<Id,String>();
       List<String> listLanguage = mapInputParam.get('MapIdLanguage').values();
       List<String> listLegalEntity = mapInputParam.get('MapIdLegalEntity').values();
  
       Map<String,String> mapKeySvdt = new Map<String,String>();
       mapInputParam.put('MapIdAccountorProduct',idCUVariablemap);

        if(type =='CustomerType' && !idCUVariablemap.isEmpty()) {
          mapAccountSelected = new Map<Id,Account>([SELECT RecordType.Name,RecordType.DeveloperName,Account_Type__c FROM Account WHERE Id IN : idCUVariablemap.values()]);
        
        } else if(type =='Product' && !idCUVariablemap.isEmpty()) {
           mapCommProductSelected = new Map<Id,NE__Product__c>([SELECT Id, Name FROM NE__Product__c WHERE Id IN : idCUVariablemap.values()]);
        } else {
            return mapVariableUrlReturn;
        }
        
       Map<String,Map<Id,sObject>> inputParamObject = new Map<String,Map<Id,sObject>>{'MapIdAccount' => mapAccountSelected,'MapIdProduct' => mapCommProductSelected};
       List<String> infofromParent=createQuadKey(mapInputParam,mapIdquadKey,inputParamObject);

      
    //POSSO CREARE UN METODO -> CINGRESSO MAPPAACOUNT O MAPPACOMM, INPUTPARAM, LISTA -> RESTITUISCE mapKeySvdt
        //  if(!mapAccountSelected.isEmpty() || !mapCommProductSelected.isEmpty()) {
          for(XC_CM_SurveyVariableFields__mdt svMtd : [SELECT XC_SurveyValue__c,XC_Language__c,XC_LegalEntity__c,XC_SystemValue__c,XC_Variable__c FROM XC_CM_SurveyVariableFields__mdt WHERE XC_Language__c IN :  listLanguage AND XC_LegalEntity__c IN : listLegalEntity AND XC_Variable__c IN  ('Product','CustomerType') AND XC_SystemValue__c IN : infofromParent]) {
              String quadKey = svMtd.XC_Language__c + '_' +  svMtd.XC_LegalEntity__c + '_' + svMtd.XC_SystemValue__c + '_'+ svMtd.XC_Variable__c;
              mapKeySvdt.put(quadKey,svMtd.XC_SurveyValue__c);
          }
            // } else if(!mapCommProductSelected.isEmpty()) {
                //    for(XC_CM_SurveyVariableFields__mdt svMtd : [SELECT XC_SurveyValue__c,XC_Language__c,XC_LegalEntity__c,XC_SystemValue__c,XC_Variable__c FROM XC_CM_SurveyVariableFields__mdt WHERE XC_Language__c IN :  listLanguage AND XC_LegalEntity__c IN : listLegalEntity AND XC_Variable__c == 'Product' AND XC_SystemValue__c IN : infofromParent]) {
                //      String quadKey = svMtd.XC_Language__c + '_' +  svMtd.XC_LegalEntity__c + '_' + svMtd.XC_SystemValue__c + '_'+ svMtd.XC_Variable__c;
            //       mapKeySvdt.add(quadKey,svMtd.XC_SurveyValue__c);
            //   }
     //  }

        //
        for(Id cuId : idCUVariablemap.keyset()) {
            if(mapIdquadKey.containsKey(cuId)) {
                String key = mapIdquadKey.get(cuId);
                if(mapKeySvdt.containsKey(key)) {
                    String value=mapKeySvdt.get(key);
                    String vurl='&'+type+'='+value;
                    mapVariableUrlReturn.put(cuId,vurl);
                }
            }
        }
       return mapVariableUrlReturn;
    } */


        /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  checkInfoVariableCI
     * @param idCUProducOrCustomertVariablemap 
     * @param mapInputParam
     * @return mapVariableUrlReturn
    */
    public static Map<Id,String> checkInfoVariableCI(Map<String,Map<Id,String>> idCUProducOrCustomertVariablemap, Map<String,Map<Id,String>> mapInputParam,String typeVariable) {
       //List<Map<Id,String>> mapVariableUrlReturn = new List<Map<Id,String>>();
       Map<Id,String> mapVariableUrlReturn = new Map<Id,String>();
       Map<Id,List<String>> mapIdquadKey = new Map<Id,List<String>>();
       Set<Id> settIdCU = new Set<Id>();
       List<String> listLanguage = mapInputParam.get('MapIdLanguage').values();
       List<String> listLegalEntity = mapInputParam.get('MapIdLegalEntity').values();
       List<String> listStream = mapInputParam.get('MapIdStream').values();
       Map<Id,String> mapIdCUCustomerTypeField = idCUProducOrCustomertVariablemap.get('CustomerType');
       Map<Id,String> mapIdCUProductNameField = idCUProducOrCustomertVariablemap.get('Product');
       Map<Id,String> mapIdCUProductNameORCustomerField = idCUProducOrCustomertVariablemap.get(typeVariable);
       
       //settIdCU.addAll(mapIdCUCustomerTypeField.keySet());
       //settIdCU.addAll(mapIdCUCustomerTypeField.keySet());
       settIdCU.addAll(mapIdCUProductNameORCustomerField.keySet());
       Map<String,String> mapKeySvdt = new Map<String,String>();
       Map<String,String> mapKeySvdtDefault = new Map<String,String>();
    
     //   if(mapIdCUCustomerTypeField.isEmpty() && mapIdCUProductNameField.isEmpty()) {
       //     return mapVariableUrlReturn;
      //  }
            if(mapIdCUProductNameORCustomerField.isEmpty()) {
               // mapVariableUrlReturn.add(new Map<Id,String>());
                return mapVariableUrlReturn;
                
            }
 
       //Map<String,Map<Id,String>> inputParamObject = new Map<String,Map<Id,String>>{'MapIdAccount' => mapIdCUCustomerTypeField,'MapIdProduct' => mapIdCUProductNameField};
       List<String> infofromParent=createQuadKey(mapInputParam,mapIdquadKey,idCUProducOrCustomertVariablemap);
           
      
    //POSSO CREARE UN METODO -> CINGRESSO MAPPAACOUNT O MAPPACOMM, INPUTPARAM, LISTA -> RESTITUISCE mapKeySvdt
        //  if(!mapAccountSelected.isEmpty() || !mapCommProductSelected.isEmpty()) {
        for(XC_CM_SurveyVariableFields__mdt svMtd : [SELECT XC_SurveyValue__c,XC_Language__c,XC_LegalEntity__c,XC_SystemValue__c,XC_Variable__c,XC_Stream__c FROM XC_CM_SurveyVariableFields__mdt WHERE XC_Language__c IN :  listLanguage AND XC_LegalEntity__c IN : listLegalEntity AND XC_Variable__c =: typeVariable /*IN  ('Product','CustomerType')*/ AND XC_SystemValue__c IN : infofromParent AND XC_Stream__c IN : listStream]) {
            String quadKey = svMtd.XC_Language__c + '_' +  svMtd.XC_LegalEntity__c + '_' + svMtd.XC_SystemValue__c + '_'+ svMtd.XC_Variable__c+'_'+svMtd.XC_Stream__c;
            mapKeySvdt.put(quadKey,svMtd.XC_SurveyValue__c);
        }

        //Add Default Query -- 
        for(XC_CM_SurveyVariableFields__mdt svMtd : [SELECT XC_SurveyValue__c,XC_Language__c,XC_LegalEntity__c,XC_SystemValue__c,XC_Variable__c,XC_Stream__c FROM XC_CM_SurveyVariableFields__mdt WHERE XC_Language__c IN :  listLanguage AND XC_LegalEntity__c IN : listLegalEntity AND XC_Variable__c =: typeVariable AND XC_SystemValue__c = null]) {
            String keyDefault = svMtd.XC_Language__c + '_' +  svMtd.XC_LegalEntity__c + '_' + svMtd.XC_Variable__c;
            mapKeySvdtDefault.put(keyDefault,svMtd.XC_SurveyValue__c);
        }

        
        for(Id cuId : settIdCU) {
            for(String key: mapIdquadKey.get(cuId)) {
                if(mapKeySvdt.containsKey(key)) {
                    mapVariableUrlReturn.put(cuId,returnVariableURL(key,3,mapKeySvdt));
                   // mapVariableUrlReturn.add(new Map<Id,String> {cuId =>vurl});
                    break; //found not need default --
                } else if(mapKeySvdtDefault.containsKey(key)) {
                    mapVariableUrlReturn.put(cuId,returnVariableURL(key,2,mapKeySvdtDefault));
                }
            }
        }

     
       return mapVariableUrlReturn;
    }

    private static String returnVariableURL(String key, Integer index,Map<String,String> mapKeySvdt) {
        String value=mapKeySvdt.get(key);
        value=EncodingUtil.urlDecode(value,'UTF-8').replaceAll(' ', '%20');
        String type = key.split('_')[index];
        String vurl='&'+type+'='+value; //value.trim();
        return vurl;
    }
    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  createQuadKey
     * @param mapInputParam
     * @param mapIdquadKey 
     * @param mapInputObjectParam
     * @return infoQueryMeta
    */
    private static List<String> createQuadKey(Map<String,Map<Id,String>> mapInputParam, Map<Id,List<String>> mapIdquadKey,Map<String, Map<Id,String>> mapInputObjectParam) {
       
        List<String> infoQueryMeta = new List<String>();
        Map<Id,String> mapAccountSelected =  mapInputObjectParam.get('CustomerType');
        Map<Id,String> mapCommProductSelected = mapInputObjectParam.get('Product');
        Set<ID> settIdCU = new Set<Id>();
        settIdCU.addAll(mapAccountSelected.keySet());
        settIdCU.addAll(mapCommProductSelected.keySet());
     
        for(Id cuId : settIdCU) {
            mapIdquadKey.put(cuId,new List<String>());
            if(mapAccountSelected.containsKey(cuId)) {
                String quadKeyy= mapInputParam.get('MapIdLanguage').get(cuId)+'_'+mapInputParam.get('MapIdLegalEntity').get(cuId) + '_'+mapAccountSelected.get(cuId) + '_' + 'CustomerType'+'_'+mapInputParam.get('MapIdStream').get(cuId);
                String defaultKey = mapInputParam.get('MapIdLanguage').get(cuId)+'_'+mapInputParam.get('MapIdLegalEntity').get(cuId) + '_CustomerType';
                mapIdquadKey.get(cuId).add(quadKeyy);
                mapIdquadKey.get(cuId).add(defaultKey);
                infoQueryMeta.add(mapAccountSelected.get(cuId));
                //String urltoAdd = '&' mapAccountSelected.get(accUd).RecordType.Name;
                //mapVariableUrlReturn.put(cuId,urltoAdd);
            }
            if(mapCommProductSelected.containsKey(cuId)) {
                String quadKeyy= mapInputParam.get('MapIdLanguage').get(cuId)+'_'+mapInputParam.get('MapIdLegalEntity').get(cuId) + '_'+mapCommProductSelected.get(cuId) + '_' + 'Product'+'_'+mapInputParam.get('MapIdStream').get(cuId);
                String defaultKey = mapInputParam.get('MapIdLanguage').get(cuId)+'_'+mapInputParam.get('MapIdLegalEntity').get(cuId) + '_Product';
                mapIdquadKey.get(cuId).add(quadKeyy);
                mapIdquadKey.get(cuId).add(defaultKey);
                infoQueryMeta.add(mapCommProductSelected.get(cuId));
                //  String urltoAdd = mapAccountSelected.get(accUd).Name;
                //  mapVariableUrlReturn.put(cuId,urltoAdd);
            }
        } 

        return infoQueryMeta;   
    }


     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  createUrlFromMethods
     * @param surveyStMeta -.> map of record of CustomerInteraction
     * @param custInter
     * @return returnListString -> List<String>;
    */

    public static List<String> createUrlFromMethods(XC_CM_SurveyMetadataType__mdt surveyStMeta,XC_Customer_Interaction__c custInter) {
        List<String> returnListString = new List<String>();
        returnListString.add(uniQuiIdStringPart(surveyStMeta,custInter));
        returnListString.add(expiredDaysStr(surveyStMeta));
        returnListString.add(idValuesStr(surveyStMeta,custInter));
        returnListString.add(idValuesStr2(surveyStMeta,custInter));
        return returnListString;
    }

   
    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  uniQuiIdStringPart
     * @param surveyStMeta -.> map of record of CustomerInteraction
     * @param customerInteractionEl
     * @return returnString -> String;
    */
    private static String uniQuiIdStringPart (XC_CM_SurveyMetadataType__mdt surveyStMeta, XC_Customer_Interaction__c customerInteractionEl) {
        String returnString = '';
        String basicStr='&gf_unique={0}&gf_Id={0}';
        List<String> stringTosub = new List<String>();

        if(surveyStMeta.XC_UniqueId__c == 'WorkOrderId' && customerInteractionEl.XC_WorkOrderId__c != null) {
            //stringTosub.add('WorkOrderId');
            stringtoSub.add(String.valueOf(customerInteractionEl.XC_WorkOrderId__c));
        } else if(surveyStMeta.XC_UniqueId__c == 'CustomerInteractionId') {
            //stringTosub.add('CustomerInteractionId');
            stringTosub.add(String.valueOf(customerInteractionEl.Id));
        } else if(surveyStMeta.XC_UniqueId__c == 'CaseId'  && customerInteractionEl.XC_CaseId__c != null) {
           // stringTosub.add('CaseId');
            stringToSub.add(String.valueOf(customerInteractionEl.XC_CaseId__c));
        }
            
        if(!stringTosub.isEmpty()) {
            returnString=String.format(basicStr, stringTosub);
           // System.debug('UNIQUE ID STRING:'+returnString);
        }
        return returnString;

        // “&gf_unique=[WorkOrderId]&gf_id=[WorkOrderId]” to the URL, using the value on XC_WorkOrderId__c on the Customer Interaction.
        //  “&gf_unique=[CustomerInteractionId]&gf_id=[ CustomerInteractionId]” to the URL, using the value on Id on the Customer Interaction.
        //  “&gf_unique=[CaseId]&gf_id=[ CaseId]” to the URL, using the value on XC_CaseId__c on the Customer Interaction.
    }

     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  expiredDaysStr
     * @param surveyStMeta -.> map of record of CustomerInteraction
     * @return returnString -> String;
    */
    private static String expiredDaysStr(XC_CM_SurveyMetadataType__mdt surveyStMeta) {
        String returnString = '';
        String basicStr='&gf_expire={0}';
        if(surveyStMeta.XC_ExpireDays__c!=null) {
            Datetime todayD = System.now().addDays(Integer.valueOf(surveyStMeta.XC_ExpireDays__c));
            returnString=String.format(basicStr, new List<String>{todayD.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')});
            //Date todayD = System.today().addDays(Integer.valueOf(surveyStMeta.XC_ExpireDays__c));
            //returnString=String.format(basicStr, new List<String>{String.valueOf(todayD)});
        }
        //   IF ExpireDays IS NOT NULL will concatenate “&gf_unique=[Date]” to the URL, were [Date] is the current date + the number of days in the field ExpireDays in the Custom Metadata queried record.
        return returnString;
    }

    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  idValuesStr
     * @param surveyStMeta -.> map of record of CustomerInteraction
    * @param customerInteractionEl
     * @return returnString -> String;
    */
    private static String idValuesStr(XC_CM_SurveyMetadataType__mdt surveyStMeta, XC_Customer_Interaction__c customerInteractionEl) {
        String returnString = '';
     
        if(surveyStMeta.XC_LeadId__c && customerInteractionEl.XC_LeadId__c !=null) {
            returnString =returnString+'&LeadID='+String.valueOf(customerInteractionEl.XC_LeadId__c);
        }
        if(surveyStMeta.XC_ContactId__c && customerInteractionEl.XC_ContactId__c !=null) {
            returnString =returnString+'&ContactID='+String.valueOf(customerInteractionEl.XC_ContactId__c);
        }
        if(surveyStMeta.XC_AccountId__c && customerInteractionEl.XC_AccountId__c !=null) {
             returnString =returnString+'&AccountID='+String.valueOf(customerInteractionEl.XC_AccountId__c);
        }
         /*  IF LeadID = True THEN Will concatenate “&LeadID=[XC_LeadId__c on Customer Interaction]” to the URL
            IF ContactID = True THEN Will concatenate “&ContactID=[XC_ContactId__c on Customer Interaction]” to the URL
            IF AccountID = True THEN Will concatenate “&AccountID=[XC_AccountId__c on Customer Interaction]” to the URL
            IF CaseID = True THEN Will concatenate “&CaseID=[XC_CaseId__c on Customer Interaction]” to the URL
            IF WorkOrderID = True THEN Will concatenate “&WorkOrderID=[XC_WorkOrderId__c on Customer Interaction]” to the URL
            COMMENTS: As an example, the fourth part of the URL will be the following:
            &ContactID=abcdefghijklmnopqr&WorkOrderID=abcdefghijklmnopqr */
        return returnString;
    }
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method  idValuesStr2
     * @param surveyStMeta -.> map of record of CustomerInteraction
    * @param customerInteractionEl
     * @return returnString -> String;
    */

    private static String idValuesStr2(XC_CM_SurveyMetadataType__mdt surveyStMeta, XC_Customer_Interaction__c customerInteractionEl) {
        String returnString = '';
     
        if(surveyStMeta.XC_CaseId__c && customerInteractionEl.XC_CaseId__c !=null) {
             returnString =returnString+'&CaseID='+String.valueOf(customerInteractionEl.XC_CaseId__c);
        }
        if(surveyStMeta.XC_WorkOrderId__c && customerInteractionEl.XC_WorkOrderId__c!=null) {
             returnString =returnString+'&WorkOrderID='+String.valueOf(customerInteractionEl.XC_WorkOrderId__c);
        }

       return returnString;
    }

}