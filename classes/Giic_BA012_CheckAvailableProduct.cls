/**
 * @author Milko Fatiga - milko.fatiga@nttdata.com
 * @description Batch to check Product Availability
 */

public class Giic_BA012_CheckAvailableProduct implements Database.batchable<Sobject>, Schedulable {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_BA012_CheckAvailableProduct');
    
    /**
     * @author Milko Fatiga - milko.fatiga@nttdata.com
     * @description Method to schedule batch
     */
    public void execute(SchedulableContext ctx){
        Database.executebatch(new Giic_BA012_CheckAvailableProduct(), 200);  
    }  

    /**
     * @author Milko Fatiga - milko.fatiga@nttdata.com
     * @description Start batch method
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        //query = 'Select id, giic_SAPtype__c, giic_Stream__c ,giic_Available_for_Sales__c, giic_Generic_Material__c, giic_LegalEntity__c from  gii__Product2Add__c  where   giic_SAPtype__c = \'Material\'  and  giic_Stream__c = \'B2BG\'';
        query = 'SELECT Id, giic_SAPtype__c, giic_Stream__c, giic_Available_for_Sales__c, giic_Generic_Material__c, giic_LegalEntity__c FROM gii__Product2Add__c WHERE giic_SAPtype__c = \'Material\'';
        return Database.getQueryLocator(query);
    } 
    
    /**
     * @author Milko Fatiga - milko.fatiga@nttdata.com
     * @description Execute batch method
     */ 
    public void execute(Database.BatchableContext bc, List<gii__Product2Add__c> scope){
        Map<String,gii__PriceBookEntry__c> pbeMaps = new Map <String,gii__PriceBookEntry__c>();
        List<gii__PriceBookEntry__c> listPbe = new List<gii__PriceBookEntry__c>();
        List<gii__Product2Add__c> product2Add = new List<gii__Product2Add__c>();

        //listPbe = [select id,gii__Product__c,giic_Default__c,   gii__PriceBook__r.giic_Contract__r.EndDate, gii__PriceBook__r.giic_Contract__r.giic_Budget_Residue__c  from gii__PriceBookEntry__c where giic_Default__c = true and gii__Product__c IN: scope];
        listPbe = [ SELECT Id, gii__Product__c, giic_Default__c, gii__PriceBook__r.giic_Contract__r.EndDate, gii__PriceBook__r.giic_Contract__r.giic_Budget_Residue__c  
                    FROM gii__PriceBookEntry__c 
                    WHERE giic_Default__c = true AND gii__PriceBook__r.giic_Contract__r.EndDate >: Date.today() AND gii__PriceBook__r.giic_Contract__r.giic_Budget_Residue__c > 0 AND gii__Product__c IN: scope
                ];
        for(gii__PriceBookEntry__c pbe : listPbe) {
            if(!pbeMaps.containsKey(pbe.gii__Product__c)) {
                pbeMaps.put(pbe.gii__Product__c, pbe);
            }
        }
        
        for(gii__Product2Add__c a : scope) {
            Boolean avForSales = false;
            gii__Product2Add__c p2Add = new gii__Product2Add__c();
            if(a.giic_LegalEntity__c == 'EnelXMobility' || a.giic_LegalEntity__c == 'EnelXItalia' || a.giic_LegalEntity__c == 'EnelXMobilityItalia') {
                avForSales = true;
            }
            else {
                if(pbeMaps.containsKey(a.Id)){
                    if(pbeMaps.get(a.Id).gii__PriceBook__r.giic_Contract__r.EndDate > Date.today() && pbeMaps.get(a.Id).gii__PriceBook__r.giic_Contract__r.giic_Budget_Residue__c > 0) {
                        avForSales = true;
                    }
                }
            }
            p2Add.Id = a.Id;    
            p2Add.giic_Available_for_Sales__c = avForSales;
            product2Add.add(p2Add);         
        }
        
        if(product2Add.size()>0) {
            update product2Add;
        }
    } 
    
    /**
     * @author Milko Fatiga - milko.fatiga@nttdata.com
     * @description Finish batch method
     */    
    public void finish(Database.BatchableContext bc){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finished batch BA012');
    } 
    
}