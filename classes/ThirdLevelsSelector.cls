public with sharing class ThirdLevelsSelector {
    public static List<Terzi_Livelli__c> getThirdLevelsByUfficioURP(String currentQueue) {
        List<Terzi_Livelli__c> thirdLevels = [SELECT Ufficio_Istruttore__c FROM Terzi_Livelli__c WHERE Ufficio_URP__c =: currentQueue];
        return thirdLevels;
    }
}