/**
 * The Class XC_TR_SurveyResponse_createCase.
 *
 * @author Giulio Serra giserra@deloitte.it
 * @date Creation 11/12/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_SurveyResponse_createCase - create cases based on the negative feedbacks
 */ 
public class XC_TR_SurveyResponse_createCase {

	/** The minimum satisfaction score. */
	private static Integer minimumSatisfactionScore = 3; // minimum score to trigger   

	/**
	 * Creates the cases.
	 *
	 * @author Giulio Serra giserra@deloitte.it
	 * @param responses the responses
	 * @date Creation 11/12/2018
	 * @date Modification dd/mm/yyyy
	 * @description createCaseFromResponses - create cases based on the negative feedbacks of the responses
	 */
	/*public static void createCases(List<Survey_Response__c> responses){
		XC_UTIL_Case.createCasesFromSurveys(responses,minimumSatisfactionScore);
	}*/
}