/**
 * @author            : Davide Desideri
 * @created date      : 
 * @description       : 
 * @testClasses       : KMSearchControllerTest
 * @last modified by  : Davide Desideri
 * @last modified on  : 03-02-2023
**/

/**
 * Created by LCONATO00 on 15/05/2020.
 */

public with sharing class KMSearchController {
    /* wrapper class */
    @TestVisible
    public class knowledgeListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Knowledge__kav objKnowledge{get;set;}
        public knowledgeListWrapper(boolean isChecked, Knowledge__kav objKnowledge){
            this.isChecked = isChecked;
            this.objKnowledge = objKnowledge;
        }
    }
    @AuraEnabled
    public static List<knowLedgeListWrapper> fetchKnowledgeWrapper(String tipologyId, Datetime creationDateFrom, Datetime creationDateTo, String knowledgeStatus,String structureId,String textToSearchInQuery){

        List<knowledgeListWrapper> lstknwoledgeListWrapper = new List<knowledgeListWrapper>();
        List<Knowledge__kav> listKnowledge = new List<Knowledge__kav>();
        //String querySELECT = ' (NOT RecordType.Name LIKE \'%Publish%\')';
        List<String> querySELECT = new List<String>();
        if(tipologyId != null){
            querySELECT.add(' ArticleType__c LIKE \'%'+tipologyId+'%\'');
        }
        if(creationDateFrom != null){
            querySELECT.add(' CreatedDate >: creationDateFrom');
        }
        if(creationDateTo != null){
            creationDateTo = creationDateTo.addDays(1).addSeconds(-1);
            querySELECT.add(' CreatedDate <: creationDateTo');
        }
        if(knowledgeStatus != null){
            querySELECT.add(' PublishStatus = \''+knowledgeStatus+'\'');
        }
        if(structureId != null){
            querySELECT.add(' MacrostructureReference__c = \''+structureId+'\'');
        }
        // if(textToSearchInQuery != null){
        //     querySELECT.add(' Title LIKE \'%'+textToSearchInQuery+'%\'');
        //     // querySELECT.add(' Abstract__c LIKE \'%'+textToSearchInQuery+'%\'');
        // }
        listKnowledge = KnowledgeSelectorWithSharing.getKnowLedgeWithGenericConditions(new String[]{'Id','Title','ArticleType__c','toLabel(PublishStatus)', 'CreatedDate','Abstract__c','MacrostructureReference__r.ExtendedName__c','Priority__c','MacrostructureReference__c',
        'Category__c'},querySELECT, creationDateFrom, creationDateTo);
        // query account records and create 'accountListWrapper' class instance for each record.
        for(Knowledge__kav knowledge : listKnowledge){
            // by default checkbox should be false

            //     if(knowledge.Abstract__c!=null){
            //         knowledge.Abstract__c = knowledge.Abstract__c.replaceAll('<[^>]+>','');
            //         knowledge.Abstract__c = knowledge.Abstract__c.replaceAll('&#39;','\'');
            //     }
            // lstknwoledgeListWrapper.add(new knowledgeListWrapper(false,knowledge));
            if(knowledge.Abstract__c!=null){
                knowledge.Abstract__c = knowledge.Abstract__c.replaceAll('<[^>]+>','');
                knowledge.Abstract__c = knowledge.Abstract__c.replaceAll('&#39;','\'');
            }
            if(String.isBlank(textToSearchInQuery)){
                lstknwoledgeListWrapper.add(new knowledgeListWrapper(false,knowledge));
            }else if((knowledge.Abstract__c!=null && knowledge.Abstract__c.containsIgnoreCase(textToSearchInQuery)) || (knowledge.Title!=null && knowledge.Title.containsIgnoreCase(textToSearchInQuery))){
                lstknwoledgeListWrapper.add(new knowledgeListWrapper(false,knowledge));
            }
        }
        // return the 'lstaccountListWrapper' list
        return lstknwoledgeListWrapper;
    }
    @AuraEnabled
    public static Map<String, String> getTipologiesName (){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeSObjectResult describeKnowledge = Schema.SObjectType.Knowledge__kav;
        Map<Id,Schema.RecordTypeInfo> rtMapById = describeKnowledge.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> rtMapByName = describeKnowledge.getRecordTypeInfosByName();
        String currentUserId = UserInfo.getUserId();
        User currentUser = UserSelector.getUserbyId(currentUserId);
        String currentUserProfile = currentUser.Profile.Name;
        for(String str : rtMapByName.keySet()){
            Schema.RecordTypeInfo rtInfo = rtMapByName.get(str);
            String rtName = rtInfo.getName();
            if(!rtName.contains('Publish') && !rtName.contains('Master') && !rtName.contains('Principale') && !(rtName.contains('Disposizioni CC') && currentUserProfile.containsIgnoreCase('urp'))){
                options.put(rtName,rtName);
            }

        }
        return options;
    }

    @AuraEnabled
    public static Map<String, String> getStatusName (){
        Map<String, String> options = new Map<String, String>();
        //get Knowledge Industry Field Describe
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.PublishStatus.getDescribe();
        //get knowledge status Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

}