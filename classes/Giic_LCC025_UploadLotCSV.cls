/*
* @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
* @date Creation 31/07/2020
* @date Modification dd/mm/yyyy
* @description 025 component controller
*/

public class Giic_LCC025_UploadLotCSV {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC025_UploadLotCSV');
    
    public static List<String> separateCommas(String input){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ IN separateCommas ' );
        List<String> results = input.split(',');
        for(String result : results) {
            result = result.trim();
        }
        return results;
    }

    
    @AuraEnabled
    public static Giic_CSVObject getCSVObject(String csv_str) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ IN getCSVObject ' );
        List<String> lines_raw = csv_str.split('\n');
        List<String> headers_raw = lines_raw[0].split(';');
        List<List<String>> lines = new List<List<String>>();
        List<Giic_CSVHeader> headers = new List<Giic_CSVHeader>();

        lines_raw.remove(0);

		//Handling fields with commas

        for(String line : lines_raw) {
            List<String> line_sep = line.split(';');
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
        }

        for(String header : headers_raw) {
            System.debug('header = '+header);
            headers.add(new Giic_CSVHeader(header));
        }
		System.debug('Ret = '+lines);
        return new Giic_CSVObject(headers, lines);
    }
    
    
    
    
   
    
    

}