/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 27/02/2020
 * @description XC_TR_Individual_U_PopulateFields – Class to manage Individual fields on Insert/Update
 */

public without sharing class XC_TR_Individual_U_PopulateFields {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Individual_U_PopulateFields');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 27/02/2020
     * @param listIndividual - List<Individual>
     * @param mapOld - Map<Id, Individual>
     * @param mapNew - Map<Id, Individual>
    */
    public static void updateChildrenFields(List<Individual> listIndividual, Map<Id, Individual> mapOld, Map<Id, Individual> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Populate Fields from Individual Trigger for -> ' + listIndividual);
        List<String> listFieldsChanged = new List<String>{'FirstName', 'LastName'};
        List<Individual> listChanged = XC_UTIL_Sobject.getListChanged(listFieldsChanged, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ List Individual changed -> ' + listChanged);

        List<Individual> listIndividualWithChildren = new List<Individual>([
            SELECT Id, FirstName, LastName,
                (SELECT Id
                FROM Leads)
            FROM Individual
            WHERE Id IN :listChanged
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listIndividualWithChildren -> ' + listIndividualWithChildren);

        List<Lead> listLeadToUpdate = new List<Lead>();
        for(Individual ind : listIndividualWithChildren) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Individual ('+ind.Id+'), #leads -> ' + ind.Leads.size());
            for(Lead ld : ind.Leads) {
                listLeadToUpdate.add(new Lead(
                    Id = ld.Id,
                    FirstName = mapNew.get(ind.Id).FirstName,
                    LastName = mapNew.get(ind.Id).LastName
                ));
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Lead to update -> ' + listLeadToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.updateListRecords(listLeadToUpdate);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Update Lead -> ' + listWr);
    }

}