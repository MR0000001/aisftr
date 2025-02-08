/**
 * Created by LCONATO00 on 18/06/2020.
 */

public with sharing class RecordTypeDAO {
    public static List<RecordType> getStructuresRecordTypes(){
        List<RecordType> recordTypes = new List<RecordType>();
        recordTypes = [SELECT Id,DeveloperName  FROM RecordType WHERE sObjectType='Structure__c'];
        return recordTypes;
    }
}