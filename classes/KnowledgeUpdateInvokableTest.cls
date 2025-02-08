/**
 * Created by RGAROFALO00 on 16/06/2020.
 */

@IsTest
private class KnowledgeUpdateInvokableTest {
    @IsTest
    public static void updateFieldKnowledgeTest() {
        List <Knowledge__kav> listKnowlKavs = TestDataFactory.createKnowledgeInternalFAQ();
        List <Id> idList = new List<Id>();

        for(Knowledge__kav thisKav : listKnowlKavs){
            idList.add(thisKav.id);
        }

        KnowledgeUpdateInvokable.updateFieldKnowledge(idList);
    }
}