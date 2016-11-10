/**
 * Inspired by Gorav Seth and Matthew Souther, https://success.salesforce.com/0D53A00002uKsks
 *
 * Developed by Doug Ayers, douglascayers.com
 */
@isTest
private class LeadConversionTriggerHandlerTest {

    @isTest
    static void test_convert_lead() {

        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            company = 'Salesforce'
        );

        insert ld;

        ContentNote note = new ContentNote(
            title = 'Story',
            content = Blob.valueOf( 'Goodnight Moon' )
        );

        insert note;

        note = [ SELECT id, latestPublishedVersion.contentDocumentId FROM ContentNote WHERE id = :note.id ];

        ContentDocumentLink noteLink = new ContentDocumentLink(
            linkedEntityId = ld.id,
            contentDocumentId = note.latestPublishedVersion.contentDocumentId,
            shareType = 'V'
        );

        insert noteLink;

        ContentVersion file = new ContentVersion(
            versionData = Blob.valueOf( 'Hello World' ),
            title = 'Message',
            pathOnClient = '/'
        );

        insert file;

        file = [ SELECT id, contentDocumentId FROM ContentVersion WHERE id = :file.id ];

        ContentDocumentLink fileLink = new ContentDocumentLink(
            linkedEntityId = ld.id,
            contentDocumentId = file.contentDocumentId,
            shareType = 'V'
        );

        insert fileLink;

        Test.startTest();

        LeadStatus convertStatus = [ SELECT id, masterLabel FROM LeadStatus WHERE isConverted = true LIMIT 1 ];

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId( ld.id );
        lc.setConvertedStatus( convertStatus.masterLabel );

        Database.LeadConvertResult lcr = Database.convertLead( lc );

        Test.stopTest();

        System.assert( lcr.isSuccess() );

        // our triggerest
        System.assertEquals( 1, [ SELECT count() FROM ContentDocumentLink WHERE linkedEntityId = :lcr.getAccountId() AND contentDocumentId = :fileLink.contentDocumentId ] );
        System.assertEquals( 1, [ SELECT count() FROM ContentDocumentLink WHERE linkedEntityId = :lcr.getContactId() AND contentDocumentId = :fileLink.contentDocumentId ] );
        System.assertEquals( 1, [ SELECT count() FROM ContentDocumentLink WHERE linkedEntityId = :lcr.getOpportunityId() AND contentDocumentId = :fileLink.contentDocumentId ] );

        // what salesforce does automatically
        System.assertEquals( 1, [ SELECT count() FROM ContentDocumentLink WHERE linkedEntityId = :lcr.getAccountId() AND contentDocumentId = :noteLink.contentDocumentId ] );
        System.assertEquals( 1, [ SELECT count() FROM ContentDocumentLink WHERE linkedEntityId = :lcr.getContactId() AND contentDocumentId = :noteLink.contentDocumentId ] );
        System.assertEquals( 0, [ SELECT count() FROM ContentDocumentLink WHERE linkedEntityId = :lcr.getOpportunityId() AND contentDocumentId = :noteLink.contentDocumentId ] );

    }

}