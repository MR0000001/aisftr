/**
 * Created by snekkanti002 on 16/09/2021.
 */

public without sharing class ContentVersionWrapper {

    public String title;
    public String pathOnClient;
    public Blob contentAsPdf;
    public String origin;
    public String firstPublishLocationId;
    public Boolean isPdfCreate;
    public Boolean isSendAttachmentToGed;

    public ContentVersionWrapper(String title, String pathOnClient, Blob contentAsPdf, String origin, Id firstPublishLocationId, Boolean isPdfCreate, Boolean isSendAttachmentToGed) {
        this.title = title;
        this.pathOnClient = pathOnClient;
        this.contentAsPdf = contentAsPdf;
        this.origin = origin;
        this.firstPublishLocationId = firstPublishLocationId;
        this.isPdfCreate = isPdfCreate;
        this.isSendAttachmentToGed = isSendAttachmentToGed;
    }
}