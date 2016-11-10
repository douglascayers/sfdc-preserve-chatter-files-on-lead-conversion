# Preserve Chatter Files on Lead Conversion

Simple Lead trigger that moves Chatter Files to the converted Account, Contact, and Opportunity upon Lead Conversion. You might also be interested in my blog post about [Advanced Lead Conversion using Process Builder](https://douglascayers.com/2016/06/26/advanced-lead-conversion-with-process-builder/).

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

As of this writing, Salesforce does not preserve Chatter or related Files during conversion operation. The Files are left orphaned.

Inspired by [Gorav Seth](https://twitter.com/goravseth)'s realization of this on [Success Community](https://success.salesforce.com/0D53A00002uKsks), and by [Matthew Souther](https://www.linkedin.com/in/matthewsouther)'s comment of suggested solution,
I developed this simple trigger to demonstrate how to preserve and carry over the [Chatter Files](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_contentdocument.htm) to the converted Account, Contact, and Opportunity.

I had originally hoped to solution this using only Process Builder and Flow, but since Salesforce already supports bringing over Enhanced Notes to the converted Account and Contact during Lead conversion, I needed to filter out all `ContentDocumentLink` records whose `ContentDocument.FileType = 'SNOTE'`, something I could not readily figure out in Flow but could easily do in SOQL in Apex.

# Usage

Deploy the trigger as-is, or integrate it into your own Apex trigger framework, to simply call the `LeadConversionTriggerHandler` class
for the `after update` trigger event.

    trigger LeadConversionTrigger on Lead ( after update ) {
        new LeadConversionTriggerHandler().handleConversion();
    }

Technically, you can call the code for all events and the handler knows what to do, but minimally the after update event must be included.
