/**
 * Created by snekkanti002 on 20/01/2023.
 */

@IsTest
public class TestResponseGeoromaStreetDetails {

    @TestSetup
    public static void setup() {

    }

    @IsTest
    public static void  testResponseGeoromaStreetDetails() {
        Test.startTest();
        ResponseGeoromaStreetDetails responseGeoromaStreetDetails = new ResponseGeoromaStreetDetails();
        responseGeoromaStreetDetails.bbox = new List<Double>();
        Test.stopTest();
    }
}