/**
* @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
* @date Creation 27/09/2019
* @date Modification 
* @description Class with methods to 
*/

public without sharing class XC_TR_GetFbResponse_U_CreateFbQuestion {

    private final static Integer NUMBER_OF_QA=25;

    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public static void createXCFBQuestionRecord(Map<id,XC_GetFeedbackResponse__c> mapNewS){
        //System.debug('createXCFBQuestionRecord called');
        Map<Id,List<Map<String,Object>>> mapIdFBRespField = new Map<Id,List<Map<String,Object>>>();

        for(XC_GetFeedbackResponse__c feedbackResp : mapNewS.values()) {
           cycleonQuestionAnswer(mapIdFBRespField,feedbackResp);
        }//fine for sui record inseriti

        List<XC_GetFeedbackQuestion__c> listRecordToinsert = new List<XC_GetFeedbackQuestion__c>();

        for(Id idGetFeedbackResp : mapIdFBRespField.keySet()) {
            if(!mapIdFBRespField.get(idGetFeedbackResp).isEmpty()) { //se la lista non è vuota -- vuol dire che c'è almeno una coppia domanda risposta popolata
                List<Map<String,Object>> listofMapQAfield = mapIdFBRespField.get(idGetFeedbackResp);
                for(Map<String,Object>  mapQAfield : listofMapQAfield) {
                    createGetFeedBackQuestionRecord(mapQAfield,listRecordToinsert);
                }
            }
        }

        if(!listRecordToinsert.isEmpty()) {
            //System.debug('LISTA DA INSERIRE : '+listRecordToinsert);
           List<XC_UTIL_Sobject.WrapperResult> wrRlist=XC_UTIL_Sobject.insertListRecords(listRecordToinsert);
           //System.debug('WRAPPER RESLIST'+wrRlist);
        }
    } 

    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be create record of XC_GetFeedbackQuestion__c
     * @param mapField - map String -> field of the object XC_GetFeedbackQuestion__c
     * @param listRecordToinsert - list of record the XC_GetFeedbackQuestion__c to populate 
    */
    public static void createGetFeedBackQuestionRecord(Map<String,Object> mapField, List<XC_GetFeedbackQuestion__c> listRecordToinsert) {
        XC_GetFeedbackQuestion__c newFBQuestionRecord = new XC_GetFeedbackQuestion__c();
        for(String apiName : mapField.keyset()) {
            if(apiName != 'XC_GfResponse__c') {
                 newFBQuestionRecord.put(apiName,String.valueOf(mapField.get(apiName)));
            } else {
                 newFBQuestionRecord.put(apiName,mapField.get(apiName));
            }
        }
        listRecordToinsert.add(newFBQuestionRecord);
    }



  


   
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param listNews - > list of new record
    */
    public static void updatePercentComplete(List<XC_GetFeedbackResponse__c> listNews) {
        for(XC_GetFeedbackResponse__c feedbackResp :listNews) {
            Decimal numberOfCompiledQuestion=0.0;
            Decimal numberOfCompiledAnswer=0.0;
            for(Integer i=1;i<=NUMBER_OF_QA;i++) {   //FOR Sul numero dei campi Domanda/Risposta dell'oggetto XC_GetFeedbackResponse__c
                String fieldQuestion='XC_Question'+i+'__c';
                String fieldAnswer='XC_Answer'+i+'__c';
                if(String.isNotBlank(String.valueOf(feedbackResp.get(fieldQuestion)))) {
                    numberOfCompiledQuestion ++;
                    if( String.isNotBlank(String.valueOf(feedbackResp.get(fieldAnswer)))) {numberOfCompiledAnswer++;}
                }
            } //fine for sui campi;
            feedbackResp.XC_Percent_Complete__c = numberOfCompiledQuestion!=0.0 ? (numberOfCompiledAnswer/numberOfCompiledQuestion)*100 : 0.0; 
        }
    }

    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param mapIdFBRespField 
     * @param feedbackResp
    */
    private static void cycleonQuestionAnswer(Map<Id,List<Map<String,Object>>> mapIdFBRespField,XC_GetFeedbackResponse__c feedbackResp) {

        for(Integer i=1;i<=NUMBER_OF_QA;i++) {   //FOR Sul numero dei campi Domanda/Risposta dell'oggetto XC_GetFeedbackResponse__c

           // Map<String,Object> mapQAfield = new Map<String,Object>(); 
           // Map<String,Object> mapQAfield = null;
            String fieldQuestion='XC_Question'+i+'__c';
            String fieldAnswer='XC_Answer'+i+'__c';
            String fieldQuestionid='XC_QuestionID'+i+'__c';

            //SE LA RISPOSTA, DOMANDA E POPOLATA mi prendo i valori dei campi per popolare la mappa
            if( String.isNotBlank(String.valueOf(feedbackResp.get(fieldAnswer))) && String.isNotBlank(String.valueOf(feedbackResp.get(fieldQuestion))) && String.isNotBlank(String.valueOf(feedbackResp.get(fieldQuestionid))) ) {
                List<Map<String,Object>> listofMapQAfield = null;
                if(!mapIdFBRespField.containsKey(feedbackResp.id)) {
                    mapIdFBRespField.put(feedbackResp.Id,new List<Map<String,Object>>());
                }
                listofMapQAfield = mapIdFBRespField.get(feedbackResp.Id);

              /*  mapQAfield.put('XC_GfResponse__c',feedbackResp.Id);
                mapQAfield.put('XC_QuestionNumber__c',i);                 // ORDINE CON CUI POPOLO LA MAPPA  -- SONO I CAMPI DELL'OGGETTO XC_FEEDBACKQuestion__c
                mapQAfield.put('XC_QuestionType__c',feedbackResp.get(fieldQuestionid));
                mapQAfield.put('XC_QuestionText__c',feedbackResp.get(fieldQuestion));  
                mapQAfield.put('XC_Answer__c',feedbackResp.get(fieldAnswer)); */

                listofMapQAfield.add(addmapQAfield(feedbackResp,i)); //aggiungo la mappa alla lista
            } 
        } //fine for numero di coppia Domanda/Risposta
    }

     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param i 
     * @param feedbackResp
     * @return mapQAfield
    */

    public static Map<String,Object> addmapQAfield(XC_GetFeedbackResponse__c feedbackResp,Integer i) {
        String fieldQuestion='XC_Question'+i+'__c';
        String fieldAnswer='XC_Answer'+i+'__c';
        String fieldQuestionid='XC_QuestionID'+i+'__c';
        Map<String,Object> mapQAfield = new Map<String,Object>();
        mapQAfield.put('XC_GfResponse__c',feedbackResp.Id);
        mapQAfield.put('XC_QuestionNumber__c',i);                 // ORDINE CON CUI POPOLO LA MAPPA  -- SONO I CAMPI DELL'OGGETTO XC_FEEDBACKQuestion__c
        mapQAfield.put('XC_QuestionType__c',feedbackResp.get(fieldQuestionid));
        mapQAfield.put('XC_QuestionText__c',feedbackResp.get(fieldQuestion));  
        mapQAfield.put('XC_Answer__c',feedbackResp.get(fieldAnswer));
        return mapQAfield;
    }

     /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to be executed on before insert
     * @param listnew
    */
    public static void populateAccountId(List<XC_GetFeedbackResponse__c> listNew) {
        
        List<String> contactIds = new List<String>();
        for(XC_GetFeedbackResponse__c gfr : listNew){
            if(!String.isBlank(gfr.XC_Contact__c)){
                contactIds.add(gfr.XC_Contact__c);
            }
        }
        if(contactIds.isEmpty()){
            return;
        }
        Map<Id, Contact> contactQueryMap = new Map<Id, Contact>([SELECT AccountId
                                                                FROM Contact  
                                                                WHERE Id in: contactIds]);
        
        for(XC_GetFeedbackResponse__c gfr : listNew){
            gfr.XC_Account__c = contactQueryMap.get(gfr.XC_Contact__c).AccountId;
        }
    }
}