public with sharing class FileManagerController {
    
    // 1. Fetch recent files the user has access to
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getExistingFiles() {
        return [
            SELECT Id, Title, FileExtension, ContentSize, CreatedDate 
            FROM ContentDocument 
            ORDER BY CreatedDate DESC 
            LIMIT 50
        ];
    }

    // 2. Link all selected files (both new and existing) to the target record
    @AuraEnabled
    public static void linkFilesToRecord(Id recordId, List<Id> documentIds) {
        if (documentIds.isEmpty()) return;

        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        
        // Query existing links to prevent duplicate linking errors
        Set<Id> existingLinkedDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]) {
            existingLinkedDocIds.add(cdl.ContentDocumentId);
        }

        for (Id docId : documentIds) {
            // Only create a link if one doesn't already exist
            if (!existingLinkedDocIds.contains(docId)) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = docId;
                cdl.ShareType = 'V'; // V = Viewer permission, I = Inferred
                cdl.Visibility = 'AllUsers';
                linksToInsert.add(cdl);
            }
        }

        if (!linksToInsert.isEmpty()) {
            try {
                insert linksToInsert;
            } catch (Exception e) {
                throw new AuraHandledException('Error linking files: ' + e.getMessage());
            }
        }
    }
}