/**
 * Created by LCONATO00 on 19/05/2020.
 */

public with sharing class KnowledgeSelectorWithSharing {
    public static List<Knowledge__kav> getKnowLedgeWithGenericConditions(List<String> knowLedgeFields, List<String> whereClause, Datetime creationDateFrom, Datetime creationDateTo) {
        String query = 'SELECT ';
        for(Integer i=0; i<knowLedgeFields.size(); i++)
            query += knowLedgeFields[i]+' ,';
        query = query.substring(0, query.length()-1);
        query += 'FROM Knowledge__kav';
        if(whereClause != null && !whereClause.isEmpty()){
            query += ' WHERE ';
            for(Integer i=0; i<whereClause.size(); i++)
                query += whereClause[i]+' AND';
            query = query.substring(0, query.length()-3);
        }
        return (List<Knowledge__kav>) Database.query(query);
    }

}