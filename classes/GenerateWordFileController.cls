public class GenerateWordFileController {

    public KnowledgeWrap wrapObj {get;set;}

    public GenerateWordFileController() {
        System.debug('# GenerateWordFileController #');

        String currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('# currentRecordId -> ' + currentRecordId);

        List<Knowledge__kav> KnowledgeList = KnowledgeSelector.getKnowledgeKavsFromId(currentRecordId);

        wrapObj = new KnowledgeWrap();
        if(KnowledgeList[0].ArticleType__c.equalsIgnoreCase(Label.Knowledge_News)){
            wrapObj.expirationDate = KnowledgeList[0].ExpirationDate__c;
            wrapObj.abstractString = KnowledgeList[0].Abstract__c;
            wrapObj.title = KnowledgeList[0].Title;
            wrapObj.body = KnowledgeList[0].Body__c;
            wrapObj.macrostructureReference = KnowledgeList[0].MacrostructureReference__r.ExtendedName__c;
            wrapObj.structureTypeReference = KnowledgeList[0].StructureTypeReference__c;
            wrapObj.isNews = true;
        }else if(KnowledgeList[0].ArticleType__c.equalsIgnoreCase(Label.Knowledge_InternalFAQ)){
            wrapObj.answer = KnowledgeList[0].Answer__c;
            wrapObj.abstractString = KnowledgeList[0].Abstract__c;
            wrapObj.title = KnowledgeList[0].Title;
            wrapObj.body = KnowledgeList[0].Body__c;
            wrapObj.question = KnowledgeList[0].Question__c;
            wrapObj.macrostructureReference = KnowledgeList[0].MacrostructureReference__r.ExtendedName__c;
            wrapObj.structureTypeReference = KnowledgeList[0].StructureTypeReference__c;
            wrapObj.isInternalFAQ = true;
        }else if(KnowledgeList[0].ArticleType__c.equalsIgnoreCase(Label.Knowledge_ExternalFAQ)){
            wrapObj.answer = KnowledgeList[0].Answer__c;
            wrapObj.abstractString = KnowledgeList[0].Abstract__c;
            wrapObj.title = KnowledgeList[0].Title;
            wrapObj.question = KnowledgeList[0].Question__c;
            wrapObj.macrostructureReference = KnowledgeList[0].MacrostructureReference__r.ExtendedName__c;
            wrapObj.structureTypeReference = KnowledgeList[0].StructureTypeReference__c;
            wrapObj.isExternalFAQ = true;
        }else if(KnowledgeList[0].ArticleType__c.equalsIgnoreCase(Label.Knowledge_ProvisionsCC)){
            wrapObj.expirationDate = KnowledgeList[0].ExpirationDate__c;
            wrapObj.abstractString = KnowledgeList[0].Abstract__c;
            wrapObj.title = KnowledgeList[0].Title;
            wrapObj.thematicArea = KnowledgeList[0].ThematicArea__c;
            wrapObj.body = KnowledgeList[0].Body__c;
            wrapObj.macrostructureReference = KnowledgeList[0].MacrostructureReference__r.ExtendedName__c;
            wrapObj.structureTypeReference = KnowledgeList[0].StructureTypeReference__c;
            wrapObj.isProvisionsCC = true;
        }else if(KnowledgeList[0].ArticleType__c.equalsIgnoreCase(Label.Knowledge_ServiceCard)){
            wrapObj.abstractString = KnowledgeList[0].Abstract__c;
            wrapObj.title = KnowledgeList[0].Title;
            wrapObj.who = KnowledgeList[0].Who__c;
            wrapObj.how = KnowledgeList[0].How__c;
            wrapObj.laws = KnowledgeList[0].Laws__c;
            wrapObj.macrostructureReference = KnowledgeList[0].MacrostructureReference__r.ExtendedName__c;
            wrapObj.structureTypeReference = KnowledgeList[0].StructureTypeReference__c;
            wrapObj.isServiceCard = true;
        }


    }


    public class KnowledgeWrap {
        public String question {get;set;}
        public String answer {get;set;}
        public String abstractString {get;set;}
        public String title {get;set;}
        public String thematicArea {get;set;}
        public String who {get;set;}
        public String how {get;set;}
        public String body {get;set;}
        public Date expirationDate {get;set;}
        public String macrostructureReference {get;set;}
        public String laws {get;set;}
        public String structureTypeReference {get;set;}
        public Boolean isNews {get;set;}
        public Boolean isInternalFAQ {get;set;}
        public Boolean isExternalFAQ {get;set;}
        public Boolean isProvisionsCC {get;set;}
        public Boolean isServiceCard {get;set;}
    }

}