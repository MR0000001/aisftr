@isTest
public class HttpCalloutMockFactory {
    
    
    public static void setMocks(){
    	generateMocks(null, null, null, null);
    }
    
    public static void setMocks(String endpoint, String body, Integer statusCode, String status){
    	generateMocks(endpoint, body, statusCode, status);
    }
    
    public static void setMocks(List<Map<String,String>> paramsList){
    	Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
    	
    	for(Map<String,String> m : paramsList){
    		SingleRequestMock mock = new SingleRequestMock(Integer.valueOf(m.get('statusCode')), m.get('status'), m.get('body'), null);
        	endpoint2TestResp.put(m.get('endpoint'), mock);
    	}
    	
    	HttpCalloutMock multiCalloutMock =new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
    }
    
    
    private static void generateMocks(String endpoint, String body, Integer statusCode, String status){
    	Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        if(endpoint != null){
        	SingleRequestMock mock = new SingleRequestMock(statusCode, status, body, null);
        	endpoint2TestResp.put(endpoint, mock);
        }
        //convertPdfPreview
        endpoint2TestResp.put('callout:AUC', AUCMock());
        
        HttpCalloutMock multiCalloutMock =new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
    }

    
    private static HttpCalloutMock AUCMock(){
        return new SingleRequestMock(200,'Complete','stringBase64',null);
    }
    
    
}