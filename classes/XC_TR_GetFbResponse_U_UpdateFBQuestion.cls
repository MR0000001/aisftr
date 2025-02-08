/**
* @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
* @date Creation 07/10/2019
* @date Modification 
* @description Class with methods to Handler of the Survey Trigger XC_TR_GetFeedbackResponse_Handler
*/


public without sharing class XC_TR_GetFbResponse_U_UpdateFBQuestion {
    private final static Integer NUMBER_OF_QA=25;

      /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
     * @param mapOlds - map Id -> old value of the record
    */
    public static void createXCFBQuestionRecordFromResumeSurvey(Map<id,XC_GetFeedbackResponse__c> mapNewS, Map<id,XC_GetFeedbackResponse__c> mapOlds){

        //System.debug('createXCFBQuestionRecordFromUpdate called');
        Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforInsert = new Map<Id,List<Map<String,Object>>>();
        Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforUpdate = new Map<Id,List<Map<String,Object>>>();
        List<String> listofQuestionType = new List<String>();
        Map<String,Object> inputparams = new Map<String,Object>(); //Parametri da passare al metodo cycleonQuestion

        for(XC_GetFeedbackResponse__c feedbackResp : mapNewS.values()) {
            inputparams.put('XC_GetFeedbackResponse__c',feedbackResp);
            inputparams.put('XC_GetFeedbackResponseOLD',mapOlds.get(feedbackResp.Id));

            listofQuestionType.addAll(cycleonQuestion(mapIdFBRespFieldforInsert,mapIdFBRespFieldforUpdate,inputparams));
           
        }//fine for sui record inseriti

        List<XC_GetFeedbackQuestion__c> listRecordToinsert = new List<XC_GetFeedbackQuestion__c>();

        for(Id idGetFeedbackResp : mapIdFBRespFieldforInsert.keySet()) {
            if(!mapIdFBRespFieldforInsert.get(idGetFeedbackResp).isEmpty()) { //se la lista non è vuota -- vuol dire che c'è almeno una coppia domanda risposta popolata
                List<Map<String,Object>> listofMapQAfield = mapIdFBRespFieldforInsert.get(idGetFeedbackResp);
                for(Map<String,Object>  mapQAfield : listofMapQAfield) {
                    XC_TR_GetFbResponse_U_CreateFbQuestion.createGetFeedBackQuestionRecord(mapQAfield,listRecordToinsert);
                }
            }
        }

        if(!listRecordToinsert.isEmpty()) {
            //System.debug('LISTA DA INSERIRE : '+listRecordToinsert);
           List<XC_UTIL_Sobject.WrapperResult> wrRlist=XC_UTIL_Sobject.insertListRecords(listRecordToinsert);
          // System.debug('WRAPPER RESLIST'+wrRlist);
        }

        if(!mapIdFBRespFieldforUpdate.isEmpty()) {
            updateXCFBQuestionrecord(mapIdFBRespFieldforUpdate,listofQuestionType);
        }
    }



     /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method for update the xc_getFeedbackQuestion record when an answer of existing survey is changed
     * @param mapIdFBRespFieldforUpdate - > list of new record
     * @param questionTypeList List of XC_QuestionType__c
    */
    private static void updateXCFBQuestionrecord( Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforUpdate,List<String> questionTypeList) {
        try {
            //List<String> questionTypeList = new List<String>();
            Map<String,Map<String,XC_GetFeedbackQuestion__c>> mapFBResponseAndQuestion= new Map<String,Map<String,XC_GetFeedbackQuestion__c>>();
            List<XC_GetFeedbackQuestion__c> listrecordToUpdate = new List<XC_GetFeedbackQuestion__c>();
            Map<Id,XC_GetFeedbackQuestion__c> mapIdgetFBQuestionRecord = new Map<Id,XC_GetFeedbackQuestion__c>([SELECT Id,XC_Answer__c,XC_QuestionType__c,XC_GfResponse__c FROM XC_GetFeedbackQuestion__c WHERE XC_GfResponse__c IN : mapIdFBRespFieldforUpdate.keyset() AND XC_QuestionType__c IN : questionTypeList]);
            
            if(!mapIdgetFBQuestionRecord.isEmpty()) {
                for(Id key: mapIdgetFBQuestionRecord.keyset()) {
                    if(!mapFBResponseAndQuestion.containsKey(mapIdgetFBQuestionRecord.get(key).XC_GfResponse__c)) {
                        mapFBResponseAndQuestion.put(mapIdgetFBQuestionRecord.get(key).XC_GfResponse__c,new Map<String,XC_GetFeedbackQuestion__c>());
                    }
                    
                    mapFBResponseAndQuestion.get(mapIdgetFBQuestionRecord.get(key).XC_GfResponse__c).put(mapIdgetFBQuestionRecord.get(key).XC_QuestionType__c,mapIdgetFBQuestionRecord.get(key));
                }

               listrecordToUpdate.addAll(addChangedAnswer(mapIdFBRespFieldforUpdate,mapFBResponseAndQuestion));

                List<XC_UTIL_Sobject.WrapperResult> wrRlis= XC_UTIL_Sobject.updateListRecords(listrecordToUpdate);
            }

        } catch(Exception e) {
           // System.debug('Exception e'+e.getMessage() + ' '+e.getCause());
        }
    } 


    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description 
     * @param mapIdFBRespFieldforUpdate - > list of new record
     * @param mapFBResponseAndQuestion 
     * @return List<XC_GetFeedbackQuestion__c> -> list record to be updated
    */
    private static List<XC_GetFeedbackQuestion__c> addChangedAnswer (Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforUpdate,Map<String,Map<String,XC_GetFeedbackQuestion__c>> mapFBResponseAndQuestion) {
       List<XC_GetFeedbackQuestion__c> listrecordToUpdate = new  List<XC_GetFeedbackQuestion__c>();

       for(String key: mapFBResponseAndQuestion.keyset()) {
            if(mapIdFBRespFieldforUpdate.containsKey(key)) {
                Map<String,XC_GetFeedbackQuestion__c> mapTypeRecord = mapFBResponseAndQuestion.get(key);
                List<Map<String,Object>> listofQuestionField = mapIdFBRespFieldforUpdate.get(key);
                        
                for(Map<String,Object> mapFieldvalue : listofQuestionField) {
                            
                    String keyQuestionType = String.valueof(mapFieldvalue.get('XC_QuestionType__c'));
                    String newAnswer = String.valueOf(mapFieldvalue.get('XC_Answer__c'));
                    //System.debug('QUESSTION TYPE:'+keyQuestionType + ' '+ newAnswer);
                        
                    if(mapFBResponseAndQuestion.get(key).containsKey(keyQuestionType)) {
                        XC_GetFeedbackQuestion__c recordToUp = mapFBResponseAndQuestion.get(key).get(keyQuestionType);
                        recordToUp.XC_Answer__c = newAnswer;
                        listrecordToUpdate.add(recordToUp);
                    }
                }
            }
        }

        return listrecordToUpdate;
    }

    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param mapIdFBRespFieldforInsert 
     * @param mapIdFBRespFieldforUpdate
     * @param inputparams
     * @return cycleonQuestion Map of parameterOutput
    */
    private static List<String> cycleonQuestion( Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforInsert,  Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforUpdate, Map<String,object> inputparams) {
        List<String> listofQuestionType = new List<String>();
        XC_GetFeedbackResponse__c feedbackResp = (XC_GetFeedbackResponse__c) inputparams.get('XC_GetFeedbackResponse__c');
        XC_GetFeedbackResponse__c feedbackRespOld = (XC_GetFeedbackResponse__c) inputparams.get('XC_GetFeedbackResponseOLD');

        for(Integer i=1;i<=NUMBER_OF_QA;i++) {   //FOR Sul numero dei campi Domanda/Risposta dell'oggetto XC_GetFeedbackResponse__c
            inputparams.put('Iteration',i);

            String fieldQuestion='XC_Question'+i+'__c';
            String fieldQuestionid='XC_QuestionID'+i+'__c';

            if( String.isNotBlank(String.valueOf(feedbackResp.get(fieldQuestion))) && String.isNotBlank(String.valueOf(feedbackResp.get(fieldQuestion))) ) {
                Map<String,Object> mapParamOutput=populateMapFields(mapIdFBRespFieldforInsert,mapIdFBRespFieldforUpdate,inputparams);
                if(mapParamOutput.containsKey('XC_QuestionType__c')) {
                    listofQuestionType.add(String.valueof(mapParamOutput.get('XC_QuestionType__c')));
                }
            }

        } //fine for numero di coppia Domanda/Risposta

        return listofQuestionType;
    }



    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it & Federico Melella fmelella@deloitte.it
     * @description Method to be executed on after insert
     * @param mapIdFBRespFieldforInsert 
     * @param mapIdFBRespFieldforUpdate
     * @param inputparams
     * @return populateMapFields Map of parameterOutput
    */
    private static Map<String,Object> populateMapFields ( Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforInsert,  Map<Id,List<Map<String,Object>>> mapIdFBRespFieldforUpdate, Map<String,object> inputparams) {
        Map<String,Object> mapOutputParam = new  Map<String,Object> ();

        Integer i = Integer.valueOf(inputparams.get('Iteration'));
        XC_GetFeedbackResponse__c feedbackResp = (XC_GetFeedbackResponse__c) inputparams.get('XC_GetFeedbackResponse__c');
        XC_GetFeedbackResponse__c feedbackRespOld = (XC_GetFeedbackResponse__c) inputparams.get('XC_GetFeedbackResponseOLD');
        // Map<String,Object> mapQAfield = new Map<String,Object>(); 
        String fieldQuestion='XC_Question'+i+'__c';
        String fieldAnswer='XC_Answer'+i+'__c';
        String fieldQuestionid='XC_QuestionID'+i+'__c';
        Map<String,Object> mapQAfield = new Map<String,Object>(); 

        //USSUMIAMO CHE LA DOMANDA IN FASE DI RESUME NON CAMBI -- CAMBIA SOLO LA RISPOSTA DATA AD UNA DOMANDA O VENGA COMPLETATO IL SURVEY ANDANDO A POPOLARE ALTRE RISPOSTE
        // SE CAMBIA LA RISPOSTA AD UNA DOMANDA GIà DATA --> ANDIAMO A FARE L'UPDATE DI UN RECORD XC_FEEDBACKQuestion__c
        // ALTRIMENTI SE VIENE POPOLATA UNA RISPOSTA NUOVA FACCIAMO L'INSERT

        if(String.isNotBlank(String.valueOf(feedbackResp.get(fieldAnswer))) && String.valueOf(feedbackResp.get(fieldAnswer)) != String.valueOf( feedbackRespOld.get(fieldAnswer)) && feedbackRespOld.get(fieldAnswer) == null  ) {
           //VEDIAMO SE é CAMBIATA LA RISPOSTA RISPETTO A QUELLA DATA IN PRECEDENZA E LA RISPOSTA DATA IN PRECEDENZA ERA NULLA
            List<Map<String,Object>> listofMapQAfield = null;
               
            if(!mapIdFBRespFieldforInsert.containsKey(feedbackResp.Id)) {    
                mapIdFBRespFieldforInsert.put(feedbackResp.Id,new List<Map<String,Object>>()) ;
            }
            listofMapQAfield = mapIdFBRespFieldforInsert.get(feedbackResp.Id);
            /*mapQAfield.put('XC_GfResponse__c',feedbackResp.Id);
            mapQAfield.put('XC_QuestionNumber__c',i);                 // ORDINE CON CUI POPOLO LA MAPPA  -- SONO I CAMPI DELL'OGGETTO XC_FEEDBACKQuestion__c
            mapQAfield.put('XC_QuestionType__c',feedbackResp.get(fieldQuestionid));
            mapQAfield.put('XC_QuestionText__c',feedbackResp.get(fieldQuestion));  
            mapQAfield.put('XC_Answer__c',feedbackResp.get(fieldAnswer));*/

            listofMapQAfield.add(XC_TR_GetFbResponse_U_CreateFbQuestion.addmapQAfield(feedbackResp,i)); //aggiungo la mappa alla lista            
         

        } //CASO IN CUI LA RISPOSTA é CAMBIATA RISPETTO ALLA PRECEDENTE MA LA PRECEDNETE ERA COMUNQUE POPOLATA 
        else if(String.isNotBlank(String.valueOf(feedbackResp.get(fieldAnswer))) && String.valueOf(feedbackResp.get(fieldAnswer)) != String.valueOf( feedbackRespOld.get(fieldAnswer)) && String.isNotBlank(String.valueOf(feedbackRespOld.get(fieldAnswer))) ) { 
            List<Map<String,Object>> listofMapQAfield = null;
            //  System.debug('CAMBIO RISPOSTA');
            if(!mapIdFBRespFieldforUpdate.containsKey(feedbackResp.Id)) {
                mapIdFBRespFieldforUpdate.put(feedbackResp.Id,new List<Map<String,Object>>()) ;
            }
            listofMapQAfield = mapIdFBRespFieldforUpdate.get(feedbackResp.Id);
                  
            mapQAfield.put('XC_QuestionType__c',feedbackResp.get(fieldQuestionid));
            mapQAfield.put('XC_Answer__c',feedbackResp.get(fieldAnswer));

            listofMapQAfield.add(mapQAfield); //aggiungo la mappa alla lista 

            //listofQuestionType.add(String.valueOf(feedbackResp.get(fieldQuestionid)));
            mapOutputParam.put('XC_QuestionType__c',String.valueOf(feedbackResp.get(fieldQuestionid)));
                
        }
        return mapOutputParam;
    }


 
}