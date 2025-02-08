/**
 * The Class XC_LCC008_LeadCallToCommodity.
 *
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 17/09/2018
 * @date Modification 10_10_2018 by Riccardo Cossu - riccardo.cossu@nttdata.com
 * @date Modification 24/10/2018 by Fabrizio Antonioli - Fabrizio.Antonioli@nttdata.com & Giovanni Schioppa - Giovanni.Schioppa@nttdata.com
 * @description XC_LCC005_LeadCallToCommodity – Controller for XC_LCP005_LeadCallToCommodity Component
 */
public class XC_LCC008_LeadCallToCommodity {

	/**
	 * The Class ResultWrapper.
	 * @description ResultWrapper
	 */
	public class ResultWrapper{
		
		/** The success. 
		* @description success
		*/
		@AuraEnabled
		public Boolean success {get; set;} 
		
		/** The record fields. 
		* @description recordFields
		*/
		@AuraEnabled
        public List<FieldWrapper> recordFields {get; set;} 
	}

	/**
	 * @description Field Wrapper
	 * The Class FieldWrapper.
	 */
	public class FieldWrapper{
		
		/** The field label. 
		* @description fieldLabel
		*/
		@AuraEnabled
        public String fieldLabel {get; set;} 
		
		/** The field value. 
		* @description fieldValue
		*/
		@AuraEnabled 
        public String fieldValue {get; set;} 
	}
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC008_LeadCallToCommodity');

	/**
	 * Call commodity.
	 * @description call Commodity
	 * @param recordId the record id
	 * @return the result wrapper
	 */
	@AuraEnabled
	public static ResultWrapper callCommodity(Id recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in callCommodity');
		ResultWrapper result = new ResultWrapper();
		Lead ld = retrieveLead(recordId);
        
		//NEW
		Boolean activeInterface = XC_UTIL_RESTCallout.checkActiveInterface(Label.XC_CL_Lead_CallToCommodity);
        String url = Label.XC_CL_Lead_CallToCommodityURL;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> url To call = '+url);
	    String requestString = '';
		if(activeInterface){
			HttpRequest request = XC_UTIL_RESTCallout.createRequest(url, requestString);
	  		HttpResponse response = XC_UTIL_RESTCallout.sendRequest(request,'XC_LCC008_LeadCallToCommodity');
			result = manageResponse(response);
		} else {
			String fakeResponse = '{"Nombre":"Pablo","Apellidos":"Perez","Correo electrónico":"pablo.perez@gmail.com","Teléfono":"0034915499556","Moviles":"00312736555","Tipo documento identificación":"NIE","Número de documento de identificación":"Z1637541N","Fecha de Nacimiento":"20-05-1989","#KWh ":"3,2 kW","#Energy Account":"LUZ","Control de lista negra":""}';
			result = manageResponseFake(fakeResponse);
			System.debug('RESULT'+result);
		}
		return result; 
	}

	/**
	 * Manage response fake.
	 * @description manage Fake Response
	 * @param fakeResponse the fake response
	 * @return the result wrapper
	 */
	private static ResultWrapper manageResponseFake(String fakeResponse){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in manageResponseFake');
		ResultWrapper result = new ResultWrapper();
		result.recordFields = new List<FieldWrapper>();
		Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(fakeResponse); 
		for(String key : responseMap.keySet()){
        	FieldWrapper wr = new FieldWrapper();
        	wr.fieldLabel = key;
        	wr.fieldValue = (String)responseMap.get(key);
        	result.recordFields.add(wr);
        }
        result.success = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> result='+result);
		return result;
	}

	/**
	 * Manage response.
	 * @description manage response
	 * @param response the response
	 * @return the result wrapper
	 */
	private static ResultWrapper manageResponse(HttpResponse response){
		ResultWrapper result = new ResultWrapper();
		//TODO
		return result;
	}

	/**
	 * Retrieve lead.
	 * @description retrieve Leads
	 * @param recordId the record id
	 * @return the lead
	 */
	private static Lead retrieveLead(Id recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in retrieveLead');
		Lead ld = new Lead();
		return ld;
	}

}