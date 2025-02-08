/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 13/05/2019
* @description XC_DF_Contract – Data Factory for Contract
*/
@isTest
public class XC_DF_Contract {


     /** 
     * @author Marco Ottaviano - mottaviano@deloitte.it
     * @description Method to create Contract from Account List
     * @param accList
     * @return  List<Contract> to insert
    */
    public static List<Contract> createCondominiumContract(List<Account> accList){
        List<Contract> listContracts = new List<Contract>();
        for (Account acc : accList){
            Contract contractToInsert = new Contract();
            contractToInsert.AccountId = acc.Id;
            contractToInsert.StartDate = System.today().addDays(-1);
            contractToInsert.ContractTerm = 12;
            contractToInsert.CurrencyIsoCode = ''; 
           // contractToInsert.Status = 'Active';
            listContracts.add(contractToInsert);
        }
        return listContracts;
    }

     /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to Assets
     * @param n - number of asset
     * @return  List<Asset> to insert
    */
    public static List<Contract> createContracts(Integer n){
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(n);
        insert accountList;
        List<Contract> contractList = new List<Contract>();
        for (Integer i=0; i<n; i++){
            Contract contr = new Contract();
            contr.AccountId = accountList[i].Id;
            contractList.add(contr);
        }
        
        return contractList; 
    }




    /**


    */
}