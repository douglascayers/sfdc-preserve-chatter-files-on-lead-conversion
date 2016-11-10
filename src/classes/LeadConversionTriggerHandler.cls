/**
 * Designed to share Salesforce Files that were shared with converted leads
 * to the newly converted Accounts, Contacts, and Opportunities.
 *
 * During Lead conversion, Salesforce automatically shares Enhanced Notes
 * to the newly converted Account and Contact but leaves behind the Chatter Files.
 * This solution fills that functionality gap.
 *
 * Inspired by Gorav Seth and Matthew Souther, https://success.salesforce.com/0D53A00002uKsks
 *
 * Developed by Doug Ayers, douglascayers.com
 */
public with sharing class LeadConversionTriggerHandler {

    /**
     * Lead trigger can simply call this method rather than have logic in the trigger itself.
     * Identifies all the leads being converted in this transaction.
     */
    public void handleConversion() {

        if ( Trigger.isAfter ) {

            if ( Trigger.isUpdate ) {

                List<Lead> convertedLeads = new List<Lead>();

                for ( Lead newRecord : (List<Lead>) Trigger.new ) {

                    Lead oldRecord = (Lead) Trigger.oldMap.get( newRecord.id );

                    if ( newRecord.isConverted && !oldRecord.isConverted ) {
                        convertedLeads.add( newRecord );
                    }

                }

                handleConvertedLeads( convertedLeads );

            }

        }

    }

    public void handleConvertedLeads( List<Lead> convertedLeads ) {

        Map<ID, Lead> convertedLeadsMap = new Map<ID, Lead>( convertedLeads );

        Set<ID> convertedLeadIds = convertedLeadsMap.keySet();

        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();

        // Get all file links excluding enhanced notes because
        // salesforce already automatically carries the enhanced notes
        // over to the converted account and contact.
        // Enhanced Notes are identified as documents with FileType of 'SNOTE'
        // https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_contentdocument.htm
        List<ContentDocumentLink> fileLinks = new List<ContentDocumentLink>([
            SELECT
                id, linkedEntityId, contentDocumentId, shareType
            FROM
                ContentDocumentLink
            WHERE
                linkedEntityId IN :convertedLeadIds
                AND
                contentDocument.fileType != 'SNOTE'
        ]);

        for ( ContentDocumentLink fileLink : fileLinks ) {

            Lead convertedLead = convertedLeadsMap.get( fileLink.linkedEntityId );

            if ( convertedLead != null ) {

                // share file to account
                if ( String.isNotBlank( convertedLead.convertedAccountId ) ) {
                    linksToInsert.add( new ContentDocumentLink(
                        linkedEntityId = convertedLead.convertedAccountId,
                        contentDocumentId = fileLink.contentDocumentId,
                        shareType = fileLink.shareType
                    ));
                }

                // share file to contact
                if ( String.isNotBlank( convertedLead.convertedContactId ) ) {
                    linksToInsert.add( new ContentDocumentLink(
                        linkedEntityId = convertedLead.convertedContactId,
                        contentDocumentId = fileLink.contentDocumentId,
                        shareType = fileLink.shareType
                    ));
                }

                // share file to opportunity
                if ( String.isNotBlank( convertedLead.convertedOpportunityId ) ) {
                    linksToInsert.add( new ContentDocumentLink(
                        linkedEntityId = convertedLead.convertedOpportunityId,
                        contentDocumentId = fileLink.contentDocumentId,
                        shareType = fileLink.shareType
                    ));
                }

            }

        }

        if ( linksToInsert.size() > 0 ) {
            insert linksToInsert;
        }

    }

}