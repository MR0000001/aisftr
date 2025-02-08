/*
* @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
* @date Creation 31/07/2020
* @date Modification dd/mm/yyyy
* @description CSV Object
*/
public class Giic_CSVObject {
    
    @AuraEnabled
    public List<Giic_CSVHeader> headers {get; set;}

    @AuraEnabled
    public List<List<String>> lines {get; set;}

    @AuraEnabled
    public Integer line_count {get; set;}

    public Giic_CSVObject() {}

    public Giic_CSVObject(List<Giic_CSVHeader> headers, List<List<String>> lines) {
        this.headers = headers;
        this.lines = lines;
        this.line_count = lines.size();
    }

}