/**
 * Created by LCONATO00 on 23/07/2020.
 */

public without sharing class TipologiaTributoDAO {
    public static List<Tipologia_Tributo__mdt> getAllTributesTypologies (){
        List<Tipologia_Tributo__mdt> tributeTypologies = [SELECT ID_Categoria__c,Label FROM Tipologia_Tributo__mdt ORDER BY Label];
        return tributeTypologies;
    }
}