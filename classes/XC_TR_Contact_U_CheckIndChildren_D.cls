/**
 * The Class XC_TR_Contact_U_CheckIndChildren_D.
 *
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 11/10/2018
 * @date Modification dd/mm/yyyy
 * @description  XC_TR_Contact_U_CheckIndChildren_D – DAO for the XC_TR_Contact_U_CheckIndividualChildren class
 */

public without sharing class XC_TR_Contact_U_CheckIndChildren_D {

	/**
	 * @description Gets the map ID to individual.
	 * @param individualId the individual id
	 * @return the map ID to individual
	 */
	public static Map<Id, Individual> getMapIDToIndividual(Set<ID> individualId) {
	    Map<Id,Individual> mapMyIndividual = new Map<Id,Individual>([
			SELECT Id ,(
			SELECT Id FROM Contacts) FROM Individual WHERE Id IN : individualId
		]);
	    return mapMyIndividual;
	}
}