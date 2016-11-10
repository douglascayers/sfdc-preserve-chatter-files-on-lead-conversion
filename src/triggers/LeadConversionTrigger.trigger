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
trigger LeadConversionTrigger on Lead ( after update ) {

    new LeadConversionTriggerHandler().handleConversion();

}