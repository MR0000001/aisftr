/**
 * Created by LCONATO00 on 23/07/2020.
 */

public without sharing class PosizioniDAO {
    public static List<Posizioni__mdt> getAllPositions (){
        List<Posizioni__mdt> positions = [SELECT Codice_Posizione__c,Label FROM Posizioni__mdt ORDER BY Label];
        return positions;
    }
}